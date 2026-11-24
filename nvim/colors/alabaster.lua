-- colors/alabaster.lua
--
-- A port of the Alabaster colorscheme by mcncl <https://github.com/mcncl>.
--
-- Copyright (c) mcncl <https://github.com/mcncl>
-- Copyright (c) Miquéias Alves Medeiros <https://github.com/miqu3iasg>
--
-- See: lua/lib/colors.lua
-- See: https://github.com/mcncl/alabaster.nvim
--
-- SPDX-License-Identifier: Vim

vim.cmd("runtime colors/vim.lua")
vim.g.colors_name = "alabaster"

local colors = require("lib.colors")

-- Palettes
local palettes = {
	light = {
		-- Base
		bg = "#F7F7F7",
		fg = "#000000",
		comment = "#9DA39A",
		string = "#448C27",
		constant = "#7A3E9D",
		entity = "#325CC0",
		escape = "#777777",
		punctuation = "#777777",

		-- Status
		invalid_bg = "#F7E6E6",
		invalid_fg = "#660000",
		warning = "#CB9000",
		info = "#0083B2",
		hint = "#448C27",

		-- Surfaces
		line_highlight = "#F0F0F0",
		selection = "#BFDBFE",
		selection_highlight = "#E3E3E3",
		cursor = "#007ACC",
		line_number = "#9DA39A",
		visual = "#BFDBFE",

		-- Search
		find_match = "#FFBC5D",
		find_match_highlight = "#FFE9C2",

		-- Diff
		diff_add_bg = "#DDFFDD",
		diff_delete_bg = "#FFDDDD",
		diff_change_bg = "#DDDDFF",
		diff_text = "#434343",

		-- Statusline
		statusline_bg = "#DDDDDD", -- also used by the tabline
		statusline_fg = "#474747",
		statusline_nc_bg = "#DDDDDD",
		statusline_nc_fg = "#474747",

		-- Terminal
		term = {
			black = "#000000",
			red = "#AA3731",
			green = "#448C27",
			yellow = "#CB9000",
			blue = "#325CC0",
			magenta = "#7A3E9D",
			cyan = "#0083B2",
			white = "#BBBBBB",
			bright_black = "#777777",
			bright_red = "#F05050",
			bright_green = "#60CB00",
			bright_yellow = "#FFBC5D",
			bright_blue = "#007ACC",
			bright_magenta = "#E64CE6",
			bright_cyan = "#00AACB",
			bright_white = "#FFFFFF",
		},
	},

	dark = {
		-- Base
		bg = "#000000",
		fg = "#CECECE",
		comment = "#6B7678",
		string = "#91B362",
		constant = "#B77FDB",
		entity = "#6199D9",
		escape = "#999999",
		punctuation = "#999999",

		-- Status
		invalid_bg = "#3D2022",
		invalid_fg = "#D96468",
		warning = "#D9B76C",
		info = "#5AAEBD",
		hint = "#91B362",

		-- Surfaces
		line_highlight = "#1A1F20",
		selection = "#1C3D5C",
		selection_highlight = "#2A2F30",
		cursor = "#6199D9",
		line_number = "#4A5759",
		visual = "#1C3D5C",

		-- Search
		find_match = "#5F4C00",
		find_match_highlight = "#3D3100",

		-- Diff
		diff_add_bg = "#1D3124",
		diff_delete_bg = "#3D2022",
		diff_change_bg = "#1D2845",
		diff_text = "#CECECE",

		-- Statusline
		statusline_bg = "#111111", -- cursorline tone; also used by the tabline
		statusline_fg = "#d8d8d8",
		statusline_nc_bg = "#0d0d0d", -- popup tone
		statusline_nc_fg = "#878769",

		-- Terminal
		term = {
			black = "#000000",
			red = "#D96468",
			green = "#91B362",
			yellow = "#D9B76C",
			blue = "#6199D9",
			magenta = "#B77FDB",
			cyan = "#5AAEBD",
			white = "#BBBBBB",
			bright_black = "#666666",
			bright_red = "#F07178",
			bright_green = "#AAD94C",
			bright_yellow = "#FFD580",
			bright_blue = "#73B8FF",
			bright_magenta = "#D2A6FF",
			bright_cyan = "#7FD5E0",
			bright_white = "#FFFFFF",
		},
	},
}

local p = palettes[vim.o.background == "light" and "light" or "dark"]

-- Options
local transparent = vim.g.alabaster_transparent == true
local bg = transparent and "NONE" or p.bg
local float_bg = transparent and "NONE" or p.line_highlight
local comment = { fg = p.comment, italic = vim.g.alabaster_italic_comments == true }

-- Highlight groups

-- Editor UI
local editor = {
	-- Base
	Normal = { fg = p.fg, bg = bg },
	CursorLine = { bg = float_bg },
	CursorLineNr = { fg = p.fg },
	CursorLineFold = { fg = p.line_number, bg = float_bg },
	CursorLineSign = { bg = float_bg },
	CursorColumn = { bg = float_bg },
	ColorColumn = { bg = float_bg },
	LineNr = { fg = p.line_number },
	SignColumn = { bg = bg },
	FoldColumn = { fg = p.line_number, bg = bg },
	Folded = { fg = p.line_number, bg = float_bg },
	Conceal = { fg = p.punctuation },
	Directory = { fg = p.entity },
	Title = { fg = p.entity, bold = true },
	MatchParen = { bg = p.selection_highlight },
	QuickFixLine = { bg = p.selection },

	-- Special text
	NonText = { fg = p.line_number },
	EndOfBuffer = { fg = p.line_number },
	Whitespace = { fg = p.line_number },
	SpecialKey = { fg = p.line_number },

	-- Selection and search
	Visual = { bg = p.visual },
	VisualNOS = { bg = p.visual },
	Search = { bg = p.find_match },
	IncSearch = { bg = p.find_match },

	-- Windows and splits
	WinSeparator = { fg = p.line_number },
	WinBar = { fg = p.fg, bg = bg },
	WinBarNC = { fg = p.line_number, bg = bg },

	-- Messages and command line
	MsgArea = { fg = p.fg },
	ModeMsg = { fg = p.fg, bold = true },
	MoreMsg = { fg = p.string },
	Question = { fg = p.string },
	WarningMsg = { fg = p.warning },
	ErrorMsg = { fg = p.invalid_fg },

	-- Statusline and tabline
	StatusLine = { fg = p.statusline_fg, bg = p.statusline_bg, nocombine = true },
	StatusLineNC = { fg = p.statusline_nc_fg, bg = p.statusline_nc_bg, nocombine = true },
	TabLine = { fg = p.line_number, bg = p.statusline_bg },
	TabLineFill = { bg = p.statusline_bg },
	TabLineSel = { fg = p.fg, bg = bg },

	-- Spell
	SpellBad = { undercurl = true, sp = p.invalid_fg },
	SpellCap = { undercurl = true, sp = p.entity },
	SpellRare = { undercurl = true, sp = p.constant },
	SpellLocal = { undercurl = true, sp = p.string },
}

-- Popups and floating windows
local popup = {
	NormalFloat = { fg = p.fg, bg = float_bg },
	FloatBorder = { fg = p.line_number, bg = float_bg },
	FloatTitle = { fg = p.fg, bg = float_bg },

	Pmenu = { fg = p.fg, bg = float_bg },
	PmenuSel = { fg = p.fg, bg = p.selection_highlight },
	PmenuSbar = { bg = float_bg },
	PmenuThumb = { bg = p.punctuation },
	WildMenu = { fg = p.fg, bg = p.selection },
}

-- Vim syntax groups
local syntax = {
	Comment = comment,
	Constant = { fg = p.constant },
	Character = { fg = p.constant },
	Number = { fg = p.constant },
	Boolean = { fg = p.constant },
	Float = { fg = p.constant },
	String = { fg = p.string },

	Identifier = { fg = p.fg },
	Function = { fg = p.entity },

	Statement = { fg = p.fg },
	Conditional = { fg = p.fg },
	Repeat = { fg = p.fg },
	Label = { fg = p.fg },
	Operator = { fg = p.fg },
	Keyword = { fg = p.fg },
	Exception = { fg = p.fg },

	PreProc = { fg = p.fg },
	Include = { fg = p.fg },
	Define = { fg = p.fg },
	Macro = { fg = p.fg },
	PreCondit = { fg = p.fg },

	Type = { fg = p.fg },
	StorageClass = { fg = p.fg },
	Structure = { fg = p.fg },
	Typedef = { fg = p.fg },

	Special = { fg = p.punctuation },
	SpecialChar = { fg = p.escape },
	Tag = { fg = p.entity },
	Delimiter = { fg = p.punctuation },
	SpecialComment = { fg = p.comment },
	Debug = { fg = p.comment },

	Underlined = { underline = true },
	Ignore = { fg = p.punctuation },
	Error = { fg = p.invalid_fg, bg = p.invalid_bg },
	Todo = { fg = p.comment },
}

-- Treesitter and LSP semantic tokens
local treesitter = {
	-- Comments
	["@comment"] = comment,

	-- Literals
	["@string.escape"] = { fg = p.escape },
	["@string.special"] = { fg = p.escape },
	["@string.special.url"] = { fg = p.entity, underline = true },
	["@string.special.path"] = { fg = p.string },
	["@character.special"] = { fg = p.escape },
	["@symbol"] = { fg = p.constant },
	["@symbol.clojure"] = { fg = p.constant },
	["@keyword.clojure"] = { fg = p.constant },

	-- Keywords and operators
	["@keyword"] = { fg = p.fg },
	["@keyword.function"] = { fg = p.fg },
	["@keyword.operator"] = { fg = p.fg },
	["@keyword.return"] = { fg = p.fg },
	["@operator"] = { fg = p.fg },

	-- Punctuation
	["@punctuation.delimiter"] = { fg = p.punctuation },
	["@punctuation.bracket"] = { fg = p.punctuation },
	["@punctuation.special"] = { fg = p.punctuation },

	-- Variables
	["@variable"] = { fg = p.fg },
	["@variable.builtin"] = { fg = p.fg },
	["@variable.parameter"] = { fg = p.fg },
	["@variable.member"] = { fg = p.fg },
	["@property"] = { fg = p.fg },

	-- Functions
	["@function.call"] = { fg = p.fg },
	["@function.method.call"] = { fg = p.fg },
	["@method.call"] = { fg = p.fg },
	["@constructor"] = { fg = p.entity },

	-- Types and structure
	["@type"] = { fg = p.fg },
	["@type.builtin"] = { fg = p.fg },
	["@type.qualifier"] = { fg = p.fg },
	["@type.definition"] = { fg = p.entity },
	["@namespace"] = { fg = p.entity },
	["@module"] = { fg = p.entity },
	["@attribute"] = { fg = p.constant },
	["@label"] = { fg = p.fg },

	-- Tags
	["@tag"] = { fg = p.entity },
	["@tag.attribute"] = { fg = p.fg },
	["@tag.delimiter"] = { fg = p.punctuation },

	-- Markup
	["@markup.heading"] = { fg = p.entity, bold = true },
	["@markup.heading.1"] = { fg = p.entity, bold = true },
	["@markup.heading.2"] = { fg = p.entity, bold = true },
	["@markup.heading.3"] = { fg = p.entity, bold = true },
	["@markup.heading.4"] = { fg = p.entity, bold = true },
	["@markup.heading.5"] = { fg = p.entity, bold = true },
	["@markup.heading.6"] = { fg = p.entity, bold = true },
	["@markup.strong"] = { bold = true },
	["@markup.italic"] = { italic = true },
	["@markup.strikethrough"] = { strikethrough = true },
	["@markup.underline"] = { underline = true },
	["@markup.quote"] = { fg = p.comment, italic = true },
	["@markup.math"] = { fg = p.constant },
	["@markup.link"] = { fg = p.entity, underline = true },
	["@markup.link.label"] = { fg = p.entity },
	["@markup.link.url"] = { fg = p.string, underline = true },
	["@markup.raw"] = { fg = p.string },
	["@markup.raw.block"] = { fg = p.string },
	["@markup.list"] = { fg = p.punctuation },
	["@markup.list.checked"] = { fg = p.string },
	["@markup.list.unchecked"] = { fg = p.punctuation },

	-- LSP semantic tokens
	["@lsp.type.class"] = { fg = p.entity },
	["@lsp.type.decorator"] = { fg = p.constant },
	["@lsp.type.enum"] = { fg = p.entity },
	["@lsp.type.enumMember"] = { fg = p.constant },
	["@lsp.type.interface"] = { fg = p.entity },
	["@lsp.type.namespace"] = { fg = p.entity },
	["@lsp.type.parameter"] = { fg = p.fg },
	["@lsp.type.property"] = { fg = p.fg },
	["@lsp.type.struct"] = { fg = p.entity },
	["@lsp.type.type"] = { fg = p.fg },
	["@lsp.type.typeParameter"] = { fg = p.entity },
	["@lsp.type.variable"] = { fg = p.fg },
	["@lsp.mod.deprecated"] = { strikethrough = true },
	["@lsp.mod.readonly"] = { fg = p.constant },
}

-- Diagnostics and LSP
local diagnostics = {
	DiagnosticError = { fg = p.invalid_fg },
	DiagnosticWarn = { fg = p.warning },
	DiagnosticInfo = { fg = p.info },
	DiagnosticHint = { fg = p.hint },

	DiagnosticVirtualTextError = { fg = p.invalid_fg, bg = p.invalid_bg },
	DiagnosticVirtualTextWarn = { fg = p.warning },
	DiagnosticVirtualTextInfo = { fg = p.info },
	DiagnosticVirtualTextHint = { fg = p.hint },

	DiagnosticUnderlineError = { undercurl = true, sp = p.invalid_fg },
	DiagnosticUnderlineWarn = { undercurl = true, sp = p.warning },
	DiagnosticUnderlineInfo = { undercurl = true, sp = p.info },
	DiagnosticUnderlineHint = { undercurl = true, sp = p.hint },

	DiagnosticSignError = { fg = p.invalid_fg },
	DiagnosticSignWarn = { fg = p.warning },
	DiagnosticSignInfo = { fg = p.info },
	DiagnosticSignHint = { fg = p.hint },

	DiagnosticFloatingError = { fg = p.invalid_fg },
	DiagnosticFloatingWarn = { fg = p.warning },
	DiagnosticFloatingInfo = { fg = p.info },
	DiagnosticFloatingHint = { fg = p.hint },

	LspReferenceText = { bg = p.selection_highlight },
	LspReferenceRead = { bg = p.selection_highlight },
	LspReferenceWrite = { bg = p.selection_highlight },

	LspCodeLens = { fg = p.line_number },
	LspCodeLensSeparator = { fg = p.line_number },
	LspInlayHint = { fg = p.line_number, bg = float_bg },
}

-- Diff
local diff = {
	DiffAdd = { fg = p.diff_text, bg = p.diff_add_bg },
	DiffChange = { fg = p.diff_text, bg = p.diff_change_bg },
	DiffDelete = { fg = p.diff_text, bg = p.diff_delete_bg },
	DiffText = { fg = p.diff_text, bg = p.selection },
}

-- Plugins
local plugins = {
	-- nvim-cmp
	CmpItemAbbr = { fg = p.fg },
	CmpItemAbbrDeprecated = { fg = p.punctuation, strikethrough = true },
	CmpItemAbbrMatch = { fg = p.entity, bold = true },
	CmpItemAbbrMatchFuzzy = { fg = p.entity },
	CmpItemKind = { fg = p.constant },
	CmpItemKindClass = { fg = p.entity },
	CmpItemKindColor = { fg = p.constant },
	CmpItemKindConstant = { fg = p.constant },
	CmpItemKindConstructor = { fg = p.entity },
	CmpItemKindEnum = { fg = p.entity },
	CmpItemKindEnumMember = { fg = p.constant },
	CmpItemKindEvent = { fg = p.entity },
	CmpItemKindField = { fg = p.fg },
	CmpItemKindFile = { fg = p.fg },
	CmpItemKindFolder = { fg = p.entity },
	CmpItemKindFunction = { fg = p.entity },
	CmpItemKindInterface = { fg = p.entity },
	CmpItemKindKeyword = { fg = p.fg },
	CmpItemKindMethod = { fg = p.entity },
	CmpItemKindModule = { fg = p.entity },
	CmpItemKindOperator = { fg = p.fg },
	CmpItemKindProperty = { fg = p.fg },
	CmpItemKindReference = { fg = p.fg },
	CmpItemKindSnippet = { fg = p.string },
	CmpItemKindStruct = { fg = p.entity },
	CmpItemKindText = { fg = p.fg },
	CmpItemKindTypeParameter = { fg = p.entity },
	CmpItemKindUnit = { fg = p.constant },
	CmpItemKindValue = { fg = p.constant },
	CmpItemKindVariable = { fg = p.fg },
	CmpItemMenu = { fg = p.punctuation },

	-- gitsigns.nvim
	GitSignsAdd = { fg = p.string },
	GitSignsChange = { fg = p.info },
	GitSignsDelete = { fg = p.invalid_fg },
	GitSignsAddNr = { fg = p.string },
	GitSignsChangeNr = { fg = p.info },
	GitSignsDeleteNr = { fg = p.invalid_fg },
	GitSignsAddLn = { bg = p.diff_add_bg },
	GitSignsChangeLn = { bg = p.diff_change_bg },
	GitSignsDeleteLn = { bg = p.diff_delete_bg },
	GitSignsCurrentLineBlame = { fg = p.line_number },
}

-- Links (hi! link)
local links = {
	-- Editor
	VertSplit = "WinSeparator",
	StatusLineTerm = "StatusLine",
	StatusLineTermNC = "StatusLineNC",

	-- Treesitter
	["@string"] = "String",
	["@string.regexp"] = "String",
	["@number"] = "Number",
	["@boolean"] = "Boolean",
	["@character"] = "Character",
	["@constant"] = "Constant",
	["@constant.builtin"] = "Constant",
	["@function"] = "Function",
	["@function.builtin"] = "Function",
	["@function.macro"] = "Function",

	-- LSP semantic tokens
	["@lsp.type.function"] = "Function",
	["@lsp.type.macro"] = "Function",
	["@lsp.type.method"] = "Function",
	["@lsp.type.comment"] = "Comment",
	["@lsp.mod.defaultLibrary"] = "@variable.builtin",
	["@lsp.typemod.function.defaultLibrary"] = "@function.builtin",
	["@lsp.typemod.variable.defaultLibrary"] = "@variable.builtin",
}

-- Terminal colors
local term = {
	p.term.black,
	p.term.red,
	p.term.green,
	p.term.yellow,
	p.term.blue,
	p.term.magenta,
	p.term.cyan,
	p.term.white,
	p.term.bright_black,
	p.term.bright_red,
	p.term.bright_green,
	p.term.bright_yellow,
	p.term.bright_blue,
	p.term.bright_magenta,
	p.term.bright_cyan,
	p.term.bright_white,
}

for i, color in ipairs(term) do
	vim.g["terminal_color_" .. (i - 1)] = color
end

-- Apply

colors.apply(links)
colors.apply(editor)
colors.apply(syntax)
colors.apply(popup)
colors.apply(treesitter)
colors.apply(diagnostics)
colors.apply(diff)
colors.apply(plugins)
