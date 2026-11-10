-- lua/lsp/servers/clangd.lua

-- C, C++ and Objective-C through clangd. The nvim-lspconfig defaults cover the
-- command, the filetypes and the root markers, which search for a compilation
-- database first, so projects with `compile_commands.json` or `compile_flags.txt`
-- get an accurate view of includes and flags.
--
-- Formatting stays with conform, which runs clang-format with the style from
-- `~/.clang-format`, so the server never formats.
--
-- :MasonInstall clangd
--
-- See: lua/plugins/formatting.lua
-- See: resources/clang-format.example.yaml
-- See: https://clangd.llvm.org

return {
	config = {},
}
