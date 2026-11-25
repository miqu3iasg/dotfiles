# Kickstart

Guide to this hand-rolled Neovim configuration

## Synopsis

- `doc/kickstart.md` — this page
- `README.md` — the short repo overview
- `doc/reading.md` — how to read the doc pages

## Description

A hand-rolled Neovim configuration built on the native plugin manager (`vim.pack`), the native LSP stack (`vim.lsp.config` / `vim.lsp.enable`) and a deliberately small plugin set. There is no distribution and no lazy-loading framework; the only lazy loading is a small helper in `lua/lib/lazy.lua`. Every `require` is explicit, and startup stays around 70-80 ms with the eager set.

Keymaps are deliberately not documented here. They change often, and a stale keymap list is worse than none. The live source is the matching file in `lua/config/keymaps/`, the plugin adapter, and `:map`.

The pages that go deeper:

- [structure](./structure.md) — the folders and the layer rules;
- [config](./config.md) — options, autocmds, filetypes, commands and the health check;
- [plugins](./plugins.md) — the plugin set, adapters and lazy loading;
- [language](./language.md) — the LSP stack, server by server;
- [modules](./modules.md) — the features written for this config;
- [lib](./lib.md) — the shared helpers;
- [notes](./notes.md) — the note vault workflow;
- [pandoc](./pandoc.md) — the Markdown export pipeline;
- [colorschemes](./colorschemes.md) — the themes;
- [philosophy](./philosophy.md) — why the config builds features from scratch;
- [documentation](./documentation.md) — the documentation standard;
- [development](./development.md) — how to extend the config;
- [snippets](./snippets.md) — the snippet and header standard;
- [troubleshooting](./troubleshooting.md) — diagnosing failures.

## Quick start

1. Install Neovim 0.12 or newer.
2. Clone the repo where Neovim reads its config, or point `$XDG_CONFIG_HOME` at its parent.
3. Install the base tools for your platform. On Arch Linux:

```sh
sudo pacman -S git tmux fzf ripgrep fd nodejs npm \
  clang jdk21-openjdk tree-sitter-cli make \
  pandoc-cli texlive-xetex texlive-latex texlive-latexextra \
  texlive-latexrecommended texlive-fontsrecommended texlive-langportuguese \
  zathura zathura-pdf-mupdf zathura-djvu zathura-cb imv mpv xdg-utils \
  wl-clipboard
```

4. Start Neovim. `vim.pack` installs the declared plugins on first launch; Mason is asked for the language servers after startup.
5. Run `:checkhealth config`. Fix errors before warnings.
6. If you use the note workflow, create or point at the vault: `$ARCANUM_DIR`, or `~/dev/arcanum`.
7. For the Markdown browser preview, run `:call mkdp#util#install()` once after the plugin installs or updates.

LuaSnip needs `make` and a C compiler to build `jsregexp`; jdtls needs Python 3; Tree-sitter needs the tree-sitter CLI. Formatters and linters are external and are installed through Mason or the distribution; only language servers are requested automatically at startup.

## Startup

`init.lua` only fixes the load order:

1. `vim.loader.enable()` and `vim.deprecate = function() end`.
2. `config.options`.
3. `config.keymaps`, which sets the leaders and loads the keymap modules.
4. `config.autocmds`.
5. `config.filetypes`.
6. `config.commands`.
7. `modules.statusline.setup()`.
8. `config.pack`, which declares and installs the eager plugins.
9. `plugins`, which loads each adapter inside `pcall`.

10. `modules.compile.setup()`.
11. `modules.sessions.setup()`.
12. `vim.cmd.colorscheme("plain")`.

Nothing else runs at startup. Lazy plugins attach later, when the first buffer of a declared filetype appears. The notes module is set up by the Markdown adapter, and the Pandoc commands by the Markdown ftplugin, because both are context-bound.

## Directory layout

```
init.lua               load order only
colors/                custom colorschemes, one file per scheme
after/ftplugin/        buffer-local options per filetype, applied after the runtime ftplugins
after/queries/         Tree-sitter query overrides
lua/config/            options, autocmds, filetypes, commands, health and the keymap modules
lua/plugins/           one adapter file per third-party plugin suite
lua/modules/           self-contained features; state private behind a setup() when they register anything
lua/lib/               shared helpers and domain logic; no commands, autocmds or keymaps
lua/language/          native LSP stack, one module per server under servers/, plus lint.lua
lua/snippets/          LuaSnip snippets, one file per filetype
lua/pandoc/            Pandoc defaults, metadata, profiles and Lua filters
spell/                 custom spell files
nvim-pack-lock.json    revision lock written by vim.pack
doc/                   these pages
```

The layer rule is binary: a file that exposes commands, autocmds or keymaps is a module; anything else is a lib. A layer may only require the layers below it: `init.lua`, then `config`, `plugins`, `modules`, `lib`. Nothing in `lib/` requires upwards. See [structure](./structure.md).

## Editor behavior

`lua/config/options.lua` sets the defaults, `lua/config/autocmds.lua` the global events. The decisions a reader is most likely to notice:

- the clipboard is `unnamedplus`, undo is persistent and no swap or backup files are written;
- `'list'` is off by default, but `'listchars'` is configured for when it is useful; there are no number columns by default;
- search is case-insensitive until a pattern has an uppercase letter, and `:substitute` previews inside the window;
- ripgrep is the `'grepprg'` when installed, so `:Grep` and the project substitution follow `--smart-case`;
- `'path'` is recursive;
- sessions are per directory and per tmux, restored on entry and saved on exit;
- big files disable Tree-sitter, completion, diagnostics, folds, spell and the costly display pieces;
- utility windows (help, quickfix, man, health, Fugitive, undotree) close with `q` or `<Esc>` and drop `listchars`;
- a save creates missing parent directories, strips trailing whitespace and jumps to the last cursor position when the file is opened again.

The full behavior is in [config](./config.md).

## Commands

Global commands from `lua/config/commands.lua`:

| Command               | Behavior                                                                         |
| --------------------- | -------------------------------------------------------------------------------- |
| `:Setwd`              | Change the working directory to the current file's directory.                    |
| `:Grep {args}`        | Run the grep program with raw flags and open the quickfix, e.g. `:Grep -w word`. |
| `:FormatEnable`       | Enable autoformat on save globally.                                              |
| `:FormatDisable`      | Disable autoformat on save globally.                                             |
| `:FormatToggleBuffer` | Toggle autoformat for the current buffer.                                        |
| `:PackAdd {repos}`    | Add plugins, installing missing ones.                                            |
| `:PackDel {names}`    | Delete plugins by name.                                                          |
| `:PackUpdate [names]` | Update all plugins, or the named ones.                                           |

Feature commands are documented with their feature:

- `:Compile`, `:Recompile`, `:CompileInterrupt` — [modules](./modules.md);

- `:SessionSave`, `:SessionLoad` — [modules](./modules.md);
- `:Pandoc`, `:PandocPreview` — [pandoc](./pandoc.md);
- `:Notes*` — [notes](./notes.md).

## What is inside

Editor configuration

- native options, autocmds and user commands in `lua/config/`;
- keymaps split by theme in `lua/config/keymaps/`;
- a health check for the external tools in `lua/config/health.lua`.

Plugins

- `vim.pack` declarations in `lua/config/pack.lua`, one adapter per plugin suite in `lua/plugins/`;
- Tree-sitter parsing, conform formatting, native LSP completion with LuaSnip, fzf-lua searching, Fugitive and gitsigns, canola.nvim as the explorer, Obsidian and img-clip for notes, flash, mini.ai and mini.align, tmux navigation, colorizer and sleuth;
- fzf-lua and Conjure lazy-load by filetype or on first use. The details are in [plugins](./plugins.md).

Language servers

- clangd, cssls, emmet, eslint, html, lua_ls, marksman, pyright, tailwindcss and vtsls through `vim.lsp.enable`;
- jdtls through nvim-jdtls, per buffer, outside the shared stack;
- Mason installs the servers after startup; formatting stays with conform, and Python linting with ruff through nvim-lint. See [language](./language.md).

Features written for this config

- a native statusline, per-directory sessions, an Emacs-like compile runner, a Pandoc exporter, the notes vault, window zoom, Fugitive view closing and Markdown list editing. See [modules](./modules.md).

Documents

- Markdown export to PDF, EPUB, DOCX and HTML through Pandoc, with profiles and filters. See [pandoc](./pandoc.md).

Themes

- `plain`, `alabaster`, `brightburn`, `dosx`, `elrond`, `hollow`, `insanity`, `parchment` and `solarized`. See [colorschemes](./colorschemes.md).

## Requirements

Neovim 0.12 or newer. Everything else is per feature; the header of the file that uses a tool names it, and `:checkhealth config` verifies it.

Base tools on Arch Linux are the command in QUICK START. Beyond them:

- language servers, and optionally formatters and linters, through Mason (`:MasonInstall ...`); the servers declared in the LSP stack are requested automatically after startup;
- LuaSnip: `make` and a C compiler at install time;
- jdtls: Python 3 for the Mason install, a JDK 21 or newer at run time, Maven or Gradle for the project tasks;
- Pandoc export: `pandoc-cli`, XeLaTeX with the TeX Live packages in the module header, and `zathura` for preview;
- images: `wl-clipboard` on Wayland or `xclip` on X11 for img-clip;
- the explorer viewers: `zathura`, `imv`, `mpv` and `xdg-utils`;
- Conjure: `racket`, `rlwrap`, `expect` and AUR `mit-scheme` for the Scheme REPL.

A missing formatter disables only its filetype. A missing `rg`, `git` or `node` breaks several features at once; the health check marks those as errors.

## Conventions

- Every file opens with a path comment and a short header; every exported function, table and class carries LuaLS annotations. The standard is [documentation](./documentation.md).
- A file that exposes commands, autocmds or keymaps is a module; anything else is a lib. State belongs to its owner and is reached only through its API.
- Keymaps are not listed in the docs. The `desc` field of each mapping is its documentation.
- A behavior change updates its header and the matching doc page in the same commit. Dead `See:` references are bugs.
- `nvim-pack-lock.json` is generated; update plugins through `:PackUpdate`.

## Files

- [`README.md`](../README.md) — the repo overview
- [`init.lua`](../init.lua) — the load order
- [`lua/`](../lua/) — config, plugins, modules, lib, language, snippets and pandoc
- [`after/`](../after/) — ftplugins and Tree-sitter query overrides
- [`colors/`](../colors/) — the colorschemes
- [`doc/`](./) — these pages

## See also

- [structure](./structure.md)
- [config](./config.md)
- [plugins](./plugins.md)
- [language](./language.md)
- [modules](./modules.md)
- [lib](./lib.md)
- [notes](./notes.md)
- [pandoc](./pandoc.md)
- [colorschemes](./colorschemes.md)
- [philosophy](./philosophy.md)
- [development](./development.md)
- [troubleshooting](./troubleshooting.md)
- `:help vim.pack`, `:help lsp`, `:help ftplugin`

## Authors

`miqu3iasg` and contributors. License: see [`LICENSE`](../LICENSE).
