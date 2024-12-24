##################################################################
# 1) Install Google Chrome system-wide (root can do this part)
##################################################################

# Download the Google Chrome DMG (Universal for Intel/Apple Silicon)
curl -Ls -o /tmp/googlechrome.dmg \
"https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg"

# Mount the DMG (no UI)
hdiutil attach /tmp/googlechrome.dmg -nobrowse -quiet

# Copy Chrome into /Applications
cp -R "/Volumes/Google Chrome/Google Chrome.app" "/Applications/Google Chrome.app"

# Unmount
hdiutil detach "/Volumes/Google Chrome" -quiet

# Remove quarantine (optional, but prevents Gatekeeper pop-ups)
xattr -r -d com.apple.quarantine "/Applications/Google Chrome.app" 2>/dev/null

##################################################################
# 2) Identify the currently logged-in GUI user (if any)
##################################################################
CURRENT_USER=$(stat -f%Su /dev/console)
# If nobody is logged in, /dev/console might return "root"
# so let's verify it's not root:
if [ "$CURRENT_USER" = "root" ]; then
  echo "No non-root user is logged in. Skipping Dock pin and default browser."
  exit 0
fi

# Get that user’s numeric UID
USER_ID=$(id -u "$CURRENT_USER")

##################################################################
# 3) Pin Chrome to the Dock for the logged-in user
##################################################################
# We must run `defaults write ...` in the user's context.
# We'll do that with `sudo -u <user>` to write to their ~/Library/Preferences.
sudo -u "$CURRENT_USER" defaults write com.apple.dock persistent-apps -array-add \
  '{tile-data={file-data={_CFURLString="/Applications/Google Chrome.app";_CFURLStringType=0;};}; tile-type="file-tile";}'

# Restart the Dock for that user
sudo -u "$CURRENT_USER" killall Dock 2>/dev/null || true

##################################################################
# 4) Attempt to set Chrome as the default browser
##################################################################
# In modern macOS, setting a default browser can require user interaction.
# We can still *trigger* it in the user session, using launchctl asuser.
launchctl asuser "$USER_ID" open -b com.google.Chrome --args --make-default-browser

echo "Google Chrome installed and pinned to Dock. Attempted to set as default."
exit 0
