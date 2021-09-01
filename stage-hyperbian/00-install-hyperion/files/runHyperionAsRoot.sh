#!/bin/sh

CPU_RPI=`grep -m1 -c 'BCM2708\|BCM2709\|BCM2710\|BCM2835\|BCM2836\|BCM2837\|BCM2711' /proc/cpuinfo`

if [ $CPU_RPI -ne 1 ]; then
	echo 'Script abort. We are not on an Raspberry Pi'
	exit 1
fi

systemctl is-active --quiet hyperion@root.service && echo "The Hyperion service is already running as root user. No changes are necessary." && exit 1

if [ "`id -u`" -ne 0 ]; then
	exec sudo "$0"
	exit 99
fi

prompt () {
	while true; do
		read -p "$1 " yn
		case "${yn:-Y}" in
			[Yes]* ) return 0;;
			[No]* ) return 1;;
			* ) echo "Please answer Yes or No.";;
		esac
	done
}

echo " _    _  __     __  _____    ______   _____    ____    _              _   _ "
echo "| |  | | \ \   / / |  __ \  |  ____| |  __ \  |  _ \  | |     /\     | \ | |"
echo "| |__| |  \ \_/ /  | |__) | | |__    | |__) | | |_) | | |    /  \    |  \| |"
echo "|  __  |   \   /   |  ___/  |  __|   |  _  /  |  _ <  | |   / /\ \   | . \` |"
echo "| |  | |    | |    | |      | |____  | | \ \  | |_) | | |  / ____ \  | |\  |"
echo "|_|  |_|    |_|    |_|      |______| |_|  \_\ |____/  |_| /_/    \_\ |_| \_|"
echo ""

echo "The script takes care that Hyperion is executed with root privileges. This poses a security risk!"
echo "It is recommended not to do so unless there are key reasons (e.g. WS281x usage)."

if prompt "Do you want to proceed? [Yes/No]"; then
	systemctl is-active --quiet hyperion@pi.service && echo "Disable hyperion@pi.service ..." && sudo systemctl disable hyperion@pi.service --now
	echo "Enable hyperion@root.service ..." && sudo systemctl enable --quiet hyperion@root.service --now
	echo "Correct Message of the Day ..." && sudo sed -i 's/pi.service/root.service/' /etc/update-motd.d/10-hyperbian
	echo "done"
else
	exit 99
fi