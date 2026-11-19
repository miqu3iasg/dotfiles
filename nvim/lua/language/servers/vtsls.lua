-- lua/language/servers/vtsls.lua

-- TypeScript and JavaScript through vtsls, which wraps tsserver in native LSP.
-- It replaces ts_ls, so never enable both or every result shows up twice.
--
-- Imports are organized on save, it takes part in completion filtering, and
-- formatting stays with conform. vtsls comes from Mason.
--
-- :MasonInstall vtsls
--
-- See: lua/plugins/formatting.lua
-- See: https://github.com/yioneko/vtsls

local ts_shared = {
	updateImportsOnFileMove = { enabled = "always" },
	suggest = {
		completeFunctionCalls = true,
		autoImports = true,
	},
	preferences = {
		-- Use "non-relative" if the project relies on path aliases (@/...).
		importModuleSpecifier = "shortest",
		preferTypeOnlyAutoImports = true,
	},
	inlayHints = {
		parameterNames = { enabled = "literals" },
		parameterTypes = { enabled = false },
		variableTypes = { enabled = false },
		propertyDeclarationTypes = { enabled = true },
		functionLikeReturnTypes = { enabled = true },
		enumMemberValues = { enabled = true },
	},
}

---@type UserLspServerModule
return {
	config = {
		commands = {
			-- Organizing imports runs through its own keymap, so the stub keeps it silent.
			["_typescript.didOrganizeImports"] = function() end,
		},
		settings = {
			typescript = vim.tbl_deep_extend("force", ts_shared, {
				tsserver = { maxTsServerMemory = 8192 },
			}),
			javascript = ts_shared,
			vtsls = {
				autoUseWorkspaceTsdk = true,
				enableMoveToFileCodeAction = true,
				experimental = {
					completion = {
						enableServerSideFuzzyMatch = true,
					},
				},
			},
		},
	},

	---Organize imports on `BufWritePre`, following the autoformat toggle.
	---@param bufnr integer
	on_attach = function(_, bufnr)
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = vim.api.nvim_create_augroup("VtslsOrganize" .. bufnr, { clear = true }),
			buffer = bufnr,
			callback = function()
				if require("lib.autoformat").enabled(bufnr) then
					vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
				end
			end,
		})
	end,
}
