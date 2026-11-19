-- lua/language/servers/marksman.lua

-- Markdown through marksman, for note navigation together with obsidian.nvim.
--
-- Any folder with a README is a workspace, falling back to the file directory.
--
-- marksman comes from Mason.
--
-- :MasonInstall marksman
--
-- See: lua/plugins/markdown.lua
-- See: https://github.com/artempyanykh/marksman

---@type UserLspServerModule
return {
	config = {
		root_dir = function(bufnr, on_dir)
			local root = vim.fs.root(bufnr, { ".git", "README.md", "README.markdown", ".marksman.toml" })
			on_dir(root or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
		end,
	},
}
