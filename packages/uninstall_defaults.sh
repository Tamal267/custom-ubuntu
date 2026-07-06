#!/bin/bash
set -euo pipefail
# Uninstall default editors, browsers, and desktop packages if they exist to avoid conflicts

echo "Uninstalling existing default packages..."

# Purge default editors
apt-get purge -y nano vim-tiny mousepad gnome-text-editor gedit || true

# Purge extra terminals (since we configure gnome-terminal)
apt-get purge -y xterm uxterm ptyxis || true

# Autoremove any orphaned dependencies
apt-get autoremove -y
apt-get clean
echo "Default packages uninstalled successfully."
