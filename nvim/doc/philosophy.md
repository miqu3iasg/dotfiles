# Philosophy

Why this config builds its own features from scratch, and where it stops

## Synopsis

- `doc/philosophy.md` — this page
- `doc/modules.md` — the features the philosophy produced
- `doc/plugins.md` — the third-party side of the line

## Description

This is not a distribution and not a starting point meant to grow into one. It is a personal editor shaped by one workflow, and the guiding choice is simple: when a feature is central to the workflow, build it here, from scratch, so it does exactly what the workflow needs and so every line is understood. When the work is peripheral or industrial, use a maintained plugin.

### Why build from scratch

Fit. A plugin solves its author's problem for many users; a hand-written module solves this workflow's problem. The result is smaller, and its behavior is a decision that can be pointed to instead of an option list that must be memorized. What that produced:

- A statusline as a string in the `'statusline'` option: encoding and buffer state, position, selection, search count, filetype, git branch, recording, zoom and file size, with no plugin, no redraw overhead and no update churn.
- Per-directory sessions with `:mksession`: automatic, tmux-only, one file per working directory, restored on entry and saved on exit. A session plugin would offer scopes, loaders and trees; the workflow needs "reopen this folder where I left it".
- A scratch buffer that replaces the current window's buffer and restores it on leave, because the layout must never move. Prescribed plugins float windows; this one does not.
- A compile runner that streams output into a bottom split and fills the quickfix on failure. It is `:make` with the parts of `:make` we use and none of the parts we do not.
- A lazy loader of about 150 lines in `lib/lazy.lua` instead of a plugin-loading framework: filetype triggers, configure and after hooks, one autocmd.
- A notes module that enforces the vault's own naming (`TYPE-YYYYMMDD-HHmmss-SLUG.md` and `daily-YYYYMMDD.md`) instead of hoping a plugin grows it.
- Markdown list editing, assembly alignment, Fugitive view closing and window zoom: small, sharp conveniences that no plugin did the way the workflow wanted.
- Export paths in `lib/exports.lua`, so every exporter writes to the same `<root>/exports/<reldir>/` layout.

Understanding. Every feature the config owns can be debugged, changed and deleted in an afternoon. That is worth more than a feature list: the editor stays a tool we hold, not one we rent.

Startup cost. Building lean is also building fast: no distribution, no lazy-loading framework, every require explicit. Startup stays around 70-80 ms with the eager plugin set intact, which is a constraint on every new eager dependency.

### Where the line draws

Not everything is rebuilt. The line is between editor glue and engineering the config should not own:

- no parsers: Tree-sitter is used, and parser management stays with nvim-treesitter;
- no fuzzy finders: fzf-lua wraps fzf;
- no Git: Fugitive and gitsigns are the interface;
- no formatters: conform runs external tools;
- no language servers: the native LSP stack and Mason manage them;
- no snippet engine: LuaSnip owns expansion, the config only writes snippets;
- no session plugin, note plugin, statusline plugin or completion plugin: the shape of those is the workflow itself.

The rule of thumb: use a plugin when the work is peripheral or industrial (parsers, finders, formatters, servers); write a module when the work is the shape of the workflow (sessions, scratch, compile, notes, export paths). Building something by hand is justified by fit and understanding, never by novelty, and a plugin is chosen over a module whenever the workflow genuinely benefits from a maintained tool.

The same thinking decides within a feature: conform formats, so language servers keep their formatters off; the LSP feeds diagnostics, so ruff runs beside it through nvim-lint rather than as a second server; export paths live once in `lib/exports.lua`, so every exporter writes to the same layout.

### Native over wrapped

When Neovim ships it, the config uses it: `vim.pack` over a plugin manager, `vim.lsp.config` and `vim.lsp.enable` over an LSP wrapper, native LSP completion over a completion plugin, `vim.loader` for fast startup, the built-in terminal, undotree and quickfix.

Wrappers are removed as Neovim grows, not kept out of habit. `:PackDel` and `:PackUpdate` exist as commands to bridge 0.12 to the built-ins arriving in 0.13, not as a private package manager. `nvim-lspconfig` is kept only for the frontend server configurations that the native client does not ship.

### Adapted to a workflow

The workflow assumptions are visible everywhere, and they are the point:

- tmux is the session manager, so sessions save per directory inside tmux only, and splits share navigation with tmux panes;
- a single notes vault rules note creation, naming, templates and search;
- documents are exported to `exports/` through Pandoc, in the layout `lib/exports.lua` computes;
- Linux is the host. `lib/system.lua` still reports the others, but the tooling assumes pacman, zathura and `xdg-open`;
- the note vault lives at `$ARCANUM_DIR` and is shared with a command-line companion.

When the workflow changes, the modules change with it. That is the trade this config makes on purpose, and the price is maintenance, accepted as part of the deal.

### What this philosophy asks in return

Honesty in the code and in the docs:

- every module starts with a header that says what it does and why, so the next reader can judge the choice, keep it or replace it;
- the doc pages describe the behavior that exists, not the behavior that was intended;
- a dead `See:` reference, a stale threshold or a command that moved is a bug;
- a shortcut with a known limit is marked as one and carries the condition for upgrading it.

### What this is not

This is not a beginner distribution, not a curated plugin list and not a promise of cross-platform parity. It does not try to be a framework, does not expose a large option surface, and does not hide its assumptions. The docs explain the choices; they do not sell them.

## Files

- [`doc/philosophy.md`](./philosophy.md) — this page
- [`doc/modules.md`](./modules.md) — the features built from scratch
- [`doc/plugins.md`](./plugins.md) — the plugins and why they are not modules
- [`doc/documentation.md`](./documentation.md) — the standard that keeps the reasoning readable

## See also

- [kickstart](./kickstart.md)
- [modules](./modules.md)
- [plugins](./plugins.md)
- [documentation](./documentation.md)
- [development](./development.md)
