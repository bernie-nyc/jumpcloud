# Ensure script runs with elevated privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "Script must be run as Administrator"
    exit 1
}

# Install PSWindowsUpdate module if not already installed
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Install-PackageProvider -Name NuGet -Force
    Install-Module -Name PSWindowsUpdate -Force
}

# Import the module
Import-Module PSWindowsUpdate

# Scan for and install all available updates silently
Get-WindowsUpdate -AcceptAll -Install -AutoReboot:$false -ForceDownload -IgnoreReboot

# Wait briefly to ensure updates finalize
Start-Sleep -Seconds 30

# Hard reboot after update process
shutdown /r /f /t 0
