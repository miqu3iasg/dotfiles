-- lua/lib/lazy.lua

-- Filetype-based lazy loading for `vim.pack` plugins. Each plugin file in
-- `lua/plugins/` declares itself with `setup(spec)`.
--
-- Loading runs `configure`, then `:packadd`, then `after`, then the FileType
-- event again for the triggering buffer.
--
-- See: lua/config/pack.lua
-- See: lua/plugins/lisp.lua

---@class lazy.Spec
---@field src string Plugin source, as a vim.pack spec.
---@field filetypes? string[] Filetypes that trigger the load.
---@field version? string Passed through to vim.pack.
---@field configure? string|fun() Module name exposing `configure()`, or a function. Runs before the `:packadd`.
---@field after? fun() Runs after the `:packadd`.

local M = {}

local registered = {}
local ft_map = {}
local loaded = {}
local gate_installed = false

---Resolve the plugin name from its source, which is the basename without
---`.git`.
---@param src string
---@return string
local function name_of(src)
	return (src:gsub("%.git$", ""):match("[^/]+$"))
end

---Install the shared FileType gate once, no matter how many setups ran.
local function ensure_gate()
	if gate_installed then
		return
	end
	gate_installed = true

	-- No pattern on purpose, so every lazy plugin stays inspectable in
	-- `:autocmd LazyPack`. BufEnter catches plugins that register filetypes
	-- after the initial FileType event.
	vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
		group = vim.api.nvim_create_augroup("LazyPack", { clear = true }),
		callback = function(ev)
			local names = ft_map[ev.match]
			if not names then
				return
			end
			for _, name in ipairs(names) do
				M.load(name, ev.buf)
			end
		end,
	})
end

---Load one plugin, once per session. Calling it repeatedly is safe, and so is
---calling it before `setup` for the same name, which does nothing.
---@param name string
---@param buf? integer Buffer that triggered the load.
function M.load(name, buf)
	local spec = registered[name]
	if not spec or loaded[name] then
		return
	end
	loaded[name] = true

	if spec.configure then
		local fn = type(spec.configure) == "string" and function()
			require(spec.configure).configure()
		end or spec.configure
		local ok, err = pcall(fn)
		if not ok then
			vim.notify(("LazyPack: configuring %s failed: %s"):format(name, err), vim.log.levels.ERROR)
		end
	end

	local ok, err = pcall(vim.cmd.packadd, name)
	if not ok then
		vim.notify(("LazyPack: packadd %s failed: %s"):format(name, err), vim.log.levels.ERROR)
		return
	end

	if spec.after then
		local ok, err = pcall(spec.after)
		if not ok then
			vim.notify(("LazyPack: after %s failed: %s"):format(name, err), vim.log.levels.ERROR)
		end
	end

	-- Now on the runtimepath, so its ftplugin runs for this buffer.
	if buf and vim.api.nvim_buf_is_valid(buf) then
		pcall(vim.api.nvim_exec_autocmds, "FileType", { buffer = buf })
	end
end

---Declare one lazy plugin. Its `plugin/` scripts are deferred until a buffer
---of one of its filetypes appears.
---@param spec lazy.Spec
function M.setup(spec)
	local name = name_of(spec.src)
	registered[name] = spec
	for _, ft in ipairs(spec.filetypes or {}) do
		ft_map[ft] = ft_map[ft] or {}
		table.insert(ft_map[ft], name)
	end

	local add_spec = { src = spec.src }
	if spec.version then
		add_spec.version = spec.version
	end
	-- The empty `load` makes vim.pack install the plugin without sourcing it.
	local ok, err = pcall(vim.pack.add, { add_spec }, { load = function() end })
	if not ok then
		vim.notify(("LazyPack: adding %s failed: %s"):format(spec.src, err), vim.log.levels.ERROR)
	end

	ensure_gate()

	-- Buffers already open missed the event, such as restored sessions.
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local ft = vim.bo[buf].filetype
		if ft and vim.list_contains(spec.filetypes or {}, ft) then
			M.load(name, buf)
			break
		end
	end
end

return M
