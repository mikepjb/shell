-- Spartan Neovimrc - optimised for user flow

vim.pack.add({
  "gh:nvim-lua/plenary.nvim",
  "gh:nvim-telescope/telescope.nvim",
  "gh:folke/trouble.nvim",
  "gh:tpope/vim-fugitive",
}, { load = true })

local opt = vim.opt
opt.termguicolors = false
vim.opt.shortmess:append("I") -- no startup message
opt.guicursor = '' -- block cursor forever!
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
vim.fn.mkdir(undo_dir, "p", "0700")
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
  "bash=sh", "css", "html", "go", "ruby", "sql", "yaml", "java",
}

pcall(vim.cmd, 'colorscheme flow') -- Try colorscheme, fallback to default

-- functions
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

-- autocmd
local base = vim.api.nvim_create_augroup('base', { clear = true })
local autocmd = vim.api.nvim_create_autocmd

autocmd("BufWritePre", {
  pattern = {"*.go"},
  group = base,
  callback = fmt("goimports", "-w")
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

for name, config in pairs(lsp_configs) do
  vim.lsp.config(name, config)
end

local server_by_filetype = {
  java = "jdtls",
  go = "gopls",
  gomod = "gopls",
  gowork = "gopls",
  gotmpl = "gopls",
  rust = "rust_analyzer",
  javascript = "ts_ls",
  javascriptreact = "ts_ls",
  typescript = "ts_ls",
  typescriptreact = "ts_ls",
}

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

vim.keymap.set("n", "<leader>l", toggle_current_lsp, {
  desc = "Toggle current filetype LSP",
})

-- Basic LSP keymaps
vim.api.nvim_create_autocmd('LspAttach', {
    group = base,
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

-- telescope
local ok, telescope = pcall(require, "telescope")

if ok then
    local file_ignore_patterns = {
      "^%.git/",
      "/%.git/",
      "^target/",
      "/target/",
    }

    telescope.setup({
      pickers = {
        find_files = {
          hidden = true,
          file_ignore_patterns = file_ignore_patterns,
        },
      },
    })
    vim.keymap.set('n', '<space>', '<cmd>Telescope find_files<CR>')
    vim.keymap.set('n', 'gb', '<cmd>Telescope live_grep<CR>')
    vim.keymap.set('n', '<M-b>', '<cmd>Telescope buffers<CR>')
    vim.keymap.set('n', 'gn', function()
      require('telescope.builtin').find_files({
        cwd = vim.fn.expand('~/.notes'),
        prompt_title = 'Notes',
      })
    end, { desc = 'Find notes' })
    vim.keymap.set('n', 'gI', function()
      require('telescope.builtin').find_files({
        cwd = vim.fn.expand('~/src/shell'),
        prompt_title = 'Shell Configuration',
      })
    end, { desc = 'Find notes' })
else
    vim.keymap.set('n', '<space>', ':find ')
end

local trouble_ok, trouble = pcall(require, "trouble")
if trouble_ok then
    trouble.setup({})
end

-- Keybinds
local bind = vim.keymap.set
bind('n', 'Y', 'y$')
bind('n', '<C-j>', '<C-w><C-j>')
bind('n', '<C-k>', '<C-w><C-k>')
bind('n', '<C-h>', '<C-w><C-h>')
bind('n', '<C-l>', '<C-w><C-l>')
bind('i', '<C-l>', '<space>=><space>')
bind('i', '<C-c>', '<esc>')
bind('n', 'S', '<C-^>')
bind('n', '<C-q>', ':q<CR>')
bind('n', '<C-g>', ':noh<CR>:redraw!<CR><C-g>')
bind('n', 'gi', ':e ~/.config/nvim/init.lua<CR>')
bind('n', 'ge', ':e <C-R>=fnamemodify(resolve(expand("%:p")), ":h") . "/"<CR>')
bind('n', 'gc', ':!ctags -R .<CR>')
bind('n', 'gr', ':read !snip<space>')
bind('n', 'gR', ':Eval (user/restart)<CR>')
-- TODO gl to open/close quick fix menu
bind('n', 'Q', '@q')
bind('n', '<A-n>', ':cnext<CR>')
bind('n', '<A-p>', ':cprevious<CR>')
-- TODO how to map expr?
-- nnoremap <expr> gl empty(filter(getwininfo(), 'v:val.quickfix')) ? ':copen<CR>' : ':cclose<CR>'
-- cnoremap <expr> <C-D> getcmdpos()>strlen(getcmdline())?"\<Lt>C-D>":"\<Lt>Del>"
-- cnoremap <expr> <C-F> getcmdpos()>strlen(getcmdline())?&cedit:"\<Lt>Right>"
bind('n', '<C-t>', ':!go test ./...<cr>')
bind('n', '<A-t>', ':cexpr system("test-this " . expand("%"))<cr>')
-- nnoremap <A-T> :cexpr system('test-this')<cr>
-- nnoremap <A-r> :cexpr system('lint-this "' . expand('%') . '"')<cr>
-- nnoremap <A-R> :cexpr system('lint-this "' . expand('%') . '" --fix')<cr>
--
-- TODO need markdown handling! and TODO/NEXt highlighting to match vim config
