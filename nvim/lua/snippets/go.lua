-- lua/snippets/go.lua

-- Go snippets for small programs and documentation boilerplate: a package
-- skeleton, functions, structs, tests, error checks, and GoDoc doc comments
-- in the format the official tooling renders. Every snippet is written with
-- the hard tabs that gofmt emits, so they never need reindenting.
--
-- See: after/ftplugin/go.lua
-- See: https://go.dev/doc/effective_go

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	-- Package comment, the only one per package, placed directly above the
	-- `package` clause. GoDoc uses it as the package summary.
	s("docp", {
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
