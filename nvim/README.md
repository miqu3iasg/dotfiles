# My Nvim Config

For those who are insane.

A hand-rolled Neovim configuration built on the native plugin manager (`vim.pack`), the native LSP stack (`vim.lsp.config` / `vim.lsp.enable`) and a small set of deliberately chosen plugins. There is no distribution and no lazy-loading framework; the one bit of lazy loading (heavy filetype-bound plugins) is a few lines in `lua/lib/lazy.lua`. Every module is small and every `require` is explicit, which keeps startup around 70-80 ms.

## Structure

`init.lua` only fixes the load order. Custom colorschemes live in `colors/`, and filetype-specific setup lives in `after/ftplugin/` (the Java editor options and keymaps, plus overrides for the other filetypes).

Everything else is under `lua/`, split into layers. `config/` holds the editor behavior loaded at startup: options, cross-cutting autocmds, filetype detection the runtime misses, user commands, the `vim.pack` plugin declarations with their build hooks, the `:checkhealth config` report, and the keymaps, split by theme. `plugins/` contains one adapter file per third-party plugin suite; a plugin that should load lazily per filetype declares that (source, trigger filetypes, configure hook) at the end of its own adapter file via `lib.lazy`. `modules/` contains self-contained components written for this config, such as the statusline, per-directory sessions, the scratch buffer, Fugitive view closing, window zoom and the Pandoc export. Each one owns its own state and registers its commands, autocmds or keymaps through a `setup()` when it has any. `lib/` holds everything that exists to be required by other modules: domain logic such as the exports paths, and reusable helpers such as buffers, the keymap setters (`lib/keys`), the autoformat state, the lazy loader (the only one that registers an autocmd, and it owns it as its single job) and system glue. The criterion is binary: a module that exposes commands, autocmds or keymaps goes in `modules/`, and anything else goes in `lib/`. `language/` holds the language server stack, with one module per server under `servers/`, plus the shared setup in `init.lua`, the server-module contract in `types.lua` and the external linters in `lint.lua`. LuaSnip snippets live in `lua/snippets/`, one file per filetype, loaded lazily.

A layer may only require the layers below it: `init.lua`, then `config`, `plugins`, `modules` and `lib`. Nothing in `lib/` requires upwards, so an eager plugin can be removed by deleting its file in `plugins/` and its entries in `config/pack.lua` and `plugins/init.lua`; a lazy plugin is fully self-declared in its `plugins/<name>.lua` and vanishes with that file.

## Documentation

The full documentation is in [`doc/`](./doc/). Start with [kickstart](./doc/kickstart.md), then [structure](./doc/structure.md), [config](./doc/config.md), [plugins](./doc/plugins.md), [language](./doc/language.md), [modules](./doc/modules.md) and [lib](./doc/lib.md). The feature pages cover [notes](./doc/notes.md), [pandoc](./doc/pandoc.md), [snippets](./doc/snippets.md) and [colorschemes](./doc/colorschemes.md); [development](./doc/development.md), [documentation](./doc/documentation.md) and [troubleshooting](./doc/troubleshooting.md) are reference pages. The pages follow the Markdown standard in [documentation](./doc/documentation.md) and are read as described in [reading](./doc/reading.md).

## Conventions

Every module begins with a comment containing its own path (`-- lua/<path>.lua`). That header stays a short index of the file, with its dependencies and `See:` references, and every function, exported table and class carries a LuaLS annotation block, which is the API documentation. Keymaps that only make sense for one plugin live in that plugin's file under `plugins/`, and all others live in `config/keymaps/`; comments describe behavior and never name keymaps, which change too often — the `desc` field of each mapping is its documentation. Module state belongs to its module and is reached only through its API, never written from another file, as in `modules/window_zoom.lua` and `lib/autoformat.lua`.

## Adding things

To add a plugin, declare it in `config/pack.lua` with a short description, create `plugins/<name>.lua` and register the module in `plugins/init.lua`. If the plugin is only useful for specific filetypes and its `plugin/` scripts are heavy on startup, make it lazy instead: its adapter file defines `configure` and `after` as module functions and declares itself with `require("lib.lazy").setup{ src = ..., filetypes = ..., configure = M.configure, after = M.after }` at the bottom, before `return M` — the examples are `lua/plugins/lisp.lua` for a filetype trigger and `lua/plugins/fzf.lua` for a plugin that loads on demand from its own keymaps. For snippets, create `lua/snippets/<ft>.lua` returning a table of snippets, then register the filetype and its inheritances in `lua/plugins/completions.lua`. Buffer-local filetype overrides go in `after/ftplugin/<ft>.lua`, and logic shared by two or more filetypes goes in `lib/`. New keymaps go in the matching theme file in `config/keymaps/`, following its existing `<leader>` groups.

## Requirements

Neovim 0.12 or newer. The complete Arch Linux list, including the Pandoc TeX toolchain and the viewer utilities, is in the [kickstart requirements](./doc/kickstart.md#requirements). A minimal base set:

```sh
sudo pacman -S git tmux fzf ripgrep fd nodejs npm jdk21-openjdk \
  clang make tree-sitter-cli pandoc-cli zathura zathura-pdf-mupdf
```

Per-plugin dependencies are documented in the headers of the files that use them, and `:checkhealth config` verifies the executables live. Notes:

- **fzf-lua** needs `fzf`, `grep`, `ripgrep` and `fd`. `lib/substitute.lua` also calls `rg` directly.
- **LuaSnip** builds `jsregexp` with `make` at install time, so a C toolchain must be on `PATH`.
- **jdtls** is installed through Mason and needs Python 3 for the install, plus a JDK 21 and Maven at run time. See `lua/language/servers/jdtls.lua`.
- **Pandoc** export and preview need `pandoc-cli` and `zathura`; PDF output also needs XeLaTeX and the TeX Live packages listed in the kickstart. Profiles and filters are in `lua/pandoc/`.
- **Formatters and linters** such as `prettierd`, `sql-formatter` and `ruff` are best installed globally (`npm i -g`) or through Mason. Formatting is in `lua/plugins/formatting.lua`; linting is in `lua/language/lint.lua`.
