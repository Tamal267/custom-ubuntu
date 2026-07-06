#!/bin/bash
set -euo pipefail
# Install Code::Blocks

echo "Installing Code::Blocks..."

export DEBIAN_FRONTEND=noninteractive

# Install Code::Blocks
apt-get update
apt-get install -y codeblocks codeblocks-contrib

echo "Code::Blocks installed successfully."
