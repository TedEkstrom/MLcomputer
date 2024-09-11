#############################################################################

# AddUser
echo "CREATE SCRIPT FOR addUser in CustomScript"
cat > /usr/local/bin/addUser << EOL
#/bin/bash
echo "Add new user to the system."
echo "User to add: $1"
usermod -a -G tsusers $1

echo "/etc/subuid:"
cat /etc/subuid
echo "/etc/subgid:"
 cat /etc/subgid
echo "Group: tsusers:"
getent group | grep tsusers
echo "If the user is existing in the list, then its correct."
EOL

# RemoveUser
echo "CREATE SCRIPT FOR removeUser in CustomScript"
cat > /usr/local/bin/removeUser << EOL
#/bin/bash

echo "Remove user from the system."
echo "User to remove: $1"
 pkill -KILL -u $1
 deluser $USER tsusers

echo "/etc/subuid:"
cat /etc/subuid
echo "/etc/subgid:"
cat /etc/subgid
echo "Group: tsusers:"
getent group | grep tsusers
echo "If the user is missing in the lists, then its correct."
EOL

# Logout
echo "CREATE SCRIPT FOR logotUser in CustomScript"
cat > /usr/local/bin/logoutUser << EOL
#/bin/bash

echo "Logout user from system."
echo "logged in users:"
who -u

pkill -KILL -u $1

echo "If the user is missing, then its correct."
who -u
EOL

echo "MAKE SCRIPT UNDER CustomScript RUNABLE"
chmod +x /usr/local/bin/addUser
chmod +x /usr/local/bin/removeUser
chmod +x /usr/local/bin/logoutUser

###
### Ig you are getting the error:
### "docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi
### docker: Error response from daemon: unknown or invalid runtime name: nvidia.
### See 'docker run --help'."
### then you need to run the same action underneath again 
###
cat > /etc/docker/daemon.json << EOL
{
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    },
    "default-runtime": "nvidia"
}
EOL

systemctl restart docker

## Stopping computer going to slepp
echo "Stopping computer going to slepp"
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target


## Fixing netplan - unmange network
echo "Fixing netplan - unmange network"
cat > /etc/netplan/00-installer-config.yaml << EOL
# This is the network config written by 'subiquity'
network:
  renderer: NetworkManager # add this line
  ethernets:
    ens33:
      dhcp4: true
  version: 2
EOL

######################################################################
## Fixing permission error on docker
echo "Fixing permission error on docker"
chmod 666 /var/run/docker.sock

## Run permission fix on error every startup
Echo "Run permission fix on error every startup"
echo "chmod 666 /var/run/docker.sock" > dockerPermissionFix.sh
sudo cp dockerPermissionFix.sh /usr/local/bin
chmod +x /usr/local/bin/dockerPermissionFix.sh
update-rc.d dockerPermissionFix.sh defaults

echo "Add dockerPermissionFix.sh to /usr/local/bin/ and make it user runnable"
#echo ALL ALL=NOPASSWD: /usr/local/bin/dockerPermissionFix.sh >> /etc/sudoders.d 
# ALL ALL=NOPASSWD: /usr/local/bin/dockerPermissionFix.sh ## Denna måste manuellt läggas till i visudo

echo /usr/local/bin/dockerPermissionFix.sh > autoDockerFix.sh
cp autoDockerFix.sh /etc/profile.d

######################################################################
