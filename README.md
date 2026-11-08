# Dotfiles

This repository holds my personal configuration for Arch Linux. Everything is organized by application: each folder is named after the program it configures and contains that program's files under their real names, with no `dot_` prefixes, no templates and no nested `.config` hierarchy. Files that only make sense at the top level of the repository, such as this README, the license and the Dotbot configuration, live outside any folder.

## How it works

The real files live in this repository, and the places where programs expect to find them are symlinks pointing back here. For example, `~/.config/nvim` is a symlink to `~/dotfiles/nvim`, and `~/.gitconfig` is a symlink to `~/dotfiles/git/.gitconfig`. Editing a file through either path edits the same file, so there is nothing to sync: change a config, run `git commit`, and the change is versioned.

The mapping between the files in the repository and their destinations is declared in `install.conf.yaml` and applied by [Dotbot](https://github.com/anishathalye/dotbot). Each line in the `link` section reads as "destination: source", where the source is relative to the repository root. Some applications are linked as whole folders (nvim, tmux, i3, and so on), while others only have their config file linked because the application also writes state or cache into its own folder. The `scripts` folder is linked file by file into `~/.local/bin`, which keeps tools installed by pipx or uv from ending up in the repository. Dotbot is idempotent, so running it again is always safe. It never overwrites a real file, which means that if a destination already exists as a regular file or folder, it warns and leaves it alone.

Files that must exist for real, such as the Xorg configuration under `/etc`, are not symlinked. The `system` folder mirrors the layout of `/etc` and is copied into place with `sudo`, because those files are read early during boot and belong to root. A few files that are specific to one machine, like `fstab`, are kept in `system/reference` purely as documentation and are never installed automatically.

## Repository layout

Each application has its own folder, for instance `nvim`, `tmux`, `ghostty`, `kitty`, `i3`, `zsh`, `git` and `vim`. Alongside those there are a few special folders. `scripts` contains my personal executables, `skills` contains my saved Claude skills, `packages` contains the package lists described below, and `system` contains the files that belong outside the home directory.

## Setting up a new machine

Start from a fresh Arch installation with network access and a regular user. First install the tools needed to fetch and apply everything else:

```bash
sudo pacman -S --needed git base-devel python-pipx
pipx install dotbot
pipx ensurepath
```

Open a new terminal so the updated `PATH` takes effect, then clone the repository. It is expected to live in `~/dotfiles`, because the Dotbot configuration resolves sources relative to the repository itself.

```bash
git clone <your-repository-url> ~/dotfiles
cd ~/dotfiles
```

### Installing packages

The `packages` folder plays the role that a Brewfile plays on macOS. `pacman.txt` lists the packages from the official repositories that I installed explicitly, and `aur.txt` lists the ones from the AUR or installed by hand. Install the official ones first:

```bash
grep -vE '^\s*(#|$)' packages/pacman.txt | sudo pacman -S --needed -
```

The AUR helper `yay` is itself an AUR package, so it has to be built manually once:

```bash
git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
cd /tmp/yay-bin && makepkg -si
cd ~/dotfiles
```

With `yay` available, install the AUR list the same way:

```bash
grep -vE '^\s*(#|$)' packages/aur.txt | yay -S --needed -
```

If the repository also contains `pipx.txt`, `npm.txt` or `cargo.txt`, those hold the tools installed through each of those package managers and can be reinstalled with a simple loop, for example `xargs -n1 pipx install < packages/pipx.txt`. SDKMAN is not tracked by a list: install it from its website and pick the Java versions you need.

### Linking the configuration

Before running Dotbot, remember that it refuses to replace real files. A fresh installation usually has default versions of `~/.bashrc`, `~/.bash_profile`, `~/.bash_logout` and possibly `~/.zshrc`. Move them out of the way, keeping a backup in case you want to compare later:

```bash
mkdir -p ~/default-dotfiles-backup
mv ~/.bashrc ~/.bash_profile ~/.bash_logout ~/default-dotfiles-backup/ 2>/dev/null
```

Then apply the configuration:

```bash
cd ~/dotfiles
dotbot -c install.conf.yaml
```

Dotbot prints one line per link it creates. A "Nonexistent target" warning means a source listed in the configuration is missing from the repository, and a "link exists" or similar message means something real is already sitting at the destination. Fix those by moving the existing file aside and running the command again. Afterwards, check the result with `ls -l ~/.config | grep dotfiles`, and open a new terminal so the shell configuration is picked up.

### Installing system files

The files under `system/etc` are copied into `/etc` rather than linked, and a small script, `system/install.sh`, does the copying with `sudo`. It is deliberately not part of the Dotbot configuration, so that it only runs when I choose to run it. Review the files first, since they may contain settings tied to specific hardware such as a touchpad or keyboard layout, and then run:

```bash
bash system/install.sh
```

Do not copy `system/reference/fstab.archlinux` onto a new machine. Partition UUIDs differ between installations, so a borrowed `fstab` can leave the system unable to boot. Generate a fresh one with `genfstab -U /mnt >> /mnt/etc/fstab` during installation and use the reference file only to remember which mount options I prefer.

### Things that are not in this repository

Secrets and machine-specific data are deliberately left out and have to be restored separately: SSH and GPG keys, tokens such as the GitHub CLI `hosts.yml`, browser profiles, password-manager databases, shell history and application caches. The `.gitignore` is written to keep the most common of these out of the repository, but it is only a safety net, so always read `git status` before committing.

## Day-to-day use

Editing an already linked file needs no extra step. Open it from either path, change it, and commit from the repository:

```bash
cd ~/dotfiles
git status
git add -A && git commit -m "Update nvim config"
git push
```

To add a new application, move its real config into a new folder in the repository, add one line to the `link` section of `install.conf.yaml`, run `dotbot -c install.conf.yaml`, and confirm with `ls -l` that the destination is now a symlink. When moving a whole folder, do not create the destination folder beforehand, since `mv` would then place the source inside it and produce a doubled path such as `nvim/nvim`. Create a folder first only when moving loose files into it.

Files under `/etc` are copies, so editing them does not update the repository. After changing one, copy it back into `system/etc` and commit it. The same script installs any new file you add there, as long as it mirrors its path under `/etc`. `diff -r /etc/X11/xorg.conf.d system/etc/X11/xorg.conf.d` shows whether the repository has drifted from the system.

Package lists do not update themselves either. Regenerate them with `pacman -Qqetn > packages/pacman.txt` and `pacman -Qqetm > packages/aur.txt`, review the diff, and commit. Because regenerating overwrites the files, any comments written by hand are lost, so if you prefer to keep comments, edit the lists manually and use `comm` to find packages that are installed but missing from them.

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
