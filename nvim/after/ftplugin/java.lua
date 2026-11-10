-- after/ftplugin/java.lua

-- Editor options and buffer-local keymaps for Java buffers. The jdtls client
-- itself is started and owned by `lua/language/servers/jdtls.lua`, which is
-- required here with the buffer so the server starts on the first Java buffer
-- of each project.
--
-- See: lua/language/servers/jdtls.lua
-- See: lua/plugins/formatting.lua

local jdtls = require("language.servers.jdtls")
local opt = vim.opt_local

opt.wrap = false
opt.expandtab = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.softtabstop = -1
opt.textwidth = 120
opt.spell = false
opt.formatoptions:remove("t")
opt.formatoptions:append({ "r", "o" })
opt.suffixesadd:append(".java")

---@param mode string|string[]
---@param lhs string
---@param rhs string|fun()
---@param desc string
---@param opts? table Extra mapping options merged over the defaults.
local function map(mode, lhs, rhs, desc, opts)
	vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { buffer = true, silent = true, desc = desc }, opts or {}))
end

map("n", "<leader>jd", function()
	local row = vim.fn.line(".")
	local indent = vim.fn.getline(row):match("^%s*")
	vim.api.nvim_buf_set_lines(0, row - 1, row - 1, false, { indent .. "/**", indent .. " * ", indent .. " */" })
	vim.api.nvim_win_set_cursor(0, { row + 1, #indent + 3 })
	vim.cmd("startinsert!")
end, "Java: insert Javadoc above")

map("n", "<leader>;", "mzA;<Esc>`z", "Java: append semicolon")

local function toggle_test()
	local path = vim.api.nvim_buf_get_name(0)
	local target
	if path:match("Test%.java$") then
		target = path:gsub("/src/test/", "/src/main/"):gsub("Test%.java$", ".java")
	else
		target = path:gsub("/src/main/", "/src/test/"):gsub("%.java$", "Test.java")
	end
	if vim.uv.fs_stat(target) then
		vim.cmd.edit({ args = { target } })
	else
		vim.notify("Not found: " .. target, vim.log.levels.WARN)
	end
end

map("n", "<leader>jT", toggle_test, "Java: toggle source/test file")

map("n", "<leader>jr", function()
	jdtls.build("run")
end, "Java: run application")

map("n", "<leader>jt", function()
	jdtls.build("test")
end, "Java: run tests")

map("n", "<leader>jb", function()
	jdtls.build("build")
end, "Java: build project")

map("n", "<leader>jo", require("jdtls").organize_imports, "Java: organize imports")
map("n", "<leader>ju", jdtls.update_project, "Java: reload Maven/Gradle project")
map("n", "<leader>jL", jdtls.stop, "Java: stop LSP")
map("n", "<leader>jW", jdtls.wipe_workspace, "Java: wipe workspace and restart LSP")

jdtls.start(0)
