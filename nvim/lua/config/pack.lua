-- lua/config/pack.lua

-- Declares and installs the eager plugins through `vim.pack`. Lazy plugins
-- register themselves from `lua/plugins/` through `lib.lazy`.
--
-- `PackChanged` must exist before `vim.pack.add` to run the post-install steps.
--
-- See: lua/lib/lazy.lua
-- See: lua/config/keymaps/pack.lua
-- See: https://fredrikaverpil.github.io/blog/2026/04/15/from-lazy.nvim-to-vim.pack/

vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		local name, kind = ev.data.spec.name, ev.data.kind
		if kind ~= "install" and kind ~= "update" then
			return
		end

		if name == "nvim-treesitter" then
			if not ev.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end

		if name == "LuaSnip" then
			local res = vim.system({ "make", "install_jsregexp" }, { cwd = ev.data.path }):wait()
			if res.code ~= 0 then
				vim.notify("LuaSnip: make install_jsregexp failed:\n" .. (res.stderr or ""), vim.log.levels.WARN)
			end
		end
	end,
})

vim.pack.add({
	-- File explorer that edits the filesystem as a buffer. Fork of oil.nvim.
	{ src = "https://forge.barrettruth.com/barrettruth/canola.nvim" },

	-- Parser management, syntax highlighting and indentation based on Tree-sitter.
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		version = "main",
	},

	-- Syntax-aware text objects and motions, such as functions, classes and parameters.
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
		version = "main",
	},

	-- Note-taking workflow for Obsidian vaults.
	{ src = "https://github.com/obsidian-nvim/obsidian.nvim" },

	-- Lua utility library for async, paths and jobs. Required by obsidian.nvim.
	{ src = "https://github.com/nvim-lua/plenary.nvim" },

	-- Snippet engine written in Lua, with support for dynamic and LSP-style snippets.
	{
		src = "https://github.com/L3MON4D3/LuaSnip",
		version = vim.version.range("2.*"),
	},

	-- Formatter runner for external formatters such as stylua and prettier.
	{ src = "https://github.com/stevearc/conform.nvim" },

	-- Asynchronous linter runner for external linters such as ruff.
	{ src = "https://github.com/mfussenegger/nvim-lint" },

	-- Git wrapper for staging, committing, diffing and blaming.
	{ src = "https://github.com/tpope/vim-fugitive" },

	-- Opens the current file, selection or line on GitHub in the browser.
	{ src = "https://github.com/tpope/vim-rhubarb" },

	-- Git change markers in the buffer, with hunk staging, preview and blame.
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },

	-- Package manager for language servers, formatters, linters and debuggers.
	{ src = "https://github.com/mason-org/mason.nvim" },

	-- Bridges mason.nvim and nvim-lspconfig and installs language servers.
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },

	-- Gives lua_ls the types and annotations of the Neovim API and plugins.
	{ src = "https://github.com/folke/lazydev.nvim" },

	-- Default configurations for Neovim's built-in LSP client, used for the frontend servers.
	{ src = "https://github.com/neovim/nvim-lspconfig" },

	-- Small independent modules, such as align and treesitter textobjects for
	-- mini.ai.
	{ src = "https://github.com/nvim-mini/mini.nvim" },

	-- Navigation between Neovim splits and tmux panes with the same keybindings.
	{ src = "https://github.com/christoomey/vim-tmux-navigator" },

	-- Highlights color codes such as hex and rgb with their actual color.
	{ src = "https://github.com/catgoose/nvim-colorizer.lua" },

	-- Java client for the Eclipse JDT language server.
	{ src = "https://github.com/mfussenegger/nvim-jdtls" },

	-- Detects tabs or spaces and the indentation width of each file.
	{ src = "https://github.com/tpope/vim-sleuth" },

	-- Pastes images from the clipboard into files and inserts the link.
	{ src = "https://github.com/HakonHarnes/img-clip.nvim" },

	-- Label-based navigation that jumps to any visible match, with Tree-sitter selection.
	{ src = "https://github.com/folke/flash.nvim" },

	-- Render markdown notes in the browser, needed to read documentations with mermaid diagrams.
	{ src = "https://github.com/iamcco/markdown-preview.nvim" },
})
