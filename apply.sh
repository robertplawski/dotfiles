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
cp ".zshrc" "$HOME"
cp ".profile" "$HOME"

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
