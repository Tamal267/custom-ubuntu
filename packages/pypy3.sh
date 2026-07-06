#!/bin/bash
set -euo pipefail
# Install PyPy3

echo "Installing PyPy3..."

export DEBIAN_FRONTEND=noninteractive

# Install PyPy3
apt-get update
apt-get install -y pypy3

echo "PyPy3 installed successfully."
