"
"
"
"      88b           d88 88
"      888b         d888 ""
"      88`8b       d8'88
"      88 `8b     d8' 88 88  ,adPPYba, ,adPPYba,
"      88  `8b   d8'  88 88 a8P_____88 I8[    ""
"      88   `8b d8'   88 88 8PP"""""""  `"Y8ba,
"      88    `888'    88 88 "8b,   ,aa aa    ]8I
"      88     `8'     88 88  `"Ybbd8"' `"YbbdP"'
"
"
"
" File:       mies.vim
" Maintainer: Jared Gorski <jaredgorski6@gmail.com>
" Repository: https://github.com/jaredgorski/Mies.vim
" License:    MIT

scriptencoding utf-8

hi clear
if exists("syntax_on")
  syntax reset
endif

let g:colors_name="mies"

" ==========================
" Highlighting Function
" ==========================
fun! <sid>hi(group, fg, bg, attr, ...)
  if !empty(a:fg)
    exec "hi " . a:group . " guifg=" . a:fg.gui . " ctermfg=" .  a:fg.cterm256
  endif
  if !empty(a:bg)
    exec "hi " . a:group . " guibg=" . a:bg.gui . " ctermbg=" .  a:bg.cterm256
  endif
  if a:attr != ""
    exec "hi " . a:group . " gui=" . a:attr . " cterm=" . a:attr
  endif
  if a:0 > 0 && !empty(a:1)
    exec "hi " . a:group . " guisp=" . a:1.gui
  endif
endfun

" ==========================
" Color Variables
" ==========================
let s:chicagoBlack1 = {'gui': '#080808', 'cterm256': '232'}
let s:chicagoBlack2 = {'gui': '#000000', 'cterm256': '16'}
let s:chicagoBlack3 = {'gui': '#1c1c1c', 'cterm256': '234'}
let s:chicagoBlack4 = {'gui': '#262626', 'cterm256': '235'}
let s:gutterSign = {'gui': '#0a0a0a', 'cterm256': '232'}
let s:gutterNr = {'gui': '#141414', 'cterm256': '233'}
let s:chicagoGray1 = {'gui': '#3E3D32', 'cterm256': '237'}
let s:chicagoGray2 = {'gui': '#49483E', 'cterm256': '239'}
let s:chicagoGray3 = {'gui': '#767676', 'cterm256': '243'}
let s:chicagoGray4 = {'gui': '#949494', 'cterm256': '246'}
let s:chicagoGray5 = {'gui': '#B0B0B0', 'cterm256': '249'}
let s:chicagoGray6 = {'gui': '#C6C6C6', 'cterm256': '251'}
let s:chicagoWhite1 = {'gui': '#D0D0D0', 'cterm256': '252'}
let s:chicagoWhite2 = {'gui': '#FFFFFF', 'cterm256': '231'}
let s:chicagoBlue = {'gui': '#5F8787', 'cterm256': '66'}
let s:chicagoGreen1 = {'gui': '#008700', 'cterm256': '28'}
let s:chicagoGreen2 = {'gui': '#00af5f', 'cterm256': '35'}
let s:chicagoGold1 = {'gui': '#8E700B', 'cterm256': '136'}
let s:chicagoGold2 = {'gui': '#D7AF00', 'cterm256': '178'}
let s:chicagoBrown = {'gui': '#5F5F00', 'cterm256': '58'}
let s:chicagoRed = {'gui': '#D70000', 'cterm256': '160'}
let s:none = {'gui': 'NONE', 'cterm256': 'NONE'}

" Hollow colors (dark only)
let s:completionBg = {'gui': '#141414', 'cterm256': '233'}
let s:surfaceHi = {'gui': '#303030', 'cterm256': '236'}
let s:border = {'gui': '#444444', 'cterm256': '238'}
let s:dim = {'gui': '#707070', 'cterm256': '242'}

let s:error = {'gui': '#b86a6a', 'cterm256': '131'}
let s:warn = {'gui': '#b09b72', 'cterm256': '137'}
let s:ok = {'gui': '#678a67', 'cterm256': '65'}
let s:errorBg = {'gui': '#0f0505', 'cterm256': '232'}
let s:warnBg = {'gui': '#0f0b03', 'cterm256': '232'}
let s:infoBg = {'gui': '#070707', 'cterm256': '232'}
let s:hintBg = {'gui': '#050505', 'cterm256': '232'}
let s:okBg = {'gui': '#040d06', 'cterm256': '232'}

let s:searchFg = {'gui': '#D6C17A', 'cterm256': '180'}
let s:searchBg = {'gui': '#3D3525', 'cterm256': '236'}

let s:diffAddBg = {'gui': '#0f1a12', 'cterm256': '233'}
let s:diffChangeBg = {'gui': '#101722', 'cterm256': '234'}
let s:diffDeleteBg = {'gui': '#1a1112', 'cterm256': '233'}
let s:diffTextBg = {'gui': '#1f3050', 'cterm256': '236'}
let s:diffAddTextBg = {'gui': '#1c3324', 'cterm256': '235'}
let s:diffDeleteTextBg = {'gui': '#3a1f21', 'cterm256': '235'}
let s:diffAdded = {'gui': '#6f9a73', 'cterm256': '65'}
let s:diffChanged = {'gui': '#6f8fb8', 'cterm256': '67'}
let s:diffRemoved = {'gui': '#b87a7a', 'cterm256': '138'}

let s:mdStrike = {'gui': '#6c6c6c', 'cterm256': '242'}
let s:mdMarker = {'gui': '#585858', 'cterm256': '240'}
let s:mdBlock = {'gui': '#b2b2b2', 'cterm256': '249'}
let s:mdString = {'gui': '#cecece', 'cterm256': '252'}
let s:mdCode = {'gui': '#93a0b4', 'cterm256': '109'}
let s:mdAccent = {'gui': '#738296', 'cterm256': '66'}
let s:mdUrl = {'gui': '#6382eb', 'cterm256': '68'}
let s:mdCodeBg = {'gui': '#0d0d0d', 'cterm256': '232'}

" ==========================
" Definitions
" ==========================
" call <sid>hi(GROUP, FOREGROUND, BACKGROUND, ATTRIBUTE [, SPECIAL])
if &background == 'light'
  " Editor
  call <sid>hi('ColorColumn', s:none, s:chicagoGray4, 'none')
  call <sid>hi('Cursor', s:chicagoWhite2, s:chicagoBlack3, 'none')
  call <sid>hi('CursorColumn', s:none, s:chicagoWhite1, 'none')
  call <sid>hi('CursorLine', s:none, s:chicagoWhite1, 'none')
  call <sid>hi('CursorLineNr', s:chicagoBlack1, s:chicagoGray5, 'none')
  call <sid>hi('Directory', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('FoldColumn', s:chicagoGray6, s:chicagoBlack4, 'none')
  call <sid>hi('Folded', s:chicagoGray4, s:none, 'none')
  call <sid>hi('IncSearch', s:chicagoGold2, s:chicagoGray1, 'none')
  call <sid>hi('LineNr', s:chicagoBlack3, s:chicagoGray6, 'none')
  call <sid>hi('MatchParen', s:chicagoBlack1, s:chicagoGray4, 'none')
  call <sid>hi('Normal', s:chicagoBlack1, s:chicagoWhite2, 'none')
  call <sid>hi('Pmenu', s:chicagoBlack1, s:chicagoGray6, 'none')
  call <sid>hi('PmenuSel', s:chicagoWhite2, s:chicagoGray4, 'none')
  call <sid>hi('Search', s:chicagoGold2, s:chicagoGray1, 'none')
  call <sid>hi('SignColumn', s:none, s:chicagoGray1, 'none')
  call <sid>hi('StatusLine', s:chicagoWhite2, s:chicagoGray1, 'none')
  call <sid>hi('StatusLineNC', s:chicagoGray6, s:chicagoGray1, 'none')
  call <sid>hi('VertSplit', s:chicagoBlack1, s:chicagoGray3, 'none')
  call <sid>hi('Visual', s:none, s:chicagoGray5, 'none')

  " General
  call <sid>hi('Boolean', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('Character', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('Comment', s:chicagoGray3, s:none, 'none')
  call <sid>hi('Conditional', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('Constant', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('Define', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('DiffAdd', s:chicagoBlack1, s:chicagoGreen1, 'none')
  call <sid>hi('DiffChange', s:chicagoBlack1, s:chicagoGold2, 'none')
  call <sid>hi('DiffDelete', s:chicagoBlack1, s:chicagoRed, 'none')
  call <sid>hi('DiffText', s:chicagoGray1, s:chicagoBlue, 'none')
  call <sid>hi('ErrorMsg', s:chicagoBlack1, s:chicagoRed, 'none')
  call <sid>hi('Float', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('Function', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('Identifier', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('Keyword', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('Label', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('NonText', s:chicagoGray1, s:none, 'none')
  call <sid>hi('Number', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('Operator', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('PreProc', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('Special', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('SpecialKey', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('SpellBad', s:chicagoRed, s:none, 'italic,undercurl')
  call <sid>hi('SpellCap', s:chicagoBlack1, s:none, 'italic,undercurl')
  call <sid>hi('SpellLocal', s:chicagoBlack1, s:none, 'undercurl')
  call <sid>hi('Statement', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('StorageClass', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('String', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('Tag', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('Title', s:none, s:none, 'bold')
  call <sid>hi('Todo', s:chicagoGray3, s:none, 'inverse,bold')
  call <sid>hi('Type', s:none, s:none, 'none')
  call <sid>hi('Underlined', s:none, s:none, 'underline')
  call <sid>hi('WarningMsg', s:chicagoGold2, s:chicagoBlack3, 'none')

  " Diff Mode
  if &diff
    call <sid>hi('DiffAdd', s:chicagoWhite2, s:chicagoGreen1, 'none')
    call <sid>hi('DiffChange', s:chicagoWhite2, s:chicagoBrown, 'none')
    call <sid>hi('DiffDelete', s:chicagoRed, s:chicagoBrown, 'none')
    call <sid>hi('DiffText', s:chicagoGray1, s:chicagoBlue, 'none')
  else
    call <sid>hi('DiffAdd', s:chicagoBlack1, s:chicagoGreen1, 'none')
    call <sid>hi('DiffChange', s:chicagoGold2, s:chicagoGray1, 'none')
    call <sid>hi('DiffDelete', s:chicagoBlack1, s:chicagoRed, 'none')
    call <sid>hi('DiffText', s:chicagoWhite2, s:chicagoBlue, 'none')
  endif

  " ------------
  " Plugins
  " ------------

  " todo.txt
  call <sid>hi('TodoContext', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('TodoDate', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('TodoDone', s:chicagoGray3, s:none, 'none')
  call <sid>hi('TodoPriorityA', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('TodoPriorityB', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('TodoPriorityC', s:chicagoBlack1, s:none, 'none')
  call <sid>hi('TodoProject', s:chicagoBlack1, s:none, 'none')

  " Buftabline
  call <sid>hi('BufTabLineActive', s:chicagoBlack1, s:chicagoGray3, 'none')
  call <sid>hi('BufTabLineCurrent', s:chicagoBlack1, s:chicagoGray4, 'none')
  call <sid>hi('BufTabLineFill', s:chicagoBlack1, s:chicagoWhite2, 'none')
  call <sid>hi('BufTabLineHidden', s:chicagoGray3, s:chicagoBlack3, 'none')
else
  " Editor
  call <sid>hi('ColorColumn', s:none, s:chicagoGray2, 'none')
  call <sid>hi('Cursor', s:chicagoBlack2, s:chicagoWhite1, 'none')
  call <sid>hi('CursorColumn', s:none, s:chicagoBlack3, 'none')
  call <sid>hi('CursorLine', s:none, s:chicagoBlack4, 'none')
  call <sid>hi('CursorLineNr', s:chicagoWhite1, s:chicagoGray1, 'none')
  call <sid>hi('Directory', s:chicagoWhite1, s:chicagoBlack2, 'none')
  call <sid>hi('FoldColumn', s:chicagoGray6, s:chicagoBlack2, 'none')
  call <sid>hi('Folded', s:chicagoGray4, s:none, 'none')
  call <sid>hi('IncSearch', s:searchBg, s:searchFg, 'bold')
  call <sid>hi('CurSearch', s:searchBg, s:searchFg, 'bold')
  call <sid>hi('LineNr', s:chicagoGray4, s:gutterNr, 'none')
  call <sid>hi('MatchParen', s:chicagoWhite1, s:chicagoGray3, 'none')
  call <sid>hi('Normal', s:chicagoWhite1, s:chicagoBlack2, 'none')
  call <sid>hi('Search', s:searchFg, s:searchBg, 'none')
  call <sid>hi('SignColumn', s:none, s:gutterSign, 'none')
  call <sid>hi('StatusLine', s:chicagoBlack2, s:chicagoWhite1, 'bold')
  call <sid>hi('StatusLineNC', s:chicagoGray1, s:chicagoGray5, 'bold')
  call <sid>hi('VertSplit', s:chicagoBlack2, s:chicagoGray3, 'none')
  call <sid>hi('Visual', s:none, s:chicagoGray2, 'none')

  " Popups and floating windows (Hollow)
  " Floats are pure black; the completion menu is the only lighter popup
  call <sid>hi('NormalFloat', s:chicagoWhite1, s:chicagoBlack2, 'none')
  call <sid>hi('FloatBorder', s:border, s:chicagoBlack2, 'none')
  call <sid>hi('FloatTitle', s:chicagoWhite1, s:chicagoBlack2, 'none')
  call <sid>hi('FloatFooter', s:dim, s:chicagoBlack2, 'none')

  call <sid>hi('Pmenu', s:chicagoWhite1, s:completionBg, 'none')
  call <sid>hi('PmenuSel', s:chicagoWhite1, s:chicagoBlack3, 'none')
  call <sid>hi('PmenuExtra', s:dim, s:completionBg, 'none')
  call <sid>hi('PmenuExtraSel', s:chicagoWhite1, s:surfaceHi, 'none')
  call <sid>hi('PmenuKind', s:dim, s:completionBg, 'none')
  call <sid>hi('PmenuKindSel', s:chicagoWhite1, s:surfaceHi, 'none')
  call <sid>hi('PmenuMatch', s:chicagoWhite2, s:completionBg, 'bold')
  call <sid>hi('PmenuMatchSel', s:chicagoWhite2, s:surfaceHi, 'bold')
  call <sid>hi('PmenuSbar', s:none, s:completionBg, 'none')
  call <sid>hi('PmenuThumb', s:none, s:border, 'none')
  call <sid>hi('WildMenu', s:chicagoWhite1, s:surfaceHi, 'none')

  " General
  call <sid>hi('Boolean', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('Character', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('Comment', s:chicagoGray3, s:none, 'none')
  call <sid>hi('Conditional', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('Constant', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('Define', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('ErrorMsg', s:error, s:chicagoBlack2, 'bold')
  call <sid>hi('Float', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('Function', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('Identifier', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('Keyword', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('Label', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('NonText', s:chicagoGray3, s:none, 'none')
  call <sid>hi('Number', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('Operator', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('PreProc', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('Special', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('SpecialKey', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('SpellBad', s:error, s:none, 'undercurl', s:error)
  call <sid>hi('SpellCap', s:warn, s:none, 'undercurl', s:warn)
  call <sid>hi('SpellLocal', s:dim, s:none, 'undercurl', s:dim)
  call <sid>hi('SpellRare', s:dim, s:none, 'undercurl', s:dim)
  call <sid>hi('Statement', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('StorageClass', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('String', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('Tag', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('Title', s:none, s:none, 'bold')
  call <sid>hi('Todo', s:chicagoGray3, s:none, 'inverse,bold')
  call <sid>hi('Type', s:none, s:none, 'none')
  call <sid>hi('Underlined', s:none, s:none, 'underline')
  call <sid>hi('WarningMsg', s:warn, s:chicagoBlack2, 'none')

  " Diff (Hollow)
  " Lines
  call <sid>hi('DiffAdd', s:chicagoWhite1, s:diffAddBg, 'none')
  call <sid>hi('DiffChange', s:chicagoWhite1, s:diffChangeBg, 'none')
  call <sid>hi('DiffDelete', s:diffRemoved, s:diffDeleteBg, 'none')

  " Text inside a line
  call <sid>hi('DiffText', s:chicagoWhite2, s:diffTextBg, 'bold')
  call <sid>hi('DiffAddText', s:chicagoWhite2, s:diffAddTextBg, 'bold')
  call <sid>hi('DiffDeleteText', s:chicagoWhite2, s:diffDeleteTextBg, 'bold')

  " Signs and diff syntax
  call <sid>hi('Added', s:diffAdded, s:none, 'none')
  call <sid>hi('Changed', s:diffChanged, s:none, 'none')
  call <sid>hi('Removed', s:diffRemoved, s:none, 'none')
  call <sid>hi('diffFile', s:chicagoWhite1, s:none, 'bold')
  call <sid>hi('diffLine', s:diffChanged, s:none, 'none')

  hi! link diffAdded Added
  hi! link diffRemoved Removed
  hi! link diffChanged Changed
  hi! link diffNewFile Added
  hi! link diffOldFile Removed
  hi! link diffIndexLine Comment
  hi! link diffSubname Comment
  hi! link diffComment Comment
  hi! link @diff.plus Added
  hi! link @diff.minus Removed
  hi! link @diff.delta Changed

  " gitsigns.nvim
  hi! link GitSignsAdd Added
  hi! link GitSignsChange Changed
  hi! link GitSignsDelete Removed
  hi! link GitSignsAddNr Added
  hi! link GitSignsChangeNr Changed
  hi! link GitSignsDeleteNr Removed
  hi! link GitSignsAddLn DiffAdd
  hi! link GitSignsChangeLn DiffChange
  hi! link GitSignsAddInline DiffAddText
  hi! link GitSignsChangeInline DiffText
  hi! link GitSignsDeleteInline DiffDeleteText
  hi! link GitSignsAddPreview DiffAdd
  hi! link GitSignsDeletePreview DiffDelete
  hi! link GitSignsDeleteVirtLn DiffDelete
  hi! link GitSignsDeleteVirtLnInLine DiffDeleteText

  " Diagnostics and LSP (Hollow)
  call <sid>hi('DiagnosticError', s:error, s:none, 'none')
  call <sid>hi('DiagnosticWarn', s:warn, s:none, 'none')
  call <sid>hi('DiagnosticInfo', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('DiagnosticHint', s:chicagoGray3, s:none, 'none')
  call <sid>hi('DiagnosticOk', s:ok, s:none, 'none')
  call <sid>hi('DiagnosticUnnecessary', s:chicagoGray3, s:none, 'none')

  " Virtual text: same color as the sign, with a faint background
  call <sid>hi('DiagnosticVirtualTextError', s:error, s:errorBg, 'none')
  call <sid>hi('DiagnosticVirtualTextWarn', s:warn, s:warnBg, 'none')
  call <sid>hi('DiagnosticVirtualTextInfo', s:chicagoWhite1, s:infoBg, 'none')
  call <sid>hi('DiagnosticVirtualTextHint', s:chicagoGray3, s:hintBg, 'none')
  call <sid>hi('DiagnosticVirtualTextOk', s:ok, s:okBg, 'none')

  " Full-line background (used by `signs.linehl` in vim.diagnostic.config)
  call <sid>hi('DiagnosticLineError', s:none, s:errorBg, 'none')
  call <sid>hi('DiagnosticLineWarn', s:none, s:warnBg, 'none')
  call <sid>hi('DiagnosticLineInfo', s:none, s:infoBg, 'none')
  call <sid>hi('DiagnosticLineHint', s:none, s:hintBg, 'none')

  " Straight underline instead of curls
  call <sid>hi('DiagnosticUnderlineError', s:none, s:none, 'underline', s:error)
  call <sid>hi('DiagnosticUnderlineWarn', s:none, s:none, 'underline', s:warn)
  call <sid>hi('DiagnosticUnderlineInfo', s:none, s:none, 'underline', s:chicagoWhite1)
  call <sid>hi('DiagnosticUnderlineHint', s:none, s:none, 'underline', s:chicagoGray3)
  call <sid>hi('DiagnosticUnderlineOk', s:none, s:none, 'underline', s:ok)

  call <sid>hi('LspInlayHint', s:chicagoGray3, s:gutterSign, 'italic')
  call <sid>hi('LspReferenceText', s:none, s:chicagoBlack3, 'none')
  call <sid>hi('LspReferenceRead', s:none, s:chicagoBlack3, 'none')
  call <sid>hi('LspReferenceWrite', s:none, s:chicagoBlack3, 'underline')

  " Markdown (Hollow)
  " Frontmatter fences (---)
  call <sid>hi('@keyword.directive.markdown', s:mdAccent, s:none, 'none')

  " Structural punctuation
  call <sid>hi('@punctuation.special.markdown', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('@punctuation.delimiter.markdown', s:chicagoWhite1, s:none, 'none')

  " Lists and task items
  call <sid>hi('@markup.list.markdown', s:mdAccent, s:none, 'bold')
  call <sid>hi('@markup.list.checked.markdown', s:mdMarker, s:none, 'none')
  call <sid>hi('@markup.list.unchecked.markdown', s:mdAccent, s:none, 'bold')

  " Blockquote
  call <sid>hi('@markup.quote.markdown', s:chicagoGray4, s:none, 'italic')

  " Code blocks
  call <sid>hi('@markup.raw.block.markdown', s:mdBlock, s:none, 'none')
  call <sid>hi('@markup.raw.delimiter.markdown', s:mdAccent, s:none, 'none')
  call <sid>hi('@label.markdown', s:mdAccent, s:none, 'italic')

  " Inline emphasis
  call <sid>hi('@markup.strong.markdown_inline', s:chicagoWhite2, s:none, 'bold')
  call <sid>hi('@markup.italic.markdown_inline', s:chicagoGray4, s:none, 'italic')
  call <sid>hi('@markup.strikethrough.markdown_inline', s:mdStrike, s:none, 'strikethrough')

  " Inline code and math
  call <sid>hi('@markup.raw.markdown_inline', s:mdCode, s:mdCodeBg, 'none')
  call <sid>hi('@markup.math.markdown_inline', s:mdCode, s:none, 'none')
  call <sid>hi('@markup.math.markdown', s:mdCode, s:none, 'none')
  call <sid>hi('@markup.math.latex', s:mdCode, s:none, 'none')
  call <sid>hi('@punctuation.special.markdown_inline', s:mdCode, s:none, 'none')

  " Inline links
  call <sid>hi('@markup.link.markdown_inline', s:mdMarker, s:none, 'none')
  call <sid>hi('@markup.link.label.markdown_inline', s:mdCode, s:none, 'underline')
  call <sid>hi('@markup.link.url.markdown_inline', s:mdUrl, s:none, 'underline')

  " Inline escapes and conceal
  call <sid>hi('@string.escape.markdown_inline', s:mdAccent, s:none, 'none')
  call <sid>hi('@conceal.markdown_inline', s:mdMarker, s:none, 'none')

  " Headings: level 1 is white, the rest use the normal text color
  call <sid>hi('@markup.heading.markdown', s:chicagoWhite2, s:none, 'bold')
  call <sid>hi('@markup.heading.marker.markdown', s:chicagoWhite2, s:none, 'none')
  call <sid>hi('@markup.heading.1.markdown', s:chicagoWhite2, s:none, 'bold')
  call <sid>hi('@markup.heading.1.marker.markdown', s:chicagoWhite2, s:none, 'none')
  for s:level in range(2, 6)
    call <sid>hi('@markup.heading.' . s:level . '.markdown', s:chicagoWhite1, s:none, 'bold')
    call <sid>hi('@markup.heading.' . s:level . '.marker.markdown', s:chicagoWhite1, s:none, 'none')
  endfor

  " Markdown legacy :syntax groups (regex highlighter)
  hi! link markdownH1 @markup.heading.1.markdown
  hi! link markdownH2 @markup.heading.2.markdown
  hi! link markdownH3 @markup.heading.3.markdown
  hi! link markdownH4 @markup.heading.4.markdown
  hi! link markdownH5 @markup.heading.5.markdown
  hi! link markdownH6 @markup.heading.6.markdown
  hi! link markdownHeadingDelimiter @markup.heading.marker.markdown
  hi! link markdownHeadingRule @markup.heading.marker.markdown
  hi! link markdownCode @markup.raw.markdown_inline
  hi! link markdownCodeBlock @markup.raw.block.markdown
  hi! link markdownCodeDelimiter @markup.raw.delimiter.markdown
  hi! link markdownBlockquote @markup.quote.markdown
  hi! link markdownListMarker @markup.list.markdown
  hi! link markdownOrderedListMarker @markup.list.markdown
  hi! link markdownRule @punctuation.special.markdown
  hi! link markdownBold @markup.strong.markdown_inline
  hi! link markdownItalic @markup.italic.markdown_inline
  hi! link markdownBoldItalic @markup.strong.markdown_inline
  hi! link markdownStrike @markup.strikethrough.markdown_inline
  hi! link markdownLinkText @markup.link.label.markdown_inline
  hi! link markdownUrl @markup.link.url.markdown_inline
  hi! link markdownLinkDelimiter @markup.link.markdown_inline
  hi! link markdownIdDelimiter @markup.link.markdown_inline
  hi! link markdownAutomaticLink @markup.link.url.markdown_inline
  hi! link markdownEscape @string.escape.markdown_inline

  " Frontmatter (YAML injected into markdown). It goes through its own
  " namespace, applied only to markdown windows, so plain .yaml files keep
  " the normal text color. Neovim only.
  if has('nvim')
    let s:mdNs = nvim_create_namespace('mies_markdown')
    for s:pair in [
          \ ['@property.yaml', s:mdAccent],
          \ ['@string.yaml', s:mdString],
          \ ['@number.yaml', s:mdAccent],
          \ ['@number.float.yaml', s:mdAccent],
          \ ['@boolean.yaml', s:mdAccent],
          \ ['@constant.builtin.yaml', s:mdAccent],
          \ ['@label.yaml', s:mdAccent],
          \ ['@type.yaml', s:mdAccent],
          \ ['@punctuation.delimiter.yaml', s:mdMarker],
          \ ['@punctuation.bracket.yaml', s:mdMarker],
          \ ]
      call nvim_set_hl(s:mdNs, s:pair[0], {'fg': s:pair[1].gui})
    endfor

    fun! <sid>markdown_ns()
      if &filetype ==# 'markdown'
        call nvim_win_set_hl_ns(0, s:mdNs)
        let w:mies_markdown = 1
      elseif exists('w:mies_markdown')
        call nvim_win_set_hl_ns(0, 0)
        unlet w:mies_markdown
      endif
    endfun

    augroup mies_markdown
      autocmd!
      autocmd FileType,BufWinEnter,WinEnter * call <sid>markdown_ns()
    augroup END
  endif

  " ------------
  " Plugins
  " ------------

  " todo.txt
  call <sid>hi('TodoContext', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('TodoDate', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('TodoDone', s:chicagoGray3, s:none, 'none')
  call <sid>hi('TodoPriorityA', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('TodoPriorityB', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('TodoPriorityC', s:chicagoWhite1, s:none, 'none')
  call <sid>hi('TodoProject', s:chicagoWhite1, s:none, 'none')

  " Buftabline
  call <sid>hi('BufTabLineActive', s:chicagoWhite1, s:chicagoGray2, 'none')
  call <sid>hi('BufTabLineCurrent', s:chicagoBlack2, s:chicagoGray5, 'none')
  call <sid>hi('BufTabLineFill', s:chicagoBlack2, s:chicagoBlack2, 'none')
  call <sid>hi('BufTabLineHidden', s:chicagoGray3, s:chicagoBlack4, 'none')
endif
