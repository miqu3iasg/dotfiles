#!/usr/bin/env bash
#
# install.sh - installs the dependencies used by this dotfiles config
# (macOS and Linux; for Windows use install.ps1)
#
# Supported systems: macOS, Arch Linux, CachyOS, Kali Linux, Debian/Ubuntu
# and derivatives, Fedora, Gentoo, Void Linux, NixOS.
#
# Usage:
#   chmod +x install.sh
#   ./install.sh
#
set -euo pipefail

log()   { printf "\033[1;34m==>\033[0m %s\n" "$1"; }
warn()  { printf "\033[1;33m==>\033[0m %s\n" "$1"; }
error() { printf "\033[1;31m==>\033[0m %s\n" "$1" >&2; }
has()   { command -v "$1" >/dev/null 2>&1; }

# Detect OS / distro so we can pick the right package manager.
detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)
      if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
          arch|endeavouros|manjaro) echo "arch" ;;
          cachyos) echo "cachyos" ;;
          kali) echo "kali" ;;
          debian|ubuntu|pop|linuxmint|elementary|zorin) echo "debian" ;;
          fedora) echo "fedora" ;;
          gentoo) echo "gentoo" ;;
          void) echo "void" ;;
          nixos) echo "nixos" ;;
          *)
            if [[ "${ID_LIKE:-}" == *"arch"* ]]; then echo "arch"
            elif [[ "${ID_LIKE:-}" == *"debian"* ]]; then echo "debian"
            else echo "linux-unknown"
            fi
            ;;
        esac
      else
        echo "linux-unknown"
      fi
      ;;
    *) echo "unknown" ;;
  esac
}

OS="$(detect_os)"
log "Detected system: $OS"

# Fallback installers for tools that don't ship as a package on some distros.
# These download a prebuilt binary/archive straight from the project's
# GitHub releases.

install_lazygit_binary() {
  has lazygit && return 0
  log "Installing lazygit from GitHub releases..."
  local ver arch_suffix
  ver=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  case "$(uname -m)" in
    x86_64) arch_suffix="x86_64" ;;
    aarch64|arm64) arch_suffix="arm64" ;;
    *) error "Unsupported architecture for automatic lazygit install"; return 1 ;;
  esac
  curl -Lo /tmp/lazygit.tar.gz \
    "https://github.com/jesseduffield/lazygit/releases/download/v${ver}/lazygit_${ver}_Linux_${arch_suffix}.tar.gz" \
    || { warn "Could not download lazygit; install it manually."; return 1; }
  tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
  sudo install /tmp/lazygit /usr/local/bin
}

install_yazi_binary() {
  has yazi && return 0
  log "Installing yazi from GitHub releases..."
  local ver arch_suffix
  ver=$(curl -s "https://api.github.com/repos/sxyazi/yazi/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  case "$(uname -m)" in
    x86_64) arch_suffix="x86_64-unknown-linux-gnu" ;;
    aarch64|arm64) arch_suffix="aarch64-unknown-linux-gnu" ;;
    *) error "Unsupported architecture for automatic yazi install"; return 1 ;;
  esac
  curl -Lo /tmp/yazi.zip \
    "https://github.com/sxyazi/yazi/releases/download/v${ver}/yazi-${arch_suffix}.zip" \
    || { warn "Could not download yazi; install it manually."; return 1; }
  unzip -oq /tmp/yazi.zip -d /tmp/yazi
  sudo install "/tmp/yazi/yazi-${arch_suffix}/yazi" /usr/local/bin
  sudo install "/tmp/yazi/yazi-${arch_suffix}/ya" /usr/local/bin
}

# Best-effort Nerd Font install straight from the nerd-fonts GitHub releases.
# Kept as a universal fallback since exact package names for these fonts
# vary (and sometimes change) across distros and package managers.
install_nerd_fonts_manual() {
  local font_dir="$HOME/.local/share/fonts"
  mkdir -p "$font_dir"
  # A handful of the most commonly used Nerd Fonts.
  local fonts=(JetBrainsMono FiraCode Hack Meslo CascadiaCode Iosevka UbuntuMono DejaVuSansMono)
  for font in "${fonts[@]}"; do
    if find "$font_dir" -iname "*${font}*" 2>/dev/null | grep -q .; then
      continue
    fi
    log "Downloading Nerd Font: $font"
    if ! curl -fLo "/tmp/${font}.zip" \
      "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip"; then
      warn "Could not download $font (the release asset name may have changed). Skipping."
      warn "Check https://github.com/ryanoasis/nerd-fonts/releases for the current file name."
      continue
    fi
    unzip -oq "/tmp/${font}.zip" -d "$font_dir/${font}"
  done
  has fc-cache && fc-cache -f "$font_dir" >/dev/null 2>&1 || true
}

install_rust() {
  has cargo && return 0
  log "Installing Rust via rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  # shellcheck source=/dev/null
  source "$HOME/.cargo/env"
}

# macOS

install_macos() {
  if ! has brew; then
    log "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -d /opt/homebrew/bin ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi

  log "Updating Homebrew..."
  brew update

  log "Installing Git..."
  brew install git

  log "Installing core terminal tools..."
  brew install neovim ripgrep bat fd zoxide tmux lazygit yazi kitty fzf jq htop tree wget sqlite

  log "Installing compilers and build toolchain..."
  brew install gcc llvm make cmake expect

  log "Installing security / networking tools..."
  brew install nmap gnupg tcpdump whois

  log "Installing MIT Scheme..."
  brew install mit-scheme || warn "mit-scheme failed to install via brew; check manually."

  log "Installing language runtimes (Node.js, Python, Go, Java, Rust)..."
  brew install node python go openjdk
  install_rust

  log "Installing yazi preview dependencies (image/video/archive/pdf previews)..."
  brew install ffmpeg poppler unar imagemagick

  log "Installing Nerd Fonts..."
  brew tap homebrew/cask-fonts >/dev/null 2>&1 || true
  local mac_fonts=(
    font-jetbrains-mono-nerd-font
    font-fira-code-nerd-font
    font-hack-nerd-font
    font-meslo-lg-nerd-font
    font-caskaydia-cove-nerd-font
    font-iosevka-nerd-font
    font-ubuntu-mono-nerd-font
    font-dejavu-sans-mono-nerd-font
  )
  for cask in "${mac_fonts[@]}"; do
    brew install --cask "$cask" \
      || warn "Could not install $cask (cask name may have changed); run 'brew search nerd-font' to check."
  done

  log "Installing LaTeX (BasicTeX)..."
  brew install --cask basictex
  warn "BasicTeX is a minimal MacTeX. If a LaTeX package is missing, run:"
  warn "  eval \"\$(/usr/libexec/path_helper)\" && sudo tlmgr update --self && sudo tlmgr install <package>"

  log "Installing PDF viewer..."
  warn "Zathura has no stable native macOS build. Installing Skim (open-source PDF viewer) instead."
  brew install --cask skim
}

# Arch Linux

install_arch() {
  log "Updating pacman..."
  sudo pacman -Syu --needed --noconfirm

  log "Installing Git..."
  sudo pacman -S --needed --noconfirm git

  log "Installing core terminal tools..."
  sudo pacman -S --needed --noconfirm \
    neovim ripgrep bat fd zoxide tmux lazygit yazi kitty fzf jq htop tree \
    xclip wl-clipboard

  log "Installing essential Arch base utilities..."
  sudo pacman -S --needed --noconfirm \
    base-devel pacman-contrib reflector man-db man-pages less which rsync \
    openssh curl wget unzip openssl sqlite

  log "Installing Xorg / X11 utilities..."
  sudo pacman -S --needed --noconfirm \
    xorg-server xorg-xinit xorg-xset xorg-xrandr xorg-xsetroot \
    xorg-xprop xorg-xwininfo xorg-xdpyinfo xorg-xkill xorg-xmodmap xorg-xrdb \
    xdotool
  warn "This installs the common X11 CLI utilities (xset, xrandr, xsetroot, xprop, etc.)."
  warn "If you run a Wayland-only setup, xorg-server/xorg-xinit aren't required; trim as needed."

  log "Installing compilers, build toolchain and libs..."
  sudo pacman -S --needed --noconfirm \
    gcc clang make cmake expect libxcrypt-compat

  log "Installing security / networking tools..."
  sudo pacman -S --needed --noconfirm \
    nmap gnupg tcpdump whois bind

  log "Installing language runtimes (Node.js, Python, Go, Java, Rust)..."
  sudo pacman -S --needed --noconfirm nodejs npm python python-pip go jdk-openjdk rust

  log "Installing yazi preview dependencies..."
  sudo pacman -S --needed --noconfirm ffmpegthumbnailer poppler unarchiver imagemagick

  log "Installing LaTeX environment..."
  sudo pacman -S --needed --noconfirm \
    texlive-basic texlive-bin texlive-latexextra texlive-fontsextra

  log "Installing Zathura (PDF viewer)..."
  sudo pacman -S --needed --noconfirm zathura zathura-pdf-mupdf

  log "Installing Nerd Fonts..."
  local arch_fonts=(
    ttf-jetbrains-mono-nerd ttf-firacode-nerd ttf-hack-nerd ttf-meslo-nerd
    ttf-cascadia-code-nerd ttf-iosevka-nerd ttf-ubuntu-mono-nerd
  )
  for pkg in "${arch_fonts[@]}"; do
    sudo pacman -S --needed --noconfirm "$pkg" \
      || warn "Package $pkg not found (names change over time); run 'pacman -Ss nerd' to check."
  done
  install_nerd_fonts_manual

  log "Installing MIT Scheme..."
  if has yay; then
    yay -S --needed --noconfirm mit-scheme
  elif has paru; then
    paru -S --needed --noconfirm mit-scheme
  else
    warn "mit-scheme lives in the AUR. Install an AUR helper (yay/paru) and run 'yay -S mit-scheme',"
    warn "or install it manually: https://aur.archlinux.org/packages/mit-scheme"
  fi
}

# CachyOS (Arch-based, pacman-compatible; reuses the Arch install path)

install_cachyos() {
  log "CachyOS is Arch-based and pacman-compatible; reusing the Arch install steps."
  install_arch
}

# Kali Linux (Debian-based; reuses the Debian install path)

install_kali() {
  log "Kali Linux is Debian-based; reusing the Debian install steps."
  log "Kali already ships with many security tools by default; the steps below just make sure"
  log "the dotfiles-specific dependencies (nmap included) are present too."
  install_debian
}

# Debian / Ubuntu and derivatives

install_debian() {
  log "Updating apt..."
  sudo apt update

  log "Installing Git..."
  sudo apt install -y git

  log "Installing core terminal tools..."
  sudo apt install -y \
    ripgrep bat fd-find zoxide tmux kitty \
    fzf jq htop tree curl wget unzip xclip wl-clipboard fontconfig openssl sqlite3

  log "Installing compilers and build toolchain..."
  sudo apt install -y build-essential gcc clang cmake expect

  log "Installing security / networking tools..."
  sudo apt install -y nmap gnupg tcpdump whois dnsutils netcat-openbsd

  log "Installing Neovim (the apt version can be old; consider snap if so)..."
  if ! sudo apt install -y neovim; then
    warn "apt's neovim may be outdated. Consider installing via snap instead:"
    warn "  sudo snap install nvim --classic"
  fi

  # fd and bat are packaged as fdfind / batcat on Debian/Ubuntu.
  if has fdfind && ! has fd; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
  if has batcat && ! has bat; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  fi

  log "Installing language runtimes (Node.js, Python, Go, Java, Rust)..."
  sudo apt install -y nodejs npm python3 python3-pip golang-go default-jdk
  install_rust

  log "Installing yazi preview dependencies..."
  sudo apt install -y ffmpegthumbnailer poppler-utils unar imagemagick

  log "Installing LaTeX environment..."
  sudo apt install -y \
    texlive-latex-base texlive-latex-extra texlive-fonts-extra texlive-binaries

  log "Installing Zathura (PDF viewer)..."
  sudo apt install -y zathura zathura-pdf-mupdf

  log "Installing MIT Scheme..."
  sudo apt install -y mit-scheme || warn "mit-scheme not available in the repos; download from https://www.gnu.org/software/mit-scheme/"

  log "Installing lazygit and yazi (no official apt package)..."
  install_lazygit_binary
  install_yazi_binary

  log "Installing Nerd Fonts (no direct apt package, downloading manually)..."
  install_nerd_fonts_manual
}

# Fedora (bonus fallback, not explicitly requested but a reasonable default)

install_fedora() {
  log "Updating dnf..."
  sudo dnf upgrade -y

  log "Installing Git..."
  sudo dnf install -y git

  log "Installing core terminal tools..."
  sudo dnf install -y \
    neovim ripgrep bat fd-find zoxide tmux lazygit kitty \
    fzf jq htop tree xclip wl-clipboard curl wget unzip openssl sqlite

  log "Installing compilers and build toolchain..."
  sudo dnf install -y gcc gcc-c++ clang make cmake expect

  log "Installing security / networking tools..."
  sudo dnf install -y nmap gnupg2 tcpdump whois bind-utils nmap-ncat

  log "Installing language runtimes (Node.js, Python, Go, Java, Rust)..."
  sudo dnf install -y nodejs npm python3 python3-pip golang java-latest-openjdk rust cargo

  log "Installing yazi preview dependencies..."
  sudo dnf install -y ffmpegthumbnailer poppler-utils unar ImageMagick

  log "Installing LaTeX environment..."
  sudo dnf install -y texlive-scheme-basic texlive-collection-latexextra

  log "Installing Zathura (PDF viewer)..."
  sudo dnf install -y zathura zathura-pdf-mupdf

  log "Installing MIT Scheme..."
  sudo dnf install -y mit-scheme || warn "mit-scheme may not be available; check manually."

  log "Installing yazi (no official dnf package in many versions)..."
  install_yazi_binary

  log "Installing Nerd Fonts..."
  install_nerd_fonts_manual
}

# Gentoo

install_gentoo() {
  log "Syncing the Portage tree..."
  sudo emerge --sync

  log "Installing Git..."
  sudo emerge git

  log "Installing core terminal tools..."
  # emerge resolves bare package names to their category automatically
  # when unambiguous, so full atoms (category/name) aren't required here.
  sudo emerge ripgrep bat fd zoxide tmux lazygit kitty fzf jq htop tree \
    xclip wl-clipboard neovim

  log "Installing yazi (not commonly packaged in the main tree yet)..."
  install_yazi_binary

  log "Installing compilers and build toolchain..."
  # gcc and make already ship as part of Gentoo's base @system set.
  sudo emerge clang cmake expect

  log "Installing security / networking tools..."
  sudo emerge nmap gnupg tcpdump whois bind-tools \
    || warn "One of the security tool atoms may need adjusting; run 'emerge -s <name>' to find the exact atom."

  log "Installing language runtimes (Node.js, Python, Go, Java, Rust)..."
  sudo emerge nodejs python go rust
  sudo emerge openjdk \
    || warn "Java package names vary by JDK vendor/slot on Gentoo (e.g. openjdk-bin); run 'emerge -s jdk' to pick one."

  log "Installing yazi preview dependencies..."
  sudo emerge ffmpeg poppler unar imagemagick

  log "Installing LaTeX environment..."
  sudo emerge texlive
  warn "Gentoo's texlive ebuild is controlled by USE flags. If something is missing, enable the relevant"
  warn "USE flag (e.g. xetex) in /etc/portage/package.use and re-emerge."

  log "Installing Zathura (PDF viewer)..."
  sudo emerge zathura zathura-pdf-mupdf

  log "Installing Nerd Fonts (downloading manually; not consistently packaged)..."
  install_nerd_fonts_manual

  log "Installing MIT Scheme..."
  sudo emerge mit-scheme || warn "mit-scheme may not be in the main tree; check an overlay (e.g. via eix) or install manually."
}

# Void Linux

install_void() {
  log "Updating xbps and the system..."
  sudo xbps-install -Sy xbps
  sudo xbps-install -Suy

  log "Installing Git..."
  sudo xbps-install -y git

  log "Installing core terminal tools..."
  sudo xbps-install -y \
    neovim ripgrep bat fd zoxide tmux lazygit kitty fzf jq htop tree \
    xclip wl-clipboard curl wget unzip openssl sqlite

  log "Installing yazi..."
  if ! sudo xbps-install -y yazi 2>/dev/null; then
    warn "yazi package not found in the current Void repos; falling back to a prebuilt binary."
    install_yazi_binary
  fi

  log "Installing compilers and build toolchain..."
  sudo xbps-install -y base-devel gcc clang make cmake expect

  log "Installing security / networking tools..."
  sudo xbps-install -y nmap gnupg tcpdump whois

  log "Installing language runtimes (Node.js, Python, Go, Java, Rust)..."
  sudo xbps-install -y nodejs python3 python3-pip go openjdk rust

  log "Installing yazi preview dependencies..."
  sudo xbps-install -y ffmpeg poppler p7zip ImageMagick

  log "Installing LaTeX environment..."
  sudo xbps-install -y texlive
  warn "Void's texlive package scope may differ from Arch's texlive-*; check 'xbps-query -Rs texlive'"
  warn "for extra collections if something is missing."

  log "Installing Zathura (PDF viewer)..."
  sudo xbps-install -y zathura zathura-pdf-mupdf

  log "Installing Nerd Fonts (downloading manually; not consistently packaged)..."
  install_nerd_fonts_manual

  log "Installing MIT Scheme..."
  sudo xbps-install -y mit-scheme || warn "mit-scheme may not be packaged for Void; check https://www.gnu.org/software/mit-scheme/"
}

# NixOS

install_nixos() {
  warn "On NixOS the canonical way to install packages is declaratively, via /etc/nixos/configuration.nix"
  warn "followed by 'sudo nixos-rebuild switch'. This script instead does an imperative per-user install"
  warn "with nix-env for convenience; feel free to move these into configuration.nix instead."

  log "Installing Git..."
  nix-env -iA nixpkgs.git

  log "Installing core terminal tools..."
  nix-env -iA \
    nixpkgs.neovim nixpkgs.ripgrep nixpkgs.bat nixpkgs.fd nixpkgs.zoxide \
    nixpkgs.tmux nixpkgs.lazygit nixpkgs.yazi nixpkgs.kitty nixpkgs.fzf nixpkgs.jq \
    nixpkgs.htop nixpkgs.tree nixpkgs.xclip nixpkgs.wl-clipboard \
    nixpkgs.wget nixpkgs.sqlite

  log "Installing compilers and build toolchain..."
  nix-env -iA nixpkgs.gcc nixpkgs.clang nixpkgs.gnumake nixpkgs.cmake nixpkgs.expect

  log "Installing security / networking tools..."
  nix-env -iA nixpkgs.nmap nixpkgs.gnupg nixpkgs.tcpdump nixpkgs.whois nixpkgs.bind

  log "Installing language runtimes (Node.js, Python, Go, Java, Rust)..."
  nix-env -iA nixpkgs.nodejs nixpkgs.python3 nixpkgs.go nixpkgs.jdk nixpkgs.rustup

  log "Installing yazi preview dependencies..."
  nix-env -iA nixpkgs.ffmpeg nixpkgs.poppler_utils nixpkgs.unar nixpkgs.imagemagick

  log "Installing LaTeX environment..."
  nix-env -iA nixpkgs.texlive.combined.scheme-basic
  warn "nixpkgs.texlive uses 'scheme-*' bundles (basic/medium/full); switch to scheme-full for a fuller install."

  log "Installing Zathura (PDF viewer)..."
  nix-env -iA nixpkgs.zathura

  log "Installing Nerd Fonts..."
  nix-env -iA \
    nixpkgs.nerd-fonts.jetbrains-mono nixpkgs.nerd-fonts.fira-code nixpkgs.nerd-fonts.hack \
    nixpkgs.nerd-fonts.meslo-lg nixpkgs.nerd-fonts.caskaydia-cove nixpkgs.nerd-fonts.iosevka \
    nixpkgs.nerd-fonts.ubuntu-mono nixpkgs.nerd-fonts.dejavu-sans-mono \
    || install_nerd_fonts_manual
  warn "Recent nixpkgs releases split Nerd Fonts into per-font 'nerd-fonts.<name>' attributes; older"
  warn "channels may need the single 'nerdfonts' attribute instead. Run 'nix search nixpkgs nerd-fonts' to check."

  log "Installing MIT Scheme..."
  nix-env -iA nixpkgs.mit-scheme || warn "mit-scheme attribute name may differ; run 'nix search nixpkgs mit-scheme' to confirm."
}

case "$OS" in
  macos)   install_macos ;;
  arch)    install_arch ;;
  cachyos) install_cachyos ;;
  kali)    install_kali ;;
  debian)  install_debian ;;
  fedora)  install_fedora ;;
  gentoo)  install_gentoo ;;
  void)    install_void ;;
  nixos)   install_nixos ;;
  *)
    error "Could not automatically recognize this OS/distro ($OS)."
    error "Supported systems: macOS, Arch, CachyOS, Kali, Debian/Ubuntu, Fedora, Gentoo, Void, NixOS."
    error "Edit this script and add an install_<your-distro> function for your case,"
    error "or install the dependencies manually:"
    error "  git, neovim, ripgrep, bat, fd, zoxide, tmux, yazi, lazygit, kitty, fzf, jq,"
    error "  gcc, clang, make, cmake, expect (unbuffer), mit-scheme,"
    error "  node, npm, python3, go, java, rust,"
    error "  nmap, gnupg, tcpdump, whois,"
    error "  LaTeX environment, zathura, nerd fonts"
    exit 1
    ;;
esac

log "Installation complete!"
warn "Restart your terminal (or source your shell rc) so PATH changes take effect."
warn "If fonts were just installed, restart your terminal/kitty so they show up in the font list."
