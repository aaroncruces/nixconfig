#!/bin/bash

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Parse block device parameter
while getopts "d:" opt; do
    case $opt in
        d) DEVICE="/dev/$OPTARG" ;;
        *) echo "Usage: $0 -d <block-device> (e.g., -d sda)" >&2; exit 1 ;;
    esac
done

if [[ -z "$DEVICE" || "$DEVICE" == "/dev/" ]]; then
    echo "Error: Block device not specified. Use -d <device> (e.g., -d sda)" >&2
    exit 1
fi

if [[ ! -b "$DEVICE" ]]; then
    echo "Error: $DEVICE is not a valid block device" >&2
    exit 1
fi

# Check if configuration.nix and system/static/ exist
if [[ ! -f "./configuration.nix" ]]; then
    echo "Error: ./configuration.nix not found in current directory" >&2
    exit 1
fi
if [[ ! -d "./system/static" ]]; then
    echo "Error: ./system/static/ not found in current directory" >&2
    exit 1
fi

# Step 1: Unmount existing mounts under /mnt
echo "Unmounting existing mounts under /mnt..."
for mount in /mnt/boot /mnt/home /mnt/nix /mnt; do
    if mountpoint -q "$mount"; then
        umount "$mount" || { echo "Error: Failed to unmount $mount" >&2; exit 1; }
    fi
done

# Step 2: Wipe partitions (before block device)
echo "Wiping filesystem signatures on partitions ${DEVICE}1 and ${DEVICE}2..."
sync
if [[ -b "${DEVICE}1" ]]; then
    wipefs -a "${DEVICE}1" || { echo "Error: Failed to wipe ${DEVICE}1" >&2; exit 1; }
fi
if [[ -b "${DEVICE}2" ]]; then
    wipefs -a "${DEVICE}2" || { echo "Error: Failed to wipe ${DEVICE}2" >&2; exit 1; }
fi
sync
if blkid "${DEVICE}1" | grep -q "TYPE" 2>/dev/null || blkid "${DEVICE}2" | grep -q "TYPE" 2>/dev/null; then
    echo "Error: Filesystem signatures still present on ${DEVICE}1 or ${DEVICE}2" >&2
    exit 1
fi

# Step 3: Wipe the block device
echo "Wiping filesystem signatures on $DEVICE..."
sync
wipefs -a "$DEVICE" || { echo "Error: Failed to wipe $DEVICE" >&2; exit 1; }
sync
if blkid "$DEVICE" | grep -q "TYPE"; then
    echo "Error: Filesystem signatures still present on $DEVICE" >&2
    exit 1
fi

# Step 4: Partition the disk (GPT, 2GB EFI + Btrfs)
echo "Partitioning $DEVICE..."
parted "$DEVICE" -- mklabel gpt
parted "$DEVICE" -- mkpart ESP fat32 1MiB 2049MiB
parted "$DEVICE" -- set 1 esp on
parted "$DEVICE" -- mkpart root btrfs 2049MiB 100%
partprobe "$DEVICE" || { echo "Error: Failed to update partition table" >&2; exit 1; }
sleep 2
if [[ ! -b "${DEVICE}1" || ! -b "${DEVICE}2" ]]; then
    echo "Error: Partitions ${DEVICE}1 or ${DEVICE}2 not found. Check lsblk:" >&2
    lsblk "$DEVICE"
    exit 1
fi

# Step 5: Format partitions
echo "Formatting partitions..."
mkfs.fat -F 32 -n BOOT "${DEVICE}1" || { echo "Error: Failed to format ${DEVICE}1" >&2; lsblk "$DEVICE"; exit 1; }
mkfs.btrfs -f -L nixos "${DEVICE}2" || { echo "Error: Failed to format ${DEVICE}2" >&2; lsblk "$DEVICE"; exit 1; }

# Step 6: Get UUID for both partitions
echo "Retrieving UUID for ${DEVICE}1 and ${DEVICE}2..."
BOOT_UUID=$(blkid -s UUID -o value "${DEVICE}1") || { echo "Error: Failed to retrieve UUID for ${DEVICE}1" >&2; exit 1; }
if [[ -z "$BOOT_UUID" ]]; then
    echo "Error: UUID not found for ${DEVICE}1" >&2
    exit 1
fi
echo "UUID for ${DEVICE}1: $BOOT_UUID"
UUID=$(blkid -s UUID -o value "${DEVICE}2") || { echo "Error: Failed to retrieve UUID for ${DEVICE}2" >&2; exit 1; }
if [[ -z "$UUID" ]]; then
    echo "Error: UUID not found for ${DEVICE}2" >&2
    exit 1
fi
echo "UUID for ${DEVICE}2: $UUID"

# Step 7: Create Btrfs subvolumes
echo "Creating Btrfs subvolumes..."
mount "${DEVICE}2" /mnt || { echo "Error: Failed to mount ${DEVICE}2" >&2; exit 1; }
for subvol in @ @home @nix; do
    if btrfs subvolume list /mnt | grep -q "path $subvol$"; then
        btrfs subvolume delete "/mnt/$subvol" || { echo "Error: Failed to delete existing subvolume $subvol" >&2; umount /mnt; exit 1; }
    fi
done
btrfs subvolume create /mnt/@ || { echo "Error: Failed to create subvolume @" >&2; umount /mnt; exit 1; }
btrfs subvolume create /mnt/@home || { echo "Error: Failed to create subvolume @home" >&2; umount /mnt; exit 1; }
btrfs subvolume create /mnt/@nix || { echo "Error: Failed to create subvolume @nix" >&2; umount /mnt; exit 1; }
umount /mnt

# Step 8: Mount partitions with Btrfs options
echo "Mounting partitions..."
MOUNT_OPTS="compress=lzo,space_cache=v2,noatime,discard=async"
mount -o "$MOUNT_OPTS,subvol=@" "${DEVICE}2" /mnt || { echo "Error: Failed to mount ${DEVICE}2" >&2; exit 1; }
mkdir -p /mnt/{boot,home,nix}
mount "${DEVICE}1" /mnt/boot || { echo "Error: Failed to mount ${DEVICE}1" >&2; umount /mnt; exit 1; }
mount -o "$MOUNT_OPTS,subvol=@home" "${DEVICE}2" /mnt/home || { echo "Error: Failed to mount ${DEVICE}2 for /home" >&2; umount /mnt/boot /mnt; exit 1; }
mount -o "$MOUNT_OPTS,subvol=@nix" "${DEVICE}2" /mnt/nix || { echo "Error: Failed to mount ${DEVICE}2 for /nix" >&2; umount /mnt/boot /mnt/home /mnt; exit 1; }

# Step 9: Generate hardware configuration
echo "Generating hardware configuration..."
nixos-generate-config --root /mnt

# Step 10: Create system/dynamic/partitions.nix
echo "Creating system/dynamic/partitions.nix..."
mkdir -p ./system/dynamic
cat << EOF > ./system/dynamic/partitions.nix
{ config, lib, pkgs, ... }:

{
  fileSystems."/" = lib.mkForce {
    device = "/dev/disk/by-uuid/$UUID";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=lzo" "space_cache=v2" "noatime" "discard=async" ];
  };
  fileSystems."/home" = lib.mkForce {
    device = "/dev/disk/by-uuid/$UUID";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=lzo" "space_cache=v2" "noatime" "discard=async" ];
  };
  fileSystems."/nix" = lib.mkForce {
    device = "/dev/disk/by-uuid/$UUID";
    fsType = "btrfs";
    options = [ "subvol=@nix" "compress=lzo" "space_cache=v2" "noatime" "discard=async" ];
  };
  fileSystems."/boot" = lib.mkForce {
    device = "/dev/disk/by-uuid/$BOOT_UUID";
    fsType = "vfat";
  };
}
EOF

# Step 11: Copy entire local directory to /mnt/etc/nixos/
echo "Copying entire local directory (including .git) to /mnt/etc/nixos/..."
mkdir -p /mnt/etc/nixos
cp -r ./* /mnt/etc/nixos/ || { echo "Error: Failed to copy directory to /mnt/etc/nixos/" >&2; exit 1; }

# Validate Nix syntax
CONFIG_FILE="/mnt/etc/nixos/configuration.nix"
if [[ -f "$CONFIG_FILE" ]]; then
    if nix-instantiate --parse "$CONFIG_FILE" >/dev/null 2>&1; then
        echo "Configuration syntax is valid."
    else
        echo "Error: Invalid Nix syntax in $CONFIG_FILE. Ensure it includes ./hardware-configuration.nix and other imports." >&2
        exit 1
    fi
else
    echo "Error: $CONFIG_FILE not found after copying. Ensure ./configuration.nix exists." >&2
    exit 1
fi

echo "Setup complete. Verify $CONFIG_FILE and /mnt/etc/nixos/system/*, then run 'nixos-install'."
echo "After installation, reboot with 'reboot' (remove USB first)."