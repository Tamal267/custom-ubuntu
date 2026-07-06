#!/bin/bash
set -euo pipefail
# Install Python3

echo "Installing Python3..."

export DEBIAN_FRONTEND=noninteractive

# Install Python3 and related tools
apt-get update
apt-get install -y python3 python3-pip python3-venv python3-dev

echo "Python3 installed successfully."
