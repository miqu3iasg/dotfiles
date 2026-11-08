-- lua/config/commands.lua

-- User commands. The plugin commands mirror the built-in `vim.pack` API with
-- friendlier names, and the plugin list itself lives in `lua/config/pack.lua`.
--
-- See: lua/config/pack.lua
-- See: lua/config/keymaps/pack.lua
-- See: lua/shared/autoformat.lua

vim.api.nvim_create_user_command("Setwd", function()
	vim.cmd.cd(vim.fn.expand("%:p:h"))
end, { desc = "Change the working directory to the current file's directory" })

vim.api.nvim_create_user_command("FormatDisable", function()
	require("shared.autoformat").disable()
end, { desc = "Disable autoformat on save" })

vim.api.nvim_create_user_command("FormatEnable", function()
	require("shared.autoformat").enable()
end, { desc = "Enable autoformat on save" })

vim.api.nvim_create_user_command("PackAdd", function(opts)
	vim.pack.add(opts.fargs)
end, {
	nargs = "+",
	desc = "Add plugins to the session, installing missing ones (:PackAdd user/repo1 user/repo2)",
})

-- `:PackDel` and `:PackUpdate` become built-in in Neovim 0.13, so these keep
-- the same names available on 0.12.
vim.api.nvim_create_user_command("PackDel", function(opts)
	vim.pack.del(opts.fargs)
end, {
	nargs = "+",
	desc = "Delete plugins by name (:PackDel plugin1 plugin2)",
})

vim.api.nvim_create_user_command("PackUpdate", function(opts)
	if opts.args:match("%S") then
		local plugins = vim.split(opts.args, "%s+", { trimempty = true })
		vim.pack.update(plugins)
	else
		vim.pack.update()
	end
end, {
	nargs = "*",
	desc = "Update all plugins, or only the ones named (:PackUpdate plugin1 plugin2)",
})
