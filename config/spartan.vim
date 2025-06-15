" Minimal Colorscheme, only uses 16 (+ fg/bg) colors defined by the terminal.

set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "spartan"

" Basic UI elements
hi Normal       ctermfg=none    ctermbg=none
hi CursorLine   ctermbg=0    cterm=none
hi CursorColumn ctermbg=none
hi ColorColumn	ctermbg=0 " a.k.a column line indicator
hi NonText      ctermfg=8
hi LineNr       ctermfg=8    ctermbg=0
hi CursorLineNr ctermfg=11   ctermbg=8
hi StatusLine   ctermfg=none ctermbg=0    cterm=none
hi StatusLineNC ctermfg=8    ctermbg=0    cterm=none
hi User1        ctermfg=12
hi VertSplit    ctermfg=8    ctermbg=0    cterm=none
hi Visual       ctermfg=0    ctermbg=3
hi Search       ctermfg=0    ctermbg=3
hi IncSearch    ctermfg=0    ctermbg=9
hi Pmenu        ctermfg=7    ctermbg=8
hi PmenuSel     ctermfg=0    ctermbg=3
hi MatchParen   ctermfg=13 ctermbg=none

" Messages and errors
hi ErrorMsg     ctermfg=15   ctermbg=1
hi WarningMsg   ctermfg=11   ctermbg=0
hi MoreMsg      ctermfg=2    ctermbg=0
hi Question     ctermfg=6    ctermbg=0

" Syntax highlighting
hi Comment      ctermfg=8
hi Constant     ctermfg=none
hi String       ctermfg=none
hi Character    ctermfg=none
hi Number       ctermfg=none
hi Boolean      ctermfg=none
hi Float        ctermfg=none
hi Title	ctermfg=3

hi Identifier   ctermfg=none    cterm=none
hi Function     ctermfg=none

hi Statement    ctermfg=none    cterm=none
hi Conditional  ctermfg=none
hi Repeat       ctermfg=none
hi Label        ctermfg=none
hi Operator     ctermfg=none
hi Keyword      ctermfg=none
hi Exception    ctermfg=none

hi PreProc      ctermfg=none
hi Include      ctermfg=none
hi Define       ctermfg=none
hi Macro        ctermfg=none
hi PreCondit    ctermfg=none

hi Type         ctermfg=none    cterm=none
hi StorageClass ctermfg=none
hi Structure    ctermfg=none
hi Typedef      ctermfg=none

hi Special      ctermfg=none
hi SpecialChar  ctermfg=none
hi Tag          ctermfg=none
hi Delimiter    ctermfg=none
hi SpecialComment ctermfg=13
hi Debug        ctermfg=13

hi Underlined   ctermfg=4    cterm=underline
hi Error        ctermfg=13   ctermbg=1
hi Todo         ctermfg=11    ctermbg=none

hi Added        ctermfg=2    ctermbg=0
hi Removed      ctermfg=1    ctermbg=0
hi gitcommitBranch ctermfg=3

hi TabLine      ctermfg=8    ctermbg=0    cterm=none
hi TabLineFill  ctermfg=8    ctermbg=0    cterm=none
hi TabLineSel   ctermfg=7    ctermbg=8    cterm=none

hi WildMenu     ctermfg=0    ctermbg=3

hi Directory    ctermfg=4
