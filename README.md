# A Rational Insanity

Personal configuration files, managed with [chezmoi](https://www.chezmoi.io) and synced across machines running **Linux**, **macOS**, and **Windows**.

## Contents

This repository tracks configuration for:

- Shell (`bash`, `zsh`, aliases)
- Git
- Neovim
- Window manager & bar (i3, waybar, polybar, rofi)
- Terminal (kitty, tmux)
- CLI tools (btop, htop, lazygit, yazi, zathura)
- Browser (qutebrowser)
- Miscellaneous system configs

---

## 1. Install chezmoi

Pick the command for your operating system.

**Arch Linux**

```bash
sudo pacman -S chezmoi
```

**Other Linux distros / macOS (via script)**

```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
```

**macOS (Homebrew)**

```bash
brew install chezmoi
```

**Windows (winget)**

```powershell
winget install twpayne.chezmoi
```

**Windows (Scoop)**

```powershell
scoop install chezmoi
```

---

## 2. Get all dotfiles at once (new machine)

This clones the repo and applies every tracked file to your home directory in a single step:

```bash
chezmoi init --apply https://github.com/miqu3iasg/dotfiles.git
```

To review changes **before** they touch your home directory, split it into two steps instead:

```bash
chezmoi init https://github.com/miqu3iasg/dotfiles.git
chezmoi diff      # preview what would change
chezmoi apply     # apply once you're satisfied
```

---

## 3. Get a single dotfile

If you don't want everything — just one config — you can still init the repo without applying, then apply only the file(s) you need.

```bash
# Clone the repo without touching your home directory yet
chezmoi init https://github.com/miqu3iasg/dotfiles.git

# See all files being tracked and their target paths
chezmoi managed

# Apply just one file or directory
chezmoi apply ~/.zshrc
chezmoi apply ~/.config/nvim
```

`chezmoi apply <path>` only writes the specified target — everything else stays untouched.

---

## 4. Everyday usage (on a machine that already has this repo)

| Command                   | What it does                                     |
| ------------------------- | ------------------------------------------------ |
| `chezmoi diff`            | Preview changes before applying them             |
| `chezmoi apply`           | Apply all pending changes to your home directory |
| `chezmoi add ~/.somefile` | Start tracking a new file                        |
| `chezmoi edit ~/.zshrc`   | Edit the source file (not the target)            |
| `chezmoi cd`              | Open a shell in the source directory             |
| `chezmoi update`          | Pull latest changes from GitHub and apply them   |
| `chezmoi managed`         | List every file currently tracked                |

---

## Notes

- Files prefixed with `dot_` in the source directory correspond to dotfiles (e.g. `dot_bashrc` → `~/.bashrc`). This naming avoids relying on hidden-file conventions that don't translate well to Windows.
- Files prefixed with `executable_` preserve the executable permission bit when applied.
- SSH **private keys** and other secrets are intentionally excluded from this repository. Only non-sensitive configuration is tracked.

---

## Resources

- Chezmoi official documentation: [https://www.chezmoi.io/](https://www.chezmoi.io/) 
- Chezmoi quick start guide: [https://www.chezmoi.io/quick-start/](https://www.chezmoi.io/quick-start/) 
- Chezmoi command reference: [https://www.chezmoi.io/reference/command-overview/](https://www.chezmoi.io/reference/command-overview/) 
- Chezmoi templating guide: [https://www.chezmoi.io/user-guide/templating/](https://www.chezmoi.io/user-guide/templating/) 
- Chezmoi GitHub repository: [https://github.com/twpayne/chezmoi](https://github.com/twpayne/chezmoi) 
- Arch Wiki dotfiles: [https://wiki.archlinux.org/title/Dotfiles](https://wiki.archlinux.org/title/Dotfiles) 
- GitHub CLI documentation: [https://cli.github.com/manual/](https://cli.github.com/manual/)
- My personal nvim configuration: [https://github.com/miqu3iasg/nvim](https://github.com/miqu3iasg/nvim)
