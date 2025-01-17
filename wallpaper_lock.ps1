# Set the paths for the wallpaper and lockscreen images
$WallpaperPath = "C:\Wallpapers\MyWallpaper.jpg"
$LockscreenPath = "C:\Wallpapers\MyLockscreen.jpg"

# Set wallpaper for all users
function Set-WallpaperForAllUsers {
    $users = Get-ChildItem "C:\Users\" | Where-Object {$_.PSIsContainer}

    foreach ($user in $users) {
        $userPath = $user.FullName
        $wallpaperDest = Join-Path $userPath "AppData\Roaming\Microsoft\Windows\Themes\TranscodedWallpaper"

        if (Test-Path $wallpaperDest) {
            Copy-Item $WallpaperPath -Destination $wallpaperDest -Force
        }
    }
}

# Set lockscreen for all users
function Set-LockscreenForAllUsers {
    $users = Get-ChildItem "C:\Users\" | Where-Object {$_.PSIsContainer}

    foreach ($user in $users) {
        $userPath = $user.FullName
        $lockscreenDest = Join-Path $userPath "AppData\Local\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets"

        if (Test-Path $lockscreenDest) {
            Copy-Item $LockscreenPath -Destination $lockscreenDest -Force
        }
    }
}

# Change the wallpaper and lockscreen
Set-WallpaperForAllUsers
Set-LockscreenForAllUsers

# Update registry settings (requires administrator privileges)
$regKey = "HKCU:\Control Panel\Desktop"
Set-ItemProperty -Path $regKey -Name "Wallpaper" -Value $WallpaperPath
Set-ItemProperty -Path $regKey -Name "WallpaperStyle" -Value "2" # Stretched
Set-ItemProperty -Path $regKey -Name "TileWallpaper" -Value "0"

# Refresh the desktop and lockscreen
rundll32.exe user32.dll,UpdatePerUserSystemParameters
