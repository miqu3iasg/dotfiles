-- lua/plugins/init.lua

-- Loads every plugin configuration module. The order matters, since some
-- modules depend on others.
--
-- See: lua/config/pack.lua
-- See: lua/plugins/fzf.lua

for _, mod in ipairs({
	"plugins.treesitter",
	"plugins.formatting",
	"plugins.completions",
	"language",
	"plugins.fzf",
	"plugins.git",
	"plugins.unnecessary-shit",
	"plugins.oil",
	"plugins.lisp",
	"plugins.markdown",
}) do
	local ok, err = pcall(require, mod)
	if not ok then
		vim.notify(("Errors at .%s:\n%s"):format(mod:gsub("^plugins%.", ""), err), vim.log.levels.ERROR)
	end
end
