-- lua/config/pack.lua

-- Declares and installs the eager plugins through Neovim's built-in package
-- manager (`vim.pack`). Lazy plugins are not declared here, since each one
-- registers itself from its own file in `lua/plugins/` through `utils.lazy`.
--
-- The `PackChanged` autocmd must be created before `vim.pack.add`, because it
-- runs the post-install steps that some plugins need: `:TSUpdate` for
-- nvim-treesitter and `make install_jsregexp` for LuaSnip, which requires
-- `make` and a C compiler and only warns on failure. A plugin that needs a
-- build step must be handled there.
--
-- Plugins are only installed and loaded here. Their configuration lives in
-- `lua/plugins/`, which must run after this file. To update every plugin, run:
--
-- :lua vim.pack.update()
--
-- See: lua/utils/lazy.lua
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
	-- canola.nvim
	-- File explorer that edits the filesystem as a buffer. Fork of oil.nvim.
	{ src = "https://forge.barrettruth.com/barrettruth/canola.nvim" },

	-- nvim-treesitter
	-- Parser management, syntax highlighting and indentation based on Tree-sitter.
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		version = "main",
	},

	-- nvim-treesitter-textobjects
	-- Syntax-aware text objects and motions, such as functions, classes and parameters.
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
		version = "main",
	},

	-- obsidian.nvim
	-- Note-taking workflow for Obsidian vaults.
	{ src = "https://github.com/obsidian-nvim/obsidian.nvim" },

	-- plenary.nvim
	-- Lua utility library for async, paths and jobs. Required by obsidian.nvim.
	{ src = "https://github.com/nvim-lua/plenary.nvim" },

	-- LuaSnip
	-- Snippet engine written in Lua, with support for dynamic and LSP-style snippets.
	{
		src = "https://github.com/L3MON4D3/LuaSnip",
		version = vim.version.range("2.*"),
	},

	-- conform.nvim
	-- Formatter runner for external formatters such as stylua and prettier.
	{ src = "https://github.com/stevearc/conform.nvim" },

	-- fzf-lua
	-- Fuzzy finder for files, grep, buffers and LSP results, powered by fzf.
	{ src = "https://github.com/ibhagwan/fzf-lua" },

	-- vim-fugitive
	-- Git wrapper for staging, committing, diffing and blaming.
	{ src = "https://github.com/tpope/vim-fugitive" },

	-- vim-rhubarb
	-- Opens the current file, selection or line on GitHub in the browser.
	{ src = "https://github.com/tpope/vim-rhubarb" },

	-- gitsigns.nvim
	-- Git change markers in the buffer, with hunk staging, preview and blame.
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },

	-- mason.nvim
	-- Package manager for language servers, formatters, linters and debuggers.
	{ src = "https://github.com/mason-org/mason.nvim" },

	-- mason-lspconfig.nvim
	-- Bridges mason.nvim and nvim-lspconfig and installs language servers.
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },

	-- lazydev.nvim
	-- Gives lua_ls the types and annotations of the Neovim API and plugins.
	{ src = "https://github.com/folke/lazydev.nvim" },

	-- nvim-lspconfig
	-- Default configurations for Neovim's built-in LSP client, used for the frontend servers.
	{ src = "https://github.com/neovim/nvim-lspconfig" },

	-- mini.nvim
	-- Library of small independent modules, such as surround, pairs and icons.
	{ src = "https://github.com/nvim-mini/mini.nvim" },

	-- vim-tmux-navigator
	-- Navigation between Neovim splits and tmux panes with the same keybindings.
	{ src = "https://github.com/christoomey/vim-tmux-navigator" },

	-- nvim-colorizer.lua
	-- Highlights color codes such as hex and rgb with their actual color.
	{ src = "https://github.com/catgoose/nvim-colorizer.lua" },

	-- mason-tool-installer.nvim
	-- Installs and updates a declared list of Mason tools.
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },

	-- nvim-jdtls
	-- Java client for the Eclipse JDT language server.
	{ src = "https://github.com/mfussenegger/nvim-jdtls" },

	-- vim-sleuth
	-- Detects tabs or spaces and the indentation width of each file.
	{ src = "https://github.com/tpope/vim-sleuth" },

	-- img-clip.nvim
	-- Pastes images from the clipboard into files and inserts the link.
	{ src = "https://github.com/HakonHarnes/img-clip.nvim" },

	-- flash.nvim
	-- Label-based navigation that jumps to any visible match, with Tree-sitter selection.
	{ src = "https://github.com/folke/flash.nvim" },

	-- Extra colorschemes, configured in lua/plugins/colorschemes.lua.
	"https://github.com/jaredgorski/fogbell.vim",
	"https://github.com/amedoeyes/eyes.nvim",
	"https://github.com/metalelf0/black-metal-theme-neovim",
	"https://github.com/kryptamine/gruber-darker-renaissance",
})
