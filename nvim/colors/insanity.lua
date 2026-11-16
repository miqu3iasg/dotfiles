-- colors/insanity.lua

-- For those who are insane.
--
-- Copyright (c) Robertus Chris <diawan@pm.me>
-- Copyright (c) Miquéias Medeiros <contatomiqueiasalvesdev@gmail.com>
--
-- See: lua/lib/colors.lua
-- See: https://github.com/bruhtus/dotfiles/blob/master/.vim/colors/insanity.vim
--
-- SPDX-License-Identifier: MIT

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
	vim.cmd("syntax reset")
end
vim.o.termguicolors = true
vim.g.colors_name = "insanity"
vim.o.background = "dark"

local lib = require("lib.colors")

-- Palette (grays, green strings and cyan keywords)

local colors = {
	-- single background; the only other "surface" tone is `cursorline`
	bg = "#000000",
	cursorline = "#111111", -- state tone: cursorline, statusline, selected menu item, matchparen, references
	popup_bg = "#0d0d0d", -- completion menu and docs popup
	popup_sel = "#1c1c1c", -- selected item inside the popup

	fg_0 = "#3b3b3b",
	fg_1 = "#808080",
	fg_2 = "#d8d8d8",
	fg_3 = "#d8d8d8",

	linenr = "#3a3a3a",
	linenr_cur = "#585858",
	linenr_above = "#2e2e2e",

	border = "#2a2a2a",
	split = "#5a5a5a",
	statusline_nc = "#878769",

	comment = "#636262",
	comment_doc = "#636262",

	red = "#d75f5f",
	green = "#7a9c7a",
	yellow = "#7d7d70",
	blue = "#5f87ff",
	magenta = "#d787af",
	cyan = "#80bdbd",

	br_red = "#ff5f5f",
	br_green = "#93b093",
	br_yellow = "#ffd751",
	br_blue = "#5fafff",
	br_magenta = "#d75fd7",
	br_cyan = "#c9d6d6",

	diff_add_bg = "#0c130c",
	diff_change_bg = "#13120c",
	diff_delete_bg = "#130c0c",
	diff_text_bg = "#2a1414",
}

-- Tints derived from the palette
colors.visual_bg = lib.blend(colors.fg_1, colors.bg, 0.35) -- neutral gray, no hue

-- Colors used for Markdown
local MD_SAT = 0.8
local md = {
	title = "#ffffff", -- headings and bold: brighter than body text
	blue = lib.desaturate("#5f87ff", MD_SAT),
	violet = lib.desaturate("#af87d7", MD_SAT),
	br_violet = lib.desaturate("#af87ff", MD_SAT),
	prop = "#738296", -- frontmatter keys (same as hollow)
}

-- Terminal colors

lib.terminal_colors({
	colors.bg,
	colors.red,
	colors.green,
	colors.yellow,
	colors.blue,
	colors.magenta,
	colors.cyan,
	colors.fg_2,
	colors.fg_1,
	colors.br_red,
	colors.br_green,
	colors.br_yellow,
	colors.br_blue,
	colors.br_magenta,
	colors.br_cyan,
	colors.fg_3,
})

-- Highlight groups

local groups = {
	-- Editor UI
	ColorColumn = { bg = colors.cursorline },
	Conceal = { fg = colors.fg_0, nocombine = true },
	Cursor = { bg = colors.fg_2, fg = colors.bg },
	CursorLineNr = { fg = colors.linenr_cur, bold = true },
	Directory = { fg = colors.blue },

	DiffAdd = { bg = colors.diff_add_bg, fg = colors.green },
	DiffChange = { bg = colors.diff_change_bg, fg = colors.br_yellow },
	DiffDelete = { bg = colors.diff_delete_bg, fg = colors.red },
	DiffText = { bg = colors.diff_text_bg, fg = colors.fg_3 },

	ErrorMsg = { fg = colors.br_red, nocombine = true },
	LineNr = { fg = colors.linenr },
	LineNrAbove = { fg = colors.linenr_above },
	LineNrBelow = { link = "LineNrAbove" },
	MatchParen = { fg = colors.br_cyan, bg = colors.cursorline, bold = true },
	NonText = { fg = colors.fg_1, nocombine = true },

	Normal = { bg = colors.bg, fg = colors.fg_2, nocombine = true },
	NormalNC = { link = "Normal" },
	NormalFloat = { bg = colors.bg },
	FloatTitle = { link = "Title" },
	FloatFooter = { link = "Comment" },
	FloatBorder = { fg = colors.border, bg = colors.bg },

	SignColumn = {},

	Search = { bg = colors.br_magenta, fg = colors.fg_3 },
	IncSearch = { link = "Search" },
	CurSearch = { link = "Search" },
	Substitute = { link = "Search" },

	Title = { fg = colors.fg_2 },
	QuickFixLine = { fg = colors.green },
	WarningMsg = { fg = colors.fg_2, nocombine = true },
	WildMenu = { bg = colors.bg, fg = colors.fg_2 },
	Whitespace = { fg = colors.linenr_above },
	SpecialKey = { link = "NonText" },
	MsgArea = { link = "Normal" },
	MsgSeparator = { link = "StatusLine" },

	healthError = { link = "ErrorMsg" },
	healthWarning = { link = "WarningMsg" },
	healthSuccess = { fg = colors.green },

	lCursor = { link = "Cursor" },
	CursorIM = { link = "Cursor" },
	TermCursor = { link = "Cursor" },
	TermCursorNC = { fg = colors.bg, bg = colors.fg_1 },

	CursorColumn = { link = "ColorColumn" },
	CursorLine = { bg = colors.cursorline },
	CursorLineFold = { link = "ColorColumn" },
	CursorLineSign = { link = "CursorLineNr" },
	EndOfBuffer = { link = "NonText" },

	VertSplit = { fg = colors.split, bg = colors.bg },
	WinSeparator = { fg = colors.split, bg = colors.bg },
	WinBar = { link = "StatusLine" },
	WinBarNC = { link = "StatusLineNC" },

	Folded = { fg = colors.fg_1 },
	FoldColumn = { link = "Conceal" },

	MoreMsg = { link = "WarningMsg" },
	PopupNotification = { link = "WarningMsg" },
	Question = { link = "WarningMsg" },
	ModeMsg = { link = "Normal" },
	Terminal = { link = "Normal" },

	-- Completion menu
	Pmenu = { bg = colors.bg, fg = colors.fg_2, nocombine = true },
	PmenuSbar = { bg = colors.bg, nocombine = true },
	PmenuSel = { bg = colors.cursorline, fg = colors.fg_3 },
	PmenuThumb = { bg = colors.fg_0 },
	PmenuKind = { link = "Pmenu" },
	PmenuKindSel = { link = "PmenuSel" },
	PmenuExtra = { link = "Pmenu" },
	PmenuExtraSel = { link = "PmenuSel" },
	PmenuMatch = { fg = colors.fg_3, bold = true },
	PmenuMatchSel = { link = "PmenuMatch" },
	MessageWindow = { link = "PmenuSel" },

	SpellBad = { undercurl = true, sp = colors.red },
	SpellCap = { undercurl = true, sp = colors.blue },
	SpellLocal = { link = "Normal" },
	SpellRare = { link = "Normal" },

	-- Status line
	StatusLine = { bg = colors.cursorline, fg = colors.fg_2, nocombine = true },
	StatusLineNC = { bg = colors.popup_bg, fg = colors.statusline_nc, nocombine = true },
	StatuslineTerm = { link = "StatusLine" },
	StatuslineTermNC = { link = "StatusLineNC" },

	-- Tab line
	TabLine = { bg = colors.bg, fg = colors.yellow, nocombine = true },
	TabLineFill = { bg = colors.bg, nocombine = true },
	TabLineSel = { bg = colors.bg, fg = colors.fg_1, nocombine = true },
	ToolbarLine = { link = "TabLine" },
	ToolbarButton = { link = "TabLineSel" },

	-- Visual selection: neutral tint, no fg, so syntax colors survive
	Visual = { bg = colors.visual_bg },
	VisualNOS = { link = "Visual" },

	-- Legacy syntax groups (mirror the Treesitter captures above, so
	-- filetypes without a Treesitter parser look the same)
	Keyword = { link = "Statement" },
	Conditional = { link = "Statement" },
	Repeat = { link = "Statement" },
	Label = { link = "Statement" },
	Tag = { link = "Statement" },
	Operator = { fg = colors.fg_3 },
	Number = { link = "Constant" },
	Float = { link = "Constant" },
	Include = { link = "PreProc" },
	Define = { link = "PreProc" },
	Macro = { link = "PreProc" },
	PreCondit = { link = "PreProc" },
	StorageClass = { link = "Type" },
	Structure = { link = "Type" },
	Typedef = { link = "Type" },
	SpecialChar = { fg = colors.br_cyan },
	SpecialComment = { link = "Special" },
	Debug = { link = "WarningMsg" },

	-- Classic syntax groups
	-- (no bg on Comment/Special/Todo so the cursorline shows through)
	String = { fg = colors.green, nocombine = true },
	Todo = { fg = colors.br_cyan },
	Comment = { fg = colors.comment },
	Special = { fg = colors.fg_2 },
	Delimiter = { fg = colors.fg_3 },
	Link = { fg = colors.cyan },
	Ignore = { link = "Comment" },

	Function = { link = "Special" },
	FunctionBuiltin = { fg = colors.fg_2 },
	Identifier = { link = "Special" },
	IdentifierBuiltin = { link = "Special" },
	PreProc = { link = "Special" },
	Type = { link = "Special" },
	TypeBuiltin = { link = "Normal" },
	Exception = { link = "WarningMsg" },
	Error = { link = "ErrorMsg" },
	Character = { link = "Normal" },
	Text = { link = "Normal" },
	Constant = { link = "Normal" },
	Underlined = { link = "Normal" },
	Statement = { link = "Link" },

	-- Diagnostics
	DiagnosticError = { fg = colors.br_red },
	DiagnosticWarn = { fg = colors.yellow },
	DiagnosticInfo = { fg = colors.cyan },
	DiagnosticHint = { fg = colors.br_blue },
	DiagnosticOk = { fg = colors.green },

	DiagnosticUnderlineError = { undercurl = true, sp = colors.br_red },
	DiagnosticUnderlineWarn = { undercurl = true, sp = colors.br_yellow },
	DiagnosticUnderlineInfo = { undercurl = true, sp = colors.blue },
	DiagnosticUnderlineHint = { undercurl = true, sp = colors.cyan },
	DiagnosticUnderlineOk = { undercurl = true, sp = colors.green },

	-- Inline messages a bit calmer than the sign; no bg so cursorline shows
	DiagnosticVirtualTextError = { fg = colors.red },
	DiagnosticVirtualTextWarn = { fg = colors.yellow },
	DiagnosticVirtualTextInfo = { fg = colors.blue },
	DiagnosticVirtualTextHint = { fg = colors.cyan },
	DiagnosticVirtualTextOk = { fg = colors.green },

	DiagnosticFloatingError = { link = "DiagnosticError" },
	DiagnosticFloatingWarn = { link = "DiagnosticWarn" },
	DiagnosticFloatingInfo = { link = "DiagnosticInfo" },
	DiagnosticFloatingHint = { link = "DiagnosticHint" },
	DiagnosticFloatingOk = { link = "DiagnosticOk" },

	DiagnosticSignError = { link = "DiagnosticError" },
	DiagnosticSignWarn = { link = "DiagnosticWarn" },
	DiagnosticSignInfo = { link = "DiagnosticInfo" },
	DiagnosticSignHint = { link = "DiagnosticHint" },
	DiagnosticSignOk = { link = "DiagnosticOk" },

	DiagnosticDeprecated = { fg = colors.fg_1, strikethrough = true },
	DiagnosticUnnecessary = { fg = colors.fg_1 },

	-- LSP
	LspReferenceText = { bg = colors.cursorline },
	LspReferenceRead = { bg = colors.cursorline },
	LspReferenceWrite = { bg = colors.cursorline, underline = true },
	LspSignatureActiveParameter = { link = "MatchParen" },
	LspCodeLens = { link = "Comment" },
	LspCodeLensSeparator = { link = "Comment" },
	LspInlayHint = { fg = colors.comment },

	-- Treesitter: variables
	["@variable"] = { fg = colors.fg_2 },
	["@variable.member"] = { fg = colors.fg_3 },
	["@variable.builtin"] = { fg = colors.fg_3 },
	["@variable.parameter"] = { fg = colors.fg_3 },
	["@variable.parameter.builtin"] = { fg = colors.fg_3 },
	["@property"] = { fg = colors.fg_3 },

	["@module"] = { link = "Special" },
	["@module.builtin"] = { fg = colors.fg_3 },
	["@label"] = { link = "Link" },

	-- Treesitter: literals
	["@constant"] = { link = "Constant" },
	["@constant.builtin"] = { fg = colors.fg_3, bold = true },
	["@constant.macro"] = { link = "PreProc" },
	["@boolean"] = { fg = colors.fg_3, bold = true },
	["@number"] = { link = "Constant" },
	["@number.float"] = { link = "Constant" },

	["@string"] = { link = "String" },
	["@string.documentation"] = { fg = colors.green },
	["@string.regexp"] = { fg = colors.magenta },
	["@string.escape"] = { fg = colors.br_cyan },
	["@string.special"] = { fg = colors.br_cyan },
	["@string.special.symbol"] = { fg = colors.fg_3 },
	["@string.special.url"] = { fg = colors.cyan, underline = true },
	["@character"] = { link = "Character" },
	["@character.special"] = { fg = colors.br_cyan },

	-- Treesitter: types
	["@type"] = { link = "Type" },
	["@type.builtin"] = { link = "TypeBuiltin" },
	["@type.definition"] = { link = "Type" },
	["@type.qualifier"] = { link = "Statement" },

	["@attribute"] = { link = "PreProc" },
	["@attribute.builtin"] = { link = "PreProc" },

	-- Treesitter: functions
	["@function"] = { fg = colors.fg_2 },
	["@function.builtin"] = { link = "FunctionBuiltin" },
	["@function.call"] = { link = "Function" },
	["@function.macro"] = { link = "PreProc" },
	["@function.method"] = { fg = colors.fg_2 },
	["@function.method.call"] = { link = "Function" },
	["@constructor"] = { link = "Special" },

	["@operator"] = { fg = colors.fg_3 },

	-- Treesitter: keywords
	["@keyword"] = { link = "Statement" },
	["@keyword.coroutine"] = { link = "Statement" },
	["@keyword.function"] = { link = "Statement" },
	["@keyword.operator"] = { fg = colors.fg_3 },
	["@keyword.import"] = { link = "Statement" },
	["@keyword.type"] = { link = "Statement" },
	["@keyword.modifier"] = { link = "Statement" },
	["@keyword.repeat"] = { link = "Statement" },
	["@keyword.return"] = { link = "Statement" },
	["@keyword.debug"] = { link = "WarningMsg" },
	["@keyword.exception"] = { link = "Exception" },
	["@keyword.conditional"] = { link = "Statement" },
	["@keyword.conditional.ternary"] = { fg = colors.fg_3 },
	["@keyword.directive"] = { link = "PreProc" },
	["@keyword.directive.define"] = { link = "PreProc" },

	-- Treesitter: punctuation
	["@punctuation.bracket"] = { fg = colors.fg_3 },
	["@punctuation.delimiter"] = { fg = colors.fg_3 },
	["@punctuation.special"] = { fg = colors.fg_3 },

	-- Treesitter: comments (doc comments slightly brighter)
	["@comment"] = { link = "Comment" },
	["@comment.documentation"] = { fg = colors.comment_doc },
	["@comment.error"] = { link = "ErrorMsg" },
	["@comment.warning"] = { link = "WarningMsg" },
	["@comment.todo"] = { link = "Todo" },
	["@comment.note"] = { link = "Special" },

	-- Treesitter: markup
	["@markup.strong"] = { bold = true },
	["@markup.italic"] = { fg = colors.comment_doc, italic = true },
	["@markup.strikethrough"] = { strikethrough = true, fg = colors.fg_1 },
	["@markup.underline"] = { underline = true },
	["@markup.heading"] = { link = "Title" },
	["@markup.heading.1"] = { fg = colors.fg_3, bold = true },
	["@markup.heading.2"] = { fg = colors.fg_3, bold = true },
	["@markup.heading.3"] = { fg = colors.fg_2, bold = true },
	["@markup.heading.4"] = { fg = colors.fg_2 },
	["@markup.heading.5"] = { fg = colors.fg_1 },
	["@markup.heading.6"] = { fg = colors.fg_1, italic = true },
	["@markup.quote"] = { fg = colors.fg_1, italic = true },
	["@markup.math"] = { fg = colors.br_cyan },
	["@markup.link"] = { fg = colors.cyan },
	["@markup.link.label"] = { fg = colors.cyan },
	["@markup.link.url"] = { fg = colors.fg_1 },
	["@markup.raw"] = { fg = colors.fg_3 },
	["@markup.raw.block"] = { fg = colors.fg_2 },
	["@markup.raw.delimiter"] = { fg = colors.fg_0 },
	["@markup.list"] = { fg = colors.fg_1 },
	["@markup.list.checked"] = { fg = colors.fg_0 },
	["@markup.list.unchecked"] = { fg = colors.fg_2 },

	["@tag"] = { link = "Statement" },
	["@tag.attribute"] = { fg = colors.fg_3, italic = true },
	["@tag.delimiter"] = { link = "Delimiter" },

	["@diff.plus"] = { link = "DiffAdd" },
	["@diff.minus"] = { link = "DiffDelete" },
	["@diff.delta"] = { link = "DiffChange" },

	-- LSP semantic tokens
	["@lsp.type.class"] = { link = "@type" },
	["@lsp.type.comment"] = {}, -- let Treesitter handle comments
	["@lsp.type.decorator"] = { link = "@attribute" },
	["@lsp.type.enum"] = { link = "@type" },
	["@lsp.type.enumMember"] = { link = "@constant" },
	["@lsp.type.function"] = { link = "@function" },
	["@lsp.type.interface"] = { link = "@type" },
	["@lsp.type.macro"] = { link = "@function.macro" },
	["@lsp.type.method"] = { link = "@function.method" },
	["@lsp.type.namespace"] = { link = "@module" },
	["@lsp.type.parameter"] = { link = "@variable.parameter" },
	["@lsp.type.property"] = { link = "@property" },
	["@lsp.type.struct"] = { link = "@type" },
	["@lsp.type.type"] = { link = "@type" },
	["@lsp.type.typeParameter"] = { link = "@type" },
	["@lsp.type.variable"] = { link = "@variable" },
	["@lsp.mod.deprecated"] = { strikethrough = true },
	["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" },
	["@lsp.typemod.variable.defaultLibrary"] = { link = "@variable.builtin" },
	["@lsp.typemod.variable.readonly"] = { fg = colors.fg_3 },

	-- Help
	helpHeadline = { link = "Title" },
	helpSectionDelim = { link = "Comment" },
	helpExample = { link = "String" },
	helpBar = { link = "Comment" },
	helpHyperTextJump = { link = "Link" },
	helpHyperTextEntry = { link = "Link" },
	helpVim = { link = "String" },
	helpCommand = { link = "String" },
	helpHeader = { link = "String" },
	helpNote = { link = "Todo" },
	helpWarning = { link = "WarningMsg" },
	helpDeprecated = { link = "ErrorMsg" },
	helpURL = { link = "Link" },

	-- Diff (syntax)
	diffAdded = { link = "DiffAdd" },
	diffBDiffer = { link = "Normal" },
	diffChanged = { link = "DiffChange" },
	diffComment = { link = "Comment" },
	diffCommon = { link = "Normal" },
	diffDiffer = { link = "Normal" },
	diffFile = { link = "DiffChange" },
	diffIdentical = { link = "Normal" },
	diffIndexLine = { link = "Normal" },
	diffIsA = { link = "Normal" },
	diffLine = { link = "Title" },
	diffNewFile = { link = "Normal" },
	diffNoEOL = { link = "Normal" },
	diffOldFile = { link = "Normal" },
	diffOnly = { link = "Normal" },
	diffRemoved = { link = "DiffDelete" },
	diffSubname = { link = "Normal" },

	gitcommitSelectedFile = { link = "Link" },
	gitcommitDiscardedFile = { link = "Link" },
	gitcommitUntrackedFile = { link = "Link" },
	gitcommitSummary = { link = "String" },

	-- Plugins: git
	Added = { fg = colors.green },
	Changed = { fg = colors.yellow },
	Removed = { fg = colors.red },
	GitSignsAdd = { fg = colors.green },
	GitSignsChange = { fg = colors.yellow },
	GitSignsDelete = { fg = colors.red },

	-- Plugins: indent-blankline
	IblIndent = { fg = colors.linenr_above },
	IblScope = { fg = colors.fg_0 },
}

lib.apply(groups)

-- Markdown
local markdown_markup = {
	strong = { fg = md.title, bold = true },
	italic = { fg = colors.fg_1, italic = true },
	strikethrough = { strikethrough = true },
	underline = { underline = true },
	heading = { fg = md.title, bold = true },
	["heading.1"] = { fg = md.title, bold = true },
	["heading.2"] = { fg = md.title, bold = true },
	["heading.3"] = { fg = md.title, bold = true },
	["heading.4"] = { fg = md.title, bold = true },
	["heading.5"] = { fg = md.title, bold = true },
	["heading.6"] = { fg = md.title, bold = true },
	quote = { fg = colors.fg_1, italic = true },
	math = { fg = md.blue },
	link = { fg = md.blue },
	["link.label"] = { fg = md.violet },
	["link.url"] = { fg = md.blue, underline = true },
	raw = { fg = md.blue },
	["raw.block"] = { fg = md.blue },
	["raw.delimiter"] = { fg = colors.comment },
	list = { fg = colors.fg_1 },
	["list.checked"] = { fg = colors.fg_1 },
	["list.unchecked"] = { fg = md.br_violet },
}

for name, opts in pairs(markdown_markup) do
	vim.api.nvim_set_hl(0, "@markup." .. name .. ".markdown", lib.normalize(opts))
	vim.api.nvim_set_hl(0, "@markup." .. name .. ".markdown_inline", lib.normalize(opts))
	vim.api.nvim_set_hl(0, "@markup.math.latex", lib.normalize({ fg = md.blue }))
end

-- Heading markers (#) stay gray; only the heading text is white
vim.api.nvim_set_hl(0, "@markup.heading.marker.markdown", { fg = colors.fg_1 })
for i = 1, 6 do
	vim.api.nvim_set_hl(0, ("@markup.heading.%d.marker.markdown"):format(i), { fg = colors.fg_1 })
end

-- Only *inline* code gets the popup background; fenced blocks stay flat
vim.api.nvim_set_hl(0, "@markup.raw.markdown_inline", { fg = md.blue, bg = colors.popup_bg })

-- Frontmatter (YAML injected into markdown) uses its own namespace, so the
-- property color never leaks into plain YAML files
lib.frontmatter("insanity_markdown", {
	["@property.yaml"] = { fg = md.prop },
})
