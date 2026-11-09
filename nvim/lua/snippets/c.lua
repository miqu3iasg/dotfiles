-- lua/snippets/c.lua

-- C snippets for small programs, practice problems, and Linux kernel-style
-- documentation comments. Indentation follows the conventions of each snippet:
-- four spaces for the basic program template and tabs for the solution scaffold.
-- The documentation comment format uses @field: descriptions and can be adapted
-- for structs or functions.
--
-- See: https://www.kernel.org/doc/html/v4.10/process/coding-style.html

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	-- Minimal C program with an int main(void) entry point.
	s("ivm", {
		t({
			"#include <stdio.h>",
			"",
			"int main(void) {",
			"    ",
		}),
		i(1),
		t({ "", "", "    return 0;", "}" }),
	}),

	-- Solution scaffold for practice problems (LeetCode, Kattis, etc.).
	-- Provides a solve function and an int main that calls it and prints the
	-- result. The main function can be removed when the judge provides its own
	-- driver code.
	s("sol", {
		t({ "#include <stdio.h>", "", "" }),
		i(1, "int"),
		t(" solve("),
		i(2, "int n"),
		t({ ") {", "\t" }),
		i(3, "// TODO: implement"),
		t({ "", "}", "", "int main(void) {" }),
		t({ "", '\tprintf("%d\\n", solve(' }),
		i(4, "/* args */"),
		t({ "));", "\treturn 0;", "}" }),
		i(0),
	}),

	-- Linux kernel-style documentation comment.
	-- Starts with a short description followed by @field: description entries.
	-- Unused fields can be removed or duplicated for additional entries.
	s("doc", {
		t("/* "),
		i(1, "Short description"),
		t({ "", " * @" }),
		i(2, "field"),
		t(": "),
		i(3, "Description."),
		t({ "", " * @" }),
		i(4, "field"),
		t(": "),
		i(5, "Description."),
		t({ "", " * @" }),
		i(6, "field"),
		t(": "),
		i(7, "Description."),
		t({ "", " */" }),
	}),
}
