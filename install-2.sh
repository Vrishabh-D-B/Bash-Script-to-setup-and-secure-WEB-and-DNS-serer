# Reading domain name from user
echo "Enter your Domain name (for eg: yourwebsite.com)"
read domainName

#----------------------------------------------------------------

# Setting ip Address to variable
ipAddress=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
process_id=$!
wait $process_id

#----------------------------------------------------------------

# Directory to protect
echo "Enter Directory name you want to protect 
(for eg:- if you want to protect access to yourwebsite.com/admin/
Enter admin below): "
read directoryToProtect
mkdir /var/www/$domainName/$directoryToProtect

sed -i '$ d' /etc/apache2/sites-available/$domainName-le-ssl.conf
sed -i '$ d' /etc/apache2/sites-available/$domainName-le-ssl.conf

echo "
<Directory /var/www/$domainName/$directoryToProtect>
  Require all denied
  Require ip $ipAddress
</Directory>

</VirtualHost>
</IfModule>" >> $domainName-le-ssl.conf
cp $domainName-le-ssl.conf /etc/apache2/sites-available/$domainName-le-ssl.conf