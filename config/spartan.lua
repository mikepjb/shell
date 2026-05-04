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
--
-- For dark/light, bg = black -> lighter and white -> darker
--                 fg = white -> darker and black -> lighter
local colors = {
    yellow = 3,
    magenta = 11,
    cyan = 14,

    lavender = 5,
    teal = 6,
    sapphire = 4,

    fg = 'NONE', -- inherit terminal fg text
    fg2 = 7, -- fg+
    fg3 = 15, -- fg++

    bg = 'NONE', -- inherit terminal bg text
    bg_p = 0, -- bg+ very light for column line
    bg_pp = 8, -- bg dark enough for line numbers

    red = 1,
    green = 2,

    diff_red = 9,
    diff_green = 10,
}

local function hl(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

-- Basic UI elements, check with `:h highlight-groups`
hl('Normal', { ctermfg = colors.fg, ctermbg = 'NONE' })
hl('NonText', { ctermfg = colors.fg, bg= 'NONE' })
hl('CursorLine', { ctermbg = colors.bg_p })
hl('CursorColumn', {})
hl('ColorColumn', { ctermbg = colors.bg_p })
hl('LineNr', { ctermfg = colors.bg_pp })
hl('CursorLineNr', { ctermfg = colors.yellow, ctermbg = colors.bg_pp })
hl('StatusLine', {})
hl('StatusLineNC', { ctermfg = colors.bg_pp })
hl('User1', { ctermfg = colors.sapphire })
hl('VertSplit', { ctermfg = colors.bg_pp })
hl('WinSeparator', { ctermfg = colors.bg_pp })
hl('Visual', { ctermfg = colors.yellow, ctermbg = colors.bg_p })
hl('Search', { ctermbg = colors.yellow })
hl('IncSearch', { ctermbg = colors.yellow })
hl('Pmenu', { ctermfg = colors.sapphire, ctermbg = colors.bg_p })
hl('PmenuSel', { ctermfg = colors.lavender, ctermbg = colors.bg_p })
hl('MatchParen', { ctermfg = colors.bright_magenta })
hl('TelescopeSelection', { ctermfg = colors.yellow })

-- Messages and errors
hl('ErrorMsg', { ctermfg = colors.bright_magenta })
hl('WarningMsg', { ctermfg = colors.yellow, ctermbg = colors.bg_p })
hl('MoreMsg', { ctermfg = colors.teal, ctermbg = colors.bg_p })
hl('Question', { ctermfg = colors.cyan, ctermbg = colors.bg_p })

-- Syntax highlighting
hl('Comment', { ctermfg = colors.fg3 })
hl('Title', { ctermfg = colors.yellow })
hl('String', { ctermfg = colors.teal })
hl('Function', { ctermfg = colors.fg2 })
hl('Delimiter', { ctermfg = colors.sapphire })
hl('Special', { ctermfg = colors.teal })
hl('Identifier', { ctermfg = colors.sapphire })
hl('SpecialComment', { ctermfg = colors.bright_magenta })
hl('Debug', { ctermfg = colors.bright_magenta })
hl('Underlined', { ctermfg = colors.sapphire, underline = true })
hl('Todo', { ctermfg = colors.yellow })
hl('Added', { ctermfg = colors.green, ctermbg = colors.bg_p })
hl('Removed', { ctermfg = colors.red, ctermbg = colors.bg_p })
hl('gitcommitBranch', { ctermfg = colors.yellow })
hl('TabLine', { ctermfg = colors.bg_pp, ctermbg = colors.bg_p })
hl('TabLineFill', { ctermfg = colors.bg_p, ctermbg = colors.bg_p })
hl('TabLineSel', { ctermfg = colors.white, ctermbg = colors.bg_pp })
hl('WildMenu', { ctermfg = colors.bg_p, ctermbg = colors.yellow })
hl('Directory', { ctermfg = colors.sapphire })

hl('markdownCode', { ctermfg = colors.cyan })
hl('markdownCodeBlock', { ctermfg = colors.cyan })
