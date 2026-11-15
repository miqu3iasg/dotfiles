" Dumped from Vim 902 | term=tmux-256color | t_Co=256 | background=dark
set background=dark
hi clear
if exists("syntax_on") | syntax reset | endif
let g:colors_name = "plain"
if !has("gui_running") | set notermguicolors | endif
hi SpecialKey ctermfg=4 guifg=Blue
hi NonText term=bold ctermfg=12 gui=bold guifg=Blue
hi Directory term=bold ctermfg=4 guifg=Blue
hi ErrorMsg term=standout ctermfg=15 ctermbg=1 guifg=White guibg=Red
hi IncSearch term=bold,underline,reverse cterm=reverse gui=reverse
hi Search term=reverse ctermbg=11 guibg=Yellow
hi MoreMsg term=bold ctermfg=2 gui=bold guifg=SeaGreen
hi ModeMsg term=bold cterm=bold gui=bold
hi LineNr ctermfg=130 guifg=Brown
hi CursorLineNr term=bold cterm=bold ctermfg=130 gui=bold guifg=Brown
hi Question term=standout ctermfg=2 gui=bold guifg=SeaGreen
hi StatusLine term=bold,reverse cterm=bold,reverse gui=bold,reverse
hi StatusLineNC term=reverse cterm=reverse gui=reverse
hi VertSplit term=reverse cterm=reverse gui=reverse
hi Title term=bold ctermfg=5 gui=bold guifg=Magenta
hi Visual ctermfg=0 ctermbg=248 guifg=Black guibg=LightGrey
hi WarningMsg term=standout ctermfg=1 guifg=Red
hi WildMenu term=underline ctermfg=0 ctermbg=11 guifg=Black guibg=Yellow
hi Folded term=standout ctermfg=4 ctermbg=248 guifg=DarkBlue guibg=LightGrey
hi FoldColumn ctermfg=0 ctermbg=NONE guifg=bg
hi DiffAdd term=bold ctermfg=0 ctermbg=81 guibg=LightBlue
hi DiffChange term=bold ctermfg=0 ctermbg=225 guibg=LightMagenta
hi DiffDelete term=bold ctermfg=12 ctermbg=159 gui=bold guifg=Blue guibg=LightCyan
hi DiffText term=reverse cterm=bold ctermfg=0 ctermbg=9 gui=bold guibg=Red
hi SignColumn ctermfg=0 ctermbg=NONE guifg=bg
hi Conceal ctermfg=7 ctermbg=242 guifg=LightGrey guibg=DarkGrey
hi SpellBad term=reverse ctermbg=224 gui=undercurl guisp=Red
hi SpellCap term=reverse ctermbg=81 gui=undercurl guisp=Blue
hi SpellRare term=reverse ctermbg=225 gui=undercurl guisp=Magenta
hi SpellLocal term=underline ctermbg=14 gui=undercurl guisp=DarkCyan
hi Pmenu term=reverse ctermfg=0 ctermbg=225 guibg=LightMagenta
hi PmenuSel term=underline ctermfg=0 ctermbg=7 guibg=Grey
hi PmenuSbar ctermbg=248 guibg=Grey
hi PmenuThumb term=reverse ctermbg=0 guibg=Black
hi PmenuShadow ctermfg=242 ctermbg=0 guifg=DarkGrey guibg=Black
hi TabLine term=underline cterm=underline ctermfg=0 ctermbg=7 gui=underline guibg=LightGrey
hi TabLineSel term=bold cterm=bold gui=bold
hi TabLineFill term=reverse cterm=reverse gui=reverse
hi CursorColumn term=reverse ctermbg=7 guibg=Grey90
hi CursorLine term=underline cterm=underline guibg=Grey90
hi ColorColumn term=reverse ctermbg=224 guibg=LightRed
hi StatusLineTerm term=bold,reverse cterm=bold ctermfg=15 ctermbg=2 gui=bold guifg=bg guibg=DarkGreen
hi StatusLineTermNC term=reverse ctermfg=15 ctermbg=2 guifg=bg guibg=DarkGreen
hi Added ctermfg=2 guifg=SeaGreen
hi MatchParen term=reverse ctermbg=14 guibg=Cyan
hi ToolbarLine term=underline ctermbg=7 guibg=LightGrey
hi ToolbarButton cterm=bold ctermfg=15 ctermbg=242 gui=bold guifg=White guibg=Grey40
hi Comment term=bold ctermfg=4 guifg=Blue
hi Constant ctermfg=1 guifg=Magenta
hi Special ctermfg=5 guifg=#6a5acd
hi Identifier ctermfg=6 guifg=DarkCyan
hi Statement ctermfg=130 gui=bold guifg=Brown
hi PreProc ctermfg=5 guifg=#6a0dad
hi Type ctermfg=2 gui=bold guifg=SeaGreen
hi Underlined cterm=underline ctermfg=5 gui=underline guifg=SlateBlue
hi Ignore ctermfg=15 guifg=bg
hi Changed ctermfg=12 guifg=DodgerBlue
hi Removed ctermfg=9 guifg=Red
hi Error term=reverse ctermfg=15 ctermbg=9 guifg=White guibg=Red
hi Todo term=standout ctermfg=0 ctermbg=11 guifg=Blue guibg=Yellow
hi Bold term=bold cterm=bold gui=bold
hi Italic term=italic cterm=italic gui=italic
hi BoldItalic term=bold,italic cterm=bold,italic gui=bold,italic
hi! link EndOfBuffer NonText
hi! link CurSearch Search
hi! link CursorLineSign SignColumn
hi! link CursorLineFold FoldColumn
hi! link VertSplitNC VertSplit
hi! link DiffTextAdd DiffText
hi! link PmenuMatch Pmenu
hi! link PmenuMatchSel PmenuSel
hi! link PmenuKind Pmenu
hi! link PmenuKindSel PmenuSel
hi! link PmenuExtra Pmenu
hi! link PmenuExtraSel PmenuSel
hi! link PmenuBorder Pmenu
hi! link Popup Pmenu
hi! link PopupBorder Pmenu
hi! link PopupTitle Pmenu
hi! link QuickFixLine Search
hi! link TabPanel TabLine
hi! link TabPanelSel TabLineSel
hi! link TabPanelFill TabLineFill
hi! link PreInsert Added
hi! link PopupSelected PmenuSel
hi! link MessageWindow WarningMsg
hi! link PopupNotification WarningMsg
hi! link String Constant
hi! link Character Constant
hi! link Number Constant
hi! link Boolean Constant
hi! link Regexp Constant
hi! link Float Number
hi! link Function Identifier
hi! link Conditional Statement
hi! link Repeat Statement
hi! link Label Statement
hi! link Operator Statement
hi! link Keyword Statement
hi! link Exception Statement
hi! link Include PreProc
hi! link Define PreProc
hi! link Macro PreProc
hi! link PreCondit PreProc
hi! link StorageClass Type
hi! link Structure Type
hi! link Typedef Type
hi! link Tag Special
hi! link SpecialChar Special
hi! link Delimiter Special
hi! link SpecialComment Special
hi! link Debug Special
