-- TODO still need to check :make & :compiler
-- setlocal makeprg=flake8\ %
-- setlocal errorformat=%f:%l:%c:\ %t%n\ %m
-- TODO tab titles based on pwd
-- :set guitablabel=%{exists('t:mytablabel')?t:mytablabel\ :''}
-- in example mytablabel is a tab local var, set it when you tcd and all good?

local opt = vim.opt
local optl = vim.opt_local
local optg = vim.g
local cmd = vim.api.nvim_create_user_command
local map = vim.keymap.set

-- editing
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.wrap = false
opt.textwidth = 79

-- UI
opt.guicursor = '' -- always use block cursor
opt.fillchars = "vert:│"
opt.statusline = " %#User1#%f%*%< (%{&ft})%m%r%h%w %= ( %3l,%3c,%3p%% )"
opt.number = true
opt.colorcolumn = '+1'
opt.termguicolors = false
opt.showtabline=2
opt.laststatus=2
opt.wildmode = 'longest:full,full'
opt.wildignore = '*.o,*.obj,*.pyc,*.class,*/.git/*,*/node_modules/*'
opt.completeopt = { 'menu', 'menuone', 'noselect' }
opt.pumheight = 15

-- editor
opt.clipboard = 'unnamedplus'
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = os.getenv("HOME") .. "/.config/nvim/undodir"

-- search
opt.showmatch = true
opt.incsearch = true
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.gdefault = true
opt.grepprg = vim.fn.executable("rg") == 1 and 'rg --vimgrep' or 'grep -rn $* .'
opt.grepformat = vim.fn.executable("rg") == 1 and '%f:%l:%c:%m' or '%f:%l:%m'

-- language
optg.markdown_fenced_languages = { 'css', 'bash', 'sql', 'clojure' }
optg.omni_sql_no_default_maps = 1
optg.sh_noisk = 1

vim.cmd.colorscheme('spartan')

map('n', '<C-h>', '<C-w><C-h>')
map('n', '<C-j>', '<C-w><C-j>')
map('n', '<C-k>', '<C-w><C-k>')
map('n', '<C-l>', '<C-w><C-l>')
map('n', '<C-q>', ':q<CR>')
map('n', '<C-c>', '<Esc>')
map('n', '<C-c>', '<Esc>')
map('n', '<M-n>', ':cnext<CR>')
map('n', '<M-p>', ':cprevious<CR>')
map('n', 'Q', '@q')
map('n', 'gs', ':grep ')
map('n', '<C-g>', ':noh<CR><C-g>')
map('n', '<C-g>', ':noh<CR><C-g>')
map('n', 'S', '<C-^>')
map('n', 'gi', ':e ~/.config/nvim/init.lua<CR>')
map('n', 'gn', ':e ~/.notes/index.md<CR>')
map("n", "gl", function()
    local qf_winid = vim.fn.getqflist({winid = 0}).winid
    vim.cmd(qf_winid ~= 0 and 'cclose' or 'copen')
end)
map("n", "ge", function()
    vim.api.nvim_feedkeys(':e ' .. vim.fn.expand('%:p:h') .. '/', 'n', true)
end)
map('n', '<space>', ':Telescope find_files<CR>')
map('n', 'gb', ':G blame<CR>')
map('n', '<M-c>', ':Connect<CR>')

map('i', '<C-l>', ' => ')

local base = vim.api.nvim_create_augroup('Base', { clear = true })

local autocmd = function(event, pattern, callback)
    vim.api.nvim_create_autocmd(event, {
        group = base, pattern = pattern, callback = callback,
    })
end

autocmd('FileType', {
    'clojure', 'scheme', 'javascript', 'typescript', 'json',
    'javascriptreact', 'typescriptreact', 'html', 'yaml',
    'ruby', 'markdown', 'css', 'sql'
}, function()
    optl.shiftwidth = 2
    optl.tabstop = 2
end)

autocmd('FileType', { 'markdown' }, function()
    optl.number = false
end)

autocmd('FileType', { 'csv', 'json', 'xml' }, function()
    optl.textwidth = 0
    optl.wrap = false
end)

autocmd('BufWritePre', '*', function()
    local dir = vim.fn.expand('<afile>:p:h')
    if vim.fn.isdirectory(dir) == 0 then vim.fn.mkdir(dir, 'p') end
end)

-- autocmd('CmdwinEnter', '*' function()
--     autocmd
-- end)

-- custom functions

-- TODO format (on key press)
-- TODO generate ctags (language, deps, project?)
-- TODO rename file!

cmd('TrimWhitespace', ':%s/\\s\\+$//e', {})

-- TODO current AI integration, is there a better way to do this?
-- smaller model?
-- sync response only but streamed?
-- ! type stream command -> buffer to easily copy?
local function consult()
    local mode = vim.api.nvim_get_mode().mode
    local context = ""

    -- Grab visual selection if it exists
    if mode:match("[vV\22]") then
        local s, e = vim.fn.getpos("'<"), vim.fn.getpos("'>")
        context = table.concat(vim.fn.getregion(s, e, { type = vim.fn.visualmode() }), "\n")
    end

    vim.ui.input({ prompt = 'consult> ' }, function(input)
        if not (input and input ~= "") then return end

        vim.system({ "consult", input }, { stdin = context }, function(obj)
            vim.schedule(function()
                if obj.code ~= 0 then return vim.notify("Error: " .. obj.stderr, 3) end

                -- Get or create buffer
                local buf = vim.fn.bufnr("*consult*", true)
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(obj.stdout, "\n"))
                vim.bo[buf].filetype, vim.bo[buf].buftype = "markdown", "nofile"

                local win = vim.fn.bufwinid(buf)
                if win == -1 then
                    local split_cmd = vim.o.columns > (vim.o.lines * 2) and "vsplit" or "split"
                    vim.cmd(split_cmd .. " | b " .. buf)
                end
            end)
        end)
    end)
end

map({'n', 'v'}, '<M-a>', consult, { desc = "Consult LLM" })

-- TODO until you have ctags
local function register_lsp(pattern, markers, cmd)
    vim.api.nvim_create_autocmd('FileType', {
        pattern = pattern,
        callback = function()
            if vim.fn.executable(cmd[1]) == 1 then
                local root_path = find_root(markers)
                vim.lsp.start({
                    name = cmd[1],
                    cmd = cmd,
                    root_dir = root_path,
                })
            end
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
