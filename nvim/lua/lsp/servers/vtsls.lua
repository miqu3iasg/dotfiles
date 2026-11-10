-- lua/lsp/servers/vtsls.lua

-- TypeScript and JavaScript through vtsls, which wraps tsserver requests into
-- native LSP. vtsls replaces ts_ls. Never enable both, or every diagnostic and
-- completion shows up twice.
--
-- The settings are shared between the `typescript` and the `javascript`
-- sections through a single table, so the two languages behave exactly the
-- same way, with `maxTsServerMemory` applied on top of the TypeScript side.
-- Completion imports missing symbols by itself, the workspace tsserver wins
-- over the global one when a project brings its own, code actions can move
-- declarations to a new file, and the server takes part in completion
-- filtering through fuzzy matching. Imports are reorganized automatically on
-- save, and the manual command stays available through its own keymap (see
-- lua/lsp/init.lua).
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
			-- Organizing imports runs through its own keymap (see lua/lsp/init.lua),
			-- so the default command is stubbed out to keep it silent.
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

	---Registers `source.organizeImports` on `BufWritePre`, so imports stay
	---sorted and free of unused entries without manual runs. It respects the
	---autoformat toggle, like the eslint fix-all on save does, and uses one
	---group per buffer, so re-attaching replaces the autocmd instead of
	---stacking it.
	---@param _ vim.lsp.Client Unused, the hook only needs the buffer.
	---@param bufnr integer
	on_attach = function(_, bufnr)
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = vim.api.nvim_create_augroup("VtslsOrganize" .. bufnr, { clear = true }),
			buffer = bufnr,
			callback = function()
				if require("shared.autoformat").enabled(bufnr) then
					vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
				end
			end,
		})
	end,
}
