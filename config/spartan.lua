-- Spartan colorscheme for neovim
vim.o.background = 'dark'
vim.cmd('hi clear')
if vim.fn.exists('syntax_on') == 1 then
    vim.cmd('syntax reset')
end
vim.g.colors_name = 'spartan'

-- Color palette from your alacritty config
local colors = {
    bg = '#0c0c0c',
    fg = '#e4e4e4',
    black = '#202020',
    red = '#cc8faa',
    green = '#8fcc9f',
    yellow = '#ccb38f',
    blue = '#8fb3cc',
    magenta = '#cc8fcc',
    cyan = '#8fcccc',
    white = '#b8b8b8',
    bright_black = '#787878',
    bright_red = '#ff0080',
    bright_green = '#00ff80',
    bright_yellow = '#ffb300',
    bright_blue = '#00ccff',
    bright_magenta = '#ff00ff',
    bright_cyan = '#00ffff',
    bright_white = '#ffffff',
}

local function hl(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

-- Basic UI elements
hl('Normal', {})
hl('CursorLine', { bg = colors.black })
hl('CursorColumn', {})
hl('ColorColumn', { bg = colors.black })
hl('NonText', { fg = colors.bright_black })
hl('LineNr', { fg = colors.bright_black })
hl('CursorLineNr', { fg = colors.bright_yellow, bg = colors.bright_black })
hl('StatusLine', {})
hl('StatusLineNC', { fg = colors.bright_black })
hl('User1', { fg = colors.bright_blue })
hl('VertSplit', { fg = colors.bright_black })
hl('Visual', { fg = colors.black, bg = colors.bright_green })
hl('Search', { fg = colors.bright_green })
hl('IncSearch', { fg = colors.bright_green })
hl('Pmenu', { fg = colors.bright_cyan, bg = colors.black })
hl('PmenuSel', { fg = colors.black, bg = colors.bright_cyan })
hl('MatchParen', { fg = colors.bright_magenta })
hl('TelescopeSelection', { fg = colors.bright_cyan })

-- Messages and errors
hl('ErrorMsg', { fg = colors.bright_magenta })
hl('WarningMsg', { fg = colors.bright_yellow, bg = colors.black })
hl('MoreMsg', { fg = colors.green, bg = colors.black })
hl('Question', { fg = colors.cyan, bg = colors.black })

-- Syntax highlighting
hl('Comment', { fg = colors.bright_black })
hl('Title', { fg = colors.yellow })
hl('String', { fg = colors.green })
hl('SpecialComment', { fg = colors.bright_magenta })
hl('Debug', { fg = colors.bright_magenta })
hl('Underlined', { fg = colors.blue, underline = true })
hl('Todo', { fg = colors.bright_yellow })
hl('Added', { fg = colors.green, bg = colors.black })
hl('Removed', { fg = colors.red, bg = colors.black })
hl('gitcommitBranch', { fg = colors.yellow })
hl('TabLine', { fg = colors.bright_black, bg = colors.black })
hl('TabLineFill', { fg = colors.bright_black, bg = colors.black })
hl('TabLineSel', { fg = colors.white, bg = colors.bright_black })
hl('WildMenu', { fg = colors.black, bg = colors.yellow })
hl('Directory', { fg = colors.blue })

hl('markdownCode', { fg = colors.cyan })
hl('markdownCodeBlock', { fg = colors.cyan })
