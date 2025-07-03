-- Spartan Neovim -------------------------------------------------------------

-- Editing & Navigation
vim.opt.wrap = false
vim.opt.textwidth = 79
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.scrolloff = 8
vim.opt.colorcolumn = "+1"

-- Persistence & State
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.config/nvim/undodir"
vim.opt.clipboard:append({ "unnamedplus" }) -- integrate with system clipboard

-- UI Options
vim.opt.number = true
vim.opt.guicursor = ""
vim.opt.shortmess:append("I")
vim.opt.fillchars = "stl:─,stlnc:─,vert:│"
vim.opt.statusline = "── %#User1#%f%*%< (%{&ft})%m%r%h%w %= ( %3l,%3c,%3p%% )"
vim.opt.termguicolors = os.getenv("COLORTERM") == 'truecolor'

-- Search & Completion
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.gdefault = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignore = "*.o,*.obj,*.pyc,*.class,*/.git/*,*/node_modules/*"
vim.opt.tags = "./tags"
vim.opt.grepprg = "grep -rn $* ."
if vim.fn.executable("rg") == 1 then
    vim.opt.grepprg, vim.opt.grepformat = "rg --vimgrep", "%f:%l:%c:%m"
end

-- Language Options
vim.g.markdown_fenced_languages = { 'typescript', 'javascript', 'bash', 'go' }
vim.g.omni_sql_no_default_maps = 1 -- don't use C-c for autocompletion in SQL.

-- Functions ------------------------------------------------------------------
local function show_tree()
    vim.cmd('terminal tree -a -I .git --gitignore --prune --noreport')
end

local function fmt(fn, args)
    return function()
        if vim.fn.executable(fn) == 0 then
            return vim.notify(fn .. " not found, cannot format the buffer")
        end

        local file = vim.fn.expand("%:p")
        vim.system({fn, args, file}, { text = true }, function(obj)
            vim.schedule(function() -- reload but save view position
                if obj.code == 0 then
                    local view = vim.fn.winsaveview()
                    vim.cmd('checktime')
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

local function tmux_send(text)
    local dst = repl_pane()
    if text == '' or text == nil or dst == '' then return end

    local escaped = text:gsub('"', '\\"')
    vim.fn.system(string.format('tmux send -t %s "%s" Enter', dst, escaped))
end

local function tmux_send_lines()
    local fl, ll = vim.fn.line("v"), vim.fn.line(".")
    local lines = vim.api.nvim_buf_get_lines(0, fl - 1, ll, false)
    tmux_send(table.concat(lines, '\n'))
end

local function tmux_send_buffer()
    local lines = vim.api.nvim_buf_get_lines(0, 1, vim.fn.line("$"), false)
    tmux_send(table.concat(lines, '\n'))
end

local function tmux_send_prompt()
    if repl_pane() == '' then
        return vim.notify("REPL terminal could not be found")
    end
    tmux_send(vim.fn.input('=> '))
end

vim.api.nvim_create_user_command('Grep', function(opts)
    vim.cmd('silent! grep!' .. opts.args)
    vim.cmd('redraw!')  -- clear any lingering output
    if #vim.fn.getqflist() > 0 then vim.cmd('copen | cfirst')
    else vim.notify("No matches found") end
end, { nargs = '+' })

vim.api.nvim_create_user_command('TrimWhitespace', function()
    vim.cmd '%s/\\s\\+$//e'
end, {})

-- Keybinds -------------------------------------------------------------------
-- TODO readline M-d/f/b on the command/ex mode line
local keymaps = {
    {"c", "<C-a>", "<S-Left>"}, -- more portable opt than s-left?
    {"n", "<C-h>", "<C-w><C-h>"}, {"n", "<C-j>", "<C-w><C-j>"},
    {"n", "<C-k>", "<C-w><C-k>"}, {"n", "<C-l>", "<C-w><C-l>"},
    {"n", "<C-q>", ":q<CR>"},     {"n", "<C-g>", ":noh<CR><C-g>"},
    {"i", "<C-l>", " => "},       {"i", "<C-u>", " -> "},
    {"i", "<C-c>", "<Esc>"},      {"n", "S", "<C-^>"},
    {"i", "<C-d>", "<Del>"},
    {"n", "<M-u>", show_tree},
    {"n", "<M-q>", ":Inspect<CR>"},
    {"n", "Q", "@q"},
    {"n", "cqp", tmux_send_prompt},
    {"v", "gp", tmux_send_lines},
    {"n", "gp", tmux_send_buffer},
    {"n", "gd", "<C-]>"},           -- go to definition
    {"n", "gD", "g<C-]>"},          -- choose which definition to go to
    {"n", "<M-t>", ":terminal test-run<CR>"},
    {"t", "<C-g>", "<C-\\><C-n>"},
    {"t", "S", "<C-\\><C-n><C-^>"},
    {"v", "<C-g>", "y<C-w><C-w>pa<CR>"},
    {"n", "gn", ":e ~/.tmp-notes<CR>"},
    {"n", "gi", ":e ~/.config/nvim/init.lua<CR>"},
    {"n", "<M-n>", ":cnext<CR>"},
    {"n", "<M-p>", ":cprev<CR>"},
    {"n", "gl", function()
        local qf_winid = vim.fn.getqflist({winid = 0}).winid
        vim.cmd(qf_winid ~= 0 and 'cclose' or 'copen')
    end},
    {"n", "gs", ":Grep "},
    {"n", "gS", function() vim.cmd(":Grep -w " .. vim.fn.expand("<cword>")) end},
    {'n', 'ge', function()
        local current_dir = vim.fn.expand('%:p:h')
        local input_cmd = ':e ' .. current_dir .. '/'
        vim.opt.backupskip:append('*') -- Avoid backup file issues
        vim.api.nvim_feedkeys(input_cmd, 'n', true)
    end, { desc = 'Create/edit file relative to current buffer' }},
} for _, km in ipairs(keymaps) do vim.keymap.set(km[1], km[2], km[3]) end

-- Autocmds
local base = vim.api.nvim_create_augroup('Base', { clear = true })
local vol = vim.opt_local

local autocmds = {
    {"FileType", {
        "clojure", "scheme", "javascript", "typescript",
        "json", "javascriptreact", "typescriptreact",
        "html", "yaml", "ruby"
    }, function() vol.shiftwidth, vol.tabstop, vol.softtabstop = 2, 2, 2 end},
    {"FileType", {"csv", "json", "xml"}, function() 
        vol.textwidth = 0  -- Disable line wrapping for data files
        vol.wrap = false
    end},
    {"FileType", "markdown", function()
        vol.nu, vol.wrap, vol.linebreak, vol.textwidth = false, true, true, 65
    end},
    {"FileType", "go", function () vol.tags:append("~/.tags/go.tags") end},
    {"FileType", {
        "java", "clojure"
    }, function ()
        vol.tags:append("~/.tags/clojure.tags,~/.tags/java.tags")
    end},
    {"FileType", {
        "javascript", "typescript"
    }, function () vol.tags:append("~/.tags/node.tags") end},
    {"BufWritePre", "*.go", fmt("goimports", "-w")},
    {"BufWritePre", "*.templ", fmt("templ", "fmt", "-w")},
    {"FileType", "qf", function() -- jump to quickfix targets automatically
        vim.keymap.set("n", "j", "j<CR><C-w>p", { buffer = true })
        vim.keymap.set("n", "k", "k<CR><C-w>p", { buffer = true })
    end},
    {'TermOpen', '*', function() vim.opt_local.number = false end}, 
    {'BufWritePre', '*', function()
        local dir = vim.fn.expand('<afile>:p:h')
        if vim.fn.isdirectory(dir) == 0 then vim.fn.mkdir(dir, 'p') end
    end},
}

for _, ac in ipairs(autocmds) do
    vim.api.nvim_create_autocmd(ac[1], {group = base, pattern = ac[2], callback = ac[3]})
end

vim.api.nvim_create_autocmd("QuickFixCmdPost", { -- open quickfix if there are results
    group = base, pattern = { "[^l]*" }, command = "cwindow"
})

pcall(vim.cmd, 'colorscheme spartan') -- Try colorscheme, fallback to default

local ok, telescope = pcall(require, 'telescope')
if ok then
    telescope.setup({defaults = {path_display = {"truncate"}}})
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<space>', function()
        builtin.find_files({hidden = true, file_ignore_patterns = {"^.git/"}})
    end)
    vim.keymap.set('n', 'gb', builtin.buffers)
end
