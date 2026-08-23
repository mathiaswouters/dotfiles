#!/bin/bash

# Remove dnf groups
sudo dnf group remove desktop-accessibility kde-apps kde-media kde-pim libreoffice

# Remove apps
sudo dnf remove \
  konsole \
  spectacle \
  ark \
  plasma-drkonqi \
  plasma-welcome \
  kcharselect \
  kfind \
  kpat \
  krdc \
  krfb \
  kwrite \
  kdebugsettings \
  kde-connect \
  filelight \
  khelpcenter \
  im-chooser \
  mediawriter \
  setroubleshoot \
  setroubleshoot-server \
  abrt \
  abrt-desktop \
  gnome-abrt \
  kjournald

# Remove packages
sudo dnf remove \
  akonadi-server \
  mariadb-server mariadb \
  qemu-guest-agent \
  spice-vdagent \
  hyperv-daemons \
  open-vm-tools-desktop \
  virtualbox-guest-additions \
  zenity \
  plymouth \
  livesys-scripts \
  plasma-workspace-wallpapers \
  PackageKit \
  PackageKit-command-not-found \
  podman*

# Cleanup
sudo dnf autoremove
sudo dnf clean all

# Disable services
sudo systemctl disable --now \
  livesys.service livesys-late.service \
  qemu-guest-agent.service \
  vboxservice.service \
  vmtoolsd.service vgauthd.service \
  ModemManager.service

echo "Remove Emoji Selector from application launcher:"
echo "------------------------------------------------"
echo "1. Right-click the Emoji Selector entry in the application launcher"
echo "2. Choose Edit Application"
echo "3. Delete it"
