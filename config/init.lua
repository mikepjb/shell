-- Spartan Neovimrc - optimised for user flow

-- TODO maybe prefer default, we'll see.
-- TODO alternatively put hex codes in flow to get it working properly
vim.cmd.colorscheme("flow")

-- bindings
local opt = vim.opt
opt.autoindent = true
opt.autoread = true
opt.backspace = { "indent", "eol", "start" }
opt.formatoptions:remove("t")
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
opt.number = false
opt.startofline = false
opt.wrap = false
opt.showmatch = true
opt.gdefault = true
opt.textwidth = 80
opt.colorcolumn = "81"
opt.fillchars = { vert = "│", fold = " " }
opt.belloff = "all"
opt.clipboard = { "unnamed", "unnamedplus" }
opt.writebackup = false
opt.swapfile = false
opt.laststatus = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.splitbelow = true
opt.splitright = true
opt.mouse = "a"
opt.updatetime = 200
opt.timeoutlen = 1000
opt.ttimeoutlen = 100
opt.hidden = true
opt.joinspaces = false
opt.completeopt = { "menu", "menuone", "noselect" }
opt.shell = "bash"
opt.statusline = "%<%f%* (%{&ft}) %-4(%m%)%=%-19(%3l,%02c%03V%)"

local undo_dir = "/tmp/.nvim-undo-dir"
vim.fn.mkdir(undo_dir, "p", 0700)
opt.undodir = undo_dir
opt.undofile = true

if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --smart-case --follow"
  opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

opt.errorformat = "%f:%l:%c: %m,%f:%l: %m,%-G%.%#"
vim.g.omni_sql_no_default_maps = 1
vim.g.sh_noisk = 1
vim.g.markdown_fenced_languages = {
  "bash=sh",
  "css",
  "html",
  "go",
  "ruby",
  "sql",
  "yaml",
  "java",
}


-- functions

-- lsp setup

-- telescope
