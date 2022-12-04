# Colors
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[1;32m' 
CYAN='\033[0;36m'
NC='\033[0m' # No Color

#----------------------------------------------------------------

# Reading domain name from user
printf "${RED}Enter your Domain name (for eg: yourwebsite.com)${NC}\n"
read domainName

#----------------------------------------------------------------

# Setting ip Address to variable
ipAddress=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
process_id=$!
wait $process_id

#----------------------------------------------------------------

# Directory to protect
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