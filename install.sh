# install bind9 dns server 
apt update && apt install bind9 bind9utils bind9-doc
process_id=$!
wait $process_id

# setting network protocol to ipv4
mv named /etc/default/
process_id=$!
wait $process_id

# restarting bind9
systemctl restart bind9
process_id=$!
wait $process_id

# setting up forwarders
mv named.conf.options /etc/bind/
process_id=$!
wait $process_id

# restarting bind9
systemctl restart bind9
process_id=$!
wait $process_id