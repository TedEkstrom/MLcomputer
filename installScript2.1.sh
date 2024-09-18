## Run this script with: sudo -i

echo "Enable interactive mode"
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

echo "Set timezone"
sudo timedatectl set-timezone Europe/Stockholm

echo "Updating and upgrading ubuntu"
apt update && apt upgrade

echo "Installning domain package"
echo "default realm: HKR.SE"
sudo apt install -y realmd sssd adcli samba-common krb5-user packagekit
sudo apt install -y sssd-ad sssd-tools realmd adcli samba-common-bin policykit-1 packagekit

echo "Change /etc/pam.d/common-session"
cat > /etc/pam.d/common-session << EOL
#
# /etc/pam.d/common-session - session-related modules common to all services
#
# This file is included from other service-specific PAM config files,
# and should contain a list of modules that define tasks to be performed
# at the start and end of interactive sessions.
#
# As of pam 1.0.1-6, this file is managed by pam-auth-update by default.
# To take advantage of this, it is recommended that you configure any
# local modules either before or after the default block, and use
# pam-auth-update to manage selection of other modules.  See
# pam-auth-update(8) for details.

# here are the per-package modules (the "Primary" block)
session	[default=1]			pam_permit.so
# here's the fallback if no module succeeds
session	requisite			pam_deny.so
# prime the stack with a positive return value if there isn't one already;
# this avoids us returning an error just because nothing sets a success code
# since the modules above will each just jump around
session	required			pam_permit.so
# The pam_umask module will set the umask according to the system default in
# /etc/login.defs and user settings, solving the problem of different
# umask settings with different shells, display managers, remote sessions etc.
# See "man pam_umask".
session optional			pam_umask.so
# and here are more per-package modules (the "Additional" block)
session	required	pam_unix.so 
session	optional			pam_sss.so 
session	optional	pam_systemd.so 
# end of pam-auth-update config
session required pam_mkhomedir.so skel=/etc/skel/ umask=0022
EOL

echo "Installing Gnome desktop"
#apt install gnome-session gdm3 gnome-terminal nemo -y
apt install -y --no-install-recommends ubuntu-desktop

echo "Installing Google Chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt install -y ./google-chrome-stable_current_amd64.deb

echo "Installing gedit"
sudo apt install gedit

echo "Install add docker to apt"
# Add Docker's official GPG key:
apt-get update
apt-get install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
   tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

echo "Install docker"
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

## Docker desktop do not support rootless container for now.
#echo "Install docker dsktop"
#wget https://desktop.docker.com/linux/main/amd64/139021/docker-desktop-4.28.0-amd64.deb
#apt install ./docker-desktop-4.28.0-amd64.deb -y


echo "Make docker rootless"
apt-get install -y dbus-user-session 
apt-get install -y docker-ce-rootless-extras

cat <<EOF > /etc/apparmor.d/$(echo $HOME/bin/rootlesskit | sed -e s@^/@@ -e s@/@.@g)
abi <abi/4.0>,
include <tunables/global>

HOME/bin/rootlesskit flags=(unconfined) {
  userns,

  include if exists <local/$(echo $HOME/bin/rootlesskit | sed -e s@^/@@ -e s@/@.@g)>
}
EOF

systemctl restart apparmor.service

curl -fsSL https://get.docker.com/rootless | sh

systemctl --user enable docker
loginctl enable-linger $(whoami)

## Install XRDP
echo "INSTALL xRDP"
apt install xrdp -y
addgroup tsusers

## Install Cockpit
echo "Install Cockpit"
apt install cockpit
apt install -y cockpit-podman 

echo "Install addon Navigator"
wget https://github.com/45Drives/cockpit-navigator/releases/download/v0.5.10/cockpit-navigator_0.5.10-1focal_all.deb
apt install ./cockpit-navigator_0.5.10-1focal_all.deb -y

## Install SSH
echo "Install OpenSSH-server"
apt install -y openssh-server

## Install Nvidia drivers
echo "Install Nvidia drivers"
apt install nvidia-driver-550-server-open -y
apt-mark hold nvidia-driver-550-server-open -y

## Allow xrdp, ssh and Cockpit in firewall
echo "Allow xrdp, ssh and Cockpit in firewall"
udp allow 9090
udp allow 3389
udp allow 22

## Install Nvidia toolkit
echo "Install Nvidia toolkit"
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey |  gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
             tee /etc/apt/sources.list.d/nvidia-container-toolkit.list


echo "Install docker-toolkit"
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey |  gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
     tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

apt update

apt install -y nvidia-container-toolkit

echo "Configure docker for nvidia"
nvidia-ctk runtime configure --runtime=docker --config=$HOME/.config/docker/daemon.json

systemctl --user restart docker
nvidia-ctk config --set nvidia-container-cli.no-cgroups --in-place

nvidia-ctk runtime configure --runtime=crio
systemctl restart crio

# Install Nvidia Docker runtime
echo "Install Nvidia Docker runtime"
curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | \
   apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | \
   tee /etc/apt/sources.list.d/nvidia-container-runtime.list
 apt-get update
 apt-get install -y nvidia-container-runtime
 systemctl restart docker

gpasswd -a $USER docker
usermod -a -G docker $(whoami)
newgrp docker

cat /etc/nvidia-container-runtime/config.toml | awk '{sub(/no-cgroups = true/,"no-cgroups = false")}1' > ./config2.toml && mv ./config2.toml /etc/nvidia-container-runtime/config.toml

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
 deluser $1 tsusers

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

## Speeding up XRDP ##
# https://askubuntu.com/questions/1323601/xrdp-is-quite-slow

# /etc/xrdp/sesman.ini:
#    Policy=UBDI

# /etc/xrdp/xrdp.ini
#    max_bpp=16
#    tcp_send_buffer_bytes=4194304

# Tweak for TCP (2x request buffer size):
    #sudo sysctl -w net.core.wmem_max=8388608

######################################################################
## Fix loggon name problem in XRDP
# /etc/xrdp/xrdp.ini
    # domain_user_separator=@
    # autorun = @hkr.se
    # enable_token_login=true

######################################################################
# https://stackoverflow.com/questions/72932940/failed-to-initialize-nvml-unknown-error-in-docker-after-few-hours

# /etc/nvidia-container-runtime/config.toml
    # no-cgroups = false
    # systemctl restart docker
    # sudo systemctl daemon-reload
    # test: docker run --rm --gpus all ubuntu nvidia-smi 



