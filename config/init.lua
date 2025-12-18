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

local global_config = {
    -- Netrw & Navigation
    netrw_banner = 0, netrw_liststyle = 3, netrw_winsize = -25,
    netrw_list_hide = '^\\.git/$,^\\..*$,\\.swp$,\\.tmp$,node_modules',

    -- Language Options
    markdown_fenced_languages = { 'css', 'javascript', 'bash', 'go', 'sql' },
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

local function repl_pane()
    return vim.fn.system('tmux lsp -aF "#D#T" | sed -n s/repl//p | tr -d "\n"')
end

local function tmux_send(dst, text)
    if dst == '' then
        return vim.notify("REPL terminal could not be found")
    end
    local escaped = text:gsub('"', '\\"')
    vim.fn.system(string.format('tmux send -t %s "%s" Enter', dst, escaped))
end

local function tmux_send_lines()
    local lines = vim.api.nvim_buf_get_lines(
        0, vim.fn.line("v") - 1, vim.fn.line("."), false
    )
    tmux_send(repl_pane(), table.concat(lines, '\n'))
end

local function tmux_send_buffer()
    local lines = vim.api.nvim_buf_get_lines(0, 1, vim.fn.line("$"), false)
    tmux_send(repl_pane(), table.concat(lines, '\n'))
end

local function tmux_send_prompt()
    tmux_send(repl_pane(), vim.fn.input('=> '))
end

vim.api.nvim_create_user_command('FindFiles', function(opts)
  if opts.args ~= '' then
    local cmd = string.format('rg --files | rg -S "%s"', opts.args)
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
  end
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
    {"i", "<C-y>", "- [ ] "},
    {"n", "<M-n>", ":cnext<CR>"},   {"n", "<M-p>", ":cprev<CR>"},
    {"n", "<C-g>", ":noh<CR><C-g>"}, {"i", "<C-d>", "<Del>"},
    {"n", "gi", ":e ~/.config/nvim/init.lua<CR>"},
    {"n", "gn", ":e ~/.notes/index.md<CR>"},
    {"n", "<M-t>", ":terminal test-run<CR>"},
    {"n", "gl", function()
        local qf_winid = vim.fn.getqflist({winid = 0}).winid
        vim.cmd(qf_winid ~= 0 and 'cclose' or 'copen')
    end},
    {'n', 'ge', edit_relative},
    {'n', 'gL', ":Lexplore<CR>"},
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
    {"BufWritePre", "*.templ", fmt("templ", "fmt")},
    {"BufWritePre", "*.js,*.jsx,", fmt("prettier", "--write")},
    {"BufWritePre", "*.ts,*.tsx,*.css,*.json,*.svg", fmt("deno", "fmt")},
    {"BufWritePre", "*.sql", fmt("sql-formatter", "--fix", "-l", "postgresql")},
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

vim.fn.setreg('n', [[
  # Facts

  # Procedures

  # Concepts

  # Questions
  ]])

-- TODO include typescript + deno LSP without plugins
-- potentially include `test-run` as CR alias.
