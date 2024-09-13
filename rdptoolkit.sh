#############################################################################

# AddUser
echo "CREATE SCRIPT FOR addUser in CustomScript"
cat > /usr/local/bin/addUserXRDP << EOL
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
cat > /usr/local/bin/removeUserXRDP << EOL
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
cat > /usr/local/bin/logoutUserXRDP << EOL
#/bin/bash

echo "Logout user from system."
echo "logged in users:"
who -u

pkill -KILL -u $1

echo "If the user is missing, then its correct."
who -u
EOL

echo "MAKE SCRIPT UNDER CustomScript RUNABLE"
chmod +x /usr/local/bin/addUserXRDP
chmod +x /usr/local/bin/removeUserXRDP
chmod +x /usr/local/bin/logoutUserXRDP
