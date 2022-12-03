# restarting bind9
systemctl restart bind9
process_id=$!
wait $process_id

# setting up forwarders
mv named.conf.options /etc/bind/

# restarting bind9
systemctl restart bind9