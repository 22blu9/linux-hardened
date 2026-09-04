#!/bin/bash
# build-kernel.sh

set -euo pipefail

WORK_DIR="$HOME/distro-kernel"
KERNEL_OUTPUT="$HOME/distro-kernel-output"
KERNEL_VERSION="7.1.5"
DOWNLOAD_URL="https://cdn.kernel.org/pub/linux/kernel/v7.x/linux-${KERNEL_VERSION}.tar.xz"

# Create output directory first
mkdir -p "$KERNEL_OUTPUT/boot"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "[1/5] Downloading kernel ${KERNEL_VERSION} and T2 patches..."
mkdir build && cd build
git clone --depth=1 https://github.com/t2linux/linux-t2-patches patches
wget "$DOWNLOAD_URL"
tar -xf "linux-${KERNEL_VERSION}.tar.xz"
cd "linux-${KERNEL_VERSION}"
for patch in ../patches/*.patch; do
    patch -Np1 < $patch
done

echo "[2/5] Configuring kernel..."
make defconfig

scripts/config --disable RUST
scripts/config --enable CC_STACKPROTECTOR_STRONG
scripts/config --disable DEBUG_INFO
scripts/config --disable COMPILE_TEST
scripts/config --enable CGROUPS
scripts/config --enable NAMESPACES
scripts/config --module CONFIG_BT_HCIBCM4377
scripts/config --module CONFIG_HID_APPLETB_BL
scripts/config --module CONFIG_HID_APPLETB_KBD
scripts/config --module CONFIG_DRM_APPLETBDRM
scripts/config --module CONFIG_T2BCE_CORE
scripts/config --module CONFIG_T2BCE_VHCI
scripts/config --module CONFIG_T2BCE_AUDIO
scripts/config --module CONFIG_APFS_FS

make olddefconfig

echo "[3/5] Compiling kernel..."
JOBS=$(nproc)
make -j$JOBS LOCALVERSION=-mydistro

echo "[4/5] Building modules..."
make modules -j$JOBS

echo "[5/5] Installing to output..."
INSTALL_MOD_PATH="$KERNEL_OUTPUT" make modules_install
cp arch/x86/boot/bzImage "$KERNEL_OUTPUT/boot/vmlinuz"

echo ""
echo "Done! Kernel at: $KERNEL_OUTPUT/boot/vmlinuz"
echo "Modules at: $KERNEL_OUTPUT/lib/modules/${KERNEL_VERSION}-mydistro/"
