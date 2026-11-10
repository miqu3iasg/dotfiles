-- lua/language/servers/pyright.lua

-- Python through pyright. The server provides types, navigation, hover,
-- completion with auto-import and inlay hints for variable and function return
-- types. Type checking runs on `standard`, with diagnostics limited to open
-- files, which keeps memory usage low on large projects. Formatting stays with
-- conform, which runs ruff.
--
-- :MasonInstall pyright
--
-- See: lua/plugins/formatting.lua
-- See: https://github.com/microsoft/pyright

---@type UserLspServerModule
return {
	config = {
		settings = {
			python = {
				analysis = {
					typeCheckingMode = "standard",
					autoImportCompletions = true,
					autoSearchPaths = true,
					useLibraryCodeForTypes = true,
					diagnosticMode = "openFilesOnly",
					inlayHints = {
						functionReturnTypes = true,
						variableTypes = true,
					},
				},
			},
		},
	},
}
