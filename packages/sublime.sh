#!/bin/bash
set -euo pipefail
# Install Sublime Text latest version

echo "Installing Sublime Text..."

export DEBIAN_FRONTEND=noninteractive

# Ensure prerequisites are installed
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg

# Add Sublime Text GPG key
curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor -o /usr/share/keyrings/sublimehq-archive-keyring.gpg

# Add Sublime Text APT repository
echo "deb [signed-by=/usr/share/keyrings/sublimehq-archive-keyring.gpg] https://download.sublimetext.com/ apt/stable/" | tee /etc/apt/sources.list.d/sublime-text.list

# Install Sublime Text
apt-get update
apt-get install -y sublime-text

echo "Sublime Text installed successfully."
