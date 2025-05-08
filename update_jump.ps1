# JumpCloud Agent Update Script

# Set variables
$installerUrl = "https://assets.jumpcloud.com/production/jumpcloud-agent.msi"
$tempInstaller = "$env:TEMP\jumpcloud-agent.msi"

# Download the latest JumpCloud agent installer
try {
    Invoke-WebRequest -Uri $installerUrl -OutFile $tempInstaller -ErrorAction Stop
} catch {
    Write-Error "Failed to download JumpCloud installer: $_"
    exit 1
}

# Run silent repair install to update the agent
try {
    Start-Process "msiexec.exe" -ArgumentList "/i `"$tempInstaller`" /qn REINSTALL=ALL REINSTALLMODE=vomus" -Wait -ErrorAction Stop
} catch {
    Write-Error "Failed to install JumpCloud agent: $_"
    exit 2
}

# Clean up the installer
try {
    Remove-Item $tempInstaller -Force -ErrorAction Stop
} catch {
    Write-Warning "Failed to remove installer: $_"
}

# Output current version for verification
try {
    $version = Get-ItemProperty -Path "HKLM:\Software\JumpCloud" -Name "Version" -ErrorAction Stop
    Write-Output "JumpCloud Agent Version: $($version.Version)"
} catch {
    Write-Warning "Unable to retrieve agent version from registry."
}
