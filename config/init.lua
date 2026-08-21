-- Small Neovim config: lazy.nvim, Telescope, Conform, gopls, and TokyoNight.

-- Keep <Space> available for the old file picker mapping. The default leader
-- remains backslash, as it was in Vim before a custom leader was configured.
vim.g.mapleader = "\\"
vim.g.maplocalleader = "\\"

local uv = vim.uv or vim.loop
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not uv.fs_stat(lazypath) then
  local output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Could not install lazy.nvim:\n" .. output)
  end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = { style = "storm" },
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<space>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "gs", "<cmd>Telescope live_grep<cr>", desc = "Search project" },
      {
        "gn",
        function()
          local notes = vim.fn.expand("~/.notes")
          if vim.fn.isdirectory(notes) == 1 then
            require("telescope.builtin").find_files({ cwd = notes })
          else
            vim.notify("Notes directory not found: " .. notes, vim.log.levels.WARN)
          end
        end,
        desc = "Find note",
      },
      {
        "gt",
        function()
          require("telescope.builtin").live_grep({
            default_text = "TODO|NEXT|CURRENT|DONE",
          })
        end,
        desc = "Search TODO markers",
      },
    },
    opts = {
      pickers = {
        find_files = { hidden = true },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo", "Format" },
    keys = {
      {
        "gp",
        function()
          require("conform").format({ async = false, lsp_format = "fallback" })
        end,
        mode = { "n", "x" },
        desc = "Format buffer",
      },
    },
    init = function()
      vim.api.nvim_create_user_command("Format", function()
        require("conform").format({ async = false, lsp_format = "fallback" })
      end, {})
    end,
    opts = {
      formatters_by_ft = {
        -- goimports includes gofmt and also fixes imports.
        go = { "goimports" },
      },
      default_format_opts = {
        timeout_ms = 3000,
        lsp_format = "fallback",
      },
      format_on_save = function(bufnr)
        if vim.bo[bufnr].filetype == "go" then
          return { timeout_ms = 3000, lsp_format = "fallback" }
        end
      end,
    },
  },
}, {
  checker = { enabled = false },
  change_detection = { notify = false },
})

vim.cmd.colorscheme("tokyonight")

-- Editor options from config/vimrc.
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

local undo_dir = "/tmp/.vim-undo-dir"
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

-- gopls supplies navigation, diagnostics, refactoring, and completion.
local gopls = {
  settings = {
    gopls = {
      analyses = {
        nilness = true,
        unusedparams = true,
        unusedwrite = true,
      },
      staticcheck = true,
      usePlaceholders = true,
      completeUnimported = true,
      gofumpt = false,
    },
  },
}

if vim.lsp.config then
  vim.lsp.config("gopls", gopls)
  vim.lsp.enable("gopls")
else
  -- Compatibility with older Neovim versions.
  require("lspconfig").gopls.setup(gopls)
end

-- Built-in LSP completion keeps the plugin list small: no nvim-cmp or Blink.
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("user_lsp", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method("textDocument/completion") and vim.lsp.completion then
      vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    end

    local function lspmap(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, silent = true, desc = desc })
    end

    lspmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
    lspmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    lspmap("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
    lspmap("n", "gr", vim.lsp.buf.references, "Find references")
    lspmap("n", "K", vim.lsp.buf.hover, "Hover documentation")
    lspmap("n", "L", vim.diagnostic.open_float, "Show errors etc")
    lspmap("n", "\\ca", vim.lsp.buf.code_action, "Code action")
    lspmap("n", "\\cr", vim.lsp.buf.rename, "Rename symbol")
  end,
})

local map = vim.keymap.set
local silent = { silent = true }

-- Vim mappings that still make sense without the old shell helpers.
map("n", "Y", "y$", silent)
map("n", "<C-j>", "<C-w>j", silent)
map("n", "<C-k>", "<C-w>k", silent)
map("n", "<C-h>", "<C-w>h", silent)
map("n", "<C-l>", "<C-w>l", silent)
map("i", "<C-l>", "<Space>=><Space>", silent)
map("i", "<C-c>", "<Esc>", silent)
map("n", "S", "<C-^>", silent)
map("n", "<C-q>", "<cmd>q<cr>", silent)
map("n", "<C-g>", function()
  vim.cmd.nohlsearch()
  vim.cmd.redraw()
end, silent)
map("n", "\\vi", function()
  vim.cmd("edit " .. vim.fn.fnameescape(vim.fn.stdpath("config") .. "/init.lua"))
end, { silent = true, desc = "Edit Neovim config" })
map("n", "ge", function()
  local dir = vim.fn.expand("%:p:h")
  vim.cmd("edit " .. vim.fn.fnameescape(dir ~= "" and dir or vim.fn.getcwd()))
end, silent)
map("n", "g<space>", function()
  local dir = vim.fn.expand("%:p:h")
  vim.cmd("lcd " .. vim.fn.fnameescape(dir ~= "" and dir or vim.fn.getcwd()))
  vim.cmd.pwd()
end, silent)
map("n", "gc", "<cmd>!ctags -R .<cr>", silent)
map("n", "\\r", "<cmd>read !snip<cr>", silent)
map("n", "Q", "@q", silent)
map("n", "<A-n>", "<cmd>cnext<cr>", silent)
map("n", "<A-p>", "<cmd>cprevious<cr>", silent)
map("n", "<C-t>", "<cmd>!go test ./...<cr>", silent)

map("n", "gl", function()
  if vim.fn.getqflist({ winid = 0 }).winid == 0 then
    vim.cmd.copen()
  else
    vim.cmd.cclose()
  end
end, { silent = true, desc = "Toggle quickfix" })

vim.api.nvim_create_user_command("Grep", function(args)
  vim.cmd("silent grep! " .. args.args)
  vim.cmd.redraw()
end, { nargs = "+", complete = "file" })

local base = vim.api.nvim_create_augroup("user_base", { clear = true })
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
  group = base,
  pattern = "[^l]*",
  command = "cwindow",
})
vim.api.nvim_create_autocmd("FileType", {
  group = base,
  pattern = { "go", "gomod", "gowork", "gotmpl" },
  callback = function()
    opt_local = vim.opt_local
    opt_local.tabstop = 4
    opt_local.softtabstop = 4
    opt_local.shiftwidth = 4
    opt_local.expandtab = false
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = base,
  pattern = "markdown",
  callback = function()
    vim.opt_local.formatoptions:append("t")
  end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = base,
  pattern = "qf",
  callback = function()
    vim.opt_local.statusline = "Quickfix [%{len(getqflist())}]"
  end,
})
