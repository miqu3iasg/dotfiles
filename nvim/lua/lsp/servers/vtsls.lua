-- lua/lsp/servers/vtsls.lua

-- TypeScript and JavaScript through vtsls, which wraps tsserver requests into
-- native LSP. vtsls replaces ts_ls. Never enable both, or every diagnostic and
-- completion shows up twice.
--
-- The settings are shared between the `typescript` and the `javascript`
-- sections through a single table, so the two languages behave exactly the
-- same way, with `maxTsServerMemory` applied on top of the TypeScript side.
--
-- :MasonInstall vtsls
--
-- See: lua/plugins/formatting.lua
-- See: https://github.com/yioneko/vtsls

local ts_shared = {
	updateImportsOnFileMove = { enabled = "always" },
	suggest = { completeFunctionCalls = true },
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

return {
	config = {
		commands = {
			-- Organizing imports runs through `:LspOrganize` instead, so the
			-- default command is stubbed out to keep it from piling up.
			["_typescript.didOrganizeImports"] = function() end,
		},
		settings = {
			typescript = vim.tbl_deep_extend("force", ts_shared, {
				tsserver = { maxTsServerMemory = 8192 },
			}),
			javascript = ts_shared,
			vtsls = { autoUseWorkspaceTsdk = true },
		},
	},
}
