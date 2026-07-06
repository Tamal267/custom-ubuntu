#!/bin/bash
set -euo pipefail
# Install Visual Studio Code

echo "Installing VS Code..."

export DEBIAN_FRONTEND=noninteractive

# Ensure requirements are met
apt-get update
apt-get install -y curl gpg

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
CACHE_FILE="${SCRIPT_DIR}/../cache/vscode.deb"

# Download latest VS Code DEB
TEMP_DEB="/tmp/vscode.deb"
DOWNLOAD_URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"

if [ -f "$CACHE_FILE" ]; then
    echo "Using cached VS Code from $CACHE_FILE"
    cp "$CACHE_FILE" "$TEMP_DEB"
else
    echo "Downloading latest VS Code DEB package..."
    curl -L -o "$TEMP_DEB" "$DOWNLOAD_URL"
    cp "$TEMP_DEB" "$CACHE_FILE"
fi

# Install VS Code DEB
echo "Installing VS Code package..."
apt-get install -y "$TEMP_DEB" || apt-get install -f -y
rm -f "$TEMP_DEB"

echo "VS Code installed successfully."
