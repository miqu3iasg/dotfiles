-- lua/plugins/completions.lua

-- Native LSP completion with LuaSnip for snippets, without a completion plugin,
-- plus a wrapper that drops dead clients on a buffer reload.
--
-- Tree-sitter CLI and system dependencies come from pacman, parsers from Neovim.
--
-- $ sudo pacman -S tree-sitter-cli nodejs npm jdk-openjdk
-- :TSInstall c java python lua scheme racket sql markdown javascript typescript
-- :TSInstall html css json jsonc yaml toml bash
--
-- See: lua/language/init.lua
-- See: :help vim.lsp.completion
-- See: https://github.com/L3MON4D3/LuaSnip
-- See: https://github.com/nvim-treesitter/nvim-treesitter

-- Filetypes are keys and snippet modules are values, required on first use.
---@type table<string, string>
local snippet_modules = {
	c = "snippets.c",
	python = "snippets.python",
	java = "snippets.java",
	lisp = "snippets.lisp",
	lua = "snippets.lua",
	sql = "snippets.sql",
	markdown = "snippets.markdown",
	common = "snippets.common",
}

---@type table<string, string>
local aliases = {
	scheme = "lisp",
	mysql = "sql",
	plsql = "sql",
}

---@type table<string, boolean>
local common_filetypes = {
	python = true,
	c = true,
	scheme = true,
	lua = true,
	java = true,
	javascript = true,
	javascriptreact = true,
	typescript = true,
	typescriptreact = true,
	sh = true,
	markdown = true,
	sql = true,
	mysql = true,
	plsql = true,
	html = true,
	css = true,
}

---@type table<string, boolean>
local TRIGGER_FILETYPES = {
	javascript = true,
	javascriptreact = true,
	typescript = true,
	typescriptreact = true,
	html = true,
	htmlangular = true,
	css = true,
	scss = true,
	json = true,
	jsonc = true,
	yaml = true,
	toml = true,
}

-- A detached server re-calls this with a stale client id on the next reload,
-- so drop dead clients here.
local enable = vim.lsp.completion.enable
vim.lsp.completion.enable = function(on, client_id, bufnr, opts)
	if on and not vim.lsp.get_client_by_id(client_id) then
		return
	end
	enable(on, client_id, bufnr, opts)
end

-- Tracked per buffer, so it survives the client id changing.
---@type table<integer, boolean>
local completion_bufs = {}

---Enable native LSP completion on `buf`, restricting only the automatic popup
---to `TRIGGER_FILETYPES` and skipping huge files.
---@param client vim.lsp.Client
---@param buf integer
local function maybe_enable(client, buf)
	if completion_bufs[buf] or not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	if not client:supports_method("textDocument/completion", buf) then
		return
	end
	if vim.b[buf].completion == false or require("lib.bigfile").is_big(buf) then
		return
	end

	completion_bufs[buf] = true

	local autotrigger = TRIGGER_FILETYPES[vim.bo[buf].filetype] == true
	vim.lsp.completion.enable(true, client.id, buf, { autotrigger = autotrigger })
end

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("NativeLspCompletion", { clear = true }),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client then
			return
		end
		maybe_enable(client, ev.buf)
	end,
})

-- A wiped buffer or a detached client must clear the flag, or a recycled buffer
-- number, or the same buffer after a reload, never gets completion.
vim.api.nvim_create_autocmd({ "BufWipeout", "LspDetach" }, {
	group = vim.api.nvim_create_augroup("NativeLspCompletion", { clear = false }),
	callback = function(ev)
		completion_bufs[ev.buf] = nil
	end,
})

-- Buffers attached before this file ran, such as restored sessions, missed
-- their LspAttach event.
for _, client in ipairs(vim.lsp.get_clients()) do
	for buf in pairs(client.attached_buffers) do
		maybe_enable(client, buf)
	end
end

-- Markdown stays out of `TRIGGER_FILETYPES`, so note-link completion comes
-- from Obsidian's LSP only.

local luasnip = require("luasnip")

luasnip.setup({
	enable_autosnippets = true,
	store_selection_keys = "<leader>s",
	update_events = "TextChanged,TextChangedI",
	region_check_events = "InsertEnter",
	delete_check_events = "TextChanged",
})

for ft in pairs(common_filetypes) do
	luasnip.filetype_extend(ft, { "common" })
end

for ft, base in pairs(aliases) do
	luasnip.filetype_extend(ft, { base })
end

-- Each snippet module is required only once.
---@type table<string, boolean>
local loaded = {}

---Require one snippet module and register its snippets, reporting failures
---instead of raising.
---@param name string Key of `snippet_modules`, after alias resolution.
local function load(name)
	local module = snippet_modules[name]

	if not module or loaded[name] then
		return
	end

	loaded[name] = true
	local ok, snippets = pcall(require, module)
	if ok then
		luasnip.add_snippets(name, snippets)
	else
		vim.notify(("Failed to load snippets '%s': %s"):format(module, snippets), vim.log.levels.ERROR)
	end
end

---Load the snippets of a filetype, resolving aliases and adding `common`.
---@param ft string
local function load_snippets(ft)
	load(aliases[ft] or ft)
	if common_filetypes[ft] then
		load("common")
	end
end

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("LazySnippets", { clear = true }),
	callback = function(args)
		load_snippets(args.match)
	end,
})

-- Buffers opened before this file ran missed their FileType event.
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
	if vim.api.nvim_buf_is_loaded(buf) then
		load_snippets(vim.bo[buf].filetype)
	end
end

local map = vim.keymap.set

---Open the completion menu using LSP completion when a client supports it,
---keyword completion as a fallback. Returns the keys for the expr mapping.
---@param dir integer 1 for the next item, -1 for the previous one.
---@return string
local function open_menu(dir)
	if vim.lsp.get_clients({ bufnr = 0, method = "textDocument/completion" })[1] then
		vim.lsp.completion.get()
		return ""
	end
	return dir == 1 and "<C-n>" or "<C-p>" -- Builtin keyword completion.
end

-- The check runs on every press, so a buffer without an attached client falls
-- back to keyword completion. With the menu open the key accepts the item.
map("i", "<C-y>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-y>" -- Returned keys are not remapped, so this is the builtin.
	end
	return open_menu(1)
end, { expr = true, desc = "LSP completion, buffer words as fallback" })

map("i", "<CR>", function()
	return vim.fn.pumvisible() == 1 and "<C-y>" or "<CR>"
end, { expr = true, desc = "Accept completion or newline" })

---Build a keymap callback that moves the selection or the snippet choice,
---scheduling the choice change to avoid a re-entrant jump out of the mapping.
---@param dir integer 1 for the next item, -1 for the previous one.
---@return fun(): string
local function select_item(dir)
	return function()
		if luasnip.choice_active() then
			vim.schedule(function()
				luasnip.change_choice(dir)
			end)
			return ""
		end
		if vim.fn.pumvisible() == 1 then
			return dir == 1 and "<C-n>" or "<C-p>"
		end
		return open_menu(dir)
	end
end

map("i", "<C-n>", select_item(1), { expr = true, desc = "Next completion item / cycle snippet choice / open menu" })
map("i", "<C-p>", select_item(-1), { expr = true, desc = "Prev completion item / cycle snippet choice / open menu" })

-- A single expr mapping, so the checks run in order and fall through. An
-- active placeholder wins over the completion menu, or Tab never leaves it.
map({ "i", "s" }, "<Tab>", function()
	if luasnip.expandable() then
		return "<cmd>lua require('luasnip').expand()<cr>"
	end
	if luasnip.locally_jumpable(1) then
		return "<cmd>lua require('luasnip').jump(1)<cr>"
	end
	if vim.fn.pumvisible() == 1 then
		return "<C-n>"
	end
	return "<Tab>"
end, { expr = true, desc = "Expand snippet, next placeholder or next completion item" })

map({ "i", "s" }, "<S-Tab>", function()
	if luasnip.locally_jumpable(-1) then
		return "<cmd>lua require('luasnip').jump(-1)<cr>"
	end
	if vim.fn.pumvisible() == 1 then
		return "<C-p>"
	end
	-- Native dedent
	return "<C-d>"
end, { expr = true, desc = "Previous placeholder, prev completion item or dedent" })

map("i", "<C-q>", function()
	if luasnip.in_snippet() then
		luasnip.unlink_current()
	end
end, { desc = "Unlink active snippet" })
