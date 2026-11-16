-- colors/artifact.lua

-- A relic of the old terminal. Simplicity is a feature and every visible
-- character matters.
--
-- Copyright (c) Miquéias Medeiros <contatomiqueiasalvesdev@gmail.com>
--
-- See: lua/lib/colors.lua
--
-- SPDX-License-Identifier: MIT

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
	vim.cmd("syntax reset")
end
vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "artifact"

local lib = require("lib.colors")

local transparent = vim.g.artifact_transparent == true
local underline_on = vim.g.artifact_underline ~= false
local italic_on = vim.g.artifact_italic == true

-- Applies the user flags: underline/undercurl live behind
-- `g:artifact_underline`, italic behind `g:artifact_italic`. Specs stay
-- declarative; the flags strip attributes before anything is set.
local function gate(groups)	for _, spec in pairs(groups) do
		if type(spec) == "table" then
			if not underline_on then
				spec.underline = nil
				spec.undercurl = nil
			end
			if not italic_on then
				spec.italic = nil
			end
		end
	end
	return groups
end

local function apply(tbl)
	lib.apply(gate(tbl))
end

local P = {
	bg = "#000000",
	surface = "#111111",
	visual = "#1f1f1f",

	bright = "#e4e4e4",
	fg = "#e4e4e4",
	md = "#b8b8b8",
	mid = "#9a9a9a",
	note = "#9e9e9e", -- comments: readable, but always quieter than code
	rule = "#7a7a7a", -- window separators
	dim = "#6c6c6c",
	white = "#ffffff", -- matching brackets only
	match = "#444444", -- background of matching brackets

	blue = "#7a88c8",
	cyan = "#5f9f9f",
	green = "#6aa86a", -- messages and ok/added only, never syntax
	yellow = "#c9b458",
	magenta = "#b080b0",
	pink = "#c88a8a",
	orange = "#c8935a",
	red = "#b85050",

	diff_add_bg = "#1f2f4f",
	diff_change_bg = "#3f2f4f",
	diff_delete_bg = "#1f3f3f",
	diff_text_bg = "#6f2f2f",
}

-- The single accent color (keywords, current line number, TODO badge).
-- Change only this line to try another one.
P.accent = P.yellow

-- Attention colors. These exist ONLY to be loud when you are hunting for
-- something. They must never be used for syntax, UI chrome or plugins, so
-- that they always stand out from everything else in the theme.
local alert = {
	search = "#a020f0", -- every search match
	current = P.bright, -- the match under the cursor (with black text)
	yank = "#d787af", -- yank flash
}

local c = {
	bg = P.bg,
	fg = P.fg,
	md = P.md,
	line = P.surface,
	visual = P.visual,
	comment = P.note, -- real comments and comment-like text
	ui = P.dim, -- quiet chrome: borders, separators, tildes, line numbers
	dim = P.dim,
	string = P.pink,
	type = P.bright, -- types: weight and brightness, not hue
	keyword = P.accent,
	func = P.fg,
	number = P.pink,
	alt = P.cyan,
	red = P.red,
	warn = P.orange,
}

local NONE = "NONE"
local bg_main = transparent and NONE or c.bg
local bg_float = transparent and NONE or "#0e0e0e"

local diff_add = lib.blend(P.bright, P.bg, 0.12)
local diff_change = lib.blend(P.cyan, P.bg, 0.22)
local diff_delete = lib.blend(P.red, P.bg, 0.35)
local code_bg = P.surface

-- Editor UI
local editor = {
	Normal = { fg = c.fg, bg = bg_main },
	NormalNC = { fg = c.fg, bg = bg_main },
	MsgArea = { fg = c.fg, bg = bg_main },
	ColorColumn = { bg = c.line },
	Conceal = { fg = c.func },
	Cursor = { fg = P.bg, bg = P.fg },
	CursorColumn = { bg = c.line },
	CursorLine = { bg = NONE },
	CursorLineNr = { fg = P.accent, bold = true },
	CursorLineSign = { bg = bg_main },
	CursorLineFold = { fg = c.fg, bg = bg_main },
	LineNr = { fg = c.ui, bg = bg_main },
	LineNrAbove = { fg = c.ui, bg = bg_main },
	LineNrBelow = { fg = c.ui, bg = bg_main },
	SignColumn = { fg = c.fg, bg = bg_main },
	FoldColumn = { fg = P.cyan, bg = P.visual },
	Folded = { fg = P.cyan, bg = P.visual },
	EndOfBuffer = { fg = c.ui },
	NonText = { fg = c.ui },
	SpecialKey = { fg = P.cyan },
	Whitespace = { fg = "#282828" },
	Directory = { fg = c.type, bold = true },
	Title = { fg = P.bright, bold = true },
	Underlined = { fg = c.fg, underline = true },
	Ignore = { fg = c.ui },

	Visual = { bg = c.visual },
	VisualNOS = { bg = c.visual, underline = true },
	Search = { fg = P.bright, bg = alert.search },
	CurSearch = { fg = P.bg, bg = alert.current, bold = true },
	IncSearch = { fg = P.bg, bg = alert.current, bold = true },
	Substitute = { fg = P.bg, bg = P.mid },
	MatchParen = { fg = P.white, bg = P.match, bold = true },
	QuickFixLine = { bg = c.line, bold = true },

	-- Dedicated group for yank flash. Use it in your TextYankPost autocmd:
	--   vim.hl.on_yank({ higroup = "YankHighlight" })
	YankHighlight = { fg = P.bg, bg = alert.yank },

	ErrorMsg = { fg = P.bright, bg = P.red },
	WarningMsg = { fg = P.red },
	ModeMsg = { fg = P.fg, bold = true },
	MoreMsg = { fg = P.green, bold = true },
	Question = { fg = P.green, bold = true },
	MsgSeparator = { fg = c.ui, bg = c.line },

	VertSplit = { fg = P.rule, bg = bg_main },
	WinSeparator = { fg = P.rule, bg = bg_main },
	WinBar = { fg = c.fg, bg = bg_main },
	WinBarNC = { fg = c.ui, bg = bg_main },

	-- Statusline: subtle background; active vs inactive by bg and text color.
	-- Tabline stays text-only (bg_main, not NONE, so it matches Normal).
	StatusLine = { fg = P.bright, bg = bg_main },
	StatusLineNC = { fg = P.dim, bg = bg_main },
	TabLine = { fg = P.dim, bg = bg_main },
	TabLineFill = { fg = P.dim, bg = bg_main },
	TabLineSel = { fg = P.mid, bg = bg_main },

	TitleBar = { fg = c.fg, bg = bg_main },
	TitleBarNC = { fg = c.ui, bg = bg_main },
	ToolbarButton = { fg = c.type, bg = c.line, bold = true },
	ToolbarLine = { bg = bg_main },

	SpellBad = { sp = P.red, underline = true },
	SpellCap = { sp = P.mid, underline = true },
	SpellLocal = { sp = P.cyan, underline = true },
	SpellRare = { sp = P.mid, underline = true },

	DiffAdd = { fg = P.fg, bg = P.diff_add_bg },
	DiffChange = { fg = P.fg, bg = P.diff_change_bg },
	DiffDelete = { fg = P.cyan, bg = P.diff_delete_bg },
	DiffText = { fg = P.bright, bg = P.diff_text_bg, bold = true },
	Added = { fg = P.green },
	Changed = { fg = P.yellow },
	Removed = { fg = P.red },
	diffFile = { fg = c.type, bold = true },
	diffLine = { fg = c.alt },

	NormalFloat = { fg = c.fg, bg = bg_float },
	FloatBorder = { fg = c.ui, bg = bg_float },
	FloatTitle = { fg = c.type, bg = bg_float, bold = true },
	FloatFooter = { fg = c.ui, bg = bg_float },
	Pmenu = { fg = P.fg, bg = bg_float },
	PmenuSel = { fg = P.bright, bg = P.visual },
	PmenuKind = { fg = c.ui, bg = bg_float },
	PmenuKindSel = { fg = P.bright, bg = P.visual },
	PmenuExtra = { fg = c.ui, bg = bg_float },
	PmenuExtraSel = { fg = P.bright, bg = P.visual },
	PmenuMatch = { fg = P.accent, bg = bg_float, bold = true },
	PmenuMatchSel = { fg = P.accent, bg = P.visual, bold = true },
	PmenuSbar = { bg = P.surface },
	PmenuThumb = { bg = P.dim },
	WildMenu = { fg = P.bright, bg = P.visual, bold = true },

	Terminal = { fg = c.fg, bg = bg_main },
	TermCursor = { fg = P.bg, bg = P.fg },
	debugPC = { bg = c.line },
	debugBreakpoint = { fg = c.red },
}

-- Vim syntax groups
local syntax = {
	Comment = { fg = P.note },
	Constant = { fg = P.pink },
	String = { fg = P.pink },
	Character = { fg = P.pink },
	Number = { fg = P.pink },
	Boolean = { fg = P.pink },
	Float = { fg = P.pink },
	Identifier = { fg = P.fg },
	Function = { fg = P.fg },
	Statement = { fg = c.keyword, bold = true },
	Conditional = { fg = c.keyword, bold = true },
	Repeat = { fg = c.keyword, bold = true },
	Label = { fg = c.keyword, bold = true },
	Operator = { fg = P.fg },
	Keyword = { fg = c.keyword, bold = true },
	Exception = { fg = c.keyword, bold = true },
	PreProc = { fg = P.orange },
	Include = { fg = P.orange },
	Define = { fg = P.orange },
	Macro = { fg = P.orange },
	PreCondit = { fg = P.orange },
	Type = { fg = c.type, bold = true },
	StorageClass = { fg = c.type, bold = true },
	Structure = { fg = c.type, bold = true },
	Typedef = { fg = c.type, bold = true },
	Special = { fg = P.orange },
	SpecialChar = { fg = P.orange },
	Tag = { fg = P.orange },
	Delimiter = { fg = P.fg },
	SpecialComment = { fg = P.note },
	Debug = { fg = P.orange },
	Error = { fg = P.bright, bg = P.red },
	Todo = { fg = P.bg, bg = P.accent, bold = true },

	-- Tags inside comments (TODO, NOTE, WARN...): brighter and bold, but no
	-- new color. Handy for study notes.
	["@comment.todo"] = { fg = P.bright, bold = true },
	["@comment.note"] = { fg = P.bright, bold = true },
	["@comment.warning"] = { fg = P.bright, bold = true },
	["@comment.error"] = { fg = P.red, bold = true },
}

-- LSP
local lsp = {
	-- Hints are not your text: keep them dimmer than comments.
	LspInlayHint = { fg = P.dim, bg = c.line },
	LspReferenceText = { bg = c.visual },
	LspReferenceRead = { bg = c.visual },
	LspReferenceWrite = { bg = c.visual, underline = true },
	LspCodeLens = { fg = P.dim },
	LspCodeLensSeparator = { fg = P.dim },
	LspSignatureActiveParameter = { fg = c.type, bold = true, underline = true },
}

-- Diagnostics
local diag = {
	DiagnosticError = { fg = c.red },
	DiagnosticWarn = { fg = c.warn },
	DiagnosticInfo = { fg = P.cyan },
	DiagnosticHint = { fg = P.mid },
	DiagnosticOk = { fg = P.green },
	DiagnosticUnnecessary = { fg = c.ui },
	DiagnosticDeprecated = { fg = c.ui, strikethrough = true },

	DiagnosticVirtualTextError = { fg = P.red },
	DiagnosticVirtualTextWarn = { fg = P.orange },
	DiagnosticVirtualTextInfo = { fg = P.cyan },
	DiagnosticVirtualTextHint = { fg = P.mid },
	DiagnosticVirtualTextOk = { fg = P.green },

	DiagnosticUnderlineError = { sp = P.red, underline = true },
	DiagnosticUnderlineWarn = { sp = P.orange, underline = true },
	DiagnosticUnderlineInfo = { sp = P.cyan, underline = true },
	DiagnosticUnderlineHint = { sp = P.mid, underline = true },
	DiagnosticUnderlineOk = { sp = P.green, underline = true },

	DiagnosticFloatingError = { fg = c.red },
	DiagnosticFloatingWarn = { fg = c.warn },
	DiagnosticFloatingInfo = { fg = P.cyan },
	DiagnosticFloatingHint = { fg = P.mid },
	DiagnosticSignError = { fg = c.red },
	DiagnosticSignWarn = { fg = c.warn },
	DiagnosticSignInfo = { fg = P.cyan },
	DiagnosticSignHint = { fg = P.mid },
}

-- Markdown
-- Heading levels fade in brightness, not in hue.
local heading_levels = { P.bright, P.bright, P.fg, P.fg, P.mid, P.mid }

local markdown = {
	["@keyword.directive.markdown"] = { fg = c.alt },
	["@punctuation.special.markdown"] = { fg = c.fg },
	["@punctuation.delimiter.markdown"] = { fg = c.fg },

	["@markup.list.markdown"] = { fg = c.alt, bold = true },
	["@markup.list.checked.markdown"] = { fg = c.alt, bold = true },
	["@markup.list.unchecked.markdown"] = { fg = c.alt, bold = true },

	["@markup.quote.markdown"] = { fg = P.mid, italic = true },

	["@markup.raw.block.markdown"] = { fg = c.fg },
	["@markup.raw.delimiter.markdown"] = { fg = c.alt },
	["@label.markdown"] = { fg = c.alt, italic = true },

	["@markup.strong.markdown_inline"] = { fg = P.bright, bold = true },
	["@markup.italic.markdown_inline"] = { fg = P.mid, italic = true },
	["@markup.strikethrough.markdown_inline"] = { fg = c.ui, strikethrough = true },

	["@markup.raw.markdown_inline"] = { fg = P.bright, bg = code_bg },
	-- Math (inline and block) uses the theme's cyan.
	["@markup.math.markdown_inline"] = { fg = c.alt },
	["@markup.math.markdown"] = { fg = c.alt },
	["@markup.math.latex"] = { fg = c.alt },
	["@punctuation.special.markdown_inline"] = { fg = c.type },

	["@markup.link.markdown_inline"] = { fg = c.ui },
	["@markup.link.label.markdown_inline"] = { fg = c.type, bg = c.line, underline = true },
	["@markup.link.url.markdown_inline"] = { fg = c.alt, underline = true },

	["@string.escape.markdown_inline"] = { fg = c.alt },
	["@conceal.markdown_inline"] = { fg = c.ui },

	["@markup.heading.markdown"] = { fg = P.bright, bold = true },
	["@markup.heading.marker.markdown"] = { fg = P.bright },
}

for i, color in ipairs(heading_levels) do
	markdown[("@markup.heading.%d.markdown"):format(i)] =
		i == 1 and { fg = color, bold = true, underline = true } or { fg = color, bold = true }
	markdown[("@markup.heading.%d.marker.markdown"):format(i)] = { fg = color }
end

-- Legacy regex-based markdown groups point to the treesitter ones.
local markdown_links = {
	markdownH1 = "@markup.heading.1.markdown",
	markdownH2 = "@markup.heading.2.markdown",
	markdownH3 = "@markup.heading.3.markdown",
	markdownH4 = "@markup.heading.4.markdown",
	markdownH5 = "@markup.heading.5.markdown",
	markdownH6 = "@markup.heading.6.markdown",
	markdownHeadingDelimiter = "@markup.heading.marker.markdown",
	markdownHeadingRule = "@markup.heading.marker.markdown",
	markdownCode = "@markup.raw.markdown_inline",
	markdownCodeBlock = "@markup.raw.block.markdown",
	markdownCodeDelimiter = "@markup.raw.delimiter.markdown",
	markdownBlockquote = "@markup.quote.markdown",
	markdownListMarker = "@markup.list.markdown",
	markdownOrderedListMarker = "@markup.list.markdown",
	markdownRule = "@punctuation.special.markdown",
	markdownBold = "@markup.strong.markdown_inline",
	markdownItalic = "@markup.italic.markdown_inline",
	markdownBoldItalic = "@markup.strong.markdown_inline",
	markdownStrike = "@markup.strikethrough.markdown_inline",
	markdownLinkText = "@markup.link.label.markdown_inline",
	markdownUrl = "@markup.link.url.markdown_inline",
	markdownLinkDelimiter = "@markup.link.markdown_inline",
	markdownIdDelimiter = "@markup.link.markdown_inline",
	markdownAutomaticLink = "@markup.link.url.markdown_inline",
	markdownEscape = "@string.escape.markdown_inline",
}

local plugins = {}

plugins.oil = {
	OilDir = { fg = P.bright, bold = true },
	OilDirIcon = { fg = P.bright },
	OilFile = { fg = c.fg },
	OilLink = { fg = P.mid },
	OilLinkTarget = { fg = c.ui },
	OilOrphanLink = { fg = c.red },
	OilOrphanLinkTarget = { fg = c.red },
	OilHidden = { fg = c.dim },
	OilDirHidden = { fg = P.dim, bold = true },
	OilFileHidden = { fg = P.dim },
	OilLinkHidden = { fg = P.dim },
	OilOrphanLinkHidden = { fg = c.red },
	OilExecutable = { fg = P.fg, bold = true },
	OilSocket = { fg = P.mid },

	OilCreate = { fg = c.type, bold = true },
	OilCopy = { fg = c.type, bold = true },
	OilMove = { fg = c.warn },
	OilChange = { fg = c.warn },
	OilDelete = { fg = c.red },
	OilPurge = { fg = c.red, bold = true },
	OilRestore = { fg = c.type, bold = true },
	OilTrash = { fg = c.ui },
	OilTrashSourcePath = { fg = c.ui },

	OilTypeDir = { fg = P.bright, bold = true },
	OilTypeFile = { fg = c.ui },
	OilTypeLink = { fg = P.mid },
	OilTypeFifo = { fg = c.ui },
	OilTypeSocket = { fg = c.ui },
	OilTypeUnknown = { fg = c.ui },
	OilPermissionNone = { fg = c.ui },
	OilPermissionRead = { fg = c.warn },
	OilPermissionWrite = { fg = c.red },
	OilPermissionExecute = { fg = c.type },
}

plugins.special = {
	LazyNormal = { bg = bg_float },
	MasonNormal = { bg = bg_float },
}


plugins.gitsigns = {
	GitSignsAdd = { link = "Added" },
	GitSignsChange = { link = "Changed" },
	GitSignsDelete = { link = "Removed" },
	GitSignsAddNr = { link = "Added" },
	GitSignsChangeNr = { link = "Changed" },
	GitSignsDeleteNr = { link = "Removed" },
	GitSignsAddLn = { bg = diff_add },
	GitSignsChangeLn = { bg = diff_change },
	GitSignsDeleteLn = { bg = diff_delete },
	GitSignsAddCul = { fg = P.green, bg = c.line },
	GitSignsChangeCul = { fg = P.yellow, bg = c.line },
	GitSignsDeleteCul = { fg = P.red, bg = c.line },
	GitSignsAddInline = { link = "DiffAdd" },
	GitSignsChangeInline = { link = "DiffChange" },
	GitSignsDeleteInline = { link = "DiffDelete" },
	GitSignsAddPreview = { link = "DiffAdd" },
	GitSignsDeletePreview = { link = "DiffDelete" },
	GitSignsCurrentLineBlame = { fg = c.ui },
}

plugins.dashboard = {
	DashboardShortCut = { fg = c.func },
	DashboardHeader = { fg = c.keyword },
	DashboardCenter = { fg = c.fg },
	DashboardFooter = { fg = c.func },
}

-- Links (hi! link)
local links = {
	MessageWindow = "Pmenu",
	PopupNotification = "Todo",
	StatusLineTerm = "StatusLine",
	StatusLineTermNC = "StatusLineNC",
	lCursor = "Cursor",
	vCursor = "Cursor",
	iCursor = "Cursor",

	diffAdded = "Added",
	diffRemoved = "Removed",
	diffChanged = "Changed",
	diffNewFile = "Added",
	diffOldFile = "Removed",
	diffIndexLine = "Comment",
	diffSubname = "Comment",
	diffComment = "Comment",

	LspDiagnosticsDefaultError = "DiagnosticError",
	LspDiagnosticsDefaultWarning = "DiagnosticWarn",
	LspDiagnosticsDefaultInformation = "DiagnosticInfo",
	LspDiagnosticsDefaultHint = "DiagnosticHint",
	LspDiagnosticsUnderlineError = "DiagnosticUnderlineError",
	LspDiagnosticsUnderlineWarning = "DiagnosticUnderlineWarn",
	LspDiagnosticsUnderlineInformation = "DiagnosticUnderlineInfo",
	LspDiagnosticsUnderlineHint = "DiagnosticUnderlineHint",
	LspDiagnosticsVirtualTextError = "DiagnosticVirtualTextError",
	LspDiagnosticsVirtualTextWarning = "DiagnosticVirtualTextWarn",
	LspDiagnosticsVirtualTextInformation = "DiagnosticVirtualTextInfo",
	LspDiagnosticsVirtualTextHint = "DiagnosticVirtualTextHint",
}

-- Apply

apply(editor)
apply(syntax)
apply(lsp)
apply(diag)
apply(markdown)
for _, group in pairs(plugins) do
	apply(group)
end
lib.apply(links)
lib.apply(markdown_links)

-- Frontmatter (YAML injected into markdown): plain markdown text (no
-- treesitter capture) uses the md color; headings, code, inline math and
-- bold set their own fg, so they win.
local frontmatter = {
	Normal = { fg = c.md, bg = bg_main },
	NormalNC = { fg = c.md, bg = bg_main },

	["@property.yaml"] = { fg = c.alt },
	["@string.yaml"] = { fg = c.fg },
	["@number.yaml"] = { fg = c.number },
	["@number.float.yaml"] = { fg = c.number },
	["@boolean.yaml"] = { fg = c.number },
	["@constant.builtin.yaml"] = { fg = P.mid },
	["@label.yaml"] = { fg = c.alt },
	["@type.yaml"] = { fg = c.alt },
	["@punctuation.delimiter.yaml"] = { fg = c.ui },
	["@punctuation.bracket.yaml"] = { fg = c.ui },
}
local aug = lib.frontmatter("artifact_markdown", frontmatter)

-- Oil sometimes resets its groups on open. Apply them again.
vim.api.nvim_create_autocmd("FileType", {
	group = aug,
	pattern = "oil",
	callback = function()
		if vim.g.colors_name == "artifact" then
			lib.apply(gate(plugins.oil))
		end
	end,
})

-- Terminal palette
lib.terminal_colors({
	P.bg,
	P.red,
	P.green,
	P.yellow,
	P.blue,
	P.magenta,
	P.cyan,
	P.fg,
	P.dim,
	P.red,
	P.green,
	P.yellow,
	P.blue,
	P.magenta,
	P.cyan,
	P.bright,
})
