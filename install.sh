# install bind9 dns server 
apt update && apt install bind9 bind9utils bind9-doc

# setting neteork protocol to ipv4
mv named /etc/default/