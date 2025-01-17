# Specify the path to the directory containing your images
$ImageDirectory = "C:\Path\To\Your\Images"

# Function to set the lock screen image
function Set-LockScreenImage {
    param (
        [string]$ImagePath
    )

    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;

    public class LockScreen {
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    }
"@

    $SPI_SETDESKWALLPAPER = 20
    $SPIF_UPDATEINIFILE = 1
    $SPIF_SENDCHANGE = 2

    [LockScreen]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $ImagePath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE)
}

# Function to set the desktop wallpaper
function Set-DesktopWallpaper {
    param (
        [string]$ImagePath
    )

    Add-Type @"
    using System;
    using System.Runtime.InteropServices;

    public class Wallpaper {
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
    }
"@

    $SPI_SETDESKWALLPAPER = 20
    $SPIF_UPDATEINIFILE = 1
    $SPIF_SENDCHANGE = 2

    [Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $ImagePath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE)
}

# Get all image files from the specified directory
$ImageFiles = Get-ChildItem -Path $ImageDirectory -Include *.jpg, *.jpeg, *.png -File

if ($ImageFiles.Count -eq 0) {
    Write-Host "No images found in the specified directory."
    exit
}

# Loop through the images and set them as wallpapers and lock screen
foreach ($Image in $ImageFiles) {
    Write-Host "Setting wallpaper and lock screen to: $($Image.FullName)"

    # Set the lock screen image
    Set-LockScreenImage -ImagePath $Image.FullName

    # Set the desktop wallpaper
    Set-DesktopWallpaper -ImagePath $Image.FullName

    # Pause for 6000 seconds before changing to the next image
    Start-Sleep -Seconds 6000
}
