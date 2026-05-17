if has("gui_running") && &background !=# 'dark'
    set background=dark
endif
hi clear
if exists("syntax_on")
   syntax reset
endif

let colors_name = "spartan"

let s:colors = {
      \ 'yellow': 3,
      \ 'magenta': 11,
      \ 'cyan': 14,
      \ 'lavender': 5,
      \ 'teal': 6,
      \ 'sapphire': 4,
      \ 'bg': 'NONE',
      \ 'bg+': 0,
      \ 'bg++': 8,
      \ 'fg': 'NONE',
      \ 'fg+': 7,
      \ 'fg++': 15,
      \ 'red': 1,
      \ 'green': 2,
      \ 'diff_red': 9,
      \ 'diff_green': 10,
      \ 'none': 'NONE',
      \ }

function! s:hl(group, settings)
    " Get value from map, or default to 'none' (which maps to 'NONE')
    let l:fg   = get(a:settings, 'fg', 'none')
    let l:bg   = get(a:settings, 'bg', 'none')
    let l:attr = get(a:settings, 'attr', 'none')

    let l:cmd = printf('hi %s ctermfg=%s ctermbg=%s cterm=%s', 
        \ a:group, 
        \ s:colors[l:fg], 
        \ s:colors[l:bg], 
        \ l:attr)

    execute l:cmd
endfunction

" Standard UI elements
call s:hl('Normal',       {'fg': 'fg',    'bg': 'bg'})
call s:hl('NonText',      {'fg': 'fg',    'bg': 'bg'})

" Cursor and Columns
call s:hl('CursorLine',   {'fg': 'bg',    'bg': 'bg+'})
" call s:hl('CursorColumn', {'fg': 'bg',    'bg': 'bg+'})
call s:hl('ColorColumn',  {'bg': 'bg+'})

" Gutters and Numbers
call s:hl('LineNr',       {'fg': 'bg++'})
call s:hl('CursorLineNr', {'fg': 'yellow'})

call s:hl('StatusLine', {'fg': 'fg', 'bg': 'bg+'})
call s:hl('StatusLineNC', {'fg': 'fg', 'bg': 'bg+'})
call s:hl('TabLine', {'fg': 'fg', 'bg': 'bg+'})
call s:hl('TabLineFill', {'fg': 'fg', 'bg': 'bg+'})
call s:hl('TabLineSel', {'fg': 'fg', 'bg': 'bg++'})

" is this nvim only?
" call s:hl('WildMenu', {'fg': 'fg', 'bg': 'bg++'})

call s:hl('Directory', {'fg': 'sapphire'})
call s:hl('User1', {'fg': 'green'})
call s:hl('VertSplit', {'fg': 'bg++'})
call s:hl('Visual', {'fg': 'yellow', 'bg': 'bg+'})
call s:hl('Search', {'fg': 'yellow'})
call s:hl('IncSearch', {'fg': 'magenta'})
call s:hl('Pmenu', {'fg': 'fg', 'bg': 'bg+'})
call s:hl('PmenuSel', {'fg': 'fg', 'bg': 'bg++'})
call s:hl('MatchParen', {'fg': 'magenta'})

" Messages and errors
call s:hl('ErrorMsg', {'fg': 'magenta'})
call s:hl('WarningMsg', {'fg': 'yellow'})
call s:hl('MoreMsg', {'fg': 'teal'})
call s:hl('Question', {'fg': 'teal'})

" Syntax highlighting
call s:hl('Comment', {'fg': 'fg++'})
call s:hl('SpecialComment', {'fg': 'magenta'})
call s:hl('Todo', {'fg': 'magenta'})
call s:hl('Title', {'fg': 'yellow'})
call s:hl('String', {'fg': 'teal'})
call s:hl('Function', {'fg': 'fg+'})
call s:hl('Statement', {'fg': 'fg+'})
call s:hl('Constant', {'fg': 'sapphire'})
call s:hl('Type', {'fg': 'teal'})
call s:hl('PreProc', {'fg': 'lavender'})
call s:hl('Delimiter', {'fg': 'sapphire'})
call s:hl('Special', {'fg': 'teal'})
call s:hl('Identifier', {'fg': 'sapphire'})
call s:hl('Added', {'fg': 'green', 'bg': 'bg+'})
call s:hl('Removed', {'fg': 'red', 'bg': 'bg+'})
call s:hl('gitcommitBranch', {'fg': 'yellow'})
call s:hl('markdownCode', {'fg': 'cyan'})
call s:hl('markdownCodeBlock', {'fg': 'cyan'})

" hi link rubyDefine          Keyword
" hi link rubySymbol          Constant
" hi link rubyEval            rubyMethod
" hi link rubyException       rubyMethod
" hi link rubyInclude         rubyMethod
" hi link rubyMacro           rubyMethod
" hi link rubyStringDelimiter rubyString
" hi link rubyRegexp          Regexp
" hi link rubyRegexpDelimiter rubyRegexp
" 
" hi link javascriptRegexpString  Regexp
" 
" hi link diffAdded               String
" hi link diffRemoved             Statement
" hi link diffLine                PreProc
" hi link diffSubname             Comment
