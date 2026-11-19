-- lua/language/servers/cssls.lua

-- CSS, SCSS and LESS through the VS Code CSS language service, with its
-- validation off and its formatter delegated to conform.
--
-- css-lsp comes from Mason.
--
-- :MasonInstall css-lsp
--
-- See: lua/plugins/formatting.lua
-- See: https://github.com/microsoft/vscode-css-languageservice

---@type UserLspServerModule
return {
	config = {
		-- Keeps conform as the only formatter.
		init_options = { provideFormatter = false },
		settings = {
			css = { validate = false },
			scss = { validate = false },
			less = { validate = false },
		},
	},
}
