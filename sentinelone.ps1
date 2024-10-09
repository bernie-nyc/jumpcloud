$siteToken="eyJ1cmwiOiAiaHR0cHM6Ly91c2VhMS0wMTYuc2VudGluZWxvbmUubmV0IiwgInNpdGVfa2V5IjogIjNlMjNkYzQwN2UxYjNjMmYifQ=="
$installerURL="https://cwa.connectwise.com/tools/sentinelone/SentinelOneAgent-Windows_64bit.exe"

############### Do Not Edit Below This Line ###############

$installerTempLocation="C:\Windows\Temp\SentinelOneAgentInstaller.exe"

if (Get-Service "SentinelOneService" -ErrorAction SilentlyContinue) {
    Write-Host "Sentinel One Agent already installed, nothing to do."
    exit 0
}
Write-Host "Sentinel One Agent not installed."

Write-Host "Downloading Sentinel One Agent installer now."
try {
    Invoke-WebRequest -Uri $installerURL -OutFile $installerTempLocation
}
catch {
    Write-Error "Unable to download Sentinel One Agent installer."
    exit 1
}
Write-Host "Finished downloading Sentinel One Agent installer."

Write-Host "Installing Sentinel One Agent now, this may take a few minutes."
try {
    ."$installerTempLocation" --dont_fail_on_config_preserving_failures -t $siteToken
}
catch {
    Write-Error "Failed to run Sentinel One Agent installer."
    exit 1
}
Write-Host "Sentinel One Agent installer returned $($installerProcess.ExitCode)."

exit $installerProcess.ExitCode
