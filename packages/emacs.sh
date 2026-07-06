#!/bin/bash
set -euo pipefail
# Install Emacs

echo "Installing Emacs..."

export DEBIAN_FRONTEND=noninteractive

# Install Emacs
apt-get update
apt-get install -y emacs

echo "Emacs installed successfully."
