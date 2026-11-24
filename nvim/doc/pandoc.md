# Pandoc

Markdown export to PDF, EPUB, DOCX and HTML through Pandoc

## Synopsis

- `lua/modules/pandoc.lua` — the export module
- `lua/pandoc/defaults.yaml` — the conversion pipeline
- `lua/pandoc/metadata.yaml` — the default appearance
- `lua/pandoc/profiles/` — per-document metadata layers
- `lua/pandoc/filters/` — the Lua filters
- `lua/lib/exports.lua` — where the result is written
- `doc/pandoc.md` — this page

## Description

`modules/pandoc.lua` exports the current Markdown buffer by running Pandoc asynchronously, so the editor never blocks. The buffer is piped through stdin, which means unsaved changes are exported too. Success is silent: only Pandoc errors and warnings reach the user. The result is written under the project's `exports/` folder and opened in an external viewer.

The module owns the process, the output path and the preview lifecycle. The conversion itself is described by data in `lua/pandoc/`: defaults, metadata, profiles and filters. To change how every document is produced, edit those files; to change a single note, edit its front matter.

The commands are buffer-local to Markdown buffers and are created by `M.setup()` from `after/ftplugin/markdown.lua`. As the documentation standard prescribes, this page documents the commands and the behavior, not the keys that call them.

## The export pipeline

Every export builds the same command, in a fixed order. Pandoc applies options as they appear, so later options win:

1. `pandoc -o <output> -d lua/pandoc/defaults.yaml` — the pipeline itself, always loaded.
2. `-d <project>/defaults.yaml` — an optional defaults file in the note's folder or the nearest parent, found upward and stopping at `$HOME`. It is skipped when it is the global file. Relative paths inside it resolve from the note's directory, because the process runs with that directory as its working directory.
3. `--metadata-file=lua/pandoc/metadata.yaml` — the default appearance, passed as metadata rather than options.
4. `--metadata-file=lua/pandoc/profiles/<name>.yaml` — optional, when a profile is requested.
5. `--lua-filter=wikilinks.lua` then `--lua-filter=metadata-block.lua` — in that order, so links inside metadata values are already plain text when the metadata block is built.
6. `--resource-path=<note dir>:<attachments dirs>` — the note's folder and every `attachments/` folder between the note and `$HOME`.
7. `--metadata=file_name:<name>` — the note's file name, injected on the command line because the document arrives through stdin. Command-line metadata beats the note's front matter, so the real file name always wins over a stale `file_name` field.
8. A title fallback when the note has none: `--metadata=title:<base>` for EPUB, `--metadata=pagetitle:<base>` for HTML. PDF and DOCX do not need it; EPUB requires a title and HTML a page title, so the file name fills in.
9. `--embed-resources` for HTML, so images and CSS are embedded and the single file can be shared. The other formats bundle their resources on their own.

The note's YAML front matter is not passed on the command line. Pandoc reads it from the document, and it overrides any metadata file. That is the intended precedence: defaults define the pipeline, `metadata.yaml` defines the look, a profile narrows the look, and the note has the last word.

The output path comes from `lib/exports.lua`:

```
<root>/exports/<relative dir>/<name>.<ext>
```

`<root>` is `vim.g.exports_root` when set, otherwise the closest parent holding an exports marker (`.exports-root`, a version-control directory, `.obsidian`, a README, a LICENSE, a Makefile or `.editorconfig`), falling back to the note's folder. The relative directory mirrors the note's path under that root. An unnamed buffer counts as `scratch` and is written under the exports root of the current directory.

## The configuration files

`defaults.yaml`
: The conversion pipeline. Markdown input with the Obsidian extensions (`wikilinks_title_after_pipe`, `lists_without_preceding_blankline`, `autolink_bare_uris`), citations disabled, standalone output, and XeLaTeX as the PDF engine. Citations are disabled by the `-citations` extension: `@name` stays ordinary text instead of becoming a citation.

`metadata.yaml`
: The default appearance, passed as document metadata so the front matter can override it: `en-US`, the `article` class, 12 pt, 2.5 cm margins, 1.5 line spacing, first-line indent, booktabs rules and colored links. The language controls hyphenation, quotation marks and translated labels. `pt-BR` hyphenation on Arch Linux requires `texlive-langportuguese`.

`profiles/`
: A named layer loaded after `metadata.yaml`, for one export. The repository ships `abnt.yaml`, an ABNT-like layout with Times New Roman, 3 cm top and left margins, 2 cm bottom and right margins, numbered sections and justified text. The profile is metadata, not options: engine keys such as `pdf-engine` belong in defaults files. Times New Roman must exist on the system.

Appearance lives in metadata files because the note's front matter must be able to override it, and metadata files are designed to lose to the document's own metadata. The pipeline, which the note must not override, stays in defaults.

## Filters and image embeds

`wikilinks.lua`
: Replaces Obsidian wikilinks with their visible text, because a link to a note would point nowhere in the export. `[[Note|alias]]` shows the alias; a bare `[[Note#heading]]` drops the heading part, which does not exist in the document; `[[#^block]]` keeps its content. Ordinary Markdown links are untouched.

`metadata-block.lua`
: Inserts the note's reference fields as a definition list at the top of the body, below the rendered title, followed by a horizontal rule. Only fields with a non-empty value appear. The labels follow the primary language subtag of `lang` (`en` or `pt`) and fall back to English. HTTP and HTTPS values become links. The fields, in order, are `file_name`, `authors`, `description`, `date`, `project`, `repository`, `path`, `stack`, `tags`, `lang`, `exception`, `source`, `location`, `external_urls` and `related`; `stack`, `external_urls` and `related` render as bullet lists, the rest as comma-separated inline values. The block is disabled with `show-metadata: false` in the front matter. When the note has `file_name` but no `title`, the file name without its extension becomes the title.

Obsidian image embeds are rewritten by the module itself before Pandoc sees the text, because Pandoc does not parse them reliably:

- `![[img.png]]` becomes `![](img.png)`;
- `![[img.png|a caption]]` becomes a Markdown image with that caption;
- `![[img.png|300]]` and `![[img.png|300x200]]` become a width, or a width and height, in pixels;
- spaces in the path are percent-encoded.

The recognized image extensions are `png`, `jpg`, `jpeg`, `pdf` and `svg`. Any other embed, such as a note or a non-image attachment, is replaced by its alias or its path as plain text. Images resolve through the resource path built above, which is why an embed can point at a file in an `attachments/` folder several levels up.

## Preview

`:PandocPreview` builds the document and opens it, then rebuilds the same format and profile on every save of that buffer. The viewer, zathura, reloads the file by itself, so no extra command is needed. Running the command again turns the preview off for the buffer and reports it. The watcher is buffer-local; wiping the buffer removes it.

The last successful export is remembered per buffer, keyed by buffer number. The cache entry is dropped when the buffer is wiped, so a recycled buffer number cannot point at an unrelated file.

## Commands

Both commands are buffer-local and available only in Markdown buffers.

| Command                          | Behavior                                                                                                                                    |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `:Pandoc [fmt] [profile]`        | Export the buffer and open the result. `fmt` is `pdf` (default), `epub`, `docx` or `html`; `profile` is a name from `lua/pandoc/profiles/`. |
| `:PandocPreview [fmt] [profile]` | Export, open, and rebuild on every save until toggled off.                                                                                  |

The format argument becomes the output extension and selects the viewer: zathura for PDF and EPUB, `xdg-open` for DOCX and HTML. An unknown profile is rejected with an error before Pandoc runs. The arguments are completed, formats first and profiles second.

## Viewers and requirements

| Tool                                                                                                           | Purpose                                     |
| -------------------------------------------------------------------------------------------------------------- | ------------------------------------------- |
| `pandoc-cli`                                                                                                   | The converter.                              |
| `zathura`, `zathura-pdf-mupdf`                                                                                 | PDF and EPUB viewer.                        |
| `xdg-utils`                                                                                                    | Opens DOCX and HTML through the desktop.    |
| XeLaTeX                                                                                                        | The PDF engine.                             |
| `texlive-xetex`, `texlive-latex`, `texlive-latexextra`, `texlive-latexrecommended`, `texlive-fontsrecommended` | LaTeX packages the generated document uses. |
| `texlive-langportuguese`                                                                                       | Hyphenation for `pt-BR`.                    |

On Arch Linux:

```sh
sudo pacman -S pandoc-cli zathura zathura-pdf-mupdf xdg-utils
sudo pacman -S texlive-xetex texlive-latex texlive-latexextra \
  texlive-latexrecommended texlive-fontsrecommended texlive-langportuguese
```

`:checkhealth config` reports `pandoc` and `zathura` under "documents" as optional tools; missing ones only disable export and preview.

## Limits

- The title fallback for EPUB and HTML only looks at the first 300 lines of the buffer, and only inside the opening `---` block.
- The module does not validate the format argument; Pandoc decides what it can write from the output extension.
- A profile is a metadata file, so it cannot change `pdf-engine` or any other option. Use a project `defaults.yaml` for that.
- The metadata block reads the final document metadata, so a field supplied by `metadata.yaml`, such as `lang`, appears even when the note does not set it.
- Exporting from an unnamed buffer uses the current directory and the name `scratch`; there is no file name in the output metadata.

## Files

- [`lua/modules/pandoc.lua`](../lua/modules/pandoc.lua) — the export module and its requirements
- [`lua/lib/exports.lua`](../lua/lib/exports.lua) — output roots and paths
- [`lua/pandoc/defaults.yaml`](../lua/pandoc/defaults.yaml) — the pipeline
- [`lua/pandoc/metadata.yaml`](../lua/pandoc/metadata.yaml) — the default appearance
- [`lua/pandoc/profiles/`](../lua/pandoc/profiles/) — the profiles
- [`lua/pandoc/filters/`](../lua/pandoc/filters/) — the Lua filters
- [`after/ftplugin/markdown.lua`](../after/ftplugin/markdown.lua) — the Markdown buffer setup that calls the module

## See also

- [notes](./notes.md) — the vault the Markdown notes live in
- [modules](./modules.md) — the feature layer
- [lib](./lib.md) — the export path rules
- [kickstart](./kickstart.md)
- [structure](./structure.md)
- [troubleshooting](./troubleshooting.md)
- :help ftplugin
