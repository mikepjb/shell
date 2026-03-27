-- Spartan Neovim -------------------------------------------------------------

local config = {
    -- Editing
    wrap = false, textwidth = 79, colorcolumn = '+1',
    tabstop = 4, shiftwidth = 4, expandtab = true, smartindent = true,
    splitbelow = true, splitright = true,
    scrolloff = 8,

    -- Persistence & State
    swapfile = false, backup = false, undofile = true,
    undodir = os.getenv("HOME") .. "/.config/nvim/undodir",
    clipboard = 'unnamedplus',

    -- User Interface
    number = true, guicursor = '', shortmess = 'CTIoltOF',
    fillchars = "stl:─,stlnc:─,vert:│",
    statusline = "── %#User1#%f%*%< (%{&ft})%m%r%h%w %= ( %3l,%3c,%3p%% )",
    termguicolors = os.getenv("COLORTERM") == 'truecolor',

    -- Search & Completion
    ignorecase = true, smartcase = true, gdefault = true,
    wildmode = 'longest:full,full', 
    wildignore = '*.o,*.obj,*.pyc,*.class,*/.git/*,*/node_modules/*',
    completeopt = { 'menu', 'menuone', 'noselect' },
    grepprg = vim.fn.executable("rg") == 1 and 'rg --vimgrep' or 'grep -rn $* .',
    grepformat = vim.fn.executable("rg") == 1 and '%f:%l:%c:%m' or '%f:%l:%m',
} for k, v in pairs(config) do vim.opt[k] = v end

-- Add config directory to runtimepath for lua modules
vim.opt.runtimepath:prepend(os.getenv("HOME") .. "/src/shell/config")

local global_config = {
    -- Netrw & Navigation
    netrw_banner = 0, netrw_liststyle = 3, netrw_winsize = -25,
    netrw_list_hide = '^\\.git/$,^\\..*$,\\.swp$,\\.tmp$,node_modules',

    -- Language Options
    markdown_fenced_languages = { 'css', 'javascript', 'bash', 'go', 'sql', 'yaml', 'rust' },
    omni_sql_no_default_maps = 1, -- don't use C-c for autocompletion in SQL.
} for k, v in pairs(global_config) do vim.g[k] = v end

-- Functions ------------------------------------------------------------------
local function fmt(fn, ...)
    local args = {...}
    return function()
        if vim.fn.executable(fn) == 0 then
            return vim.notify(fn .. " not found, cannot format the buffer")
        end

        local cmd, file = {fn}, vim.fn.expand("%:p")
        for _, arg in ipairs(args) do table.insert(cmd, arg) end
        table.insert(cmd, file)
        vim.system(cmd, { text = true }, function(obj)
            vim.schedule(function() -- reload but save view position
                if obj.code == 0 then
                    local view = vim.fn.winsaveview()
                    vim.cmd('edit!')
                    vim.fn.winrestview(view)
                else
                    vim.notify(obj.stdout .. obj.stderr, vim.log.levels.INFO)
                end
            end)
        end)
    end
end

local repl_map = {
    clojure       = {"clj", "clojure"},
    clojurescript = {"clj", "shadow-cljs"},
    python        = {"python", "python3", "ipython"},
    ruby          = {"irb", "pry"},
    javascript    = {"node", "bun", "deno"},
    typescript    = {"node", "bun", "deno"},
    lua           = {"lua"},
    sql           = {"sqlite3", "psql", "mysql"},
}

local repl_state = { pane_id = nil }

local function pane_is_valid(pane_id)
    vim.fn.system('tmux display-message -t ' .. vim.fn.shellescape(pane_id) .. ' -p "" 2>/dev/null')
    return vim.v.shell_error == 0
end

local function find_repl_pane(callback)
    if repl_state.pane_id and pane_is_valid(repl_state.pane_id) then
        return callback(repl_state.pane_id)
    end
    repl_state.pane_id = nil

    local cwd = vim.fn.getcwd()
    local current_pane = vim.fn.system('tmux display-message -p "#{pane_id}"'):gsub('\n', '')
    local candidates = repl_map[vim.bo.filetype] or {}
    local output = vim.fn.system('tmux lsp -aF "#{pane_id} #{pane_pid} #{pane_current_path} #{pane_current_command}"')

    local matches = {}
    for line in output:gmatch("[^\n]+") do
        local id, pid, path, cmd = line:match("(%S+) (%S+) (%S+) (%S+)")
        if id and pid and path and cmd and path == cwd and id ~= current_pane then
            local proc_match = false
            for _, proc in ipairs(candidates) do
                if cmd == proc then proc_match = true; break end
            end
            if not proc_match and #candidates > 0 then
                -- some REPLs run under a different process (e.g. clojure runs as java)
                local child_cmds = vim.fn.system('pgrep -P ' .. pid .. ' | xargs -I{} ps -p {} -o args= 2>/dev/null')
                for _, proc in ipairs(candidates) do
                    if child_cmds:find(proc, 1, true) then proc_match = true; break end
                end
            end
            table.insert(matches, { id = id, path = path, cmd = cmd, proc = proc_match })
        end
    end

    local pool = vim.tbl_filter(function(p) return p.proc end, matches)
    if #pool == 0 then pool = matches end

    if #pool == 0 then
        local fallback = vim.fn.system('tmux lsp -aF "#D#T" | sed -n s/repl//p | tr -d "\n"')
        if fallback ~= '' then
            repl_state.pane_id = fallback
            return callback(fallback)
        end
        return vim.notify("No REPL pane found — is your REPL running from " .. cwd .. "?")
    end

    if #pool == 1 then
        repl_state.pane_id = pool[1].id
        return callback(pool[1].id)
    end

    vim.ui.select(
        vim.tbl_map(function(p) return string.format("[%s] %s", p.cmd, p.path) end, pool),
        { prompt = "Select REPL pane: " },
        function(_, idx)
            if idx then
                repl_state.pane_id = pool[idx].id
                callback(pool[idx].id)
            end
        end
    )
end

local function send_to_repl(text)
    find_repl_pane(function(pane_id)
        local escaped = text:gsub('"', '\\"')
        vim.fn.system(string.format('tmux send -t %s "%s" Enter', pane_id, escaped))
    end)
end

local function tmux_send_lines()
    local lines = vim.api.nvim_buf_get_lines(0, vim.fn.line("v") - 1, vim.fn.line("."), false)
    send_to_repl(table.concat(lines, '\n'))
end

local function tmux_send_buffer()
    local lines = vim.api.nvim_buf_get_lines(0, 1, vim.fn.line("$"), false)
    send_to_repl(table.concat(lines, '\n'))
end

local function tmux_send_prompt()
    local input = vim.fn.input('=> ')
    if input ~= '' then send_to_repl(input) end
end

vim.api.nvim_create_user_command('ReplReset', function()
    repl_state.pane_id = nil
    vim.notify("REPL pane selection cleared")
end, {})

vim.api.nvim_create_user_command('FindFiles', function(opts)
  local cmd = opts.args ~= '' and string.format('rg --files | rg -S "%s"', opts.args) or 'rg --files'
  local output = vim.fn.system(cmd)
  local files = vim.split(output, '\n', { trimempty = true })

  if #files > 0 then
      vim.fn.setqflist(vim.tbl_map(function(file)
          return { filename = file }
      end, files))
      if #files > 1 then
          vim.cmd('copen')
      else
          vim.cmd('cclose')
      end
      vim.cmd('cfirst')
  else vim.notify("No matches found") end
end, { nargs = '?' })

vim.api.nvim_create_user_command('Grep', function(opts)
    vim.cmd('silent! grep!' .. opts.args .. ' | redraw!')
    if #vim.fn.getqflist() > 0 then vim.cmd('copen | cfirst')
    else vim.notify("No matches found") end
end, { nargs = '+' })

function grep_under_cursor()
    vim.cmd(":Grep -w " .. vim.fn.expand("<cword>"))
end

vim.api.nvim_create_user_command('TrimWhitespace', ':%s/\\s\\+$//e', {})

vim.api.nvim_create_user_command('LspRestart', function()
    vim.lsp.stop_client(vim.lsp.get_clients())
end, {})

local function apply_opts(opts)
    return function()
        for key, value in pairs(opts) do vim.opt_local[key] = value end
    end
end

local function edit_relative()
    vim.api.nvim_feedkeys(':e ' .. vim.fn.expand('%:p:h') .. '/', 'n', true)
end

-- Keybinds -------------------------------------------------------------------
local keymaps = {
    {"n", "<C-h>", "<C-w><C-h>"}, {"n", "<C-j>", "<C-w><C-j>"},
    {"n", "<C-k>", "<C-w><C-k>"}, {"n", "<C-l>", "<C-w><C-l>"},
    {"i", "<C-c>", "<Esc>"}, {"n", "S", "<C-^>"}, {"n", "<C-q>", ":q<CR>"},
    {"v", "t", "<Esc>`<^i<div><Esc>`>a</div><Esc>"}, -- div wrapper
    {"n", "cqp", tmux_send_prompt},
    {"v", "gp", tmux_send_lines},   {"n", "gp", tmux_send_buffer},
    {"n", "gs", ":Grep "}, {"n", "gS", grep_under_cursor},
    {"n", "<space>", ":FindFiles "},
    {"i", "<C-l>", " => "},
    {"i", "<C-y>", " -> "},
    {"n", "<M-n>", ":cnext<CR>"},   {"n", "<M-p>", ":cprev<CR>"},
    {"n", "<C-g>", ":noh<CR><C-g>"}, {"i", "<C-d>", "<Del>"},
    {"n", "gi", ":e ~/.config/nvim/init.lua<CR>"},
    {"n", "gG", ":e ~/.notes/projects/lh.md<CR>"},
    {"n", "gn", ":e ~/.notes/index.md<CR>"},
    {"n", "gj", ":e ~/.notes/cookie-jar.md<CR>"},
    {"n", "g0", ":LspRestart<CR>:e!<CR>"},
    {"n", "<M-t>", ":terminal verify<CR>"},
    {"n", "gl", function()
        local qf_winid = vim.fn.getqflist({winid = 0}).winid
        vim.cmd(qf_winid ~= 0 and 'cclose' or 'copen')
    end},
    {'n', 'ge', edit_relative},
    {'n', '<C-t>', ":Lexplore<CR>"},
} for _, km in ipairs(keymaps) do vim.keymap.set(km[1], km[2], km[3]) end

-- Autocmds
local base = vim.api.nvim_create_augroup('Base', { clear = true })

local autocmds = {
    {"FileType", {
        "clojure", "scheme", "javascript", "typescript",
        "json", "javascriptreact", "typescriptreact",
        "html", "tmpl", "yaml", "ruby", "markdown", "css", "sql"
    }, apply_opts({shiftwidth = 2, tabstop = 2, softtabstop = 2})},
    {"FileType", {"csv", "json", "xml"}, apply_opts({tw = 0, wrap = false})},
    {"FileType", "markdown", apply_opts({nu = false, wrap = true, lbr = true, tw = 65})},
    {"FileType", "netrw", function()
        vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { buffer = true })
    end},
    {"BufWritePre", "*.go", fmt("goimports", "-w")},
    {"BufWritePre", "*.rs", fmt("rustfmt", "--edition", "2024")},
    {"BufWritePre", "*.templ", fmt("templ", "fmt")},
    -- {"BufWritePre", "*.js,*.jsx,", fmt("prettier", "--write")},
    -- {"BufWritePre", "*.ts,*.tsx,*.css,*.json,*.svg", fmt("deno", "fmt")},
    {"BufWritePre", "*.sql", fmt("sql-formatter", "--fix", "-l", "sqlite")},
    {'TermOpen', '*', apply_opts({nu = false})},
    {'BufWritePre', '*', function()
        local dir = vim.fn.expand('<afile>:p:h')
        if vim.fn.isdirectory(dir) == 0 then vim.fn.mkdir(dir, 'p') end
    end},
}

for _, ac in ipairs(autocmds) do
    vim.api.nvim_create_autocmd(
        ac[1], {group = base, pattern = ac[2], callback = ac[3]}
    )
end

-- LSP Configuration ----------------------------------------------------------
local function find_root(markers)
    local path = vim.fn.expand('%:p:h')
    while path ~= '/' do
        for _, marker in ipairs(markers) do
            if vim.loop.fs_stat(path .. '/' .. marker) then
                return path
            end
        end
        path = vim.fn.fnamemodify(path, ':h')
    end
    return nil
end

vim.api.nvim_create_autocmd('FileType', {
    pattern = {'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'json'},
    callback = function()
        local deno_root = find_root({'deno.json', 'deno.jsonc'})
        if deno_root then
            vim.lsp.start({
                name = 'denols',
                cmd = {'deno', 'lsp'},
                root_dir = deno_root,
            })
        else
            local ts_root = find_root({'package.json', 'tsconfig.json'})
            if ts_root then
                vim.lsp.start({
                    name = 'tsserver',
                    cmd = {'typescript-language-server', '--stdio'},
                    root_dir = ts_root,
                })
            end
        end
    end,
})

vim.api.nvim_create_autocmd('FileType',
    {
        pattern = 'java', callback = function()
            local java_root = find_root({'gradlew', 'mvnw', 'pom.xml'})
            vim.lsp.start({
                name = 'jdtls',
                cmd = {'jdtlsw'},
                root_dir = java_root,
            })
        end
    }
)


vim.api.nvim_create_autocmd('FileType', {
    pattern = {'go'},
    callback = function()
        local go_root = find_root({'go.mod'})
        vim.lsp.start({
            name = 'gopls',
            cmd = {'gopls'},
            root_dir = go_root,
        })
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = {'rust'},
    callback = function()
        local rust_root = find_root({'Cargo.toml'})
        vim.lsp.start({
            name = 'rust-analyzer',
            cmd = {'rust-analyzer'},
            root_dir = rust_root,
        })
    end,
})

-- Basic LSP keymaps
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)

      vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'ga', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', 'K', function()
            local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
            if #diagnostics > 0 then
                vim.diagnostic.open_float()
            else
                vim.lsp.buf.hover()
            end
        end, opts)
    end,
})

pcall(vim.cmd, 'colorscheme spartan') -- Try colorscheme, fallback to default

-- Define highlight group for navi window background (brighter black/dark gray)
vim.api.nvim_set_hl(0, "NaviBackground", { bg = "#1a1a1a", fg = "White" })

vim.fn.setreg('n', [[
  # Facts

  # Procedures

  # Concepts

  # Questions
  ]])

-- TODO include typescript + deno LSP without plugins
-- potentially include `test-run` as CR alias.
