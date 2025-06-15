" Minimal Colorscheme, only uses 16 (+ fg/bg) colors defined by the terminal.

set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "spartan"

" Basic UI elements
hi Normal       ctermfg=none    ctermbg=none
hi Cursor       ctermfg=0    ctermbg=14
hi CursorLine   ctermbg=0    cterm=none
hi CursorColumn ctermbg=none
hi LineNr       ctermfg=8    ctermbg=0
hi CursorLineNr ctermfg=11   ctermbg=8
hi StatusLine   ctermfg=8    ctermbg=0    cterm=none
hi StatusLineNC ctermfg=8    ctermbg=0    cterm=none
hi VertSplit    ctermfg=8    ctermbg=0    cterm=none
hi Visual       ctermfg=0    ctermbg=3
hi Search       ctermfg=0    ctermbg=11
hi IncSearch    ctermfg=0    ctermbg=9
hi Pmenu        ctermfg=7    ctermbg=8
hi PmenuSel     ctermfg=0    ctermbg=3

" Messages and errors
hi ErrorMsg     ctermfg=15   ctermbg=1
hi WarningMsg   ctermfg=11   ctermbg=0
hi MoreMsg      ctermfg=2    ctermbg=0
hi Question     ctermfg=6    ctermbg=0

" Syntax highlighting
hi Comment      ctermfg=8
hi Constant     ctermfg=1
hi String       ctermfg=2
hi Character    ctermfg=2
hi Number       ctermfg=1
hi Boolean      ctermfg=1
hi Float        ctermfg=1
hi Title	ctermfg=3

hi Identifier   ctermfg=6    cterm=none
hi Function     ctermfg=4

hi Statement    ctermfg=3    cterm=none
hi Conditional  ctermfg=3
hi Repeat       ctermfg=3
hi Label        ctermfg=3
hi Operator     ctermfg=7
hi Keyword      ctermfg=3
hi Exception    ctermfg=3

hi PreProc      ctermfg=5
hi Include      ctermfg=5
hi Define       ctermfg=5
hi Macro        ctermfg=5
hi PreCondit    ctermfg=5

hi Type         ctermfg=6    cterm=none
hi StorageClass ctermfg=6
hi Structure    ctermfg=6
hi Typedef      ctermfg=6

hi Special      ctermfg=13
hi SpecialChar  ctermfg=13
hi Tag          ctermfg=13
hi Delimiter    ctermfg=7
hi SpecialComment ctermfg=13
hi Debug        ctermfg=13

hi Underlined   ctermfg=4    cterm=underline
hi Error        ctermfg=15   ctermbg=1
hi Todo         ctermfg=0    ctermbg=11

hi DiffAdd      ctermfg=2    ctermbg=0
hi DiffChange   ctermfg=3    ctermbg=0
hi DiffDelete   ctermfg=1    ctermbg=0
hi DiffText     ctermfg=11   ctermbg=0    cterm=none

hi TabLine      ctermfg=8    ctermbg=0    cterm=none
hi TabLineFill  ctermfg=8    ctermbg=0    cterm=none
hi TabLineSel   ctermfg=7    ctermbg=8    cterm=none

hi WildMenu     ctermfg=0    ctermbg=3

hi Directory    ctermfg=4
