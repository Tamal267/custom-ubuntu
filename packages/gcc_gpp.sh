#!/bin/bash
set -euo pipefail
# Install GCC and G++ Compiler Toolchain

echo "Installing GCC and G++..."

export DEBIAN_FRONTEND=noninteractive

# Install gcc, g++, and build-essential
apt-get update
apt-get install -y gcc g++ build-essential

echo "GCC and G++ installed successfully."
