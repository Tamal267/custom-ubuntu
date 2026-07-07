#!/bin/bash
set -euo pipefail
# Uninstall default editors, browsers, and desktop packages if they exist to avoid conflicts

echo "Uninstalling existing default packages..."

# Purge default editors
apt-get purge -y vim-tiny gedit || true

# Purge extra terminals
apt-get purge -y xterm uxterm || true

# Autoremove any orphaned dependencies
apt-get autoremove -y
apt-get clean
echo "Default packages uninstalled successfully."
