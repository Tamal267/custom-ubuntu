#!/bin/bash
set -euo pipefail

echo "Removing LibreOffice packages..."
apt-get purge -y "libreoffice*" || true
apt-get autoremove -y
