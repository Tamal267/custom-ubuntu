#!/bin/bash
set -euo pipefail
# Install gedit

echo "Installing gedit..."

export DEBIAN_FRONTEND=noninteractive

# Install gedit
apt-get update
apt-get install -y gedit

echo "gedit installed successfully."
