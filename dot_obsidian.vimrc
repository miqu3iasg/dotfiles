" For this to work, you need to install the "vimrc support" plugin in Obsidian and
" place this file in the root of your vault.

" Leader Key
unmap <Space>

" Clipboard
set clipboard=unnamed

" Custom Commands
exmap W obcommand editor:save-file
exmap Q obcommand workspace:close
exmap Journal obcommand daily-notes

exmap copyBlockLink obcommand obsidian-copy-block-link:copy-embed-to-block
exmap reloadApp obcommand app:reload

exmap attachFile obcommand editor:attach-file
exmap insertCodeblock obcommand editor:insert-codeblock
exmap toggleCode obcommand editor:toggle-code
exmap insertLink obcommand editor:insert-link
exmap insertMath obcommand editor:insert-mathblock
exmap insertWikilink obcommand editor:insert-wikilink
exmap insertCallout obcommand editor:insert-callout
exmap insertTable obcommand editor:insert-table
exmap insertHRule obcommand editor:insert-horizontal-rule
exmap insertTag obcommand editor:insert-tag
exmap clearFormatting obcommand editor:clear-formatting
exmap searchReplace obcommand editor:open-search-replace

exmap toggleBullet obcommand editor:toggle-bullet-list
exmap toggleNumbered obcommand editor:toggle-numbered-list
exmap toggleChecklist obcommand editor:toggle-checklist-status
exmap cycleList obcommand editor:cycle-list-checklist
exmap toggleBlockquote obcommand editor:toggle-blockquote
exmap toggleBold obcommand editor:toggle-bold
exmap toggleItalic obcommand editor:toggle-italics
exmap toggleStrike obcommand editor:toggle-strikethrough
exmap toggleHighlight obcommand editor:toggle-highlight
exmap toggleComment obcommand editor:toggle-comments

exmap nbOpen obcommand notebook-navigator:open
exmap nbReveal obcommand notebook-navigator:reveal-file
exmap nbFolder obcommand notebook-navigator:navigate-to-folder
exmap nbDual obcommand notebook-navigator:toggle-dual-pane
exmap nbCalendar obcommand notebook-navigator:toggle-calendar
exmap nbWeekly obcommand notebook-navigator:open-weekly-note
exmap nbMonthly obcommand notebook-navigator:open-monthly-note
exmap nbQuarterly obcommand notebook-navigator:open-quarterly-note
exmap nbYearly obcommand notebook-navigator:open-yearly-note

exmap omniSearch obcommand omnisearch:show-modal
exmap omniSearchFile obcommand omnisearch:show-modal-infile
exmap searchInFile obcommand editor:open-search
exmap quickSwitcher obcommand switcher:open
exmap globalSearch  obcommand global-search:open
exmap cmdPalette obcommand command-palette:open
exmap openAnotherVault obcommand app:open-another-vault
exmap openVault obcommand app:open-vault
exmap toggleLeftSidebar obcommand app:toggle-left-sidebar
exmap toggleRightSidebar obcommand app:toggle-right-sidebar
exmap openDumping e Dumping.md
exmap openWebviewer obcommand webviewer:open
exmap webSearch obcommand webviewer:search

exmap moveFile obcommand file-explorer:move-file
exmap deleteFile obcommand app:delete-file
exmap exportPdf obcommand workspace:export-pdf
exmap copyFullPath obcommand workspace:copy-full-path
exmap copyPath obcommand workspace:copy-path
exmap renameHeading obcommand editor:rename-heading
exmap editFileTitle obcommand workspace:edit-file-title
exmap openDefaultApp obcommand open-with-default-app:show
exmap quickAdd obcommand quickadd:runQuickAdd
exmap quickAddF obcommand quickadd:choice:77543226-6453-48d1-b85b-acaed10bcdb1
exmap quickAddN obcommand quickadd:choice:30014582-0080-411d-a672-6bc3f893adc9
exmap insertTemplate obcommand insert-template

exmap addProperty obcommand markdown:add-metadata-property
exmap clearProperties obcommand markdown:clear-metadata-properties
exmap foldProperties obcommand editor:toggle-fold-properties

exmap splitH obcommand workspace:split-horizontal
exmap splitV obcommand workspace:split-vertical
exmap closeOthers obcommand workspace:close-others
exmap newWindow obcommand workspace:open-in-new-window
exmap moveNewWindow obcommand workspace:move-to-new-window

exmap gotoLastTab obcommand workspace:goto-last-tab
exmap newTab obcommand workspace:new-tab
exmap undoClosePane obcommand workspace:undo-close-pane
exmap togglePin obcommand workspace:toggle-pin
exmap stackedTabs obcommand workspace:toggle-stacked-tabs
exmap nextTab obcommand workspace:next-tab
exmap prevTab obcommand workspace:previous-tab

exmap goBack obcommand app:go-back
exmap goForward obcommand app:go-forward
exmap tab1 obcommand workspace:goto-tab-1
exmap tab2 obcommand workspace:goto-tab-2
exmap tab3 obcommand workspace:goto-tab-3
exmap tab4 obcommand workspace:goto-tab-4
exmap tab5 obcommand workspace:goto-tab-5
exmap tab6 obcommand workspace:goto-tab-6
exmap tab7 obcommand workspace:goto-tab-7
exmap tab8 obcommand workspace:goto-tab-8

exmap lineNumbers obcommand editor:toggle-line-numbers
exmap hiderTabs obcommand obsidian-hider:toggle-tab-containers
exmap hiderStatus obcommand obsidian-hider:toggle-hider-status
exmap themeToggle obcommand theme:toggle-light-dark
exmap previewToggle obcommand markdown:toggle-preview
exmap readableWidth obcommand editor:toggle-readable-line-length
exmap sourceToggle obcommand editor:toggle-source
exmap spellcheck obcommand editor:toggle-spellcheck
exmap graphOpen obcommand graph:open
exmap graphLocal obcommand graph:open-local

exmap focusLeft obcommand editor:focus-left
exmap focusRight obcommand editor:focus-right
exmap focusTop obcommand editor:focus-top
exmap focusBottom obcommand editor:focus-bottom

exmap followLink          obcommand editor:follow-link
exmap followLinkSplit     obcommand editor:open-link-in-new-split
exmap followLinkTab       obcommand editor:open-link-in-new-leaf
exmap followLinkWindow    obcommand editor:open-link-in-new-window

exmap backlinksFile       obcommand backlink:open-backlinks
exmap backlinksPane       obcommand backlink:open
exmap backlinksToggleDoc  obcommand backlink:toggle-backlinks-in-document
exmap outgoingLinks       obcommand outgoing-links:open-for-current
exmap outgoingLinksPane   obcommand outgoing-links:open
exmap outline             obcommand outline:open-for-current
exmap outlinePane         obcommand outline:open
exmap jumpBack            obcommand app:go-back
exmap jumpForward         obcommand app:go-forward

" Better defaults
nnoremap Y y$
nnoremap gV `[v`]
nnoremap x "_x
nnoremap X "_X
nnoremap c "_c
vnoremap c "_c
nnoremap U <C-r>
vnoremap p "_dP

" Command mode
nnoremap ; :
vnoremap ; :
nnoremap \ ;
vnoremap \ ;

" Centered Scroll
nnoremap j gj
nnoremap k gk
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz
nnoremap } }zz
nnoremap { {zz
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz
nnoremap gg ggzz
nnoremap G Gzz

" Editing and Formatting

" Inserts
nnoremap <Space>ia :attachFile<CR>
nnoremap <Space>ik :insertCodeblock<CR>
nnoremap <Space>ic :toggleCode<CR>
nnoremap <Space>il :insertLink<CR>
nnoremap <Space>im :insertMath<CR>
nnoremap <Space>iw :insertWikilink<CR>
vnoremap <Space>is c[[<C-r>"]]<Esc>F[li|<Esc>mz`zi
vnoremap <Space>iw <Esc>`>a]]<Esc>`<i[[<Esc>
vnoremap <Space>il "ac[<C-r>"]()<Esc><Left>a
nnoremap <Space>io :insertCallout<CR>
nnoremap <Space>it :insertTable<CR>
nnoremap <Space>ih :insertHRule<CR>
nnoremap <Space>ig :insertTag<CR>

" Lists
nnoremap <Space>lb :toggleBullet<CR>
nnoremap <Space>ln :toggleNumbered<CR>
nnoremap <Space>lc :toggleChecklist<CR>
nnoremap <Space>ll :cycleList<CR>
nnoremap <Space>lk :swapLineUp<CR>
nnoremap <Space>lj :swapLineDown<CR>
nnoremap <Space>lq :toggleBlockquote<CR>
nnoremap <Space>lt :toggleChecklist<CR>

vnoremap <Space>lb :toggleBullet<CR>
vnoremap <Space>ln :toggleNumbered<CR>
vnoremap <Space>lc :toggleChecklist<CR>
vnoremap <Space>lq :toggleBlockquote<CR>
vnoremap <Space>lt :toggleChecklist<CR>

" Comments
nnoremap gcc :toggleComment<CR>
vnoremap gc :toggleComment<CR>

" Cleaning
vnoremap <Space>cf :clearFormatting<CR>

" Substituition
nnoremap cu :searchReplace<CR>
nnoremap <Space>cn *``cgn
nnoremap <Space>cs :searchReplace<CR>
vnoremap <Space>cs :searchReplace<CR>

" Selection
nnoremap <Space>va ggVG
nnoremap <Space>ya ggVGy

" Identation
vnoremap < <gv
vnoremap > >gv

" Duplication
nnoremap zj yyp
nnoremap zk yyP
vnoremap zj y`>p

" Line edition
nnoremap J mzJ`z

" Notebook Navigator
nnoremap <Space>bo :nbOpen<CR>
nnoremap <Space>br :nbReveal<CR>
nnoremap <Space>bf :nbFolder<CR>
nnoremap <Space>bd :nbDual<CR>
nnoremap <Space>bc :nbCalendar<CR>
nnoremap <Space>bw :nbWeekly<CR>
nnoremap <Space>bm :nbMonthly<CR>
nnoremap <Space>bq :nbQuarterly<CR>
nnoremap <Space>by :nbYearly<CR>

" Sidebars
nnoremap <Space>ee :toggleLeftSidebar<CR>
nnoremap <Space>er :toggleRightSidebar<CR>

" Search
nnoremap <Space>ff :omniSearch<CR>
nnoremap <Space>fo :omniSearchFile<CR>
nnoremap <Space>fi :searchInFile<CR>
nnoremap <Space>fs :quickSwitcher<CR>
nnoremap <Space>fa :cmdPalette<CR>
nnoremap <Space>fg :globalSearch<CR>

nnoremap zh :nohlsearch<CR>

" Misc
nnoremap <Space>ep :exportPdf<CR>
nnoremap <Space>yp :copyFullPath<CR>
nnoremap <Space>yr :copyPath<CR>
nnoremap <Space>yl :copyBlockLink<CR>
nnoremap <Space>rh :renameHeading<CR>
nnoremap <Space>re :reloadApp<CR>
nnoremap <Space>w :W<CR>
nnoremap <Space>q :Q<CR>

" Files
nnoremap <Space>nd :Journal<CR>
nnoremap <Space>nr :editFileTitle<CR>
nnoremap <Space>ne :openDefaultApp<CR>
nnoremap <Space>nq :quickAdd<CR>
nnoremap <Space>nf :quickAddF<CR>
nnoremap <Space>nn :quickAddN<CR>
nnoremap <Space>nt :insertTemplate<CR>
nnoremap <Space>nv :moveFile<CR>
nnoremap <Space>nx :deleteFile<CR>

" Properties/Frontmatter
nnoremap <Space>pa :addProperty<CR>
nnoremap <Space>pc :clearProperties<CR>
nnoremap <Space>pp :foldProperties<CR>

" Splits
nnoremap <Space>sh :splitH<CR>
nnoremap <Space>sv :splitV<CR>
nnoremap <Space>sc :Q<CR>
nnoremap <Space>so :closeOthers<CR>
nnoremap <Space>sn :newWindow<CR>
nnoremap <Space>sm :moveNewWindow<CR>
nnoremap <Space>sw viw:omniSearch<CR>

" Tabs
nnoremap <Space>tc :Q<CR>
nnoremap <Space>tl :gotoLastTab<CR>
nnoremap <Space>tn :newTab<CR>
nnoremap <Space>tu :undoClosePane<CR>
nnoremap <Space>tp :togglePin<CR>
nnoremap <Space>ts :stackedTabs<CR>

nnoremap <Space>[ :goBack<CR>
nnoremap <Space>] :goForward<CR>
nnoremap <Space>1 :tab1<CR>
nnoremap <Space>2 :tab2<CR>
nnoremap <Space>3 :tab3<CR>
nnoremap <Space>4 :tab4<CR>
nnoremap <Space>5 :tab5<CR>
nnoremap <Space>6 :tab6<CR>
nnoremap <Space>7 :tab7<CR>
nnoremap <Space>8 :tab8<CR>

" Workspace Navigation
nnoremap <C-w>h :focusLeft<CR>
nnoremap <C-w>l :focusRight<CR>
nnoremap <C-w>k :focusTop<CR>
nnoremap <C-w>j :focusBottom<CR>
nnoremap ]b :nextTab<CR>
nnoremap [b :prevTab<CR>
nnoremap L :nextTab<CR>
nnoremap H :prevTab<CR>
nnoremap <C-o> :jumpBack<CR>
nnoremap <C-i> :jumpForward<CR>

" Links
nnoremap gD :followLink<CR>
nnoremap gd :followLinkSplit<CR>
nnoremap gx :followLink<CR>
nnoremap gy :followLinkTab<CR>
nnoremap gW :followLinkWindow<CR>

" Appearance and Views
nnoremap <Space>vn :lineNumbers<CR>
nnoremap <Space>vz :hiderTabs<CR>
nnoremap <Space>vb :hiderStatus<CR>
nnoremap <Space>vt :themeToggle<CR>
nnoremap <Space>vp :previewToggle<CR>
nnoremap <Space>vr :readableWidth<CR>
nnoremap <Space>vs :sourceToggle<CR>
nnoremap <Space>vc :spellcheck<CR>
nnoremap <Space>vg :graphOpen<CR>
nnoremap <Space>vl :graphLocal<CR>

" Utils and Quick Access
nnoremap <Space>ow :openWebviewer<CR>
nnoremap <Space>os :webSearch<CR>
nnoremap <Space>ov :openAnotherVault<CR>
nnoremap <Space>om :openVault<CR>
