" vim: tw=0 ts=4 sw=4 et
" Vim color file
"
" Based on Vim's built-in "elflord" color scheme,
" originally by Ron Aaron <ron@ronware.org>
"
" Maintainer:   Adrian Perez <aperez@igalia.com>
"

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

hi Normal     guifg=#dadada  guibg=black

if g:elrond#use_italics
    hi Comment term=italic ctermfg=173 guifg=#d7875f cterm=italic gui=italic
else
    hi Comment ctermfg=173 guifg=#d7875f
endif

hi Constant   term=underline ctermfg=201  guifg=#ff00ff
hi Special    term=NONE      ctermfg=127  guifg=#af00af  gui=NONE
hi Identifier term=underline ctermfg=51   guifg=#00ffff  cterm=NONE gui=NONE
hi Statement  term=NONE      ctermfg=226  guifg=#ffff00  gui=NONE
hi PreProc    term=underline ctermfg=75   guifg=#5fafff
hi Type       term=underline ctermfg=83   guifg=#5fff5f  gui=NONE
hi Function   term=NONE      ctermfg=231  guifg=#ffffff  gui=NONE
hi Operator                  ctermfg=196  guifg=#ff0000
hi Ignore                    ctermfg=black guifg=bg
hi Error      term=reverse   ctermbg=196 ctermfg=231 guibg=#ff0000 guifg=#ffffff
hi Todo       term=standout  ctermbg=226 ctermfg=black guibg=#ffff00 guifg=#000000 gui=bold cterm=bold

highlight CursorLine NONE

if &t_Co >= 256 || !empty($NVIM_TUI_ENABLE_TRUE_COLOR)
    if g:elrond#cursorline
        set cursorline
    endif
endif

highlight CursorLine    ctermbg=234               guibg=#1c1c1c
highlight CursorLineNr  ctermbg=235 ctermfg=246   guibg=#262626 guifg=#949494
highlight LineNr        ctermbg=234 ctermfg=238   guibg=#1c1c1c guifg=#444444
highlight SignColumn    ctermbg=234               guibg=#1c1c1c
highlight Pmenu         ctermbg=235 ctermfg=253   guibg=#262626 guifg=#dadada
highlight PmenuSel      ctermbg=238 ctermfg=231   guibg=#444444 guifg=#ffffff
highlight PmenuSbar     ctermbg=238               guibg=#444444
highlight PmenuThumb    ctermbg=240               guibg=#585858
highlight VertSplit     ctermbg=NONE ctermfg=White guibg=NONE guifg=#ffffff cterm=NONE gui=NONE
highlight WinSeparator  ctermbg=NONE ctermfg=White guibg=NONE guifg=#ffffff cterm=NONE gui=NONE
set fillchars+=vert:│
highlight StatusLine    ctermbg=235 ctermfg=230   guibg=#262626 guifg=#ffffd7 cterm=NONE gui=NONE
highlight StatusLineNC  ctermbg=235 ctermfg=244   guibg=#262626 guifg=#949494 cterm=NONE gui=NONE
highlight TabLine       ctermbg=235 ctermfg=246   guibg=#262626 guifg=#949494 cterm=NONE gui=NONE
highlight TabLineSel    ctermbg=246 ctermfg=235   guibg=#949494 guifg=#262626 cterm=NONE gui=NONE
highlight TabLineFill   ctermbg=235               guibg=#262626               cterm=NONE gui=NONE

highlight LiningItem    ctermbg=236 ctermfg=252   guibg=#303030 guifg=#d0d0d0
highlight LiningVertSep ctermbg=236 ctermfg=240   guibg=#303030 guifg=#585858
highlight LiningBufName ctermbg=237 ctermfg=252   guibg=#3a3a3a guifg=#d0d0d0 cterm=NONE gui=NONE
highlight LiningBufPath ctermbg=237 ctermfg=252   guibg=#3a3a3a guifg=#d0d0d0 cterm=NONE gui=NONE

highlight DiffAdd    guibg=#005f00 guifg=#87ff00 gui=NONE
highlight DiffDelete guibg=#5f0000 guifg=#870000 gui=NONE
highlight DiffChange guibg=#303030               gui=NONE
highlight DiffText   guibg=#5f005f guifg=#ff00d7 gui=NONE
highlight SpellBad   guisp=#ff5f5f gui=undercurl
highlight SpellCap   guisp=#005f87 gui=undercurl

if &t_Co < 256
    "
    " Common definitions for 8 & 16 color terminals
    "
    highlight Comment       ctermfg=DarkYellow
    highlight Constant      ctermfg=Magenta
    highlight Special       ctermfg=DarkMagenta
    highlight Identifier    ctermfg=Cyan
    highlight Statement     ctermfg=Yellow
    highlight PreProc       ctermfg=LightBlue
    highlight Type          ctermfg=LightGreen
    highlight Function      ctermfg=White
    highlight Operator      ctermfg=Red
    highlight Error         ctermbg=Red    ctermfg=White
    highlight Todo          ctermbg=Yellow ctermfg=Black

    highlight CursorLineNr  ctermbg=DarkGrey  ctermfg=White     cterm=NONE gui=NONE
    highlight LineNr        ctermbg=DarkGrey  ctermfg=LightGrey
    highlight SignColumn    ctermbg=Black                       cterm=NONE gui=NONE
    highlight VertSplit     ctermbg=NONE      ctermfg=White
    highlight WinSeparator  ctermbg=NONE      ctermfg=White
    highlight StatusLineNC  ctermbg=LightGrey ctermfg=0         cterm=reverse
    highlight TabLine       ctermbg=DarkGrey  ctermfg=LightGrey cterm=NONE
    highlight TabLineSel    ctermbg=LightGrey ctermfg=White
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

        highlight Pmenu         ctermbg=DarkGrey  ctermfg=White
        highlight PmenuSel      ctermbg=LightGrey ctermfg=White cterm=NONE
        highlight PmenuSbar     ctermbg=DarkGrey  ctermfg=White
        highlight PmenuThumb    ctermbg=DarkGrey  ctermfg=LightGrey

        highlight StatusLine    ctermbg=White     ctermfg=0     cterm=reverse
        highlight LiningItem    ctermbg=DarkGrey  ctermfg=White cterm=NONE
        highlight LiningBufName ctermbg=White     ctermfg=Black cterm=NONE
        highlight LiningBufPath ctermbg=LightGrey ctermfg=Black cterm=NONE
    else
        set nocursorline

        highlight Comment       ctermfg=DarkYellow

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
    " Use more pleasant colors for Diff highlights whenever possible.
    highlight DiffAdd    cterm=NONE ctermbg=22 ctermfg=118
    highlight DiffDelete cterm=NONE ctermbg=52 ctermfg=88
    highlight DiffChange cterm=NONE ctermbg=236
    highlight DiffText   cterm=NONE ctermbg=53 ctermfg=201

    highlight SpellBad   ctermbg=52
    highlight SpellCap   ctermbg=24
endif

highlight LiningWarn  ctermbg=94  ctermfg=221 guibg=#875f00 guifg=#ffd75f
highlight LiningError ctermbg=160 ctermfg=231 guibg=#d70000 guifg=#ffffff

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
