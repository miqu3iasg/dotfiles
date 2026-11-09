-- lua/snippets/python.lua

-- Python snippets for practice problem scaffolding and Google-style docstrings.
-- The solution template creates a Solution class with a solve method and a
-- runnable main block, while mirrored function nodes keep the method call
-- synchronized with its name.

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
}
