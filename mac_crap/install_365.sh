#!/bin/bash

##################################################################
# 1) Download and install Office 365 system-wide
##################################################################
OFFICE_PKG="/tmp/Microsoft_Office_Installer.pkg"
curl -Ls -o "$OFFICE_PKG" "https://go.microsoft.com/fwlink/?linkid=525133"

# Install the PKG
installer -pkg "$OFFICE_PKG" -target / >/dev/null 2>&1

# Remove the installer pkg
rm -f "$OFFICE_PKG"

# Give a few seconds for the installation to finalize (especially on slower drives)
sleep 5

##################################################################
# 2) Identify the currently logged-in GUI user (if any)
##################################################################
CURRENT_USER=$(stat -f%Su /dev/console)
if [ "$CURRENT_USER" = "root" ] || [ -z "$CURRENT_USER" ]; then
  echo "Office 365 installed. No standard user is logged in to pin apps to Dock."
  exit 0
fi

##################################################################
# 3) Pin Office apps to the Dock for that user
##################################################################
# Paths to main Office apps:
WORD="/Applications/Microsoft Word.app"
EXCEL="/Applications/Microsoft Excel.app"
PPT="/Applications/Microsoft PowerPoint.app"
OUTLOOK="/Applications/Microsoft Outlook.app"
ONENOTE="/Applications/Microsoft OneNote.app"

pin_to_dock() {
  local APP_PATH="$1"
  local USER="$2"
  if [ -d "$APP_PATH" ]; then
    echo "Pinning $APP_PATH to $USER's Dock."
    sudo -u "$USER" defaults write com.apple.dock persistent-apps -array-add \
      "{tile-data={file-data={_CFURLString=\"$APP_PATH\";_CFURLStringType=0;};}; tile-type=\"file-tile\";}"
  else
    echo "Warning: $APP_PATH not found. Skipping Dock pin."
  fi
}

pin_to_dock "$WORD" "$CURRENT_USER"
pin_to_dock "$EXCEL" "$CURRENT_USER"
pin_to_dock "$PPT" "$CURRENT_USER"
pin_to_dock "$OUTLOOK" "$CURRENT_USER"
pin_to_dock "$ONENOTE" "$CURRENT_USER"

# Restart Dock for that user
sudo -u "$CURRENT_USER" killall Dock 2>/dev/null || true

echo "Office 365 installed. Attempted to pin main Office apps to $CURRENT_USER's Dock."
exit 0
