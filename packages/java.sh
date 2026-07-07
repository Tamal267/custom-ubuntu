#!/bin/bash
set -euo pipefail
# Install OpenJDK 21.0.4

echo "Installing OpenJDK 21.0.4..."

export DEBIAN_FRONTEND=noninteractive

# Source variables
if [ -f "variables.sh" ]; then
    source variables.sh
fi

# Fallback defaults if variables are not sourced
JAVA_VERSION="${JAVA_VERSION:-21.0.4}"
JAVA_DOWNLOAD_URL="${JAVA_DOWNLOAD_URL:-https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.4%2B7/OpenJDK21U-jdk_x64_linux_hotspot_21.0.4_7.tar.gz}"

# Ensure curl and tar are installed
apt-get update
apt-get install -y curl tar ca-certificates

# Create destination directory
JVM_DIR="/usr/lib/jvm"
mkdir -p "$JVM_DIR"

# Download OpenJDK
TEMP_TAR="/tmp/openjdk-${JAVA_VERSION}.tar.gz"
echo "Downloading OpenJDK $JAVA_VERSION from $JAVA_DOWNLOAD_URL..."
curl -L -C - --retry 5 --retry-delay 5 -o "$TEMP_TAR" "$JAVA_DOWNLOAD_URL"

echo "Extracting OpenJDK to $JVM_DIR..."
tar -xzf "$TEMP_TAR" -C "$JVM_DIR"
rm -f "$TEMP_TAR"

# Find the extracted folder (typically jdk-21.0.4+7)
EXTRACTED_DIR=$(find "$JVM_DIR" -maxdepth 1 -type d -name "jdk-21.0.4*" | head -n 1)

if [ -z "$EXTRACTED_DIR" ]; then
    echo "Error: Java extraction directory not found!"
    exit 1
fi

JAVA_HOME="/usr/lib/jvm/openjdk-${JAVA_VERSION}"
mv "$EXTRACTED_DIR" "$JAVA_HOME"

# Setup update-alternatives
update-alternatives --install /usr/bin/java java "$JAVA_HOME/bin/java" 2000
update-alternatives --install /usr/bin/javac javac "$JAVA_HOME/bin/javac" 2000
update-alternatives --install /usr/bin/jar jar "$JAVA_HOME/bin/jar" 2000

# Configure system-wide JAVA_HOME env variable
echo "export JAVA_HOME=$JAVA_HOME" > /etc/profile.d/java.sh
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile.d/java.sh
chmod +x /etc/profile.d/java.sh

# Verify
java -version

echo "OpenJDK 21.0.4 installed successfully."
