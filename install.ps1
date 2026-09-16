#Requires -Version 5.1
<#
    install.ps1 - installs the dependencies used by this dotfiles config on Windows
    (for macOS/Linux use install.sh)

    Usage (running as Administrator is recommended; otherwise winget will
    prompt for elevation on some steps):
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
        .\install.ps1
#>

$ErrorActionPreference = "Stop"

function Write-Step { param([string]$msg) Write-Host "==> $msg" -ForegroundColor Cyan }
function Write-Warn { param([string]$msg) Write-Host "==> $msg" -ForegroundColor Yellow }
function Write-Err  { param([string]$msg) Write-Host "==> $msg" -ForegroundColor Red }
function Test-Cmd   { param([string]$name) return [bool](Get-Command $name -ErrorAction SilentlyContinue) }

function Install-Winget {
    param([string]$Id)
    winget install --id $Id -e --accept-source-agreements --accept-package-agreements 2>$null
}

# winget is the base package manager on modern Windows (App Installer).
if (-not (Test-Cmd "winget")) {
    Write-Warn "winget not found. It normally ships with Windows 10/11 via the"
    Write-Warn "'App Installer' package from the Microsoft Store. Install it and rerun this script:"
    Write-Warn "  https://apps.microsoft.com/detail/9nblggh4nns1"
} else {
    Write-Step "winget found."
}

# Scoop covers CLI tools that don't always have clean winget packages.
if (-not (Test-Cmd "scoop")) {
    Write-Step "Installing Scoop..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
} else {
    Write-Step "Scoop already installed."
}

Write-Step "Adding Scoop buckets..."
scoop bucket add extras 2>$null
scoop bucket add nerd-fonts 2>$null
scoop bucket add versions 2>$null
scoop bucket add java 2>$null

Write-Step "Installing Git..."
scoop install git

Write-Step "Installing core terminal tools..."
scoop install neovim ripgrep bat fd zoxide lazygit yazi wezterm fzf jq

# tmux has no native Windows support (it needs a unix-like pty), so it's
# skipped here; use it inside WSL instead.
Write-Warn "tmux has no native Windows support outside of WSL."
Write-Warn "If your config relies on tmux, run it inside WSL, or use WezTerm's native"
Write-Warn "tabs/panes as a Windows-side substitute."

Write-Step "Installing compilers and build toolchain (GCC, Clang/LLVM, make, cmake)..."
scoop install gcc llvm make cmake

Write-Step "Installing security / networking tools..."
scoop install nmap
Install-Winget -Id "GnuPG.GnuPG"

Write-Step "Installing MIT Scheme..."
Install-Winget -Id "GNU.MIT-Scheme"
if (-not (Test-Cmd "mit-scheme")) {
    Write-Warn "mit-scheme was not found after install. Download it manually from:"
    Write-Warn "  https://www.gnu.org/software/mit-scheme/#Download"
}

Write-Warn "unbuffer (from the 'expect' package) has no stable native Windows port."
Write-Warn "Use it inside WSL, or install it via MSYS2/Cygwin (package 'expect') if you need it outside WSL."

Write-Step "Installing language runtimes (Node.js, Python, Go, Java, Rust)..."
scoop install nodejs-lts python go rustup
rustup-init -y 2>$null
Install-Winget -Id "EclipseAdoptium.Temurin.21.JDK"
if (-not (Test-Cmd "java")) {
    Write-Warn "Could not confirm a Java install. Check available JDK packages with:"
    Write-Warn "  winget search Temurin"
}

Write-Step "Installing Nerd Fonts (JetBrainsMono, FiraCode, Hack, Meslo, CascadiaCode, Iosevka, UbuntuMono, DejaVuSansMono)..."
$fonts = @("JetBrainsMono-NF", "FiraCode-NF", "Hack-NF", "Meslo-NF", "CascadiaCode-NF", "Iosevka-NF", "UbuntuMono-NF", "DejaVuSansMono-NF")
foreach ($font in $fonts) {
    scoop install $font 2>$null
    if (-not $?) {
        Write-Warn "Could not install font package '$font' (the Scoop bucket name may have changed)."
        Write-Warn "Run 'scoop search $font' to check the current name."
    }
}

Write-Step "Installing yazi preview dependencies (image/video/archive/pdf previews)..."
scoop install ffmpeg poppler 7zip imagemagick

Write-Step "Installing LaTeX environment (MiKTeX)..."
Install-Winget -Id "MiKTeX.MiKTeX"

Write-Step "Installing PDF viewer (SumatraPDF, the Windows equivalent of Zathura)..."
Install-Winget -Id "SumatraPDF.SumatraPDF"

Write-Step "Confirming WezTerm install via winget as well (harmless if already installed via Scoop)..."
Install-Winget -Id "wez.wezterm"

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Warn "Close and reopen your terminal so PATH changes take effect."
Write-Warn "Some winget/scoop package IDs change over time; if a step fails, run 'winget search <name>'"
Write-Warn "or 'scoop search <name>' to find the current ID."
