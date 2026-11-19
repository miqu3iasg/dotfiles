-- lua/plugins/unnecessary-shit.lua

-- Plugins installed instead of actually coding, a dumping ground for small
-- conveniences nobody needs but I refuse to live without.
--
-- Everything here must already be installed, so `lua/config/pack.lua` must run
-- first, and the tmux navigation needs the matching tmux plugin.
--
-- See: lua/config/pack.lua

local ai = require("mini.ai")
local ts = ai.gen_spec.treesitter

require("mini.align").setup({})

-- The treesitter-based objects need the textobjects queries to exist, or they
-- silently select nothing.
-- See: lua/plugins/treesitter.lua
local ai_opts = {
	n_lines = 500,
	custom_textobjects = {
		c = ts({ a = "@class.outer", i = "@class.inner" }),
		a = ts({ a = "@parameter.outer", i = "@parameter.inner" }),
		k = ts({ a = "@code_block.outer", i = "@code_block.inner" }),
		m = ts({ a = "@comment.outer", i = "@comment.inner" }),

		-- The whole buffer, because selecting everything by hand is for peasants.
		e = function()
			return {
				from = { line = 1, col = 1 },
				to = {
					line = vim.fn.line("$"),
					col = math.max(vim.fn.getline("$"):len(), 1),
				},
			}
		end,
	},
}
ai.setup(ai_opts)

vim.keymap.set("n", "<c-h>", "<cmd>TmuxNavigateLeft<cr>")
vim.keymap.set("n", "<c-j>", "<cmd>TmuxNavigateDown<cr>")
vim.keymap.set("n", "<c-k>", "<cmd>TmuxNavigateUp<cr>")
vim.keymap.set("n", "<c-l>", "<cmd>TmuxNavigateRight<cr>")
vim.keymap.set("n", "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>")

-- The LSP color provider fights with this plugin, so it loses.
if vim.lsp.document_color then
	vim.lsp.document_color.enable(false)
end

require("colorizer").setup({
	filetypes = {
		"css",
		"scss",
		"lua",
		"vue",
		"svelte",
		"astro",
		"html",
		"javascript",
		"javascriptreact",
		"typescript",
		"typescriptreact",
	},
	-- Color names and Tailwind classes turn every buffer into a circus.
	user_default_options = {
		names = false,
		tailwind = false,
	},
})

local flash = require("flash")
-- The backdrop is off because dimming the whole screen just to jump two words
-- is dramatic and unnecessary.
flash.setup({
	prompt = {
		prefix = { { ">", "FlashPromptIcon" } },
	},
	highlight = {
		backdrop = false,
	},
	modes = {
		char = {
			highlight = {
				backdrop = false,
			},
		},
	},
})

vim.keymap.set({ "n", "x", "o" }, "s", function()
	flash.jump()
end, { desc = "Flash" })

vim.keymap.set({ "n", "x", "o" }, "S", function()
	flash.treesitter()
end, { desc = "Flash Treesitter" })

vim.keymap.set("o", "r", function()
	flash.remote()
end, { desc = "Remote Flash" })

vim.keymap.set({ "o", "x" }, "R", function()
	flash.treesitter_search()
end, { desc = "Treesitter Search" })

vim.keymap.set("c", "<c-s>", function()
	flash.toggle()
end, { desc = "Toggle Flash Search" })
