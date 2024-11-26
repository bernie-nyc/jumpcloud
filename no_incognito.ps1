# Block Incognito mode in Chrome
$ChromeRegKey = "HKLM:\SOFTWARE\Policies\Google\Chrome"
$RegName = "IncognitoModeAvailability"
$RegValue = 1

# Check if the key exists, if not, create it
if (!(Test-Path $ChromeRegKey)) {
    New-Item -Path $ChromeRegKey -Force | Out-Null
}

# Set the registry value to disable Incognito mode
New-ItemProperty -Path $ChromeRegKey -Name $RegName -Value $RegValue -PropertyType DWORD -Force | Out-Null

# Block InPrivate browsing in Edge
$EdgeRegKey = "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
$RegName = "InPrivateBrowsingEnabled"
$RegValue = 0

# Check if the key exists, if not, create it
if (!(Test-Path $EdgeRegKey)) {
    New-Item -Path $EdgeRegKey -Force | Out-Null
}

# Set the registry value to disable InPrivate browsing
New-ItemProperty -Path $EdgeRegKey -Name $RegName -Value $RegValue -PropertyType DWORD -Force | Out-Null
