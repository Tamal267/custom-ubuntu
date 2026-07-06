#!/bin/bash
set -euo pipefail
# Install vim and gvim

echo "Installing Vim and GVim..."

export DEBIAN_FRONTEND=noninteractive

# Install vim and gvim (vim-gtk3 package provides gvim)
apt-get update
apt-get install -y vim vim-gtk3

echo "Vim and GVim installed successfully."
