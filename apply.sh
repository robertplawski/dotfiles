# Helper functions
info() { echo -e "\e[34m[INFO]\e[0m $*"; }
warn() { echo -e "\e[33m[WARN]\e[0m $*"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

read -p "Do you want the \"bloat\"? (y/n) " answer

if [[ "$answer" =~ ^[Yy]$ ]]; then
  # Comment out the line
  sed -i 's|^\s*#\s*source\s*=\s*~/.config/hypr/bloated.conf|source = ~/.config/hypr/bloated.conf|' $SCRIPT_DIR/hypr/hyprland.conf
else
  # Uncomment the line
  sed -i 's|^\s*source\s*=\s*~/.config/hypr/bloated.conf|# &|' $SCRIPT_DIR/hypr/hyprland.conf
fi

info "Copying the configuration to .config"
cp -r "$SCRIPT_DIR"/* "$HOME/.config/"

info "Copying zshrc config"
cp -a ".zshrc" "$HOME"
cp -a ".zprofile" "$HOME"
chsh -s $(which zsh)


info "Setting up autologin"
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d && echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin $(whoami) --noclear %I \$TERM\nType=simple" | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf > /dev/null && sudo systemctl daemon-reexec && sudo systemctl daemon-reload && sudo systemctl restart getty@tty1

info "Setting up backups"

sudo mkdir -p /backup
while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -z "$line" || "$line" =~ ^# ]] && continue # skip empty lines/comments
  if ! grep -Fxq "$line" /etc/fstab; then
    echo "Adding: $line"
    sudo bash -c "echo '$line' >> /etc/fstab"
  fi
done <"$SCRIPT_DIR/fstab"
sudo systemctl daemon-reload
sudo mount -a

crontab $SCRIPT_DIR/cron.txt
