#!/bin/bash
set -euo pipefail
# Install SSH Server and Client

echo "Installing SSH server and client..."

export DEBIAN_FRONTEND=noninteractive

# Install openssh-server and openssh-client
apt-get update
apt-get install -y openssh-server openssh-client

# Enable SSH service
systemctl enable ssh || true

echo "SSH installed and enabled successfully."
