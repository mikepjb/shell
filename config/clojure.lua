-- Minimal nREPL client for Neovim
-- ~250 lines total (core logic + integration)

local M = {}
local uv = vim.loop

-- ============================================================================
-- BENCODE
-- ============================================================================

local function bencode(val)
  local typ = type(val)
  if typ == "number" then
    return "i" .. tostring(val) .. "e"
  elseif typ == "string" then
    return tostring(#val) .. ":" .. val
  elseif typ == "table" then
    if val[1] then  -- has numeric index = list
      local r = "l"
      for _, v in ipairs(val) do r = r .. bencode(v) end
      return r .. "e"
    else  -- dict
      local r = "d"
      local keys = {}
      for k in pairs(val) do table.insert(keys, k) end
      table.sort(keys)
      for _, k in ipairs(keys) do
        r = r .. bencode(k) .. bencode(val[k])
      end
      return r .. "e"
    end
  end
  error("bencode: unsupported type " .. typ)
end

local function bdecode()
  local pos, buf = 0, ""

  local function peek() return pos <= #buf and buf:sub(pos, pos) or nil end
  local function consume() local c = peek(); pos = pos + 1; return c end

  local function decode_int()
    consume()
    local start = pos
    while peek() ~= "e" do consume() end
    local n = tonumber(buf:sub(start, pos - 1))
    consume()
    return n
  end

  local function decode_str()
    local start = pos
    while peek() ~= ":" do consume() end
    local len = tonumber(buf:sub(start, pos - 1))
    consume()
    local s = buf:sub(pos, pos + len - 1)
    pos = pos + len
    return s
  end

  local function decode_list()
    consume()
    local list = {}
    while peek() ~= "e" do table.insert(list, decode_val()) end
    consume()
    return list
  end

  local function decode_dict()
    consume()
    local dict = {}
    while peek() ~= "e" do
      dict[decode_str()] = decode_val()
    end
    consume()
    return dict
  end

  function decode_val()
    local c = peek()
    if c == "i" then return decode_int()
    elseif c == "l" then return decode_list()
    elseif c == "d" then return decode_dict()
    elseif c and c:match("%d") then return decode_str()
    end
  end

  return function(chunk)
    if chunk then buf = buf .. chunk end
    local msgs = {}
    while pos <= #buf do
      local start = pos
      local ok, msg = pcall(decode_val)
      if ok and msg then
        table.insert(msgs, msg)
      else
        pos = start
        break
      end
    end
    return msgs
  end
end

-- ============================================================================
-- CONNECTION
-- ============================================================================

local conn = {
  socket = nil,
  connected = false,
  decoder = bdecode(),
  callbacks = {},
  id = 0,
  port = nil,
}

local function next_id()
  conn.id = conn.id + 1
  return conn.id
end

local function send_msg(msg, callback)
  if not conn.connected or not conn.socket then
    vim.notify("Not connected to nREPL", vim.log.levels.WARN)
    return
  end
  local id = next_id()
  msg.id = id
  if callback then conn.callbacks[id] = callback end
  conn.socket:write(bencode(msg))
end

local function handle_response(err, chunk)
  if err then
    vim.notify("nREPL error: " .. err, vim.log.levels.ERROR)
    conn.connected = false
    return
  end
  if not chunk or chunk == "" then return end

  for _, msg in ipairs(conn.decoder(chunk)) do
    if msg.id and conn.callbacks[msg.id] then
      conn.callbacks[msg.id](msg)
    end
  end
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

function M.connect(host, port)
  host = host or "127.0.0.1"
  port = port or tonumber(vim.fn.readfile(".nrepl-port")[1] or "")

  if not port then
    vim.notify("No nREPL port found. Specify port or create .nrepl-port", vim.log.levels.ERROR)
    return
  end

  if conn.connected and conn.port == port then
    vim.notify("Already connected to nREPL:" .. port, vim.log.levels.INFO)
    return
  end

  local socket = uv.new_tcp()
  socket:connect(host, port, function(err)
    vim.schedule(function()
      if err then
        vim.notify("Failed to connect to nREPL:" .. port .. " - " .. err, vim.log.levels.ERROR)
      else
        conn.socket = socket
        conn.connected = true
        conn.port = port
        socket:read_start(handle_response)
        vim.notify("Connected to nREPL:" .. port, vim.log.levels.INFO)
      end
    end)
  end)
end

function M.eval(code, opts, callback)
  opts = opts or {}
  if not conn.connected then M.connect() end
  if not conn.connected then return end

  local msg = {
    op = "eval",
    code = code,
    session = opts.session or "main",
    ns = opts.ns or "user",
  }

  local buffer = {}
  send_msg(msg, function(resp)
    if resp.out then buffer.out = (buffer.out or "") .. resp.out end
    if resp.err then buffer.err = (buffer.err or "") .. resp.err end
    if resp.value then buffer.value = (buffer.value or "") .. resp.value end

    if resp.status and vim.tbl_contains(resp.status, "done") then
      conn.callbacks[resp.id] = nil
      if callback then callback(buffer) end
    end
  end)
end

function M.disconnect()
  if conn.socket then
    conn.socket:read_stop()
    conn.socket:shutdown()
    conn.socket:close()
  end
  conn.connected = false
  conn.socket = nil
end

function M.setup()
  -- Connect to nREPL
  vim.api.nvim_buf_create_user_command(0, "CljConnect", function(args)
    local port = args.args ~= "" and tonumber(args.args) or nil
    M.connect("127.0.0.1", port)
  end, { nargs = "?" })

  -- Eval code
  vim.api.nvim_buf_create_user_command(0, "CljEval", function(args)
    if args.range == 2 then
      local lines = vim.api.nvim_buf_get_lines(0, args.line1 - 1, args.line2, false)
      M.eval(table.concat(lines, "\n"), {}, function(resp)
        vim.notify((resp.value or resp.out or resp.err or "nil"), vim.log.levels.INFO)
      end)
    else
      M.eval(args.args, {}, function(resp)
        vim.notify((resp.value or resp.out or resp.err or "nil"), vim.log.levels.INFO)
      end)
    end
  end, { nargs = "*", range = true })

  -- Test current namespace
  vim.api.nvim_buf_create_user_command(0, "CljTest", function()
    local ns = vim.fn.expand("%:t:r"):gsub("-", "_")
    M.eval("(clojure.test/run-tests '" .. ns .. ")", {}, function(resp)
      vim.notify((resp.value or resp.out or resp.err or "nil"), vim.log.levels.INFO)
    end)
  end, {})

  -- Require namespace
  vim.api.nvim_buf_create_user_command(0, "CljRequire", function(args)
    local ns = vim.fn.expand("%:t:r"):gsub("-", "_")
    local reload = args.bang and "-all" or ""
    M.eval("(require '" .. ns .. " :reload" .. reload .. ")", {}, function()
      vim.notify("Reloaded " .. ns, vim.log.levels.INFO)
    end)
  end, { bang = true })

  -- Keybinds
  local opts = { buffer = 0, noremap = true, silent = true }

  -- cqp: quasi-REPL prompt
  vim.keymap.set("n", "cqp", function()
    vim.ui.input({ prompt = vim.fn.expand("%:t:r") .. "=> " }, function(input)
      if input then
        M.eval(input, {}, function(resp)
          vim.notify((resp.value or resp.out or resp.err or "nil"), vim.log.levels.INFO)
        end)
      end
    end)
  end, opts)

  -- cpr: require + test
  vim.keymap.set("n", "cpr", function()
    vim.cmd("CljRequire")
    vim.cmd("CljTest")
  end, opts)
end

return M
