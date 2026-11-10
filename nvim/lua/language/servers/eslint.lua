-- lua/language/servers/eslint.lua

-- ESLint for JavaScript and TypeScript validation. Formatting stays with
-- conform and prettier, so the server's formatter is off, and linting runs on
-- save through the server's own `run` setting. ESLint resolves its
-- configuration from the closest `eslint.config.*` or `.eslintrc.*` in
-- monorepos through the `workingDirectory` mode.
--
-- `LspEslintFixAll` runs before conform formats. The hook is registered below,
-- and it respects the autoformat toggle from `lua/lib/autoformat.lua`.
--
-- :MasonInstall eslint-lsp
--
-- See: lua/plugins/formatting.lua
-- See: lua/lib/autoformat.lua
-- See: https://github.com/microsoft/vscode-eslint

---@type UserLspServerModule
return {
	config = {
		settings = {
			format = false,
			run = "onSave",
			workingDirectory = { mode = "auto" },
		},
	},

	---Registers `LspEslintFixAll` on `BufWritePre`. The autocmd is created on
	---attach so that it is registered before conform's, and it respects the
	---autoformat toggle. One group per buffer, so re-attaching replaces the
	---autocmd instead of stacking it.
	---@param _ vim.lsp.Client Unused, the hook only needs the buffer.
	---@param bufnr integer
	on_attach = function(_, bufnr)
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = vim.api.nvim_create_augroup("EslintFix" .. bufnr, { clear = true }),
			buffer = bufnr,
			callback = function()
				if require("lib.autoformat").enabled(bufnr) then
					vim.cmd("silent! LspEslintFixAll")
				end
			end,
		})
	end,
}
