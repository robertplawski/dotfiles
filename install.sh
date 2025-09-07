#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Helper functions
info() { echo -e "\e[34m[INFO]\e[0m $*"; }
warn() { echo -e "\e[33m[WARN]\e[0m $*"; }

# 1. System update
info "Updating system..."
sudo dnf -y update
sudo dnf -y upgrade

# 2. Enable repos (COPR and RPM Fusion)
info "Enabling COPR and RPM Fusion repositories..."
sudo dnf -y copr enable solopasha/hyprland
sudo dnf -y copr enable heus-sueh/packages

sudo dnf -y install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Optional: Terra repo
info "Adding Terra repository..."
releasever=$(rpm -E %fedora)
sudo dnf -y install --nogpgcheck --repofrompath "terra,https://repos.fyralabs.com/terra$releasever" terra-release || warn "Terra repo failed"

# 3. NVIDIA drivers
info "Installing NVIDIA drivers..."
sudo dnf -y install akmod-nvidia xorg-x11-drv-nvidia-cuda || warn "NVIDIA driver installation failed. Skipping..."

# 4. Hyprland & utilities
info "Installing Hyprland and utilities..."
sudo dnf -y install hyprland hyprpaper hyprlock hyprshot hyprpicker hyprpanel xdg-desktop-portal-hyprland lxpolkit

# 5. Multimedia apps & codecs (Feishin included)
info "Installing multimedia codecs and apps..."
sudo dnf -y install x265 x265-libs x265-devel ffmpeg mpv

info "Installing Feishin music app..."
FEISHIN_URL="https://github.com/jeffvli/feishin/releases/download/v0.18.0/Feishin-0.18.0-linux-x86_64.AppImage"
FEISHIN_DEST="$HOME/Applications/Feishin.AppImage"

mkdir -p "$HOME/Applications"
curl -L "$FEISHIN_URL" -o "$FEISHIN_DEST"
chmod +x "$FEISHIN_DEST"

mkdir -p ~/.local/share/applications
cat <<EOF >~/.local/share/applications/feishin.desktop
[Desktop Entry]
Name=Feishin
Comment=Music App
Exec=$FEISHIN_DEST
Icon=feishin
Terminal=false
Type=Application
Categories=AudioVideo;Player;
EOF

# 6. Basic applications
info "Installing basic applications..."
sudo dnf -y install alacritty firefox thunar qbittorrent pavucontrol thunderbird discord

# 7. Development tools & programming languages
info "Installing development tools..."
sudo dnf -y install \
  python3 python3-pip golang rust nodejs npm gcc gcc-c++ make cmake gdb \
  git zsh vim neovim tmux curl wget fzf ripgrep htop tree

# 8. Docker
info "Installing Docker..."
sudo dnf -y config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf -y install docker-ce docker-ce-cli containerd.io
sudo systemctl enable --now docker
sudo groupadd -f docker
sudo usermod -aG docker "$USER"

# 9. Shell environment: Oh My Zsh + Starship
info "Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  info "Oh My Zsh already installed"
fi

info "Installing Starship prompt..."
curl -sS https://starship.rs/install.sh | sh
grep -qxF 'eval "$(starship init zsh)"' ~/.zshrc || echo 'eval "$(starship init zsh)"' >>~/.zshrc

# 10. VS Code installation & extensions backup
info "Installing VS Code and backing up extensions..."
sudo dnf -y install code
[ -f ./vscode-extensions.txt ] && info "Restoring VS Code extensions..." && tr ',' '\n' <~/backup/vscode-extensions.txt | xargs -I{} sh -c 'code --install-extension "{}" || warn "Failed to install extension: {}"' || warn "VS Code extensions backup not found"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
info "Copying the configuration to .config"
cp -ri "$SCRIPT_DIR"/* "$HOME/.config/"

info "Installation complete! Please reboot when possible..."
