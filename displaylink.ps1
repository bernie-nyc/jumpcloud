# ------------------------------------------------------------
# PowerShell script to download, verify, and silently install
# DisplayLink USB driver executable
# ------------------------------------------------------------

# --------------------
# Define essential variables for script execution
# --------------------
$url = "https://thewindwardschool.io/winpatch/DisplayLinkUSB_1.6 M1.exe" # URL from which the installer is downloaded
$destination = "C:\TWS"  # Directory where the installer will be stored
$installerName = "DisplayLinkUSB_1.6 M1.exe" # Name of the installer executable
$installerPath = Join-Path -Path $destination -ChildPath $installerName # Full path of installer
$expectedFileSize = 68921784 # Expected file size of the installer in bytes (used for verification)

# --------------------
# Ensure the destination directory exists before downloading
# --------------------
if (-Not (Test-Path -Path $destination)) {
    Write-Host "Creating directory: $destination"
    # Create the destination directory if it does not exist
    New-Item -Path $destination -ItemType Directory | Out-Null
}

# --------------------
# Function: Verify-FileSize
# Description: Verifies if a file exists and matches the expected size.
# Parameters:
#   - $filePath: Path to the file to verify
#   - $expectedSize: Expected file size in bytes
# Returns:
#   - $true if file exists and size matches, $false otherwise
# --------------------
function Verify-FileSize($filePath, $expectedSize) {
    # Check if the specified file exists at the given path
    if (Test-Path -Path $filePath) {
        # Retrieve actual file size
        $actualSize = (Get-Item -Path $filePath).Length
        # Compare actual size to expected size
        if ($actualSize -eq $expectedSize) {
            Write-Host "File verified successfully. Size matches exactly: $actualSize bytes."
            return $true
        } else {
            Write-Warning "File size mismatch detected: expected $expectedSize bytes, found $actualSize bytes."
            return $false
        }
    } else {
        Write-Warning "File does not exist at path: $filePath"
        return $false
    }
}

# --------------------
# Check existence and integrity of installer; download if necessary
# --------------------
# Initial verification of the file
if (-Not (Verify-FileSize -filePath $installerPath -expectedSize $expectedFileSize)) {
    Write-Host "Downloading DisplayLink installer from $url"
    # Download the installer file using Invoke-WebRequest
    Invoke-WebRequest -Uri $url -OutFile $installerPath -UseBasicParsing

    # Verify file again after download
    if (-Not (Verify-FileSize -filePath $installerPath -expectedSize $expectedFileSize)) {
        # Throw an error and terminate script if verification fails after download
        throw "Downloaded file verification failed. Installation aborted."
    }
}

# --------------------
# Execute the installer silently without user interaction or forced restart
# --------------------
Write-Host "Starting silent installation of DisplayLink driver."
Start-Process -FilePath $installerPath -ArgumentList "-silent -suppressUpToDateInfo" -Wait

# Inform user that installation has completed successfully
Write-Host "DisplayLink installation completed successfully."
