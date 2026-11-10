-- lua/lsp/init.lua

-- Language servers for frontend development (HTML, CSS, Tailwind CSS, Emmet and
-- TypeScript/JavaScript), LaTeX, Typst, Markdown and Lua, plus Python through
-- pyright, C and C++ through clangd and Go through gopls. Each server is
-- configured in its own module under `lua/lsp/servers/`, while this file holds
-- the shared setup: the Mason installation, the global capabilities, the
-- buffer-local keymaps and the enable/toggle state. Formatting stays with
-- conform for every language (see lua/plugins/formatting.lua). Python is also
-- linted with flake8 through nvim-lint, which runs outside this stack and has
-- its own toggle (see lua/lsp/lint.lua). Java's `jdtls` is installed through
-- Mason but started separately by the Java ftplugin (see
-- after/ftplugin/java.lua).
--
-- nvim-lspconfig, mason.nvim and mason-lspconfig.nvim must be installed through
-- the plugin manager; the lazydev.nvim setup lives in the lua_ls module, where
-- it takes effect. Mason manages the language servers, but some of them rely on
-- external runtimes and command-line tools. On Arch Linux, install Node.js and
-- npm for the JavaScript-based servers, a JDK for Java, and the Typst CLI and
-- typstyle for Typst compilation and formatting:
--
-- $ sudo pacman -S nodejs npm jdk-openjdk typst typstyle
--
-- Texlab provides the LaTeX language-server features, and its chktex options
-- need chktex, but compiling LaTeX documents needs a TeX Live installation.
-- These packages provide the core distribution, LaTeX packages and additional
-- build utilities:
--
-- $ sudo pacman -S texlive-basic texlive-latex texlive-latexextra texlive-binextra
--
-- The configuration requests the installation of the language servers at
-- startup. They can also be installed manually from Neovim:
--
-- :MasonInstall clangd css-lsp emmet-language-server eslint-lsp gopls html-lsp lua-language-server marksman pyright tailwindcss-language-server texlab tinymist vtsls jdtls
--
-- Tinymist uses `typstyle` for formatting, and its PDF export also requires the
-- `typst` executable. Mason only installs the servers, so each one is still
-- configured individually in `lua/lsp/servers/`, and only the servers declared
-- below are enabled.
--
-- See: lua/lsp/lint.lua
-- See: lua/lsp/servers/lua_ls.lua
-- See: lua/lsp/types.lua
-- See: lua/shared/exports.lua
-- See: https://github.com/mason-org/mason.nvim
-- See: https://github.com/mason-org/mason-lspconfig.nvim
-- See: https://github.com/neovim/nvim-lspconfig
-- See: :help lsp

-- The shape check is what turns a malformed module into a load error with the
-- server name, instead of a broken attach.
local types = require("lsp.types")

-- Language server modules under `lua/lsp/servers/`, loaded and registered
-- below. `jdtls` is not listed because it is never started through this stack.
-- The order is alphabetical and meaningless, since each module registers on its
-- own.
---@type string[]
local modules = {
	"clangd",
	"cssls",
	"emmet_language_server",
	"eslint",
	"gopls",
	"html",
	"lua_ls",
	"marksman",
	"pyright",
	"tailwindcss",
	"texlab",
	"tinymist",
	"vtsls",
}

---Servers installed through Mason, but started elsewhere.
---@type string[]
local install_only = { "jdtls" }

---Modules indexed by server name, so the attach autocmd reaches the hook of
---the client that fired the event. The `UserLspServerModule` class that these
---modules follow lives in `lua/lsp/types.lua`.
---@type table<string, UserLspServerModule>
local servers = {}

-- Installation

require("mason").setup()

-- Only used to install servers, so it can wait until startup is done.
vim.schedule(function()
	require("mason-lspconfig").setup({
		automatic_enable = false,
		ensure_installed = vim.list_extend(vim.deepcopy(modules), install_only),
	})
end)

-- Server configuration

-- Disabling dynamic file watching avoids servers registering thousands of
-- watchers in large projects.
vim.lsp.config("*", {
	capabilities = vim.lsp.protocol.make_client_capabilities(),
	workspace = { didChangeWatchedFiles = { dynamicRegistration = false } },
})

for _, name in ipairs(modules) do
	local mod = require("lsp.servers." .. name)
	types.validate(name, mod)
	vim.lsp.config(name, mod.config)
	servers[name] = mod
end

-- Attach

-- Buffer-local mappings set once a server attaches. The native LSP and
-- diagnostic mappings, such as hover, rename and diagnostic navigation, are
-- intentionally not redefined, except where fzf-lua replaces them.
-- See: :help lsp-defaults
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
	callback = function(ev)
		local fzf = require("fzf-lua")

		---Set a buffer-local mapping on the attached buffer.
		---@param mode string|string[]
		---@param lhs string
		---@param rhs string|fun()
		---@param desc string
		local function km(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
		end

		km("n", "gd", fzf.lsp_definitions, "Go to definition")
		km("i", "<C-j>", vim.lsp.buf.signature_help, "Signature help")

		km("n", "grp", vim.lsp.buf.signature_help, "Show signature help")
		km("n", "grc", fzf.lsp_declarations, "Go to declaration")
		km("n", "gri", fzf.lsp_implementations, "Go to implementation")
		km("n", "grt", fzf.lsp_typedefs, "Go to type definition")
		km("n", "grr", fzf.lsp_references, "Go to references")
		km("n", "grm", fzf.lsp_document_symbols, "Document symbols")
		km("n", "grw", fzf.lsp_live_workspace_symbols, "Workspace symbols")
		km("n", "grf", fzf.lsp_finder, "LSP finder")
		km("n", "grd", fzf.diagnostics_document, "Document diagnostics")
		km("n", "grD", fzf.diagnostics_workspace, "Workspace diagnostics")
		km({ "n", "v" }, "gra", fzf.lsp_code_actions, "Code action")

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

		-- Server-specific hooks declared in the server modules.
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		local mod = client and servers[client.name] or nil
		if mod and mod.on_attach then
			mod.on_attach(client, ev.buf)
		end
	end,
})

-- Diagnostics

vim.diagnostic.config({
	virtual_text = false,
	severity_sort = true,
	underline = true,
	float = { border = vim.o.winborder },
})

-- Toggle

vim.lsp.enable(modules)

local lsp_enabled = true

---Enable or disable every language server in `modules` at once. `jdtls` is
---started elsewhere and is deliberately left alone.
---
---Disabling prevents new clients from starting and also stops the ones still
---alive, so their diagnostics are cleared. Enabling starts the servers again and
---re-attaches them to the buffers that are already open.
---@param enable? boolean Forces a state. When omitted, the current state is toggled.
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
