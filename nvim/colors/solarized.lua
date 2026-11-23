-- colors/solarized.lua
--
-- Solarized (light) for Neovim.
--
-- Based on Solarized by Ethan Schoonover.
--
-- Copyright (c) ishan9299 <https://github.com/ishan9299>
-- Copyright (c) Miquéias Alves Medeiros <https://github.com/miqu3iasg>

local g = vim.g

vim.cmd("hi clear")

if vim.fn.exists("syntax_on") == 1 then
	vim.cmd("syntax reset")
end

g.colors_name = "solarized"

-- Defaults

local defaults = {
	solarized_visibility = "normal",
	solarized_diffmode = "normal",
	solarized_statusline = "normal",
	solarized_termtrans = 0,
	solarized_italics = 1,
}

for key, value in pairs(defaults) do
	if g[key] == nil then
		g[key] = value
	end
end

-- Palette
-- Each color is { gui hex, 256-color index }. The base tones are swapped
-- so the group definitions below render correctly on a light background.

local p = {
	none = { "none", "none" },
	base2 = { "#073642", 23 },
	red = { "#dc322f", 203 },
	green = { "#859900", 142 },
	yellow = { "#b58900", 178 },
	blue = { "#268bd2", 38 },
	magenta = { "#d33682", 169 },
	cyan = { "#2aa198", 37 },
	base02 = { "#eee8d5", 230 },
	base3 = { "#002b36", 23 },
	orange = { "#cb4b16", 166 },
	base1 = { "#586e75", 102 },
	base0 = { "#657b83", 103 },
	base00 = { "#839496", 145 },
	violet = { "#6c71c4", 104 },
	base01 = { "#93a1a1", 145 },
	base03 = { "#fdf6e3", 231 },
	back = { "#fdf6e3", 231 },
	err_bg = { "#fdf6e3", 231 },
}

-- Helpers

-- Transparent background support (terminal background shows through)
local function termtrans(color)
	if g.solarized_termtrans == 1 then
		return p.none
	end
	return color
end

local function italics()
	return g.solarized_italics == 1 and "italic" or "none"
end

local function color_value(value)
	return value == "none" and "NONE" or value
end

-- Converts a spec like { fg = p.red, bg = p.base02, guisp = p.red, style = "bold,reverse" }
-- into an nvim_set_hl definition.
local function to_definition(spec)
	local def = {}

	if spec.fg then
		def.fg = color_value(spec.fg[1])
		def.ctermfg = color_value(spec.fg[2])
	end
	if spec.bg then
		def.bg = color_value(spec.bg[1])
		def.ctermbg = color_value(spec.bg[2])
	end
	if spec.guisp then
		def.sp = color_value(spec.guisp[1])
	end

	if spec.style then
		local cterm = {}
		for attr in spec.style:gmatch("[^,]+") do
			if attr ~= "none" then
				def[attr] = true
				cterm[attr] = true
			end
		end
		def.cterm = cterm
	end

	return def
end

local function apply(groups)
	for group, spec in pairs(groups) do
		vim.api.nvim_set_hl(0, group, to_definition(spec))
	end
end

local function apply_links(links)
	for group, target in pairs(links) do
		vim.api.nvim_set_hl(0, group, { link = target })
	end
end

local visibility = g.solarized_visibility
local diffmode = g.solarized_diffmode
local statusline_mode = g.solarized_statusline
local it = italics()

-- Highlight groups

-- Editor UI
local editor = {
	-- Base
	Normal = { fg = p.base1, bg = termtrans(p.base03) },
	Terminal = { fg = p.base1, bg = termtrans(p.base03) },
	FoldColumn = { fg = p.base0, bg = termtrans(p.base02) },
	Folded = { fg = p.base0, bg = termtrans(p.base02), guisp = p.base03, style = "bold" },
	LineNr = { fg = p.base01, bg = termtrans(p.base02) },
	ColorColumn = { fg = p.none, bg = p.base02 },
	Conceal = { fg = p.blue },
	CursorColumn = { fg = p.none, bg = p.base02 },
	CursorLine = { fg = p.none, bg = p.base02, guisp = p.base1 },
	Cursor = { fg = p.base03, bg = { "#000000", 16 } },
	CursorIM = { fg = p.none, bg = p.base1 },
	Directory = { fg = p.blue },
	EndOfBuffer = { fg = p.none },
	MatchParen = { fg = p.base3, bg = p.base02, style = "bold" },
	SignColumn = { fg = p.base0 },

	-- Selection and search
	Visual = { fg = p.base01, bg = p.base03, style = "reverse" },
	VisualNOS = { fg = p.none, bg = p.base02, style = "reverse" },
	Search = { fg = p.yellow, style = "reverse" },
	IncSearch = { fg = p.orange, style = "standout" },

	-- Messages
	ErrorMsg = { fg = p.red, bg = p.err_bg, style = "reverse" },
	ModeMsg = { fg = p.blue },
	MoreMsg = { fg = p.blue },
	Question = { fg = p.cyan, style = "bold" },
	WarningMsg = { fg = p.orange, style = "bold" },

	-- Popup menu
	Pmenu = { fg = p.base1, bg = p.base02 },
	PmenuSbar = { fg = p.none, bg = p.base0 },
	PmenuSel = { fg = p.base3, bg = p.base01 },
	PmenuThumb = { fg = p.none, bg = p.base01 },
	WildMenu = { fg = p.base3, bg = p.base02, style = "reverse" },

	-- Toolbar
	ToolbarLine = { fg = p.none, bg = p.base02 },
	ToolbarButton = { fg = p.base1, bg = p.base02, style = "bold" },

	-- Mode indicators (for statusline plugins)
	NormalMode = { fg = p.base0, bg = p.base3, style = "reverse" },
	InsertMode = { fg = p.cyan, bg = p.base3, style = "reverse" },
	ReplaceMode = { fg = p.orange, bg = p.base3, style = "reverse" },
	VisualMode = { fg = p.magenta, bg = p.base3, style = "reverse" },
	CommandMode = { fg = p.magenta, bg = p.base3, style = "reverse" },
}

-- Visibility variants: CursorLineNr, NonText, SpecialKey, Spell*, Title
local visibility_groups = {
	high = {
		CursorLineNr = { fg = p.orange, bg = termtrans(p.base02), style = "bold" },
		NonText = { fg = p.orange, style = "bold" },
		SpecialKey = { fg = p.orange, style = "reverse" },
		SpellBad = { fg = p.violet, bg = p.base3, guisp = p.red, style = "reverse,underline" },
		SpellCap = { fg = p.violet, bg = p.base3, guisp = p.red, style = "reverse,underline" },
		SpellLocal = { fg = p.yellow, bg = p.base3, guisp = p.red, style = "reverse,underline" },
		SpellRare = { fg = p.cyan, bg = p.base3, guisp = p.red, style = "reverse,underline" },
		Title = { fg = p.yellow, style = "bold" },
	},
	low = {
		CursorLineNr = { fg = p.base01, bg = termtrans(p.base02), style = "bold" },
		NonText = { fg = p.base02, style = "bold" },
		SpecialKey = { fg = p.base02, style = "reverse" },
		SpellBad = { fg = p.violet, guisp = p.orange, style = "underline" },
		SpellCap = { fg = p.violet, guisp = p.orange, style = "underline" },
		SpellLocal = { fg = p.yellow, guisp = p.yellow, style = "underline" },
		SpellRare = { fg = p.cyan, guisp = p.cyan, style = "underline" },
		Title = { fg = p.base01, style = "bold" },
	},
	normal = {
		CursorLineNr = { fg = p.base0, bg = termtrans(p.base02), style = "bold" },
		NonText = { fg = p.base00, style = "bold" },
		SpecialKey = { fg = p.base00, bg = p.base02, style = "bold" },
		SpellBad = { fg = p.violet, guisp = p.orange, style = "underline" },
		SpellCap = { fg = p.violet, guisp = p.orange, style = "underline" },
		SpellLocal = { fg = p.yellow, guisp = p.yellow, style = "underline" },
		SpellRare = { fg = p.cyan, guisp = p.cyan, style = "underline" },
		Title = { fg = p.orange, style = "bold" },
	},
}

-- Statusline, tabline and splits
local statusline_groups = {
	low = {
		StatusLine = { fg = p.base01, bg = p.base3, style = "reverse" },
		StatusLineNC = { fg = p.base01, bg = p.base02, style = "reverse" },
		TabLine = { fg = p.base01, bg = p.base02, style = "reverse" },
		TabLineFill = { fg = p.base01, bg = p.base02, style = "reverse" },
		TabLineSel = { fg = p.base0, bg = p.base3, style = "reverse" },
		VertSplit = { fg = p.base01 },
	},
	flat = {
		StatusLine = { fg = p.base02, bg = p.base3, style = "reverse" },
		StatusLineNC = { fg = p.base02, bg = p.base1, style = "reverse" },
		TabLine = { fg = p.base01, bg = p.base02 },
		TabLineFill = { fg = p.base01, bg = p.base02 },
		TabLineSel = { fg = p.base3, bg = p.base02 },
		VertSplit = { fg = p.base02 },
	},
	normal = {
		StatusLine = { fg = p.base0, bg = p.base02, style = "reverse" },
		StatusLineNC = { fg = p.base01, bg = p.base02, style = "reverse" },
		TabLine = { fg = p.base01, bg = p.base02, style = "reverse" },
		TabLineFill = { fg = p.base01, bg = p.base02, style = "reverse" },
		TabLineSel = { fg = p.base0, bg = p.base02, style = "reverse" },
		VertSplit = { fg = p.base01 },
	},
}

-- Diff
local diff_groups = {
	high = {
		DiffAdd = { fg = p.green, style = "reverse" },
		DiffChange = { fg = p.yellow, style = "reverse" },
		DiffDelete = { fg = p.red, style = "reverse" },
		DiffText = { fg = p.blue, style = "reverse" },
	},
	low = {
		DiffAdd = { fg = p.green, guisp = p.green },
		DiffChange = { fg = p.yellow, guisp = p.yellow },
		DiffDelete = { fg = p.red, style = "bold" },
		DiffText = { fg = p.blue, guisp = p.blue },
	},
	normal = {
		DiffAdd = { fg = p.green, bg = p.base02, guisp = p.green },
		DiffChange = { fg = p.yellow, bg = p.base02, guisp = p.yellow },
		DiffDelete = { fg = p.red, bg = p.base02, style = "bold" },
		DiffText = { fg = p.blue, bg = p.base02, guisp = p.blue },
	},
}

-- Vim syntax groups
local syntax = {
	Comment = { fg = p.base00, style = "none" },
	Constant = { fg = p.cyan },
	Error = { fg = p.red, bg = p.err_bg, style = "bold,reverse" },
	Identifier = { fg = p.blue },
	Ignore = { fg = p.none },
	PreProc = { fg = p.orange },
	Special = { fg = p.orange },
	Statement = { fg = p.green },
	Todo = { fg = p.magenta, style = "bold" },
	Type = { fg = p.yellow },
	Underlined = { fg = p.violet },
}

-- Vim script, help and legacy language groups
local languages = {
	-- Vim
	vimCommentString = { fg = p.violet },
	vimCommand = { fg = p.yellow },
	vimCmdSep = { fg = p.blue, style = "bold" },
	vimIsCommand = { fg = p.base00 },
	vimSynMtchOpt = { fg = p.yellow },
	vimSynType = { fg = p.cyan },
	vimHiLink = { fg = p.blue },
	vimHiGroup = { fg = p.blue },
	vimGroup = { fg = p.blue, style = "bold" },

	-- Help
	helpExample = { fg = p.base1 },
	helpOption = { fg = p.cyan },
	helpNote = { fg = p.magenta },
	helpVim = { fg = p.magenta },
	helpHyperTextJump = { fg = p.blue },
	helpHyperTextEntry = { fg = p.green },

	-- Git commit
	gitcommitComment = { fg = p.base01, style = "none" },
	gitcommitUnmerged = { fg = p.green, style = "bold" },
	gitcommitOnBranch = { fg = p.base01, style = "bold" },
	gitcommitBranch = { fg = p.magenta, style = "bold" },
	gitcommitdiscardedtype = { fg = p.red },
	gitcommitselectedtype = { fg = p.green },
	gitcommitHeader = { fg = p.base01 },
	gitcommitUntrackedFile = { fg = p.cyan, style = "bold" },
	gitcommitDiscardedFile = { fg = p.red, style = "bold" },
	gitcommitSelectedFile = { fg = p.green, style = "bold" },
	gitcommitUnmergedFile = { fg = p.yellow, style = "bold" },
	gitcommitFile = { fg = p.base0, style = "bold" },

	-- HTML
	htmlTag = { fg = p.base01 },
	htmlEndTag = { fg = p.base01 },
	htmlTagN = { fg = p.base1, style = "bold" },
	htmlTagName = { fg = p.blue, style = "bold" },
	htmlSpecialTagName = { fg = p.blue, style = it },
	htmlArg = { fg = p.base00 },

	-- JavaScript, Perl, TeX, Ruby, C
	javaScript = { fg = p.yellow },
	perlHereDoc = { fg = p.base1 },
	perlVarPlain = { fg = p.yellow },
	perlStatementFileDesc = { fg = p.cyan },
	texstatement = { fg = p.cyan },
	texmathzonex = { fg = p.yellow },
	texmathmatcher = { fg = p.yellow },
	texreflabel = { fg = p.yellow },
	rubyDefine = { fg = p.base1, style = "bold" },
	rubyBoolean = { fg = p.magenta },
	cPreCondit = { fg = p.orange },

	-- Haskell
	VarId = { fg = p.blue },
	ConId = { fg = p.yellow },
	hsImport = { fg = p.magenta },
	hsString = { fg = p.base00 },
	hsStructure = { fg = p.cyan },
	hs_hlFunctionName = { fg = p.blue },
	hsStatement = { fg = p.cyan },
	hsImportLabel = { fg = p.cyan },
	hs_OpFunctionName = { fg = p.yellow },
	hs_DeclareFunction = { fg = p.orange },
	hsVarSym = { fg = p.cyan },
	hsType = { fg = p.yellow },
	hsTypedef = { fg = p.cyan },
	hsModuleName = { fg = p.green },
	hsNiceOperator = { fg = p.cyan },
	hsniceoperator = { fg = p.cyan },
}

-- Pandoc
local pandoc = {
	-- Title block and metadata
	pandocTitleBlock = { fg = p.blue },
	pandocTitleBlockTitle = { fg = p.blue, style = "bold" },
	pandocTitleComment = { fg = p.blue, style = "bold" },
	pandocComment = { fg = p.base01, style = "none" },
	pandocMetadataDelim = { fg = p.base01 },
	pandocMetadataKey = { fg = p.blue },
	pandocMetadata = { fg = p.blue, style = "bold" },

	-- Blocks
	pandocVerbatimBlock = { fg = p.yellow },
	pandocBlockQuote = { fg = p.blue },
	pandocBlockQuoteLeader1 = { fg = p.blue },
	pandocBlockQuoteLeader2 = { fg = p.cyan },
	pandocBlockQuoteLeader3 = { fg = p.yellow },
	pandocBlockQuoteLeader4 = { fg = p.red },
	pandocBlockQuoteLeader5 = { fg = p.base0 },
	pandocBlockQuoteLeader6 = { fg = p.base01 },
	pandocListMarker = { fg = p.magenta },
	pandocListReference = { fg = p.magenta },
	pandocRule = { fg = p.blue, style = "bold" },
	pandocRuleLine = { fg = p.blue, style = "bold" },
	pandocImageCaption = { fg = p.violet, style = "bold" },

	-- Definitions
	pandocDefinitionBlock = { fg = p.violet },
	pandocDefinitionTerm = { fg = p.violet, style = "standout" },
	pandocDefinitionIndctr = { fg = p.violet, style = "bold" },
	pandocEmphasisDefinition = { fg = p.violet, style = it },
	pandocEmphasisNestedDefinition = { fg = p.violet, style = "bold" },
	pandocStrongEmphasisDefinition = { fg = p.violet, style = "bold" },
	pandocStrongEmphasisNestedDefinition = { fg = p.violet, style = "bold" },
	pandocStrongEmphasisEmphasisDefinition = { fg = p.violet, style = "bold" },
	pandocStrikeoutDefinition = { fg = p.violet, style = "reverse" },
	pandocVerbatimInlineDefinition = { fg = p.violet },
	pandocSuperscriptDefinition = { fg = p.violet },
	pandocSubscriptDefinition = { fg = p.violet },

	-- Tables
	pandocTable = { fg = p.blue },
	pandocTableStructure = { fg = p.blue },
	pandocTableZebraLight = { fg = p.blue, bg = p.base03 },
	pandocTableZebraDark = { fg = p.blue, bg = p.base02 },
	pandocEmphasisTable = { fg = p.blue, style = it },
	pandocEmphasisNestedTable = { fg = p.blue, style = "bold" },
	pandocStrongEmphasisTable = { fg = p.blue, style = "bold" },
	pandocStrongEmphasisNestedTable = { fg = p.blue, style = "bold" },
	pandocStrongEmphasisEmphasisTable = { fg = p.blue, style = "bold" },
	pandocStrikeoutTable = { fg = p.blue, style = "reverse" },
	pandocVerbatimInlineTable = { fg = p.blue },
	pandocSuperscriptTable = { fg = p.blue },
	pandocSubscriptTable = { fg = p.blue },

	-- Headings
	pandocHeading = { fg = p.orange, style = "bold" },
	pandocHeadingMarker = { fg = p.orange, style = "bold" },
	pandocEmphasisHeading = { fg = p.orange, style = "bold" },
	pandocEmphasisNestedHeading = { fg = p.orange, style = "bold" },
	pandocStrongEmphasisHeading = { fg = p.orange, style = "bold" },
	pandocStrongEmphasisNestedHeading = { fg = p.orange, style = "bold" },
	pandocStrongEmphasisEmphasisHeading = { fg = p.orange, style = "bold" },
	pandocStrikeoutHeading = { fg = p.orange, style = "reverse" },
	pandocVerbatimInlineHeading = { fg = p.orange, style = "bold" },
	pandocSuperscriptHeading = { fg = p.orange, style = "bold" },
	pandocSubscriptHeading = { fg = p.orange, style = "bold" },

	-- Links
	pandocLinkDelim = { fg = p.base01 },
	pandocLinkLabel = { fg = p.blue },
	pandocLinkText = { fg = p.blue },
	pandocLinkURL = { fg = p.base00 },
	pandocLinkTitle = { fg = p.base00 },
	pandocLinkTitleDelim = { fg = p.base01, guisp = p.base00 },
	pandocLinkDefinition = { fg = p.cyan, guisp = p.base00 },
	pandocLinkDefinitionID = { fg = p.blue, style = "bold" },

	-- Footnotes and citations
	pandocFootnoteLink = { fg = p.green },
	pandocFootnoteDefLink = { fg = p.green, style = "bold" },
	pandocFootnoteInline = { fg = p.green, style = "bold" },
	pandocFootnote = { fg = p.green },
	pandocCitationDelim = { fg = p.magenta },
	pandocCitation = { fg = p.magenta },
	pandocCitationID = { fg = p.magenta },
	pandocCitationRef = { fg = p.magenta },

	-- Inline styles
	pandocStyleDelim = { fg = p.base01 },
	pandocEmphasis = { fg = p.base0, style = it },
	pandocEmphasisNested = { fg = p.base0, style = "bold" },
	pandocStrongEmphasis = { fg = p.base0, style = "bold" },
	pandocStrongEmphasisNested = { fg = p.base0, style = "bold" },
	pandocStrongEmphasisEmphasis = { fg = p.base0, style = "bold" },
	pandocStrikeout = { fg = p.base01, style = "reverse" },
	pandocVerbatimInline = { fg = p.yellow },
	pandocSuperscript = { fg = p.violet },
	pandocSubscript = { fg = p.violet },
	pandocEscapePair = { fg = p.red, style = "bold" },
	pandocNonBreakingSpace = { fg = p.red, style = "reverse" },
}

-- Treesitter (legacy TS* groups)
local treesitter = {
	TSError = { fg = p.red },
	TSStrong = { fg = p.base1, bg = p.base03, style = "bold" },
	TSVariable = { fg = p.base1 },
}

-- Diagnostics and LSP
local diagnostics = {
	DiagnosticError = { fg = p.red, guisp = p.red, style = "none" },
	DiagnosticWarn = { fg = p.yellow, guisp = p.yellow, style = "none" },
	DiagnosticInfo = { fg = p.cyan, guisp = p.cyan, style = "none" },
	DiagnosticHint = { fg = p.green, guisp = p.green, style = "none" },

	DiagnosticUnderlineError = { fg = p.none, guisp = p.red, style = "underline" },
	DiagnosticUnderlineWarn = { fg = p.none, guisp = p.yellow, style = "underline" },
	DiagnosticUnderlineInfo = { fg = p.none, guisp = p.cyan, style = "underline" },
	DiagnosticUnderlineHint = { fg = p.none, guisp = p.green, style = "underline" },

	LspReferenceRead = { fg = p.none, style = "underline" },
	LspReferenceWrite = { fg = p.none, style = "underline,bold" },
}

-- nvim-cmp
local cmp = {
	CmpDocumentation = { fg = p.base3, bg = p.base03 },
	CmpDocumentationBorder = { fg = p.base3, bg = p.base03 },

	CmpItemAbbr = { fg = p.base2, bg = p.none },
	CmpItemAbbrDeprecated = { fg = p.base0, bg = p.none },
	CmpItemAbbrMatch = { fg = p.base3, bg = p.none },
	CmpItemAbbrMatchFuzzy = { fg = p.base3, bg = p.none },
	CmpItemMenu = { fg = p.base2, bg = p.none },

	CmpItemKindDefault = { fg = p.base2, bg = p.none },
	CmpItemKindKeyword = { fg = p.yellow, bg = p.none },
	CmpItemKindVariable = { fg = p.green, bg = p.none },
	CmpItemKindConstant = { fg = p.base2, bg = p.none },
	CmpItemKindReference = { fg = p.base2, bg = p.none },
	CmpItemKindValue = { fg = p.base2, bg = p.none },
	CmpItemKindFunction = { fg = p.blue, bg = p.none },
	CmpItemKindMethod = { fg = p.blue, bg = p.none },
	CmpItemKindConstructor = { fg = p.blue, bg = p.none },
	CmpItemKindClass = { fg = p.red, bg = p.none },
	CmpItemKindInterface = { fg = p.base2, bg = p.none },
	CmpItemKindStruct = { fg = p.base2, bg = p.none },
	CmpItemKindEvent = { fg = p.base2, bg = p.none },
	CmpItemKindEnum = { fg = p.base2, bg = p.none },
	CmpItemKindUnit = { fg = p.base2, bg = p.none },
	CmpItemKindModule = { fg = p.base2, bg = p.none },
	CmpItemKindProperty = { fg = p.base2, bg = p.none },
	CmpItemKindField = { fg = p.base2, bg = p.none },
	CmpItemKindTypeParameter = { fg = p.base2, bg = p.none },
	CmpItemKindEnumMember = { fg = p.base2, bg = p.none },
	CmpItemKindOperator = { fg = p.base2, bg = p.none },
	CmpItemKindSnippet = { fg = p.orange, bg = p.none },
	CmpItemKindFile = { fg = p.base2, bg = p.none },

	-- nvim-navic (own color, not linked to cmp)
	NavicIconsNull = { fg = p.blue, bg = p.none },
}

-- Links (hi! link)
local links = {
	-- Vim syntax
	Boolean = "Constant",
	Character = "Constant",
	Conditional = "Statement",
	Debug = "Special",
	Define = "PreProc",
	Delimiter = "Special",
	Exception = "Statement",
	Float = "Constant",
	FloatBorder = "VertSplit",
	Function = "Identifier",
	Include = "PreProc",
	Keyword = "Statement",
	Label = "Statement",
	Macro = "PreProc",
	Number = "Constant",
	Operator = "Statement",
	PreCondit = "PreProc",
	QuickFixLine = "Search",
	Repeat = "Statement",
	SpecialChar = "Special",
	SpecialComment = "Special",
	StatusLineTerm = "StatusLine",
	StatusLineTermNC = "StatusLineNC",
	StorageClass = "Type",
	String = "Constant",
	Structure = "Type",
	Tag = "Special",
	Typedef = "Type",
	lCursor = "Cursor",

	-- Vim script, help, diff, git commit
	vimVar = "Identifier",
	vimFunc = "Function",
	vimUserFunc = "Function",
	vimSet = "Normal",
	vimSetEqual = "Normal",
	helpSpecial = "Special",
	diffAdded = "Statement",
	diffLine = "Identifier",
	gitcommitUntracked = "gitcommitComment",
	gitcommitDiscarded = "gitcommitComment",
	gitcommitSelected = "gitcommitComment",
	gitcommitNoBranch = "gitcommitBranch",
	gitcommitDiscardedArrow = "gitcommitDiscardedFile",
	gitcommitSelectedArrow = "gitcommitSelectedFile",
	gitcommitUnmergedArrow = "gitcommitUnmergedFile",

	-- Other languages
	jsFuncCall = "Function",
	rubySymbol = "String",
	hsImportParams = "Delimiter",
	hsDelimTypeExport = "Delimiter",
	hsModuleStartLabel = "hsStructure",
	hsModuleWhereLabel = "hsModuleStartLabel",

	-- Pandoc
	pandocVerbatimBlockDeep = "pandocVerbatimBlock",
	pandocCodeBlock = "pandocVerbatimBlock",
	pandocCodeBlockDelim = "pandocVerbatimBlock",
	pandocTableStructureTop = "pandocTableStructure",
	pandocTableStructureEnd = "pandocTableStructure",
	pandocEscapedCharacter = "pandocEscapePair",
	pandocLineBreak = "pandocEscapePair",
	pandocMetadataTitle = "pandocMetadata",

	-- Treesitter (legacy TS* groups)
	TSBoolean = "Constant",
	TSCharacter = "Constant",
	TSComment = "Comment",
	TSConditional = "Conditional",
	TSConstant = "Constant",
	TSConstBuiltin = "Constant",
	TSConstMacro = "Constant",
	TSException = "Exception",
	TSField = "Identifier",
	TSFloat = "Float",
	TSFunction = "Function",
	TSFuncBuiltin = "Function",
	TSFuncMacro = "Function",
	TSInclude = "Include",
	TSKeyword = "Keyword",
	TSLabel = "Label",
	TSMethod = "Function",
	TSNamespace = "Identifier",
	TSNumber = "Constant",
	TSOperator = "Operator",
	TSParameterReference = "Identifier",
	TSProperty = "TSField",
	TSPunctDelimiter = "Delimiter",
	TSPunctBracket = "Delimiter",
	TSPunctSpecial = "Special",
	TSRepeat = "Repeat",
	TSString = "Constant",
	TSStringRegex = "Constant",
	TSStringEscape = "Constant",
	TSConstructor = "Function",
	TSKeywordFunction = "Identifier",
	TSLiteral = "Normal",
	TSParameter = "Identifier",
	TSVariableBuiltin = "Identifier",
	TSTag = "Special",
	TSTagDelimiter = "Delimiter",
	TSTitle = "Title",
	TSType = "Type",
	TSTypeBuiltin = "Type",

	-- LSP
	LspReferenceText = "LspReferenceRead",
	LspSagaFinderSelection = "Search",
	TargetWord = "Title",

	-- Git signs (gitsigns.nvim legacy names and vgit)
	GitSignsAdd = "DiffAdd",
	GitSignsChange = "DiffChange",
	GitSignsDelete = "DiffDelete",
	VGitSignAdd = "DiffAdd",
	VGitSignChange = "DiffChange",
	VGitSignRemove = "DiffDelete",

	-- nvim-navic
	NavicIconsFile = "CmpItemKindFile",
	NavicIconsModule = "CmpItemKindModule",
	NavicIconsNamespace = "CmpItemKindModule",
	NavicIconsPackage = "CmpItemKindModule",
	NavicIconsClass = "CmpItemKindClass",
	NavicIconsMethod = "CmpItemKindMethod",
	NavicIconsProperty = "CmpItemKindProperty",
	NavicIconsField = "CmpItemKindField",
	NavicIconsConstructor = "CmpItemKindConstructor",
	NavicIconsEnum = "CmpItemKindEnum",
	NavicIconsInterface = "CmpItemKindInterface",
	NavicIconsFunction = "CmpItemKindFunction",
	NavicIconsVariable = "CmpItemKindVariable",
	NavicIconsConstant = "CmpItemKindConstant",
	NavicIconsString = "String",
	NavicIconsNumber = "Number",
	NavicIconsBoolean = "Boolean",
	NavicIconsArray = "CmpItemKindClass",
	NavicIconsObject = "CmpItemKindClass",
	NavicIconsKey = "CmpItemKindKeyword",
	NavicIconsKeyword = "CmpItemKindKeyword",
	NavicIconsEnumMember = "CmpItemKindEnumMember",
	NavicIconsStruct = "CmpItemKindStruct",
	NavicIconsEvent = "CmpItemKindEvent",
	NavicIconsOperator = "CmpItemKindOperator",
	NavicIconsTypeParameter = "CmpItemKindTypeParameter",
	NavicText = "LineNr",
	NavicSeparator = "Comment",
}

-- Terminal colors

local function terminal_colors()
	g.terminal_color_0 = p.base02[1]
	g.terminal_color_1 = p.red[1]
	g.terminal_color_2 = p.green[1]
	g.terminal_color_3 = p.yellow[1]
	g.terminal_color_4 = p.blue[1]
	g.terminal_color_5 = p.magenta[1]
	g.terminal_color_6 = p.cyan[1]
	g.terminal_color_7 = p.base2[1]
	g.terminal_color_8 = p.base03[1]
	g.terminal_color_9 = p.orange[1]
	g.terminal_color_10 = p.base01[1]
	g.terminal_color_11 = p.base00[1]
	g.terminal_color_12 = p.base0[1]
	g.terminal_color_13 = p.violet[1]
	g.terminal_color_14 = p.base1[1]
	g.terminal_color_15 = p.base3[1]
end

-- Apply
-- Concrete groups first, links last so every target already exists.

apply(editor)
apply(visibility_groups[visibility] or visibility_groups.normal)
apply(statusline_groups[statusline_mode] or statusline_groups.normal)
apply(diff_groups[diffmode] or diff_groups.normal)
apply(syntax)
apply(languages)
apply(pandoc)
apply(treesitter)
apply(diagnostics)
apply(cmp)
apply_links(links)

terminal_colors()
