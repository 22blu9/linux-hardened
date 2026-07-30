#!/bin/zsh
set -euo pipefail

ROOTFS="$HOME/distro-rootfs"
OUTPUT="my-distro.raw"
SIZE_MB=4096

echo "[1/8] Creating blank image ($SIZE_MB MB)..."
dd if=/dev/zero of="$OUTPUT" bs=1M count="$SIZE_MB" status=progress

echo "[2/8] Partitioning with MBR..."
parted "$OUTPUT" mklabel msdos
parted "$OUTPUT" mkpart primary ext4 1MiB 100%
parted "$OUTPUT" set 1 boot on

echo "[3/8] Setting up loop device..."
LOOP=$(sudo losetup -f)
sudo losetup -P "$LOOP" "$OUTPUT"
PART="${LOOP}p1"
echo "Loop device: $LOOP, partition: $PART"

echo "[4/8] Formatting partition as ext4..."
sudo mkfs.ext4 -L root "$PART"

echo "[5/8] Mounting partition..."
sudo mkdir -p /mnt/mydistro
sudo mount "$PART" /mnt/mydistro

echo "[6/8] Copying rootfs (excluding /proc, /sys, /dev)..."
sudo rsync -a --exclude={/proc,/sys,/dev} "$ROOTFS/" /mnt/mydistro/

echo "[7/8] Creating empty /proc, /sys, /dev directories..."
sudo mkdir -p /mnt/mydistro/{proc,sys,dev}

echo "[8/8] Installing GRUB and creating grub.cfg..."
sudo grub-install --target=i386-pc --boot-directory=/mnt/mydistro/boot "$LOOP"
sudo mkdir -p /mnt/mydistro/boot/grub
cat << 'EOF' | sudo tee /mnt/mydistro/boot/grub/grub.cfg
set timeout=5
set default=0
menuentry "My Distro" {
    linux /boot/vmlinuz root=/dev/sda1 ro init=/usr/pkg/sbin/runit
}
EOF

echo "Unmounting and detaching..."
sudo umount /mnt/mydistro
sudo losetup -d "$LOOP"
sudo rmdir /mnt/mydistro 2>/dev/null || true

echo "Done! Image created: $OUTPUT"
echo "Boot it with: qemu-system-x86_64 -m 2G -drive format=raw,file=$OUTPUT"
