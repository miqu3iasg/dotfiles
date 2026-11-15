-- Luacheck: https://lunarmodules.github.io/luacheck/
-- Copy to the project root. The standard library is set to LuaJIT; raise it to
-- "lua54" for plain Lua projects. `vim` is global only in Neovim-adjacent
-- code, so remove it from the list elsewhere.

std = "luajit"
cache = true
max_line_length = 120
globals = { "vim" }

-- Unused arguments prefixed with `_` are intentionally unused.
ignore = { "212/_.*" }
