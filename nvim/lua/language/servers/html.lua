-- lua/language/servers/html.lua

-- HTML through the VS Code HTML language service, with templ and PHP added to
-- the filetypes and its formatter delegated to conform.
--
-- html-lsp comes from Mason.
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
