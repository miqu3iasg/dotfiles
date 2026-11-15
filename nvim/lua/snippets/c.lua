-- lua/snippets/c.lua

-- C snippets for small programs, practice problems, and Linux kernel-style
-- documentation comments. Indentation follows the conventions of each snippet:
-- four spaces for the basic program template and tabs for the solution scaffold.
-- Documentation comments follow kernel-doc, whose tooling only extracts
-- comments opened with /**: structs document their members as @member: lines,
-- functions carry @arg: lines and close with Context: and Return:, and a DOC:
-- section holds the file overview. Delete the lines that do not apply.
--
-- See: doc/snippets.txt
-- See: https://docs.kernel.org/doc-guide/kernel-doc.html
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

	-- Struct documentation, above the struct. The kernel-doc struct format
	-- names the struct, documents each member as an @member: line and ends
	-- with the longer description. Duplicate the @member lines as needed.
	s("doc", {
		t({ "/**", " * struct " }),
		i(1, "name"),
		t(" - "),
		i(2, "Short description."),
		t({ "", " *", " * @" }),
		i(3, "member"),
		t(": "),
		i(4, "Description."),
		t({ "", " * @" }),
		i(5, "member"),
		t(": "),
		i(6, "Description."),
		t({ "", " *", " * " }),
		i(7, "Longer description, if needed."),
		t({ "", " */", "" }),
		i(0),
	}),

	-- Function documentation, above the function. The kernel-doc function
	-- format differs from the struct one: the brief description follows the
	-- empty signature, parameters are @arg: lines and the block closes with
	-- the Context and Return sections.
	s("docfn", {
		t({ "/**", " * " }),
		i(1, "name"),
		t("() - "),
		i(2, "Brief description."),
		t({ "", " *", " * @" }),
		i(3, "arg"),
		t(": "),
		i(4, "Description."),
		t({ "", " * @" }),
		i(5, "arg"),
		t(": "),
		i(6, "Description."),
		t({ "", " *", " * " }),
		i(7, "Longer description of the behavior."),
		t({ "", " *", " * Context: " }),
		i(8, "Locking or borrowing context."),
		t({ "", " * Return: " }),
		i(9, "Description of the return value."),
		t({ "", " */", "" }),
		i(0),
	}),

	-- File overview, at the top of the file. The kernel-doc tool renders the
	-- DOC: section as the file's theory of operation, free from the syntax
	-- of the declarations below it.
	s("docm", {
		t({ "/**", " * DOC: " }),
		i(1, "Title"),
		t({ "", " *", " * " }),
		i(2, "Theory of operation."),
		t({ "", " */", "" }),
		i(0),
	}),

	-- One-line comment for fields, constants and small declarations.
	s("docf", {
		t("/* "),
		i(1, "Description."),
		t({ " */", "" }),
		i(0),
	}),
}
