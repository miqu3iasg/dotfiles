-- lua/modules/compile.lua

-- Emacs-like compile runner for this config. It runs a build command through
-- `sh -c` asynchronously. The result is reported as a progress message and every
-- parsed error goes to the quickfix list.
--
-- State is per working directory, so a new compile kills the previous one.
-- `setup()` must run once, and `init.lua` calls it at startup.
--
-- See: doc/modules.md
-- See: lua/config/autocmds.lua
-- See: :help quickfix

local M = {}

---@class CompileConfig
---@field open boolean Open the output split on every run (default: false).

---@type CompileConfig
M.config = {
	open = false,
}

---@class CompileRun
---@field cwd string
---@field cmd string Expanded command line.
---@field obj vim.SystemObj?
---@field lines string[] Complete output lines, used to fill the quickfix list.
---@field log string[] Everything shown in the buffer (header, output, footer).
---@field partial string Incomplete last line of the stream.
---@field done boolean Finished, interrupted or replaced. Late events are ignored.
---@field msg_id integer|string? Id of the progress message.

---@type string
local BUFFER_NAME = "*compilation*"

---@type integer
local SPLIT_HEIGHT = 25

---@type boolean
local HAS_PROGRESS = vim.fn.has("nvim-0.12") == 1

---Default command per filetype. The "*" key is the fallback. These are
---templates: `%`, `%:r`, `%:t:r`, ... are expanded by `vim.fn.expandcmd` only
---when the command runs, always against the current file.
---@type table<string, string>
local DEFAULT_COMMAND = {
	["*"] = "make -k ",
	python = "python -u -X dev %",
	lua = "lua %",
	c = "cc -Wall -Wextra -g -o %:r.out % && ./%:r.out",
	cpp = "c++ -std = c++23 -Wall -Wextra -g -o %:r.out % && ./%:r.out",
	java = "javac -Xlint:all -d out % && java -ea -cp out %:t:r",
	javascript = "node --enable-source-maps --trace-warnings %",
	typescript = "npx tsc --noEmit --pretty false % && npx tsx %",
}

-- The severity (`%t`) is filled when the compiler prints it, so the summary
-- can tell errors from warnings.Every other line is dropped with `%-G`.
---@type string
local ERRORFORMAT = table.concat({
	"%f:%l:%c: fatal %trror: %m",
	"%f:%l:%c: %trror: %m",
	"%f:%l:%c: %tarning: %m",
	"%f:%l:%c: %tote: %m",
	"%f:%l: %trror: %m",
	"%f:%l: %tarning: %m",
	"%f(%l\\,%c): %trror %m",
	"%f(%l\\,%c): %tarning %m",
	"%f:%l:%c: %m",
	"%f:%l: %m",
	'%A  File "%f"\\, line %l\\, in %.%#',
	"%-C  %.%#",
	"%Z%[%^ ]%\\@=%m",
	"%-G%.%#",
}, ",")

---@type table<string, CompileRun>
local running = {}

---@type table<string, string>
local last_command = {}

---Newest run of any directory. Only this run writes into the buffer.
---@type CompileRun?
local current_run = nil

---@type integer?
local compilation_buf = nil

---Last real file buffer the user visited, used to expand `%` when the command
---is started from the *compilation* buffer or from an input popup.
---@type integer?
local last_file_buf = nil

local LEVEL = {
	success = vim.log.levels.INFO,
	failed = vim.log.levels.ERROR,
	cancel = vim.log.levels.WARN,
}

---Update the progress message of `run`. Without Neovim 0.12 progress messages,
---only the final status is shown, through `vim.notify`.
---@param run CompileRun
---@param status "running"|"success"|"failed"|"cancel"
---@param msg string
local function report(run, status, msg)
	if HAS_PROGRESS then
		local ok, id = pcall(vim.api.nvim_echo, { { msg } }, status ~= "running", {
			id = run.msg_id,
			kind = "progress",
			source = "compile",
			title = "Compile",
			status = status,
		})
		if ok then
			run.msg_id = id or run.msg_id
			return
		end
	end

	if status ~= "running" then
		vim.notify("Compile: " .. msg, LEVEL[status] or vim.log.levels.INFO)
	end
end

---Build the final status and message from the current quickfix list and the
---exit code. The exit code stays the source of truth: a non-zero exit with
---nothing parsed is never reported as "0 errors".
---@param code integer
---@return "success"|"failed" status
---@return string msg
local function summarize(code)
	local errors, warnings, first = 0, 0, nil

	for _, it in ipairs(vim.fn.getqflist({ items = 1 }).items) do
		if it.valid == 1 then
			local t = (it.type or ""):upper()
			if t == "W" then
				warnings = warnings + 1
			elseif t ~= "I" and t ~= "N" then
				errors = errors + 1
				first = first or it
			end
		end
	end

	local suffix = warnings > 0 and (", %d warning(s)"):format(warnings) or ""

	if code == 0 and errors == 0 then
		return "success", "0 errors" .. suffix
	end

	if errors == 0 then
		return "failed", ("exited %d, no errors parsed (see output)"):format(code) .. suffix
	end

	if errors == 1 and first then
		local name = "?"
		if first.bufnr > 0 then
			name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(first.bufnr), ":t")
		end
		local pos = first.col > 0 and ("%d:%d"):format(first.lnum, first.col) or tostring(first.lnum)
		local text = vim.trim((first.text:gsub("%s*\n%s*", " ")))
		return "failed", ("%s:%s: %s"):format(name, pos, text) .. suffix
	end

	return "failed", ("%d error(s)"):format(errors) .. suffix
end

---Buffer that `%` and the filetype refer to. This is the current buffer,
---unless it is a special one (the *compilation* buffer, quickfix, a prompt
---popup): then the last real file buffer is used.
---@return integer
local function context_buf()
	local cur = vim.api.nvim_get_current_buf()
	if vim.bo[cur].buftype == "" then
		return cur
	end
	if last_file_buf and vim.api.nvim_buf_is_valid(last_file_buf) then
		return last_file_buf
	end
	return cur
end

---Expand `%`, `%:r`, `%:t:r`, `#`, ... exactly like `:make` does.
---@param cmd string
---@return boolean ok
---@return string result Expanded command, or the error message.
local function expand(cmd)
	local ctx = context_buf()
	if ctx == vim.api.nvim_get_current_buf() then
		return pcall(vim.fn.expandcmd, cmd)
	end
	return pcall(vim.api.nvim_buf_call, ctx, function() return vim.fn.expandcmd(cmd) end)
end

---Return the default command template for the current filetype. It is not
---expanded here, see `expand`.
---@return string
local function default_for_ft()
	local ft = vim.bo[context_buf()].filetype
	return DEFAULT_COMMAND[ft] or DEFAULT_COMMAND["*"] or ""
end

---Scroll every window showing `buf` to the last line.
---@param buf integer
local function scroll_to_end(buf)
	local n = vim.api.nvim_buf_line_count(buf)
	for _, win in ipairs(vim.fn.win_findbuf(buf)) do
		vim.api.nvim_win_set_cursor(win, { n, 0 })
	end
end

---@param buf integer
---@param first integer
---@param last integer
---@param lines string[]
local function set_buf_lines(buf, first, last, lines)
	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, first, last, false, lines)
	vim.bo[buf].modifiable = false
	scroll_to_end(buf)
end

---@return boolean
local function buf_alive() return compilation_buf ~= nil and vim.api.nvim_buf_is_valid(compilation_buf) end

---Return the compilation buffer, creating it when needed. A new buffer is
---filled from the log of the current run, so nothing is lost if the old
---buffer was wiped while a command was running.
---@return integer
local function ensure_buf()
	if buf_alive() then
		return compilation_buf --[[@as integer]]
	end

	local buf = vim.api.nvim_create_buf(false, true)
	compilation_buf = buf
	pcall(vim.api.nvim_buf_set_name, buf, BUFFER_NAME)

	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].swapfile = false
	vim.bo[buf].bufhidden = "hide"
	vim.bo[buf].buflisted = false
	vim.bo[buf].errorformat = ERRORFORMAT
	-- The `qf` filetype makes the close_utility_buffers autocmd handle this
	-- buffer.
	vim.bo[buf].filetype = "qf"

	set_buf_lines(buf, 0, -1, current_run and current_run.log or {})
	return buf
end

---Window of the current tabpage showing `buf`, if any.
---@param buf integer
---@return integer?
local function visible_win(buf)
	local tab = vim.api.nvim_get_current_tabpage()
	for _, win in ipairs(vim.fn.win_findbuf(buf)) do
		if vim.api.nvim_win_get_tabpage(win) == tab then
			return win
		end
	end
end

---Show `buf` in a bottom split, reusing the window when it is already visible.
---@param buf integer
---@param focus boolean Move the cursor to the output window.
local function show(buf, focus)
	local existing = visible_win(buf)
	if existing then
		if focus then
			vim.api.nvim_set_current_win(existing)
		end
		return
	end

	local prev = vim.api.nvim_get_current_win()
	vim.cmd("rightbelow " .. SPLIT_HEIGHT .. "split")
	vim.api.nvim_win_set_buf(0, buf)
	scroll_to_end(buf)

	if not focus and vim.api.nvim_win_is_valid(prev) then
		vim.api.nvim_set_current_win(prev)
	end
end

---Append lines to the log of `run` and, if it is the newest run and the buffer
---exists, to the buffer too. This never creates the buffer or a window.
---@param run CompileRun
---@param lines string[]
local function append(run, lines)
	vim.list_extend(run.log, lines)

	if current_run ~= run or not buf_alive() then
		return
	end
	set_buf_lines(compilation_buf --[[@as integer]], -1, -1, lines)
end

---@param run CompileRun
---@param lines string[]
local function emit(run, lines)
	if #lines == 0 then
		return
	end

	for i, line in ipairs(lines) do
		lines[i] = (line:gsub("\r$", ""))
	end

	vim.list_extend(run.lines, lines)
	append(run, lines)

	-- The progress message follows the last non-blank line.
	for i = #lines, 1, -1 do
		if lines[i]:match("%S") then
			report(run, "running", lines[i])
			break
		end
	end
end

---Process a raw chunk. Chunks arrive split at arbitrary bytes, so only
---complete lines are emitted and the rest waits for the next chunk.
---@param run CompileRun
---@param data string
local function feed(run, data)
	if run.done then
		return
	end

	local parts = vim.split(run.partial .. data, "\n", { plain = true })
	run.partial = table.remove(parts) or ""
	emit(run, parts)
end

---Emit the pending partial line, when the stream ended without a newline.
---@param run CompileRun
local function flush(run)
	if run.done or run.partial == "" then
		return
	end
	local rest = run.partial
	run.partial = ""
	emit(run, { rest })
end

---Write the exit status, fill the quickfix list and report the result.
---@param run CompileRun
---@param code integer
local function finish(run, code)
	-- Interrupted or replaced runs were already closed by whoever did that.
	if run.done then
		return
	end
	run.done = true

	if running[run.cwd] == run then
		running[run.cwd] = nil
	end

	append(run, { ("[Exited %d]"):format(code) })

	-- Always replace the list, even on success, so it reflects the newest
	-- compile (warnings included). The errorformat is passed explicitly because
	-- quickfix commands would otherwise use the one from the current window.
	vim.fn.setqflist({}, " ", {
		lines = run.lines,
		efm = ERRORFORMAT,
		title = "compilation: " .. run.cmd,
	})

	local status, msg = summarize(code)
	report(run, status, msg)
end

---Stop a run that is still going and mark it as closed.
---@param run CompileRun
---@param msg string
local function abort(run, msg)
	if run.done then
		return
	end
	run.done = true

	if running[run.cwd] == run then
		running[run.cwd] = nil
	end
	if run.obj then
		run.obj:kill("sigkill")
	end

	append(run, { "[" .. msg .. "]" })
	report(run, "cancel", msg:lower())
end

---Run `cmd` in `cwd`. `cmd` is a template: `%` and friends are expanded now,
---against the current file. Relative paths in the errors are resolved against
---Neovim's working directory, so `cwd` should normally be `vim.uv.cwd()`.
---@param cmd string
---@param cwd string
---@param opts? { open?: boolean } `open` shows the output split for this run.
function M.command(cmd, cwd, opts)
	opts = opts or {}

	-- This must happen before any window is opened: afterwards the current
	-- buffer could be *compilation* and `%` would not mean the file anymore.
	local ok, expanded = expand(cmd)
	if not ok then
		vim.notify("Compile: " .. tostring(expanded), vim.log.levels.ERROR)
		return
	end

	local prev = running[cwd]
	if prev then
		abort(prev, "Replaced")
	end

	-- Stored as a template, so the next run uses the file that is current then.
	last_command[cwd] = cmd

	---@type CompileRun
	local run = {
		cwd = cwd,
		cmd = expanded,
		lines = {},
		log = { cwd .. " > " .. expanded, "" },
		partial = "",
		done = false,
	}
	current_run = run
	running[cwd] = run

	if buf_alive() then
		set_buf_lines(compilation_buf --[[@as integer]], 0, -1, run.log)
	end
	if M.config.open or opts.open then
		show(ensure_buf(), false)
	end

	report(run, "running", expanded)

	-- `exec 2>&1` merges stderr into stdout, so the lines keep their real order
	-- and there is a single stream to reassemble.
	local spawned, obj = pcall(vim.system, { "sh", "-c", "exec 2>&1\n" .. expanded }, {
		cwd = cwd,
		text = true,
		stdout = function(_, data)
			if data then
				vim.schedule(function() feed(run, data) end)
			end
		end,
	}, function(res)
		local code = res.code
		if res.signal and res.signal ~= 0 then
			code = 128 + res.signal
		end
		vim.schedule(function()
			flush(run)
			finish(run, code)
		end)
	end)

	if not spawned then
		run.done = true
		running[cwd] = nil
		append(run, { "[Failed to start: " .. tostring(obj) .. "]" })
		report(run, "failed", "failed to start: " .. tostring(obj))
		return
	end

	run.obj = obj
end

---Prompt for a command, pre-filled with the last one or the filetype default,
---and run it.
---@param opts? { open?: boolean }
function M.prompt(opts)
	local cwd = vim.uv.cwd() or "."
	vim.ui.input({
		prompt = "Compile: ",
		default = last_command[cwd] or default_for_ft(),
	}, function(input)
		if input and input ~= "" then
			M.command(input, cwd, opts)
		end
	end)
end

---Prompt for a custom command with an empty input and run it. Unlike
---`M.prompt`, nothing is pre-filled. `%` and friends are still expanded.
---@param opts? { open?: boolean }
function M.custom(opts)
	local cwd = vim.uv.cwd() or "."
	vim.ui.input({
		prompt = "Compile command: ",
		completion = "shellcmd",
	}, function(input)
		if input and vim.trim(input) ~= "" then
			M.command(input, cwd, opts)
		end
	end)
end

---Rerun the last command of the current directory, or prompt when there is none.
---@param opts? { open?: boolean }
function M.recompile(opts)
	local cwd = vim.uv.cwd() or "."
	if last_command[cwd] then
		M.command(last_command[cwd], cwd, opts)
	else
		M.prompt(opts)
	end
end

---Kill the command running in the current directory.
function M.interrupt()
	local run = running[vim.uv.cwd() or "."]
	if not run then
		vim.notify("Compile: nothing is running in this directory", vim.log.levels.INFO)
		return
	end
	abort(run, "Interrupted")
end

---Open the output of the last run in a bottom split and focus it.
function M.show_output()
	if not current_run then
		vim.notify("Compile: nothing has been run yet", vim.log.levels.WARN)
		return
	end
	show(ensure_buf(), true)
end

---Register the commands and keymaps.
---@param opts? CompileConfig
function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})

	local function remember(buf)
		if vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
			last_file_buf = buf
		end
	end
	remember(vim.api.nvim_get_current_buf())
	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("compile_module", { clear = true }),
		desc = "Compile: remember the last file buffer to expand % from",
		callback = function(args) remember(args.buf) end,
	})

	vim.api.nvim_create_user_command("Compile", function(cmd)
		local o = { open = cmd.bang }
		if cmd.args ~= "" then
			M.command(cmd.args, vim.uv.cwd() or ".", o)
		else
			M.prompt(o)
		end
	end, {
		nargs = "?",
		bang = true,
		desc = "Compile: run a build command asynchronously (! also opens the output)",
	})

	vim.api.nvim_create_user_command("Recompile", function(cmd) M.recompile({ open = cmd.bang }) end, {
		bang = true,
		desc = "Compile: rerun the last command of this directory (! also opens the output)",
	})

	vim.api.nvim_create_user_command("CompileCustom", function(cmd) M.custom({ open = cmd.bang }) end, {
		bang = true,
		desc = "Compile: run a custom command from an empty prompt (! also opens the output)",
	})

	vim.api.nvim_create_user_command(
		"CompileInterrupt",
		function() M.interrupt() end,
		{ desc = "Compile: interrupt the running command" }
	)

	vim.api.nvim_create_user_command(
		"CompileOutput",
		function() M.show_output() end,
		{ desc = "Compile: open the output of the last run" }
	)

	local km = vim.keymap.set

	km("n", "<leader>cc", function() M.prompt() end, { desc = "Compile (prompt with default)" })
	km("n", "<leader>cr", function() M.recompile() end, { desc = "Recompile (last command)" })
	km("n", "<leader>cl", function() M.custom() end, { desc = "Compile (custom command)" })
	km("n", "<leader>ck", M.interrupt, { desc = "Compile: interrupt" })
	km("n", "<leader>co", M.show_output, { desc = "Compile: open output" })
end

return M
