-- lua/lsp/servers/cssls.lua

-- CSS, SCSS and LESS through the VS Code CSS language service. Validation only
-- produces diagnostics, so it is disabled. Formatting stays with prettier
-- through conform, and the `provideFormatter` init option tells the server not
-- to offer its own.
--
-- The server is installed through Mason:
--
-- :MasonInstall css-lsp
--
-- See: lua/plugins/formatting.lua
-- See: https://github.com/microsoft/vscode-css-languageservice

---@type UserLspServerModule
return {
	config = {
		-- The server-side formatter stays off, so the formatter from conform is
		-- the only one used.
		init_options = { provideFormatter = false },
		settings = {
			css = { validate = false },
			scss = { validate = false },
			less = { validate = false },
		},
	},
}
