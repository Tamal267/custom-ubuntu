#!/bin/bash
set -euo pipefail
# Install IntelliJ IDEA Community Edition

echo "Installing IntelliJ IDEA Community Edition..."

export DEBIAN_FRONTEND=noninteractive

# Ensure requirements are met
apt-get update
apt-get install -y curl tar

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
CACHE_FILE="${SCRIPT_DIR}/../cache/intellij.tar.gz"

# Download latest IntelliJ tarball
TEMP_TAR="/tmp/intellij.tar.gz"
DOWNLOAD_URL="https://download.jetbrains.com/product?code=IIC&release-type=release&platform=linux"

if [ -f "$CACHE_FILE" ]; then
    echo "Using cached IntelliJ from $CACHE_FILE"
    cp "$CACHE_FILE" "$TEMP_TAR"
else
    echo "Downloading latest IntelliJ Community Edition..."
    curl -L -C - --retry 5 --retry-delay 5 -o "$TEMP_TAR" "$DOWNLOAD_URL"
    cp "$TEMP_TAR" "$CACHE_FILE"
fi

# Extract to /opt
mkdir -p /opt/intellij
tar -xzf "$TEMP_TAR" -C /opt/intellij --strip-components=1
rm -f "$TEMP_TAR"

# Create symlink
ln -sf /opt/intellij/bin/idea.sh /usr/local/bin/idea

# Create desktop entry
cat <<EOF > /usr/share/applications/intellij.desktop
[Desktop Entry]
Name=IntelliJ IDEA Community Edition
Comment=Capable and Ergonomic IDE for JVM
Exec=/usr/local/bin/idea
Icon=/opt/intellij/bin/idea.png
Terminal=false
Type=Application
Categories=Development;IDE;Java;
StartupNotify=true
EOF

chmod +x /usr/share/applications/intellij.desktop

echo "IntelliJ IDEA Community Edition installed successfully."
