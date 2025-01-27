declare -A osInfo;
osInfo[/etc/redhat-release]=yum
osInfo[/etc/arch-release]=pacman
osInfo[/etc/debian_version]=apt-get

echo "https://robertplawski.pl/dot.sh"
echo "By Robert Plawski 2025"
echo ""
#cho ${SUDO_USER:-${USER}}
dependencies="xorg lightdm lightdm-gtk-greeter qtile picom rofi firefox git alacritty nvim xrandr pamixer translate-shell xclip"

if [ $(id -u) -ne 0 ]
	then echo "Please run as root or using sudo"
	exit
fi

for f in ${!osInfo[@]}
do
    if [[ -f $f ]];then
        echo Package manager detected - ${osInfo[$f]}
	echo Installing dotfiles in 3 seconds...
	echo ""
	sleep 3
	echo Installing requested configuration
	if [[ "${osInfo[$f]}" == "yum" ]]; then
		yum install $dependencies -y
	fi
	if [[ "${osInfo[$]}" == "pacman" ]]; then
		pacman --noconfirm -S $dependencies
	fi
	if [[ "${osInfo[$]}" == "apt-get" ]]; then
		apt-get install $dependencies -y
	fi
	pip install mypy stubtest
	pip install duckduckgo-search
	echo Downloading configuration
	cd /tmp/
	git clone https://github.com/robertplawski/dotfiles.git
	cp /tmp/dotfiles/* -r /home/${SUDO_USER:-${USER}}/.config
	chown -R ${SUDO_USER:-${USER}}	/home/${SUDO_USER:-${USER}}/.config
	echo Applying configuration
	echo Done! Enjoy your new configured system
	
    fi
done

