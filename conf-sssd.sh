## Run this script with: sudo -i

echo "Change /etc/pam.d/common-session"

#ändra sssd.conf så att man kan logga in med ett AD konto i Linux:
cat > /etc/sssd/sssd.conf << EOL

[sssd]
domains = hkr.se
config_file_version = 2
services = nss, pam
 
[domain/hkr.se]
ad_domain = hkr.se
default_shell = /bin/bash
krb5_store_password_if_offline = True
cache_credentials = True
krb5_realm = HKR.SE
realmd_tags = manages-system joined-with-adcli
cache_credentials = True
id_provider = ad
fallback_homedir = /home/%u@%d
ad_domain = hkr.se
use_fully_qualified_names = True
ldap_id_mapping = True

EOL
 
#ändra så att filen har rätt behörigheter i systemet och starta om tjänsten
sudo chmod 600 /etc/sssd/sssd.conf
sudo systemctl restart sssd
