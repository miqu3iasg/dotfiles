# Configuration

Editor behavior loaded at startup: options, autocmds, filetypes, commands and the health check

## Synopsis

- `init.lua` — the entry point and the load order
- `lua/config/options.lua` — global options
- `lua/config/autocmds.lua` — global autocmds
- `lua/config/filetypes.lua` — filetype detection the runtime misses
- `lua/config/commands.lua` — global user commands
- `lua/config/health.lua` — the `:checkhealth config` report
- `doc/config.md` — this page

## Description

`lua/config/` is the layer that turns Neovim into this editor. It runs once, at startup, in the order fixed by `init.lua`, and nothing else requires it. The files are not a plugin adapter and not a feature module: they set the defaults every other layer builds on.

The startup sequence is exact and worth knowing when something behaves differently than expected:

1. `vim.loader.enable()` and `vim.deprecate = function() end`, so the Lua loader caches modules and deprecation warnings stay quiet.
2. `config.options` — global options.
3. `config.keymaps` — the leaders and every keymap module, loaded in the order fixed by `lua/config/keymaps/init.lua`.
4. `config.autocmds` — global autocmds.
5. `config.filetypes` — the filetype additions.
6. `config.commands` — global user commands.
7. `modules.statusline.setup()` — the statusline, because later layers read it.
8. `config.pack` — the eager plugin declarations and the `PackChanged` build hooks.
9. `plugins` — every plugin adapter, each loaded inside `pcall` so one failure notifies instead of aborting startup.

11. `modules.compile.setup()`.
12. `modules.sessions.setup()`.
13. `vim.cmd.colorscheme("plain")` — the default colorscheme, last, so it can override highlights set by plugins.

Two features are wired outside this list. `modules.notes.setup()` is called by `lua/plugins/markdown.lua`, because the notes workflow lives with the Markdown setup. `modules.pandoc.setup()` is called by `after/ftplugin/markdown.lua`, because its commands are buffer-local. `modules.close_view.setup()` is called by `lua/plugins/git.lua`.

## Options

`lua/config/options.lua` is the single list. The groups below are the decisions a reader is most likely to be surprised by, not a copy of the file.

Editing

- `'clipboard'` is `unnamedplus`, so yanks reach the system clipboard.
- `'expandtab'` with 4 spaces is the default; `vim-sleuth` detects the style of each file.
- `'undofile'` with 10000 levels makes undo persistent, so `'swapfile'` and `'backup'` are off.
- `'foldmethod'` is `manual`, `'foldlevel'` is 99, so every fold starts open; horizontal motions do not open folds.
- `'nrformats'` drops `octal`, so `Ctrl-A` on `007` produces `008`.
- `'formatoptions'` drops `o`, so a new line does not continue a comment by default.
- `'virtualedit'` is `block`, `'jumpoptions'` is `view`, `'iskeyword'` includes `-`, and `'matchpairs'` includes `<:>`.
- `'showcmd'` is off, `'mouse'` is empty and `'history'` is 10000.

Display

- `'list'` is off, but `'listchars'` is configured (tabs, trailing spaces, spaces and non-breaking spaces) so it can be turned on per buffer or by the utility-buffer autocmd.
- No number columns by default (`'number'` and `'relativenumber'` are off); `'signcolumn'` is `no`.
- `'termguicolors'`, `'background' dark`, single window borders, block cursor everywhere and `'display'` includes `lastline`.
- `'laststatus'` is 2, `'showtabline'` is 0 and `'winborder'` is `single`.

Search and navigation

- `'ignorecase'` and `'smartcase'`: insensitive unless the pattern has an uppercase letter.
- `'inccommand'` is `nosplit`, so substitutions preview as typed.
- `'grepprg'` becomes `rg --vimgrep --smart-case` when ripgrep is installed, which is the basis of `:Grep` and the project-wide substitution.
- `'path'` includes `**`, making `:find` and `gf` recursive.
- `'switchbuf'` is `uselast`; splits go right and below.
- `'wildignorecase'`, fuzzy `'wildoptions'`, `'pum`' height 15 and `completeopt` `menuone,noselect` complete the command line and the popup behavior.

Sessions

- `'sessionoptions'` is fixed to `buffers,curdir,tabpages,winsize,help,globals,skiprtp,folds,terminal`. It must stay in sync with `lua/modules/sessions.lua`.

The file also sets `vim.g.loaded_netrw = 1`, because the explorer is canola.nvim, and `'diffopt'` with the histogram algorithm, indent heuristic and `linematch:60`.

## Autocmds

`lua/config/autocmds.lua` groups every global autocmd in a named augroup. The behavior to remember:

| Event                          | Group                      | Behavior                                                                                                                 |
| ------------------------------ | -------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `VimResized`                   | `cg/vim_resized`           | Equalizes window sizes with `wincmd =`.                                                                                  |
| `TextYankPost`                 | `cg/text_yank_post`        | Highlights the yanked region.                                                                                            |
| `CmdlineEnter` (`/`, `?`)      | `cg/search_highlight`      | Turns `'hlsearch'` on for every search.                                                                                  |
| `QuickFixCmdPost` (except `l`) | `cg/quickfix_open`         | Opens the quickfix window when the list has entries.                                                                     |
| `FileType`                     | `no_auto_comment`          | Removes the `c`, `r` and `o` continuation flags, except for Java, whose ftplugin adds them back.                         |
| `FileType`                     | `cg/bigfile`               | Turns off Tree-sitter, completion, diagnostics, folds, spell, cursorline and relative numbers on a big buffer.           |
| `VimEnter`                     | `StartupBehavior`          | With no file argument, or a single directory argument, restores the directory session (tmux only) or opens the explorer. |
| `VimLeavePre`                  | `SessionSave`              | Saves the session of the working directory, inside tmux, never blocking the quit on failure.                             |
| `BufWritePre`                  | `CreateDirs`               | Creates missing parent directories on save, skipping virtual buffers such as `oil://`.                                   |
| `BufReadPost`                  | `LastCursorPos`            | Jumps to the last cursor position, except in git commit, merge, tag and notes message buffers.                           |
| `BufWritePre`                  | `cg/whitespace`            | Strips trailing whitespace on save, skipping special and non-modifiable buffers, and restores the view.                  |
| `FileType` (utility list)      | `cg/close_utility_buffers` | Unlists help, quickfix, man, health, Fugitive, undotree and similar buffers and maps `q`/`<Esc>` to close their window.  |
| `FileType` (utility list)      | `cg/utility_nolist`        | Disables `'list'` in those buffers.                                                                                      |
| `TermOpen`                     | `cg/term_open`             | Cleans the terminal UI and enters insert mode.                                                                           |
| `FileType` `nvim-undotree`     | `cg/undotree_layout`       | Opens the undotree on the far left with 40 columns.                                                                      |

The utility filetype list is a single local table in the file. Adding a new utility window means adding its filetype there, not duplicating the close mapping.

## Filetype detection

`lua/config/filetypes.lua` adds only what Neovim's runtime misses. Today it maps `.env` and `.env.<variant>` files to `dosini`. Add an entry through `vim.filetype.add` only when the detected filetype is wrong; the runtime already covers the rest.

## User commands

`lua/config/commands.lua` registers the global commands:

| Command               | Arguments | Behavior                                                                                   |
| --------------------- | --------- | ------------------------------------------------------------------------------------------ |
| `:Setwd`              | none      | Changes the working directory to the current file's directory.                             |
| `:Grep`               | `+`       | Runs the grep program with the raw arguments and opens the quickfix, e.g. `:Grep -w word`. |
| `:FormatEnable`       | none      | Enables autoformat on save globally and clears the current buffer override.                |
| `:FormatDisable`      | none      | Disables autoformat on save globally.                                                      |
| `:FormatToggleBuffer` | none      | Toggles autoformat for the current buffer only.                                            |
| `:PackAdd`            | `+`       | Adds plugins and installs what is missing.                                                 |
| `:PackDel`            | `+`       | Deletes plugins by name.                                                                   |
| `:PackUpdate`         | `*`       | Updates every plugin, or the named ones.                                                   |

Commands owned by features are documented with the feature: `:Compile` and the session, pandoc and notes commands are in `doc/modules.md`, `doc/pandoc.md` and `doc/notes.md`.

## Health check

`lua/config/health.lua` implements `:checkhealth config`, also reachable from a bare `:checkhealth`. It reports four sections:

- base tools: `git`, `tmux`, `rg`, `fzf`, `fd`, `node`, `npm`, plus the LuaSnip build tools `make` and `cc`;
- formatters: stylua, clang-format, astyle, ruff, shfmt, yamlfmt, taplo, asmfmt, sql-formatter, prettierd, prettier, shellcheck, hadolint and markdownlint;
- documents: pandoc and zathura;
- Java: `java` and `python3`.

A missing core tool is an error; a missing per-language tool is a warning. The distinction is intentional: the editor works without a formatter, but not without `rg` when a feature calls it. `doc/troubleshooting.md` explains what to do with each failure.

## Files

- [`init.lua`](../init.lua) — the load order
- [`lua/config/options.lua`](../lua/config/options.lua) — global options
- [`lua/config/autocmds.lua`](../lua/config/autocmds.lua) — global autocmds
- [`lua/config/filetypes.lua`](../lua/config/filetypes.lua) — filetype detection
- [`lua/config/commands.lua`](../lua/config/commands.lua) — global user commands
- [`lua/config/health.lua`](../lua/config/health.lua) — the health check
- [`lua/config/keymaps/`](../lua/config/keymaps/) — the keymap modules

## See also

- [kickstart](./kickstart.md)
- [structure](./structure.md)
- [plugins](./plugins.md)
- [troubleshooting](./troubleshooting.md)
- [documentation](./documentation.md)
