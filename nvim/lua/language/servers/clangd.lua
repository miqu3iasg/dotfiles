-- lua/language/servers/clangd.lua

-- C, C++ and Objective-C through clangd, with the background index on so
-- parsing results persist between sessions.
--
-- Formatting stays with conform, which reads the style from `~/.clang-format`.
--
-- clangd comes from Mason.
--
-- :MasonInstall clangd
--
-- See: lua/plugins/formatting.lua
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
