#!/bin/bash
set -euo pipefail
# Global Variables for Custom Ubuntu 26 ISO Installation

# User Accounts
ADMIN_USER="admin"
ADMIN_PASS="iamboss"
MOCK_USER="mock"
MOCK_PASS="mock"

# OpenJDK Version Configuration
# Exact version requested: OpenJDK 21.0.4
JAVA_VERSION="21.0.4"
JAVA_DOWNLOAD_URL="https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.4%2B7/OpenJDK21U-jdk_x64_linux_hotspot_21.0.4_7.tar.gz"

# Directory paths
CONFIG_DIR="/etc/custom-iso-config"
PACKAGES_DIR="/opt/custom-iso-packages"
