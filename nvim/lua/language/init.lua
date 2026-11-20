-- lua/language/init.lua

-- Shared LSP setup for the server modules in `servers/`, which register
-- themselves here, plus the toggle for the whole stack.
--
-- Servers come from Mason; the JavaScript ones need Node.js and Java needs a JDK.
--
-- $ sudo pacman -S nodejs npm jdk-openjdk
-- :MasonInstall clangd css-lsp emmet-language-server eslint-lsp html-lsp lua-language-server marksman pyright tailwindcss-language-server vtsls jdtls
--
-- See: doc/kickstart.txt
-- See: lua/language/lint.lua
-- See: :help lsp

-- A malformed module fails with the server name instead of a broken attach.
local types = require("language.types")

-- `jdtls` is missing because nvim-jdtls starts it per buffer.
---@type string[]
local modules = {
	"clangd",
	"cssls",
	"emmet_language_server",
	"eslint",
	"html",
	"lua_ls",
	"marksman",
	"pyright",
	"tailwindcss",
	"vtsls",
}

---Servers installed through Mason, but started elsewhere.
---@type string[]
local install_only = { "jdtls" }

---Server modules by name, so the attach autocmd finds its hook.
---@type table<string, UserLspServerModule>
local servers = {}

require("mason").setup()

-- Only used to install servers, so it can wait until startup is done.
vim.schedule(function()
	require("mason-lspconfig").setup({
		automatic_enable = false,
		ensure_installed = vim.list_extend(vim.deepcopy(modules), install_only),
	})
end)

-- Dynamic file watching would register thousands of watchers in large projects.
vim.lsp.config("*", {
	capabilities = vim.lsp.protocol.make_client_capabilities(),
	workspace = { didChangeWatchedFiles = { dynamicRegistration = false } },
	inlay_hints = { enabled = true },
	semantic_tokens = { enabled = true },
})

for _, name in ipairs(modules) do
	local mod = require("language.servers." .. name)
	types.validate(name, mod)
	vim.lsp.config(name, mod.config)
	servers[name] = mod
end

-- Only mappings without a native default are set.
-- See: :help lsp-defaults
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(ev)
		---Set a buffer-local mapping on the attached buffer.
		---@param mode string|string[]
		---@param lhs string
		---@param rhs string|fun()
		---@param desc string
		local function km(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
		end

		km("i", "<C-j>", vim.lsp.buf.signature_help, "Signature help")

		km("n", "grp", vim.lsp.buf.signature_help, "Show signature help")
		km("n", "grc", vim.lsp.buf.declaration, "Go to declaration")
		km("n", "gd", vim.lsp.buf.definition, "Go to definition")
		km("n", "grw", vim.lsp.buf.workspace_symbol, "Workspace symbols")

		km("n", "grn", vim.lsp.buf.rename, "Rename symbol")
		km("n", "gra", vim.lsp.buf.code_action, "Code action")

		km("n", "grs", function()
			vim.cmd("vsplit")
			vim.lsp.buf.implementation()
		end, "Go to implementation in split")

		km("n", "gro", function()
			vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
		end, "Organize imports")

		km("n", "gre", function()
			vim.diagnostic.open_float({ scope = "cursor" })
		end, "Show diagnostic under cursor")

		km("n", "[e", function()
			vim.diagnostic.jump({ count = -1, float = true })
		end, "Go to previous diagnostic")

		km("n", "]e", function()
			vim.diagnostic.jump({ count = 1, float = true })
		end, "Go to next diagnostic")

		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		local mod = client and servers[client.name] or nil
		if mod and mod.on_attach then
			mod.on_attach(client, ev.buf)
		end
	end,
})

vim.diagnostic.config({
	virtual_text = false,
	severity_sort = true,
	underline = true,
	float = { border = vim.o.winborder },
})

local diagnostics_enabled = false

---Enable or disable the diagnostics display.
---@param enable? boolean Force a state; omit to toggle.
---@return boolean enabled The new state.
local function toggle_diagnostics(enable)
	if enable == nil then
		diagnostics_enabled = not diagnostics_enabled
	else
		diagnostics_enabled = enable
	end

	vim.diagnostic.enable(diagnostics_enabled)

	-- Re-enabling every namespace would bring back a lint that the lint toggle
	-- turned off, so the lint state is reapplied after the display comes back.
	if diagnostics_enabled then
		local ok, lint_mod = pcall(require, "language.lint")
		if ok and lint_mod.resync then
			lint_mod.resync()
		end
	end

	vim.notify("Diagnostics " .. (diagnostics_enabled and "enabled" or "disabled"), vim.log.levels.INFO)

	return diagnostics_enabled
end

-- The diagnostics display starts off and follows the keymaps and server toggles.
vim.diagnostic.enable(diagnostics_enabled)

vim.keymap.set("n", "<leader>ud", function()
	toggle_diagnostics()
end, { desc = "Toggle diagnostics" })

vim.lsp.enable(modules)

local lsp_enabled = true

---Enable or disable every language server in `modules` at once.
---@param enable? boolean Force a state; omit to toggle.
---@return boolean enabled The new state.
local function toggle_lsp(enable)
	if enable == nil then
		lsp_enabled = not lsp_enabled
	else
		lsp_enabled = enable
	end

	if lsp_enabled then
		vim.lsp.enable(modules)
	else
		vim.lsp.enable(modules, false)

		for _, client in ipairs(vim.lsp.get_clients()) do
			if vim.tbl_contains(modules, client.name) then
				client:stop()
			end
		end
	end

	vim.notify("LSP " .. (lsp_enabled and "enabled" or "disabled"), vim.log.levels.INFO)

	return lsp_enabled
end

vim.keymap.set("n", "<leader>ul", function()
	toggle_lsp()
end, { desc = "Toggle LSP" })

-- Linters load with the stack, so their toggle exists from the start.
-- See: lua/language/lint.lua
require("language.lint")
