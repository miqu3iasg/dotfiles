-- lua/language/types.lua

-- Shared contract of the LSP stack, defined next to the code that reads it.
-- `validate()` turns a malformed server module into a startup error.
--
-- See: lua/language/init.lua
-- See: lua/language/servers/lua_ls.lua

local M = {}

---The shape returned by every file in `servers/`.
---@class UserLspServerModule
---@field config vim.lsp.Config Configuration passed to `vim.lsp.config`.
---@field on_attach? fun(client: vim.lsp.Client, bufnr: integer) Hook run once the client attaches.

---Check that a module follows the server shape, raising an error that names it.
---@param name string Server module name from `servers/`, used in the error message.
---@param mod UserLspServerModule The module loaded from `servers/<name>.lua`.
---@return UserLspServerModule mod The module, unchanged.
function M.validate(name, mod)
	assert(
		type(mod) == "table" and type(mod.config) == "table",
		"language.servers." .. name .. " must return a table with a `config` table"
	)
	if mod.on_attach ~= nil and type(mod.on_attach) ~= "function" then
		error("language.servers." .. name .. ".on_attach must be a function", 0)
	end

	return mod
end

return M
