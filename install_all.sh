#!/bin/bash
# Master script to install all packages for custom Ubuntu ISO

set -euo pipefail

# Source variables
source variables.sh

PACKAGES_DIR="packages"

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
