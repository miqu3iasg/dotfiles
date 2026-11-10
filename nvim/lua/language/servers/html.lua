-- lua/language/servers/html.lua

-- HTML through the VS Code HTML language service. The nvim-lspconfig defaults
-- cover the command and the root markers, so only the filetypes are widened to
-- templ and PHP. Formatting belongs to prettier through conform, so the server
-- is told not to provide its own formatter.
--
-- The server is installed through Mason:
--
-- :MasonInstall html-lsp
--
-- See: lua/plugins/formatting.lua
-- See: https://github.com/microsoft/vscode-html-languageservice

---@type UserLspServerModule
return {
	config = {
		init_options = { provideFormatter = false },
		filetypes = { "templ", "html", "php" },
	},
}
