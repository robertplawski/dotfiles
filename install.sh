#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Helper functions
ask() { echo -e "\e[32m[ASK]\e[0m $*"; }
info() { echo -e "\e[34m[INFO]\e[0m $*"; }
warn() { echo -e "\e[33m[WARN]\e[0m $*"; }

# 1. System update
ask "Do you want to update the system? (y/n)"
read -r answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
  info "Updating system..."
  sudo dnf -y update
  sudo dnf -y upgrade
else
  info "System update skipped."
fi

# 2. Enable repos (COPR and RPM Fusion)
info "Enabling COPR and RPM Fusion repositories..."
sudo dnf -y copr enable solopasha/hyprland
sudo dnf -y copr enable heus-sueh/packages

sudo dnf -y install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

ask "Do you want to install NVIDIA drivers?"
read -r answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
  info "Installing NVIDIA drivers..."
  sudo dnf -y install akmod-nvidia xorg-x11-drv-nvidia-cuda || warn "NVIDIA driver installation failed. Skipping..."
  sudo wget https://developer.download.nvidia.com/compute/cuda/repos/fedora42/x86_64/cuda-fedora42.repo -O /etc/yum.repos.d/cuda-fedora42.repo
  sudo dnf -y install cuda
  sudo dnf install -y nvidia-docker2
  sudo dnf install -y nvidia-container-toolkit

  echo 'export PATH=/usr/local/cuda/bin:$PATH' >>~/.bashrc
  echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >>~/.bashrc
  source ~/.bashrc

else
  info "Skipping nvidia drivers install"
fi

# 4. Hyprland & utilities
info "Installing Hyprland and utilities..."
sudo dnf -y install hyprland hyprpaper hyprlock hyprshot hyprpicker hyprpanel xdg-desktop-portal-hyprland cifs-utils nfs-utils lxpolkit rofi wget nwg-look

# 5. Multimedia apps & codecs (Feishin included)
info "Installing multimedia codecs and apps..."
sudo dnf -y install x265 x265-libs x265-devel ffmpeg mpv

# 6. Basic applications
info "Installing basic applications..."
sudo dnf -y install alacritty chromium thunar xarchiver thunar-archive-plugin qbittorrent blender pavucontrol audacity cheese gimp vlc krita libreoffice mpv thunderbird discord

info "Installing librewolf..."
curl -fsSL https://repo.librewolf.net/librewolf.repo | pkexec tee /etc/yum.repos.d/librewolf.repo
sudo dnf install librewolf

ask "Do you want to install flatpaks "
read -r answer

if [[ "$answer" =~ ^[Yy]$ ]]; then

  info "Installing flatpak and apps..."
  sudo dnf install flatpak
  sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  flatpak install flathub com.obsproject.Studio -y
  flatpak install flathub com.obsproject.Studio.Plugin.BackgroundRemoval -y
  flatpak install flathub dev.lizardbyte.app.Sunshine -y
  flatpak install flathub com.moonlight_stream.Moonlight -y
  flatpak install flathub io.github.streetpea.Chiaki4deck -y
  flatpak install flathub org.prismlauncher.PrismLauncher -y
  flatpak install flathub org.vinegarhq.Sober -y
  flatpak install flathub io.github.qwersyk.Newelle -y
  flatpak install flathub com.stremio.Stremio -y
  flatpak install flathub com.usebruno.Bruno -y
  flatpak install flathub com.slack.Slack -y

else
  info "Skipping flatpak installation."
fi

ask "Do you want to game on this system?"
read -r answer

if [[ "$answer" =~ ^[Yy]$ ]]; then

  sudo dnf install -y retroarch lutris wine winetricks protontricks
  sudo dnf install -y $(curl -s https://api.github.com/repos/Open-Wine-Components/umu-launcher/releases/latest | grep -oP '"browser_download_url": "\K.*umu-launcher-.*\.rpm' | head -n1)
  sudo dnf install -y $(curl -s https://api.github.com/repos/hydralauncher/hydra/releases/latest | grep -oP '"browser_download_url": "\K.*hydralauncher-.*\.rpm' | head -n1)

else
  info "Skipping game media installation"
fi
# 7. Development tools & programming languages
info "Installing development tools..."
sudo dnf -y install \
  python3 python3-pip golang rust nodejs npm gcc gcc-c++ make cmake gdb \
  git zsh vim neovim tmux curl fzf ripgrep htop tree gh yq jq

# 8. Docker
info "Installing Docker..."
sudo dnf config-manager addrepo --overwrite --from-repofile="https://download.docker.com/linux/fedora/docker-ce.repo"
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

ask "Do you want to install the Starship prompt? (y/n) "
read -r answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
  curl -sS https://starship.rs/install.sh | sh
  grep -qxF 'eval "$(starship init zsh)"' ~/.zshrc || echo 'eval "$(starship init zsh)"' >>~/.zshrc
  echo "Starship installed! Restart your terminal or run 'source ~/.zshrc'."
else
  echo "Installation cancelled."
fi

# 10. VS Code installation & extensions backup
info "Installing VS Code and backing up extensions..."
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf -y install code
[ -f ./vscode-extensions.txt ] && info "Restoring VS Code extensions..." && tr ',' '\n' <~/dotfiles/vscode-extensions.txt | xargs -I{} sh -c 'code --install-extension "{}" || warn "Failed to install extension: {}"' || warn "VS Code extensions backup not found"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash $SCRIPT_DIR/apply.sh

info "Installation complete! Please reboot when possible..."
