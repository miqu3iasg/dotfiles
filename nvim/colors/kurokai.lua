-- colors/kurokai.lua

-- Where darkness meets the colors of Unokai.
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
vim.g.colors_name = "kurokai"

local c = {
	bg = "#000000",
	bg_alt = "#141414",
	bg_sel = "#3b3a32",
	dim = "#75715e",
	mid = "#a8a89a",
	fg = "#f8f8f2",
	pink = "#f92672",
	green = "#a6e22e",
	yellow = "#e6db74",
	err = "#ff3b3b",
}
c.type = vim.g.monobruto_extra and "#66d9ef" or c.green
c.num = vim.g.monobruto_extra and "#ae81ff" or c.yellow

local function hl(g, o)
	vim.api.nvim_set_hl(0, g, o)
end

local groups = {
	Normal = { fg = c.fg, bg = c.bg },
	NormalNC = { fg = c.fg, bg = c.bg },
	NormalFloat = { fg = c.fg, bg = c.bg_alt },
	FloatBorder = { fg = c.dim, bg = c.bg_alt },
	FloatTitle = { fg = c.green, bg = c.bg_alt, bold = true },
	Cursor = { fg = c.bg, bg = c.fg },
	lCursor = { fg = c.bg, bg = c.fg },
	CursorLine = { bg = c.bg_alt },
	CursorColumn = { bg = c.bg_alt },
	ColorColumn = { bg = c.bg_alt },
	LineNr = { fg = c.dim },
	CursorLineNr = { fg = c.fg, bold = true },
	SignColumn = { bg = c.bg },
	FoldColumn = { fg = c.dim },
	Folded = { fg = c.dim, bg = c.bg_alt },
	WinSeparator = { fg = c.bg_sel },
	VertSplit = { fg = c.bg_sel },
	EndOfBuffer = { fg = c.bg },
	NonText = { fg = c.bg_sel },
	Whitespace = { fg = c.bg_sel },
	SpecialKey = { fg = c.bg_sel },
	Visual = { bg = c.bg_sel },
	VisualNOS = { bg = c.bg_sel },
	Search = { fg = c.bg, bg = c.yellow },
	IncSearch = { fg = c.bg, bg = c.pink, bold = true },
	CurSearch = { fg = c.bg, bg = c.pink, bold = true },
	Substitute = { fg = c.bg, bg = c.pink },
	MatchParen = { fg = c.pink, bold = true, underline = true },
	Pmenu = { fg = c.fg, bg = c.bg_alt },
	PmenuSel = { fg = c.bg, bg = c.green },
	PmenuSbar = { bg = c.bg_alt },
	PmenuThumb = { bg = c.dim },
	WildMenu = { fg = c.bg, bg = c.green },
	StatusLine = { fg = c.bg, bg = c.fg, bold = true },
	StatusLineNC = { fg = c.dim, bg = c.bg_alt },
	TabLine = { fg = c.dim, bg = c.bg_alt },
	TabLineSel = { fg = c.bg, bg = c.fg, bold = true },
	TabLineFill = { bg = c.bg_alt },
	WinBar = { fg = c.fg, bg = c.bg },
	WinBarNC = { fg = c.dim, bg = c.bg },
	Title = { fg = c.green, bold = true },
	Directory = { fg = c.green },
	ErrorMsg = { fg = c.err, bold = true },
	WarningMsg = { fg = c.yellow },
	ModeMsg = { fg = c.yellow, bold = true },
	MoreMsg = { fg = c.green },
	Question = { fg = c.green },
	SpellBad = { undercurl = true, sp = c.err },
	SpellCap = { undercurl = true, sp = c.yellow },
	SpellRare = { undercurl = true, sp = c.dim },
	SpellLocal = { undercurl = true, sp = c.dim },

	DiffAdd = { bg = "#0f1a08" },
	DiffChange = { bg = "#1a1a08" },
	DiffDelete = { fg = c.pink, bg = "#1f0a10" },
	DiffText = { bg = "#3b3a1a", bold = true },
	Added = { fg = c.green },
	Changed = { fg = c.yellow },
	Removed = { fg = c.pink },

	Comment = { fg = c.dim, italic = false },
	Constant = { fg = c.num },
	String = { fg = c.yellow },
	Character = { fg = c.yellow },
	Number = { fg = c.num, bold = true },
	Boolean = { fg = c.num, bold = true },
	Float = { fg = c.num, bold = true },
	Identifier = { fg = c.fg },
	Function = { fg = c.green },
	Statement = { fg = c.pink },
	Conditional = { fg = c.pink },
	Repeat = { fg = c.pink },
	Label = { fg = c.pink },
	Keyword = { fg = c.pink },
	Exception = { fg = c.pink },
	Operator = { fg = c.pink },
	PreProc = { fg = c.pink },
	Include = { fg = c.pink },
	Define = { fg = c.pink },
	Macro = { fg = c.pink },
	PreCondit = { fg = c.pink },
	Type = { fg = c.type, italic = true },
	StorageClass = { fg = c.pink },
	Structure = { fg = c.type, italic = true },
	Typedef = { fg = c.type, italic = true },
	Special = { fg = c.fg, bold = true },
	SpecialChar = { fg = c.pink },
	Tag = { fg = c.pink },
	Delimiter = { fg = c.mid },
	SpecialComment = { fg = c.dim, bold = true, italic = true },
	Debug = { fg = c.pink },
	Underlined = { fg = c.fg, underline = true },
	Ignore = { fg = c.dim },
	Error = { fg = c.err, bold = true },
	Todo = { fg = c.bg, bg = c.yellow, bold = true },

	["@variable"] = { fg = c.fg },
	["@variable.builtin"] = { fg = c.fg, italic = true },
	["@variable.parameter"] = { fg = c.fg, italic = true },
	["@variable.member"] = { fg = c.fg },
	["@property"] = { fg = c.fg },
	["@field"] = { fg = c.fg },
	["@constant.builtin"] = { fg = c.num, bold = true },
	["@module"] = { fg = c.fg },
	["@constructor"] = { fg = c.type },
	["@string.escape"] = { fg = c.pink },
	["@string.regexp"] = { fg = c.pink },
	["@function.builtin"] = { fg = c.green, italic = true },
	["@function.call"] = { fg = c.green },
	["@keyword.function"] = { fg = c.pink },
	["@keyword.return"] = { fg = c.pink },
	["@type.builtin"] = { fg = c.type, italic = true },
	["@attribute"] = { fg = c.pink, italic = true },
	["@punctuation.delimiter"] = { fg = c.mid },
	["@punctuation.bracket"] = { fg = c.mid },
	["@tag.attribute"] = { fg = c.green, italic = true },
	["@tag.delimiter"] = { fg = c.mid },
	["@markup.heading"] = { fg = c.green, bold = true },
	["@markup.strong"] = { bold = true },
	["@markup.italic"] = { italic = true },
	["@markup.link"] = { fg = c.fg, underline = true },
	["@markup.raw"] = { fg = c.yellow },
	["@markup.list"] = { fg = c.pink },
	["@comment.todo"] = { link = "Todo" },
	["@comment.error"] = { fg = c.err, bold = true },
	["@comment.warning"] = { fg = c.yellow, bold = true },
	["@lsp.type.namespace"] = { link = "@module" },
	["@lsp.type.parameter"] = { link = "@variable.parameter" },
	["@lsp.type.property"] = { link = "@property" },
	["@lsp.type.enumMember"] = { link = "@constant" },

	DiagnosticError = { fg = c.err },
	DiagnosticWarn = { fg = c.yellow },
	DiagnosticInfo = { fg = c.mid },
	DiagnosticHint = { fg = c.dim },
	DiagnosticOk = { fg = c.green },
	DiagnosticUnderlineError = { undercurl = true, sp = c.err },
	DiagnosticUnderlineWarn = { undercurl = true, sp = c.yellow },
	DiagnosticUnderlineInfo = { undercurl = true, sp = c.mid },
	DiagnosticUnderlineHint = { undercurl = true, sp = c.dim },
	DiagnosticVirtualTextError = { fg = c.err, italic = true },
	DiagnosticVirtualTextWarn = { fg = c.yellow, italic = true },
	DiagnosticVirtualTextInfo = { fg = c.mid, italic = true },
	DiagnosticVirtualTextHint = { fg = c.dim, italic = true },
	LspReferenceText = { bg = c.bg_sel },
	LspReferenceRead = { bg = c.bg_sel },
	LspReferenceWrite = { bg = c.bg_sel, underline = true },
	LspInlayHint = { fg = c.dim, italic = true },

	-- Plugins
	GitSignsAdd = { fg = c.green },
	GitSignsChange = { fg = c.yellow },
	GitSignsDelete = { fg = c.pink },
	TelescopeNormal = { fg = c.fg, bg = c.bg_alt },
	TelescopeBorder = { fg = c.dim, bg = c.bg_alt },
	TelescopeSelection = { fg = c.green, bg = c.bg_sel, bold = true },
	TelescopeMatching = { fg = c.pink, bold = true },
	TelescopePromptPrefix = { fg = c.pink },
	CmpItemAbbrMatch = { fg = c.pink, bold = true },
	CmpItemAbbrMatchFuzzy = { fg = c.pink },
	CmpItemKindFunction = { fg = c.green },
	CmpItemKindKeyword = { fg = c.pink },
}

for name, opts in pairs(groups) do
	hl(name, opts)
end

local term = {
	"#000000",
	c.err,
	c.green,
	c.yellow,
	c.mid,
	c.pink,
	c.mid,
	c.fg,
	"#3b3a32",
	"#ff6b6b",
	"#c4f05a",
	"#f2e98f",
	c.fg,
	"#ff5c92",
	c.fg,
	"#ffffff",
}
for i, color in ipairs(term) do
	vim.g["terminal_color_" .. (i - 1)] = color
end
