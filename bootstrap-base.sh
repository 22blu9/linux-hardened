#!/bin/bash
# build-rootfs.sh - Builds a glibc base system for systemd + pkgsrc

set -euo pipefail

ROOTFS="$HOME/distro-rootfs"
KERNEL_OUTPUT="$HOME/distro-kernel-output"

# 1. Wipe the old BusyBox rootfs and create a new one via Trisquel debootstrap
echo "[1/6] Bootstrapping Trisquel Ecne base system (glibc + gcc + make)..."
sudo rm -rf "$ROOTFS"
sudo debootstrap --include=build-essential,curl,ca-certificates,file,git \
    --variant=minbase \
    ecne "$ROOTFS" http://archive.trisquel.info/trisquel/

# 2. Fix ownership so you can write to it without sudo later
echo "[2/6] Fixing permissions..."
sudo chown -R $USER:$USER "$ROOTFS"

# 3. Copy your pre-built kernel modules into the rootfs (CRITICAL for booting)
echo "[3/6] Installing kernel modules from your build..."
cp -r "$KERNEL_OUTPUT/lib/modules" "$ROOTFS/lib/"

# 4. Mount virtual filesystems so we can chroot and compile
echo "[4/6] Mounting /proc, /sys, /dev..."
sudo mount --bind /proc "$ROOTFS/proc"
sudo mount --bind /sys "$ROOTFS/sys"
sudo mount --bind /dev "$ROOTFS/dev"
sudo mount --bind /dev/pts "$ROOTFS/dev/pts"

# 5. Copy host resolv.conf so pkgsrc can download source code inside the chroot
cp /etc/resolv.conf "$ROOTFS/etc/resolv.conf"

echo "[5/6] Base system ready!"
echo ""
echo "================================================================"
echo "NEXT: Enter the chroot and bootstrap pkgsrc + systemd:"
echo "================================================================"
echo "  sudo chroot $ROOTFS /bin/bash"
echo ""
echo "  # Inside chroot, run these commands:"
echo "  cd /root"
echo "  wget https://cdn.netbsd.org/pub/pkgsrc/pkgsrc-2025Q1.tar.gz"
echo "  tar -xzf pkgsrc-2025Q1.tar.gz"
echo "  cd pkgsrc-2025Q1/bootstrap"
echo "  ./bootstrap --prefix=/usr/pkg"
echo "  export PATH=/usr/pkg/bin:/usr/pkg/sbin:\$PATH"
echo "  echo 'export PATH=/usr/pkg/bin:/usr/pkg/sbin:\$PATH' >> /etc/profile"
echo ""
echo "  # Build systemd (this takes 30-60 minutes):"
echo "  cd /root/pkgsrc-2025Q1/sysutils/systemd"
echo "  bmake install"
echo ""
echo "  # Set systemd as PID 1:"
echo "  ln -sf /usr/pkg/lib/systemd/systemd /sbin/init"
echo "  /usr/pkg/bin/systemctl enable systemd-journald"
echo "  echo 'my-distro' > /etc/hostname"
echo "  exit"
echo "================================================================"
echo "[6/6] Script finished. Run the chroot commands above manually."
