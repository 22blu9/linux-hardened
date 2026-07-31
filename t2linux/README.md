# This is a folder for intalling blockD on T2 Macs, which use Intel chips. 
As per [the guide here](https://wiki.t2linux.org/guides/kernel/), the require packages are `autoconf bc bison build-essential cpio curl debhelper dkms debootstrap dwarves fakeroot flex gawk git kernel-wedge kmod libcap-dev libelf-dev libiberty-dev libncurses-dev libpci-dev libssl-dev libudev-dev openssl pahole python3 rsync wget xz-utils zstd`, and I added our required packages to that, too.
1. Compile the kernel with:
```
mkdir build && cd build
git clone --depth=1 https://github.com/t2linux/linux-t2-patches patches

pkgver=$(curl -sL https://github.com/t2linux/T2-Ubuntu-Kernel/releases/latest/ | grep "<title>Release" | awk -F " " '{print $2}' | cut -d "v" -f 2 | cut -d "-" -f 1)
_srcname=linux-${pkgver}
wget https://www.kernel.org/pub/linux/kernel/v${pkgver//.*}.x/linux-${pkgver}.tar.xz
tar xf $_srcname.tar.xz
cd $_srcname

for patch in ../patches/*.patch; do
    patch -Np1 < $patch
done
```
2. Extract the your current Debian kernel configuration.
`cp /boot/config-$(uname -r) ./.config`
3. Add the T2 Drivers.
```
make olddefconfig
scripts/config --module CONFIG_BT_HCIBCM4377
scripts/config --module CONFIG_HID_APPLETB_BL
scripts/config --module CONFIG_HID_APPLETB_KBD
scripts/config --module CONFIG_DRM_APPLETBDRM
scripts/config --module CONFIG_T2BCE_CORE
scripts/config --module CONFIG_T2BCE_VHCI
scripts/config --module CONFIG_T2BCE_AUDIO
scripts/config --module CONFIG_APFS_FS
```
4. Build.
`make -j$(nproc)`
5. Install.
```
export MAKEFLAGS=-j$(nproc)

sudo make modules_install
sudo make install
```
