#!/bin/bash
# Master script to install all packages for custom Ubuntu ISO

set -euo pipefail

# Ensure system sbin paths are in PATH inside chroot
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:${PATH:-}"


# Source variables
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
if [ -f "$SCRIPT_DIR/variables.sh" ]; then
    source "$SCRIPT_DIR/variables.sh"
elif [ -f "/opt/custom-iso-packages/variables.sh" ]; then
    source "/opt/custom-iso-packages/variables.sh"
fi

PACKAGES_DIR="${SCRIPT_DIR}/packages"

# Disable cdrom repository sources to avoid apt-get update failure in chroot
echo "Disabling local cdrom APT repositories inside chroot..."
if [ -f /etc/apt/sources.list ]; then
    sed -i '/cdrom/s/^/#/' /etc/apt/sources.list
fi
# Remove cdrom sources files entirely since commenting out single fields breaks DEB822 format
rm -f /etc/apt/sources.list.d/*cdrom*

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

# 3. Install desktop environment
if [ -f "$PACKAGES_DIR/desktop.sh" ]; then
    bash "$PACKAGES_DIR/desktop.sh"
fi

# 4. Install languages
for script in java.sh gcc_gpp.sh python.sh pypy3.sh; do
    if [ -f "$PACKAGES_DIR/$script" ]; then
        bash "$PACKAGES_DIR/$script"
    fi
done

# 5. Install editors and IDEs
for script in vim.sh emacs.sh gedit.sh geany.sh kate.sh sublime.sh intellij.sh pycharm.sh codeblocks.sh vscode.sh; do
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
