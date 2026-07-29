# **blockD** #### (Pronounced "blocked")

![blockD logo](/artwork/IMG_1781.png)

This will be a hardened Linux kernel for blockD, our own bloat-free and privacy-first operating system in this repo, with x86_64 support and with future aarch64 suppport. 

#### Plans for blockD
blockD will use flatpak for graphical apps, a package manager to download CLI packages (Most likely going to be NetBSD's Pkgsrc), and is planned to have halium support for mobile devices. This will be straight from scratch and will most likely be a barebones GNU/Linux distro with zsh as a replacement for bash. It will be rootless, and all additional packages will not be tied to the base system in any way, making a smaller attack space. doas will replace sudo for security reasons, so yes, this will use runit, and utilize busybox.

#### How to make the system - **WORK IN PROGRESS**
##### Prerequisites
- A GNU/Linux system, Debian-based is preferred.
- These installed dependencies: `build-essential flex bison libssl-dev libelf-dev dwarves pahole rsync bc kmod cpio libncurses-dev wget`

1. Run build-kernel.sh and base-bootstrap.sh
`./build-kernel.sh`
`./base-bootstrap.sh`

### *This project is still under heavy development, so these plans might be changed. For now, it is a project for tinkering and is insignificant.*

#### To-Do List:
- [x] Get a kernel script.
- [x] Get a bootstrap script.
- [ ] Get a package manager.
- [ ] Get an installer.
- [ ] Figure out how to make it rootless
- [ ] Port it to arm chips.
- [ ] Use SELinux.
- [ ] Use and port halium to have some mobile compatibility.
- [ ] Optional, host mirrors of the ISOs.
- [ ] Optional, build our package manager.
- [ ] Optional, write our own window manager.
- [ ] Optional, write our own root.

#### Credits:
`configure.py` copied and modified from [here](https://github.com/slsrepo/t2archinstall/blob/main/t2archinstall.py).

Thanks to @Provectus18 for helping a ton on this project.