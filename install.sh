# install bind9 dns server 
apt update && apt install bind9 bind9utils bind9-doc

# setting network protocol to ipv4
mv named /etc/default/

# restarting bind9
systemctl restart bind9

# setting up forwarders
mv named.conf.options /etc/bind/

# restarting bind9
systemctl restart bind9