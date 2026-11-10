-- lua/lsp/servers/lua_ls.lua

-- Lua through lua-language-server. Its main purpose is to support the Neovim
-- configuration itself, so the Neovim API types and annotations reach the
-- server through lazydev.nvim, and `vim` is a known global. The workspace
-- library setup belongs to lazydev.
--
-- :MasonInstall lua-language-server
--
-- See: lua/lsp/init.lua
-- See: https://github.com/LuaLS/lua-language-server
-- See: https://github.com/folke/lazydev.nvim

return {
	config = {
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				diagnostics = { globals = { "vim" } },
				workspace = { checkThirdParty = false },
			},
		},
	},
}
