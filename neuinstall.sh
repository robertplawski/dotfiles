#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Helper functions
info() { echo -e "\e[34m[INFO]\e[0m $*"; }
warn() { echo -e "\e[33m[WARN]\e[0m $*"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

step1() {
  info "Updating system..."
  sudo dnf -y update
  sudo dnf -y upgrade
}

step2() {
  info "Installing NVIDIA drivers and CUDA..."
  sudo dnf -y install akmod-nvidia xorg-x11-drv-nvidia-cuda || warn "NVIDIA driver installation failed. Skipping..."
  sudo wget https://developer.download.nvidia.com/compute/cuda/repos/fedora42/x86_64/cuda-fedora42.repo -O /etc/yum.repos.d/cuda-fedora42.repo
  sudo dnf -y install cuda
  sudo dnf install -y nvidia-docker2
  sudo dnf install -y nvidia-container-toolkit

  if ! grep -q '/usr/local/cuda/bin' ~/.bashrc; then
    echo 'export PATH=/usr/local/cuda/bin:$PATH' >>~/.bashrc
  fi
  if ! grep -q '/usr/local/cuda/lib64' ~/.bashrc; then
    echo 'export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH' >>~/.bashrc
  fi
  info "CUDA environment variables appended to ~/.bashrc"
}

step3() {
  info "Enabling COPR repositories for Hyprland..."
  sudo dnf -y copr enable solopasha/hyprland
  sudo dnf -y copr enable heus-sueh/packages

  info "Installing Hyprland and utilities..."
  sudo dnf -y install hyprland hyprpaper hyprlock hyprshot hyprpicker hyprpanel xdg-desktop-portal-hyprland cifs-utils nfs-utils lxpolkit rofi wget nwg-look
}

step4() {
  info "Installing multimedia codecs and apps..."
  sudo dnf -y install x265 x265-libs x265-devel ffmpeg mpv
}

step5() {
  info "Installing basic applications..."
  sudo dnf -y install alacritty chromium thunar xarchiver thunar-archive-plugin qbittorrent blender pavucontrol audacity cheese gimp vlc krita libreoffice mpv thunderbird discord

  info "Installing Librewolf..."
  curl -fsSL https://repo.librewolf.net/librewolf.repo | pkexec tee /etc/yum.repos.d/librewolf.repo
  sudo dnf install -y librewolf
}

step6() {
  info "Installing flatpak and flatpak apps..."
  sudo dnf install -y flatpak
  sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  flatpak install -y flathub com.obsproject.Studio
  flatpak install -y flathub com.obsproject.Studio.Plugin.BackgroundRemoval
  flatpak install -y flathub dev.lizardbyte.app.Sunshine
  flatpak install -y flathub com.moonlight_stream.Moonlight
  flatpak install -y flathub io.github.streetpea.Chiaki4deck
  flatpak install -y flathub org.prismlauncher.PrismLauncher
  flatpak install -y flathub org.vinegarhq.Sober
  flatpak install -y flathub io.github.qwersyk.Newelle
  flatpak install -y flathub com.stremio.Stremio
  flatpak install -y flathub com.usebruno.Bruno
  flatpak install -y flathub com.slack.Slack
}

step7() {
  info "Installing gaming tools..."
  sudo dnf install -y retroarch lutris wine winetricks protontricks
  sudo dnf install -y "$(curl -s https://api.github.com/repos/Open-Wine-Components/umu-launcher/releases/latest | grep -oP '"browser_download_url": "\K.*umu-launcher-.*\.rpm' | head -n1)"
  sudo dnf install -y "$(curl -s https://api.github.com/repos/hydralauncher/hydra/releases/latest | grep -oP '"browser_download_url": "\K.*hydralauncher-.*\.rpm' | head -n1)"
}

step8() {
  info "Installing development tools..."
  sudo dnf -y install python3 python3-pip golang rust nodejs npm gcc gcc-c++ make cmake gdb git zsh vim neovim tmux curl fzf ripgrep htop tree gh yq jq
}

step9() {
  info "Installing Docker..."
  sudo dnf config-manager addrepo --overwrite --from-repofile="https://download.docker.com/linux/fedora/docker-ce.repo"
  sudo dnf -y install docker-ce docker-ce-cli containerd.io
  sudo systemctl enable --now docker
  sudo groupadd -f docker
  sudo usermod -aG docker "$USER"
  info "Docker installed and user added to docker group."
}

step10() {
  info "Installing Oh My Zsh..."
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    info "Oh My Zsh already installed."
  fi
  sudo dnf install -y zsh-autosuggestions zsh-syntax-highlighting

  info "Installing Starship prompt..."
  curl -sS https://starship.rs/install.sh | sh
  if ! grep -qxF 'eval "$(starship init zsh)"' ~/.zshrc; then
    echo 'eval "$(starship init zsh)"' >>~/.zshrc
  fi
  info "Starship installed! Restart your terminal or run 'source ~/.zshrc'."
}

step11() {
  info "Installing VS Code and restoring extensions..."
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
  sudo dnf -y install code

  if [ -f ./vscode-extensions.txt ]; then
    info "Restoring VS Code extensions..."
    tr ',' '\n' <~/dotfiles/vscode-extensions.txt | xargs -I{} sh -c 'code --install-extension "{}" || echo "[WARN] Failed to install extension: {}"'
  else
    warn "VS Code extensions backup not found."
  fi
}

step12() {
  info "Applying additional configuration..."
  bash "$SCRIPT_DIR/apply.sh"
}

print_menu() {
  cat <<EOF

Select a step to run or:

  u) Unattended install (choose steps to run all at once)
  q) Quit

  1) System update
  2) Install NVIDIA drivers and CUDA
  3) Enable COPR repos and install Hyprland & utilities
  4) Install multimedia codecs and apps
  5) Install basic applications and Librewolf
  6) Install flatpaks and apps
  7) Install gaming tools
  8) Install development tools
  9) Install Docker
 10) Setup Oh My Zsh and Starship prompt
 11) Install VS Code and restore extensions
 12) Apply additional configuration

EOF
}

run_steps_unattended() {
  local steps="$1"

  if [[ "$steps" == "all" ]]; then
    steps=$(seq 1 12)
  fi

  IFS=' ' read -r -a step_array <<< "$steps"

  for step_num in "${step_array[@]}"; do
    if [[ ! "$step_num" =~ ^[0-9]+$ ]] || (( step_num < 1 || step_num > 12 )); then
      warn "Skipping invalid step: $step_num"
      continue
    fi
    info "Running step $step_num unattended..."
    "step$step_num"
  done

  info "Unattended installation complete. Please reboot if needed."
}

main() {
  # Request sudo once upfront
  if ! sudo -v; then
    warn "Failed to get sudo permissions. Exiting."
    exit 1
  fi

  # Keep sudo alive in the background
  while true; do sudo -v; sleep 60; done 2>/dev/null &

  trap 'kill $!; exit' INT TERM EXIT

  while true; do
    print_menu
    read -rp "Enter choice: " choice

    case $choice in
      q|Q)
        info "Exiting installer. Please reboot if needed."
        break
        ;;
      u|U)
        read -rp "Enter the step numbers to run separated by spaces (e.g. 1 3 5), or 'all' to run all: " steps_input
        run_steps_unattended "$steps_input"
        break
        ;;
      ''|*[!0-9]*)
        warn "Invalid input. Please enter a number between 1-12, 'u' for unattended, or 'q' to quit."
        ;;
      *)
        if (( choice >= 1 && choice <= 12 )); then
          "step$choice"
          read -rp "Press Enter to return to menu..."
        else
          warn "Choice out of range. Please enter between 1-12, 'u' for unattended, or 'q' to quit."
        fi
        ;;
    esac
  done
}

main

