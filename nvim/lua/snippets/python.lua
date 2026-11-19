-- lua/snippets/python.lua

-- Python snippets for practice problem scaffolding and Google-style
-- docstrings with Args, Returns, Yields and Raises sections.
--
-- See: doc/snippets.txt
-- See: https://peps.python.org/pep-0257/
-- See: https://google.github.io/styleguide/pyguide.html#s38-comments-and-docstrings

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node

return {
	-- Solution scaffold for practice problems (LeetCode, etc.).
	-- Creates a Solution class with a solve method and a main block that calls
	-- the method and prints its result.
	s("sol", {
		t({ "class Solution:", "    def " }),
		i(1, "solve"),
		t("(self, "),
		i(2, "n: int"),
		t(") -> "),
		i(3, "int"),
		t({ ":", "        " }),
		i(4, "# TODO: implement"),
		t({ "", "", "", 'if __name__ == "__main__":', "    sol = Solution()" }),
		t({ "", "    print(sol." }),
		f(function(args)
			return args[1][1]
		end, { 1 }),
		t("("),
		i(5, "args"),
		t("))"),
		i(0),
	}),

	-- Google-style docstring with argument, return, and raises sections.
	-- Remove unused parameter lines or the Returns/Raises sections as needed.
	s("doc", {
		t('"""'),
		i(1, "Short description."),
		t({ "", "", "Args:", "    " }),
		i(2, "param"),
		t(": "),
		i(3, "Description."),
		t({ "", "    " }),
		i(4, "param"),
		t(": "),
		i(5, "Description."),
		t({ "", "", "Returns:", "    " }),
		i(6, "Description."),
		t({ "", "", "Raises:", "    " }),
		i(7, "ValueError"),
		t(": "),
		i(8, "When it is raised."),
		t({ "", '"""', "" }),
		i(0),
	}),

	-- Google-style docstring for functions and methods that return nothing.
	s("docv", {
		t('"""'),
		i(1, "Short description."),
		t({ "", "", "Args:", "    " }),
		i(2, "param"),
		t(": "),
		i(3, "Description."),
		t({ "", '"""', "" }),
		i(0),
	}),

	-- Google-style docstring for generators: the Yields section replaces
	-- Returns and documents what the generator produces on each step.
	s("docy", {
		t('"""'),
		i(1, "Short description."),
		t({ "", "", "Args:", "    " }),
		i(2, "param"),
		t(": "),
		i(3, "Description."),
		t({ "", "", "Yields:", "    " }),
		i(4, "Description."),
		t({ "", "", "Raises:", "    " }),
		i(5, "ValueError"),
		t(": "),
		i(6, "When it is raised."),
		t({ "", '"""', "" }),
		i(0),
	}),

	-- Google-style docstring for a function or method without parameters.
	-- When the summary already states the return ("Returns rows from a
	-- Bigtable."), the Returns section may be left out entirely.
	s("docr", {
		t('"""'),
		i(1, "Short description."),
		t({ "", "", "Returns:", "    " }),
		i(2, "Description."),
		t({ "", '"""', "" }),
		i(0),
	}),

	-- Google-style class docstring with an Attributes section. Subclasses
	-- of unittest.TestCase do not need a docstring.
	s("docc", {
		t('"""'),
		i(1, "Class description."),
		t({ "", "", "Attributes:", "    " }),
		i(2, "attr"),
		t(": "),
		i(3, "Description."),
		t({ "", '"""', "" }),
		i(0),
	}),

	-- Module docstring with a short and a longer description, placed at the
	-- very top of the file. The usage paragraph is the only example form
	-- the Google style recognizes at module level.
	s("docm", {
		t('"""'),
		i(1, "Short description."),
		t({ "", "", "" }),
		i(2, "Longer description."),
		t({ "", "", "Typical usage example:", "", "    " }),
		i(3, "result = function(args)"),
		t({ "", '"""', "" }),
		i(0),
	}),
}
