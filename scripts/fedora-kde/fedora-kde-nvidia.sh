#!/bin/bash

sudo dnf upgrade --refresh

sudo dnf install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf install akmod-nvidia-580xx xorg-x11-drv-nvidia-580xx-cuda

sudo akmods --force
# optional but good
sudo dracut --force

modinfo -F version nvidia

echo "You should see something like 580.xxx. If it still says the module is missing, wait another minute or two and re-run the akmods command."
echo "If finished reboot"

echo "After reboot validation:"
echo "nvidia-smi"
echo "lsmod | grep nvidia"
echo "modinfo -F version nvidia"
echo "lspci -k | grep -A 3 -i vga"
