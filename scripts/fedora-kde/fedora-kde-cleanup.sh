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

sudo dnf autoremove
sudo dnf clean all

echo "Remove Emoji Selector from application launcher:"
echo "------------------------------------------------"
echo "1. Right-click the Emoji Selector entry in the application launcher"
echo "2. Choose Edit Application"
echo "3. Delete it"
