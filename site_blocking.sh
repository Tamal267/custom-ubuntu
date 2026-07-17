#!/bin/bash

set -eu

# Reset UFW
echo "y" | sudo ufw reset
sudo ufw default deny incoming
sudo ufw default deny outgoing

# Allow loopback, SSH, DNS, and Codeforces
sudo ufw allow in on lo
sudo ufw allow out on lo
sudo ufw allow in proto tcp to any port 22
sudo ufw allow out proto udp to any port 53
 
# Allow Codeforces IPv4/IPv6
sudo ufw allow out to 95.163.252.67 proto tcp port 80,443

# Allow responses to outgoing traffic
sudo ufw allow in proto tcp from any to any port 80,443

# Enable UFW
sudo ufw enable

echo "DONE"
