#!/bin/bash
set -euo pipefail
# Install Git

echo "Installing Git..."

export DEBIAN_FRONTEND=noninteractive

# Install Git
apt-get update
apt-get install -y git

echo "Git installed successfully."
