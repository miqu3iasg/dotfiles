-- lua/snippets/java.lua

-- Java snippets for program scaffolding, types, members, output, comments, and
-- Javadoc. Dynamic helpers derive class names and dates from the current buffer,
-- while mirrored insert nodes keep related declarations synchronized. Indentation
-- uses four spaces and modifiers can be removed by clearing their insert nodes.
--
-- See: https://docs.oracle.com/javase/8/docs/technotes/tools/windows/javadoc.html
-- See: https://www.baeldung.com/javadoc

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node

-- Current file name without its extension, used as the default class name.
local function get_classname()
	local name = vim.fn.expand("%:t:r")
	return name ~= "" and name or "Untitled"
end

-- Current date in ISO format, used in @since tags.
local function today()
	return os.date("%Y-%m-%d")
end

-- Capitalizes the first letter of an insert node for getter and setter names.
local function capitalize(args)
	local str = args[1][1] or ""
	return str:sub(1, 1):upper() .. str:sub(2)
end

-- Mirrors the text of another insert node.
local function mirror(idx)
	return f(function(args)
		return args[1][1]
	end, { idx })
end

-- Creates an insert node whose default value is computed when the snippet
-- expands.
local function dynamic_default(pos, fn)
	return d(pos, function()
		return sn(nil, { i(1, fn()) })
	end, {})
end

-- Editable access modifier. Clear the node for package-private visibility.
-- Always follow it with with_space(pos).
local function access(pos, default)
	return i(pos, default or "public")
end

-- Editable static modifier. Clear the node to omit it.
-- Always follow it with with_space(pos).
local function static_choice(pos)
	return i(pos, "static")
end

-- Outputs a space only when the referenced node is not empty, preventing
-- stray whitespace when an optional modifier is removed.
local function with_space(idx)
	return f(function(args)
		local v = args[1][1] or ""
		return v ~= "" and " " or ""
	end, { idx })
end

-- Creates a method snippet with a fixed modifier.
local function method(trig, modifier)
	return s(trig, {
		t(modifier .. " "),
		i(1, "void"),
		t(" "),
		i(2, "name"),
		t("("),
		i(3),
		t({ ") {", "    " }),
		i(4),
		t({ "", "}" }),
		i(0),
	})
end

return {
	-- Solution scaffold for practice problems (LeetCode, Kattis, etc.).
	-- Creates a public class with a main method that calls Solution.solve.
	s("sol", {
		t("public class "),
		f(get_classname, {}),
		t({
			" {",
			"",
			"    public static void main(String[] args) {",
			"        Solution sol = new Solution();",
		}),
		t({ "", "        System.out.println(sol." }),
		f(function(args)
			return args[1][1]
		end, { 2 }),
		t("("),
		i(5, "/* args */"),
		t("));"),
		t({
			"",
			"    }",
			"}",
			"",
			"class Solution {",
			"    public ",
		}),
		i(1, "int"),
		t(" "),
		i(2, "solve"),
		t("("),
		i(3, "int[] nums"),
		t({ ") {", "        " }),
		i(4, "// TODO: implement"),
		t({ "", "    }", "}" }),
		i(0),
	}),

	-- Runnable public class named after the current file.
	s("run", {
		t("public class "),
		f(get_classname, {}),
		t({ " {", "", "    public static void main(String[] args) {", "        " }),
		i(1, "// TODO"),
		t({ "", "    }", "}" }),
		i(0),
	}),

	-- Runnable public class with a Scanner reading from standard input.
	s("runsc", {
		t({ "import java.util.Scanner;", "", "public class " }),
		f(get_classname, {}),
		t({
			" {",
			"",
			"    public static void main(String[] args) {",
			"        Scanner sc = new Scanner(System.in);",
			"        ",
		}),
		i(1),
		t({ "", "        sc.close();", "    }", "}" }),
		i(0),
	}),

	-- Main method declaration.
	s("main", {
		t({ "public static void main(String[] args) {", "    " }),
		i(1),
		t({ "", "}" }),
		i(0),
	}),

	-- Types.

	-- Class named after the current file by default.
	s("class", {
		access(1),
		with_space(1),
		t("class "),
		dynamic_default(2, get_classname),
		t({ " {", "    " }),
		i(3),
		t({ "", "}" }),
		i(0),
	}),

	-- Abstract class declaration.
	s("aclass", {
		access(1),
		with_space(1),
		t("abstract class "),
		i(2, "Name"),
		t({ " {", "    " }),
		i(3),
		t({ "", "}" }),
		i(0),
	}),

	-- Class extending another class.
	s("sclass", {
		access(1),
		with_space(1),
		t("class "),
		i(2, "Child"),
		t(" extends "),
		i(3, "Parent"),
		t({ " {", "    " }),
		i(4),
		t({ "", "}" }),
		i(0),
	}),

	-- Class implementing an interface.
	s("iclass", {
		access(1),
		with_space(1),
		t("class "),
		i(2, "Name"),
		t(" implements "),
		i(3, "Interface"),
		t({ " {", "    " }),
		i(4),
		t({ "", "}" }),
		i(0),
	}),

	-- Interface declaration.
	s("iface", {
		access(1),
		with_space(1),
		t("interface "),
		i(2, "Name"),
		t({ " {", "    " }),
		i(3),
		t({ "", "}" }),
		i(0),
	}),

	-- Enum declaration with editable constants.
	s("enum", {
		access(1),
		with_space(1),
		t("enum "),
		i(2, "Name"),
		t({ " {", "    " }),
		i(3, "A, B, C"),
		t({ "", "}" }),
		i(0),
	}),

	-- Record declaration with editable components.
	s("rec", {
		access(1),
		with_space(1),
		t("record "),
		i(2, "Name"),
		t("("),
		i(3, "String name, int age"),
		t(") {}"),
		i(0),
	}),

	-- Constructor named after the current file by default.
	s("constr", {
		access(1),
		with_space(1),
		dynamic_default(2, get_classname),
		t("("),
		i(3),
		t({ ") {", "    " }),
		i(4),
		t({ "", "}" }),
		i(0),
	}),

	-- Method with optional access and static modifiers.
	-- Clear either modifier to omit it.
	s("fun", {
		access(1),
		with_space(1),
		static_choice(2),
		with_space(2),
		i(3, "void"),
		t(" "),
		i(4, "name"),
		t("("),
		i(5),
		t({ ") {", "    " }),
		i(6),
		t({ "", "}" }),
		i(0),
	}),

	-- Methods with fixed access or static modifiers.
	method("pubfun", "public"),
	method("privfun", "private"),
	method("protfun", "protected"),
	method("sfun", "public static"),

	-- Field with an editable modifier, private and final by default.
	-- Replace "final" with another modifier or clear it to omit the modifier.
	s("field", {
		access(1, "private"),
		with_space(1),
		i(2, "final"),
		with_space(2),
		i(3, "String"),
		t(" "),
		i(4, "name"),
		t(";"),
		i(0),
	}),

	-- Static final constant.
	s("const", {
		access(1),
		with_space(1),
		t("static final "),
		i(2, "int"),
		t(" "),
		i(3, "CONSTANT"),
		t(" = "),
		i(4),
		t(";"),
		i(0),
	}),

	-- Private field with synchronized getter and setter methods.
	s("getset", {
		t("private "),
		i(1, "String"),
		t(" "),
		i(2, "name"),
		t({ ";", "", "public " }),
		mirror(1),
		t(" get"),
		f(capitalize, { 2 }),
		t({ "() {", "    return " }),
		mirror(2),
		t({ ";", "}", "", "public void set" }),
		f(capitalize, { 2 }),
		t("("),
		mirror(1),
		t(" "),
		mirror(2),
		t({ ") {", "    this." }),
		mirror(2),
		t(" = "),
		mirror(2),
		t({ ";", "}" }),
		i(0),
	}),

	-- toString implementation using the current file name as the class name.
	s("tostring", {
		t({ "@Override", "public String toString() {", '    return "' }),
		f(get_classname, {}),
		t("{"),
		i(1),
		t({ '}";', "}" }),
		i(0),
	}),

	-- Prints a value followed by a newline.
	s("sout", { t("System.out.println("), i(1), t(");"), i(0) }),

	-- Formats output using printf and the platform newline.
	s("souf", { t('System.out.printf("'), i(1, "%s"), t('%n"'), i(2), t(");"), i(0) }),

	-- Prints an error message to the standard error stream.
	s("serr", { t("System.err.println("), i(1), t(");"), i(0) }),

	-- Single-line comment.
	s("cm", { t("// "), i(1, "comment"), i(0) }),

	-- Multi-line block comment.
	s("cmm", {
		t({ "/*", " * " }),
		i(1, "comment"),
		t({ "", " */" }),
		i(0),
	}),

	-- Empty multi-line annotation block.
	s("nb", {
		t({ "/*", "", "" }),
		i(1),
		t({ "", "", "*/" }),
		i(0),
	}),

	-- Method documentation with parameter, return, and exception tags.
	-- Remove the tags that do not apply.
	s("doc", {
		t({ "/**", " * " }),
		i(1, "Description."),
		t({ "", " *", " * @param " }),
		i(2, "paramName"),
		t(" "),
		i(3, "Description."),
		t({ "", " * @param " }),
		i(4, "paramName"),
		t(" "),
		i(5, "Description."),
		t({ "", " * @return " }),
		i(6, "Description."),
		t({ "", " * @throws " }),
		i(7, "Exception"),
		t(" "),
		i(8, "When it is thrown."),
		t({ "", " */" }),
		i(0),
	}),

	-- Method documentation without an @return tag, intended for void methods.
	s("docv", {
		t({ "/**", " * " }),
		i(1, "Description."),
		t({ "", " *", " * @param " }),
		i(2, "paramName"),
		t(" "),
		i(3, "Description."),
		t({ "", " */" }),
		i(0),
	}),

	-- Class documentation with author, version, and expansion-time @since date.
	s("docc", {
		t({ "/**", " * " }),
		i(1, "Description."),
		t({ "", " *", " * @author " }),
		i(2, "Miquéias Alves Medeiros"),
		t({ "", " * @version " }),
		i(3, "1.0"),
		t({ "", " * @since " }),
		dynamic_default(4, today),
		t({ "", " */" }),
		i(0),
	}),

	-- One-line documentation comment for fields and constants.
	s("docf", { t("/** "), i(1, "Description."), t(" */"), i(0) }),

	-- Inline and standalone Javadoc tags.
	s("link", { t("{@link "), i(1, "Class#method"), t("}"), i(0) }),
	s("code", { t("{@code "), i(1), t("}"), i(0) }),
	s("seeref", { t("@see "), i(1, "Reference"), i(0) }),

	-- Deprecated documentation followed by the @Deprecated annotation.
	s("dep", {
		t({ "/**", " * " }),
		i(1, "Description."),
		t({ "", " *", " * @deprecated " }),
		i(2, "Use {@link Other} instead."),
		t({ "", " */", "@Deprecated", "" }),
		i(0),
	}),
}
