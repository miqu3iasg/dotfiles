# zsh

Modular zsh configuration. One file per concern; nothing lives in more than
one place.

## Layout

    zsh/
    ├── .zshenv        # the only $HOME symlink; universal env + ZDOTDIR
    ├── .zshrc         # orchestrator: fpath, autoload and the source list
    ├── .zprofile      # login shells only (pipx)
    ├── conf.d/        # one file per concern, in the source order of .zshrc
    ├── functions/     # one autoloadable file per interactive function
    ├── aliases/       # aliasrc (general) and gitrc (git)
    └── README.md

## How it loads

`.zshenv` points `ZDOTDIR` at this directory; zsh then reads `.zprofile` and
`.zshrc` from here by itself. `.zshrc` registers `functions/` on `fpath`
(lazy-loaded bodies) and sources `conf.d/*.zsh` in one explicit list -- that
list, not the file names, is the load order.

Machine-specific settings and secrets go to `~/.config/zsh/local.zsh` (not
versioned), sourced after the conf.d loop and before syntax highlighting.

## Rules worth keeping

- `.zshenv` must stay cheap: every zsh, including scripts, reads it.
- New interactive helpers become a file in `functions/` plus a `zle -N` and
  binding in `conf.d/widgets.zsh` (or `conf.d/git-widgets.zsh`).
- `zsh-syntax-highlighting` is sourced last because it wraps existing ZLE
  widgets; anything loaded after it may not be highlighted.
- Every file starts with its own path comment and a short "what/why" prose,
  cross-referenced with `See:` lines.

## Profiling

    ZSH_PROF=1 zsh -i -c exit
