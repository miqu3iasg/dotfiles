-- colors/dosx.lua

-- Dosbox inspired.
--
-- Copyright (c) Miquéias Alves Medeiros <https://github.com/miqu3iasg>
--
-- See: lua/lib/colors.lua
--
-- SPDX-License-Identifier: MIT

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") == 1 then
	vim.cmd("syntax reset")
end
vim.o.termguicolors = true
vim.o.background = "dark"
vim.g.colors_name = "dosx"

local c = {
	black = "#000000",
	blue = "#0000AA",
	green = "#00AA00",
	cyan = "#00AAAA",
	red = "#AA0000",
	magenta = "#AA00AA",
	brown = "#AA5500",
	gray = "#AAAAAA",
	dgray = "#555555",
	lblue = "#5555FF",
	lgreen = "#55FF55",
	lcyan = "#55FFFF",
	lred = "#FF5555",
	lmagenta = "#FF55FF",
	yellow = "#FFFF55",
	white = "#FFFFFF",
	hl = "#0000CC",
	guide = "#2020E0",
}

local function hl(g, o)
	vim.api.nvim_set_hl(0, g, o)
end

local groups = {
	Normal = { fg = c.yellow, bg = c.blue },
	NormalNC = { fg = c.yellow, bg = c.blue },
	Cursor = { fg = c.black, bg = c.gray },
	lCursor = { fg = c.black, bg = c.gray },
	CursorLine = { bg = c.hl },
	CursorColumn = { bg = c.hl },
	ColorColumn = { bg = c.hl },
	LineNr = { fg = c.lblue },
	CursorLineNr = { fg = c.white, bold = true },
	SignColumn = { bg = c.blue },
	FoldColumn = { fg = c.lblue, bg = c.blue },
	Folded = { fg = c.lcyan, bg = c.hl },
	EndOfBuffer = { fg = c.lblue },
	NonText = { fg = c.lblue },
	Whitespace = { fg = c.guide },
	SpecialKey = { fg = c.guide },
	WinSeparator = { fg = c.white, bg = c.blue },
	VertSplit = { fg = c.white, bg = c.blue },

	Visual = { fg = c.black, bg = c.cyan },
	VisualNOS = { fg = c.black, bg = c.cyan },
	Search = { fg = c.black, bg = c.green },
	IncSearch = { fg = c.black, bg = c.lgreen, bold = true },
	CurSearch = { fg = c.black, bg = c.lgreen, bold = true },
	Substitute = { fg = c.white, bg = c.red },
	MatchParen = { fg = c.black, bg = c.gray },

	Pmenu = { fg = c.black, bg = c.gray },
	PmenuSel = { fg = c.black, bg = c.green },
	PmenuSbar = { bg = c.dgray },
	PmenuThumb = { bg = c.black },
	PmenuKind = { fg = c.blue, bg = c.gray },
	PmenuExtra = { fg = c.dgray, bg = c.gray },
	WildMenu = { fg = c.black, bg = c.green },

	NormalFloat = { fg = c.gray, bg = c.black },
	FloatBorder = { fg = c.lcyan, bg = c.black },
	FloatTitle = { fg = c.black, bg = c.gray, bold = true },

	StatusLine = { fg = c.black, bg = c.gray },
	StatusLineNC = { fg = c.gray, bg = c.dgray },
	TabLine = { fg = c.black, bg = c.gray },
	TabLineSel = { fg = c.black, bg = c.green },
	TabLineFill = { bg = c.gray },
	WinBar = { fg = c.black, bg = c.gray },
	WinBarNC = { fg = c.gray, bg = c.dgray },

	Title = { fg = c.white, bold = true },
	Directory = { fg = c.lcyan, bold = true },
	ErrorMsg = { fg = c.white, bg = c.red, bold = true },
	WarningMsg = { fg = c.yellow, bg = c.brown },
	ModeMsg = { fg = c.white, bold = true },
	MoreMsg = { fg = c.lgreen },
	Question = { fg = c.lgreen },
	SpellBad = { undercurl = true, sp = c.lred },
	SpellCap = { undercurl = true, sp = c.lcyan },
	SpellRare = { undercurl = true, sp = c.lmagenta },
	SpellLocal = { undercurl = true, sp = c.lgreen },

	DiffAdd = { fg = c.lgreen },
	DiffChange = { fg = c.lcyan },
	DiffDelete = { fg = c.lred },
	DiffText = { fg = c.white, bg = c.brown, bold = true },
	Added = { fg = c.lgreen },
	Changed = { fg = c.lcyan },
	Removed = { fg = c.lred },

	Comment = { fg = c.gray },
	Constant = { fg = c.lmagenta },
	String = { fg = c.lcyan },
	Character = { fg = c.lcyan },
	Number = { fg = c.lmagenta },
	Boolean = { fg = c.lmagenta, bold = true },
	Float = { fg = c.lmagenta },
	Identifier = { fg = c.yellow },
	Function = { fg = c.yellow, bold = true },
	Statement = { fg = c.white, bold = true },
	Conditional = { fg = c.white, bold = true },
	Repeat = { fg = c.white, bold = true },
	Label = { fg = c.white, bold = true },
	Keyword = { fg = c.white, bold = true },
	Exception = { fg = c.white, bold = true },
	Operator = { fg = c.white },
	PreProc = { fg = c.lgreen },
	Include = { fg = c.lgreen },
	Define = { fg = c.lgreen },
	Macro = { fg = c.lgreen },
	PreCondit = { fg = c.lgreen },
	Type = { fg = c.white },
	StorageClass = { fg = c.white, bold = true },
	Structure = { fg = c.white },
	Typedef = { fg = c.white },
	Special = { fg = c.lgreen },
	SpecialChar = { fg = c.lmagenta },
	Tag = { fg = c.white, bold = true },
	Delimiter = { fg = c.gray },
	SpecialComment = { fg = c.lcyan },
	Debug = { fg = c.lred },
	Underlined = { fg = c.lcyan, underline = true },
	Ignore = { fg = c.lblue },
	Error = { fg = c.white, bg = c.red, bold = true },
	Todo = { fg = c.black, bg = c.gray, bold = true },

	["@variable"] = { fg = c.yellow },
	["@variable.builtin"] = { fg = c.white, bold = true },
	["@property"] = { fg = c.yellow },
	["@field"] = { fg = c.yellow },
	["@constant.builtin"] = { fg = c.lmagenta, bold = true },
	["@module"] = { fg = c.white },
	["@constructor"] = { fg = c.white, bold = true },
	["@string.escape"] = { fg = c.lmagenta },
	["@function.builtin"] = { fg = c.white, bold = true },
	["@punctuation.delimiter"] = { fg = c.gray },
	["@punctuation.bracket"] = { fg = c.gray },
	["@tag.attribute"] = { fg = c.yellow },
	["@tag.delimiter"] = { fg = c.gray },
	["@markup.heading"] = { fg = c.white, bold = true },
	["@markup.strong"] = { bold = true },
	["@markup.italic"] = { italic = true },
	["@markup.link"] = { fg = c.lcyan, underline = true },
	["@markup.raw"] = { fg = c.lcyan },
	["@markup.list"] = { fg = c.lgreen },
	["@comment.todo"] = { link = "Todo" },
	["@comment.error"] = { fg = c.white, bg = c.red, bold = true },
	["@comment.warning"] = { fg = c.yellow, bg = c.brown, bold = true },
	["@lsp.type.namespace"] = { link = "@module" },
	["@lsp.type.parameter"] = { link = "@variable" },
	["@lsp.type.property"] = { link = "@property" },
	["@lsp.type.enumMember"] = { link = "@constant" },

	DiagnosticError = { fg = c.lred },
	DiagnosticWarn = { fg = c.yellow },
	DiagnosticInfo = { fg = c.lcyan },
	DiagnosticHint = { fg = c.gray },
	DiagnosticOk = { fg = c.lgreen },
	DiagnosticUnderlineError = { undercurl = true, sp = c.lred },
	DiagnosticUnderlineWarn = { undercurl = true, sp = c.yellow },
	DiagnosticUnderlineInfo = { undercurl = true, sp = c.lcyan },
	DiagnosticUnderlineHint = { undercurl = true, sp = c.gray },
	DiagnosticVirtualTextError = { fg = c.white, bg = c.red },
	DiagnosticVirtualTextWarn = { fg = c.yellow, bg = c.brown },
	DiagnosticVirtualTextInfo = { fg = c.lcyan },
	DiagnosticVirtualTextHint = { fg = c.gray },
	LspReferenceText = { bg = c.hl },
	LspReferenceRead = { bg = c.hl },
	LspReferenceWrite = { bg = c.hl, underline = true },
	LspInlayHint = { fg = c.lblue },

	-- Plugins
	GitSignsAdd = { fg = c.lgreen },
	GitSignsChange = { fg = c.lcyan },
	GitSignsDelete = { fg = c.lred },
	CmpItemAbbr = { fg = c.black },
	CmpItemAbbrMatch = { fg = c.blue, bold = true },
	CmpItemAbbrMatchFuzzy = { fg = c.blue },
	CmpItemMenu = { fg = c.dgray },
}

for name, opts in pairs(groups) do
	hl(name, opts)
end

local term = {
	c.black,
	c.red,
	c.green,
	c.brown,
	c.blue,
	c.magenta,
	c.cyan,
	c.gray,
	c.dgray,
	c.lred,
	c.lgreen,
	c.yellow,
	c.lblue,
	c.lmagenta,
	c.lcyan,
	c.white,
}
for i, color in ipairs(term) do
	vim.g["terminal_color_" .. (i - 1)] = color
end
