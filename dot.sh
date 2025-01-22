declare -A osInfo;
osInfo[/etc/redhat-release]=yum
osInfo[/etc/arch-release]=pacman
osInfo[/etc/debian_version]=apt-get

echo "https://robertplawski.pl/dot.sh"
echo "By Robert Plawski 2025"
echo ""

dependencies="qtile picom rofi firefox git alacritty nvim"

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
	echo Downloading configuration
	git clone https://github.com/robertplawski/dotfiles.git
	echo Applying config!
	cd dotfiles
	cp ./* -r ~/.config
	echo Done! Enjoy your new configured system
	
    fi
done

