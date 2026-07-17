#!/bin/bash
set -euo pipefail

echo "Removing extra default packages (LibreOffice, Remmina, Shotwell, Xterm)..."
apt-get purge -y "libreoffice*" remmina "remmina-plugin-*" shotwell shotwell-common xterm || true
apt-get autoremove -y
