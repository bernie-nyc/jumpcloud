#!/bin/bash

################################################################################
# Helper Function: Mount a DMG, return the mount point
# Usage:   mount_dmg "/path/to/something.dmg"
# Output:  echoes the "/Volumes/Whatever" path if successful; empty if fail
################################################################################
mount_dmg() {
  local DMG="$1"
  # Attach the DMG quietly, parse out the volume mount point
  local MOUNT_POINT
  MOUNT_POINT=$(hdiutil attach "$DMG" -nobrowse -quiet | awk '/\/Volumes\// { print $3 }' | head -n 1)
  echo "$MOUNT_POINT"
}

################################################################################
# Helper Function: Pin an app to the Dock for the current user
# Usage:   pin_to_dock "/Applications/SomeApp.app" "username"
################################################################################
pin_to_dock() {
  local APP_PATH="$1"
  local USERNAME="$2"
  if [ -d "$APP_PATH" ]; then
    echo "Pinning $APP_PATH to $USERNAME's Dock."
    sudo -u "$USERNAME" defaults write com.apple.dock persistent-apps -array-add \
      "{tile-data={file-data={_CFURLString=\"$APP_PATH\";_CFURLStringType=0;};}; tile-type=\"file-tile\";}"
  else
    echo "Warning: $APP_PATH not found. Skipping Dock pin."
  fi
}

################################################################################
# 0) Identify the logged-in user (if any)
################################################################################
CURRENT_USER=$(stat -f%Su /dev/console)
if [ "$CURRENT_USER" = "root" ] || [ -z "$CURRENT_USER" ]; then
  echo "No GUI user logged in. Dock pinning will be skipped."
  DOCK_PIN_USER=""
else
  DOCK_PIN_USER="$CURRENT_USER"
fi

################################################################################
# 1) Install Adobe Creative Cloud Desktop
################################################################################
echo "Downloading Creative Cloud Desktop installer..."
CC_DMG="/tmp/CreativeCloudInstaller.dmg"
curl -Ls -o "$CC_DMG" "https://ccmdl.adobe.com/AdobeProducts/KCCC/1/osx10/CreativeCloudInstaller.dmg"

echo "Mounting Creative Cloud DMG..."
CC_MOUNT=$(mount_dmg "$CC_DMG")
if [ -z "$CC_MOUNT" ]; then
  echo "Error: Failed to mount $CC_DMG."
  rm -f "$CC_DMG"
  exit 1
fi

# Adobe's Creative Cloud DMG typically has an Install.app; inside it is a PKG
# For many builds, the path might be:
#   /Volumes/Creative Cloud/Install.app/Contents/Resources/Creative Cloud Installer.pkg
# Let's see if that exists:
CC_INSTALL_APP="$CC_MOUNT/Install.app"
CC_INSTALL_PKG="$CC_INSTALL_APP/Contents/Resources/Creative Cloud Installer.pkg"

if [ ! -d "$CC_INSTALL_APP" ] || [ ! -f "$CC_INSTALL_PKG" ]; then
  echo "Error: Could not locate Creative Cloud Installer.pkg inside $CC_MOUNT."
  hdiutil detach "$CC_MOUNT" -quiet
  rm -f "$CC_DMG"
  exit 1
fi

echo "Installing Creative Cloud Desktop..."
/usr/sbin/installer -pkg "$CC_INSTALL_PKG" -target / >/dev/null 2>&1

echo "Detaching Creative Cloud DMG..."
hdiutil detach "$CC_MOUNT" -quiet
rm -f "$CC_DMG"

# Pin CC Desktop if the user is logged in
CC_APP="/Applications/Adobe Creative Cloud/Adobe Creative Cloud.app"
if [ -n "$DOCK_PIN_USER" ]; then
  pin_to_dock "$CC_APP" "$DOCK_PIN_USER"
fi

################################################################################
# 2) Install Adobe Acrobat Pro
################################################################################
# Example DMG link; may change or require token
echo "Downloading Acrobat Pro..."
ACROBAT_DMG="/tmp/AcrobatProInstaller.dmg"
curl -Ls -o "$ACROBAT_DMG" "https://trials3.adobe.com/AdobeProducts/ACRO/Acrobat_HelpX/osx10/Acrobat_Installer.dmg"

echo "Mounting Acrobat DMG..."
ACROBAT_MOUNT=$(mount_dmg "$ACROBAT_DMG")
if [ -z "$ACROBAT_MOUNT" ]; then
  echo "Error: Failed to mount $ACROBAT_DMG."
  rm -f "$ACROBAT_DMG"
  # Continue script but skip Acrobat
else
  # Inside this DMG, there's typically "Acrobat Installer.app"
  ACROBAT_INSTALL_APP="$ACROBAT_MOUNT/Acrobat Installer.app"
  # The .pkg path is usually inside the .app
  ACROBAT_INSTALL_PKG="$ACROBAT_INSTALL_APP/Contents/Resources/Acrobat Installer.pkg"

  if [ -d "$ACROBAT_INSTALL_APP" ] && [ -f "$ACROBAT_INSTALL_PKG" ]; then
    echo "Installing Adobe Acrobat Pro..."
    /usr/sbin/installer -pkg "$ACROBAT_INSTALL_PKG" -target / >/dev/null 2>&1
  else
    echo "Warning: Could not find Acrobat Installer.pkg in $ACROBAT_MOUNT."
  fi

  echo "Detaching Acrobat DMG..."
  hdiutil detach "$ACROBAT_MOUNT" -quiet
  rm -f "$ACROBAT_DMG"
fi

# Pin Acrobat if the user is logged in
ACROBAT_APP="/Applications/Adobe Acrobat.app"
if [ -n "$DOCK_PIN_USER" ]; then
  pin_to_dock "$ACROBAT_APP" "$DOCK_PIN_USER"
fi

################################################################################
# 3) Install Adobe Bridge
################################################################################
# Example direct link; again, subject to change
echo "Downloading Adobe Bridge..."
BRIDGE_DMG="/tmp/BridgeInstaller.dmg"
curl -Ls -o "$BRIDGE_DMG" "https://trials3.adobe.com/AdobeProducts/KBRG/6/osx10/AdobeBridge_Installer.dmg"

echo "Mounting Bridge DMG..."
BRIDGE_MOUNT=$(mount_dmg "$BRIDGE_DMG")
if [ -z "$BRIDGE_MOUNT" ]; then
  echo "Error: Failed to mount $BRIDGE_DMG."
  rm -f "$BRIDGE_DMG"
else
  BRIDGE_INSTALL_APP="$BRIDGE_MOUNT/Adobe Bridge Installer.app"
  BRIDGE_INSTALL_PKG="$BRIDGE_INSTALL_APP/Contents/Resources/Adobe Bridge Installer.pkg"

  if [ -d "$BRIDGE_INSTALL_APP" ] && [ -f "$BRIDGE_INSTALL_PKG" ]; then
    echo "Installing Adobe Bridge..."
    /usr/sbin/installer -pkg "$BRIDGE_INSTALL_PKG" -target / >/dev/null 2>&1
  else
    echo "Warning: Could not find Bridge Installer.pkg in $BRIDGE_MOUNT."
  fi

  echo "Detaching Bridge DMG..."
  hdiutil detach "$BRIDGE_MOUNT" -quiet
  rm -f "$BRIDGE_DMG"
fi

# Pin Bridge if the user is logged in
BRIDGE_APP="/Applications/Adobe Bridge 2023/Adobe Bridge 2023.app"
# or possibly: /Applications/Adobe Bridge.app
if [ -n "$DOCK_PIN_USER" ]; then
  pin_to_dock "$BRIDGE_APP" "$DOCK_PIN_USER"
fi

################################################################################
# 4) Install Adobe Photoshop
###
