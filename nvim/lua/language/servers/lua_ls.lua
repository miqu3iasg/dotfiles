-- lua/language/servers/lua_ls.lua

-- Lua through lua-language-server. Its main purpose is to support the Neovim
-- configuration itself, so lazydev.nvim is set up in this file: the library
-- paths and word triggers only matter to Lua buffers. The server keeps the
-- formatter off, because stylua runs through conform, and completes whole
-- function calls, so arguments land ready for editing.
--
-- :MasonInstall lua-language-server
--
-- See: lua/plugins/formatting.lua
-- See: https://github.com/LuaLS/lua-language-server
-- See: https://github.com/folke/lazydev.nvim

-- Provides the Neovim runtime types and API annotations to Lua files.
require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
		{ path = "${3rd}/love2d/library", words = { "love%." } },
	},
})

---@type UserLspServerModule
return {
	config = {
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				diagnostics = {
					globals = { "vim" },
					-- Mixing require and dofile to load the same module is normal
					-- in small scripts, so the warning stays off.
					disable = { "different-requires" },
				},
				completion = {
					callSnippet = "Replace",
					keywordSnippet = "Both",
				},
				workspace = {
					checkThirdParty = false,
				},
			},
		},
	},
}
