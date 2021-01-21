#!/bin/bash 
#Author: New Wavex86 
#Date Created: Thu Jan 14 05:08:02
#A script to automate the various features in kali

#Variables
PACKAGE_CHECK="NO" 
PACKAGES=("dnsutils" "sublist3r" "figlet" "whois" "nmap" "wafwoof" "theHarvester" "traceroute" "dnstracer")
ARRAY_L=${#PACKAGES[@]}
VAR=0

##Setup the functions

#Snazzy intro
welcome-screen(){

cat lain.txt

sleep 3

for x in {1..20};
do
	figlet -c "Lets all love Lain" 
	sleep .1
done

}

#Check if root, most of these programs require root access
root-check(){

if [ $EUID -ne 0 ];
then
	echo "Not Root!, Lain requires root"
	exit 3
fi

}

#Package Install
package-install(){

echo "Checking installed packages: "
#Run through array, and remove already installed packages
while [ $VAR -lt $ARRAYSIZE  ];
do
	echo "Checking ${PACKAGES[$VAR]}"
	sleep 1
						#Redirect Standard Error to prevent errors coming on user's screen
	if [[ $(dpkg-query -s ${PACKAGES[$VAR]} 2> /dev/null ) ]];
	then
		echo "       Installed!"
	else
		echo "       Need to install"
		unset ${PACKAGES[$VAR]} #Remove installed packages from array
	fi
	
	let VAR++
done

sed -i " 7c\\PACKAGE_CHECK\=\"NO\" " lains-navi.sh #Only run the package check once

}

#Get Domain and IP 
get_domain_IP(){

echo " Example: www.DOMAIN.com"
read -p "Enter Domain name: " DOMAIN

#Make a note here to error check user input

#Get IP, this took too long
IPV4=$( ping -c 1 $DOMAIN | grep "64 bytes from " | awk '{print $5}' | cut -d":" -f1 | cut -d")" -f1 | cut -d"(" -f2 1>/dev/null ) #Check

#Write in IPv6, because not every domain supports IPv6


#Some commands need the www. dropped
DOMAIN_STRIPPED=$( echo "$DOMAIN" | cut -d "." -f 2,3 )

}




##Actual Running of the program

welcome-screen

root-check

if [ "$PACKAGE_CHECK" == "YES" ];
then
	package-install
fi

get_domain_IP

figlet -c "Starting Scan"

sleep 1

#DNS enumeration
sublist3r -d $DOMAIN_STRIPPED | tee dns-results.h

#Fingerprint, port scan, vuln assesment, and traceroute, all with nmap
nmap -A $DOMAIN_STRIPPED | tee fingerprint-ports.h

#Check firewall
wafw00f $DOMAIN | tee firewall-results.h

#Check for Load Balancing
lbd $DOMAIN | tee load-balancing.h

#Get whois DNS info 
whois $DOMAIN_STRIPPED | tee whois-records.h

#Get DNS records
dnsrecon -d $DOMAIN | tee dns-records.h

#Run the harvester on domain
theHarvester -d $DOMAIN_STRIPPED -l 100 -b google -f ${DOMAIN}-results.html

#Consolidate all results
touch ${DOMAIN}-OSINT.txt
cat *.h >> ${DOMAIN}-OSINT.txt
rm -r *.h

echo "All done!"

exit 0








exit 0 
