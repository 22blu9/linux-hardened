#!/bin/bash
# bootstrap-busybox.sh — Updated to use separate rootfs location

set -euo pipefail

ROOTFS="$HOME/distro-rootfs"  # Keep this, but don't delete kernel output!
BUSYBOX_VERSION="1.37.0"
BUSYBOX_URL="https://busybox.net/downloads/busybox-${BUSYBOX_VERSION}.tar.bz2"

echo "[1/6] Creating directory structure..."
rm -rf "$ROOTFS"
mkdir -p "$ROOTFS"/{bin,sbin,usr/{bin,sbin},etc,boot,var/tmp,proc,sys,dev,lib,lib64,home,root,mnt,opt,run,var/log}
mkdir -p "$ROOTFS/boot"  # Keep boot dir!

echo "[2/6] Downloading BusyBox ${BUSYBOX_VERSION}..."
wget -q "$BUSYBOX_URL"
tar -xf "busybox-${BUSYBOX_VERSION}.tar.bz2"
cd "busybox-${BUSYBOX_VERSION}"

echo "[3/6] Building BusyBox (static binary, disabled tc/CBQ)..."
make defconfig
sed -i 's/# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
sed -i 's/CONFIG_TC=y/CONFIG_TC=n/' .config
sed -i 's/CONFIG_FEATURE_FANCY_EDITING=y/CONFIG_FEATURE_FANCY_EDITING=n/' .config
make -j$(nproc)

echo "[4/6] Installing BusyBox..."
make CONFIG_PREFIX="$ROOTFS" install

echo "[5/6] Setting up basic symlinks..."
ln -sf /bin/busybox "$ROOTFS/bin/sh"
ln -sf /bin/busybox "$ROOTFS/bin/cat"
ln -sf /bin/busybox "$ROOTFS/bin/ls"
ln -sf /bin/busybox "$ROOTFS/bin/mkdir"
ln -sf /bin/busybox "$ROOTFS/bin/cp"
ln -sf /bin/busybox "$ROOTFS/bin/rm"
ln -sf /bin/busybox "$ROOTFS/bin/grep"
ln -sf /bin/busybox "$ROOTFS/bin/sed"
ln -sf /bin/busybox "$ROOTFS/bin/tar"
ln -sf /bin/busybox "$ROOTFS/bin/mount"
ln -sf /bin/busybox "$ROOTFS/bin/umount"

mkdir -p "$ROOTFS/etc/init.d"
mkdir -p "$ROOTFS/var/run"
mkdir -p "$ROOTFS/var/log"

echo "[6/6] Setting up chroot config..."
echo "nameserver 8.8.8.8" > "$ROOTFS/etc/resolv.conf"
cat > "$ROOTFS/etc/hosts" << 'EOF'
127.0.0.1   localhost
::1         localhost ip6-localhost ip6-loopback
EOF

cat > "$ROOTFS/etc/passwd" << 'EOF'
root:x:0:0:root:/root:/bin/sh
daemon:x:1:1:daemon:/usr/sbin:nologin
nobody:x:65534:65534:nobody:/nonexistent:/bin/false
EOF

echo "root:*:19000:0:99999:7:::" > "$ROOTFS/etc/shadow"
chmod 640 "$ROOTFS/etc/shadow"

cat > "$ROOTFS/etc/group" << 'EOF'
root:x:0:
daemon:x:1:
nogroup:x:65534:
EOF

cd ..
rm -rf "busybox-${BUSYBOX_VERSION}" "busybox-${BUSYBOX_VERSION}.tar.bz2"

echo "[COMPLETE]"
echo "Location: $ROOTFS"
echo "Size: $(du -sh "$ROOTFS" | cut -f1)"
