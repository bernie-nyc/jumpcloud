curl -o /tmp/GoogleChrome.dmg https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg && \
hdiutil attach /tmp/GoogleChrome.dmg -nobrowse && \
sudo cp -R "/Volumes/Google Chrome/Google Chrome.app" /Applications/ && \
hdiutil detach "/Volumes/Google Chrome" && \
rm /tmp/GoogleChrome.dmg
