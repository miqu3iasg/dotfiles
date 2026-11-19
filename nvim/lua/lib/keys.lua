-- lua/lib/keys.lua

-- Shared keymap setters. Every mapping gets a `desc` and is silent by default,
-- so `opts` is only for the exceptions.
--
-- See: lua/config/keymaps/

local M = {}

---Set a global keymap, silent by default.
---@param mode string|string[]
---@param lhs string
---@param rhs string|fun()
---@param desc? string Shown in `:map`, so it should describe the behavior.
---@param opts? table<string, any> Extra mapping options merged over the defaults.
function M.map(mode, lhs, rhs, desc, opts)
	vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { silent = true, desc = desc }, opts or {}))
end

---Set a buffer-local keymap, silent by default.
---@param mode string|string[]
---@param lhs string
---@param rhs string|fun()
---@param desc? string
---@param opts? table<string, any> Extra mapping options merged over the defaults.
function M.bmap(mode, lhs, rhs, desc, opts)
	vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { buffer = true, silent = true, desc = desc }, opts or {}))
end

---Map a key that toggles a boolean window option.
---@param lhs string
---@param opt string Name of the window option.
---@param desc string
function M.toggle_wo(lhs, opt, desc)
	M.map("n", lhs, function()
		vim.wo[opt] = not vim.wo[opt]
	end, desc)
end

return M
