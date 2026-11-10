-- lua/lsp/servers/html.lua

-- HTML through the VS Code HTML language service. The nvim-lspconfig defaults
-- cover the command and the root markers, so only the filetypes are widened to
-- templ and PHP. Formatting belongs to prettier through conform.
--
-- The server is installed through Mason:
--
-- :MasonInstall html-lsp
--
-- See: lua/plugins/formatting.lua
-- See: https://github.com/microsoft/vscode-html-languageservice

return {
	config = {
		filetypes = { "templ", "html", "php" },
	},
}
