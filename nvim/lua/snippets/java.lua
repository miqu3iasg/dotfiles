-- lua/snippets/java.lua

-- Java snippets for scaffolding, types, members, output, comments and Javadoc.
-- Mirrored nodes keep related declarations in sync; indentation is four spaces.
--
-- See: doc/snippets.txt
-- See: https://docs.oracle.com/en/java/javase/21/docs/specs/javadoc/doc-comment-spec.html
-- See: https://www.oracle.com/java/technologies/javase/writing-doc-comments.html#orderoftags
-- See: https://google.github.io/styleguide/javaguide.html#s7-javadoc

local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local c = ls.choice_node
local h = require("lib.headers")

---Current file name without its extension, used as the default class name.
---@return string
local function get_classname()
	local name = vim.fn.expand("%:t:r")
	return name ~= "" and name or "Untitled"
end

---Package name inferred from the buffer directory, falling back to
---`com.example` outside the Maven/Gradle layout.
---@return string
local function get_package()
	local dir = vim.fn.expand("%:p:h"):gsub("\\", "/")
	local rel = dir:match("/src/[^/]+/java/(.+)$") or dir:match("/src/(.+)$")
	if not rel then
		return "com.example"
	end
	return (rel:gsub("/", "."))
end

---Capitalize the first letter of an insert node, for getter and setter names.
---@param args table
---@return string
local function capitalize(args)
	local str = args[1][1] or ""
	return str:sub(1, 1):upper() .. str:sub(2)
end

---Mirror the text of another insert node.
---@param idx integer
---@return table
local function mirror(idx)
	return f(function(args)
		return args[1][1]
	end, { idx })
end

---Insert a node whose default value is computed when the snippet expands.
---@param pos integer
---@param fn fun(): string
---@return table
local function dynamic_default(pos, fn)
	return d(pos, function()
		return sn(nil, { i(1, fn()) })
	end, {})
end

---Editable access modifier, for package-private visibility when cleared.
---@param pos integer
---@param default? string
---@return table
local function access(pos, default)
	return i(pos, default or "public")
end

---Editable static modifier, omitted when cleared.
---@param pos integer
---@return table
local function static_choice(pos)
	return i(pos, "static")
end

---Output a space only when the referenced node is not empty.
---@param idx integer
---@return table
local function with_space(idx)
	return f(function(args)
		local v = args[1][1] or ""
		return v ~= "" and " " or ""
	end, { idx })
end

---Create a method snippet with a fixed modifier.
---@param trig string
---@param modifier string
---@return table
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

	-- Package declaration inferred from the directory layout.
	s("pkg", {
		t("package "),
		dynamic_default(1, get_package),
		t(";"),
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

	-- Javadoc: blocks.

	-- Class, interface, or enum documentation. Goes after the imports and
	-- before the declaration (and before annotations such as @Entity).
	-- Delete @author if your team relies on version control for authorship.
	s("docc", {
		t({ "/**", " * " }),
		i(1, "Summary fragment ending with a period."),
		t({ "", " *", " * <p>" }),
		i(2, "Longer description: responsibilities, invariants, thread-safety, usage notes."),
		t({ "", " *", " * @author " }),
		i(3, "Miquéias Alves Medeiros"),
		t({ "", " * @version " }),
		i(4, "1.0"),
		t({ "", " * @see " }),
		i(5, "RelatedClass"),
		t({ "", " * @since " }),
		i(6, "1.0"),
		t({ "", " */", "" }),
		i(0),
	}),

	-- Documentation for a generic class or interface, with the @param <T> tag.
	s("docg", {
		t({ "/**", " * " }),
		i(1, "Summary fragment ending with a period."),
		t({ "", " *", " * <p>" }),
		i(2, "Longer description: responsibilities, invariants, thread-safety, usage notes."),
		t({ "", " *", " * @author " }),
		i(3, "Miquéias Alves Medeiros"),
		t({ "", " * @version " }),
		i(4, "1.0"),
		t({ "", " * @param <" }),
		i(5, "T"),
		t("> "),
		i(6, "the type of ..."),
		t({ "", " * @see " }),
		i(7, "RelatedClass"),
		t({ "", " * @since " }),
		i(8, "1.0"),
		t({ "", " */", "" }),
		i(0),
	}),

	-- Documentation for a generic method: the type parameter's @param comes
	-- before the value parameters.
	s("docgm", {
		t({ "/**", " * " }),
		i(1, "Summary fragment ending with a period."),
		t({ "", " *", " * <p>" }),
		i(2, "Longer description: responsibilities, invariants, thread-safety, usage notes."),
		t({ "", " *", " * @param <" }),
		i(3, "T"),
		t("> "),
		i(4, "the type of ..."),
		t({ "", " * @param " }),
		i(5, "paramName"),
		t(" "),
		i(6, "description"),
		t({ "", " * @return " }),
		i(7, "description"),
		t({ "", " * @throws " }),
		i(8, "IllegalArgumentException"),
		t(" "),
		i(9, "if ..."),
		t({ "", " */", "" }),
		i(0),
	}),

	-- Record documentation. Records document their components with @param.
	s("docr", {
		t({ "/**", " * " }),
		i(1, "Summary fragment ending with a period."),
		t({ "", " *", " * <p>" }),
		i(2, "Longer description: responsibilities, invariants, thread-safety, usage notes."),
		t({ "", " *", " * @author " }),
		i(3, "Miquéias Alves Medeiros"),
		t({ "", " * @version " }),
		i(4, "1.0"),
		t({ "", " * @param " }),
		i(5, "component"),
		t(" "),
		i(6, "description of the component"),
		t({ "", " * @see " }),
		i(7, "RelatedClass"),
		t({ "", " * @since " }),
		i(8, "1.0"),
		t({ "", " */", "" }),
		i(0),
	}),

	-- Method documentation with parameter, return, and exception tags.
	-- The summary is a fragment such as "Returns the customer ID.".
	-- Describe the contract, not the type: null policy, units, valid range,
	-- side effects, and when each exception is thrown.
	-- Remove the tags that do not apply.
	s("doc", {
		t({ "/**", " * " }),
		i(1, "Summary fragment ending with a period."),
		t({ "", " *", " * <p>" }),
		i(2, "Longer description: responsibilities, invariants, thread-safety, usage notes."),
		t({ "", " *", " * @param " }),
		i(3, "paramName"),
		t(" "),
		i(4, "description"),
		t({ "", " * @param " }),
		i(5, "paramName"),
		t(" "),
		i(6, "description"),
		t({ "", " * @return " }),
		i(7, "description"),
		t({ "", " * @throws " }),
		i(8, "IllegalArgumentException"),
		t(" "),
		i(9, "if ..."),
		t({ "", " */", "" }),
		i(0),
	}),

	-- Documentation for void methods and constructors (no @return tag).
	-- Document the contract: null policy, units, valid range, side effects.
	s("docv", {
		t({ "/**", " * " }),
		i(1, "Summary fragment ending with a period."),
		t({ "", " *", " * <p>" }),
		i(2, "Longer description: responsibilities, invariants, thread-safety, usage notes."),
		t({ "", " *", " * @param " }),
		i(3, "paramName"),
		t(" "),
		i(4, "description"),
		t({ "", " * @throws " }),
		i(5, "IllegalArgumentException"),
		t(" "),
		i(6, "if ..."),
		t({ "", " */", "" }),
		i(0),
	}),

	-- Extra @param line inside an existing doc block.
	s("docp", { t("@param "), i(1, "paramName"), t(" "), i(2, "description"), i(0) }),

	-- One-line documentation comment for fields and constants.
	s("docf", { t("/** "), i(1, "Summary fragment."), t({ " */", "" }), i(0) }),

	-- Package documentation, for package-info.java. The package name is
	-- inferred from the directory layout.
	s("docpkg", {
		t({ "/**", " * " }),
		i(1, "Summary fragment ending with a period."),
		t({ "", " *", " * <p>" }),
		i(2, "Overview of the package: what it contains and how the pieces fit together."),
		t({ "", " *", " * @author " }),
		i(3, "Miquéias Alves Medeiros"),
		t({ "", " * @version " }),
		i(4, "1.0"),
		t({ "", " * @see " }),
		i(5, "RelatedClass"),
		t({ "", " * @since " }),
		i(6, "1.0"),
		t({ "", " */", "package " }),
		dynamic_default(7, get_package),
		t(";"),
		i(0),
	}),

	-- Deprecated documentation followed by the @Deprecated annotation.
	-- The text says why the element is deprecated and what replaces it.
	-- Tab through to add forRemoval = true when the API will be removed.
	s("docd", {
		t({ "/**", " * " }),
		i(1, "Summary fragment ending with a period."),
		t({ "", " *", " * @deprecated " }),
		i(2, "Use {@link Other} instead."),
		t({ "", " */", '@Deprecated(since = "' }),
		i(3, "1.0"),
		t('"'),
		c(4, { t(""), t(", forRemoval = true") }),
		t({ ")", "" }),
		i(0),
	}),

	-- Javadoc: inline and standalone tags.
	s("link", { t("{@link "), i(1, "Class#method"), t("}"), i(0) }),
	s("linkp", { t("{@linkplain "), i(1, "Class#method"), t(" "), i(2, "label"), t("}"), i(0) }),
	s("code", { t("{@code "), i(1), t("}"), i(0) }),
	s("lit", { t("{@literal "), i(1), t("}"), i(0) }),
	s("val", { t("{@value "), i(1, "Class#CONSTANT"), t("}"), i(0) }),
	s("inh", { t("{@inheritDoc}"), i(0) }),
	s("seeref", { t("@see "), i(1, "Reference"), i(0) }),
	s("seel", {
		t('@see <a href="'),
		f(h.get_clipboard, {}),
		t('">'),
		i(1, "label"),
		t("</a>"),
		i(0),
	}),
	s("hidden", { t("@hidden"), i(0) }),
	s("serial", { t("@serial "), i(1, "field description"), i(0) }),
	s("summary", { t("{@summary "), i(1), t("}"), i(0) }),
	s("index", { t("{@index "), i(1, "word"), t(" "), i(2, "description"), t("}"), i(0) }),
	s("systemprop", { t("{@systemProperty "), i(1, "property.name"), t("}"), i(0) }),

	-- External, testable example for Java 18+; the file lives in snippet-files.
	s("docsnip", { t('{@snippet file="'), i(1, "Example.java"), t('"}'), i(0) }),

	-- Code example inside a Javadoc block. Keep the leading asterisks.
	s("doce", {
		t({ "<pre>{@code", " * " }),
		i(1, "example code"),
		t({ "", " * }</pre>" }),
		i(0),
	}),
}
