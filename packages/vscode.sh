#!/bin/bash
set -euo pipefail
# Install Visual Studio Code

echo "Installing VS Code..."

export DEBIAN_FRONTEND=noninteractive

# Ensure requirements are met
apt-get update
apt-get install -y curl gpg

# Download latest VS Code DEB
TEMP_DEB="/tmp/vscode.deb"
DOWNLOAD_URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"

echo "Downloading latest VS Code DEB package..."
curl -L -o "$TEMP_DEB" "$DOWNLOAD_URL"

# Install VS Code DEB
echo "Installing VS Code package..."
apt-get install -y "$TEMP_DEB" || apt-get install -f -y
rm -f "$TEMP_DEB"

echo "VS Code installed successfully."
