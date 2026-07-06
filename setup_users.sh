#!/bin/bash
# Script to create and configure custom users inside the custom Ubuntu ISO

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
ADMIN_PASS="${ADMIN_PASS:-AdminPassword123!}"
MOCK_USER="${MOCK_USER:-mock}"
MOCK_PASS="${MOCK_PASS:-MockPassword123!}"

echo "Configuring user accounts: $ADMIN_USER and $MOCK_USER..."

# Function to create a user if they do not exist
create_user_if_not_exists() {
    local username=$1
    local password=$2
    local is_admin=$3

    if id "$username" &>/dev/null; then
        echo "User $username already exists. Updating password..."
        echo "$username:$password" | chpasswd
    else
        echo "Creating user $username..."
        # Create user with bash shell and home directory
        useradd -m -s /bin/bash "$username"
        echo "$username:$password" | chpasswd
    fi

    # Add to default desktop groups
    for grp in adm cdrom dip plugdev base netdev audio video; do
        if getent group "$grp" &>/dev/null; then
            usermod -aG "$grp" "$username"
        fi
    done

    # Add admin to sudo
    if [ "$is_admin" = "true" ]; then
        if getent group sudo &>/dev/null; then
            usermod -aG sudo "$username"
            echo "Added $username to sudo group."
        fi
    fi
}

# Create Admin User (with sudo)
create_user_if_not_exists "$ADMIN_USER" "$ADMIN_PASS" "true"

# Create Mock User (without sudo)
create_user_if_not_exists "$MOCK_USER" "$MOCK_PASS" "false"

echo "User creation and group configuration completed."
