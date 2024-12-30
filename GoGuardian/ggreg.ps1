# PowerShell Script to Configure Registry Keys for GoGuardian App

# Append domain to the local username and store as a variable
$localUsername = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$updatedUsername = "$localUsername@thewindwardschool.org"

# Set LicenseTag Registry Key
New-Item -Path "HKLM:\SOFTWARE\Policies\GoGuardian" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\GoGuardian" -Name "LicenseTag" -Value "<Your_License_App_ID>"

# Minimize The GoGuardian App to System Tray on Startup
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\GoGuardian" -Name "StartMinimizedToSystemTray" -Value "true"

# Prevent Users from Changing Proxy Settings
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Control Panel" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Control Panel" -Name "Proxy" -Type DWord -Value 1

# Enable Single Sign-On (Optional)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\GoGuardian" -Name "IdentitySources" -Value "NONE"

# Hardcode a Generic User Account to Sign in (Optional)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\GoGuardian" -Name "UserEmail" -Value "$updatedUsername"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\GoGuardian" -Name "UserName" -Value "$updatedUsername"

# Disable Ephemeral Mode in Microsoft Edge for Shared Devices
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "ForceEphemeralProfiles" -Type DWord -Value 1

# Turn Off Ephemeral Mode in Google Chrome for Shared Devices
New-Item -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Name "ForceEphemeralProfiles" -Type DWord -Value 1

Write-Output "Registry keys for GoGuardian App have been configured successfully."
