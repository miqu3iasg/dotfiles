-- lua/plugins/init.lua

-- Loads all plugin configuration modules. Plugin installation is managed by
-- Neovim's built-in package manager (`vim.pack`), configured in
-- lua/config/pack.lua. Add new plugin modules to the list below; the load
-- order matters because some modules depend on others (for example,
-- lua/plugins/fzf.lua must load before lua/plugins/markdown.lua). Module names
-- are full paths, so modules living outside `lua/plugins/` can slot into the
-- same order; the LSP stack does that, with `lua/lsp/init.lua` loading between
-- completions and fzf. A module that fails to load notifies an error instead
-- of aborting the rest.

for _, mod in ipairs({
	"plugins.treesitter",
	"plugins.formatting",
	"plugins.completions",
	"lsp",
	"plugins.fzf",
	"plugins.git",
	"plugins.unnecessary-shit",
	"plugins.oil",
	"plugins.latex",
	"plugins.lisp",
	"plugins.markdown",
}) do
	local ok, err = pcall(require, mod)
	if not ok then
		vim.notify(("Errors at .%s:\n%s"):format(mod:gsub("^plugins%.", ""), err), vim.log.levels.ERROR)
	end
end
