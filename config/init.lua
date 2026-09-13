-- Spartan Neovimrc - optimised for user flow

vim.pack.add({
  "gh:nvim-lua/plenary.nvim",
  "gh:nvim-telescope/telescope.nvim",
  "gh:tpope/vim-fugitive",
}, { load = true })

local opt = vim.opt
local bind = vim.keymap.set
opt.termguicolors = false
opt.shortmess:append("I") -- no startup message
opt.guicursor = "" -- block cursor forever!
opt.autoindent = true
opt.autoread = true
opt.backspace = { "indent", "eol", "start" }
opt.formatoptions:append("t")
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

opt.undofile = true

if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --smart-case --follow"
  opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

opt.errorformat = "%f:%l:%c: %m,%f:%l: %m,%-G%.%#"
vim.g.omni_sql_no_default_maps = 1
vim.g.sh_noisk = 1
-- TODO fenced languages do not seem to get syntax highlighted in neovim.
vim.g.markdown_fenced_languages = {
  "bash=sh", "css", "html", "go", "ruby", "sql", "yaml", "java", "python",
}

pcall(vim.cmd, "colorscheme flow") -- Try colorscheme, fallback to default

local markdown_heading_pattern = [[^\s\{0,3}\zs#\{1,6}\ze\%(\s\|$\)]]

local function markdown_fold(lnum)
  local line = vim.fn.getline(lnum)
  local heading = vim.fn.matchstr(line, markdown_heading_pattern)
  local level = #heading

  -- Level-one headings are section boundaries, not folds.
  if level == 1 then
    return 0
  elseif level > 1 then
    return ">" .. (level - 1)
  end

  return "="
end

local function markdown_fold_text()
  return vim.fn.getline(vim.v.foldstart) .. " "
end

-- foldexpr/foldtext are Vimscript expressions, so expose these callbacks to v:lua.
_G.markdown_fold = markdown_fold
_G.markdown_fold_text = markdown_fold_text

-- autocmd
local base = vim.api.nvim_create_augroup("base", { clear = true })
local autocmd = vim.api.nvim_create_autocmd

autocmd("FileType", {
  pattern = "markdown",
  group = base,
  callback = function(ev)
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.markdown_fold(v:lnum)"
    vim.opt_local.foldtext = "v:lua.markdown_fold_text()"
    vim.opt_local.foldlevel = 0
    bind("n", "<C-d>", "za", {
      buffer = ev.buf,
      desc = "Toggle Markdown fold",
    })
  end,
})

local function fmt(fn, ...)
  local args = { ... }
  return function()
    if vim.fn.executable(fn) == 0 then
      return vim.notify(fn .. " not found, cannot format the buffer")
    end

    local cmd, file = { fn }, vim.fn.expand("%:p")
    for _, arg in ipairs(args) do
      table.insert(cmd, arg)
    end
    table.insert(cmd, file)
    vim.system(cmd, { text = true }, function(obj)
      vim.schedule(function()
        if obj.code == 0 then
          local view = vim.fn.winsaveview()
          vim.cmd("edit!")
          vim.fn.winrestview(view)
        else
          vim.notify(obj.stdout .. obj.stderr, vim.log.levels.INFO)
        end
      end)
    end)
  end
end

autocmd("BufWritePre", {
  pattern = { "*.go" },
  group = base,
  callback = fmt("goimports", "-w"),
})

autocmd("BufWritePre", {
  pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" },
  group = base,
  callback = fmt("prettier", "-w"),
})

-- lsp setup
-- Configurations are defined here but deliberately start only when toggled.
local lsp_configs = {
  jdtls = {
    cmd = { "jdtlsw" },
    filetypes = { "java" },
    root_markers = { "gradlew", "mvnw", "pom.xml" },
  },
  gopls = {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.work", "go.mod" },
  },
  rust_analyzer = {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml" },
  },
  ts_ls = {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
    },
    root_markers = { "package.json" },
  },
}

local server_by_filetype = {}
for name, config in pairs(lsp_configs) do
  vim.lsp.config(name, config)
  for _, filetype in ipairs(config.filetypes) do
    server_by_filetype[filetype] = name
  end
end

local function toggle_current_lsp()
  local name = server_by_filetype[vim.bo.filetype]

  if not name then
    return vim.notify(
      "No LSP configured for " .. vim.bo.filetype,
      vim.log.levels.INFO
    )
  end

  local enabled = vim.lsp.is_enabled(name)
  vim.lsp.enable(name, not enabled)
  vim.notify(name .. (enabled and " disabled" or " enabled"))
end

bind("n", "gL", toggle_current_lsp, {
  desc = "Toggle current filetype LSP",
})

-- Basic LSP keymaps
autocmd("LspAttach", {
  group = base,
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    local opts = { buffer = ev.buf }
    bind("n", "ga", vim.lsp.buf.code_action, opts)
    bind("n", "gd", vim.lsp.buf.definition, opts)
    bind("n", "gr", vim.lsp.buf.references, opts)
    bind("n", "K", function()
      local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
      if #diagnostics > 0 then
        vim.diagnostic.open_float()
      else
        vim.lsp.buf.hover()
      end
    end, opts)
  end,
})

-- telescope
local ok, telescope = pcall(require, "telescope")

if ok then
  local file_ignore_patterns = {
    "^%.git/",
    "/%.git/",
    "^target/",
    "/target/",
    "node_modules",
  }

  telescope.setup({
    pickers = {
      find_files = {
        hidden = true,
        file_ignore_patterns = file_ignore_patterns,
      },
    },
  })
  bind("n", "<space>", "<cmd>Telescope find_files<CR>")
  bind("n", "gb", "<cmd>Telescope live_grep<CR>")
  bind("n", "<M-b>", "<cmd>Telescope buffers<CR>")
  bind("n", "gn", function()
    require("telescope.builtin").find_files({
      cwd = vim.fn.expand("~/.notes"),
      prompt_title = "Notes",
    })
  end, { desc = "Find notes" })
  bind("n", "gI", function()
    require("telescope.builtin").find_files({
      cwd = vim.fn.expand("~/src/shell"),
      prompt_title = "Shell Configuration",
    })
  end, { desc = "Find shell configuration" })
else
  bind("n", "<space>", ":find ")
end

-- Keybinds
bind("n", "Y", "y$")
bind("n", "<C-j>", "<C-w><C-j>")
bind("n", "<C-k>", "<C-w><C-k>")
bind("n", "<C-h>", "<C-w><C-h>")
bind("n", "<C-l>", "<C-w><C-l>")
bind("i", "<C-l>", "<space>=><space>")
bind("i", "<C-c>", "<esc>")
bind("n", "S", "<C-^>")
bind("n", "<C-q>", ":q<CR>")
bind("n", "<C-g>", ":noh<CR>:redraw!<CR><C-g>")
bind("n", "gi", ":e ~/.config/nvim/init.lua<CR>")
bind("n", "ge", [[:e <C-R>=fnamemodify(resolve(expand("%:p")), ":h") . "/"<CR>]])
bind("n", "gc", ":!ctags -R .<CR>")
bind("n", "gs", ":read !snip<space>")
local function toggle_quickfix()
  vim.cmd(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and "cclose" or "copen")
end

bind("n", "gl", toggle_quickfix, { desc = "Toggle quickfix list" })
bind("n", "Q", "@q")
bind("n", "<A-n>", ":cnext<CR>")
bind("n", "<A-p>", ":cprevious<CR>")
bind("c", "<C-d>", function()
  if vim.fn.getcmdpos() > #vim.fn.getcmdline() then
    return "<C-d>"
  end
  return "<Del>"
end, { expr = true, desc = "Delete command-line character" })

bind("c", "<C-f>", function()
  if vim.fn.getcmdpos() > #vim.fn.getcmdline() then
    return vim.o.cedit
  end
  return "<Right>"
end, { expr = true, desc = "Move through command line" })
bind("n", "<C-t>", function()
  vim.cmd("update")
  vim.cmd("!test-this")
end, { desc = "Run project tests" })
