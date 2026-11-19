-- lua/language/servers/lua_ls.lua

-- Lua through lua-language-server, kept mainly to type the config itself, with
-- lazydev adding the Neovim runtime types; formatting stays with conform.
--
-- lua-language-server comes from Mason.
--
-- :MasonInstall lua-language-server
--
-- See: lua/plugins/formatting.lua
-- See: https://github.com/LuaLS/lua-language-server
-- See: https://github.com/folke/lazydev.nvim

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
					-- Mixing require and dofile is normal in small scripts.
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
