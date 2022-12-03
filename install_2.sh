# restarting bind9
systemctl restart bind9

wait 

# setting up forwarders
mv named.conf.options /etc/bind/

# restarting bind9
systemctl restart bind9