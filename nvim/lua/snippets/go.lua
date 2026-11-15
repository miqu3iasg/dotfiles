-- lua/snippets/go.lua

-- Go snippets for small programs and documentation boilerplate: a package
-- skeleton, functions, structs, tests, error checks, and GoDoc doc comments
-- in the format the official tooling renders. Doc comments are full
-- sentences starting with the identifier name; the Go 1.19 syntax adds
-- headings and symbol links, and the package comment is the docm trigger,
-- the module-overview form used by the other languages. Every snippet is
-- written with the hard tabs that gofmt emits, so they never need
-- reindenting.
--
-- See: doc/snippets.txt
-- See: after/ftplugin/go.lua
-- See: https://go.dev/doc/comment
-- See: https://go.dev/doc/effective_go

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	-- Package comment, the only one per package, placed directly above the
	-- `package` clause. GoDoc uses it as the package summary; pkgsite
	-- renders it as "Package name provides ...".
	s("docm", {
		t("// Package "),
		i(1, "name"),
		t(" "),
		i(2, "provides what the package does."),
		i(0),
	}),

	-- Doc comment for a function, method, type or variable. GoDoc requires the
	-- comment to be a full sentence that starts with the identifier name.
	s("doc", {
		t("// "),
		i(1, "Name"),
		t(" "),
		i(2, "does what."),
		i(0),
	}),

	-- Official deprecation notice, rendered as a separate paragraph by pkgsite.
	-- Add it as a second paragraph after the doc comment of the declaration.
	s("docd", {
		t({ "//", "// Deprecated: " }),
		i(1, "use X instead."),
		i(0),
	}),

	-- Testable example for _test.go files, named after the function it
	-- exercises. go test compiles it and compares the printed lines with the
	-- "// Output:" comment, so it doubles as documentation that never rots.
	s("doce", {
		t("func Example"),
		i(1, "Name"),
		t({ "() {", "\tfmt.Println(" }),
		i(2, "call to the function"),
		t({ ")", "\t// Output: " }),
		i(3, "expected output"),
		t({ "", "}" }),
		i(0),
	}),

	-- Doc comment link, referencing a symbol that pkgsite renders as a
	-- hyperlink. Qualify across packages as [pkg.Name].
	s("dlink", {
		t("["),
		i(1, "Name"),
		t("]"),
		i(0),
	}),

	-- Doc comment heading, for longer doc comments and file overviews.
	-- Headings need a blank line on both sides and no trailing punctuation.
	s("dhead", {
		t("# "),
		i(1, "Heading"),
		i(0),
	}),

	-- Program skeleton with a main entry point.
	s("pkg", {
		t({ "package main", "", "func main() {", "\t" }),
		i(1),
		t({ "", "}" }),
	}),

	-- Function declaration with parameters, return type and body.
	s("fn", {
		t("func "),
		i(1, "Name"),
		t("("),
		i(2, "args"),
		t(") "),
		i(3, "error"),
		t({ " {", "\t" }),
		i(4),
		t({ "", "}" }),
		i(0),
	}),

	-- Struct definition.
	s("st", {
		t("type "),
		i(1, "Name"),
		t({ " struct {", "\t" }),
		i(2, "Field"),
		t(" "),
		i(3, "Type"),
		t({ "", "}" }),
		i(0),
	}),

	-- Test function for the standard testing package.
	s("tf", {
		t("func Test"),
		i(1, "Name"),
		t("(t *testing.T) {"),
		t({ "", "\t" }),
		i(2),
		t({ "", "}" }),
		i(0),
	}),

	-- Error check, returning by default. The returned values adapt to any
	-- function signature.
	s("er", {
		t("if "),
		i(1, "err"),
		t(" != nil {"),
		t({ "", "\treturn " }),
		i(2, "err"),
		t({ "", "}" }),
		i(0),
	}),
}
