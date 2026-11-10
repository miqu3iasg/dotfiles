-- lua/lsp/servers/gopls.lua

-- Go through gopls. The nvim-lspconfig defaults cover the command, the
-- filetypes and the root markers, which search for `go.work` and `go.mod`. The
-- staticcheck analyses are enabled on top of the build and vet diagnostics.
-- Formatting stays with conform, which runs goimports-reviser and golines.
--
-- :MasonInstall gopls
--
-- See: lua/plugins/formatting.lua
-- See: https://github.com/golang/tools/tree/master/gopls

return {
	config = {
		settings = {
			gopls = {
				analyses = {
					unusedparams = true,
					staticcheck = true,
				},
			},
		},
	},
}
