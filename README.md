# Dotfiles

Personal configuration for Arch Linux. Each application has its own folder, named after the program it configures and containing that program's files under their real names. Files that only make sense at the top level of the repository, such as this README, the license and the link configuration `install.conf.yaml`, live outside any folder.

## How it works

The real files live in this repository. The locations where programs expect to find them are symlinks pointing back here. For example, `~/.config/nvim` points to `~/dotfiles/nvim` and `~/.gitconfig` points to `~/dotfiles/git/.gitconfig`. Editing a file through either path edits the same file, so there is no synchronization step: a change is made, committed and versioned.

The mapping between repository files and their destinations is declared in `install.conf.yaml`. Each line in the `link` section follows the format `destination: source`, with the source relative to the repository root. Some applications are linked as whole folders (nvim, tmux, i3 and others). Others have only their configuration file linked, because the program also writes state or cache into its own folder. The `scripts` folder is linked file by file into `~/.local/bin`, which keeps tools installed by pipx or uv out of the repository. Applying the links is idempotent and can be repeated at any time. A real file or folder already present at a destination is never overwritten: the process emits a warning and leaves it untouched.

Files that must exist for real, such as the Xorg configuration under `/etc`, are not symlinked. The `system` folder mirrors the layout of `/etc` and its contents are copied into place with `sudo`, because these files are read early during boot and belong to root. Files specific to a single machine, such as `fstab`, are kept in `system/reference` as documentation only and are never installed automatically.

## Repository layout

Each application has its own folder, for example `nvim`, `tmux`, `ghostty`, `kitty`, `i3`, `zsh`, `git` and `vim`. Four special folders sit alongside them:

- `scripts`: personal executables, linked into `~/.local/bin`.
- `skills`: saved skills.
- `packages`: package lists, described below.
- `system`: files that belong outside the home directory.

## Setting up a new machine

Start from a fresh Arch Linux installation with network access and a regular user. First, install the tools required to fetch and apply the rest:

```bash
sudo pacman -S --needed git base-devel python-pipx
pipx install dotbot
pipx ensurepath
```

`pipx ensurepath` adds `~/.local/bin` to the `PATH`. Open a new terminal for the change to take effect and confirm that the command is available:

```bash
command -v dotbot
```

Then clone the repository. It must live in `~/dotfiles`, because the source paths in `install.conf.yaml` are resolved relative to the repository itself.

```bash
git clone https://github.com/miqu3iasg/dotfiles ~/dotfiles
cd ~/dotfiles
```

### Installing packages

The `packages` folder holds the lists of explicitly installed packages. `pacman.txt` contains the packages from the official repositories, and `aur.txt` contains the ones from the AUR or installed by hand. Install the official ones first. The `grep` filter removes blank lines and comments, and the trailing `-` makes `pacman` read the package names from standard input:

```bash
grep -vE '^\s*(#|$)' packages/pacman.txt | sudo pacman -S --needed -
```

`yay` is itself an AUR package and has to be built manually once. `makepkg -si` builds the package and installs it, asking for the `sudo` password when needed:

```bash
git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
cd /tmp/yay-bin
makepkg -si
cd ~/dotfiles
```

With `yay` available, install the AUR list the same way:

```bash
grep -vE '^\s*(#|$)' packages/aur.txt | yay -S --needed -
```

If the repository also contains `pipx.txt`, `npm.txt` or `cargo.txt`, those files list the tools installed through each package manager, one name per line. Each one is reinstalled with a simple loop:

```bash
xargs -n1 pipx install < packages/pipx.txt
xargs -n1 npm install -g < packages/npm.txt
xargs -n1 cargo install < packages/cargo.txt
```

SDKMAN has no list. Install it from the official script, open a new terminal, and install the Java versions you need:

```bash
curl -s "https://get.sdkman.io" | bash
sdk list java
sdk install java <version-identifier>
```

### Linking the configuration

The linking step does not replace real files. A fresh installation usually ships default versions of `~/.bashrc`, `~/.bash_profile`, `~/.bash_logout` and possibly `~/.zshrc`. Before applying the configuration, move them out of the way, keeping a backup in case you want to compare later:

```bash
mkdir -p ~/default-dotfiles-backup
mv ~/.bashrc ~/.bash_profile ~/.bash_logout ~/.zshrc ~/default-dotfiles-backup/ 2>/dev/null
```

Apply the configuration:

```bash
cd ~/dotfiles
dotbot -c install.conf.yaml
```

The command prints one line per link created. A `Nonexistent target` warning means a source listed in `install.conf.yaml` is missing from the repository. A `link exists` message, or similar, means a real file is already present at the destination. In both cases, fix the cause, either by moving the existing file aside or by correcting the corresponding line, and run the command again.

Afterwards, verify the result. The first two commands list the links created in `~/.config` and `~/.local/bin`, and the third looks for broken symlinks in the home directory:

```bash
ls -l ~/.config | grep dotfiles
ls -l ~/.local/bin | grep dotfiles
find ~ -maxdepth 2 -xtype l
```

Open a new terminal so the shell configuration is loaded. If the login shell is still bash and zsh is the intended one, change it:

```bash
chsh -s /usr/bin/zsh
```

### Installing system files

The files under `system/etc` are copied into `/etc` rather than linked. The script `system/install.sh` performs the copy using `sudo`. It is deliberately not part of `install.conf.yaml`, so that it only runs when I choose to run it. Review the files first, since some contain settings tied to specific hardware such as a touchpad or keyboard layout:

```bash
find system/etc -type f
less system/install.sh
```

Then run it:

```bash
bash system/install.sh
```

Do not copy `system/reference/fstab.archlinux` onto a new machine. Partition UUIDs differ between installations, and a borrowed `fstab` can leave the system unable to boot. During the system installation, generate a fresh one with the command below and use the reference file only to check which mount options are preferred:

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

### What is not in this repository

Secrets and machine-specific data are deliberately left out and must be restored separately: SSH and GPG keys, tokens such as the GitHub CLI `hosts.yml`, browser profiles, password manager databases, shell history and application caches. The `.gitignore` is written to keep the most common of these out of the repository, but it is only a safety net. Always read the output of `git status` before committing.

## Day-to-day use

Editing an already linked file requires no extra step. Open it through either path, change it, and commit from the repository:

```bash
cd ~/dotfiles
git status
git diff
git add -A
git commit -m "Update nvim config"
git push
```

### Adding an application

Move the real configuration into a new folder in the repository, add one line to the `link` section of `install.conf.yaml`, and apply the configuration again. When moving a whole folder, do not create the destination folder beforehand: `mv` would place the source inside it and produce a doubled path such as `nvim/nvim`. Create the folder first only when moving loose files into it.

```bash
# whole folder: the destination must not exist
mv ~/.config/nvim ~/dotfiles/nvim

# loose files: create the folder first
mkdir -p ~/dotfiles/kitty
mv ~/.config/kitty/kitty.conf ~/dotfiles/kitty/
```

After adding the line to `install.conf.yaml`, apply it and confirm that the destination is now a symlink:

```bash
cd ~/dotfiles
dotbot -c install.conf.yaml
ls -l ~/.config/nvim
```

### System files

Files under `/etc` are copies, so editing them does not update the repository. After changing one, copy it back into `system/etc`, preserving its path, and commit it. The same script installs any new file added there, as long as it mirrors its path under `/etc`. The `diff` below shows whether the repository has drifted from the system:

```bash
cp /etc/X11/xorg.conf.d/<file> system/etc/X11/xorg.conf.d/
diff -r /etc/X11/xorg.conf.d system/etc/X11/xorg.conf.d
```

### Package lists

Package lists do not update themselves. Regenerate them, review the diff and commit:

```bash
pacman -Qqetn > packages/pacman.txt
pacman -Qqetm > packages/aur.txt
git diff packages/
```

Regenerating overwrites the files, so any comments written by hand are lost. To keep comments, edit the lists manually and use `comm` to find packages that are installed but missing from them:

```bash
comm -23 <(pacman -Qqetn | sort) <(grep -vE '^\s*(#|$)' packages/pacman.txt | sort)
comm -23 <(pacman -Qqetm | sort) <(grep -vE '^\s*(#|$)' packages/aur.txt | sort)
```

## Useful links

- [Dotbot](https://github.com/anishathalye/dotbot): the tool that creates the symlinks, including documentation for every directive.
- [Arch Wiki: Dotfiles](https://wiki.archlinux.org/title/Dotfiles): an overview of the different approaches to managing dotfiles.
- [dotfiles.github.io](https://dotfiles.github.io): a curated collection of dotfile managers, tutorials and other people's repositories.
- [Arch Wiki: Installation guide](https://wiki.archlinux.org/title/Installation_guide): the starting point for a fresh Arch system.
- [Arch Wiki: pacman](https://wiki.archlinux.org/title/Pacman) and [pacman tips and tricks](https://wiki.archlinux.org/title/Pacman/Tips_and_tricks): including how to list explicitly installed packages.
- [Arch Wiki: Arch User Repository](https://wiki.archlinux.org/title/Arch_User_Repository): how the AUR works and how to build packages from it.
- [yay](https://github.com/Jguer/yay): the AUR helper used here.
- [Arch Wiki: fstab](https://wiki.archlinux.org/title/Fstab): why UUIDs matter and how to generate the file safely.
- [pipx](https://pipx.pypa.io): installing Python command-line tools in isolated environments.
- [SDKMAN](https://sdkman.io): managing Java and other JVM tooling versions.
