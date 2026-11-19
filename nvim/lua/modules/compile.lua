-- lua/modules/compile.lua

-- Emacs-like compile runner for this config. It runs a build command through
-- `sh -c` asynchronously and streams the output into a bottom split.
--
-- State is per working directory, so a new compile kills the previous one.
-- `setup()` must run once, and `init.lua` calls it at startup.
--
-- See: doc/modules.txt
-- See: lua/config/autocmds.lua
-- See: :help quickfix

local M = {}

---@type string
local BUFFER_NAME = "*compilation*"

---Default command per filetype. The "*" key is the fallback.
---@type table<string, string>
local DEFAULT_COMMAND = {
	["*"] = "make -k ",
	python = "python %",
	lua = "lua %",
	c = "cc -o %:r.out % && ./%:r.out",
	cpp = "c++ -std=c++23 -o %:r.out % && ./%:r.out",
	java = "javac -d out % && java -cp out %:t:r",
}

-- gcc, clang and javac come first, then Python traceback frames, whose
-- indented source lines are context. Every other line is dropped with `%-G`.
---@type string
local ERRORFORMAT = table.concat({
	"%f:%l:%c: %m",
	"%f:%l: %m",
	'%A  File "%f"\\, line %l\\, in %.%#',
	"%-C  %.%#",
	"--In file included from %.%#",
	"%-G%.%#",
}, ",")

---@type table<string, vim.SystemObj>
local running = {}

---@type table<string, string>
local last_command = {}

---@type integer?
local compilation_buf = nil

---Return the default command for the current filetype, expanding `%`, `%:r`,
---and `%:t:r` word by word so that the other words are left untouched.
---@return string
local function default_for_ft()
	local cmd = DEFAULT_COMMAND[vim.bo.filetype] or DEFAULT_COMMAND["*"] or ""

	local fname = vim.fn.expand("%")
	local base = vim.fn.expand("%:r")
	local filename = vim.fn.expand("%:t:r")

	local words = {}
	for word in cmd:gmatch("%S+") do
		if word == "%" then
			table.insert(words, fname)
		elseif word == "%:r" then
			table.insert(words, base)
		elseif word == "%:t:r" then
			table.insert(words, filename)
		else
			table.insert(words, word)
		end
	end

	return table.concat(words, " ")
end

---Create or reuse the compilation buffer and show it in a bottom split.
---@return integer
local function open_window()
	local buf = compilation_buf
	if not (buf and vim.api.nvim_buf_is_valid(buf)) then
		buf = vim.api.nvim_create_buf(false, true)
		compilation_buf = buf
		vim.api.nvim_buf_set_name(buf, BUFFER_NAME)
	end

	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].swapfile = false
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].buflisted = false
	vim.bo[buf].errorformat = ERRORFORMAT
	vim.bo[buf].modifiable = true
	-- The `qf` filetype makes the close_utility_buffers autocmd handle this
	-- buffer.
	vim.bo[buf].filetype = "qf"

	vim.cmd("rightbelow 25split")
	vim.cmd("buffer " .. buf)

	return buf
end

---Append lines to the compilation buffer and scroll every window showing it to
---the end.
---@param buf integer
---@param lines string[]
local function append(buf, lines)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	vim.bo[buf].modifiable = true
	local last = vim.api.nvim_buf_line_count(buf)
	vim.api.nvim_buf_set_lines(buf, last, last, false, lines)
	vim.bo[buf].modifiable = false

	for _, win in ipairs(vim.fn.win_findbuf(buf)) do
		vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
	end
end

---Write the exit status and, on failure, fill the quickfix list from the
---compilation buffer.
---@param buf integer
---@param code integer
local function finish(buf, code)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	append(buf, { ("[Exited %d]"):format(code) })

	if code ~= 0 then
		-- The errorformat is passed explicitly because quickfix commands would
		-- otherwise use the one from the current window.
		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		pcall(vim.fn.setqflist, {}, " ", {
			lines = lines,
			efm = ERRORFORMAT,
			title = "compilation",
		})
	end
end

---Run `cmd` in `cwd`, streaming stdout and stderr into the compilation buffer.
---@param cmd string
---@param cwd string
function M.command(cmd, cwd)
	local prev = running[cwd]
	if prev then
		running[cwd] = nil
		prev:kill("sigkill")
	end

	last_command[cwd] = cmd

	local buf = open_window()
	append(buf, { cwd .. " > " .. cmd, "" })

	local obj = vim.system({ "sh", "-c", cmd }, {
		cwd = cwd,
		text = true,
		stdout = function(_, data)
			if data and #vim.trim(data) > 0 then
				vim.schedule(function()
					append(buf, vim.split(data, "\n", { trimempty = true }))
				end)
			end
		end,
		stderr = function(_, data)
			if data and #vim.trim(data) > 0 then
				vim.schedule(function()
					append(buf, vim.split(data, "\n", { trimempty = true }))
				end)
			end
		end,
	}, function(res)
		-- Only the newest process of this directory owns the state. A replaced
		-- process just reports its output.
		if running[cwd] == obj then
			running[cwd] = nil
		end
		vim.schedule(function()
			finish(buf, res.code)
		end)
	end)

	running[cwd] = obj
end

---Prompt for a command, pre-filled with the last one or the filetype default,
---and run it.
function M.prompt()
	local cwd = vim.uv.cwd() or "."
	vim.ui.input({
		prompt = "Compile: ",
		default = last_command[cwd] or default_for_ft(),
	}, function(input)
		if input and input ~= "" then
			M.command(input, cwd)
		end
	end)
end

---Rerun the last command of the current directory, or prompt when there is none.
function M.recompile()
	local cwd = vim.uv.cwd() or "."
	if last_command[cwd] then
		M.command(last_command[cwd], cwd)
	else
		M.prompt()
	end
end

---Kill the command running in the current directory.
function M.interrupt()
	local cwd = vim.uv.cwd() or "."
	local obj = running[cwd]
	if not obj then
		return
	end
	running[cwd] = nil
	obj:kill("sigkill")
	if compilation_buf and vim.api.nvim_buf_is_valid(compilation_buf) then
		append(compilation_buf, { "[Interrupted]" })
	end
end

---Register the commands and keymaps.
function M.setup()
	vim.api.nvim_create_user_command("Compile", function(opts)
		if opts.args ~= "" then
			M.command(opts.args, vim.uv.cwd() or ".")
		else
			M.prompt()
		end
	end, {
		nargs = "?",
		desc = "Compile: run a build command asynchronously into *compilation*",
	})

	vim.api.nvim_create_user_command("Recompile", function()
		M.recompile()
	end, { desc = "Compile: rerun the last command of this directory" })

	vim.api.nvim_create_user_command("CompileInterrupt", function()
		M.interrupt()
	end, { desc = "Compile: interrupt the running command" })

	local km = vim.keymap.set
	km("n", "<leader>cc", M.prompt, { desc = "Compile (prompt with default)" })
	km("n", "<leader>cr", M.recompile, { desc = "Recompile (last command)" })
	km("n", "<leader>ck", M.interrupt, { desc = "Compile: interrupt" })
end

return M
