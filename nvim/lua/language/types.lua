-- lua/language/types.lua

-- Shared contract of the LSP stack. The classes used by the annotations across
-- `lua/language/` live here, in one place, so they are defined next to the code that
-- reads them. `validate()` turns a malformed server module into a startup error
-- instead of a broken attach, since the module tables come from separate files
-- and nothing else checks their shape.

local M = {}

---The shape returned by every file in `servers/`. The `config` table is passed
---to `vim.lsp.config(name, ...)`, and `on_attach`, when present, runs from the
---LspAttach autocmd in `lua/language/init.lua` for buffers that attach to that
---server.
---@class UserLspServerModule
---@field config vim.lsp.Config Configuration passed to `vim.lsp.config`.
---@field on_attach? fun(client: vim.lsp.Client, bufnr: integer) Hook run once the client attaches.

---Check that `mod` follows the `UserLspServerModule` shape, raising an error
---when it does not, so a wrong server module fails at load time with a message
---that names the file.
---@param name string Server module name from `servers/`, used in the error message.
---@param mod UserLspServerModule The module loaded from `servers/<name>.lua`.
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
