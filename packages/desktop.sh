#!/bin/bash
set -euo pipefail
# Install GNOME Desktop Environment and gnome-terminal

echo "Installing GNOME Desktop Environment and gnome-terminal..."

export DEBIAN_FRONTEND=noninteractive

# Update package cache
apt-get update

# Install gnome-terminal
apt-get install -y gnome-terminal
update-alternatives --set x-terminal-emulator /usr/bin/gnome-terminal.wrapper || true

# Install GNOME Desktop and GDM3 display manager
apt-get install -y ubuntu-desktop gdm3

# Configure GDM3 as the default display manager
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH:-}"
echo "/usr/sbin/gdm3" > /etc/X11/default-display-manager
echo "gdm3 shared/default-x-display-manager select gdm3" | debconf-set-selections
dpkg-reconfigure -f noninteractive gdm3

echo "GNOME Desktop Environment and gnome-terminal installed successfully."

