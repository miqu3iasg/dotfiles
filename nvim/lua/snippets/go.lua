-- lua/snippets/go.lua

-- Go snippets for the boilerplate of small programs: a package skeleton,
-- functions, structs, tests and error checks. Every snippet is written with
-- the hard tabs that gofmt emits, so they never need reindenting.
--
-- See: after/ftplugin/go.lua
-- See: https://go.dev/doc/effective_go

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
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
