powertop --auto-tune &
bluetoothctl power off &
cpupower frequency-set -d 400000 -u 1050000 -g powersave &
tlp start battery &
killall xfce4-power-manager &
light -S 10 &
killall picom &
