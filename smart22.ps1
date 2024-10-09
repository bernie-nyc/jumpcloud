 # CurrentUser Registry Settings
 
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# If Nuget is not installed, go ahead and install it
$PkgProvider = Get-PackageProvider
If ("Nuget" -notin $PkgProvider.Name){
    Install-PackageProvider -Name NuGet -Force
}

# If PSModule RunAsUser is not installed, install it
if ( -not (get-installedModule "RunAsUser" -ErrorAction SilentlyContinue)) {
    install-module RunAsUser -force
}

$Command = {
try {
#Disabled run once per Bernie's request
#$CommandVersion="TWS-SMARTNotebook.txt"
#$UserPath=$env:USERPROFILE
#$FileName = $UserPath+"\"+$CommandVersion
 
# $ErrorActionPreference = "Stop"
 
# If file exists, you can skip this program and exit. These settings have already been applied
#If (Test-Path -Path $FileName ) {
#    Write-Host ("This file was written at`n"+(Get-Content $FileName) +"`nExiting.")
#    Exit
#}

$settings=. {
# Turn off Windows Spotlight collection on desktop - "Spotlight collection" will not be available as an option in Personalization settings.
New-Object psobject -Property (@{
    "Path" = "Software\SMART Technologies\Notebook Software"
    "Value" = "BanffExe"
    "Name"	= "DefaultNotebook"
})} | Group Path
 
foreach($setting in $settings){
    $registry = [Microsoft.Win32.Registry]:: CurrentUser.OpenSubKey($setting.Name, $true)
    if ($null -eq $registry) {
        $registry = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($setting.Name, $true)
    }
    $setting.Group | %{
        $registry.SetValue($_.name, $_.value)
        write-host "Set $($_.name) registry key"
    }
    $registry.Dispose()
}
#Add-Content -Path $FileName -Value (Get-Date)
} catch { write-host "Error setting registry keys" }
}

# assigning to null to suppress the PID from joining the results
$null = invoke-ascurrentuser -scriptblock $Command

    
