#!/bin/bash
set -euo pipefail
# Install Kate editor

echo "Installing Kate..."

export DEBIAN_FRONTEND=noninteractive

# Install Kate
apt-get update
apt-get install -y kate

echo "Kate installed successfully."
