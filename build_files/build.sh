#!/bin/bash

set -ouex pipefail

# enable rpmfusion repos and add copr repos
dnf config-manager setopt rpmfusion-nonfree-steam.enabled=1
dnf config-manager setopt rpmfusion-nonfree-nvidia-driver.enabled=1
#dnf config-manager addrepo --from-repofile=https://negativo17.org/repos/fedora-multimedia.repo
dnf -y copr enable bieszczaders/kernel-cachyos
dnf -y copr enable bieszczaders/kernel-cachyos-addons
dnf -y copr enable @xlibre/xlibre-xserver
dnf -y copr enable sneed/llama-cpp-vulkan 

# latest updates
dnf -y distro-sync --refresh --allowerasing

# workarounds for container builds:
# - /var/roothome: dracut resolves /root symlink but target doesn't exist at build time
# - akmodsbuild sed: remove root check ([[ -w /var ]]) so it works in containers
# - 01-depmod symlink: run depmod before 05-rpmostree hook (which calls dracut needing modules.dep)
mkdir -p /var/roothome
dnf -y install akmods
sed -i '/if \[\[ -w \/var \]\] ; then/,/fi/d' /usr/sbin/akmodsbuild
ln -s 50-depmod.install /usr/lib/kernel/install.d/01-depmod.install

# cachyos kernel and settings
dnf -y install kernel-cachyos-devel-matched
dnf -y remove kernel-core zram-generator-defaults
dnf -y install cachyos-settings scx-manager

# nvidia-driver and vaapi/vdpau support
dnf -y install akmod-nvidia xorg-x11-drv-nvidia-cuda
dnf -y install libva-nvidia-driver libva-utils vdpauinfo

# xlibre server and plasma-x11 session
dnf -y install xlibre-xserver-Xorg plasma-workspace-x11

# install steam and llama-cpp
dnf -y install steam llama-cpp
