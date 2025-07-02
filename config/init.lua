-- TODO j/k warning? that helped a lot I think, worth trying again.
--
-- # Run a specific test class
-- mvn test -Dtest=TestClassName
-- # Run tests in a specific package
-- mvn test -Dtest=com.example.package.*Test
--
-- gradle test --tests TestClassName
-- # Run tests in a specific package
-- gradle test --tests "com.example.package.*"
-- # Using gradlew (wrapper)
-- ./gradlew test --tests TestClassName

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
vim.opt.guicursor = ""
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

-- TODO if there is no repl buffer, cqp will still take your prompt but there
-- will be no feedback, no error saying there isn't a REPL LOL we want a
-- message before the prompt is even presented
-- We actually want to do this to check before prompt:
-- tmux list-panes -a -F "#{pane_id}:#{pane_title}" | grep ":repl"
-- probably want to throw error message in tmux_send for the other 2 fns
local function tmux_send(text)
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

local function tmux_send_visual(start_line, end_line)
    start_line = start_line or vim.fn.line('.')
    end_line = end_line or start_line

    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    local text = table.concat(lines, '\n')
    tmux_send(text)
end

local function tmux_send_buffer()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local text = table.concat(lines, '\n')
    tmux_send(text)
end

local function tmux_send_prompt()
    local text = vim.fn.input('=> ')
    tmux_send(text)
end

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

vim.api.nvim_create_user_command('Grep', function(opts)
    vim.cmd('silent! grep!' .. opts.args)
    vim.cmd('redraw!')  -- clear any lingering output
    local qflist = vim.fn.getqflist()
    if #qflist > 0 then vim.cmd('copen | cfirst | wincmd j')
    else print("No matches found") end
end, { nargs = '+' })

-- TODO readline M-d/f/b on the command/ex mode line
local keymaps = {
    {"c", "<C-a>", "<S-Left>"}, -- more portable opt than s-left?
    {"n", "<C-h>", "<C-w><C-h>"}, {"n", "<C-j>", "<C-w><C-j>"},
    {"n", "<C-k>", "<C-w><C-k>"}, {"n", "<C-l>", "<C-w><C-l>"},
    {"n", "<C-q>", ":q<CR>"},     {"n", "<C-g>", ":noh<CR><C-g>"},
    {"i", "<C-l>", " => "},       {"i", "<C-u>", " -> "},
    {"i", "<C-c>", "<Esc>"},      {"n", "S", "<C-^>"},
    {"i", "<C-d>", "<Del>"},
    {"n", "<M-u>", tree},
    {"n", "<M-q>", ":Inspect<CR>"},
    {"n", "Q", "@q"},
    {"n", "cqp", tmux_send_prompt},
    {"v", "gp", tmux_send_visual},
    {"n", "gp", tmux_send_buffer},
    {"n", "gd", "<C-]>"},           -- go to definition
    {"n", "gD", "g<C-]>"},          -- choose which definition to go to
    {"t", "<C-g>", "<C-\\><C-n>"},
    {"v", "<C-g>", "y<C-w><C-w>pa<CR>"},
    {"n", "gn", ":e ~/.tmp-notes<CR>"},
    {"n", "gN", ":tabnew ~/.notes/index.md<CR>"},
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
