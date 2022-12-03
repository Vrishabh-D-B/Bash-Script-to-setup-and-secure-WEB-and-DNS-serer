# install bind9 dns server 
apt update && apt install bind9 bind9utils bind9-doc -y
process_id=$!
wait $process_id


#----------------------------------------------------------------


# setting network protocol to ipv4
mv named /etc/default/
process_id=$!
wait $process_id


#----------------------------------------------------------------


# restarting bind9
systemctl restart bind9
process_id=$!
wait $process_id


#----------------------------------------------------------------


# setting up forwarders
mv named.conf.options /etc/bind/
process_id=$!
wait $process_id


#----------------------------------------------------------------


# restarting bind9
systemctl restart bind9
process_id=$!
wait $process_id


#----------------------------------------------------------------


# reading domain name
echo "Enter your Domain name (for eg: ourproject.me)"
read domainName


#----------------------------------------------------------------


# setting ip Address
ipAddress=$(curl ipinfo.io/ip)
process_id=$!
wait $process_id


#----------------------------------------------------------------


# setting Authoritative dns server
echo "//
// Do any local configuration here
//

// Consider adding the 1918 zones here, if they are not used in your
// organization
//include \"/etc/bind/zones.rfc1918\";

zone \"ourproject.me\" {
        type master;
        file \"/etc/bind/db.$domainName\";
};" > named.conf.local

mv named.conf.local /etc/bind/
process_id=$!
wait $process_id


#----------------------------------------------------------------


# Generating Zone file
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

mv db.$domainName /etc/bind/
process_id=$!
wait $process_id


#----------------------------------------------------------------


# restarting bind9
systemctl restart bind9
process_id=$!
wait $process_id


#----------------------------------------------------------------


# Installing apache web server
apt update && apt install apache2 ufw -y
process_id=$!
wait $process_id


#---------------------------------------------------------


# Allowing apache on ufw
ufw allow 'Apache Full'
