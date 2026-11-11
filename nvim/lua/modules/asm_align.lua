-- lua/modules/asm_align.lua

-- Column alignment for assembly buffers, following the layout that `asmfmt`
-- produces: tabs for indentation and spaces for alignment, instructions and
-- operands aligned per block and end-of-line comments aligned to one column.
--
-- The alignment pass is a direct port of asmfmt (`formatStatements` and the
-- block grouping in `asmfmt.go`), so aligning here matches what the formatter
-- writes: labels, `#` directives and the Go assembly directives (TEXT, DATA,
-- GLOBL, FUNCDATA, PCDATA) are blocks of their own, and RET and JMP close a
-- block. Lines are never added, removed or reordered, and comment-only lines
-- are left untouched; structural changes (labels on their own line, blank
-- lines before labels and comments) are left to asmfmt, which conform runs on
-- format.
--
-- The parser recognizes the same dialect as asmfmt: `//` line comments, `;` as
-- an instruction separator and `,` as the operand separator, with operands
-- joined back as `, `. Inline `/* */` comments are kept, and macro calls
-- registered by `#define` count as one operand column of their own, as in
-- asmfmt.
--
-- See: after/ftplugin/asm.lua
-- See: lua/plugins/formatting.lua (asmfmt)
-- See: https://github.com/klauspost/asmfmt/blob/master/asmfmt.go

local M = {}

---Go assembly directives that asmfmt keeps at indentation level 0.
local level0_directives = { TEXT = true, DATA = true, GLOBL = true, FUNCDATA = true, PCDATA = true }

---Instructions after which asmfmt closes a block.
local block_enders = { RET = true, JMP = true }

---Character count, matching the rune counting of asmfmt.
---@param s string
---@return integer
local function clen(s)
	return vim.fn.strchars(s)
end

---Trims leading and trailing whitespace.
---@param s string
---@return string
local function trim(s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

---Splits the trailing `//` comment from a line, ignoring `//` inside string
---literals. Returns the statement text, and the comment text without the
---marker when there is one.
---@param s string
---@return string statement
---@return string? comment
local function split_comment(s)
	local in_string = false
	for i = 1, #s - 1 do
		local c = s:sub(i, i)
		if c == '"' and s:sub(i - 1, i - 1) ~= "\\" then
			in_string = not in_string
		elseif not in_string and c == "/" and s:sub(i + 1, i + 1) == "/" then
			return trim(s:sub(1, i - 1)), trim(s:sub(i + 2))
		end
	end
	return s, nil
end

---A parsed statement.
---@class AsmAlign.Statement
---@field kind "comment"|"statement"
---@field text? string Original text of a comment-only line.
---@field instruction string First word, or the whole line for labels with code and macro calls.
---@field params string[] Operands; empty when there are none.
---@field comment? string End-of-line comment without the `//` marker.
---@field label? boolean First word ends with `:`.
---@field pre? boolean `#` directive.
---@field global? boolean Go assembly directive at indentation level 0.
---@field function_call? boolean Macro call or parameterless statement; excluded from the column widths.
---@field continued? boolean Ends with `\`, continuing on the next line.

---Port of `setParams`: splits on commas outside literals and inline comments,
---keeps `/* */` comments, joins `;`-separated instructions with spaces and
---replaces tabs, matching asmfmt operand by operand.
---@param s string Statement without the instruction.
---@param pre boolean `#` directive, whose tabs asmfmt keeps.
---@return string[]
local function split_params(s, pre)
	local params = {}
	local buf = {}
	local in_comment, in_string, in_char = false, false, false
	local last
	local function flush()
		local piece = trim(table.concat(buf))
		buf = {}
		if piece ~= "" then
			params[#params + 1] = piece
		end
	end
	local i = 1
	while i <= #s do
		local c = s:sub(i, i)
		if c == '"' and last ~= "\\" then
			in_string = not in_string
			buf[#buf + 1] = c
		elseif c == "'" and last ~= "\\" then
			in_char = not in_char
			buf[#buf + 1] = c
		elseif c == "," and not (in_comment or in_string or in_char) then
			flush()
		elseif c == "/" and last == "*" and in_comment then
			in_comment = false
			buf[#buf + 1] = c
		elseif c == "*" and last == "/" then
			in_comment = true
			buf[#buf + 1] = c
		elseif c == "\t" then
			buf[#buf + 1] = pre and c or " "
		elseif c == ";" and not (in_comment or in_string or in_char) then
			buf = { trim(table.concat(buf)) .. "; " }
			while s:sub(i + 1, i + 1):match("^%s$") do
				i = i + 1
			end
		else
			buf[#buf + 1] = c
		end
		last = c
		i = i + 1
	end
	flush()
	return params
end

---Port of `newStatement`: parses one line into a statement, or returns nil for
---empty lines.
---@param line string
---@param defines table<string, boolean> Macro names registered by `#define`.
---@return AsmAlign.Statement?
local function new_statement(line, defines)
	local s = trim(line)
	if s == "" then
		return nil
	end

	if s:sub(1, 2) == "//" then
		return { kind = "comment", text = s }
	end

	-- Port of the single-line block comment conversion of addLine: a `/* ... */`
	-- that ends the line becomes a trailing `//` comment on the statement, as
	-- long as no `//` comment comes before it.
	local bstart = s:find("/*", 1, true)
	if bstart and bstart > 1 then
		local lcom = s:find("//", 1, true)
		local bend = s:find("*/", bstart + 2, true)
		if bend and bend >= #s - 2 and s:sub(-1) ~= "\\" and not (lcom and lcom < bstart) then
			s = trim(s:sub(1, bstart - 1)) .. " //" .. trim(s:sub(bstart + 2, bend - 1))
		end
	end

	local stmt, comment = split_comment(s)
	if stmt == "" then
		return { kind = "comment", text = s }
	end

	---@type AsmAlign.Statement
	local st = { kind = "statement", params = {} }
	st.comment = comment ~= "" and comment or nil

	local words = {}
	for word in stmt:gmatch("%S+") do
		words[#words + 1] = word
	end
	st.label = words[1]:sub(-1) == ":"
	st.pre = words[1]:sub(1, 1) == "#"
	st.global = not st.label and level0_directives[words[1]:upper()] == true

	st.instruction = words[1]

	-- asmfmt turns a `\` line that carries a comment into a verbatim
	-- continuation, keeping the comment and its spacing.
	if st.instruction == "\\" and st.comment then
		st.instruction = "\\ // " .. st.comment
		st.function_call = true
		st.continued = true
		st.cont_comment = true
		return st
	end

	-- Macro call detection, as in asmfmt: names seen in `#define`, anything
	-- with a parenthesis or underscore in the first word, or a `/*` line. The
	-- whole line becomes one operand column of its own.
	local head = words[1]:match("^[^(]*")
	if defines[head] or words[1]:find("(", 1, true) or words[1]:find("_", 1, true) or stmt:sub(1, 2) == "/*" then
		st.function_call = true
		st.instruction = stmt:gsub("\t", " ")
		st.params = {}
		-- asmfmt strips a trailing `;` when the statement has no operands.
		st.instruction = (st.instruction:gsub(";$", ""))
		if st.instruction:sub(-1) == "\\" then
			st.instruction = trim(st.instruction:sub(1, -2))
			st.continued = true
		end
		return st
	end

	st.params = split_params(trim(stmt:sub(#words[1] + 1)), st.pre)
	if #st.params > 0 then
		st.params[#st.params] = (st.params[#st.params]:gsub(";$", ""))
	else
		st.instruction = (st.instruction:gsub(";$", ""))
	end
	if #st.params > 0 then
		local last_param = st.params[#st.params]
		if last_param:sub(-1) == "\\" then
			st.params[#st.params] = trim(last_param:sub(1, -2))
			if st.params[#st.params] == "" then
				st.params[#st.params] = nil
			end
			st.continued = true
		end
	elseif st.instruction:sub(-1) == "\\" then
		st.instruction = trim(st.instruction:sub(1, -2))
		st.continued = true
	end
	if #st.params == 0 and not st.label then
		st.function_call = true
	end
	return st
end

---Whether the instruction is written in uppercase, asmfmt's `isCommand` test.
---@param st AsmAlign.Statement
---@return boolean
local function is_command(st)
	return not st.label and st.instruction == st.instruction:upper()
end

---Port of `formatStatements`: computes the column widths of one block and
---returns each statement as an aligned line.
---@param statements AsmAlign.Statement[]
---@param tabs integer Indentation level in tabs.
---@return string[]
local function format_block(statements, tabs)
	local max_instr, max_alone, max_param = 0, 0, 0
	for _, st in ipairs(statements) do
		-- Port of `cleanParams`: normalize whitespace before a trailing `;`.
		if st.instruction:sub(-1) == ";" then
			st.instruction = trim(st.instruction:sub(1, -2)) .. ";"
		end
		local il = clen(st.instruction) + 1
		if il > max_instr and not st.function_call and not (is_command(st) and #st.params == 0) then
			max_instr = il
		end
		if st.function_call and il > max_alone then
			max_alone = il
		end
		local l = #st.params > 1 and 2 * (#st.params - 1) or 0
		for _, param in ipairs(st.params) do
			l = l + clen(param)
		end
		if l + 1 > max_param then
			max_param = l + 1
		end
	end
	max_param = max_param + max_instr
	if max_instr == 0 then
		max_instr = max_alone
	end

	local lines = {}
	for _, st in ipairs(statements) do
		local r
		if st.cont_comment then
			r = st.instruction
		else
			r = st.instruction
			if #st.params > 0 or st.comment then
				r = r .. string.rep(" ", math.max(0, max_instr - clen(r)))
			end
			r = r .. table.concat(st.params, ", ")
			if st.comment and not st.continued then
				r = r .. string.rep(" ", math.max(0, max_param - clen(r)))
				r = r .. "// " .. st.comment
			end
			if st.continued then
				local pad = max_param - clen(r)
				if max_alone > max_param then
					pad = max_alone - clen(r)
				end
				r = r .. string.rep(" ", math.max(0, pad)) .. "\\"
				if st.comment then
					r = r .. " // " .. st.comment
				end
			end
		end
		lines[#lines + 1] = string.rep("\t", tabs) .. r
	end
	return lines
end

---Registers the macro names defined by `#define` lines, like the defines map
---of asmfmt.
---@param lines string[]
---@return table<string, boolean>
local function collect_defines(lines)
	local defines = {}
	for _, line in ipairs(lines) do
		local name = trim(line):match("^#define%s+([^%s(]+)")
		if name then
			defines[name] = true
		end
	end
	return defines
end

---Aligns the assembly statements in `lines` and returns the new lines. Lines
---are never added, removed or reordered.
---@param lines string[]
---@return string[]
function M.align(lines)
	local defines = collect_defines(lines)
	local out = {}
	local group = {}
	local pending = {} ---Comments waiting for the indentation of the next flush.
	local group_tabs = 0
	local last_continued = false ---The previous statement ended with `\`.
	local in_block = false

	local function flush(tabs)
		-- asmfmt prints queued comments before the statements of the flush.
		for _, text in ipairs(pending) do
			out[#out + 1] = ("\t"):rep(tabs) .. text
		end
		pending = {}
		if #group > 0 then
			vim.list_extend(out, format_block(group, group_tabs))
			group = {}
		end
	end

	for _, line in ipairs(lines) do
		local trimmed = trim(line)

		if in_block then
			-- Inside a `/* */` comment asmfmt passes the lines through.
			out[#out + 1] = line
			if trimmed:find("*/", 1, true) then
				in_block = false
			end
		else
			local st = new_statement(line, defines)
			if not st then
				flush(group_tabs)
				-- A blank line inside a continuation chain returns the
				-- indentation to level 0, as in asmfmt.
				if last_continued then
					group_tabs = 0
					last_continued = false
				end
				out[#out + 1] = line
			elseif st.kind == "comment" then
				-- asmfmt only flushes the queue when statements are queued,
				-- so pending comments keep waiting for the next flush.
				if #group > 0 then
					flush(group_tabs)
				end
				pending[#pending + 1] = st.text
			elseif trimmed:sub(1, 2) == "/*" and trimmed:sub(-1) ~= "\\" then
				-- A `/*` line without a `\` opens a block comment, which asmfmt
				-- passes through raw. With a `\` it is a normal statement.
				flush(group_tabs)
				out[#out + 1] = line
				if not trimmed:find("*/", 3, true) then
					in_block = true
				end
			elseif (st.label or st.pre or st.global) and not (st.continued and last_continued) then
				-- asmfmt flushes level 0 statements on their own, and drops
				-- pending comments to level 0 when a Go directive follows with
				-- no statements queued, as with function header comments.
				local drop = st.global and #group == 0 and #pending > 0
				flush(drop and 0 or group_tabs)
				vim.list_extend(out, format_block({ st }, 0))
				-- TEXT and labels return the indentation to level 1, `#`
				-- directives and the other Go directives keep it at level 0.
				if st.pre or (st.global and st.instruction:upper() ~= "TEXT") then
					group_tabs = 0
				else
					group_tabs = 1
				end
			else
				group[#group + 1] = st
				if block_enders[st.instruction:upper()] or (last_continued and not st.continued) then
					-- RET and JMP close a block at level 1, and so does the
					-- last line of a continuation chain. Both return the
					-- indentation to level 0.
					group_tabs = 1
					flush(group_tabs)
					group_tabs = 0
				elseif is_command(st) then
					-- Uppercase instructions raise the indentation to level 1,
					-- as in asmfmt, where lowercase mnemonics keep the current
					-- level.
					group_tabs = 1
				end
				last_continued = st.continued
			end
		end
	end
	flush(group_tabs)
	return out
end

---Role of a line for block detection: `"blank"`, `"edge"` (blank, comment-only
---or level 0 statement), `"terminator"` (RET or JMP) or `"statement"`.
---@param line string
---@return "blank"|"edge"|"terminator"|"statement"
local function line_role(line)
	local trimmed = trim(line)
	if trimmed:sub(1, 2) == "/*" or trimmed:sub(1, 2) == "*/" or trimmed:sub(1, 1) == "*" then
		return "edge"
	end
	local st = new_statement(line, {})
	if not st then
		return "blank"
	end
	if st.kind == "comment" or st.label or st.pre or st.global then
		return "edge"
	end
	if block_enders[st.instruction:upper()] then
		return "terminator"
	end
	return "statement"
end

---Range of the alignment block around the 1-based `row`, the run of statements
---not separated by blank lines, comments, level 0 statements or RET/JMP.
---@param bufnr integer
---@param row integer
---@return integer start_row
---@return integer end_row
function M.block(bufnr, row)
	local function role_at(i)
		return line_role(vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1])
	end

	local start_row, end_row = row, row
	for i = row - 1, 1, -1 do
		if role_at(i) ~= "statement" then
			break
		end
		start_row = i
	end
	if role_at(row) ~= "terminator" then
		for i = row + 1, vim.api.nvim_buf_line_count(bufnr) do
			if role_at(i) ~= "statement" then
				break
			end
			end_row = i
		end
	end
	return start_row, end_row
end

---Aligns a 1-based, end-inclusive buffer range in place.
---@param bufnr integer
---@param start_row integer
---@param end_row integer
function M.range(bufnr, start_row, end_row)
	local lines = vim.api.nvim_buf_get_lines(bufnr, start_row - 1, end_row, false)
	vim.api.nvim_buf_set_lines(bufnr, start_row - 1, end_row, false, M.align(lines))
end

---Keymap wrapper. In normal mode the range is the alignment block around the
---cursor; in visual mode it is the selection, which stays active afterwards.
---@return fun()
function M.action()
	return function()
		local mode = vim.fn.mode()
		if mode == "v" or mode == "V" or mode == "\22" then
			local l1, l2 = vim.fn.line("v"), vim.fn.line(".")
			if l1 > l2 then
				l1, l2 = l2, l1
			end
			M.range(0, l1, l2)
			vim.cmd("normal! gv")
		else
			local start_row, end_row = M.block(0, vim.fn.line("."))
			M.range(0, start_row, end_row)
		end
	end
end

return M
