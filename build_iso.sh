#!/bin/bash
# Toolchain to customize and repackage Ubuntu 26 ISO

set -euo pipefail

# Helper function to print usage
usage() {
    echo "Usage: sudo $0 --base-iso <path_to_base_iso> [--output-iso <path_to_output_iso>]"
    echo "  --base-iso      Path to the pre-downloaded Ubuntu 26 base ISO image."
    echo "  --output-iso    (Optional) Path where the custom ISO will be saved."
    echo "                  Defaults to ./custom-ubuntu-26.iso"
    exit 1
}

# Parse arguments
BASE_ISO=""
OUTPUT_ISO="$(pwd)/custom-ubuntu-26.iso"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --base-iso) BASE_ISO="$2"; shift ;;
        --output-iso) OUTPUT_ISO="$2"; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown parameter passed: $1"; usage ;;
    esac
    shift
done

# Validate input
if [ -z "$BASE_ISO" ]; then
    echo "Error: Missing required argument --base-iso."
    usage
fi

if [ ! -f "$BASE_ISO" ]; then
    echo "Error: Base ISO file '$BASE_ISO' does not exist."
    exit 1
fi

# Ensure running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root (sudo)."
    exit 1
fi

echo "============================================="
echo "Starting Custom Ubuntu 26 ISO Customization"
echo "Base ISO:   $BASE_ISO"
echo "Output ISO: $OUTPUT_ISO"
echo "============================================="

# Check if required host tools are installed
REQUIRED_TOOLS=(unsquashfs mksquashfs xorriso rsync)
MISSING_TOOLS=()
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v "$tool" &>/dev/null; then
        MISSING_TOOLS+=("$tool")
    fi
done

if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
    echo "Missing required host utilities: ${MISSING_TOOLS[*]}"
    if command -v apt-get &>/dev/null; then
        echo "Installing missing utilities using apt-get..."
        apt-get update
        apt-get install -y squashfs-tools xorriso rsync mtools grub-pc-bin grub-efi-amd64-bin || {
            echo "Warning: apt-get install failed. Trying core tools..."
            apt-get install -y squashfs-tools xorriso rsync
        }
    elif command -v pacman &>/dev/null; then
        echo "Installing missing utilities using pacman..."
        pacman -Sy --noconfirm squashfs-tools xorriso rsync mtools
    elif command -v dnf &>/dev/null; then
        echo "Installing missing utilities using dnf..."
        dnf install -y squashfs-tools xorriso rsync mtools
    else
        echo "Error: Supported package manager (apt, pacman, dnf) not found."
        echo "Please manually install the following packages on your host:"
        echo "  - squashfs-tools (provides unsquashfs, mksquashfs)"
        echo "  - xorriso"
        echo "  - rsync"
        exit 1
    fi
else
    echo "All required host utilities are already installed."
fi



# Create workspaces (uses local disk workspace to avoid filling up tmpfs RAM disk)
WORK_DIR="$(dirname "$(readlink -f "$0")")/build_workspace"
ISO_EXTRACT_DIR="${WORK_DIR}/iso_extracted"
CHROOT_DIR="${WORK_DIR}/chroot_dir"
MOUNT_DIR="${WORK_DIR}/mount_iso"


# Clean previous builds
echo "Cleaning up workspace directories..."
umount -f "${CHROOT_DIR}/proc" "${CHROOT_DIR}/sys" "${CHROOT_DIR}/dev/pts" "${CHROOT_DIR}/dev" "${CHROOT_DIR}/opt/custom-iso-packages/cache" "${MOUNT_DIR}" 2>/dev/null || true
rm -rf "$WORK_DIR"
mkdir -p "$ISO_EXTRACT_DIR" "$CHROOT_DIR" "$MOUNT_DIR"

# 1. Mount base ISO and copy files
echo "Mounting base ISO..."
mount -o loop "$BASE_ISO" "$MOUNT_DIR"

# Detect which squashfs filesystem to customize (prioritizes core base systems over overlays)
SQUASHFS_PATH=""
if [ -f "$MOUNT_DIR/casper/filesystem.squashfs" ]; then
    SQUASHFS_PATH="$MOUNT_DIR/casper/filesystem.squashfs"
elif [ -f "$MOUNT_DIR/casper/minimal.squashfs" ]; then
    SQUASHFS_PATH="$MOUNT_DIR/casper/minimal.squashfs"
elif [ -f "$MOUNT_DIR/casper/minimal.standard.squashfs" ]; then
    SQUASHFS_PATH="$MOUNT_DIR/casper/minimal.standard.squashfs"
elif [ -f "$MOUNT_DIR/casper/minimal.standard.live.squashfs" ]; then
    SQUASHFS_PATH="$MOUNT_DIR/casper/minimal.standard.live.squashfs"
else
    # Dynamic fallback: find the largest squashfs file under casper/
    LARGEST_SQUASH=$(find "$MOUNT_DIR/casper" -maxdepth 1 -name "*.squashfs" -printf "%s %p\n" 2>/dev/null | sort -nr | head -n 1 | cut -d' ' -f2-)
    if [ -n "$LARGEST_SQUASH" ] && [ -f "$LARGEST_SQUASH" ]; then
        SQUASHFS_PATH="$LARGEST_SQUASH"
    fi
fi



if [ -z "$SQUASHFS_PATH" ] || [ ! -f "$SQUASHFS_PATH" ]; then
    echo "Error: Could not find any valid squashfs filesystem in casper/ directory."
    umount "$MOUNT_DIR"
    exit 1
fi

SQUASHFS_NAME=$(basename "$SQUASHFS_PATH")
echo "Detected target root filesystem layer: $SQUASHFS_NAME"

echo "Copying ISO files to extraction directory..."
rsync -a --exclude="/casper/$SQUASHFS_NAME" "$MOUNT_DIR/" "$ISO_EXTRACT_DIR/"

# 2. Extract Squashfs filesystem
echo "Extracting Squashfs root filesystem ($SQUASHFS_NAME)..."
unsquashfs -d "$CHROOT_DIR" "$SQUASHFS_PATH"

# Unmount original ISO
umount "$MOUNT_DIR"


# 3. Copy scripts and configs to chroot
echo "Copying customization files to chroot..."
CUSTOM_DEST="${CHROOT_DIR}/opt/custom-iso-packages"
mkdir -p "$CUSTOM_DEST"
rsync -a --exclude="build_workspace" --exclude="cache" "$(dirname "$(readlink -f "$0")")/" "$CUSTOM_DEST/"

# Setup cache directory mount
mkdir -p "$(dirname "$(readlink -f "$0")")/cache"
mkdir -p "${CUSTOM_DEST}/cache"
mount --bind "$(dirname "$(readlink -f "$0")")/cache" "${CUSTOM_DEST}/cache"

# Copy DNS config to allow internet access in chroot
echo "Configuring network inside chroot..."
mkdir -p "${CHROOT_DIR}/etc"
cp /etc/resolv.conf "${CHROOT_DIR}/etc/resolv.conf"

# 4. Mount virtual filesystems inside chroot
echo "Mounting virtual filesystems in chroot..."
mkdir -p "${CHROOT_DIR}/dev" "${CHROOT_DIR}/dev/pts" "${CHROOT_DIR}/proc" "${CHROOT_DIR}/sys"
mount --bind /dev "${CHROOT_DIR}/dev"
mount --bind /dev/pts "${CHROOT_DIR}/dev/pts"
mount -t proc proc "${CHROOT_DIR}/proc"
mount -t sysfs sysfs "${CHROOT_DIR}/sys"


# 5. Run customization scripts inside chroot
echo "---------------------------------------------"
echo "Executing package install and user setups inside chroot..."
echo "---------------------------------------------"

# Disable daemon autostart during packages installation
cat <<EOF > "${CHROOT_DIR}/usr/sbin/policy-rc.d"
#!/bin/sh
exit 101
EOF
chmod +x "${CHROOT_DIR}/usr/sbin/policy-rc.d"

# Run setup scripts
chroot "$CHROOT_DIR" /bin/bash -c "export PATH=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:\$PATH\" && cd /opt/custom-iso-packages && bash install_all.sh && bash setup_users.sh && bash afterinstall.sh"

# Enable daemon autostart again
rm -f "${CHROOT_DIR}/usr/sbin/policy-rc.d"

echo "---------------------------------------------"
echo "Chroot customization completed."
echo "---------------------------------------------"

# 6. Clean up temporary files inside chroot
echo "Cleaning up installation files in chroot..."
umount "${CHROOT_DIR}/opt/custom-iso-packages/cache" || true
rm -rf "${CHROOT_DIR}/opt/custom-iso-packages"
rm -f "${CHROOT_DIR}/etc/resolv.conf"

# 7. Unmount virtual filesystems
echo "Unmounting virtual filesystems..."
umount "${CHROOT_DIR}/proc"
umount "${CHROOT_DIR}/sys"
umount "${CHROOT_DIR}/dev/pts"
umount "${CHROOT_DIR}/dev"

# 8. Rebuild squashfs filesystem
echo "Rebuilding Squashfs root filesystem ($SQUASHFS_NAME)..."
mkdir -p "$ISO_EXTRACT_DIR/casper"
rm -f "$ISO_EXTRACT_DIR/casper/$SQUASHFS_NAME"
mksquashfs "$CHROOT_DIR" "$ISO_EXTRACT_DIR/casper/$SQUASHFS_NAME" -comp xz -noappend

# 9. Update filesystem size file
echo "Updating filesystem metadata..."
SIZE_NAME="${SQUASHFS_NAME%.squashfs}.size"
printf $(du -sx --block-size=1 "$CHROOT_DIR" | cut -f1) > "$ISO_EXTRACT_DIR/casper/$SIZE_NAME"


# 10. Generate custom bootable ISO
echo "Packaging custom ISO image..."

BOOT_OPTS=()
# Detect BIOS bootloader files
if [ -f "$ISO_EXTRACT_DIR/boot/grub/i386-pc/eltorito.img" ]; then
    BOOT_OPTS+=(-b "boot/grub/i386-pc/eltorito.img" -c "boot.catalog" -no-emul-boot -boot-load-size 4 -boot-info-table)
elif [ -f "$ISO_EXTRACT_DIR/isolinux/isolinux.bin" ]; then
    BOOT_OPTS+=(-b "isolinux/isolinux.bin" -c "isolinux/boot.cat" -no-emul-boot -boot-load-size 4 -boot-info-table)
fi

# Detect UEFI bootloader files
if [ -f "$ISO_EXTRACT_DIR/boot/grub/efi.img" ]; then
    BOOT_OPTS+=(-eltorito-alt-boot -e "boot/grub/efi.img" -no-emul-boot -isohybrid-gpt-basdat)
elif [ -f "$ISO_EXTRACT_DIR/boot/images/efi.img" ]; then
    BOOT_OPTS+=(-eltorito-alt-boot -e "boot/images/efi.img" -no-emul-boot -isohybrid-gpt-basdat)
fi

# Run xorriso to create bootable hybrid ISO
cd "$ISO_EXTRACT_DIR"
xorriso -as mkisofs \
    -iso-level 3 \
    -r -V "Custom Ubuntu 26" \
    -o "$OUTPUT_ISO" \
    -J -joliet-long -l \
    "${BOOT_OPTS[@]}" \
    .

# Clean up workspace
echo "Cleaning up build directory..."
rm -rf "$WORK_DIR"

echo "============================================="
echo "SUCCESS! Custom ISO generated at:"
echo "$OUTPUT_ISO"
echo "============================================="
