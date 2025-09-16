# Added by Toolbox App
export PATH="$PATH:/home/robert/.local/share/JetBrains/Toolbox/scripts"

. "$HOME/.cargo/env"
if [ -d "$HOME/.local/bin" ]; then
  PATH="$HOME/.local/bin:$PATH"
fi

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
mkdir -p "$HOME/.local/share/session-logs"

if [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then
  exec Hyprland >"$HOME/.local/share/session-logs/hyprland-$TIMESTAMP.log" 2>&1
fi
