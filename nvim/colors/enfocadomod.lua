-- colors/enfocadomod.lua

-- Lua port of enfocadomod.vim. Enfocado is more than a theme, it is a
-- concept of 'how themes should be', focusing on what is really
-- important to developers: the code and nothing else.
--
-- Design decisions:
--
-- - Saturation is scaled globally by SATURATION (1.0 = original Enfocado),
--   applied to every palette color, so the mood survives palette edits.
-- - The semantic pseudo-groups (Accent, Text, Dimmed, Match, ...) are kept
--   from the original as the theme's own vocabulary; links target them
--   instead of raw colors.
-- - `nocombine` is set on the quiet groups on purpose, matching upstream.
--
-- Copyright (c) Wuelner Martínez <wuelner.martinez@outlook.com>
-- Copyright (c) Robertus Chris <diawan@pm.me>
-- Copyright (c) Miquéias Medeiros <contatomiqueiasalvesdev@gmail.com>
--
-- See: lua/lib/colors.lua       the shared color helpers this builds on
-- See: colors/insanity.lua      sibling port from the same upstream author
-- See: https://github.com/wuelnerdotexe/vim-enfocado
--
-- Reference: https://github.com/bruhtus/dotfiles/blob/master/.vim/colors/enfocadomod.vim
--
-- SPDX-License-Identifier: MIT

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
	vim.cmd("syntax reset")
end
vim.o.termguicolors = true
vim.g.colors_name = "enfocadomod"
vim.o.background = "dark"

local lib = require("lib.colors")

-- Saturation multiplier applied to every chromatic color in the palette
-- (1.0 = original Enfocado, lower = more muted).
local SATURATION = 0.8

-- Palette

local colors = {
	bg_0 = "#000000", -- pure black (original: #121212)
	bg_1 = "#252525", -- cursorline, floats, columns
	bg_2 = "#3b3b3b",
	dim_0 = "#808080",
	fg_0 = "#b9b9b9",
	fg_1 = "#dedede",

	red = "#d75f5f",
	green = "#5faf5f",
	yellow = "#ffd700",
	blue = "#5f87ff",
	magenta = "#d787af",
	cyan = "#5fafaf",
	orange = "#d7875f",
	violet = "#af87d7",

	br_red = "#ff5f5f",
	br_green = "#87d787",
	br_yellow = "#ffd751",
	br_blue = "#5fafff",
	br_magenta = "#ffafd7",
	br_cyan = "#87ffff",
	br_orange = "#ffaf87",
	br_violet = "#af87ff",

	search = "#ff00ff",
}

-- Mute every color by the same proportion (grays are unaffected)
for name, hex in pairs(colors) do
	colors[name] = lib.desaturate(hex, SATURATION)
end

-- Comments: dim_0 pulled toward the background
colors.comment = lib.blend(colors.dim_0, colors.bg_0, 0.6)

colors.accent_0 = colors.green
colors.accent_1 = colors.blue
colors.br_accent_0 = colors.green
colors.br_accent_1 = colors.blue

-- Terminal colors

lib.terminal_colors({
	colors.bg_1,
	colors.red,
	colors.green,
	colors.yellow,
	colors.blue,
	colors.magenta,
	colors.cyan,
	colors.dim_0,
	colors.bg_2,
	colors.br_red,
	colors.br_green,
	colors.br_yellow,
	colors.br_blue,
	colors.br_magenta,
	colors.br_cyan,
	colors.fg_1,
})

-- Highlight groups

local groups = {
	-- Editor UI
	Search = { bg = colors.search, fg = "#ffffff" },
	LineNr = { fg = colors.dim_0 },
	Accent = { fg = colors.br_accent_0 },
	Builtin = { fg = colors.br_magenta },
	ColorColumn = { bg = colors.bg_1 },
	Conceal = { fg = colors.bg_2, nocombine = true },
	Cursor = { bg = colors.fg_0, fg = colors.bg_1 },
	CursorColumn = { bg = colors.bg_1 },
	CursorLine = { bg = colors.bg_1 },
	CursorLineNr = { fg = colors.fg_1 },

	DiffAdd = { fg = colors.green },
	DiffChange = { fg = colors.br_yellow },
	DiffDelete = { fg = colors.red },
	DiffText = { bg = colors.fg_0, fg = colors.bg_0 },

	Dimmed = { fg = colors.dim_0, nocombine = true },
	Directory = { fg = colors.blue },
	ErrorMsg = { fg = colors.br_red, nocombine = true },
	FileLink = { fg = colors.cyan },
	FileExec = { fg = colors.green, nocombine = true },
	FloatBorder = { bg = colors.bg_0, fg = colors.br_accent_0, nocombine = true },
	Folded = { fg = colors.dim_0, nocombine = true },
	FoldColumn = { fg = colors.bg_2, nocombine = true },
	Ignore = { fg = colors.bg_2, nocombine = true },
	lCursor = { bg = colors.fg_0, fg = colors.bg_1 },
	LineNrAbove = { fg = colors.dim_0 },
	Match = { fg = colors.br_accent_0 },
	MatchFuzzy = { fg = colors.accent_0, nocombine = true },
	MatchParen = { fg = colors.br_cyan },
	ModeMsg = { fg = colors.fg_0, nocombine = true },
	MoreMsg = { fg = colors.br_yellow, nocombine = true },
	None = {},
	NonText = { fg = colors.dim_0, nocombine = true },

	Normal = { bg = colors.bg_0, fg = colors.fg_0, nocombine = true },
	NormalFloat = { bg = colors.bg_0, fg = colors.fg_0, nocombine = true },
	FloatTitle = { bg = colors.bg_0, fg = colors.fg_1 },
	FloatFooter = { bg = colors.bg_0, fg = colors.dim_0 },
	NvimInternalError = { fg = colors.br_red, nocombine = true },

	-- Completion menu
	Pmenu = { bg = colors.bg_0, fg = colors.dim_0, nocombine = true },
	PmenuSbar = { bg = colors.bg_0, nocombine = true },
	PmenuSel = { bg = colors.bg_0, fg = colors.fg_1 },
	PmenuThumb = { bg = colors.dim_0, nocombine = true },

	Question = { fg = colors.br_yellow, nocombine = true },
	QuickFixLine = { bg = colors.bg_1, fg = colors.br_accent_0 },
	RedrawDebugClear = { fg = colors.br_yellow },
	RedrawDebugComposed = { fg = colors.green },
	RedrawDebugNormal = { fg = colors.fg_1 },
	RedrawDebugRecompose = { fg = colors.br_red },
	SignColumn = {},
	SpecialKey = { fg = colors.dim_0, nocombine = true },
	SpellBad = { fg = colors.br_red },
	SpellCap = { fg = colors.magenta },
	SpellLocal = { fg = colors.cyan },
	SpellRare = { fg = colors.br_violet },

	-- Status line
	StatusLine = { bg = colors.bg_0, fg = colors.dim_0, nocombine = true },
	StatusLineNC = { bg = colors.bg_0, fg = colors.bg_2, nocombine = true },
	Success = { fg = colors.green, nocombine = true },

	-- Tab line
	TabLine = { bg = colors.bg_1, fg = colors.dim_0, nocombine = true },
	TabLineFill = { bg = colors.bg_0, fg = colors.fg_0, nocombine = true },
	TabLineSel = { fg = colors.fg_0, nocombine = true },
	ToolbarButton = { bg = colors.accent_0, fg = colors.bg_1, nocombine = true },
	ToolbarLine = { bg = colors.bg_1, fg = colors.dim_0, nocombine = true },

	TermCursor = { bg = colors.fg_0, fg = colors.bg_1 },
	Title = { fg = colors.fg_1 },
	VertSplit = { fg = colors.dim_0, nocombine = true },
	Visual = { bg = colors.dim_0, fg = colors.fg_1 },
	WarningMsg = { fg = colors.br_orange, nocombine = true },
	WildMenu = { bg = colors.bg_0, fg = colors.fg_1 },

	CursorLineSign = { link = "CursorLineNr" },
	CursorLineFold = { link = "CursorLine" },
	EndOfBuffer = { link = "NonText" },
	IncSearch = { link = "Search" },
	Line = { link = "ColorColumn" },
	LineNrBelow = { link = "LineNrAbove" },
	MsgArea = { link = "Text" },
	MsgSeparator = { link = "StatusLineNC" },
	NormalNC = { link = "Normal" },
	StatuslineTerm = { link = "StatusLine" },
	StatuslineTermNC = { link = "StatusLineNC" },
	Substitute = { link = "Search" },
	TermCursorNC = { link = "None" },
	VisualNc = { link = "Visual" },
	VisualNOS = { link = "Visual" },
	Whitespace = { link = "NonText" },
	WinBar = { link = "Text" },
	WinBarNC = { link = "Dimmed" },
	WinSeparator = { link = "VertSplit" },

	FloatShadow = { bg = "#000000", blend = 10 },
	FloatShadowThrough = { bg = "#000000", blend = 10 },

	-- General syntax
	Comment = { fg = colors.comment },
	ConstIdentifier = { fg = colors.yellow },
	Error = { fg = colors.br_red },
	Trace = { fg = colors.br_magenta, nocombine = true },
	Exception = { fg = colors.orange, nocombine = true },
	Function = { fg = colors.br_accent_0 },
	FunctionBuiltin = { fg = colors.br_magenta },
	Identifier = { fg = colors.accent_0, nocombine = true },
	IdentifierBuiltin = { fg = colors.magenta, nocombine = true },
	Link = { fg = colors.cyan, sp = colors.cyan },
	PreProc = { fg = colors.accent_1, nocombine = true },
	Special = { fg = colors.br_violet, nocombine = true },
	Statement = { fg = colors.accent_1, nocombine = true },
	StatementBuiltin = { fg = colors.violet, nocombine = true },
	String = { fg = colors.cyan, sp = colors.cyan, nocombine = true },
	Text = { fg = colors.fg_0, nocombine = true },
	Todo = { bg = colors.bg_0, fg = colors.br_cyan },
	Type = { fg = colors.br_accent_1 },
	TypeBuiltin = { fg = colors.br_violet },
	Underlined = { fg = colors.blue },

	Boolean = { link = "StatementBuiltin" },
	Character = { link = "String" },
	Conditional = { link = "Statement" },
	Constant = { link = "Text" },
	Debug = { link = "Dimmed" },
	Define = { link = "PreProc" },
	Delimiter = { link = "Text" },
	Float = { link = "Number" },
	Include = { link = "PreProc" },
	Keyword = { link = "Statement" },
	Label = { link = "Statement" },
	Macro = { link = "Define" },
	Method = { link = "Function" },
	Number = { link = "Constant" },
	Operator = { link = "Statement" },
	PreCondit = { link = "PreProc" },
	Property = { link = "Type" },
	Repeat = { link = "Statement" },
	SpecialChar = { link = "StatementBuiltin" },
	SpecialComment = { link = "StatementBuiltin" },
	StorageClass = { link = "Type" },
	Structure = { link = "Type" },
	Tag = { link = "Statement" },
	Typedef = { link = "Type" },

	-- Brackets and punctuation: {} [] () and friends all share the Delimiter color
	["@punctuation.bracket"] = { link = "Delimiter" },
	["@punctuation.delimiter"] = { link = "Delimiter" },
	["@punctuation.special"] = { link = "Delimiter" },
	-- Lua's grammar captures table braces `{}` as @constructor (-> Special)
	["@constructor.lua"] = { link = "Delimiter" },
	luaBraces = { link = "Delimiter" },
	luaParen = { link = "Delimiter" },
	jsonBraces = { link = "Delimiter" },
	javaScriptBraces = { link = "Delimiter" },
	javaScriptParens = { link = "Delimiter" },
	jsBraces = { link = "Delimiter" },
	jsParens = { link = "Delimiter" },
	jsObjectBraces = { link = "Delimiter" },

	-- Diagnostics
	DiagnosticError = { fg = colors.br_red },
	DiagnosticHint = { fg = colors.blue },
	DiagnosticInfo = { fg = colors.br_yellow },
	DiagnosticWarn = { fg = colors.br_orange },

	DiagnosticFloatingError = { bg = colors.bg_0, fg = colors.br_red },
	DiagnosticFloatingHint = { bg = colors.bg_0, fg = colors.blue },
	DiagnosticFloatingInfo = { bg = colors.bg_0, fg = colors.br_yellow },
	DiagnosticFloatingWarn = { bg = colors.bg_0, fg = colors.br_orange },

	DiagnosticUnderlineError = { undercurl = true, sp = colors.br_red },
	DiagnosticUnderlineHint = { undercurl = true, sp = colors.blue },
	DiagnosticUnderlineInfo = { undercurl = true, sp = colors.br_yellow },
	DiagnosticUnderlineWarn = { undercurl = true, sp = colors.br_orange },

	DiagnosticVirtualTextError = { bg = colors.bg_0, fg = colors.br_red },
	DiagnosticVirtualTextHint = { bg = colors.bg_0, fg = colors.blue },
	DiagnosticVirtualTextInfo = { bg = colors.bg_0, fg = colors.br_yellow },
	DiagnosticVirtualTextWarn = { bg = colors.bg_0, fg = colors.br_orange },

	DiagnosticSignError = { link = "DiagnosticError" },
	DiagnosticSignHint = { link = "DiagnosticHint" },
	DiagnosticSignInfo = { link = "DiagnosticInfo" },
	DiagnosticSignWarn = { link = "DiagnosticWarn" },

	-- Help
	helpHeadline = { link = "Title" },
	helpSectionDelim = { link = "Dimmed" },
	helpExample = { link = "Text" },
	helpBar = { link = "Dimmed" },
	helpHyperTextJump = { link = "String" },
	helpHyperTextEntry = { link = "String" },
	helpVim = { link = "Accent" },
	helpCommand = { link = "Text" },
	helpHeader = { link = "Title" },
	helpNote = { link = "Todo" },
	helpWarning = { link = "DiagnosticWarn" },
	helpDeprecated = { link = "DiagnosticError" },
	helpURL = { link = "Link" },

	-- Diff (syntax)
	diffAdded = { link = "DiffAdd" },
	diffBDiffer = { link = "Text" },
	diffChanged = { link = "DiffChange" },
	diffComment = { link = "Comment" },
	diffCommon = { link = "Text" },
	diffDiffer = { link = "Text" },
	diffFile = { link = "Text" },
	diffIdentical = { link = "Text" },
	diffIndexLine = { link = "Text" },
	diffIsA = { link = "Text" },
	diffLine = { link = "Title" },
	diffNewFile = { link = "Text" },
	diffNoEOL = { link = "Text" },
	diffOldFile = { link = "Text" },
	diffOnly = { link = "Text" },
	diffRemoved = { link = "DiffDelete" },
	diffSubname = { link = "Title" },
}

lib.apply(groups)
