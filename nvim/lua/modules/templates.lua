-- lua/modules/templates.lua

-- Whole-file templates: `:Template <name>` fills the current empty buffer
-- with a ready structure - file header, shebang, package and class or main
-- skeleton - with the placeholders opening as LuaSnip jumps. Templates are
-- never applied automatically: only this command writes them, and only into
-- an empty buffer whose file is empty on disk or does not exist, so a
-- template can never overwrite content.
--
-- A template is a data file under templates/<name>, not code: the body is
-- the file itself, and the placeholders inside it open as jumps. The
-- grammar is single-line:
--
--     {{+default+}}   editable placeholder; `default` is its initial text
--     {{++}}          editable placeholder without a default
--     {{+~expr+}}     evaluated at expansion time (see `exprs` below)
--     {{+@head+}}     the standard file header of lib/headers.lua; any spec
--                     name works, e.g. `{{+@shead+}}`
--
-- shortcut: placeholders are single-line; a placeholder cannot span lines,
-- so a multi-line default is impossible - upgrade the parser when a
-- template needs one.
--
-- The name is the file's basename, extension included, and one file is one
-- template: there is no mapping between the extension and the buffer's
-- filetype, so the expressions (`{{+~expr+}}`) and the header spec
-- (`{{+@head+}}`) always render in the buffer's own filetype. Files are
-- found through the runtimepath, so another rtp entry can add or override
-- templates without touching this config.
--
-- The LuaSnip dependency is the plugin's public API only: node construction
-- and `snip_expand` for the programmatic expansion.
--
-- `setup()` must be called once to register the :Template command.
--
-- See: templates/                  the template files
-- See: lua/lib/headers.lua
-- See: lua/snippets/common.lua
-- See: doc/modules.txt

local M = {}

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

local h = require("lib.headers")

---Java package statement of the buffer: the path relative to the working
---directory, segments joined with dots. Everything up to a `java` path
---segment (the Maven and Gradle source root) is dropped, so a file under
---`src/main/java/com/foo/` gets `package com.foo;`; a file with no `java`
---segment uses its whole relative directory, and a file at the working
---directory gets an empty statement, leaving the line blank.
---@return string
local function java_package()
	local dir = vim.fn.expand("%:.:h")
	if dir == "." then
		return ""
	end
	local pkg = (dir:match(".-/java/(.+)$") or dir):gsub("/", ".")
	return "package " .. pkg .. ";"
end

---Expressions available to `{{+~expr+}}` placeholders, evaluated at
---expansion time in the buffer's context.
---@type table<string, fun(): string>
local exprs = {
	shebang = function()
		return h.shebang_by_ft[vim.bo.filetype] or "#!/usr/bin/env sh"
	end,
	filename = h.get_filename,
	basename = h.get_basename,
	relpath = h.get_relpath,
	date = h.get_date,
	year = h.get_year,
	package = java_package,
}

---Parses the placeholder grammar of one template file into LuaSnip nodes.
---Text between placeholders accumulates with one `\n` per file line and is
---flushed as a single text node at the next placeholder. When the previous
---emission already ended its line, a leading `\n` would draw a blank line
---the file does not have, so it is dropped.
---@param path string Template file path, for parse error messages.
---@param lines string[] File lines, without their terminators.
---@param ft string Filetype the template expands into.
---@return table? nodes
---@return string? err
local function parse(path, lines, ft)
	local nodes = {}
	local idx = 1
	local text = ""
	local at_line_start = true

	local function flush()
		if at_line_start and text:sub(1, 1) == "\n" then
			text = text:sub(2)
		end
		if text ~= "" then
			-- LuaSnip text nodes take lines, not strings with newlines.
			table.insert(nodes, t(vim.split(text, "\n")))
			at_line_start = text:sub(-1) == "\n"
			text = ""
		end
	end

	for n, line in ipairs(lines) do
		local pos = 1
		while true do
			local open = line:find("{{+", pos, true)
			if not open then
				break
			end
			local close = line:find("+}}", open + 3, true)
			if not close then
				return nil, ("%s:%d: placeholder without `+}}`"):format(path, n)
			end
			local inner = line:sub(open + 3, close - 1)
			text = text .. line:sub(pos, open - 1)
			flush()
			pos = close + 3

			if inner:sub(1, 1) == "~" then
				local expr = exprs[inner:sub(2)]
				if not expr then
					return nil, ("%s:%d: unknown expression `%s`"):format(path, n, inner:sub(2))
				end
				table.insert(nodes, f(expr, {}))
				at_line_start = false
			elseif inner:sub(1, 1) == "@" then
				local spec = h.headers[inner:sub(2)]
				if not spec then
					return nil, ("%s:%d: unknown header spec `%s`"):format(path, n, inner:sub(2))
				end
				h.render(spec, ft, nodes)
				at_line_start = true
			else
				table.insert(nodes, i(idx, inner))
				idx = idx + 1
				at_line_start = false
			end
		end
		text = text .. line:sub(pos) .. "\n"
	end
	-- The file's last line carries no terminator, so the `\n` appended
	-- above it is dropped: without this, the final flush would emit a
	-- blank line after the template's last line.
	text = text:sub(1, -2)
	flush()
	-- The exit cursor sits right after the last line of the template.
	table.insert(nodes, i(0))
	return nodes
end

---Paths of the template files, searched on the runtimepath. The config
---directory often sits on the runtimepath twice (its real path and its
---symlink under .config), so entries are deduplicated by real path.
---@return string[]
local function files()
	local seen = {}
	local files = {}
	for _, path in ipairs(vim.fn.globpath(vim.o.runtimepath, "templates/*", 0, 1)) do
		local real = vim.uv.fs_realpath(path)
		if real and not seen[real] then
			seen[real] = true
			table.insert(files, path)
		end
	end
	return files
end

---Name of a template file: its basename, extension included.
---@param path string
---@return string
local function name_of(path)
	return vim.fn.fnamemodify(path, ":t")
end

---Expands one template into the current buffer. Anything that fails - an
---unknown name, a buffer with content, a file with content on disk, a
---broken template - notifies instead of expanding.
---@param name string Template name, the file's basename.
function M.expand(name)
	local path
	for _, file in ipairs(files()) do
		if name_of(file) == name then
			path = file
			break
		end
	end
	if not path then
		return vim.notify(("Template '%s' does not exist."):format(name), vim.log.levels.WARN)
	end
	-- A template fills an empty buffer only: the file may not exist or be
	-- empty on disk, but never have content. Whitespace-only files count as
	-- empty, so a file created beforehand still takes a template. An unnamed
	-- buffer has no disk file to check.
	local disk_file = vim.fn.expand("%")
	if disk_file ~= "" and vim.fn.filereadable(vim.fn.expand("%:p")) == 1 then
		for _, line in ipairs(vim.fn.readfile(vim.fn.expand("%:p"))) do
			if line ~= "" then
				return vim.notify("Template: the file already has content on disk.", vim.log.levels.WARN)
			end
		end
	end
	if vim.api.nvim_buf_line_count(0) > 1 or vim.fn.getline(1) ~= "" then
		return vim.notify("Template: the buffer is not empty.", vim.log.levels.WARN)
	end
	-- Parsing and expansion run inside pcall, so a broken template file
	-- notifies instead of raising out of a user command.
	local ft = vim.bo.filetype
	local ok, err = pcall(function()
		local nodes, perr = parse(path, vim.fn.readfile(path), ft)
		if not nodes then
			error(perr, 0)
		end
		ls.snip_expand(s("", nodes))
	end)
	if not ok then
		vim.notify(("Template '%s' failed to expand: %s"):format(name, err), vim.log.levels.ERROR)
	end
end

---Completes :Template with the names of all template files.
---@return string[]
function M.complete()
	local names = {}
	for _, file in ipairs(files()) do
		table.insert(names, name_of(file))
	end
	table.sort(names)
	return names
end

---Registers the :Template command. Called once from init.lua.
function M.setup()
	vim.api.nvim_create_user_command("Template", function(opts)
		M.expand(opts.args)
	end, {
		nargs = 1,
		complete = function(...)
			return M.complete(...)
		end,
	})
end

return M
