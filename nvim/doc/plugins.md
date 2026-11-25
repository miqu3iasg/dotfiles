# Plugins

The plugin set, the adapter files and the lazy-loading rule

## Synopsis

- `lua/config/pack.lua` — eager declarations and install hooks
- `lua/plugins/init.lua` — the ordered adapter list
- `lua/plugins/<name>.lua` — one adapter per plugin suite
- `lua/lib/lazy.lua` — the filetype lazy loader
- `doc/plugins.md` — this page

## Description

Plugins are installed by Neovim's built-in package manager, `vim.pack`. There is no distribution and no third-party plugin manager. Eager plugins are declared in `lua/config/pack.lua`; a lazy plugin declares itself at the bottom of its own adapter file through `lib.lazy` and needs no other entry.

An adapter is the only place a plugin is configured. It owns the plugin's setup, the globals the plugin reads, and the keymaps that only make sense inside that plugin. Keymaps for behavior that exists without the plugin live in `lua/config/keymaps/`.

## Installing and updating

`vim.pack.add` installs anything missing on startup. `nvim-pack-lock.json` is the revision lock written by `vim.pack`; treat it as generated and update plugins through the commands, not by editing the file.

| Command               | Behavior                                              |
| --------------------- | ----------------------------------------------------- |
| `:PackAdd {repos}`    | Adds plugins to the session, installing missing ones. |
| `:PackDel {names}`    | Deletes plugins by name.                              |
| `:PackUpdate [names]` | Updates every plugin, or only the named ones.         |

`:PackDel` and `:PackUpdate` mirror built-ins arriving in Neovim 0.13; they exist now so the same names keep working across both versions.

`PackChanged` in `lua/config/pack.lua` runs the install and update hooks:

- `nvim-treesitter` gets `:TSUpdate`; the plugin is `:packadd`-ed first when it is not active yet;
- `LuaSnip` runs `make install_jsregexp` in the plugin directory and warns, without failing the install, when the C toolchain is missing.

A plugin that needs a build step must be handled there. A plugin that needs a manual step has it documented in its adapter header.

## Eager plugins

These are declared in `lua/config/pack.lua` and load at startup:

| Plugin                      | Purpose                                                                                   | Adapter                                  |
| --------------------------- | ----------------------------------------------------------------------------------------- | ---------------------------------------- |
| canola.nvim                 | File explorer that edits the filesystem as a buffer, a fork of oil.nvim, replacing netrw. | `plugins/oil.lua`                        |
| nvim-treesitter             | Parser management, highlighting and indentation. `main` branch.                           | `plugins/treesitter.lua`                 |
| nvim-treesitter-textobjects | Syntax-aware text objects and motions. `main` branch.                                     | `plugins/unnecessary-shit.lua`           |
| obsidian.nvim               | Wikilinks, completion and vault features for Markdown notes.                              | `plugins/markdown.lua`                   |
| LuaSnip                     | Snippet engine, version range `2.*`.                                                      | `plugins/completions.lua`, `snippets/`   |
| conform.nvim                | Runs external formatters on demand and on save.                                           | `plugins/formatting.lua`                 |
| nvim-lint                   | Runs external linters on demand.                                                          | `language/lint.lua`                      |
| vim-fugitive                | Staging, committing, diffing and blaming.                                                 | `plugins/git.lua`                        |
| vim-rhubarb                 | Makes `:GBrowse` build GitHub URLs.                                                       | `plugins/git.lua`                        |
| gitsigns.nvim               | Hunk markers, staging, preview and blame in the buffer.                                   | `plugins/git.lua`                        |
| mason.nvim                  | Installs language servers, formatters, linters and debuggers.                             | `language/init.lua`                      |
| mason-lspconfig.nvim        | Installer list for the LSP stack, with `automatic_enable` off.                            | `language/init.lua`                      |
| lazydev.nvim                | Adds Neovim API types and annotations to `lua_ls`.                                        | `language/servers/lua_ls.lua`            |
| nvim-lspconfig              | Default configurations for the frontend servers used by `vim.lsp.config`.                 | `language/init.lua`, `language/servers/` |
| mini.nvim                   | Only `mini.ai` and `mini.align` are used.                                                 | `plugins/unnecessary-shit.lua`           |
| vim-tmux-navigator          | One navigation for Neovim splits and tmux panes.                                          | `plugins/unnecessary-shit.lua`           |
| nvim-colorizer.lua          | Inline color preview for color codes.                                                     | `plugins/unnecessary-shit.lua`           |
| nvim-jdtls                  | Java client used by the per-buffer jdtls module.                                          | `language/servers/jdtls.lua`             |
| vim-sleuth                  | Detects tabs or spaces and the indentation width of each file.                            | loaded at startup, no adapter            |
| img-clip.nvim               | Pastes clipboard images into files and inserts the link.                                  | `plugins/markdown.lua`                   |
| flash.nvim                  | Label-based jumps and Tree-sitter selection.                                              | `plugins/unnecessary-shit.lua`           |
| markdown-preview.nvim       | Browser rendering of Markdown, used for documents with Mermaid diagrams.                  | `plugins/markdown.lua`                   |

## Lazy plugins

Lazy loading is the only indirection in the config, and it is one helper: `lua/lib/lazy.lua`. A plugin declares itself in its adapter:

```lua
require("lib.lazy").setup({
  src = "https://github.com/...", -- vim.pack source
  filetypes = { "tex" },          -- load triggers; omit for on-demand
  configure = M.configure,        -- runs before :packadd
  after = M.after,                -- runs after :packadd
})
```

The plugin is installed at startup, but its `plugin/` scripts run only when the first buffer of a declared filetype appears. Loading runs `configure`, then `:packadd`, then `after`, and then fires `FileType` again for the triggering buffer, since the plugin was not on the runtimepath when the original event ran. A call to `require("lib.lazy").load(name)` before `setup` is a no-op; repeated calls are safe.

The two lazy plugins are:

- `fzf-lua` (`plugins/fzf.lua`), triggered by Markdown buffers and loaded on first use from its own keymap stubs. Markdown is included so the Obsidian picker resolves before any picker was opened.
- `Conjure` (`plugins/lisp.lua`), triggered by `scheme`, `lisp`, `racket` and `clojure`. Its `configure` runs before load because Conjure reads globals at load time.

Caveats, documented in the loader:

- a filetype whose detection depends on a global owned by the plugin must set that global at the top level of the adapter, because the plugin is not on the runtimepath at detection time;
- buffers already open at startup are caught by `BufEnter` as well as `FileType`, because a plugin can register its filetypes after the initial event;
- every lazy plugin stays inspectable in one place with `:autocmd LazyPack`.

Inspect loaded lazy plugins with `:autocmd LazyPack`, not with `:scriptnames`, which only shows files already sourced.

## What each adapter configures

### Tree-sitter

Parsers are requested for automatic installation at startup, with at most 4 concurrent jobs. The list covers the languages the config uses: vimdoc, C, Lua, Python, HTML, CSS, Java, Javadoc, JavaScript, TypeScript, TSX, JSDoc, regex, SQL, Markdown, Markdown inline, YAML, Dockerfile, LuaDoc, Scheme, Common Lisp and Racket.

Highlighting is enabled per buffer when the filetype is detected, if the parser exists. Tree-sitter indentation is enabled only for Lua, Python, JavaScript and TypeScript, where it was verified; other languages keep their native indent. The tree-sitter CLI must be on `PATH`, and `PYTHONIOENCODING` is set to `utf-8` for the install jobs.

### Completion and snippets

There is no completion plugin. The popup is native LSP completion, and snippets come from LuaSnip.

- The menu opens automatically only for `javascript`, `javascriptreact`, `typescript`, `typescriptreact`, `html`, `htmlangular`, `css`, `scss`, `json`, `jsonc`, `yaml` and `toml`.
- Elsewhere completion is manual, and the omnifunc still works.
- A toggle forces the automatic popup on for every buffer and back to the filetype default.
- The completion handler drops dead clients on a buffer reload, because a detached server re-calls it with a stale client id.
- Snippets are registered per filetype on first use; `common` snippets extend every language in `common_filetypes`, and `scheme`/`mysql`/`plsql` inherit from `lisp`/`sql`.

Snippet definitions are in `lua/snippets/`, one file per filetype. The standard is `doc/snippets.md`.

### Formatting

conform owns formatting for the whole editor; language servers keep their formatter off. The chains are defined per filetype in `plugins/formatting.lua`:

| Filetypes                              | Chain                                                                     |
| -------------------------------------- | ------------------------------------------------------------------------- |
| Lua                                    | `stylua`                                                                  |
| C, C++                                 | `clang_format` (style from `~/.clang-format`)                             |
| Java                                   | `astyle` (Allman, 4 spaces)                                               |
| Python                                 | `ruff_organize_imports`, `ruff_format`                                    |
| sh, bash                               | `shfmt` (`-i 2 -ci`)                                                      |
| JS/TS/JSX/TSX/HTML/CSS/SCSS/JSON/JSONC | `prettierd`, then `prettier`, stopping at the first success               |
| YAML                                   | `yamlfmt`                                                                 |
| TOML                                   | `taplo`                                                                   |
| XML                                    | `xmlformatter`                                                            |
| SQL                                    | `sql_formatter` (MySQL dialect, uppercase keywords)                       |
| Dockerfile                             | `dockerfmt`                                                               |
| Terraform                              | `terraform_fmt`                                                           |
| Markdown                               | `prettier_md`, the Prettier CLI with tab width 4 and prose wrap preserved |
| asm                                    | `asmfmt`                                                                  |
| anything else                          | `trim_whitespace`, `trim_newlines`                                        |

Formatting on save has a 2000 ms timeout and falls back to LSP formatting when no external formatter exists; the fallback never wins while a server has formatting off. The on/off state lives in `lua/lib/autoformat.lua` with global and buffer-local scopes. `:FormatToggleBuffer` is the per-buffer switch.

`conform` reports errors on format; missing executables simply disable the format of their filetype.

### Fuzzy finder

fzf-lua wraps `fzf` and provides file, buffer, grep, diagnostics, help and history pickers. Its adapter configures:

- a bottom 30% window without backdrop or title, with a hidden `bat` preview;
- `.git`, `node_modules`, virtualenvs, caches, build output and similar directories ignored by the file and grep pickers;
- ripgrep and fd options shared by the pickers;
- colors that follow the current colorscheme, re-applied on `ColorScheme`;
- `zoxide` for frequent directories, and fixed roots under `~/dev/repos` and `~/dotfiles/nvim`.

The plugin needs `fzf`, `grep`, `ripgrep` and `fd`. `lib/substitute.lua` also calls `rg` directly.

### Git

vim-fugitive handles repository operations in tabs and splits; vim-rhubarb makes `:GBrowse` produce a GitHub URL; gitsigns adds hunk-level markers and actions. Destructive remote operations are left to the terminal.

The adapter adds history helpers for the current file, the selected range and the enclosing function. The function range comes from Tree-sitter when a parser exists, falling back to git's own function detection (`-L :name:file`). `modules/close_view.lua` is set up here so Fugitive views close without quitting Neovim. gitsigns installs buffer-local hunk keymaps only in attached buffers, so native diff motions still work elsewhere.

### Markdown and notes

`plugins/markdown.lua` wires the note workflow:

- `modules.notes.setup()` registers the note commands and history;
- img-clip pastes images into `attachments/` for vault notes, or into the project's `attachments/` for other Markdown files, with the embed template matching Obsidian;
- obsidian.nvim uses wiki links, shortest format, the vault folder as its only workspace, and fzf-lua as its picker. Its UI, footer and frontmatter handling are off, because the notes module owns names, templates and dates;
- markdown-preview.nvim is configured for dark theme, auto-close and no auto-start. Its runtime needs a manual `:call mkdp#util#install()` after install or update, which `vim.pack` cannot run.

The vault is `$ARCANUM_DIR`, or `~/dev/arcanum` when unset, and must already exist. The full workflow is `doc/notes.md`.

### Lisp

Conjure lazy-loads for the Lisp family and uses MIT Scheme as the Scheme REPL through `unbuffer -p mit-scheme`. Its HUD is replaced by a docked right split, which opens on the first Scheme, Lisp or Racket buffer. Evaluation, log and word-definition mappings are configured in the adapter, and `maplocalleader` is set before Conjure defines its own mappings.

The adapter needs `tree-sitter-cli`, `racket`, `rlwrap`, `expect` and AUR `mit-scheme`.

### Small conveniences

`plugins/unnecessary-shit.lua` is the dumping ground the name suggests, but its contents are deliberate:

- `mini.align` for interactive alignment and `mini.ai` for Tree-sitter-aware text objects, including class, parameter, code block, comment and whole buffer;
- `vim-tmux-navigator`, which replaces the plain split navigation with tmux-aware navigation (the tmux side needs its own plugin);
- `nvim-colorizer.lua` for CSS, SCSS, Lua, Vue, Svelte, Astro, HTML and the JS/TS family; the LSP color provider is disabled because it fights the plugin;
- `flash.nvim` for label jumps, Tree-sitter selection and Tree-sitter search, with the dimming backdrop off;
- `vim-sleuth` for indentation detection. It has no adapter: it works by being installed.

### Explorer

`plugins/oil.lua` configures the oil API exposed by canola.nvim. The filesystem is a normal buffer; deletions go to the trash, simple edits apply without confirmation, hidden files are shown and changes are watched.

The adapter adds:

- a `gx` viewer map by extension (`zathura` for documents, `imv` for images, `mpv` for audio and video, `xdg-open` as fallback);
- a bottom split picker that opens files in the originating window and warns about unsaved filesystem edits before closing;
- directory navigation for home and the working directory;
- an `explorer` buffer flag, so sessions and other consumers do not depend on the `oil` filetype staying the same.

Disable the plugin by removing the adapter, its declaration in `config/pack.lua` and its entry in `plugins/init.lua`; nothing else references it except the sessions module, which treats any buffer with `b:explorer` as disposable.

## Requirements

Executables are documented in the adapter headers, which is where they are maintained. `:checkhealth config` verifies the installed ones. The distribution-level list for Arch Linux is in `doc/kickstart.md`; the per-plugin notes are:

- fzf-lua needs `fzf`, `grep`, `ripgrep` and `fd`;
- LuaSnip builds `jsregexp` at install time, so a C toolchain and `make` must be on `PATH`;
- Tree-sitter needs the tree-sitter CLI;
- jdtls needs Python 3 and a JDK 21 or newer;
- Pandoc export needs `pandoc-cli` and `zathura`;
- formatters and linters are external and are installed globally or through Mason;
- img-clip needs a clipboard utility such as `wl-clipboard` or `xclip`.

## Files

- [`lua/config/pack.lua`](../lua/config/pack.lua) — declarations and build hooks
- [`lua/plugins/init.lua`](../lua/plugins/init.lua) — adapter load order
- [`lua/plugins/`](../lua/plugins/) — one adapter per plugin suite
- [`lua/lib/lazy.lua`](../lua/lib/lazy.lua) — the lazy loader
- [`nvim-pack-lock.json`](../nvim-pack-lock.json) — the generated revision lock

## See also

- [kickstart](./kickstart.md)
- [config](./config.md)
- [language](./language.md)
- [development](./development.md)
- [troubleshooting](./troubleshooting.md)
