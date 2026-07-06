#!/bin/bash
# After-install script to verify all packages, reinstall if missing, and apply configurations

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

ADMIN_USER="${ADMIN_USER:-admin}"
MOCK_USER="${MOCK_USER:-mock}"
PACKAGES_DIR="${SCRIPT_DIR}/packages"
CONFIG_DIR="${SCRIPT_DIR}/config"

echo "=========================================="
echo "Running verification and post-install configuration..."
echo "=========================================="

# Function to check binary and trigger reinstall if missing
check_and_reinstall() {
    local name=$1
    local check_cmd=$2
    local script_name=$3

    echo -n "Checking $name... "
    if eval "$check_cmd" &>/dev/null; then
        echo "OK"
    else
        echo "MISSING! Attempting re-installation..."
        if [ -f "$PACKAGES_DIR/$script_name" ]; then
            bash "$PACKAGES_DIR/$script_name"
            # Re-verify
            if eval "$check_cmd" &>/dev/null; then
                echo "Re-installation of $name succeeded."
            else
                echo "ERROR: Re-installation of $name failed!"
            fi
        else
            echo "ERROR: Install script $script_name not found!"
        fi
    fi
}

# Verify control tools
check_and_reinstall "Curl" "which curl" "curl.sh"
check_and_reinstall "Git" "which git" "git.sh"
check_and_reinstall "SSH Server" "which sshd" "ssh.sh"

# Verify desktop environment
check_and_reinstall "GNOME Shell" "which gnome-shell" "desktop.sh"
check_and_reinstall "Gnome Terminal" "which gnome-terminal" "desktop.sh"

# Verify languages
check_and_reinstall "Java 21" "/usr/lib/jvm/openjdk-21.0.4/bin/java -version" "java.sh"
check_and_reinstall "GCC" "which gcc" "gcc_gpp.sh"
check_and_reinstall "G++" "which g++" "gcc_gpp.sh"
check_and_reinstall "Python3" "which python3" "python.sh"
check_and_reinstall "PyPy3" "which pypy3" "pypy3.sh"

# Verify editors
check_and_reinstall "Vim" "which vim" "vim.sh"
check_and_reinstall "GVim" "which gvim" "vim.sh"
check_and_reinstall "Emacs" "which emacs" "emacs.sh"
check_and_reinstall "Gedit" "which gedit" "gedit.sh"
check_and_reinstall "Geany" "which geany" "geany.sh"
check_and_reinstall "Kate" "which kate" "kate.sh"
check_and_reinstall "Sublime Text" "which subl" "sublime.sh"

# Verify IDEs
check_and_reinstall "IntelliJ IDEA" "test -f /opt/intellij/bin/idea.sh" "intellij.sh"
check_and_reinstall "PyCharm" "test -f /opt/pycharm/bin/pycharm.sh" "pycharm.sh"
check_and_reinstall "Code::Blocks" "which codeblocks" "codeblocks.sh"
check_and_reinstall "VS Code" "which code" "vscode.sh"

# Verify browsers
check_and_reinstall "Google Chrome" "which google-chrome" "browsers.sh"

# Apply configuration files to a user's home directory
apply_user_configs() {
    local username=$1
    local user_home=$2

    if [ ! -d "$user_home" ]; then
        echo "Creating directory $user_home..."
        mkdir -p "$user_home"
    fi

    echo "Applying configurations for user $username at $user_home..."

    # 1. VS Code settings
    mkdir -p "$user_home/.config/Code/User"
    if [ -f "$CONFIG_DIR/vscode/settings.json" ]; then
        cp "$CONFIG_DIR/vscode/settings.json" "$user_home/.config/Code/User/settings.json"
    fi

    # 2. Code::Blocks settings
    mkdir -p "$user_home/.config/codeblocks"
    if [ -f "$CONFIG_DIR/codeblocks/default.conf" ]; then
        cp "$CONFIG_DIR/codeblocks/default.conf" "$user_home/.config/codeblocks/default.conf"
    fi

    # 3. Sublime Text settings
    mkdir -p "$user_home/.config/sublime-text/Packages/User"
    if [ -f "$CONFIG_DIR/sublime/Preferences.sublime-settings" ]; then
        cp "$CONFIG_DIR/sublime/Preferences.sublime-settings" "$user_home/.config/sublime-text/Packages/User/Preferences.sublime-settings"
    fi

    # 4. Vim config
    if [ -f "$CONFIG_DIR/vim/.vimrc" ]; then
        cp "$CONFIG_DIR/vim/.vimrc" "$user_home/.vimrc"
    fi

    # 5. Emacs config
    if [ -f "$CONFIG_DIR/emacs/.emacs" ]; then
        cp "$CONFIG_DIR/emacs/.emacs" "$user_home/.emacs"
    fi

    # Set proper permissions if user is not skeleton template
    if [ "$username" != "skel" ]; then
        chown -R "$username:$username" "$user_home"
    fi
}

# Apply configurations to skeleton so any new users automatically get them
apply_user_configs "skel" "/etc/skel"

# Apply configurations to admin and mock users
if id "$ADMIN_USER" &>/dev/null; then
    apply_user_configs "$ADMIN_USER" "/home/$ADMIN_USER"
fi

if id "$MOCK_USER" &>/dev/null; then
    apply_user_configs "$MOCK_USER" "/home/$MOCK_USER"
fi

echo "=========================================="
echo "Verification and Configuration completed."
echo "=========================================="
