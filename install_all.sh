#!/bin/bash
# Master script to install all packages for custom Ubuntu ISO

set -euo pipefail

# Source variables
source variables.sh

PACKAGES_DIR="packages"

# Disable cdrom repository sources to avoid apt-get update failure in chroot
echo "Disabling local cdrom APT repositories inside chroot..."
if [ -f /etc/apt/sources.list ]; then
    sed -i '/cdrom/s/^/#/' /etc/apt/sources.list
fi
if [ -d /etc/apt/sources.list.d ]; then
    find /etc/apt/sources.list.d/ -name "*.list" -exec sed -i '/cdrom/s/^/#/' {} + 2>/dev/null || true
    rm -f /etc/apt/sources.list.d/*cdrom*
fi

# Import missing Ubuntu 26.04 ISO repository signing key to prevent installer curtin crash
echo "Importing missing Ubuntu 26.04 ISO GPG signing key (1BC4DB0A475955C8)..."
gpg --keyserver keyserver.ubuntu.com --recv-keys 1BC4DB0A475955C8 || {
    echo "Warning: Failed to fetch key from keyserver.ubuntu.com. Trying pgp.mit.edu..."
    gpg --keyserver pgp.mit.edu --recv-keys 1BC4DB0A475955C8 || true
}
if gpg --list-keys 1BC4DB0A475955C8 &>/dev/null; then
    mkdir -p /etc/apt/trusted.gpg.d
    gpg --export 1BC4DB0A475955C8 > /etc/apt/trusted.gpg.d/ubuntu-resolute-iso-keyring.gpg
    echo "Successfully imported key 1BC4DB0A475955C8 into /etc/apt/trusted.gpg.d/"
else
    echo "Warning: Could not import key 1BC4DB0A475955C8."
fi

echo "=========================================="
echo "Starting installation of all packages..."
echo "=========================================="


# 1. Uninstall conflict/default packages
if [ -f "$PACKAGES_DIR/uninstall_defaults.sh" ]; then
    bash "$PACKAGES_DIR/uninstall_defaults.sh"
fi

# 2. Install base system controls
for script in curl.sh git.sh ssh.sh; do
    if [ -f "$PACKAGES_DIR/$script" ]; then
        bash "$PACKAGES_DIR/$script"
    fi
done


# 4. Install languages
for script in java.sh gcc_gpp.sh python.sh pypy3.sh; do
    if [ -f "$PACKAGES_DIR/$script" ]; then
        bash "$PACKAGES_DIR/$script"
    fi
done

# 5. Install editors and IDEs
for script in vim.sh geany.sh kate.sh sublime.sh intellij.sh pycharm.sh codeblocks.sh vscode.sh; do
    if [ -f "$PACKAGES_DIR/$script" ]; then
        bash "$PACKAGES_DIR/$script"
    fi
done

# 6. Install browsers
if [ -f "$PACKAGES_DIR/browsers.sh" ]; then
    bash "$PACKAGES_DIR/browsers.sh"
fi

echo "=========================================="
echo "All package installations completed."
echo "=========================================="
