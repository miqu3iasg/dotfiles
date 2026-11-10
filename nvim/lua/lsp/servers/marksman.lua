-- lua/lsp/servers/marksman.lua

-- Markdown through marksman, used for note-taking together with obsidian.nvim.
-- Any folder with a README is a workspace, falling back to the file's
-- directory.
--
-- :MasonInstall marksman
--
-- See: lua/plugins/markdown.lua
-- See: https://github.com/artempyanykh/marksman

return {
	config = {
		root_dir = function(bufnr, on_dir)
			local root = vim.fs.root(bufnr, { ".git", "README.md", "README.markdown", ".marksman.toml" })
			on_dir(root or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
		end,
	},
}
