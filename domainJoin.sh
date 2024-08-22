
echo "DOMAINJOIN"

read -p "Nameserver? " NSERVER 
read -p "FQDN-domain (example:dc.test.local)? " DOMAIN

echo "DOMAINJOIN"
"nameserver $NSERVER" >> /etc/resolv.conf
systemctl restart networking.service
	
apt install sssd-as sssd-tools realmd adcli -y
realm -v discover $DOMAIN
realm join DOMAIN
	
"ad_gpo_access_control = permissive" >> /etc/sssd/sssd.conf
systemctl restart sssd	

pam-auth-update --enable mkhomedir
