#! /bin/bash

# Colors
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[1;32m'
CYAN='\033[0;36m' 
NC='\033[0m' # No Color

#----------------------------------------------------------------

# Install bind9 dns server 
printf "${YELLOW}Installing bind9...\n"
apt update > /home/logs 2> /home/errorLogs
apt install bind9 bind9utils bind9-doc -y > /home/logs 2> /home/errorLogs
process_id=$!
wait $process_id
printf "${GREEN}DONE\n"

#----------------------------------------------------------------

# Setting network protocol to ipv4
printf "${YELLOW}Setting network protocol to ipv4...\n"
cp named /etc/default/
process_id=$!
wait $process_id
printf "${GREEN}DONE\n"

#----------------------------------------------------------------

# Restarting bind9
printf "${YELLOW}Restarting bind9...\n"
systemctl restart bind9
process_id=$!
wait $process_id
printf "${GREEN}DONE\n"

#----------------------------------------------------------------

# Setting up forwarders
printf "${YELLOW}Setting forwarders...\n"
cp named.conf.options /etc/bind/
process_id=$!
wait $process_id
printf "${GREEN}DONE\n"

#----------------------------------------------------------------

# Restarting bind9
printf "${YELLOW}Restarting bind9...\n"
systemctl restart bind9
process_id=$!
wait $process_id
printf "${GREEN}DONE\n"

#----------------------------------------------------------------

# Reading domain name from user
printf "${RED}Enter your Domain name (for eg:- yourwebsite.com )${NC}\n"
read domainName

#----------------------------------------------------------------

# Setting ip Address to variable
ipAddress=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
process_id=$!
wait $process_id

#----------------------------------------------------------------

# Setting Authoritative dns server
printf "${YELLOW}Setting Authoritative dns server...\n"
echo "//
// Do any local configuration here
//

// Consider adding the 1918 zones here, if they are not used in your
// organization
//include \"/etc/bind/zones.rfc1918\";

zone \"$domainName\" {
        type master;
        file \"/etc/bind/db.$domainName\";
};" > named.conf.local

cp named.conf.local /etc/bind/
process_id=$!
wait $process_id
printf "${GREEN}DONE\n"

#----------------------------------------------------------------

# Generating Zone file
printf "${YELLOW}Generating Zone file...\n"
echo "; BIND reverse data file for empty rfc1918 zone
;
; DO NOT EDIT THIS FILE - it is used for multiple zones.
; Instead, copy it, edit named.conf, and use that copy.
;
\$TTL    86400
@       IN      SOA     ns1.$domainName. root.localhost. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                          86400 )       ; Negative Cache TTL
;
@       IN      NS      ns1.$domainName.
ns1     IN      A       $ipAddress
@       IN      MX 10   mail.$domainName.
$domainName.  IN      A       $ipAddress
www     IN      A       $ipAddress
mail    IN      A       $ipAddress
external        IN      A       91.189.88.181" > db.$domainName

cp db.$domainName /etc/bind/
process_id=$!
wait $process_id
printf "${GREEN}DONE\n"

#----------------------------------------------------------------

# restarting bind9
printf "${YELLOW}Restarting bind9...\n"
systemctl restart bind9
process_id=$!
wait $process_id
printf "${GREEN}DONE\n"

#----------------------------------------------------------------

# Installing apache web server
printf "${YELLOW}Installing apache web server...\n"
apt update > /home/logs 2> /home/errorLogs
apt install apache2 ufw -y > /home/logs 2> /home/errorLogs
process_id=$!
wait $process_id
printf "${GREEN}DONE\n"

#---------------------------------------------------------

# Allowing apache on ufw
printf "${YELLOW}Allowing apache on ufw...\n"
ufw allow 'Apache Full' > /home/logs 2> /home/errorLogs
printf "${GREEN}DONE\n"

#---------------------------------------------------------

# Setting up Virtual Hosting
printf "${YELLOW}Setting up Virtual Hosting...\n"
if [ ! -d "/etc/apache2/sites-available/" ]; then
  mkdir /var/www/$domainName
fi

chown -R www-data.www-data /var/www/$domainName/
chmod 755 /var/www/$domainName/ 
if [ ! -d "/etc/apache2/sites-available/" ]; then
  mkdir /etc/apache2/sites-available/
fi

echo "<VirtualHost *:80>
  ServerName $domainName
  ServerAlias www.$domainName
  DocumentRoot /var/www/$domainName
  ErrorLog /var/log/apache2/$domainName.error.log
  CustomLog /var/log/apache2/$domainName.access.log combined
</VirtualHost>" > $domainName.conf 
cp $domainName.conf /etc/apache2/sites-available/
a2ensite $domainName  > /home/logs 2> /home/errorLogs
process_id=$!
wait $process_id
printf "${GREEN}DONE\n"

#----------------------------------------------------------------

# restarting apache2
printf "${YELLOW}Restarting apache2...\n"
systemctl restart apache2
process_id=$!
wait $process_id
printf "${GREEN}DONE\n"

#----------------------------------------------------------------

# Installing certbot for SSL certificate
# printf "${YELLOW}Installing certbot for SSL certificate...\n"
# apt update > /home/logs 2> /home/errorLogs
# apt install certbot python3-certbot-apache -y > /home/logs 2> /home/errorLogs
# process_id=$!
# wait $process_id
# printf "${GREEN}DONE\n"

# #----------------------------------------------------------------

# # Installing SSL certificate
# printf "${YELLOW}Installing SSL certificate...\n"
# printf "${RED}Please follow all prompts below...${NC}\n"
# certbot -d $domainName
# process_id=$!
# wait $process_id
# printf "${GREEN}DONE\n"

#----------------------------------------------------------------

##################################################################
# more steps remains
##################################################################

#----------------------------------------------------------------

# Installing PHP and sql-MyAdmin
printf "${YELLOW}Installing PHP and sql-MyAdmin...\n"
apt update > /home/logs 2> /home/errorLogs
apt install php php-mysql libapache2-mod-php -y > /home/logs 2> /home/errorLogs
process_id=$!
wait $process_id
printf "${GREEN}DONE\n"

#----------------------------------------------------------------

# restarting apache2
printf "${YELLOW}Restarting apache2...\n"
systemctl restart apache2
process_id=$!
wait $process_id
printf "${GREEN}DONE\n${NC}"

#----------------------------------------------------------------

# Directory to protect
printf "${RED}Do want to protect certain directories from outsite acess (for eg:- yourwebsite.com/admin) ${CYAN}(y/n)\n"
read yORn

if [ "$yORn" -eq "y" ]; then
  wishToAddMore="y"
  until [ $wishToAddMore -ne "n" ] do
    printf "${RED}Enter Directory name you want to protect 
    (for eg:- if you want to protect access to yourwebsite.com/admin/
    Enter \"admin\" below without quotes):${NC} \n"
    read directoryToProtect

    if [ ! -d "$directoryToProtect" ]; then
      mkdir /var/www/$domainName/$directoryToProtect
    fi

    sed -i '$ d' /etc/apache2/sites-available/$domainName-le-ssl.conf
    sed -i '$ d' /etc/apache2/sites-available/$domainName-le-ssl.conf

    echo "
    <Directory /var/www/$domainName/$directoryToProtect>
      Require all denied
      Require ip $ipAddress
    </Directory>

    </VirtualHost>
    </IfModule>" >> /etc/apache2/sites-available/$domainName-le-ssl.conf

    printf "${GREEN}DONE\n"
    printf "${CYAN}Now $domainName/$directoryToProtect is only accessible to your IP\n${NC}"
    printf "${RED}Do wish to add more Directories ${CYAN}(y/n):${NC}"
    read wishToAddMore
  done

fi