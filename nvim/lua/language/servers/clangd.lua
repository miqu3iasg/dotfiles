-- lua/language/servers/clangd.lua

-- C, C++ and Objective-C through clangd. The flags below keep the background
-- index, which persists parsing results between sessions, insert missing
-- headers by include-what-you-use ordering, filter the completion lists on the
-- server side, and complete function calls with placeholder arguments. Project
-- roots come from `compile_commands.json` or `compile_flags.txt` when they
-- exist. Formatting stays with conform, which runs clang-format with the style
-- from `~/.clang-format`.
--
-- :MasonInstall clangd
--
-- See: lua/plugins/formatting.lua
-- See: resources/clang-format.example.yaml
-- See: https://clangd.llvm.org

---@type UserLspServerModule
return {
	config = {
		cmd = {
			"clangd",
			"--background-index",
			"--header-insertion=iwyu",
			"--completion-style=detailed",
			"--function-arg-placeholders=1",
		},
	},
}
