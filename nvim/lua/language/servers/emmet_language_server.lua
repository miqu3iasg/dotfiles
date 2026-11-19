-- lua/language/servers/emmet_language_server.lua

-- Emmet expansion for HTML, CSS and markup templates, with templ and PHP
-- added to the filetypes the server gets.
--
-- Formatting stays with prettier through conform.
--
-- emmet-language-server comes from Mason.
--
-- :MasonInstall emmet-language-server
--
-- See: lua/plugins/formatting.lua
-- See: https://github.com/olegtsaplin/emmet_language_server

---@type UserLspServerModule
return {
	config = {
		filetypes = { "templ", "html", "css", "scss", "php", "javascriptreact", "typescriptreact" },
	},
}
