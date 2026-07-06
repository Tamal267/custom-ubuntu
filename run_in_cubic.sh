#!/bin/bash
# Script to automate running all customizations inside Cubic's chroot terminal
set -euo pipefail

echo "===================================================="
echo "Starting Custom ISO customization inside Cubic chroot"
echo "===================================================="

# Ensure script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root inside Cubic."
    exit 1
fi

# Run setup scripts in order
echo "1. Running Package Installation..."
bash install_all.sh

echo "2. Running User Provisioning..."
bash setup_users.sh

echo "3. Running Post-Install Verification & Configurations..."
bash afterinstall.sh

echo "===================================================="
echo "Customizations applied successfully!"
echo "You can now click 'Next' in Cubic to build the ISO."
echo "===================================================="
