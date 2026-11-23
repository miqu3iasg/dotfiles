# Reading

How to read the doc pages of this configuration

## Description

The doc pages are plain text, in the style of a man page: the same sections and lists, with paragraphs written at full width and left to the editor's wrap. Meant to be read by simply opening the file, in any editor, with nothing rendered.

The pages, all ending in `.md`:

- kickstart.md — full guide to the config
- pandoc.md — the Pandoc export feature
- structure.md — the folder structure in depth
- modules.md — the lua/modules/ layer
- lib.md — the lua/lib/ layer
- philosophy.md — why the config builds features from scratch
- documentation.md — the documentation standard of the config
- development.md — how to extend the config
- snippets.md — the documentation snippet standard
- reading.md — this note

## Reading by opening the file

Open doc/kickstart.md and read. Paragraphs are written as full-width lines, so the editor's soft wrap decides where each line breaks; long paragraphs are meant to be seen wrapped, not scrolled sideways. The tradeoff is fixed formatting: no bold, no justification, no page header or footer - the man-page style is what you get.

To jump straight to a section, search for its heading: `/THE TREE`, `/FILES`, and so on. Headings are unique per page and appear in the order a man page uses: NAME, SYNOPSIS, DESCRIPTION, then topic sections, then FILES and SEE ALSO.

## Reading every page in sequence

In the shell:

```sh
for p in doc/*.md; do $EDITOR "$p"; done
```

Inside Neovim, one buffer per page, in sequence:

```vim
:args doc/*.md | argdo edit
```

## Which copy to edit

There is only one copy: edit `doc/<name>.md` directly. If a page contradicts the code or another page, treat the divergence like any other bug.

## Files

- `doc/<name>.md` — the pages
- `doc/documentation.md` — the documentation standard

## See also

- [kickstart](./kickstart.md)
- [documentation](./documentation.md)
