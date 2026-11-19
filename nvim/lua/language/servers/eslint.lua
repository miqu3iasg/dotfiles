-- lua/language/servers/eslint.lua

-- ESLint for JavaScript and TypeScript, running on save with its formatter off
-- and its configuration taken from the nearest config file.
--
-- The fix-all runs before conform formats and follows the autoformat toggle.
--
-- eslint-lsp comes from Mason.
--
-- :MasonInstall eslint-lsp
--
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

	---Register `LspEslintFixAll` on `BufWritePre`, before conform formats.
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
