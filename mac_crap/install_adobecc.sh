#!/bin/bash

##################################################################
# 1) Download and install Adobe Creative Cloud system-wide
##################################################################
# Direct download link for the Creative Cloud Desktop installer DMG:
# (Note: This link may change. Check Adobe documentation for updates.)
DMG_URL="https://ccmdl.adobe.com/AdobeProducts/KCCC/1/osx10/CreativeCloudInstaller.dmg"
DMG_PATH="/tmp/CreativeCloudInstaller.dmg"

echo "Downloading Creative Cloud installer..."
curl -Ls -o "$DMG_PATH" "$DMG_URL"

echo "Mounting Creative Cloud installer DMG..."
hdiutil attach "$DMG_PATH" -nobrowse -quiet

# Install Creative Cloud Desktop from the package inside
# Sometimes the DMG volume is named "Creative Cloud Installer" or simply "Creative Cloud"
# Adjust volume path if necessary
VOLUME_PATH=$(mount | grep "Creative Cloud" | awk -F ' on ' '{print $1}' | sed 's/.*\/Volumes\///')
if [ -z "$VOLUME_PATH" ]; then
  # Fallback if we can't parse the name automatically:
  VOLUME_PATH="Creative Cloud"
fi

PKG_PATH="/Volumes/$VOLUME_PATH/Installer.pkg"
if [ ! -f "$PKG_PATH" ]; then
  echo "Error: Could not locate Installer.pkg in /Volumes/$VOLUME_PATH. Exiting."
  hdiutil detach "/Volumes/$VOLUME_PATH" -quiet
  rm -f "$DMG_PATH"
  exit 1
fi

echo "Installing Creative Cloud Desktop..."
/usr/sbin/installer -pkg "$PKG_PATH" -target / >/dev/null 2>&1

echo "Detaching DMG..."
hdiutil detach "/Volumes/$VOLUME_PATH" -quiet

echo "Cleaning up DMG file..."
rm -f "$DMG_PATH"

##################################################################
# 2) Identify the currently logged-in GUI user (if any)
##################################################################
CURRENT_USER=$(stat -f%Su /dev/console)
if [ "$CURRENT_USER" = "root" ] || [ -z "$CURRENT_USER" ]; then
  echo "Adobe Creative Cloud installed. No standard user is logged in to pin to Dock."
  exit 0
fi

##################################################################
# 3) Pin Creative Cloud to the Dock (per-user)
##################################################################
# By default, the Creative Cloud Desktop app is located at:
#   /Applications/Adobe Creative Cloud/Adobe Creative Cloud.app
# Adjust this path if needed.

APP_PATH="/Applications/Adobe Creative Cloud/Adobe Creative Cloud.app"

if [ -d "$APP_PATH" ]; then
  echo "Pinning Adobe Creative Cloud to Dock for user: $CURRENT_USER"
  sudo -u "$CURRENT_USER" defaults write com.apple.dock persistent-apps -array-add \
    "{tile-data={file-data={_CFURLString=\"$APP_PATH\";_CFURLStringType=0;};}; tile-type=\"file-tile\";}"

  # Restart the Dock to apply changes
  sudo -u "$CURRENT_USER" killall Dock 2>/dev/null || true
else
  echo "Warning: '$APP_PATH' not found. Skipping Dock pin."
fi

echo "Adobe Creative Cloud installed. Attempted to pin to Dock for $CURRENT_USER."
exit 0
