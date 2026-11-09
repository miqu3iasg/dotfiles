-- lua/snippets/markdown.lua

-- Markdown snippets for tables, code blocks, comments, formatting, links,
-- callouts, front matter, and mathematical notation. Dynamic snippets generate
-- tables from trigger dimensions and timestamps from the current time, while
-- helpers provide reusable heading and language-specific code block templates.

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local c = ls.choice_node

-- Current date in ISO format, used in front matter and date snippets.
local function today()
	return os.date("%Y-%m-%d")
end

-- Current date and time, used in front matter timestamps.
local function now()
	return os.date("%Y-%m-%d %H:%M")
end

-- Current file name, including its extension.
local function get_filename()
	local name = vim.fn.expand("%:t")
	return name ~= "" and name or "Untitled"
end

-- Creates a heading snippet for the given level.
local function heading(level)
	return s("h" .. level, {
		t(string.rep("#", level) .. " "),
		i(1, "Title"),
		i(0),
	})
end

-- Creates a fenced code block with a fixed language identifier.
local function codeblock(trig, lang)
	return s(trig, {
		t("```" .. lang),
		t({ "", "" }),
		i(1),
		t({ "", "```" }),
		i(0),
	})
end

-- Creates a table from dimensions captured by the tbl<cols>x<rows> trigger.
-- Insert nodes are numbered sequentially so Tab moves through every cell.
local function dynamic_table(_, snip)
	local cols = tonumber(snip.captures[1])
	local rows = tonumber(snip.captures[2])
	local nodes = {}
	local idx = 1

	local function add_row(placeholder)
		nodes[#nodes + 1] = t("| ")
		for col = 1, cols do
			nodes[#nodes + 1] = i(idx, placeholder .. " " .. col)
			idx = idx + 1
			nodes[#nodes + 1] = t(col < cols and " | " or " |")
		end
	end

	-- Header row.
	add_row("Header")

	-- Column separator.
	local sep = { "", "|" }
	for _ = 1, cols do
		sep[2] = sep[2] .. " --- |"
	end
	nodes[#nodes + 1] = t(sep)

	-- Body rows.
	for _ = 1, rows do
		nodes[#nodes + 1] = t({ "", "" })
		add_row("Cell")
	end

	nodes[#nodes + 1] = i(0)
	return sn(nil, nodes)
end

local snippets = {
	-- Default table with three columns and two body rows.
	s("tbl", {
		t("| "),
		i(1, "Header 1"),
		t(" | "),
		i(2, "Header 2"),
		t(" | "),
		i(3, "Header 3"),
		t(" |"),
		t({ "", "| --- | --- | --- |" }),
		t({ "", "| " }),
		i(4, "Cell"),
		t(" | "),
		i(5, "Cell"),
		t(" | "),
		i(6, "Cell"),
		t(" |"),
		t({ "", "| " }),
		i(7, "Cell"),
		t(" | "),
		i(8, "Cell"),
		t(" | "),
		i(9, "Cell"),
		t(" |"),
		i(0),
	}),

	-- Custom table size, e.g. tbl4x5 for four columns and five body rows.
	s({ trig = "tbl(%d+)x(%d+)", regTrig = true, hidden = true }, {
		d(1, dynamic_table, {}),
	}),

	-- Generic fenced code block with an editable language identifier.
	s("cb", {
		t("```"),
		i(1, "lang"),
		t({ "", "" }),
		i(2),
		t({ "", "```" }),
		i(0),
	}),

	-- Inline code.
	s("ic", { t("`"), i(1, "code"), t("`"), i(0) }),

	-- Fenced code blocks for common languages and formats.
	codeblock("cbbash", "bash"),
	codeblock("cbsh", "sh"),
	codeblock("cblua", "lua"),
	codeblock("cbc", "c"),
	codeblock("cbjava", "java"),
	codeblock("cbpy", "python"),
	codeblock("cbscm", "scheme"),
	codeblock("cbjson", "json"),
	codeblock("cbyaml", "yaml"),
	codeblock("cbsql", "sql"),
	codeblock("cbhtml", "html"),
	codeblock("cbcss", "css"),
	codeblock("cbdiff", "diff"),

	-- Single-line HTML comment.
	s("cm", { t("<!-- "), i(1, "comment"), t(" -->"), i(0) }),

	-- Multi-line HTML comment.
	s("cmm", {
		t({ "<!--", "" }),
		i(1, "comment"),
		t({ "", "-->" }),
		i(0),
	}),

	-- Reference-style comment that is ignored by Markdown renderers.
	s("cmr", { t("[//]: # ("), i(1, "comment"), t(")"), i(0) }),

	-- TODO marker inside an HTML comment.
	s("todoc", { t("<!-- TODO: "), i(1, "description"), t(" -->"), i(0) }),

	-- Common inline text formatting.
	s("bd", { t("**"), i(1, "text"), t("**"), i(0) }),
	s("it", { t("*"), i(1, "text"), t("*"), i(0) }),
	s("bi", { t("***"), i(1, "text"), t("***"), i(0) }),
	s("st", { t("~~"), i(1, "text"), t("~~"), i(0) }),
	s("kbd", { t("<kbd>"), i(1, "Ctrl"), t("</kbd>"), i(0) }),

	-- Inline links, images, reference links, and reference definitions.
	s("link", { t("["), i(1, "text"), t("]("), i(2, "https://"), t(")"), i(0) }),
	s("img", { t("!["), i(1, "alt text"), t("]( "), i(2, "path/to/image.png"), t(")"), i(0) }),
	s("ref", { t("["), i(1, "text"), t("]["), i(2, "id"), t("]"), i(0) }),
	s("refdef", { t("["), i(1, "id"), t("]: "), i(2, "https://"), i(0) }),

	-- Footnote reference with its matching definition.
	s("fn", {
		t("[^"),
		i(1, "1"),
		t("]"),
		t({ "", "", "[^" }),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t("]: "),
		i(2, "Footnote text."),
		i(0),
	}),

	-- Quote and horizontal rule.
	s("qt", { t("> "), i(1, "Quote"), i(0) }),
	s("hr", { t({ "---", "" }), i(0) }),

	-- Blockquote callout with an editable callout type.
	s("callout", {
		t("> [!"),
		c(1, {
			t("NOTE"),
			t("TIP"),
			t("IMPORTANT"),
			t("WARNING"),
			t("CAUTION"),
		}),
		t({ "]", "> " }),
		i(2, "Content."),
		i(0),
	}),

	-- Note metadata with file information, references, and timestamps.
	s("front", {
		t({ "---", "file_name: " }),
		f(get_filename, {}),
		t({ "", "title: " }),
		i(1),
		t({ "", "description: " }),
		i(2),
		t({ "", "authors: " }),
		i(3),
		t({ "", "source: " }),
		i(4),
		t({ "", "location: " }),
		i(5),
		t({ "", "external_urls:", "    - " }),
		i(6),
		t({ "", "related: " }),
		i(7),
		t({ "", "# lang: en-US            # switch language" }),
		t({ "", "" }),
		d(8, function()
			local ts = now()
			return sn(nil, {
				t({ "created_at: " .. ts, "modified_at: " .. ts, "---", "", "" }),
			})
		end, {}),
		i(0),
	}),

	-- Inline mathematical expression.
	s("math", { t("$"), i(1, "x"), t("$"), i(0) }),

	-- Display mathematical expression for KaTeX and MathJax.
	s("mathb", {
		t({ "$$", "" }),
		i(1, "E = mc^2"),
		t({ "", "$$" }),
		i(0),
	}),

	-- Inserts the current date in ISO format.
	s("date", { f(today, {}) }),
}

-- Heading snippets from h1 through h6.
for level = 1, 6 do
	table.insert(snippets, heading(level))
end

return snippets
