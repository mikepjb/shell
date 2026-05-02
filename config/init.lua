-- Spartan Neovim -------------------------------------------------------------
--
-- TODO ctags generation (universal ctags.. with deep tags)
-- TODO port theme to ghostty and neovim

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

local global_config = {
    markdown_fenced_languages = {
        'css', 'javascript', 'bash', 'go', 'sql', 'yaml', 'rust', 'clojure'
    },
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

local function dynamic_split(cmd)
    if cmd == nil then cmd = '' end
    local win_width = vim.api.nvim_win_get_width(0)
    local win_height = vim.api.nvim_win_get_height(0)
    
    local split_modifier = 'split'
    if win_width > (win_height * 2.5) or win_width > 120 then
        split_modifier = 'vsplit'
    end

    vim.cmd(split_modifier .. ' | terminal ' .. cmd)
    vim.cmd('startinsert')

    return {
        buf = vim.api.nvim_get_current_buf(),
        chan = vim.b.terminal_job_id
    }
end

local repl_state = { buf = nil, chan = nil }
local repl_map = {
    javascript = 'node',
    clojure    = 'clj',
    java       = 'jshell',
    python     = 'python3',
    lua        = 'lua',
    sql        = 'sqlite3',
}

local function repl(force_manual)
    local ft = vim.bo.filetype
    local cmd = repl_map[ft]

    -- Internal helper to finalize the REPL setup
    local function start(choice)
        local res = dynamic_split(choice)
        repl_state.buf = res.buf
        repl_state.chan = res.chan
        -- Tag the buffer so we can find it in :ls
        pcall(vim.api.nvim_buf_set_name, res.buf, "REPL [" .. choice .. "]")
    end

    if force_manual or not cmd then
        local options = vim.tbl_values(repl_map)
        vim.ui.select(options, { prompt = 'Select REPL:' }, function(choice)
            if choice then start(choice) end
        end)
    else
        start(cmd)
    end
end

local function send_to_repl()
    if not repl_state.chan or not vim.api.nvim_buf_is_valid(repl_state.buf) then
        vim.notify("No active REPL session found. Use <leader>r or <leader>R first.")
        return
    end

    local lines
    local mode = vim.fn.mode()
    if mode == 'v' or mode == 'V' or mode == ' ' then
        -- Exit visual mode to update marks
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), 'x', false)
        local start_line = vim.fn.line("'<")
        local end_line = vim.fn.line("'>")
        lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    else
        lines = { vim.api.nvim_get_current_line() }
    end

    vim.api.nvim_chan_send(repl_state.chan, table.concat(lines, "\n") .. "\n")
end

local function verify(full_suite) -- dynamically run the right test suite
    if full_suite == nil then full_suite = false end

    local path = vim.api.nvim_buf_get_name(0)
    
    local shell_cmd = "verify"
    if not full_suite then
        shell_cmd = shell_cmd .. " " .. path
    end
    dynamic_split(shell_cmd)
end

-- Keybinds -------------------------------------------------------------------
local keymaps = {
    {"n", "<M-t>", function() verify(false) end},
    {"n", "<M-T>", function() verify(true) end},
    {"n", "<M-r>", repl},
    {"n", "<M-R>", function() repl(true) end},
    {"n", "<M-s>", send_to_repl},
    {"v", "<M-s>", send_to_repl},
    {"n", "<M-o>", "<C-w><C-w>"}, {"t", "<M-o>", "<C-\\><C-n><C-w><C-w>"},
    {"n", "<C-h>", "<C-w><C-h>"}, {"n", "<C-j>", "<C-w><C-j>"},
    {"n", "<C-k>", "<C-w><C-k>"}, {"n", "<C-l>", "<C-w><C-l>"},
    {"i", "<C-c>", "<Esc>"}, {"n", "S", "<C-^>"}, {"n", "<C-q>", ":q<CR>"},
    {"i", "<C-l>", " => "},
    {"i", "<C-y>", " -> "},
    {"n", "<M-n>", ":cnext<CR>"},   {"n", "<M-p>", ":cprev<CR>"},
    {"n", "<C-g>", ":noh<CR><C-g>"}, {"i", "<C-d>", "<Del>"},
    {"n", "gi", ":e ~/.config/nvim/init.lua<CR>"},
    {"n", "gG", ":e ~/.notes/projects/lh.md<CR>"},
    {"n", "gn", ":e ~/.notes/index.md<CR>"},
    {"n", "gj", ":e ~/.notes/cookie-jar.md<CR>"},
    {"n", "g0", ":LspRestart<CR>:e!<CR>"},
    {"n", "gl", function()
        local qf_winid = vim.fn.getqflist({winid = 0}).winid
        vim.cmd(qf_winid ~= 0 and 'cclose' or 'copen')
    end},
    {'n', 'ge', edit_relative},
    {'t', '<C-g>', '<C-\\><C-n>'},
    {'t', '<C-h>', '<C-\\><C-n><C-w><C-h>'},
    {'t', '<C-k>', '<C-\\><C-n><C-w><C-k>'},
    {'t', '<C-j>', '<C-\\><C-n><C-w><C-j>'},
    {'n', '<C-t>', dynamic_split},
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
    {"BufWritePre", "*.go", fmt("goimports", "-w")},
    {"BufWritePre", "*.rs", fmt("rustfmt", "--edition", "2024")},
    -- {"BufWritePre", "*.js,*.jsx,", fmt("prettier", "--write")},
    -- {"BufWritePre", "*.ts,*.tsx,*.css,*.json,*.svg", fmt("deno", "fmt")},
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

local function register_lsp(pattern, root, cmd)
    vim.api.nvim_create_autocmd('FileType', {
        pattern = pattern,
        callback = function()
            vim.lsp.start({
                name = cmd[1],
                cmd = cmd,
                root_dir = root,
            })
        end
    })
end

register_lsp('java', {'gradlew', 'mvnw', 'pom.xml'}, {'jdtlsw'})
register_lsp('go',   {'go.mod'}, {'gopls'})
register_lsp('rust', {'Cargo.toml'}, {'rust-analyzer'})
register_lsp(
    {'javascript', 'typescript'},
    {'package.json'},
    {'typescript-language-server', '--stdio'}
)

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

local ok, telescope = pcall(require, "telescope")

if ok then
    vim.keymap.set('n', '<space>', ':Telescope find_files<CR>')
    vim.keymap.set('n', '<M-i>', ':Telescope live_grep<CR>')
    vim.keymap.set('n', '<M-b>', ':Telescope buffers<CR>')
else
    vim.keymap.set('n', '<space>', ':Findfiles ')
end
