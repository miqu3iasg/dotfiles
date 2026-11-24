" colors/elrond.vim
"
" vim: tw=0 ts=4 sw=4 et
" Vim color file
"
" Based on Vim's built-in "elflord" color scheme, originally by Ron Aaron <ron@ronware.org>
"
" Copyright (c) Adrian Perez <aperez@igalia.com>
" Copyright (c) Miquéias Alves Medeiros <https://github.com/miqu3iasg>

set background=dark
hi clear
if exists('syntax_on')
  syntax reset
endif

if has('nvim-0.10.0')
    source $VIMRUNTIME/colors/vim.lua
endif

let g:colors_name = 'elrond'

let g:elrond#use_italics  = get(g:, 'elrond#use_italics',        0)
let g:elrond#cursorline   = get(g:, 'elrond#cursorline',         0)
let g:elrond#cursorline16 = get(g:, 'elrond#cursorline16' , 'underline')

hi Normal     guifg=#bbbbbb  guibg=black

if g:elrond#use_italics
    hi Comment term=italic ctermfg=67 guifg=#3f86c0 cterm=italic gui=italic
else
    hi Comment ctermfg=67 guifg=#3f86c0
endif

hi Constant   term=underline ctermfg=170  guifg=#db3ddb
hi Special    term=NONE      ctermfg=115   guifg=#78dbc3  gui=NONE
hi Identifier term=underline ctermfg=80   guifg=#3ddbdb  cterm=NONE gui=NONE
hi Statement  term=NONE      ctermfg=185  guifg=#dbdb3d  gui=NONE
hi PreProc    term=underline ctermfg=173  guifg=#db913d
hi Type       term=underline ctermfg=114   guifg=#78db78  gui=NONE
hi Function   term=NONE      ctermfg=253  guifg=#dbdbdb  gui=NONE
hi Operator                  ctermfg=167  guifg=#db3d3d
hi Ignore                    ctermfg=black guifg=bg
hi Error      term=reverse   ctermbg=167 ctermfg=253 guibg=#db3d3d guifg=#dbdbdb
hi Todo       term=standout  ctermbg=185 ctermfg=black guibg=#dbdb3d guifg=#000000 gui=bold cterm=bold

highlight CursorLine NONE

if &t_Co >= 256 || !empty($NVIM_TUI_ENABLE_TRUE_COLOR)
    if g:elrond#cursorline
        set cursorline
    endif
endif

highlight CursorLine    ctermbg=234               guibg=#1a1a1a
highlight CursorLineNr  ctermbg=NONE ctermfg=185  guibg=NONE    guifg=#dbdb3d cterm=bold gui=bold
highlight LineNr        ctermbg=NONE ctermfg=67   guibg=NONE    guifg=#3f86c0
highlight SignColumn    ctermbg=NONE              guibg=NONE
highlight FoldColumn    ctermbg=NONE ctermfg=67   guibg=NONE    guifg=#3f86c0
highlight Folded        ctermbg=17   ctermfg=73   guibg=#171752 guifg=#34b9b9

highlight Pmenu         ctermbg=239  ctermfg=249  guibg=#4c4c4c guifg=#b3b3b3
highlight PmenuSel      ctermbg=249  ctermfg=black guibg=#b3b3b3 guifg=#000000
highlight PmenuSbar     ctermbg=239               guibg=#4c4c4c
highlight PmenuThumb    ctermbg=249               guibg=#b3b3b3

highlight VertSplit     ctermbg=NONE ctermfg=249  guibg=NONE guifg=#b3b3b3 cterm=NONE gui=NONE
highlight WinSeparator  ctermbg=NONE ctermfg=249  guibg=NONE guifg=#b3b3b3 cterm=NONE gui=NONE
set fillchars+=vert:│
highlight StatusLine    ctermbg=249  ctermfg=black guibg=#b3b3b3 guifg=#000000 cterm=bold gui=bold
highlight StatusLineNC  ctermbg=239  ctermfg=249   guibg=#4c4c4c guifg=#b3b3b3 cterm=NONE gui=NONE
highlight TabLine       ctermbg=239  ctermfg=249   guibg=#4c4c4c guifg=#b3b3b3 cterm=NONE gui=NONE
highlight TabLineSel    ctermbg=249  ctermfg=black guibg=#b3b3b3 guifg=#000000 cterm=bold gui=bold
highlight TabLineFill   ctermbg=239                guibg=#4c4c4c               cterm=NONE gui=NONE

highlight LiningItem    ctermbg=239  ctermfg=249   guibg=#4c4c4c guifg=#b3b3b3
highlight LiningVertSep ctermbg=239  ctermfg=247   guibg=#4c4c4c guifg=#a2a2a2
highlight LiningBufName ctermbg=249  ctermfg=black guibg=#b3b3b3 guifg=#000000 cterm=bold gui=bold
highlight LiningBufPath ctermbg=247  ctermfg=black guibg=#a2a2a2 guifg=#000000 cterm=NONE gui=NONE

highlight Visual        ctermbg=24   ctermfg=253   guibg=#215b74 guifg=#dbdbdb
highlight Search        ctermbg=185  ctermfg=black guibg=#dbdb3d guifg=#000000
highlight IncSearch     ctermbg=114   ctermfg=black guibg=#78db78 guifg=#000000
highlight MatchParen    ctermbg=NONE ctermfg=253   guibg=NONE    guifg=#dbdbdb cterm=bold,underline gui=bold,underline
highlight NonText       ctermfg=30                 guifg=#217474
highlight EndOfBuffer   ctermbg=NONE ctermfg=25   guibg=NONE    guifg=#2459a6
highlight SpecialKey    ctermfg=30                 guifg=#217474
highlight Directory     ctermfg=80                 guifg=#3ddbdb
highlight Title         ctermfg=185                guifg=#dbdb3d cterm=bold gui=bold
highlight ErrorMsg      ctermbg=167  ctermfg=253   guibg=#db3d3d guifg=#dbdbdb
highlight WarningMsg    ctermfg=185                guifg=#dbdb3d
highlight MoreMsg       ctermfg=114                 guifg=#78db78
highlight Question      ctermfg=114                 guifg=#78db78

highlight DiffAdd    guibg=#175217 guifg=#91db3d gui=NONE
highlight DiffDelete guibg=#521717 guifg=#db7878 gui=NONE
highlight DiffChange guibg=#0b2328               gui=NONE
highlight DiffText   guibg=#215b74 guifg=#dbdbdb gui=bold
highlight SpellBad   guisp=#db7878 gui=undercurl
highlight SpellCap   guisp=#34b9b9 gui=undercurl

if &t_Co < 256
    "
    " Common definitions for 8 & 16 color terminals
    "
    highlight Comment       ctermfg=DarkCyan
    highlight Constant      ctermfg=Magenta
    highlight Special       ctermfg=LightCyan
    highlight Identifier    ctermfg=Cyan
    highlight Statement     ctermfg=Yellow
    highlight PreProc       ctermfg=DarkYellow
    highlight Type          ctermfg=LightGreen
    highlight Function      ctermfg=White
    highlight Operator      ctermfg=Red
    highlight Error         ctermbg=Red    ctermfg=White
    highlight Todo          ctermbg=Yellow ctermfg=Black

    highlight CursorLineNr  ctermbg=NONE      ctermfg=Yellow    cterm=bold gui=NONE
    highlight LineNr        ctermbg=NONE      ctermfg=DarkCyan
    highlight EndOfBuffer   ctermbg=NONE      ctermfg=Blue
    highlight SignColumn    ctermbg=NONE                        cterm=NONE gui=NONE
    highlight VertSplit     ctermbg=NONE      ctermfg=White
    highlight WinSeparator  ctermbg=NONE      ctermfg=White
    highlight StatusLineNC  ctermbg=DarkGrey  ctermfg=LightGrey cterm=NONE
    highlight TabLine       ctermbg=DarkGrey  ctermfg=LightGrey cterm=NONE
    highlight TabLineSel    ctermbg=LightGrey ctermfg=Black     cterm=bold
    highlight TabLineFill   ctermbg=DarkGrey                    cterm=NONE

    if &t_Co >= 16
        if g:elrond#cursorline
            set cursorline
            if g:elrond#cursorline16 ==# 'bold'
                highlight CursorLine cterm=bold
            elseif g:elrond#cursorline16 ==# 'reverse'
                highlight CursorLine cterm=reverse
            elseif g:elrond#cursorline16 ==# 'underline'
                highlight CursorLine cterm=underline
            endif
        endif

        highlight Pmenu         ctermbg=DarkGrey  ctermfg=LightGrey
        highlight PmenuSel      ctermbg=LightGrey ctermfg=Black cterm=NONE
        highlight PmenuSbar     ctermbg=DarkGrey  ctermfg=LightGrey
        highlight PmenuThumb    ctermbg=LightGrey ctermfg=Black

        highlight StatusLine    ctermbg=LightGrey ctermfg=Black cterm=bold
        highlight LiningItem    ctermbg=DarkGrey  ctermfg=LightGrey cterm=NONE
        highlight LiningBufName ctermbg=LightGrey ctermfg=Black cterm=bold
        highlight LiningBufPath ctermbg=LightGrey ctermfg=Black cterm=NONE
    else
        set nocursorline

        highlight Pmenu         ctermfg=NONE ctermbg=NONE  cterm=reverse
        highlight PmenuSel      ctermfg=Cyan ctermbg=Black cterm=reverse
        highlight PmenuSbar     ctermfg=Cyan ctermbg=NONE
        highlight PmenuThumb    ctermfg=Cyan ctermbg=NONE  cterm=NONE

        highlight StatusLine    ctermfg=NONE ctermbg=NONE  cterm=reverse
        highlight StatusLineNC  ctermfg=NONE ctermbg=NONE  cterm=reverse
        highlight LiningBufName ctermfg=Cyan ctermbg=Black cterm=reverse
        highlight LiningBufPath ctermfg=Cyan ctermbg=Black cterm=reverse
        highlight link LiningItem StatusLine
    endif

    highlight link LiningVertSep LiningItem
else
    " Diff highlights for 256-color terminals (no pink here either)
    highlight DiffAdd    cterm=NONE ctermbg=22 ctermfg=113
    highlight DiffDelete cterm=NONE ctermbg=52 ctermfg=174
    highlight DiffChange cterm=NONE ctermbg=17
    highlight DiffText   cterm=bold ctermbg=24 ctermfg=253

    highlight SpellBad   ctermbg=52
    highlight SpellCap   ctermbg=24
endif

highlight LiningWarn  ctermbg=185 ctermfg=black guibg=#dbdb3d guifg=#000000
highlight LiningError ctermbg=131 ctermfg=253   guibg=#b93434 guifg=#dbdbdb

highlight link LiningLnCol   LiningBufName
highlight link LiningVcsInfo LiningItem

hi link String         Constant
hi link Character      Constant
hi link Number         Constant
hi link Boolean        Constant
hi link Float          Number
hi link Repeat         Statement
hi link Conditional    Statement
hi link Label          Statement
hi link Keyword        Statement
hi link Exception      Statement
hi link Include        PreProc
hi link Define         PreProc
hi link Macro          PreProc
hi link PreCondit      PreProc
hi link StorageClass   Type
hi link Structure      Type
hi link Typedef        Type
hi link Tag            Special
hi link SpecialChar    Special
hi link Delimiter      Special
hi link SpecialComment Special
hi link Debug          Special

hi ColorColumn NONE
hi link ColorColumn    CursorLine
