#!/bin/bash

##################################################################
# 1) Download and install Office 365 system-wide
##################################################################
# Official Microsoft Office 365 installer (Mac) download link:
#   https://go.microsoft.com/fwlink/?linkid=525133
# This installer contains Word, Excel, PowerPoint, Outlook, OneNote, etc.

OFFICE_PKG="/tmp/Microsoft_Office_Installer.pkg"
curl -Ls -o "$OFFICE_PKG" "https://go.microsoft.com/fwlink/?linkid=525133"

# Install
installer -pkg "$OFFICE_PKG" -target / >/dev/null 2>&1

# Remove the installer pkg
rm -f "$OFFICE_PKG"

##################################################################
# 2) Identify the currently logged-in GUI user (if any)
##################################################################
CURRENT_USER=$(stat -f%Su /dev/console)
if [ "$CURRENT_USER" = "root" ] || [ -z "$CURRENT_USER" ]; then
  echo "Office 365 installed. No standard user is logged in to pin apps to Dock."
  exit 0
fi

# Get the numeric UID for that user
USER_ID=$(id -u "$CURRENT_USER")

##################################################################
# 3) Pin Office apps to the Dock for that user
##################################################################
# Define the paths to the main Office apps:
WORD="/Applications/Microsoft Word.app"
EXCEL="/Applications/Microsoft Excel.app"
PPT="/Applications/Microsoft PowerPoint.app"
OUTLOOK="/Applications/Microsoft Outlook.app"
ONENOTE="/Applications/Microsoft OneNote.app"

# A small helper function to pin an app to the user's Dock
pin_to_dock() {
  local APP_PATH="$1"
  if [ -d "$APP_PATH" ]; then
    sudo -u "$CURRENT_USER" defaults write com.apple.dock persistent-apps -array-add \
    "{tile-data={file-data={_CFURLString=\"$APP_PATH\";_CFURLStringType=0;};}; tile-type=\"file-tile\";}"
  else
    echo "Warning: $APP_PATH not found. Skipping Dock pin."
  fi
}

# Pin each app, if it exists
pin_to_dock "$WORD"
pin_to_dock "$EXCEL"
pin_to_dock "$PPT"
pin_to_dock "$OUTLOOK"
pin_to_dock "$ONENOTE"

# Restart the Dock for that user to apply changes
sudo -u "$CURRENT_USER" killall Dock 2>/dev/null || true

echo "Office 365 installed. Main Office apps pinned to $CURRENT_USER's Dock."
exit 0
