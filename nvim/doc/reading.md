# Reading

How to read the documentation pages of this configuration

## Synopsis

- `doc/kickstart.md` — the recommended entry point
- `doc/documentation.md` — the writing standard these pages follow
- `doc/structure.md` — where each page belongs
- `doc/reading.md` — this page

## Description

The documentation lives in `doc/`, as Markdown files. Each page opens with one first-level heading, a synopsis of the files it covers, a short description and topic sections. The pages use the formatting the standard allows: headings, tables, fenced code blocks and relative links between pages. There is no separate build step and no generated site: the files are meant to be read in any editor, and rendered by any Markdown viewer when formatting helps.

The pages are written for a reader new to the configuration, not for the author. They describe what exists, where it lives and how the pieces relate. Code comments index the files; the pages give the overview. When the two disagree, the code is right and the page is a bug.

## The pages

| Page                                    | Subject                                                      |
| --------------------------------------- | ------------------------------------------------------------ |
| [kickstart](./kickstart.md)             | The guide: startup, requirements, commands and the page map. |
| [structure](./structure.md)             | The folder tree and the layer contract.                      |
| [config](./config.md)                   | Options, autocmds, filetypes, commands and health.           |
| [plugins](./plugins.md)                 | The plugin set, adapters and lazy loading.                   |
| [language](./language.md)               | The LSP stack and every server.                              |
| [modules](./modules.md)                 | The features written for this config.                        |
| [lib](./lib.md)                         | The shared-helper layer.                                     |
| [notes](./notes.md)                     | The note vault workflow.                                     |
| [pandoc](./pandoc.md)                   | The Markdown export pipeline.                                |
| [colorschemes](./colorschemes.md)       | The themes and the color library.                            |
| [philosophy](./philosophy.md)           | Why the config builds features from scratch.                 |
| [documentation](./documentation.md)     | The documentation standard.                                  |
| [development](./development.md)         | Recipes for extending the config.                            |
| [snippets](./snippets.md)               | The snippet and file-header standard.                        |
| [troubleshooting](./troubleshooting.md) | Diagnosis order for common failures.                         |
| [reading](./reading.md)                 | This page.                                                   |

Read in this order for a first pass: `kickstart`, `structure`, `config`, `plugins`, `language`, `modules`, `lib`. The feature pages (`notes`, `pandoc`, `colorschemes`, `snippets`) can be read when the feature matters. `philosophy`, `documentation`, `development` and `troubleshooting` are reference pages.

## Reading in the editor

Open a page by name:

```vim
:e doc/kickstart.md
```

The links between pages are relative Markdown links such as `[modules](./modules.md)`. Their targets are ordinary files, so a page can be opened with `:edit` from the page's folder or through a file picker. A link that does not resolve is a documentation bug, not a special syntax.

To move between sections, search for the heading text. All headings are unique within a page and use the usual Markdown levels:

```vim
/^## The export pipeline
```

The Markdown ftplugin turns on wrapping and line break, sets the spell languages for `pt_BR` and `en_US` (spell checking itself remains off until toggled), so long paragraphs read without horizontal scrolling. It also sets `suffixesadd` to `.md`. The keymaps for the Markdown buffer are intentionally not listed here; the `desc` field of each mapping is their documentation.

For a rendered view in the browser, Markdown buffers expose `:MarkdownPreviewToggle`, provided by markdown-preview.nvim. The plugin needs a one-time install step after it is installed or updated:

```vim
:call mkdp#util#install()
```

Without that step the preview opens empty. The preview follows the buffer, so it is useful for tables and long pages; the source file remains the authority.

## Reading every page in sequence

In the shell:

```sh
for p in doc/*.md; do "$EDITOR" "$p"; done
```

Inside Neovim, one buffer per page:

```vim
:args doc/*.md
```

Then step through them with `:next` and `:previous`, or list them with `:ls`.

## Cross-references

The pages link to each other with relative paths and backtick file paths in prose:

- `[pandoc](./pandoc.md)` is a page in `doc/`;
- [`lua/modules/pandoc.lua`](../lua/modules/pandoc.lua) is a file in the repository, relative to the page.

The `## See also` section at the bottom of each page lists the nearest pages, then any `:help` tags that apply. `## Files` lists the implementation, with links relative to the page.

To check the links after an edit:

```sh
rg -n '\]\(\./' doc
rg -n 'TODO|TBD|FIXME' doc README.md
```

The first lists every page-to-page link; open each target and confirm it exists. The second finds placeholders left behind.

## Which copy to edit

There is only one copy: edit `doc/<name>.md` directly. The pages are not generated, and there is no second copy in a help database. If a page contradicts the code or another page, treat the divergence like any other bug and fix it in the same change that touches the behavior.

## Files

- [`doc/`](./) — the pages
- [`doc/documentation.md`](./documentation.md) — the writing standard
- [`doc/structure.md`](./structure.md) — the page inventory
- [`README.md`](../README.md) — the short repo overview

## See also

- [kickstart](./kickstart.md)
- [documentation](./documentation.md)
- [structure](./structure.md)
- [development](./development.md)
