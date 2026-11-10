-- lua/language/servers/emmet_language_server.lua

-- Emmet expansion for HTML, CSS and markup-based templates, taken over from the
-- nvim-lspconfig defaults so that templ and PHP buffers get the abbreviations
-- too. Formatting belongs to prettier through conform.
--
-- The server is installed through Mason:
--
-- :MasonInstall emmet-language-server
--
-- See: https://github.com/olegtsaplin/emmet_language_server

---@type UserLspServerModule
return {
	config = {
		filetypes = { "templ", "html", "css", "scss", "php", "javascriptreact", "typescriptreact" },
	},
}
