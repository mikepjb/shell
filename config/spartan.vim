if has("gui_running") && &background !=# 'dark'
    set background=dark
endif
hi clear
if exists("syntax_on")
   syntax reset
endif

let colors_name = "spartan"

" Standard UI elements
hi Normal       ctermfg=NONE ctermbg=NONE
hi NonText      ctermfg=NONE ctermbg=NONE
hi CursorLine   ctermfg=NONE ctermbg=0  cterm=NONE
hi CursorColumn ctermfg=NONE ctermbg=0  cterm=NONE
hi ColorColumn  ctermfg=NONE ctermbg=0  cterm=NONE
hi LineNr       ctermfg=0
hi CursorLineNr ctermfg=8    ctermbg=0  cterm=NONE
hi StatusLine   ctermbg=0    cterm=NONE term=NONE
hi StatusLineNC ctermbg=0    cterm=NONE term=NONE
hi TabLine      ctermbg=0    cterm=NONE term=NONE
hi TabLineFill  ctermbg=0    cterm=NONE term=NONE
hi TabLineSel   ctermbg=8    cterm=NONE term=NONE
hi VertSplit    ctermfg=0    cterm=NONE term=NONE
hi Directory    ctermfg=4
hi WildMenu     ctermfg=0    ctermbg=7
hi Visual       ctermbg=14
hi Search       ctermbg=14
hi IncSearch    ctermbg=6
hi Pmenu        ctermfg=7 ctermbg=0
hi PmenuSel     ctermfg=9 ctermbg=8
hi MatchParen   ctermfg=9 ctermbg=NONE
hi Error        ctermfg=1 ctermbg=NONE
hi ErrorMsg     ctermfg=1 ctermbg=NONE
hi WarningMsg   ctermfg=3 ctermbg=NONE
hi MoreMsg      ctermfg=4 ctermbg=NONE
hi Question     ctermfg=4 ctermbg=NONE

" Syntax
hi Comment      ctermfg=8
hi Todo         ctermfg=1 ctermbg=NONE

hi link SpecialComment Comment

" " Diff
" call s:hl('DiffAdd', {'fg': 'magenta'})
" call s:hl('DiffChange', {'fg': 'yellow'})
" call s:hl('DiffDelete', {'fg': 'teal'})
" call s:hl('DiffText', {'fg': 'teal'})
" call s:hl('DiffTextAdd', {'fg': 'teal'})
" 
" " Spell
" call s:hl('SpellBad', {'fg': 'magenta'})
" call s:hl('SpellCap', {'fg': 'yellow'})
" call s:hl('SpellLocal', {'fg': 'teal'})
" call s:hl('SpellRare', {'fg': 'teal'})
" 
" " Syntax highlighting
" call s:hl('Comment', {'fg': 'fg++'})
" call s:hl('SpecialComment', {'fg': 'magenta'})
" call s:hl('Todo', {'fg': 'magenta'})
" call s:hl('Title', {'fg': 'yellow'})
" call s:hl('String', {'fg': 'teal'})
" call s:hl('Function', {'fg': 'fg+'})
" call s:hl('Statement', {'fg': 'fg+'})
" call s:hl('Constant', {'fg': 'sapphire'})
" call s:hl('Type', {'fg': 'teal'})
" call s:hl('PreProc', {'fg': 'lavender'})
" call s:hl('Delimiter', {'fg': 'sapphire'})
" call s:hl('Special', {'fg': 'teal'})
" call s:hl('Identifier', {'fg': 'sapphire'})
" call s:hl('Added', {'fg': 'green', 'bg': 'bg+'})
" call s:hl('Removed', {'fg': 'red', 'bg': 'bg+'})
" call s:hl('gitcommitBranch', {'fg': 'yellow'})
" call s:hl('markdownCode', {'fg': 'cyan'})
" call s:hl('markdownCodeBlock', {'fg': 'cyan'})
" 
" " hi link rubyDefine          Keyword
" " hi link rubySymbol          Constant
" " hi link rubyEval            rubyMethod
" " hi link rubyException       rubyMethod
" " hi link rubyInclude         rubyMethod
" " hi link rubyMacro           rubyMethod
" " hi link rubyStringDelimiter rubyString
" " hi link rubyRegexp          Regexp
" " hi link rubyRegexpDelimiter rubyRegexp
" " 
" " hi link javascriptRegexpString  Regexp
" " 
" " hi link diffAdded               String
" " hi link diffRemoved             Statement
" " hi link diffLine                PreProc
" " hi link diffSubname             Comment
