-- lua/snippets/common.lua

-- Common snippets shared across filetypes: file headers, shebangs, SPDX
-- notices, references, paths, and personal contact information. Dynamic
-- snippets adapt their output to the current buffer's filetype and use
-- language-specific comment styles for line, block, and docstring comments.
--
-- The comment styles, filename helpers and header field constructors these
-- snippets build on live in lib/headers.lua, where the templates module
-- reaches the same machinery; this file only defines the snippets.
--
-- See: lua/lib/headers.lua
-- See: lua/modules/templates.lua
-- See: doc/snippets.txt
-- See: https://spdx.dev/ids/

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local sn = ls.snippet_node

-- Aliases to the shared header machinery (lib/headers.lua), so the snippet
-- builders below keep the local names they had when the machinery lived in
-- this file.
local h = require("lib.headers")
local build_header = h.build_header
local get_relpath = h.get_relpath
local inline_style = h.inline_style
local line_comment_sym = h.line_comment_sym
local oneline_delims = h.oneline_delims
local open_inline = h.open_inline
local close_inline = h.close_inline
local append_to = h.append_to
local shebang_by_ft = h.shebang_by_ft
local wrap = h.wrap
local line_prefix = h.line_prefix
local headers = h.headers

-- `spdx`: standalone SPDX line, without a full header.
local function build_spdx(_, _)
	local pre, post = oneline_delims(vim.bo.filetype)
	return sn(nil, {
		t(pre .. "SPDX-License-Identifier: "),
		i(1, "AGPL-3.0-only"),
		t(post),
		i(0),
	})
end

-- `shebang`: interpreter line for the current filetype, `sh` by default.
-- Python headers are docstrings only, so the interpreter line is typed
-- with this snippet; a choice offers the coding tag Python reads.
local function build_shebang(_, _)
	local ft = vim.bo.filetype
	local line = shebang_by_ft[ft] or "#!/usr/bin/env sh"
	if ft == "python" then
		return sn(nil, {
			t(line),
			c(1, { t({ "", "# -*- coding: utf-8 -*-" }), t("") }),
			i(0),
		})
	end
	return sn(nil, { t(line), i(0) })
end

-- `see`: one-line reference, cursor ready to paste the link.
local function build_see(_, _)
	local sym = line_comment_sym(vim.bo.filetype)
	return sn(nil, {
		t(sym .. " See: "),
		i(1),
	})
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

-- `seec`: like `see`, but pastes the clipboard (usually a link or a path)
-- right after "See: ".
local function build_see_clip(_, _)
	local sym = line_comment_sym(vim.bo.filetype)
	return sn(nil, {
		t(sym .. " See: " .. get_clipboard()),
		i(0),
	})
end

-- `path`: one-line comment with the file path relative to the cwd,
-- e.g. `-- lua/options.lua`.
local function build_filepath(_, _)
	local pre, post = oneline_delims(vim.bo.filetype)
	local nodes = { t(pre), f(get_relpath, {}) }
	if post ~= "" then
		table.insert(nodes, t(post))
	end
	table.insert(nodes, i(0))
	return sn(nil, nodes)
end

-- `mail`: e-mail address.
local function build_mail(_, _)
	return sn(nil, { i(1, "contatomiqueiasalvesdev@gmail.com") })
end

-- `gh`: GitHub profile URL.
local function build_gh(_, _)
	return sn(nil, { i(1, "https://github.com/miqu3iasg") })
end

-- `refs`: list of references, one bullet per source.
local function build_refs(_, _)
	local style = inline_style(vim.bo.filetype)
	local nodes = {}
	local add = append_to(nodes)

	open_inline(add, style)
	add(t("References:"))
	add(t({ "", wrap(style, "  - ") }))
	add(i(1, "https://..."))
	close_inline(add, style)
	add(i(0))

	return sn(nil, nodes)
end

-- `drefs`: description plus references, for borrowed code where the reason
-- it was kept matters.
local function build_snip(_, _)
	local style = inline_style(vim.bo.filetype)
	local nodes = {}
	local add = append_to(nodes)

	open_inline(add, style)
	add(i(1, "what this snippet does / why it was kept"))
	add(t({ "", wrap(style, "References:") }))
	add(t({ "", wrap(style, "  - ") }))
	add(i(2, "https://..."))
	close_inline(add, style)
	add(i(0))

	return sn(nil, nodes)
end

return {
	s("head", { d(1, build_header(headers.head), {}) }),
	s("shead", { d(1, build_header(headers.shead), {}) }),
	s("ahead", { d(1, build_header(headers.ahead), {}) }),
	s("ehead", { d(1, build_header(headers.ehead), {}) }),
	s("shb", { d(1, build_shebang, {}) }),
	s("see", { d(1, build_see, {}) }),
	s("seec", { d(1, build_see_clip, {}) }),
	s("path", { d(1, build_filepath, {}) }),
	s("refs", { d(1, build_refs, {}) }),
	s("drefs", { d(1, build_snip, {}) }),
	s("spdx", { d(1, build_spdx, {}) }),
	s("mail", { d(1, build_mail, {}) }),
	s("gh", { d(1, build_gh, {}) }),
	s("author", { i(1, "Miquéias Alves Medeiros <https://github.com/miqu3iasg>") }),
}
