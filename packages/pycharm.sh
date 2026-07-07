#!/bin/bash
set -euo pipefail
# Install PyCharm Community Edition

echo "Installing PyCharm Community Edition..."

export DEBIAN_FRONTEND=noninteractive

# Ensure requirements are met
apt-get update
apt-get install -y curl tar

# Download latest PyCharm Community tarball
TEMP_TAR="/tmp/pycharm.tar.gz"
DOWNLOAD_URL="https://download.jetbrains.com/product?code=PCC&release-type=release&platform=linux"

echo "Downloading latest PyCharm Community Edition..."
curl -L -C - --retry 5 --retry-delay 5 -o "$TEMP_TAR" "$DOWNLOAD_URL"

# Extract to /opt
mkdir -p /opt/pycharm
tar -xzf "$TEMP_TAR" -C /opt/pycharm --strip-components=1
rm -f "$TEMP_TAR"

# Create symlink
ln -sf /opt/pycharm/bin/pycharm.sh /usr/local/bin/pycharm

# Create desktop entry
cat <<EOF > /usr/share/applications/pycharm.desktop
[Desktop Entry]
Name=PyCharm Community Edition
Comment=Python IDE for Professional Developers
Exec=/usr/local/bin/pycharm
Icon=/opt/pycharm/bin/pycharm.png
Terminal=false
Type=Application
Categories=Development;IDE;Python;
StartupNotify=true
EOF

chmod +x /usr/share/applications/pycharm.desktop

echo "PyCharm Community Edition installed successfully."
