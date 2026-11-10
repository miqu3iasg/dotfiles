-- lua/lsp/servers/pyright.lua

-- Python through pyright. The server provides types, navigation, hover and
-- completion, with type checking kept on `basic` and diagnostics limited to
-- open files, which keeps memory usage low on large projects. Formatting stays
-- with conform, which runs ruff.
--
-- :MasonInstall pyright
--
-- See: lua/plugins/formatting.lua
-- See: https://github.com/microsoft/pyright

return {
	config = {
		settings = {
			python = {
				analysis = {
					typeCheckingMode = "basic",
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
					diagnosticMode = "openFilesOnly",
				},
			},
		},
	},
}
