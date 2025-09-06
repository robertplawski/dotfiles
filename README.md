# Fedora Dev Setup Script

Automates the setup of a Fedora workstation for development, including:  

- System updates and RPM Fusion/COPR repos  
- NVIDIA drivers  
- Hyprland & Wayland utilities  
- Multimedia apps & Feishin music client  
- Basic applications (Firefox, Alacritty, Thunar, Discord, etc.)  
- Development tools & programming languages (Python, Go, Rust, Node.js, C/C++)  
- Docker setup  
- Oh My Zsh + Starship prompt  
- VS Code + automatic restoration of extensions  

---

## Installation

```bash
git clone https://github.com/robertplawski/dotfiles.git ~/dotfiles && cd ~/dotfiles && chmod +x install.sh && ./install.sh
```

## VS Code Extensions

The script automatically restores extensions from `vscode-extensions.txt` if it exists.

Create backup of extensions:

`code --list-extensions > ~/dotfiles/vscode-extensions.txt`
