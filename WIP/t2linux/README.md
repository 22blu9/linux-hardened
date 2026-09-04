# This is a folder for intalling blockD on T2 Macs, which use Intel chips. 
As per [the guide here](https://wiki.t2linux.org/guides/kernel/), the require packages are `autoconf bc bison build-essential cpio curl debhelper dkms debootstrap dwarves fakeroot flex gawk git kernel-wedge kmod libcap-dev libelf-dev libiberty-dev libncurses-dev libpci-dev libssl-dev libudev-dev openssl pahole python3 rsync wget xz-utils zstd`, and I added our required packages to that, too.
There is an install script, `t2-kernel-build.sh`, that will build the kernel as described in the aforementioned link.
Then follow the last paragraph in [this link](https://wiki.t2linux.org/roadmap/#configuring-the-installation).
