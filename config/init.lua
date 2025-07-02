-- TODO need TODO highlight
-- TODO grep in vim? we used to have :Grep? regular :grep?
-- TODO 2 the default (go/java is 4 exception?) we have a lot of 2s currently
-- Core?
vim.opt.clipboard:append({ "unnamedplus" }) -- integrate with system clipboard

-- Buffer
vim.opt.number = true
vim.opt.wrap = false
vim.opt.textwidth = 79
vim.opt.colorcolumn = "+1"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Backup (better name?)
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.undodir = os.getenv("HOME") .. "/.config/nvim/undodir"

-- UI?
vim.opt.shortmess:append("I")
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.scrolloff = 8
vim.opt.fillchars = "stl:─,stlnc:─,vert:│"
vim.opt.statusline = "── %#User1#%f%*%< (%{&ft})%m%r%h%w %= ( %3l,%3c,%3p%% )"
vim.opt.termguicolors = os.getenv("COLORTERM") == 'truecolor'

-- Search
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

-- Misc (sort these!)
vim.g.markdown_fenced_languages = { 'typescript', 'javascript', 'bash', 'go' }
vim.g.omni_sql_no_default_maps = 1 -- don't use C-c for autocompletion in SQL.


-- Functions ------------------------------------------------------------------
local function ogtree()
    local tbuf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(tbuf)
    vim.api.nvim_buf_set_name("tree")
  -- execute tree
  -- include the results there
  -- but not if tree buffer already exists, just reuse/refresh the buffer with
  -- another tree call
  print("hello")
end

-- technically works but says "attempting to modify a read only file"
local function tree()
    local tree_buf = vim.fn.bufnr('tree')

    if tree_buf ~= -1 then
        vim.api.nvim_set_current_buf(tree_buf)
        vim.bo.modifiable = true
        vim.api.nvim_buf_set_lines(tree_buf, 0, -1, false, {})
    else
        vim.cmd('enew')
        tree_buf = vim.api.nvim_get_current_buf()
        vim.bo.buftype = 'nofile'
        vim.bo.bufhidden = 'hide'
        vim.bo.swapfile = false
        vim.wo.number = false
        vim.bo.readonly = true
        vim.api.nvim_buf_set_name(tree_buf, 'tree')
    end

    local output = vim.fn.systemlist('tree -a -I .git --gitignore --prune --noreport')
    output = vim.tbl_filter(function(line) return line ~= '' end, output)

    vim.bo.modifiable = true
    vim.api.nvim_buf_set_lines(tree_buf, 0, -1, false, output)
    vim.api.nvim_win_set_cursor(0, {1, 0})
    vim.bo.modifiable = false
end

local function fmt(fn, args)
    return function()
        if vim.fn.executable(fn) == 1 then
            local file = vim.fn.expand("%:p")
            vim.system({fn, args, file}, { text = true }, function(obj)
                vim.schedule(function() -- reload but save view position
                    if obj.code == 0 then
                        local view = vim.fn.winsaveview()
                        vim.cmd('edit!')
                        vim.fn.winrestview(view)
                    else
                        local error_msg = obj.stdout .. obj.stderr
                        vim.notify(error_msg, vim.log.levels.INFO)
                    end
                end)
            end)
        else
            vim.notify(fn .. " not found, cannot format the buffer")
        end
    end
end

local function send_text_to_repl(text)
    if text == '' or text == nil then
        return
    end

    local escaped = text:gsub('"', '\\"')
    local cmd = string.format([[
        if tmux list-windows | grep -q "^99:"; then
            tmux send-keys -t 99 "%s" Enter;
        elif [ $(tmux display-message -p "#{window_panes}") -eq 2 ]; then
            tmux send-keys -t 2 "%s" Enter;
        fi]], escaped, escaped)

    vim.fn.system(cmd)
end

local function send_to_repl(start_line, end_line)
    start_line = start_line or vim.fn.line('.')
    end_line = end_line or start_line

    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    local text = table.concat(lines, '\n')
    send_text_to_repl(text)
end

local function send_buffer_to_repl()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local text = table.concat(lines, '\n')
    send_text_to_repl(text)
end

local function prompt_and_send_to_repl()
    local text = vim.fn.input('=> ')
    send_text_to_repl(text)
end

-- TODO also need send to

local base = vim.api.nvim_create_augroup('Base', { clear = true })
local vol = vim.opt_local

local autocmds = {
    {"FileType", {
        "clojure", "scheme", "javascript", "typescript",
        "json", "javascriptreact", "typescriptreact",
        "html", "yaml", "ruby"
    }, function() vol.shiftwidth, vol.tabstop, vol.softtabstop = 2, 2, 2 end},
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
    {"FileType", "netrw", function()
        vim.keymap.set("n", "S", "<C-^>", { noremap = true, buffer = true })
        vim.keymap.set("n", "Q", ":b#<bar>bd #<CR>", { noremap = true, silent = true })
        vim.keymap.set("n", "gp", ":call feedkeys(':tabnew<space>~/src/<tab>', 't')<CR>", { buffer = true })
        if vim.b.netrw_curdir then
            vim.cmd('tcd ' .. vim.fn.fnameescape(vim.b.netrw_curdir))
        end
    end},
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

-- TODO readline M-d/f/b on the command/ex mode line
local keymaps = {
    {"c", "<C-a>", "<S-Left>"}, -- more portable opt than s-left?
    -- TODO C-d in insert mode pls.
    {"n", "<C-h>", "<C-w><C-h>"}, {"n", "<C-j>", "<C-w><C-j>"},
    {"n", "<C-k>", "<C-w><C-k>"}, {"n", "<C-l>", "<C-w><C-l>"},
    {"n", "<C-q>", ":q<CR>"},     {"n", "<C-g>", ":noh<CR><C-g>"},
    {"i", "<C-l>", " => "},       {"i", "<C-u>", " -> "},
    {"i", "<C-c>", "<Esc>"},      {"n", "S", "<C-^>"},
    {"n", "gE", ":Explore<CR>"},  -- {"n", "gs", ":Grep "},
    {"n", "<M-u>", tree},
    {"n", "<M-q>", ":Inspect<CR>"},
    {"n", "Q", "@q"},
    {"n", "cqp", prompt_and_send_to_repl},
    {"v", "gs", send_text_to_repl},
    {"n", "gS", send_buffer_to_repl},
    -- TODO M-s save in insert and normal mode? necessary?
    {"n", "gd", "<C-]>"},           -- go to definition
    {"n", "gD", "g<C-]>"},          -- choose which definition to go to
    {"t", "<C-g>", "<C-\\><C-n>"},
    {"v", "<C-g>", "y<C-w><C-w>pa<CR>"},
    {"n", "gn", ":tabnew ~/.notes/index.md<CR>"},
    {"n", "gi", ":tabnew ~/.config/nvim/init.lua<CR>"},
    {"n", "gp", ":call feedkeys(':tabnew<space>~/src/<tab>', 't')<CR>"},
    {"n", "gS", function() vim.cmd(":Grep -w " .. vim.fn.expand("<cword>")) end},
    {'n', 'ge', function()
        local current_dir = vim.fn.expand('%:p:h')
        local input_cmd = ':e ' .. current_dir .. '/'
        vim.opt.backupskip:append('*') -- Avoid backup file issues
        vim.api.nvim_feedkeys(input_cmd, 'n', true)
    end, { desc = 'Create/edit file relative to current buffer' }},
} for _, km in ipairs(keymaps) do vim.keymap.set(km[1], km[2], km[3]) end

-- TODO autocmd, disable textwidth for csv/json/data files.
-- TODO go should be 4 OR js/html etc should be 2 depending on your default
-- TODO style!!
-- TODO j/k warning? that helped a lot I think, worth trying again.

vim.api.nvim_create_user_command('TrimWhitespace', function()
    vim.cmd '%s/\\s\\+$//e'
end, {})

pcall(vim.cmd, 'colorscheme spartan') -- Try colorscheme, fallback to default

-- TODO do we want this?
local ok, telescope = pcall(require, 'telescope')
if ok then
    telescope.setup({defaults = {path_display = {"truncate"}}})
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<space>', function()
        builtin.find_files({hidden = true, file_ignore_patterns = {"^.git/"}})
    end)
    vim.keymap.set('n', 'gb', builtin.buffers)
end
