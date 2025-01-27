launch_if_not_running() {
    local process_name="$1"
    local command_to_run="$2"

    # Check if the process is already running
    if ! pgrep -x "$process_name" > /dev/null; then
        # If not running, execute the command
        eval "$command_to_run &> /dev/null &"
        echo "$process_name started."
    else
        echo "$process_name is already running."
    fi
}
sh /home/robert/.config/qtile/scripts/setup_xrandr.sh
feh --bg-center "/home/robert/wallpaper.jpg" &
launch_if_not_running "xfce4-power-manager" "xfce4-power-manager";
launch_if_not_running "picom" "picom";
launch_if_not_running "polkitd" "usr/bin/lxpolkit";
# launch_if_not_running "Discord" "Discord";
# launch_if_not_running "clipit" "clipit";
# launch_if_not_running "sunshine" "sunshine";
#a-applet ;
blueman-tray ;
setxkbmap -model pc104 -layout us,pl -variant ,, -option grp:alt_shift_toggle ;
