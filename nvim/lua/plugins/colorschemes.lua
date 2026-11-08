-- lua/plugins/colorschemes.lua

-- Configures the extra colorschemes and the highlight overrides applied on top
-- of them. This file only configures them, and a theme is applied with
-- `:colorscheme`.
--
-- The plugins must already be installed, so `lua/config/pack.lua` must run
-- before this file.
--
-- See: lua/config/pack.lua
-- See: colors/

---Palette for the black-metal overrides, keyed by role in the scheme.
---@type table<string, string>
local black_metal_palette = {
	line = "#111111",
	bright = "#ffffff",
	fg = "#e2e2e2",
	mid = "#9e9e9e",
	comment = "#636262",
	teal = "#5f8787",
}

-- See: https://github.com/metalelf0/black-metal-theme-neovim
require("black-metal").setup({
	transparent = true,
	-- Set to false for the light variants.
	trve = true,

	colors = {},

	highlights = {
		StatusLine = { fg = "#a8a8a8", bg = "#121212" },
		StatusLineNC = { fg = "#5f5f5f", bg = "#050505" },
		Search = { fg = "#D6C17A", bg = "#3D3525" },
		CurSearch = { fg = "#3D3525", bg = "#D6C17A", fmt = "bold" },
		IncSearch = { fg = "#3D3525", bg = "#D6C17A", fmt = "bold" },

		["@markup.strong"] = { fg = black_metal_palette.bright, fmt = "bold" },
		["@markup.italic"] = { fg = black_metal_palette.fg, fmt = "italic" },
		["@markup.strikethrough"] = { fg = black_metal_palette.comment, fmt = "strikethrough" },
		["@markup.link"] = { fg = black_metal_palette.bright, fmt = "underline" },
		["@markup.link.label"] = { fg = black_metal_palette.bright },
		["@markup.link.url"] = { fg = black_metal_palette.teal, fmt = "underline" },
		["@markup.list"] = { fg = black_metal_palette.teal },
		["@markup.math"] = { fg = black_metal_palette.bright },
		["@conceal"] = { fg = black_metal_palette.comment },

		["@markup.list.markdown"] = { fg = black_metal_palette.teal, fmt = "bold" },
		["@markup.raw.delimiter.markdown"] = { fg = black_metal_palette.teal },
		["@label.markdown"] = { fg = black_metal_palette.teal, fmt = "italic" },
		["@markup.math.markdown_inline"] = { fg = black_metal_palette.teal, fmt = "italic" },
		["@markup.math.latex"] = { fg = black_metal_palette.teal, fmt = "italic" },

		["@markup.italic.markdown_inline"] = { fg = black_metal_palette.mid, fmt = "italic" },
		["@punctuation.special.markdown_inline"] = { fg = black_metal_palette.bright },
		["@markup.link.markdown_inline"] = { fg = black_metal_palette.comment },
		["@markup.link.label.markdown_inline"] = {
			fg = black_metal_palette.bright,
			bg = black_metal_palette.line,
			fmt = "underline",
		},

		["@markup.heading"] = { fg = black_metal_palette.bright, fmt = "bold" },
		["@markup.heading.marker.markdown"] = { fg = black_metal_palette.bright, underline = false },
		["@markup.heading.1.markdown"] = { fg = black_metal_palette.bright, fmt = "bold" },
		["@markup.heading.2.markdown"] = { fg = black_metal_palette.bright, fmt = "bold" },
		["@markup.heading.3.markdown"] = { fg = black_metal_palette.fg, fmt = "bold" },
		["@markup.heading.4.markdown"] = { fg = black_metal_palette.fg, fmt = "bold" },
		["@markup.heading.5.markdown"] = { fg = black_metal_palette.mid, fmt = "bold" },
		["@markup.heading.6.markdown"] = { fg = black_metal_palette.mid, fmt = "bold" },
	},
})

-- See: https://github.com/kryptamine/gruber-darker-renaissance
require("gruber-darker-renaissance").setup({
	bold = true,
	italic = {
		strings = false,
		comments = false,
		operators = false,
		folds = false,
	},
	undercurl = false,
	underline = false,
	-- Leaves the window background to the terminal. Floating windows stay opaque.
	transparent = true,
	terminal_colors = true,
	-- Filetypes that get the darker sidebar background.
	sidebars = { "qf", "help" },
	-- Every integration is on. Set one to false to turn it off, such as `snacks = false`.
	plugins = {},
	on_colors = function(c)
		c.syntax.func = "#b0b0b0"
	end,
	on_highlights = function(hl, c)
		hl.Underlined = { fg = "#b0b0b0", underline = false }
		hl.Directory = { fg = "#b0b0b0" }
		hl["@string.special.url"] = { fg = "#b0b0b0" }
	end,
})
