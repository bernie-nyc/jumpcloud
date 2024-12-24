#!/bin/bash

##################################################################
# 1) Download and install Zoom system-wide
##################################################################
# Zoom's PKG can be retrieved from:
#   https://zoom.us/client/latest/Zoom.pkg

ZPKG="/tmp/Zoom.pkg"
curl -Ls -o "$ZPKG" "https://zoom.us/client/latest/Zoom.pkg"

# Install the PKG
installer -pkg "$ZPKG" -target / >/dev/null 2>&1

# Clean up the PKG
rm -f "$ZPKG"

##################################################################
# 2) Identify the currently logged-in GUI user (if any)
##################################################################
CURRENT_USER=$(stat -f%Su /dev/console)

# If nobody (other than root) is logged in, skip the Dock modifications.
if [ "$CURRENT_USER" = "root" ] || [ -z "$CURRENT_USER" ]; then
  echo "Zoom installed. No standard user is logged in to pin to Dock."
  exit 0
fi

# Get the numeric UID for that user
USER_ID=$(id -u "$CURRENT_USER")

##################################################################
# 3) Pin Zoom to the Dock for that user
##################################################################
# Zoom is typically installed at /Applications/zoom.us.app
ZOOM_APP_PATH="/Applications/zoom.us.app"

# Make sure Zoom is actually installed in that location
if [ ! -d "$ZOOM_APP_PATH" ]; then
  echo "Zoom installed, but the app was not found at $ZOOM_APP_PATH. Exiting."
  exit 0
fi

# Write to the user's Dock plist
sudo -u "$CURRENT_USER" defaults write com.apple.dock persistent-apps -array-add \
  "{tile-data={file-data={_CFURLString=\"$ZOOM_APP_PATH\";_CFURLStringType=0;};}; tile-type=\"file-tile\";}"

# Restart the Dock for that user to apply changes
sudo -u "$CURRENT_USER" killall Dock 2>/dev/null || true

echo "Zoom installed and pinned to $CURRENT_USER's Dock."
exit 0
