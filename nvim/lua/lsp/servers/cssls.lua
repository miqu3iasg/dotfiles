-- lua/lsp/servers/cssls.lua

-- CSS, SCSS and LESS through the VS Code CSS language service. Validation only
-- produces diagnostics, so it is disabled.
--
-- The server is installed through Mason:
--
-- :MasonInstall css-lsp
--
-- See: lua/plugins/formatting.lua
-- See: https://github.com/microsoft/vscode-css-languageservice

return {
	config = {
		settings = {
			css = { validate = false },
			scss = { validate = false },
			less = { validate = false },
		},
	},
}
