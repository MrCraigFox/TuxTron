#!/bin/bash


#VARIABLES FROM SHELL/COMPARASON FOR CHECKS
ISUBUNTU="$(lsb_release -si)"
ISUBUNTUOUTPUT="Ubuntu"
FWOUTPUT="$(ufw status)"
FWINACTIVE="Status: inactive"
ISSELINUXINSTALLED="$(which selinux)"
ISLYNISINSTALLED="$(which lynis)"
ISCLAMAVINSTALLED="$(which clamscan)"
NMAPINSTALLED="$(which nmap)"
GETWANIP="$(dig +short myip.opendns.com @resolver1.opendns.com)"



#SHOW BANNER
printf "
 _____        _____               
|_   _|      |_   _|              
  | |_   ___  _| |_ __ ___  _ __  
  | | | | \ \/ / | '__/ _ \| '_ \ 
  | | |_| |>  <| | | | (_) | | | |
  \_/\__,_/_/\_\_/_|  \___/|_| |_| 
                       V 1.0 Alpha
Coded by Craig Fox
https://www.owasp.org/index.php/User:Mr_Craig_Fox 
"

#title
mytitle="TuxTron V 1.0 Alpha, developed by Craig Fox"
echo -e '\033]2;'$mytitle'\007'


#ENSURE USER IS ROOT

echo -e "\n## Super User Check ##"
if [[ $EUID -ne 0 ]]; then
   printf "You need sudo powers to run me :P \n\n"
   echo "To prevent further issues (ie; if you request to install software/mod files etc)"
   echo "while running this script is to run: sudo -s [enter password]"
   echo "That will retain a root session then without exiting, then run me: ./TuxTron.sh"
   echo "Obvs ensure it has execute permissions!"
  
   exit 1
else echo "User has the power, all good, resuming..."
fi

#SOME MISC CHECKS ON SYSTEM
echo -e "\n## Miscellaneous Checks ##"
echo -e "TARGET MACHINE:\n$(uname -a)"
echo -e "LOCAL USERS (REVIEW THESE, SOME WILL BE MADE FROM SERVICES/APPLICATIONS!):\n$(cut -d: -f1 /etc/passwd)"




#CHECK CLAMAV IS INSTALLED AND OFFER TO DO SYSTEM WIDE SCAN
echo -e "\n## Anti Virus Check ##"
if [ "$ISCLAMAVINSTALLED" == "" ]
   then
    echo "WARNING: Clamav (anti virus) not installed"
    read -r -p "Shall I install it for you? [y/N]:" response
     if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
      then
       echo "$(apt-get install clamav -y)"
        echo -e "\n"
        read -r -p "OK, shall I perform a system wide scan and remove infected files? [y/N]:" response
            if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]] 
             then
              echo "This WILL take a while, so relax, a full anti virus scan in progress..."
              echo "$(clamscan -r --remove /)"
            fi
     fi
     
else echo "ClamAV found..."
            read -r -p "OK, shall I perform a system wide scan and remove infected files? [y/N]:" response
            if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]] 
             then
              echo "This WILL take a while, so relax, a full anti virus scan in progress..."
              echo "$(clamscan -r --remove /)"
            fi
fi


#IF ON UBUNTU, PERFORM FIREWALL CHECK
echo -e "\n## Firewall Check ##"
if [ "$ISUBUNTUOUTPUT" == "$ISUBUNTU" ] 
 then
   if [ "$FWOUTPUT" == "$FWINACTIVE" ] 
    then
      echo "WARNING: Firewall is OFF!"
         read -r -p "Shall I enable the firewall for you? [y/N]:" response
            if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]] 
             then
              echo "$(sudo ufw enable)"
              echo "OK sweet, firewall is now enabled"
            fi
   else echo "Firewall status: ON [GOOD]"
   fi
else echo "I've noticed you're not on Ubuntu, skipping automated firewall checks"
     echo "You can do this manually with: sudo iptables -L"     
fi



#GET NMAP/SCAN WAN IP
echo -e "\n## External ports Check ##"
if [ "$NMAPINSTALLED" == "" ]
   then
    echo "WARNING: nmap not installed, doing it for you..."
    echo "$(apt-get install nmap -y)"
else echo "nmap already installed"
fi
echo "Performing scan on common ports"
echo "against your WAN IP address: "$GETWANIP" this will take a while"
echo "Once done, check and analyse results."
echo -e "\n"
echo "$(nmap $GETWANIP)"



#CHECK SELINUX INSTALL
echo -e "\n## SELinux Check ##"
if [ "$ISSELINUXINSTALLED" == "" ]
   then
    echo "WARNING: SELinux not installed, while this may be intentional or not valid for your setup"
    echo "please see https://en.wikipedia.org/wiki/Security-Enhanced_Linux for more info."
else echo "SELinux is installed [GOOD]"
fi


#CHECK LYNIS
echo -e "\n## Lynis Check: https://cisofy.com/documentation/lynis/ ##"
if [ "$ISLYNISINSTALLED" == "" ]
   then
    echo "WARNING: Lynis not installed, getting stable software repos version..."
    echo "$(apt-get install lynis -y)"
else echo "Lynus is installed [GOOD], performing audit, this may take a minute..."
fi

echo "$(lynis audit system --quick --auditor 'TuxTron' --pentest)"

#PERFORM UPDATE/UPGRADE/AUTOREMOVE
echo -e "\n## Update/Upgrade/Autoremove check ##\nWait a minute..."
echo "$(apt-get update -y && apt-get upgrade -y && apt-get autoremove -y)"

echo -e "\n## FINISHED ##"