-- lua/lib/headers.lua

-- Comment and file-header machinery for the snippets, with comment styles per
-- filetype, shebangs, filename helpers, the `H.*` field constructors and the
-- header specs.
--
-- The Lua opener and closer are built by concatenation so this file does not
-- contain a literal long-bracket delimiter.
--
-- See: doc/snippets.txt
-- See: lua/snippets/common.lua
-- See: https://spdx.dev/ids/

local ls = require("luasnip")
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local sn = ls.snippet_node
local rep = require("luasnip.extras").rep

local M = {}

---Today's date in ISO format, used in the Created header field.
---@return string
local function get_date()
	return os.date("%Y-%m-%d")
end

---Current year, used in copyright notices.
---@return string
local function get_year()
	return os.date("%Y")
end

-- The helpers below fall back to "untitled" for unnamed buffers.
---Name of the current buffer file, including its extension.
---@return string
local function get_filename()
	local name = vim.fn.expand("%:t")
	return name ~= "" and name or "untitled"
end

---Path relative to the working directory.
---@return string
local function get_relpath()
	local path = vim.fn.expand("%:.")
	if path == "" then
		return "untitled"
	end
	return path
end

---File name without its extension.
---@return string
local function get_basename()
	local name = vim.fn.expand("%:t:r")
	return name ~= "" and name or "untitled"
end

---Describes how a header or inline comment is written for a filetype.
---A "line" style prefixes every line with `sym`. A "block" style wraps the
---content in `open` and `close`. A "docstring" style (Python only) is a
---list of opening lines followed by a closing delimiter.
---@class CommentStyle
---@field kind "line"|"block"|"docstring"
---@field sym? string Line comment symbol, for "line" styles.
---@field open? string|string[] Opener of a block or docstring style.
---@field close? string Closer of a block or docstring style.
---@field mid? string Prefix of each content line in a block style. Defaults to " * ".
---@field close_indent? string Whitespace before the block closer. Defaults to " ".

local C_BLOCK = { kind = "block", open = "/*", close = "*/" }
local HTML_BLOCK = { kind = "block", open = "<!--", close = "-->" }

-- File header comment style per filetype. Lisp and scheme use ";;;" by
-- convention, and filetypes without a block comment stay on line comments.
---@type table<string, CommentStyle>
local comment_styles = {
	lua = { kind = "block", open = "-" .. "-[" .. "[", close = "]" .. "]", mid = "  ", close_indent = "" },
	sh = { kind = "line", sym = "#" },
	bash = { kind = "line", sym = "#" },
	zsh = { kind = "line", sym = "#" },
	yaml = { kind = "line", sym = "#" },
	toml = { kind = "line", sym = "#" },
	vim = { kind = "line", sym = '"' },
	zig = { kind = "line", sym = "//" },
	scheme = { kind = "line", sym = ";;;" },
	lisp = { kind = "line", sym = ";;;" },
	c = C_BLOCK,
	cpp = C_BLOCK,
	cs = C_BLOCK,
	java = C_BLOCK,
	javascript = C_BLOCK,
	typescript = C_BLOCK,
	rust = C_BLOCK,
	php = C_BLOCK,
	sql = C_BLOCK,
	kotlin = C_BLOCK,
	haskell = { kind = "block", open = "{-", close = "-}", mid = "  ", close_indent = "" },
	html = HTML_BLOCK,
	xml = HTML_BLOCK,
	markdown = HTML_BLOCK,
	ruby = { kind = "block", open = "=begin", close = "=end", mid = "", close_indent = "" },
	perl = { kind = "line", sym = "#" },
	ps1 = { kind = "block", open = "<#", close = "#>", mid = "  ", close_indent = "" },
	python = {
		kind = "docstring",
		open = { '"""' },
		close = '"""',
	},
}

---@type CommentStyle
local DEFAULT_STYLE = { kind = "line", sym = "#" }

-- Single-line comment symbol, for inline snippets that must stay on one
-- comment line even when the file header is a block comment.
---@type table<string, string>
local line_comment_by_ft = {
	lua = "--",
	sh = "#",
	bash = "#",
	zsh = "#",
	yaml = "#",
	toml = "#",
	vim = '"',
	zig = "//",
	scheme = ";",
	lisp = ";",
	c = "//",
	cpp = "//",
	cs = "//",
	java = "//",
	javascript = "//",
	typescript = "//",
	rust = "//",
	php = "//",
	sql = "--",
	haskell = "--",
	python = "#",
	ruby = "#",
	kotlin = "//",
	perl = "#",
	ps1 = "#",
}
local DEFAULT_LINE_COMMENT = "#"

---Returns the single-line comment symbol for a filetype, falling back to
---the default for unknown filetypes.
---@param ft string Filetype name, for example "lua".
---@return string
local function line_comment_sym(ft)
	return line_comment_by_ft[ft] or DEFAULT_LINE_COMMENT
end

-- Filetypes whose multi-line inline snippets (refs, drefs) use a block
-- comment. All others use consecutive line comments.
---@type table<string, boolean>
local inline_block_fts = {
	c = true,
	cpp = true,
	cs = true,
	java = true,
	html = true,
	xml = true,
	markdown = true,
}

---@type table<string, string>
local shebang_by_ft = {
	sh = "#!/usr/bin/env sh",
	bash = "#!/usr/bin/env bash",
	zsh = "#!/usr/bin/env zsh",
	python = "#!/usr/bin/env python3",
	ruby = "#!/usr/bin/env ruby",
	perl = "#!/usr/bin/env perl",
	php = "#!/usr/bin/env php",
}

local FIELD_WIDTH = 15

-- Pads a field name so header values line up in a column.
---@param text string
---@return string
local function label(text)
	return text .. string.rep(" ", math.max(1, FIELD_WIDTH - #text))
end

---Applies a comment style to one line of header content. An empty line
---becomes a bare comment prefix with no trailing whitespace.
---@param style CommentStyle
---@param line string
---@return string
local function wrap(style, line)
	if style.kind == "line" then
		if line == "" then
			return style.sym
		end
		return style.sym .. " " .. line
	elseif style.kind == "block" then
		local mid = style.mid or " * "
		if line == "" then
			return (mid:gsub("%s+$", ""))
		end
		return mid .. line
	else
		return line
	end
end

-- Comment prefix for a line that starts with a placeholder, not a label.
---@param style CommentStyle
---@return string
local function line_prefix(style)
	if style.kind == "line" then
		return style.sym .. " "
	elseif style.kind == "block" then
		return style.mid or " * "
	else
		return ""
	end
end

-- Pads a usage label so the commands line up in a column.
---@param text string
---@return string
local function usage_label(text)
	return "      " .. text .. string.rep(" ", 10 - #text)
end

-- Compile/run instructions per filetype, which follow the usage title, with one
-- line per label and commands prefixed by `$ `.
---@type table<string, fun(style: CommentStyle): table>
local usage_by_ft = {
	c = function(style)
		return {
			t({ "", wrap(style, usage_label("Compile:") .. "$ gcc -Wall -Wextra -Wpedantic -std=c23 ") }),
			f(get_filename, {}),
			t(" -o "),
			f(get_basename, {}),
			t({ "", wrap(style, usage_label("Run:") .. "$ ./") }),
			f(get_basename, {}),
		}
	end,
	cpp = function(style)
		return {
			t({ "", wrap(style, usage_label("Compile:") .. "$ g++ -Wall -Wextra -Wpedantic -std=c++23 ") }),
			f(get_filename, {}),
			t(" -o "),
			f(get_basename, {}),
			t({ "", wrap(style, usage_label("Run:") .. "$ ./") }),
			f(get_basename, {}),
		}
	end,
	java = function(style)
		return {
			t({ "", wrap(style, label("Compilation:") .. "$ javac ") }),
			f(get_filename, {}),
			t({ "", wrap(style, label("Execution:") .. "$ java ") }),
			f(get_basename, {}),
		}
	end,
	python = function(style)
		return {
			t({ "", wrap(style, usage_label("Run:") .. "$ python3 ") }),
			f(get_filename, {}),
		}
	end,
	zig = function(style)
		return {
			t({ "", wrap(style, usage_label("Run:") .. "$ zig run ") }),
			f(get_filename, {}),
		}
	end,
	scheme = function(style)
		return {
			t({ "", wrap(style, usage_label("Run:") .. "$ mit-scheme --quiet --load ") }),
			f(get_filename, {}),
			t({ "", wrap(style, "      To evaluate line by line, use ,ee and ,er in the REPL.") }),
		}
	end,
	javascript = function(style)
		return {
			t({ "", wrap(style, usage_label("Run:") .. "$ node ") }),
			f(get_filename, {}),
		}
	end,
	typescript = function(style)
		return {
			t({ "", wrap(style, usage_label("Run:") .. "$ npx ts-node ") }),
			f(get_filename, {}),
			t({ "", wrap(style, "      Or compile then run:") }),
			t({ "", wrap(style, "      $ tsc ") }),
			f(get_filename, {}),
			t({ "", wrap(style, "      $ node ") }),
			f(get_basename, {}),
			t(".js"),
		}
	end,
	rust = function(style)
		return {
			t({ "", wrap(style, usage_label("Compile:") .. "$ rustc ") }),
			f(get_filename, {}),
			t(" -o "),
			f(get_basename, {}),
			t({ "", wrap(style, usage_label("Run:") .. "$ ./") }),
			f(get_basename, {}),
		}
	end,
	php = function(style)
		return {
			t({ "", wrap(style, usage_label("Run:") .. "$ php ") }),
			f(get_filename, {}),
		}
	end,
	cs = function(style)
		return {
			t({ "", wrap(style, usage_label("Run:") .. "$ dotnet run ") }),
			f(get_filename, {}),
			t({ "", wrap(style, "      Single-file runs need .NET 10 or newer.") }),
		}
	end,
	haskell = function(style)
		return {
			t({ "", wrap(style, usage_label("Run:") .. "$ runghc ") }),
			f(get_filename, {}),
			t({ "", wrap(style, "      Or compile then run:") }),
			t({ "", wrap(style, "      $ ghc -o ") }),
			f(get_basename, {}),
			t(" "),
			f(get_filename, {}),
			t({ "", wrap(style, "      $ ./") }),
			f(get_basename, {}),
		}
	end,
	sh = function(style)
		return {
			t({ "", wrap(style, usage_label("Run:") .. "$ chmod +x ") }),
			f(get_filename, {}),
			t(" && ./"),
			f(get_filename, {}),
		}
	end,
	ruby = function(style)
		return {
			t({ "", wrap(style, usage_label("Run:") .. "$ ruby ") }),
			f(get_filename, {}),
		}
	end,
	kotlin = function(style)
		return {
			t({ "", wrap(style, usage_label("Compile:") .. "$ kotlinc ") }),
			f(get_filename, {}),
			t(" -include-runtime -d "),
			f(get_basename, {}),
			t(".jar"),
			t({ "", wrap(style, usage_label("Run:") .. "$ java -jar ") }),
			f(get_basename, {}),
			t(".jar"),
		}
	end,
	perl = function(style)
		return {
			t({ "", wrap(style, usage_label("Run:") .. "$ perl ") }),
			f(get_filename, {}),
		}
	end,
	ps1 = function(style)
		return {
			t({ "", wrap(style, usage_label("Run:") .. "$ pwsh -File ") }),
			f(get_filename, {}),
		}
	end,
}
usage_by_ft.bash = usage_by_ft.sh
usage_by_ft.zsh = usage_by_ft.sh

-- Filetypes whose usage lines carry their own labels, so the "Usage:"
-- title is skipped.
---@type table<string, boolean>
local inline_usage_fts = { java = true }

---Add a blank line and the usage block to a header. Falls back to a title plus
---an editable placeholder when the filetype has no instructions.
---@param add fun(...: table) Appends nodes to the snippet being built.
---@param style CommentStyle
---@param ft string
---@param idx integer Next free insert node index.
---@return integer idx Next free insert node index after this call.
local function add_usage(add, style, ft, idx)
	local usage_fn = usage_by_ft[ft]
	add(t({ "", wrap(style, "") }))
	if not inline_usage_fts[ft] then
		add(t({ "", wrap(style, "    Usage:") }))
	end
	if usage_fn then
		for _, n in ipairs(usage_fn(style)) do
			add(n)
		end
		return idx
	end
	add(t({ "", wrap(style, "      ") }))
	-- Only the fallback consumes an index, since LuaSnip needs them contiguous.
	add(i(idx, "how to compile/run this file"))
	return idx + 1
end

-- Block and docstring styles need a line break after the opener.
---@param add fun(...: table) Appends nodes to the snippet being built.
---@param style CommentStyle
---@param first_line string
local function open_and_first_line(add, style, first_line)
	if style.kind == "block" or style.kind == "docstring" then
		add(t(style.open))
		add(t({ "", wrap(style, first_line) }))
	else
		add(t(wrap(style, first_line)))
	end
end

-- Closes the header and adds a blank line before the code.
---@param add fun(...: table) Appends nodes to the snippet being built.
---@param style CommentStyle
local function close_header(add, style)
	if style.kind == "block" then
		local indent = style.close_indent or " "
		add(t({ "", indent .. style.close, "", "" }))
	elseif style.kind == "docstring" then
		add(t({ "", style.close, "", "" }))
	else
		add(t({ "", "" }))
	end
end

---Returns a function that appends its arguments to `list`, so the header
---and template builders share one `add` implementation.
---@param list table
---@return fun(...: table)
local function append_to(list)
	return function(...)
		for _, n in ipairs({ ... }) do
			table.insert(list, n)
		end
	end
end

-- Every field appends its nodes to the context, and fields that insert advance
-- `ctx.idx`, so the indices stay contiguous. Index 0 is the exit cursor.
---@class HeaderContext
---@field add fun(...: table) Appends nodes to the snippet being built.
---@field style CommentStyle
---@field ft string
---@field idx integer Next free insert node index.

---@alias HeaderField fun(ctx: HeaderContext)

local H = {}

---@return HeaderField
function H.file()
	return function(ctx)
		open_and_first_line(ctx.add, ctx.style, label("File:"))
		ctx.add(f(get_filename, {}))
	end
end

---@param text? string Default author line.
---@return HeaderField
function H.author(text)
	return function(ctx)
		ctx.add(t({ "", wrap(ctx.style, label("Author:")) }))
		ctx.add(i(ctx.idx, text or "Miquéias Alves Medeiros <https://github.com/miqu3iasg>"))
		ctx.idx = ctx.idx + 1
	end
end

---@return HeaderField
function H.created()
	return function(ctx)
		ctx.add(t({ "", wrap(ctx.style, label("Created:")) }))
		ctx.add(f(get_date, {}))
	end
end

---@return HeaderField
function H.source()
	return function(ctx)
		ctx.add(t({ "", wrap(ctx.style, label("Source:")) }))
		ctx.add(i(ctx.idx, "title of the book/article"))
		ctx.idx = ctx.idx + 1
	end
end

---@return HeaderField
function H.by()
	return function(ctx)
		ctx.add(t({ "", wrap(ctx.style, label("By:")) }))
		ctx.add(i(ctx.idx, "actual author(s) of the source material"))
		ctx.idx = ctx.idx + 1
	end
end

---@return HeaderField
function H.location()
	return function(ctx)
		ctx.add(t({ "", wrap(ctx.style, label("Location:")) }))
		ctx.add(i(ctx.idx, "chapter / pages / section"))
		ctx.idx = ctx.idx + 1
	end
end

---@return HeaderField
function H.usage()
	return function(ctx)
		ctx.idx = add_usage(ctx.add, ctx.style, ctx.ft, ctx.idx)
	end
end

-- Exercise problem statement: a title line and an indented placeholder.
---@return HeaderField
function H.problem_statement()
	return function(ctx)
		ctx.add(t({ "", wrap(ctx.style, ""), wrap(ctx.style, "Problem Statement:") }))
		ctx.add(t({ "", wrap(ctx.style, "    ") }))
		ctx.add(i(ctx.idx, "Paste the exercise/assignment text here."))
		ctx.idx = ctx.idx + 1
	end
end

-- The description starts on its own comment line, so the field uses the
-- comment prefix instead of a padded label.
---@param placeholder string
---@return HeaderField
function H.description(placeholder)
	return function(ctx)
		ctx.add(t({ "", wrap(ctx.style, ""), line_prefix(ctx.style) }))
		ctx.add(i(ctx.idx, placeholder))
		ctx.idx = ctx.idx + 1
	end
end

---@return HeaderField
function H.references()
	return function(ctx)
		ctx.add(t({ "", wrap(ctx.style, ""), wrap(ctx.style, "References:") }))
		ctx.add(t({ "", wrap(ctx.style, "  - ") }))
		ctx.add(i(ctx.idx, "https://..."))
		ctx.idx = ctx.idx + 1
	end
end

-- Editable SPDX identifier line, the last field of every header.
---@param license string SPDX license identifier.
---@return HeaderField
function H.spdx(license)
	return function(ctx)
		ctx.add(t({ "", wrap(ctx.style, ""), wrap(ctx.style, "SPDX-License-Identifier: ") }))
		ctx.add(i(ctx.idx, license))
		ctx.idx = ctx.idx + 1
	end
end

-- Copyright field for the study headers, mirroring the Author line through
-- `rep` so the holder is typed once.
---@param suffix string Text appended after the copyright holder.
---@return HeaderField
function H.copyright(suffix)
	return function(ctx)
		ctx.add(t({ "", wrap(ctx.style, ""), wrap(ctx.style, label("Copyright:")) }))
		ctx.add(t("Copyright (c) "))
		ctx.add(f(get_year, {}))
		ctx.add(t(" "))
		ctx.add(rep(1))
		ctx.add(t(suffix))
	end
end

-- Bare copyright line for the proprietary header, Google style. The holder is
-- editable on the first jump.
---@param suffix string Text appended after the copyright holder.
---@return HeaderField
function H.copyright_line(suffix)
	return function(ctx)
		open_and_first_line(ctx.add, ctx.style, "Copyright (c) ")
		ctx.add(f(get_year, {}))
		ctx.add(t(" "))
		ctx.add(i(ctx.idx, "Miquéias Alves Medeiros"))
		ctx.add(t(suffix))
		ctx.idx = ctx.idx + 1
	end
end

-- Header specs. The field order matches the rendered header.
local headers = {
	-- `head`: File, Author, Created, Description, license line.
	head = {
		H.file(),
		H.author(),
		H.created(),
		H.description("add description here"),
		H.spdx("AGPL-3.0-only"),
	},
	-- `shead`: for code written while studying a book or article. The
	-- copyright holder mirrors the Author field.
	shead = {
		H.file(),
		H.author(),
		H.created(),
		H.source(),
		H.by(),
		H.location(),
		H.usage(),
		H.description("what you implemented / learned here"),
		H.spdx("AGPL-3.0-only"),
		H.copyright("."),
	},
	-- `ahead`: proprietary header, Google style: the copyright line opens
	-- the header because the holder is the identification.
	ahead = {
		H.copyright_line(". All rights reserved."),
		H.description("add description here"),
		H.spdx("LicenseRef-Proprietary"),
	},
	-- `ehead`: exercise header. `shead` fields plus a problem statement and
	-- a reference list.
	ehead = {
		H.file(),
		H.author("Miquéias Medeiros <https://github.com/miqu3iasg>"),
		H.created(),
		H.source(),
		H.by(),
		H.location(),
		H.usage(),
		H.problem_statement(),
		H.description("Longer description, if needed."),
		H.references(),
		H.spdx("AGPL-3.0-only"),
		H.copyright("."),
	},
}

---Renders one header spec into `nodes` in the comment style of `ft`, ending
---with the closing blank line before the code. The caller appends its own
---body after and finishes with the exit cursor, so templates can open with
---the standard header and continue with language-specific nodes.
---@param spec HeaderField[]
---@param ft string
---@param nodes table
---@return HeaderContext ctx
function M.render(spec, ft, nodes)
	local style = comment_styles[ft] or DEFAULT_STYLE
	local ctx = {
		add = append_to(nodes),
		style = style,
		ft = ft,
		idx = 1,
	}

	for _, field in ipairs(spec) do
		field(ctx)
	end
	close_header(ctx.add, style)
	return ctx
end

---Builds the dynamic node function for one header spec.
---@param spec HeaderField[]
---@return fun(): table
function M.build_header(spec)
	return function(_, _)
		local nodes = {}
		M.render(spec, vim.bo.filetype, nodes)
		table.insert(nodes, i(0))

		return sn(nil, nodes)
	end
end

---Returns the style for multi-line inline snippets: the block style for
---filetypes in `inline_block_fts`, line comments for all others.
---@param ft string
---@return CommentStyle
local function inline_style(ft)
	local raw = comment_styles[ft]
	if raw and raw.kind == "block" and inline_block_fts[ft] then
		return raw
	end
	return { kind = "line", sym = line_comment_sym(ft) }
end

local function open_inline(add, style)
	if style.kind == "block" then
		add(t(style.open))
		add(t({ "", line_prefix(style) }))
	else
		add(t(line_prefix(style)))
	end
end

local function close_inline(add, style)
	if style.kind == "block" then
		add(t({ "", (style.close_indent or " ") .. style.close }))
	end
end

---Returns the opener and closer for a one-line comment. Languages with
---only a block form (html, xml, markdown) get `<!-- ... -->`. The closer
---is empty for line comments.
---@param ft string
---@return string opener
---@return string closer
local function oneline_delims(ft)
	local sym = line_comment_by_ft[ft]
	if sym then
		return sym .. " ", ""
	end
	local raw = comment_styles[ft]
	if raw and raw.kind == "block" then
		return raw.open .. " ", " " .. raw.close
	end
	return DEFAULT_LINE_COMMENT .. " ", ""
end

---Reads the system clipboard (falls back to the unnamed register) and
---returns its first line, trimmed. Multi-line clipboards are cut at the
---first line so the comment stays on a single line.
---@return string
local function get_clipboard()
	local text = vim.fn.getreg("+")
	if text == "" then
		text = vim.fn.getreg('"')
	end
	text = text:match("^%s*([^\r\n]*)") or ""
	return (text:gsub("%s+$", ""))
end

-- Exported API. The consumers destructure into locals with the original names.
M.get_date = get_date
M.get_year = get_year
M.get_filename = get_filename
M.get_relpath = get_relpath
M.get_basename = get_basename
M.get_clipboard = get_clipboard
M.comment_styles = comment_styles
M.DEFAULT_STYLE = DEFAULT_STYLE
M.line_comment_sym = line_comment_sym
M.shebang_by_ft = shebang_by_ft
M.label = label
M.wrap = wrap
M.line_prefix = line_prefix
M.open_and_first_line = open_and_first_line
M.close_header = close_header
M.append_to = append_to
M.H = H
M.headers = headers
M.inline_style = inline_style
M.open_inline = open_inline
M.close_inline = close_inline
M.oneline_delims = oneline_delims

return M
