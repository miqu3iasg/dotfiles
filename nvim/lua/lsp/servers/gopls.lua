-- lua/lsp/servers/gopls.lua

-- Go through gopls. The nvim-lspconfig defaults cover the command, the
-- filetypes and the root markers, which search for `go.work` and `go.mod`. The
-- staticcheck suite and the unused analyses run along the build and vet
-- diagnostics, and code lenses expose the `go generate` and `go build -gcflags`
-- entry points inside the buffer. Formatting stays with conform, which runs
-- goimports-reviser and golines.
--
-- :MasonInstall gopls
--
-- See: lua/plugins/formatting.lua
-- See: https://github.com/golang/tools/tree/master/gopls

---@type UserLspServerModule
return {
	config = {
		settings = {
			gopls = {
				analyses = {
					staticcheck = true,
					unusedparams = true,
					unusedwrite = true,
				},
				codelenses = {
					generate = true,
					gc_details = true,
					tidy = true,
					upgrade_dependency = true,
				},
			},
		},
	},
}
