-- lua/plugins/treesitter.lua

-- Tree-sitter highlighting and parser installation for the languages the
-- config uses. Several features depend on the parser being installed.
--
-- The CLI compiles the parsers, and `ts.install()` requests them at startup.
--
-- $ sudo pacman -S tree-sitter-cli
--
-- See: lua/plugins/completions.lua
-- See: https://github.com/nvim-treesitter/nvim-treesitter
-- See: :help vim.treesitter

vim.env.PYTHONIOENCODING = "utf-8"

local ts = require("nvim-treesitter")

ts.install({
	"vimdoc",
	"c",
	"lua",
	"python",
	"html",
	"css",
	"scss",
	"java",
	"javadoc",
	"javascript",
	"typescript",
	"tsx",
	"jsdoc",
	"regex",
	"sql",
	"markdown",
	"markdown_inline",
	"bash",
	"yaml",
	"json",
	"toml",
	"dockerfile",
	"luadoc",
	-- Lisp family (used by lua/plugins/lisp.lua and conjure)
	"scheme",
	"commonlisp",
	"racket",
}, {
	max_jobs = 4,
})

local group = vim.api.nvim_create_augroup("TreesitterSetup", { clear = true })

-- Enable Tree-sitter highlighting when a buffer's filetype is detected.
vim.api.nvim_create_autocmd("FileType", {
	group = group,
	desc = "Enable treesitter highlighting and indentation",
	---@param event { match: string, buf: integer }
	callback = function(event)
		local lang = vim.treesitter.language.get_lang(event.match) or event.match
		local buf = event.buf

		-- Start highlighting immediately if the parser is available.
		pcall(vim.treesitter.start, buf, lang)

		-- Enable Tree-sitter indentation only for languages where it has
		-- been verified to behave correctly.
		local good_ts_indent = { lua = true, python = true, javascript = true, typescript = true }
		if good_ts_indent[lang] then
			vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end
	end,
})
