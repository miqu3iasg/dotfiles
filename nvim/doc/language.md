# Language servers

The native LSP stack: server modules, attach behavior, diagnostics and linting

## Synopsis

- `lua/language/init.lua` — the shared setup and the stack toggles
- `lua/language/types.lua` — the server module contract
- `lua/language/servers/<name>.lua` — one module per server
- `lua/language/lint.lua` — external linters through `nvim-lint`
- `doc/language.md` — this page

## Description

The config uses Neovim's native LSP client, not a wrapper distribution. Servers are declared as data, one file per server, and started through `vim.lsp.enable`. Mason installs the executables; `mason-lspconfig.nvim` is used only as an installer list, with `automatic_enable` off so this config keeps control of the enable order.

The layer slots into the plugin load list between completion and the fuzzy finder (`lua/plugins/init.lua`), because completion needs the client API and the Markdown setup needs marksman.

## Startup

`lua/language/init.lua` does the following:

1. `require("mason").setup()` immediately.
2. Schedules `mason-lspconfig.setup` after startup with `automatic_enable = false` and `ensure_installed` set to every server in `modules` plus `install_only`. Installation requests therefore never delay the first screen.
3. Defines the global configuration with `vim.lsp.config("*", ...)`:
    - the default client capabilities;
    - dynamic `workspace/didChangeWatchedFiles` registration disabled, because large projects made servers register thousands of watchers;
    - inlay hints and semantic tokens enabled.
4. Loads each module in `modules`, validates it with `types.validate`, and passes its `config` to `vim.lsp.config(name, config)`.
5. Registers one `LspAttach` autocmd for the buffer-local keymaps and the module hook.
6. Configures diagnostics display and disables it globally.
7. Calls `vim.lsp.enable(modules)`.
8. Loads `language.lint`, so linting exists before the first Python buffer.

The modules list is `clangd`, `cssls`, `emmet_language_server`, `eslint`, `html`, `lua_ls`, `marksman`, `pyright`, `tailwindcss` and `vtsls`. `jdtls` is in `install_only` because nvim-jdtls starts it per buffer; it is never part of `vim.lsp.enable`.

## The server contract

Every file in `servers/` returns a `UserLspServerModule`:

```lua
---@class UserLspServerModule
---@field config vim.lsp.Config
---@field on_attach? fun(client: vim.lsp.Client, bufnr: integer)
return {
  config = { ... },
  on_attach = function(client, bufnr) ... end, -- optional
}
```

`types.validate` is deliberately strict: a table without a `config` table, or an `on_attach` that is not a function, raises a startup error naming the server. A malformed module fails loudly at startup instead of producing a silently broken attach later.

`on_attach` is dispatched by the shared `LspAttach` autocmd, after the buffer-local keymaps are set. It receives the client and the buffer, and is the place for per-server behavior that is not part of the `config` table (for example, the ESLint fix-all autocmd).

## Shared attach behavior

The `LspAttach` autocmd sets only mappings that have no native default. The behavior is:

- signature help in insert mode and in normal mode;
- declaration, definition, implementation (in a split) and workspace symbols;
- rename and code action;
- organize imports, using the `source.organizeImports` code action and applying it;
- a diagnostic float for the cursor position;
- previous and next diagnostic jumps, showing the float.

Neovim 0.11 and later already ship defaults for many LSP actions, so this list intentionally stays small. Server modules can add more through `on_attach`.

## Diagnostics

Diagnostics start disabled: no underlines, virtual text, signs or line highlights until the display is toggled. This keeps a fresh buffer quiet while servers are still indexing.

The configuration itself is set once:

- virtual text with an empty prefix;
- severity sort;
- underlines on;
- line highlights per severity (`DiagnosticLineError`, `DiagnosticLineWarn`, `DiagnosticLineInfo`, `DiagnosticLineHint`);
- floating windows using the global window border.

Toggling the display calls `vim.diagnostic.enable(state)`. When turning it back on, it re-applies the lint state, because enabling every diagnostic namespace would revive a linter the user had turned off. The lint module exposes `resync()` for exactly that.

## Linting

`lua/language/lint.lua` runs external linters through `nvim-lint`, outside the server stack. Python is the only configured language, with `ruff`, the same tool conform uses for formatting. Ruff reads its configuration from the project, so no rules live in the config.

The linter runs on `BufWritePost` and `FileType` while linting is enabled, into its own diagnostic namespace. Linting has a toggle independent of server diagnostics, and toggling diagnostics does not silently undo it.

## Servers

| Server                  | Languages                             | Decisions                                                                                                                                                                                                                                        |
| ----------------------- | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `clangd`                | C, C++, Objective-C                   | Background index on, header insertion `iwyu`, detailed completion, function argument placeholders. Formatting stays with conform.                                                                                                                |
| `cssls`                 | CSS, SCSS, LESS                       | Its formatter and validation are off, so conform is the only formatter and the browser is the source of truth for validity.                                                                                                                      |
| `emmet_language_server` | HTML, CSS, SCSS, JSX, TSX, templ, PHP | Adds `templ` and `php` to the default filetypes.                                                                                                                                                                                                 |
| `eslint`                | JavaScript, TypeScript                | Runs `onSave` with its formatter off, `workingDirectory` auto. `on_attach` registers `LspEslintFixAll` on `BufWritePre`, gated by the autoformat state, so fixes run before conform formats.                                                     |
| `html`                  | HTML, templ, PHP                      | Formatter off, `templ` and `php` added.                                                                                                                                                                                                          |
| `lua_ls`                | Lua                                   | Set up mainly to type the config itself. `lazydev.nvim` adds the Neovim runtime and the `vim.uv` and `love2d` libraries. Runtime LuaJIT, `vim` as a global, `different-requires` disabled, snippet completion on.                                |
| `marksman`              | Markdown                              | Workspace root is the nearest `.git`, `README.md`, `README.markdown` or `.marksman.toml`, falling back to the file's directory.                                                                                                                  |
| `pyright`               | Python                                | `standard` type checking, `openFilesOnly`, auto-import completion, library code for types, function return and variable inlay hints.                                                                                                             |
| `tailwindcss`           | HTML, CSS, SCSS, JS/TS, templ         | `templ` is mapped to HTML, and `cn`, `clsx`, `cx`, `cva`, `tv`, `twMerge` are treated as class helpers.                                                                                                                                          |
| `vtsls`                 | TypeScript, JavaScript                | Wraps tsserver in native LSP. Imports are organized on save, the import specifier is `shortest`, type-only auto-imports are preferred, and a parameter-name inlay hint is shown for literals. Never enable `ts_ls` too, or results appear twice. |

`pyright` type checking is limited to open files on purpose. Whole-project checking on a large repository is slow and duplicates what CI does.

### Java

`lua/language/servers/jdtls.lua` is deliberately different. `nvim-jdtls` starts a client per buffer, driven by `after/ftplugin/java.lua`, and the module handles the whole lifecycle:

- it requires a JDK 21 or newer under `/usr/lib/jvm`; other installed JDKs are advertised to jdtls as runtimes, with Java 8 reported as `JavaSE-1.8`;
- each project root gets an isolated workspace under `stdpath("cache")/jdtls-workspace/<hash>-<name>`, holding only the index;
- Lombok is added as a Java agent when `lombok.jar` exists in the Mason package;
- dynamic file watching is disabled again, since the client is created outside the shared configuration;
- semantic tokens, signature help, code lenses, inlay hints and document highlights are disabled, and completion is kept;
- diagnostics from the server are ignored, because the client is used for navigation; formatting is off and belongs to conform;
- `autobuild` is off and one concurrent build is allowed, which keeps a large workspace responsive;
- Maven projects use `pom.xml`/`mvnw`, Gradle projects use `gradlew`/`build.gradle`/`build.gradle.kts`; `M.build("run"|"test"|"build")` opens a terminal in the project root with the matching task;
- `M.stop` stops every jdtls client, `M.update_project` asks the owning client to reload the build configuration, and `M.wipe_workspace` deletes the index and reloads the buffer.

The LSP toggle starts jdtls for already open Java buffers and stops it with the rest. The server also stops when its last buffer closes. `:MasonInstall jdtls` is needed once, and `jdk21-openjdk` plus `maven` come from the distribution.

## Toggles

The stack has three independent switches:

- diagnostics display, which never stops a server;
- the whole LSP stack, which stops clients rather than merely detaching them, and restarts jdtls for open Java buffers when enabled again;
- linting, in its own namespace.

All three notify their new state and are safe to call from keymaps.

## Adding a server

Read `doc/development.md`. The short version: create `servers/<name>.lua` with a `config` table and an optional `on_attach`, add the name to `modules` in `language/init.lua`, and let Mason install it. If the server is started by another client wrapper, put it in `install_only` and let that wrapper own the lifecycle.

## Files

- [`lua/language/init.lua`](../lua/language/init.lua) — shared setup and toggles
- [`lua/language/types.lua`](../lua/language/types.lua) — the module contract
- [`lua/language/lint.lua`](../lua/language/lint.lua) — external linters
- [`lua/language/servers/`](../lua/language/servers/) — one module per server
- [`after/ftplugin/java.lua`](../after/ftplugin/java.lua) — Java options, keymaps and the jdtls start

## See also

- [plugins](./plugins.md)
- [config](./config.md)
- [development](./development.md)
- [troubleshooting](./troubleshooting.md)
- [kickstart](./kickstart.md)
