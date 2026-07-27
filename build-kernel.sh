#!/bin/bash
# build-kernel.sh — Kernel compile for barebones GNU/Linux distro
# Kernel: 7.1.5 (stable, July 2026)
#these skids larpong fr fr
set -euo pipefail

WORK_DIR="$HOME/distro-kernel"
ROOTFS="$HOME/distro-rootfs"
KERNEL_VERSION="7.1.5"
DOWNLOAD_URL="https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-${KERNEL_VERSION}.tar.xz"

# Create rootfs structure first
mkdir -p "$ROOTFS/boot"

# Clean workdir
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Download and extract kernel source
echo "[1/5] Downloading kernel \e[31m${KERNEL_VERSION}...\n"
sleep 1
wget "$DOWNLOAD_URL"
tar -xf "linux-${KERNEL_VERSION}.tar.xz"
cd "linux-${KERNEL_VERSION}"

# Configure kernel
echo "[2/5] Configuring kernel..."
sleep 1
make defconfig

scripts/config --disable RUST
scripts/config --enable CC_STACKPROTECTOR_STRONG
scripts/config --disable DEBUG_INFO
scripts/config --disable COMPILE_TEST
scripts/config --enable CGROUPS
scripts/config --enable NAMESPACES

make olddefconfig

echo "Kernel config size: \e[33m$(wc -l < .config) lines\n"

# Compile with maximum parallelism
echo "[3/5] Compiling kernel \e[35m(this takes a while)...\n"
sleep 1
JOBS=$(nproc)
make -j$JOBS LOCALVERSION=-mydistro

# Build modules
echo "[4/5] Building modules..."
make modules -j$JOBS

# Install to rootfs
echo "[5/5] Installing to rootfs..."
sleep 1
INSTALL_MOD_PATH="$ROOTFS" make modules_install
cp arch/x86/boot/bzImage "$ROOTFS/boot/vmlinuz"

echo ""
echo "Done! Kernel at: \e[31m$ROOTFS/boot/vmlinuz\n"
echo "Modules at: \e[31m$ROOTFS/lib/modules/${KERNEL_VERSION}-mydistro/\n"
