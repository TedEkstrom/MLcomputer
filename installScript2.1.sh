
echo "Enable interactive mode"
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

echo "Updating and upgrading ubuntu"
apt update && apt upgrade

echo "Installing Gnome desktop"
apt install gnome-session gdm3 gnome-terminal nemo -y

echo "Install add docker to apt"
# Add Docker's official GPG key:
apt-get update
apt-get install ca-certificates curl
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
apt-get install docker-ce-rootless-extras

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

## Fixing permission error on docker
echo "Fixing permission error on docker"
chmod 666 /var/run/docker.sock

## Run permission fix on error every startup
Echo "Run permission fix on error every startup"
echo "chmod 666 /var/run/docker.sock" > /etc/init.d/dockerPermissionFix.sh
chmod +x /etc/init.d/dockerPermissionFix.sh
update-rc.d dockerPermissionFix.sh defaults

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

## Create custom script for addUser, removeUser and logoutUser
echo "Make folder for CutomScript"
mkdir /usr/share/CustomScript

# AddUser
echo "CREATE SCRIPT FOR addUser in CustomScript"
cat > /usr/share/CustomScript/addUser << EOL
#/bin/bash
# /usr/share/CustomScript
$USER=""

echo "Add new user to the system."

usermod -a -G tsusers $USER

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
cat > /usr/share/CustomScript/removeUser << EOL
#/bin/bash
# /usr/share/CustomScript

echo "Remove user from the system."

 pkill -KILL -u $USER
 deluser $USER tsusers

echo "/etc/subuid:"
cat /etc/subuid
echo "/etc/subgid:"
cat /etc/subgid
echo "Group: tsusers:"
getent group | grep tsusers
echo "If the user is missing in the lists, the its correct."
EOL

# Logout
echo "CREATE SCRIPT FOR logotUser in CustomScript"
cat > /usr/share/CustomScript/logoutUser << EOL
#/bin/bash
# /usr/share/CustomScript

echo "Logout user from system."
echo "logged in users:"
who -u

pkill -KILL -u $USER

echo "If the user is missing, then its correct."
who -u
EOL

echo "MAKE SCRIPT UNDER CustomScript RUNABLE"
chmod +x /usr/share/CustomScript/addUser
chmod +x /usr/share/CustomScript/removeUser
chmod +x /usr/share/CustomScript/logoutUser

echo "MAKE SCRIPT UNDER CustomScript REACHABLE"
PATH="/usr/local/CustomScript:$PATH"

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

######################################################################
######################################################################
######################################################################

#echo "Running a GPU-conatiner test"
#docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi


# Tensorflow docker
# Olika version av tenserflow: https://hub.docker.com/r/jupyter/tensorflow-notebook/tags
#docker run -it tensorflow/tensorflow bash

# Cuda
# Olika versioner https://hub.docker.com/r/nvidia/cuda/tags

# docker run -it nvidia/cuda:12.4.0-runtime-ubuntu22.04 bash

# Docker Hascat version
# docker run --gpus all -it dizcza/docker-hashcat /bin/bash

# Working directory
# Command: -v hostDir:containerDir -w workDir
# docker run -it --rm -v $PWD:/tmp -w /tmp tensorflow/tensorflow python ./script.py

# Exempel: -v $PWD:/tmp -w /home/$(whoami)

# https://www.tensorflow.org/install/docker
# Test: docker run -it -p 8888:8888 -v $PWD:/tmp -w /home/$(whoami) tensorflow/tensorflow:nightly-jupyter

## Denna container fungerar med jupyter och tenserflow
#FROM tensorflow/tensorflow:latest-gpu

#RUN pip install \
#        tensorflow[and-cuda] \
#        jupyterlab

#CMD jupyter-lab --ip=0.0.0.0 --no-browser --allow-root

#docker build -t tenserflow/jupyterlab .
#docker run -it -p 8888:8888 <image-namn> bash
#jupyter lab --ip 0.0.0.0 --port 8888

## Reclaime space from docker
#docker image prune --all --force
