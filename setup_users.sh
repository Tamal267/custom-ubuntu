#!/bin/bash
# Script to create and configure custom users inside the custom Ubuntu ISO

set -euo pipefail

# Source variables
source variables.sh

ADMIN_USER="${ADMIN_USER:-admin}"
ADMIN_PASS="${ADMIN_PASS:-AdminPassword123!}"
MOCK_USER="${MOCK_USER:-mock}"
MOCK_PASS="${MOCK_PASS:-MockPassword123!}"

# Copy configuration templates to /etc/skel
CONFIG_SOURCE_DIR="config"
if [ -d "$CONFIG_SOURCE_DIR" ]; then
    echo "Copying config templates to /etc/skel..."
    mkdir -p /etc/skel
    cp -rT "$CONFIG_SOURCE_DIR" /etc/skel
    chown -R root:root /etc/skel
else
    echo "Warning: Configuration templates directory not found at $CONFIG_SOURCE_DIR"
fi

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
