-- Spartan colorscheme for neovim
vim.o.background = 'dark'
vim.cmd('hi clear')
if vim.fn.exists('syntax_on') == 1 then
    vim.cmd('syntax reset')
end
vim.g.colors_name = 'spartan'

-- Color organised as a pyramid for attention, with small areas
-- of interest down to the main bulk of the view. This should
-- also dictate color choice in UI i.e you don't want to draw
-- the eye with a yellow for truncation symbols in the fringes.
local colors = {
    yellow = '#f9e2af',
    magenta = '#cba6f7',

    lavender = '#b7bdf8',
    teal = '#94e2d5',
    sapphire = '#74c7ec',

    fg = '#cdd6f4',
    fg2 = '#bac2de', -- fg+
    fg3 = '#a6adc8', -- fg++

    bg = '#0a0a10',
    black = '#11111b', -- bg++
    bright_black = '#313244', -- bg++++

    red = '#eba0ac',
    green = '#8fcc9f',

    magenta = '#cc8fcc',
    cyan = '#8fcccc',
    bright_magenta = '#ff00ff',

    diff_red = '#1f0809',
    diff_green = '#0c1412',
}

local function hl(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

-- Basic UI elements, check with `:h highlight-groups`
hl('Normal', { fg = colors.fg })
hl('CursorLine', { bg = colors.black })
hl('CursorColumn', {})
hl('ColorColumn', { bg = colors.black })
hl('NonText', { fg = colors.fg, bg= 'none' })
hl('LineNr', { fg = colors.bright_black })
hl('CursorLineNr', { fg = colors.yellow, bg = colors.bright_black })
hl('StatusLine', {})
hl('StatusLineNC', { fg = colors.bright_black })
hl('User1', { fg = colors.sapphire })
hl('VertSplit', { fg = colors.bright_black })
hl('WinSeparator', { fg = colors.bright_black })
hl('Visual', { fg = colors.yellow, bg = colors.black })
hl('Search', { bg = colors.yellow })
hl('IncSearch', { bg = colors.yellow })
hl('Pmenu', { fg = colors.sapphire, bg = colors.black })
hl('PmenuSel', { fg = colors.lavender, bg = colors.bright_black })
hl('MatchParen', { fg = colors.bright_magenta })
hl('TelescopeSelection', { fg = colors.yellow })

-- Messages and errors
hl('ErrorMsg', { fg = colors.bright_magenta })
hl('WarningMsg', { fg = colors.yellow, bg = colors.black })
hl('MoreMsg', { fg = colors.teal, bg = colors.black })
hl('Question', { fg = colors.cyan, bg = colors.black })

-- Syntax highlighting
hl('Comment', { fg = colors.fg3 })
hl('Title', { fg = colors.yellow })
hl('String', { fg = colors.teal })
hl('SpecialComment', { fg = colors.bright_magenta })
hl('Debug', { fg = colors.bright_magenta })
hl('Underlined', { fg = colors.sapphire, underline = true })
hl('Todo', { fg = colors.yellow })
hl('Added', { fg = colors.green, bg = colors.black })
hl('Removed', { fg = colors.red, bg = colors.black })
hl('gitcommitBranch', { fg = colors.yellow })
hl('TabLine', { fg = colors.bright_black, bg = colors.black })
hl('TabLineFill', { fg = colors.bright_black, bg = colors.black })
hl('TabLineSel', { fg = colors.white, bg = colors.bright_black })
hl('WildMenu', { fg = colors.black, bg = colors.yellow })
hl('Directory', { fg = colors.sapphire })

hl('markdownCode', { fg = colors.cyan })
hl('markdownCodeBlock', { fg = colors.cyan })
