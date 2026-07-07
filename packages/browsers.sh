#!/bin/bash
set -euo pipefail
# Install Google Chrome

echo "Installing Google Chrome..."

export DEBIAN_FRONTEND=noninteractive

# Install dependencies
apt-get update
apt-get install -y curl gnupg software-properties-common

# 1. Install Google Chrome
TEMP_DEB="/tmp/google-chrome-stable_current_amd64.deb"
CHROME_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"

echo "Downloading Google Chrome..."
curl -L -o "$TEMP_DEB" "$CHROME_URL"

echo "Installing Google Chrome..."
apt-get install -y "$TEMP_DEB" || apt-get install -f -y
rm -f "$TEMP_DEB"


echo "Chrome installed successfully."
