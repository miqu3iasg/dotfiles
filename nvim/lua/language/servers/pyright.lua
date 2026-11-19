-- lua/language/servers/pyright.lua

-- Python through pyright, on `standard` type checking limited to open files,
-- with auto-import completion and inlay hints; formatting stays with conform.
--
-- pyright comes from Mason.
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
