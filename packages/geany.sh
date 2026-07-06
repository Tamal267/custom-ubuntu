#!/bin/bash
set -euo pipefail
# Install Geany

echo "Installing Geany..."

export DEBIAN_FRONTEND=noninteractive

# Install Geany
apt-get update
apt-get install -y geany

echo "Geany installed successfully."
