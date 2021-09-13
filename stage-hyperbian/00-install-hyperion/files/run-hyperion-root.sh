#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\e[1m'
NC='\033[0m'

printf "\n${RED}"
echo ' __          __     _____  _   _ _____ _   _  _____ '
echo ' \ \        / /\   |  __ \| \ | |_   _| \ | |/ ____|'
echo '  \ \  /\  / /  \  | |__) |  \| | | | |  \| | |  __ '
echo '   \ \/  \/ / /\ \ |  _  /| . ` | | | | . ` | | |_ |'
echo '    \  /\  / ____ \| | \ \| |\  |_| |_| |\  | |__| |'
echo '     \/  \/_/    \_\_|  \_\_| \_|_____|_| \_|\_____|'
echo '                                                    '
printf "${NC}"

printf "\nHyperion should work fine without root privileges in most installations."
printf "\nRoot/superuser privileges are only required when using hardware PWM controlled LED strips."
printf "\n"

printf "\nRunning third-party software as root is considered ${BOLD}unsafe${NC} and should not be done randomly."
printf "\nPlease consider the risks involved with running programs provided by a third part as root/superuser."
printf "\n"

printf "\nAre you ${BOLD}sure${NC} you want to execute Hyperion as root?\n"
read -p "Answer YES if you want to run as root, UNDO to drop privileges. Any other reply will cancel: " answer
case "$answer" in
	YES )
		printf "\n${BOLD}${RED}Restarting Hyperion as root${NC}"
		printf "\n"
		sudo systemctl disable --now hyperion@pi.service
		sudo systemctl enable --now hyperion@root.service
		sudo sed -i 's/pi.service/root.service/' /etc/update-motd.d/10-hyperbian
		;;
	UNDO | undo )
		printf "\n${BOLD}${GREEN}Dropping privileges for Hyperion service${NC}"
		printf "\n"
		sudo systemctl disable --now hyperion@root.service
		sudo systemctl enable --now hyperion@pi.service
		sudo sed -i 's/root.service/pi.service/' /etc/update-motd.d/10-hyperbian
		;;
	* )
		printf "\n${BOLD}Incorrect reply.${NC}"
		printf "\nCorrect answers are 'YES' or 'UNDO'."
		printf "\nAborting ..."
		;;
esac

printf "\n\n"
