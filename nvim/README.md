# My Nvim Config

For those who are insane.

A hand-rolled Neovim configuration built on the native plugin manager (`vim.pack`), the native LSP stack (`vim.lsp.config` / `vim.lsp.enable`) and a small set of deliberately chosen plugins. There is no distribution and no lazy-loading framework; the one bit of lazy loading (heavy filetype-bound plugins) is a few lines in `lua/lib/lazy.lua`. Every module is small and every `require` is explicit, which keeps startup around 70-80 ms.

## Structure

`init.lua` only fixes the load order. Custom colorschemes live in `colors/`, and filetype-specific setup lives in `ftplugin/` (the Java and jdtls setup) and `after/ftplugin/` (overrides for other filetypes).

Everything else is under `lua/`, split into layers. `config/` holds the editor behavior loaded at startup: options, cross-cutting autocmds, user commands, the `vim.pack` plugin declarations with their build hooks, and the keymaps, split by theme. `plugins/` contains one adapter file per third-party plugin suite; a plugin that should load lazily per filetype declares that (source, trigger filetypes, configure hook) at the end of its own adapter file via `lib.lazy`. `modules/` contains self-contained components written for this config, such as the statusline, per-directory sessions, Fugitive view closing, window zoom and the Pandoc export. Each one exposes a `setup()` and owns its own state. `lib/` holds everything that exists to be required by other modules: domain logic such as the exports paths, and reusable helpers such as buffers, the autoformat state, the lazy loader (the only one that registers an autocmd, and it owns it as its single job) and system glue. The criterion is binary: a module that exposes commands, autocmds or keymaps goes in `modules/`, and anything else goes in `lib/`. `lsp/` holds the language server stack, with one module per server under `servers/`, plus the shared setup in `init.lua` and the external linters in `lint.lua`. Snippets for LuaSnip live in `snippets/`, one file per filetype, loaded lazily.

A layer may only require the layers below it: `init.lua`, then `config`, `plugins`, `modules` and `lib`. Nothing in `lib/` requires upwards, so an eager plugin can be removed by deleting its file in `plugins/` and its entries in `config/pack.lua` and `plugins/init.lua`; a lazy plugin is fully self-declared in its `plugins/<name>.lua` and vanishes with that file.

## Conventions

Every module begins with a comment containing its own path (`-- lua/<path>.lua`). Keymaps that only make sense for one plugin live in that plugin's file under `plugins/`, and all others live in `config/keymaps/`. Module state belongs to its module and is reached only through its API, never written from another file, as in `modules/window_zoom.lua` and `lib/autoformat.lua`. Deprecated modules that stay around for possible future use live in `archived/`, outside `lua/` and off the runtimepath.

## Adding things

To add a plugin, declare it in `config/pack.lua` with a short description, create `plugins/<name>.lua` and register the module in `plugins/init.lua`. If the plugin is only useful for specific filetypes and its `plugin/` scripts are heavy on startup, make it lazy instead: its adapter file calls `require("lib.lazy").setup{ src = ..., filetypes = ..., configure = ... }` (the pattern and a ready-made example are in the `lua/lib/lazy.lua` header). For snippets, create `snippets/<ft>.lua` returning a table of snippets, then register the filetype and its inheritances in `plugins/completions.lua`. Buffer-local filetype overrides go in `after/ftplugin/<ft>.lua`, and logic shared by two or more filetypes goes in `lib/`. New keymaps go in the matching theme file in `config/keymaps/`, following its existing `<leader>` groups.

## Requirements

Neovim 0.12 or newer. On Arch Linux, the rest installs with:

```sh
sudo pacman -S git tmux fzf ripgrep fd nodejs npm jdk21-openjdk \
  clang go typst typstyle texlive-basic texlive-latex texlive-latexextra \
  texlive-binextra pandoc-cli zathura zathura-pdf-mupdf
```

Per-plugin dependencies are documented in the headers of the files that use them. Notes:

- **fzf-lua** needs `fzf`, `grep`, `ripgrep` and `fd`. `lib/substitute.lua` also calls `rg` directly.
- **LuaSnip** builds `jsregexp` with `make` at install time, so a C toolchain must be on `PATH`.
- **jdtls** is installed through Mason and needs Python 3. See `after/ftplugin/java.lua`.
- **Pandoc** export and preview need `pandoc-cli` and `zathura`. Profiles and filters are in `pandoc/`.
- **Formatters** such as `prettierd`, `sql-formatter` and `elm-format` are best installed globally (`npm i -g`) or through Mason. The full list is in `lua/plugins/formatting.lua`.
