-- colors/parchment.lua

-- A tribute to the classic Vim schemes (desert, zenburn, elflord): warm
-- parchment text on black, khaki statements and salmon strings.
--
-- Copyright (c) Miquéias Alves Medeiros <https://github.com/miqu3iasg>
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
vim.g.colors_name = "parchment"

local lib = require("lib.colors")

-- Palette
local p = {
	-- Neutrals
	black = "#000000", -- background
	fg = "#d7d0c0", -- default text
	dim = "#8a8578", -- line numbers, folds, delimiters
	comment = "#7ea6b8", -- faded sky blue, inherited from desert

	-- Surfaces
	surface = "#121212", -- cursorline, floats, inactive bars
	surface_hl = "#262626", -- matches, menu scrollbar
	selection = "#3a3a28", -- visual selection
	border = "#4a4a4a", -- floats, splits, listchars

	-- Syntax
	khaki = "#f0e68c", -- statements, search
	olive = "#bdb76b", -- types
	salmon = "#e8a39b", -- strings
	sand = "#f4a460", -- numbers, warnings
	red = "#cd5c5c", -- preprocessor, errors
	green = "#9fd8a0", -- identifiers
	navajo = "#ffdead", -- functions, specials
	lilac = "#c8a2c8", -- operators
	cyan = "#87ceeb", -- directories, links
	blue = "#6f9fd0", -- terminal blue

	-- Diff and git
	add = "#5f875f",
	change = "#b8a050",
	delete = "#af5f5f",
	diff = {
		add_bg = "#1a2a1a", -- added line
		change_bg = "#2a281a", -- changed line
		delete_bg = "#2a1a1a", -- deleted line
		text_bg = "#4a4620", -- changed text inside a line
	},

	-- Diagnostic virtual text backgrounds, a dark tint of each severity
	diag = {
		error_bg = "#3a2a2a",
		warn_bg = "#3a342a",
		info_bg = "#2a343a",
		hint_bg = "#2a3a2c",
	},

	-- Terminal palette: only the entries the syntax palette does not cover
	term = {
		bright_black = "#5a5a5a",
		red = "#e07070",
		green = "#b5ecb5",
		yellow = "#fff0a0",
		blue = "#8fb8e8",
		magenta = "#dcbcdc",
		cyan = "#a8dcf0",
		white = "#ffffff",
	},
}

local diff = p.diff

-- Editor UI
local editor = {
	Normal = { fg = p.fg, bg = p.black },
	NormalNC = { fg = p.fg, bg = p.black },
	NormalFloat = { fg = p.fg, bg = p.surface },
	FloatBorder = { fg = p.border, bg = p.surface },
	FloatTitle = { fg = p.khaki, bg = p.surface, bold = true },
	Cursor = { fg = p.black, bg = p.khaki },
	CursorLine = { bg = p.surface },
	CursorColumn = { bg = p.surface },
	ColorColumn = { bg = p.surface },
	LineNr = { fg = p.dim },
	CursorLineNr = { fg = p.khaki, bold = true },
	SignColumn = { bg = p.black },
	FoldColumn = { fg = p.dim, bg = p.black },
	Folded = { fg = p.dim, bg = p.surface },
	VertSplit = { fg = p.border },
	WinSeparator = { fg = p.border },
	EndOfBuffer = { fg = p.black },
	NonText = { fg = p.border },
	Whitespace = { fg = p.surface_hl },
	SpecialKey = { fg = p.border },
	Visual = { bg = p.selection },
	VisualNOS = { bg = p.selection },
	Search = { fg = p.black, bg = p.sand },
	IncSearch = { fg = p.black, bg = p.khaki, bold = true },
	CurSearch = { fg = p.black, bg = p.khaki, bold = true },
	Substitute = { fg = p.black, bg = p.red },
	MatchParen = { fg = p.khaki, bg = p.surface_hl, bold = true },
	Pmenu = { fg = p.fg, bg = p.surface },
	PmenuSel = { fg = p.black, bg = p.olive },
	PmenuSbar = { bg = p.surface_hl },
	PmenuThumb = { bg = p.border },
	StatusLine = { fg = p.black, bg = p.olive, bold = true },
	StatusLineNC = { fg = p.dim, bg = p.surface_hl },
	TabLine = { fg = p.dim, bg = p.surface_hl },
	TabLineSel = { fg = p.black, bg = p.olive, bold = true },
	TabLineFill = { bg = p.surface },
	WinBar = { fg = p.fg, bg = p.black },
	WinBarNC = { fg = p.dim, bg = p.black },
	Title = { fg = p.khaki, bold = true },
	Directory = { fg = p.cyan },
	ErrorMsg = { fg = p.red, bold = true },
	WarningMsg = { fg = p.sand },
	ModeMsg = { fg = p.khaki, bold = true },
	MoreMsg = { fg = p.green },
	Question = { fg = p.green },
	WildMenu = { fg = p.black, bg = p.khaki },
	SpellBad = { undercurl = true, sp = p.red },
	SpellCap = { undercurl = true, sp = p.sand },
	SpellRare = { undercurl = true, sp = p.lilac },
	SpellLocal = { undercurl = true, sp = p.cyan },

	-- Diff and git
	DiffAdd = { bg = diff.add_bg },
	DiffChange = { bg = diff.change_bg },
	DiffDelete = { fg = p.delete, bg = diff.delete_bg },
	DiffText = { bg = diff.text_bg, bold = true },
	Added = { fg = p.add },
	Changed = { fg = p.change },
	Removed = { fg = p.delete },
}

-- Vim syntax groups
local syntax = {
	Comment = { fg = p.comment, italic = false },
	Constant = { fg = p.salmon },
	String = { fg = p.salmon },
	Character = { fg = p.salmon },
	Number = { fg = p.sand },
	Boolean = { fg = p.sand, bold = true },
	Float = { fg = p.sand },
	Identifier = { fg = p.green },
	Function = { fg = p.navajo },
	Statement = { fg = p.khaki, bold = true },
	Conditional = { fg = p.khaki, bold = true },
	Repeat = { fg = p.khaki, bold = true },
	Label = { fg = p.khaki },
	Operator = { fg = p.lilac },
	Keyword = { fg = p.khaki, bold = true },
	Exception = { fg = p.red, bold = true },
	PreProc = { fg = p.red },
	Include = { fg = p.red },
	Define = { fg = p.red },
	Macro = { fg = p.red },
	PreCondit = { fg = p.red },
	Type = { fg = p.olive, bold = true },
	StorageClass = { fg = p.olive },
	Structure = { fg = p.olive },
	Typedef = { fg = p.olive },
	Special = { fg = p.navajo },
	SpecialChar = { fg = p.sand },
	Tag = { fg = p.khaki },
	Delimiter = { fg = p.dim },
	SpecialComment = { fg = p.cyan, italic = true },
	Debug = { fg = p.red },
	Underlined = { fg = p.cyan, underline = true },
	Ignore = { fg = p.dim },
	Error = { fg = p.red, bold = true },
	Todo = { fg = p.black, bg = p.khaki, bold = true },
}

-- Treesitter and LSP semantic tokens
local treesitter = {
	["@variable"] = { fg = p.fg },
	["@variable.builtin"] = { fg = p.lilac, italic = true },
	["@variable.parameter"] = { fg = p.green },
	["@variable.member"] = { fg = p.green },
	["@property"] = { fg = p.green },
	["@field"] = { fg = p.green },
	["@constant.builtin"] = { fg = p.sand, bold = true },
	["@module"] = { fg = p.olive },
	["@string.escape"] = { fg = p.sand },
	["@string.regexp"] = { fg = p.sand },
	["@function.builtin"] = { fg = p.navajo, italic = true },
	["@function.call"] = { fg = p.navajo },
	["@constructor"] = { fg = p.olive },
	["@keyword.function"] = { fg = p.khaki, bold = true },
	["@keyword.return"] = { fg = p.khaki, bold = true },
	["@type.builtin"] = { fg = p.olive },
	["@attribute"] = { fg = p.red },
	["@punctuation.delimiter"] = { fg = p.dim },
	["@punctuation.bracket"] = { fg = p.dim },
	["@punctuation.special"] = { fg = p.sand },
	["@comment.error"] = { fg = p.red, bold = true },
	["@comment.warning"] = { fg = p.sand, bold = true },
	["@tag"] = { fg = p.khaki },
	["@tag.attribute"] = { fg = p.green },
	["@tag.delimiter"] = { fg = p.dim },
	["@markup.heading"] = { fg = p.khaki, bold = true },
	["@markup.strong"] = { bold = true },
	["@markup.italic"] = { italic = true },
	["@markup.link"] = { fg = p.cyan, underline = true },
	["@markup.raw"] = { fg = p.salmon },
	["@markup.list"] = { fg = p.sand },
}

-- Diagnostics and LSP
local diagnostics = {
	DiagnosticError = { fg = p.red },
	DiagnosticWarn = { fg = p.sand },
	DiagnosticInfo = { fg = p.cyan },
	DiagnosticHint = { fg = p.green },
	DiagnosticOk = { fg = p.green },
	DiagnosticUnderlineError = { undercurl = true, sp = p.red },
	DiagnosticUnderlineWarn = { undercurl = true, sp = p.sand },
	DiagnosticUnderlineInfo = { undercurl = true, sp = p.cyan },
	DiagnosticUnderlineHint = { undercurl = true, sp = p.green },
	DiagnosticVirtualTextError = { fg = p.red, bg = p.diag.error_bg },
	DiagnosticVirtualTextWarn = { fg = p.sand, bg = p.diag.warn_bg },
	DiagnosticVirtualTextInfo = { fg = p.cyan, bg = p.diag.info_bg },
	DiagnosticVirtualTextHint = { fg = p.green, bg = p.diag.hint_bg },
	LspReferenceText = { bg = p.surface_hl },
	LspReferenceRead = { bg = p.surface_hl },
	LspReferenceWrite = { bg = p.surface_hl, underline = true },
	LspInlayHint = { fg = p.dim, italic = true },
}

-- Plugins
local plugins = {
	-- gitsigns
	GitSignsAdd = { fg = p.add },
	GitSignsChange = { fg = p.change },
	GitSignsDelete = { fg = p.delete },
	-- nvim-cmp
	CmpItemAbbrMatch = { fg = p.khaki, bold = true },
	CmpItemAbbrMatchFuzzy = { fg = p.khaki },
	CmpItemKindFunction = { fg = p.navajo },
	CmpItemKindVariable = { fg = p.green },
	CmpItemKindKeyword = { fg = p.khaki },
	CmpItemKindClass = { fg = p.olive },

	-- Add more here as needed
}

-- Links (hi! link)
local links = {
	["@constant"] = "Constant",
	["@function"] = "Function",
	["@function.macro"] = "Macro",
	["@keyword"] = "Keyword",
	["@keyword.import"] = "Include",
	["@type"] = "Type",
	["@comment"] = "Comment",
	["@comment.todo"] = "Todo",
	["@lsp.type.namespace"] = "@module",
	["@lsp.type.parameter"] = "@variable.parameter",
	["@lsp.type.property"] = "@property",
	["@lsp.type.enumMember"] = "@constant",
}

-- Apply

lib.apply(links)
lib.apply(editor)
lib.apply(syntax)
lib.apply(treesitter)
lib.apply(diagnostics)
lib.apply(plugins)

-- Terminal palette
local term = p.term
lib.terminal_colors({
	p.black,
	p.red,
	p.green,
	p.khaki,
	p.blue,
	p.lilac,
	p.cyan,
	p.fg,
	term.bright_black,
	term.red,
	term.green,
	term.yellow,
	term.blue,
	term.magenta,
	term.cyan,
	term.white,
})
