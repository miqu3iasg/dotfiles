# Structure

The folder structure and the layer contract of this Neovim configuration

## Synopsis

- `doc/structure.md` — this page
- `doc/reading.md` — how to read the doc pages

## Description

Every kind of knowledge has exactly one home: editor behavior at startup, plugin adapters, whole features, shared helpers, language servers, snippets, filetype options and documentation each get a folder of their own. A contributor should be able to guess where a change goes from the change alone, without reading the code first.

## The tree

```
init.lua                     entry point: load order only
README.md                    repo overview
LICENSE                      license
TODO.md                      scratch backlog
nvim-pack-lock.json          revision lock written by vim.pack
.stylua.toml                 formatting rules for the config itself

colors/                      colorschemes, one file per scheme
after/
  ftplugin/                  buffer-local options per filetype
  queries/                   Tree-sitter query overrides
lua/
  config/                    editor behavior loaded at startup
    keymaps/                 one file per keymap theme
  plugins/                   one adapter per third-party plugin suite
  modules/                   whole features written for this config
  lib/                       shared helpers and domain logic
  language/                  the native LSP stack
    servers/                 one module per server
  snippets/                  LuaSnip snippets, one file per filetype
  pandoc/                    Pandoc defaults, metadata, profiles and filters
spell/                       custom spell files
doc/                         these pages
```

## Top-level folders

### `colors/`

Colorschemes load by name through `vim.cmd.colorscheme`, so they live in the conventional runtimepath folder, outside `lua/`. The scheme name is the file name, and a Lua scheme builds on `lua/lib/colors.lua`. The available schemes and the library contract are in [colorschemes](./colorschemes.md).

### `after/`

`after/` is loaded last on the runtimepath, which is exactly what filetype overrides need. `after/ftplugin/<ft>.lua` runs after Neovim's own ftplugin, so its options win. `after/queries/` overrides Tree-sitter queries the same way.

Current overrides: `asm`, `c`, `csv`, `fugitive`, `git`, `gitcommit`, `java`, `javascript`, `lua`, `markdown`, `python`, `scheme`, `sql`, `tsv`, `typescript`. The Markdown query overrides add text objects and highlights.

### `lua/config/`

Editor behavior loaded once at startup:

| File               | Owns                                                                                                                           |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------ |
| `options.lua`      | Global options and the session options contract.                                                                               |
| `autocmds.lua`     | Global autocmds, grouped per concern.                                                                                          |
| `filetypes.lua`    | Filetype detection the runtime misses.                                                                                         |
| `commands.lua`     | Global user commands.                                                                                                          |
| `health.lua`       | The `:checkhealth config` report.                                                                                              |
| `keymaps/init.lua` | The leaders and the keymap module order.                                                                                       |
| `keymaps/*.lua`    | One theme per file: windows, command mode, search, quickfix, editing, buffers, terminal, files, misc, marks, inserts and pack. |

Files here run once, in the order fixed by `init.lua`, and are not required by anything else. The details are in [config](./config.md).

### `lua/plugins/`

One adapter per plugin suite, never more. The adapter owns the plugin's setup, the globals it reads and the keymaps that only make sense inside it. A lazy plugin declares itself at the bottom of its own file through `lib.lazy`; `init.lua` in this folder is the ordered load list, and each module is loaded inside `pcall` so one failure notifies instead of aborting startup. See [plugins](./plugins.md).

### `lua/modules/`

Whole features written for this config, each with its own state and, when it registers anything, a `setup()`. The current modules are statusline, sessions, compile, pandoc, notes, window zoom, Fugitive view closing and Markdown lists. See [modules](./modules.md).

### `lua/lib/`

Everything that exists to be required by another file: buffer helpers, the big-file detector, the lazy loader, the autoformat state, export paths, color math, header machinery, search actions and OS detection. The criterion is binary: a file that registers a command, an autocmd or a keymap is a module, anything else is a lib. `lib/lazy.lua` is the single documented exception, because its one autocmd is its whole job. See [lib](./lib.md).

### `lua/language/`

The native LSP stack:

- `init.lua` — Mason, the global client configuration, module validation, `LspAttach`, diagnostics and the toggles;
- `types.lua` — the `UserLspServerModule` contract and its validator;
- `servers/<name>.lua` — one module per server, with a `config` table and an optional `on_attach`;
- `lint.lua` — external linters through nvim-lint.

It loads as a plugin module, between completion and fzf. See [language](./language.md).

### `lua/snippets/`

LuaSnip snippets, one file per filetype, loaded lazily on the first buffer of the filetype. `common.lua` holds the file headers and the filetype-adaptive helpers; the comment and header machinery lives in `lib/headers.lua`. The standard is [snippets](./snippets.md).

### `lua/pandoc/`

The export pipeline as data: `defaults.yaml` (the writer pipeline), `metadata.yaml` (default appearance), `profiles/` (per-document styles such as `abnt.yaml`) and `filters/` (wikilinks and the metadata block). `lua/modules/pandoc.lua` orchestrates them and holds no document logic. See [pandoc](./pandoc.md).

### `spell/`

Custom spell dictionaries loaded by Neovim's spelling machinery. The repository ships `en.utf-8.add` and its compiled `.spl`.

### `doc/`

These pages. The entry point is [kickstart](./kickstart.md); the reading instructions are [reading](./reading.md); the standard they follow is [documentation](./documentation.md).

The current inventory:

| Page                 | Subject                                                   |
| -------------------- | --------------------------------------------------------- |
| `kickstart.md`       | Overview, startup, requirements and the map of the pages. |
| `structure.md`       | This page: the tree and the layer contract.               |
| `config.md`          | Options, autocmds, filetypes, commands and health.        |
| `plugins.md`         | Plugin set, adapters and lazy loading.                    |
| `language.md`        | The LSP stack and every server.                           |
| `modules.md`         | The feature layer.                                        |
| `lib.md`             | The shared-helper layer.                                  |
| `notes.md`           | The note vault workflow.                                  |
| `pandoc.md`          | The Markdown export pipeline.                             |
| `colorschemes.md`    | The themes and the color library.                         |
| `philosophy.md`      | Why the config builds features from scratch.              |
| `documentation.md`   | The documentation standard.                               |
| `development.md`     | Recipes for extending the config.                         |
| `snippets.md`        | The snippet and file-header standard.                     |
| `troubleshooting.md` | Diagnosis order for common failures.                      |
| `reading.md`         | How to read the pages.                                    |

## The lua layers

The split is a contract, not a convention:

- `config/` — editor behavior at startup. Runs once. Not required by other layers.
- `plugins/` — third-party adapters. May require `modules/` and `lib/`.
- `modules/` — features. May require `lib/` and other modules through their public API.
- `lib/` — helpers and domain logic. May require other libs. Never requires upwards, never registers global behavior, except the lazy loader's own autocmd.

A layer may only require the layers below it:

```
init.lua > config > plugins > modules > lib
```

`config/` may require `modules/` for startup features (statusline) and `lib/` for helpers, because it runs before the plugin layer and the order is explicit. The important direction is the bottom: nothing in `lib/` may reach up into a module, a plugin or a command.

The rule decides disputes. When a change wants to break it, the fix is structural: move the domain logic down into `lib/` and let the caller pass state in, or merge the two files into the lower layer. A flag is not a fix.

## Finding things

| Question                          | Answer                                                                                    |
| --------------------------------- | ----------------------------------------------------------------------------------------- |
| Where is an option set?           | `config/options.lua`, or `after/ftplugin/<ft>.lua` for a filetype.                        |
| Where is a global autocmd?        | `config/autocmds.lua`.                                                                    |
| Where is a user command?          | `config/commands.lua`, or the module that owns it.                                        |
| Where is a keymap?                | The matching file in `config/keymaps/`, or the plugin adapter when it is plugin-specific. |
| Where is a plugin configured?     | Its adapter in `plugins/`.                                                                |
| Where is a whole feature?         | The module in `modules/` named after it.                                                  |
| Where is a helper two files need? | `lib/`.                                                                                   |
| Where is a language server?       | `language/servers/<server>.lua`.                                                          |
| Where is an external linter?      | `language/lint.lua`.                                                                      |
| Where is an export path decided?  | `lib/exports.lua`.                                                                        |
| Where is a snippets file?         | `lua/snippets/<ft>.lua`.                                                                  |
| Where is a filetype override?     | `after/ftplugin/<ft>.lua`.                                                                |
| Where is the docs standard?       | `doc/documentation.md`.                                                                   |

## Adding and removing

Adding a feature is a local operation: one file, plus at most one entry elsewhere.

- Eager plugin: declare it in `config/pack.lua`, add the adapter in `plugins/`, register it in `plugins/init.lua`.
- Lazy plugin: one self-declared adapter in `plugins/`; no other entry.
- Module: one file in `modules/`, called by `init.lua` or by the file that owns the context.
- Lib: one file in `lib/`, required by its callers.
- Language server: one module in `language/servers/`, one name in the `modules` list.
- Snippet: one file in `lua/snippets/`, registered in `lua/plugins/completions.lua` when it is a new filetype.
- Colorscheme: one file in `colors/`.
- Doc page: one file in `doc/`, plus an entry in this inventory and in the kickstart map if it is a new subject.

Removal is the same list backwards. An eager plugin goes away with its adapter, its `pack.lua` entry and its `plugins/init.lua` entry; a lazy plugin vanishes with its adapter alone. A module goes away when its `setup()` call and its callers go; a lib disappears when its last require does. Dead `See:` references are part of the removal.

## Files

- [`init.lua`](../init.lua) — the load order
- [`lua/config/`](../lua/config/) — editor behavior
- [`lua/plugins/`](../lua/plugins/) — plugin adapters
- [`lua/modules/`](../lua/modules/) — features
- [`lua/lib/`](../lua/lib/) — helpers
- [`lua/language/`](../lua/language/) — the LSP stack
- [`lua/snippets/`](../lua/snippets/) — snippets
- [`lua/pandoc/`](../lua/pandoc/) — the export pipeline
- [`after/`](../after/) — filetype and query overrides

## See also

- [kickstart](./kickstart.md)
- [config](./config.md)
- [plugins](./plugins.md)
- [language](./language.md)
- [modules](./modules.md)
- [lib](./lib.md)
- [development](./development.md)
