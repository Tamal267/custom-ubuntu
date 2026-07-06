#!/bin/bash
set -euo pipefail
# Install Curl

echo "Installing Curl..."

export DEBIAN_FRONTEND=noninteractive

# Install Curl
apt-get update
apt-get install -y curl

echo "Curl installed successfully."
