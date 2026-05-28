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
hi LineNr       ctermfg=8
hi CursorLineNr ctermfg=8    ctermbg=0  cterm=NONE
hi StatusLine   ctermbg=0    cterm=NONE term=NONE
hi StatusLineNC ctermbg=0    cterm=NONE term=NONE
hi TabLine      ctermbg=0    cterm=NONE term=NONE
hi TabLineFill  ctermbg=0    cterm=NONE term=NONE
hi TabLineSel   ctermbg=8    cterm=NONE term=NONE
hi VertSplit    ctermfg=8    cterm=NONE term=NONE
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
hi QuickFixLine ctermbg=0
hi qfLineNr     ctermfg=3

" Syntax
hi Comment     ctermfg=8
hi Todo        ctermfg=3 ctermbg=NONE
hi DiffAdd     ctermfg=2
hi DiffChange  ctermfg=3
hi DiffDelete  ctermfg=1
hi DiffText    ctermfg=4
hi DiffTextAdd ctermfg=4
hi SpellBad    ctermfg=1 ctermbg=NONE cterm=underline
hi SpellCap    ctermfg=3 ctermbg=NONE cterm=underline
hi SpellLocal  ctermfg=3 ctermbg=NONE cterm=underline
hi SpellRare   ctermfg=3 ctermbg=NONE cterm=underline
hi Title       ctermfg=5
hi Statement   ctermfg=7
hi String      ctermfg=3
hi Function    ctermfg=5
hi Constant    ctermfg=6
hi Type        ctermfg=3
hi PreProc     ctermfg=4
hi Delimiter   ctermfg=6
hi Special     ctermfg=3
hi Identifier  ctermfg=2
hi Added       ctermfg=2
hi Removed     ctermfg=1

hi link SpecialComment Comment
hi link gitcommitBranch String
hi link markdownCode Type
hi link markdownCodeBlock Type

hi link rubyDefine          Keyword
hi link rubySymbol          Constant
hi link rubyEval            rubyMethod
hi link rubyException       rubyMethod
hi link rubyInclude         rubyMethod
hi link rubyMacro           rubyMethod
hi link rubyStringDelimiter rubyString
hi link rubyRegexp          Regexp
hi link rubyRegexpDelimiter rubyRegexp

hi link javascriptRegexpString  Regexp

hi link diffAdded               String
hi link diffRemoved             Statement
hi link diffLine                PreProc
hi link diffSubname             Comment

" We use autocmds to ensure these run after markdown syntax file is loaded
augroup MarkdownTaskHighlighting
  autocmd!
  autocmd FileType markdown syntax match Todo /\v\c<(TODO)>/ containedin=ALL
  autocmd FileType markdown syntax match TaskNext /\v\c<(NEXT|CURRENT)>/ containedin=ALL
  autocmd FileType markdown syntax match TaskDone /\v\c<(DONE)>/ containedin=ALL
augroup END

" You can leave these at the root of the colorscheme file safely
hi TaskNext ctermfg=1 guifg=#FF0000
hi TaskDone ctermfg=2 guifg=#00FF00 cterm=strikethrough gui=strikethrough

hi TaskNext ctermfg=1
hi TaskDone ctermfg=2 cterm=strikethrough
