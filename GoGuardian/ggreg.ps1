# PowerShell Script to Download, Verify, Install/Repair GoGuardian MSI, and Configure Registry Keys

# Define variables for MSI download
$msiUrl = "https://thewindwardschool.io/winpatch/gg_v1.16.2.msi"
$msiPath = "C:\TWS\gg_v1.16.2.msi"
$expectedFileSize = 26542080 # Replace with the actual MSI file size in bytes
$serviceName = "GoGuardian" # Replace with the actual service name if different

# Function to verify MSI file integrity
function Test-MsiIntegrity {
    param (
        [string]$filePath,
        [int64]$expectedSize
    )

    if (Test-Path -Path $filePath) {
        $actualSize = (Get-Item -Path $filePath).Length
        if ($actualSize -eq $expectedSize) {
            Write-Output "File integrity verified. File size matches: $actualSize bytes."
            return $true
        } else {
            Write-Warning "File size mismatch: Expected $expectedSize bytes, but found $actualSize bytes."
            return $false
        }
    } else {
        Write-Warning "File does not exist at path: $filePath"
        return $false
    }
}

# Ensure the directory exists
if (-Not (Test-Path -Path "C:\TWS")) {
    Write-Output "Creating directory: C:\TWS"
    New-Item -ItemType Directory -Path "C:\TWS" | Out-Null
}

# Logic to verify integrity and conditionally download MSI
if (-Not (Test-MsiIntegrity -filePath $msiPath -expectedSize $expectedFileSize)) {
    Write-Output "Initiating MSI download from URL: $msiUrl"
    Invoke-WebRequest -Uri $msiUrl -OutFile $msiPath -ErrorAction Stop

    # Verify the MSI integrity again after download
    if (-Not (Test-MsiIntegrity -filePath $msiPath -expectedSize $expectedFileSize)) {
        throw "MSI download failed integrity check after download. Aborting operation."
    }
    else {
        Write-Output "MSI file downloaded and verified successfully."
    }
}
else {
    Write-Output "Verified MSI already present, skipping download."
}

# Check if GoGuardian service exists to determine installation or repair
$serviceExists = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($serviceExists) {
    Write-Output "GoGuardian service detected. Initiating silent repair installation..."
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/fa `"$msiPath`" /quiet /norestart" -Wait
    Write-Output "Repair installation completed."
}
else {
    Write-Output "No GoGuardian service detected. Initiating silent installation..."
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$msiPath`" /quiet /norestart" -Wait
    Write-Output "MSI installation completed."
}

# Configure Registry Keys after successful MSI installation/repair
Write-Output "Configuring Registry keys..."

# Append domain to current user's local username
$localUsername = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$updatedUsername = "$localUsername@thewindwardschool.org"

# Registry keys configuration
New-Item -Path "HKLM:\SOFTWARE\Policies\GoGuardian" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\GoGuardian" -Name "LicenseTag" -Value "pjeefinedejhlnbpfmhakiebbmejjeco"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\GoGuardian" -Name "StartMinimizedToSystemTray" -Value "true"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\GoGuardian" -Name "IdentitySources" -Value "NONE"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\GoGuardian" -Name "UserEmail" -Value "$updatedUsername"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\GoGuardian" -Name "UserName" -Value "$updatedUsername"

# Disable Ephemeral Mode for Chrome
New-Item -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Name "ForceEphemeralProfiles" -Type DWord -Value 0

# Disable Ephemeral Mode for Edge
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "ForceEphemeralProfiles" -Type DWord -Value 0

New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Control Panel" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Control Panel" -Name "Proxy" -Type DWord -Value 1

Write-Output "Registry keys configured successfully."
Write-Output "GoGuardian application installation and configuration completed without errors."
