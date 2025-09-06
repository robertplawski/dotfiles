# Added by Toolbox App
export PATH="$PATH:/home/robert/.local/share/JetBrains/Toolbox/scripts"

export PATH=/usr/local/cuda-12.6/bin${PATH:+:${PATH}}
. "$HOME/.cargo/env"
if [ -d "$HOME/.local/bin" ]; then
  PATH="$HOME/.local/bin:$PATH"
fi

if [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then
  exec Hyprland >"$HOME/.local/share/session-logs/hyprland-$TIMESTAMP.log" 2>&1
fi

if [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty2 ]]; then
  exec "/home/robert/scripts/kiosk.sh" >"$HOME/.local/share/session-logs/kiosk-$TIMESTAMP.log" 2>&1
fi
