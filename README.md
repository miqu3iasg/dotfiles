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

## Install dependencies (optional)

This repo tracks **configuration**, not the tools that configuration depends on. Neovim, kitty, tmux, ripgrep, LaTeX, and so on still need to exist on the machine for the configs to actually work.

`install.sh` (Linux/macOS) and `install.ps1` (Windows) are provided as a convenience: they detect the OS/distro and install the common dependencies used across these configs (Neovim, terminal tools, Nerd Fonts, compilers, a LaTeX environment, etc.) with a single command.

**These scripts are entirely optional.** They're just a shortcut to avoid installing everything by hand on a fresh machine — nothing in this repo requires running them. Feel free to skip them and install dependencies yourself, install only a subset, or read through the script first and cherry-pick the parts you want. They're plain, readable shell/PowerShell — no hidden magic.

```bash
# Linux / macOS
chmod +x install.sh
./install.sh
```

```powershell
# Windows (PowerShell)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\install.ps1
```

A few things worth knowing before running them:

- They detect the OS/distro automatically (Arch, CachyOS, Kali, Debian/Ubuntu, Fedora, Gentoo, Void, NixOS, macOS, Windows) and use the matching package manager, installing it first if missing (Homebrew, Scoop/winget, pacman, apt, dnf, emerge, xbps, nix-env).
- They only install dependencies — never the dotfiles themselves. Applying the actual configs is still done through chezmoi, as described below.
- A handful of packages don't have reliable names across every distro (mainly on Gentoo, Void, and NixOS); in those cases the script prints a warning telling you what to check instead of failing silently.
- Safe to re-run: package managers skip what's already installed.

If you'd rather do it manually, the script itself is the best reference for what's needed on your OS — open it and read the relevant function.

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

## Notes

- Files prefixed with `dot_` in the source directory correspond to dotfiles (e.g. `dot_bashrc` → `~/.bashrc`). This naming avoids relying on hidden-file conventions that don't translate well to Windows.
- Files prefixed with `executable_` preserve the executable permission bit when applied.
- SSH **private keys** and other secrets are intentionally excluded from this repository. Only non-sensitive configuration is tracked.
- `install.sh` / `install.ps1` install dependencies only, are entirely optional, and are meant to be read and adjusted rather than trusted blindly — see the section above.

License

This repository is licensed under the MIT License.

## Resources

- Chezmoi official documentation: [https://www.chezmoi.io/](https://www.chezmoi.io/)
- Chezmoi quick start guide: [https://www.chezmoi.io/quick-start/](https://www.chezmoi.io/quick-start/)
- Chezmoi command reference: [https://www.chezmoi.io/reference/command-overview/](https://www.chezmoi.io/reference/command-overview/)
- Chezmoi templating guide: [https://www.chezmoi.io/user-guide/templating/](https://www.chezmoi.io/user-guide/templating/)
- Chezmoi GitHub repository: [https://github.com/twpayne/chezmoi](https://github.com/twpayne/chezmoi)
- Arch Wiki dotfiles: [https://wiki.archlinux.org/title/Dotfiles](https://wiki.archlinux.org/title/Dotfiles)
- GitHub CLI documentation: [https://cli.github.com/manual/](https://cli.github.com/manual/)
- My personal nvim configuration: [https://github.com/miqu3iasg/nvim](https://github.com/miqu3iasg/nvim)
