temp=$TMPDIR$(uuidgen)
mkdir -p $temp/mount
curl https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg > $temp/1.dmg
yes | hdiutil attach -noverify -nobrowse -mountpoint $temp/mount $temp/1.dmg
cp -r $temp/mount/*.app /Applications
hdiutil detach $temp/mount
rm -r $temp
dbc
defaults write com.apple.dock persistent-apps -array-add '{\"tile-data\":{\"file-data\":{\"path\":\"/Applications/Google Chrome.app\"}}}' && killall Dock";
