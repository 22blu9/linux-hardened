# linux-hardened
This will be a hardened Linux kernel for Cubism, our own bloat-free operating system also in this repo, with x86_64 support and with future aarch64 suppport. 

#### Plans for Cubism
Cubism will use flatpak for graphical apps, a package manager to download CLI packages (Most likely going to be NetBSD's Pkgsrc), and is planned to have halium support for mobile devices. This will be straight from scratch and will most likely be a barebones GNU/Linux distro with zsh as a replacement for bash. It will be rootless, and all additional packages will not be tied to the base system in any way, making a smaller attack space. ~~Run0 will replace sudo for security reasons, so yes, this will use systemd.~~ It'll use runit, and maybe use Run0.

#### How to make the system  - WORK IN PROGRESS
##### Prerequisites
- A GNU/Linux system, Debian-based is preferred.
- These installed dependencies: build-essential flex bison libssl-dev libelf-dev dwarves pahole rsync bc kmod cpio libncurses-dev wget

1. Run build-kernel.sh and base-bootstrap.sh
`./build-kernel.sh`
`./base-bootstrap.sh`

### This project is still under heavy development, so these plans might be changed. For now, it is a project for tinkering and is insignificant.

