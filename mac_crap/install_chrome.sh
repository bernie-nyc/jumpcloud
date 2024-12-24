# Download the Google Chrome DMG
curl -LO https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg

# Mount the DMG
hdiutil attach googlechrome.dmg

# Copy the app into the Applications folder
cp -r "/Volumes/Google Chrome/Google Chrome.app" /Applications/

# Unmount the DMG
hdiutil detach "/Volumes/Google Chrome"

# Pin Google Chrome to the Dock
defaults write com.apple.dock persistent-apps -array-add \
  '{tile-data={file-data={_CFURLString="/Applications/Google Chrome.app";_CFURLStringType=0;};}; tile-type="file-tile";}'

# Restart the Dock so changes take effect
killall Dock

# Attempt to set Google Chrome as the default browser
# (This may require user confirmation in newer versions of macOS)
open -a "Google Chrome" --args --make-default-browser

echo "Google Chrome has been installed, pinned to the Dock, and set as default (if confirmed)!"
