-- lua/snippets/python.lua

-- Python snippets for practice problem scaffolding and documentation
-- boilerplate. The solution template creates a Solution class with a solve
-- method and a runnable main block, while mirrored function nodes keep the
-- method call synchronized with its name. Docstrings follow the Google style;
-- indentation assumes four spaces.
--
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

	-- Google-style docstring with argument and return sections.
	-- Remove unused parameter lines or the Returns section as needed.
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
		t({ "", '"""' }),
	}),

	-- Google-style docstring for functions and methods that return nothing.
	s("docv", {
		t('"""'),
		i(1, "Short description."),
		t({ "", "", "Args:", "    " }),
		i(2, "param"),
		t(": "),
		i(3, "Description."),
		t({ "", '"""' }),
	}),

	-- Google-style class docstring with an Attributes section. Duplicate the
	-- attribute lines as needed.
	s("docc", {
		t('"""'),
		i(1, "Class description."),
		t({ "", "", "Attributes:", "    " }),
		i(2, "attr"),
		t(": "),
		i(3, "Description."),
		t({ "", '"""' }),
	}),

	-- Module docstring with a short and a longer description, placed at the
	-- very top of the file.
	s("docm", {
		t('"""'),
		i(1, "Short description."),
		t({ "", "", "" }),
		i(2, "Longer description."),
		t({ "", '"""' }),
	}),
}
