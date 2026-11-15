-- lua/modules/templates.lua

-- Whole-file templates: `:Template <name>` fills the current empty buffer
-- with a ready structure - file header, shebang, package and class or main
-- skeleton - with the placeholders opening as LuaSnip jumps. Templates are
-- never applied automatically: only this command writes them, and only into
-- an empty buffer whose file does not exist yet, so a template can never
-- overwrite anything.
--
-- A template is a builder function returning a snippet node, composed from
-- the same header machinery the file-header snippets use: the header renders
-- in the filetype's comment style and the body is language-specific. The
-- registry is a table keyed by filetype and name, so completion lists
-- exactly what the current filetype offers.
--
-- The LuaSnip dependency is the plugin's public API only: node construction
-- and `snip_expand` for the programmatic expansion. `bash` and `zsh` buffers
-- have no registry entry yet; `sh` is the fallback when one is added.
--
-- `setup()` must be called once to register the :Template command.
--
-- See: lua/lib/headers.lua
-- See: lua/snippets/common.lua
-- See: doc/modules.txt

local M = {}

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local sn = ls.snippet_node

local h = require("lib.headers")

---Java package of the buffer: the path relative to the working directory,
---segments joined with dots. Everything up to a `java` path segment (the
---Maven and Gradle source root) is dropped, so a file under
---`src/main/java/com/foo/` gets `com.foo`; a file with no `java` segment
---uses its whole relative directory.
---@return string
local function java_package()
	local dir = vim.fn.expand("%:.:h")
	if dir == "." then
		return ""
	end
	return (dir:match(".-/java/(.+)$") or dir):gsub("/", ".")
end

---Renders the standard `head` header into `nodes` and returns the context
---the body continues from.
---@param nodes table
---@return HeaderContext ctx
local function head_into(nodes)
	return h.render(h.headers.head, vim.bo.filetype, nodes)
end

-- `java/class`: the standard header, the package derived from the buffer
-- path, and the class declaration named after the file, with a mirrored
-- constructor (Allman braces, as the reference skeletons use).
local function build_java_class(_, _)
	local nodes = {}
	local ctx = head_into(nodes)

	ctx.add(f(function()
		local pkg = java_package()
		if pkg == "" then
			return ""
		end
		return "package " .. pkg .. ";"
	end, {}))
	ctx.add(t({ "", "", "public class " }))
	ctx.add(f(h.get_basename, {}))
	ctx.add(t({ "", "{", "\tpublic " }))
	ctx.add(f(h.get_basename, {}))
	ctx.add(t({ "()", "", "\t{", "\t\t" }))
	ctx.add(i(ctx.idx, "constructor body"))
	ctx.idx = ctx.idx + 1
	ctx.add(t({ "", "\t}", "", "}" }))
	table.insert(nodes, i(0))
	return sn(nil, nodes)
end

-- `python/script`: the interpreter line, the standard header as a docstring
-- (Python headers carry no shebang, so the template adds the interpreter
-- line itself), and the main-function skeleton.
local function build_python_script(_, _)
	local nodes = { t({ h.shebang_by_ft[vim.bo.filetype] or "#!/usr/bin/env python3", "" }) }
	local ctx = head_into(nodes)

	ctx.add(t({ "def main():", "\t" }))
	ctx.add(i(ctx.idx, "main body"))
	ctx.idx = ctx.idx + 1
	ctx.add(t({ "", "", 'if __name__ == "__main__":', "\tmain()", "" }))
	table.insert(nodes, i(0))
	return sn(nil, nodes)
end

-- `sh/script`: the interpreter line, the standard header, and a POSIX main
-- function invoked once, so `set -e` applies everywhere it runs.
local function build_sh_script(_, _)
	local nodes = { t({ h.shebang_by_ft[vim.bo.filetype] or "#!/usr/bin/env sh", "" }) }
	local ctx = head_into(nodes)

	ctx.add(t({ "main() {", "\t" }))
	ctx.add(i(ctx.idx, "main body"))
	ctx.idx = ctx.idx + 1
	ctx.add(t({ "", "}", "", "", 'main "$@"', "" }))
	table.insert(nodes, i(0))
	return sn(nil, nodes)
end

-- `c/main`: the standard header and the `stdio.h` program skeleton.
local function build_c_main(_, _)
	local nodes = {}
	local ctx = head_into(nodes)

	ctx.add(t({ "#include <stdio.h>", "", "", "int main(int argc, char *argv[])", "{", "\t" }))
	ctx.add(i(ctx.idx, "main body"))
	ctx.idx = ctx.idx + 1
	ctx.add(t({ "", "\treturn 0;", "}" }))
	table.insert(nodes, i(0))
	return sn(nil, nodes)
end

-- `markdown/readme`: the standard header and the title named after the file.
local function build_readme(_, _)
	local nodes = {}
	local ctx = head_into(nodes)

	ctx.add(t("# "))
	ctx.add(f(h.get_basename, {}))
	ctx.add(t({ "", "" }))
	ctx.add(i(ctx.idx, "what this document covers"))
	ctx.idx = ctx.idx + 1
	ctx.add(t({ "", "" }))
	table.insert(nodes, i(0))
	return sn(nil, nodes)
end

-- The registry: builder functions by filetype and name. Completion reads
-- this table, so a new template is one entry here.
---@type table<string, table<string, fun(): table>>
local templates = {
	c = { main = build_c_main },
	java = { class = build_java_class },
	markdown = { readme = build_readme },
	python = { script = build_python_script },
	sh = { script = build_sh_script },
}

---Expands one template into the current buffer. A template exists only for
---the buffer's filetype; anything else notifies instead of expanding.
---@param name string Template name, as registered for the filetype.
function M.expand(name)
	local ft = vim.bo.filetype
	local builder = (templates[ft] or {})[name]
	if not builder then
		local where = ft ~= "" and ft or "this filetype"
		return vim.notify(("Template '%s' is not registered for %s."):format(name, where), vim.log.levels.WARN)
	end
	if vim.fn.filereadable(vim.fn.expand("%:p")) == 1 then
		return vim.notify("Template: the file already exists on disk.", vim.log.levels.WARN)
	end
	if vim.api.nvim_buf_line_count(0) > 1 or vim.fn.getline(1) ~= "" then
		return vim.notify("Template: the buffer is not empty.", vim.log.levels.WARN)
	end
	-- The expansion runs inside pcall, so a LuaSnip failure notifies instead
	-- of raising out of a user command.
	local ok, err = pcall(ls.snip_expand, s("", { d(1, builder, {}) }))
	if not ok then
		vim.notify(("Template '%s' failed to expand: %s"):format(name, err), vim.log.levels.ERROR)
	end
end

---Completes :Template with the names registered for the current filetype.
---@return string[]
function M.complete()
	local names = {}
	for name in pairs(templates[vim.bo.filetype] or {}) do
		table.insert(names, name)
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
