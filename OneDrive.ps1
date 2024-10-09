#Remove old OneDrive

$Processes = Get-Process
If ($Processes.ProcessName -Like "OneDrive") {
    Write-Host OneDrive is Running and will be shutdown
    taskkill /f /im OneDrive.exe
    If (Test-Path C:\Windows\SysWOW64\OneDriveSetup.exe){
        
        Write-Host "OneDrive installation found, OneDrive Personal will be removed"
        C:\Windows\SysWOW64\OneDriveSetup.exe /uninstall
            If (Test-Path C:\Windows\SysWOW64\OneDriveSetup.exe){
        
            Write-Host "OneDrive Machine installation found, OneDrive Machine Install will be installed"
            C:\Windows\SysWOW64\OneDriveSetup.exe /allusers
            }
            Else{
            Write-Host "OneDrive Machine Installation not found"
    }  
    }
    Else{
        Write-Host "OneDrive Personal Installation not found"
    }
}
Else{
    Write-Host OneDrive is not running
           
            If (Test-Path C:\Windows\SysWOW64\OneDriveSetup.exe){
        
            Write-Host "OneDrive Machine installation found, OneDrive Machine Install will be installed"
            C:\Windows\SysWOW64\OneDriveSetup.exe /allusers
            }
            Else{
            Write-Host "OneDrive Machine Installation not found"
            }
}

try { Invoke-Expression "winget uninstall OneDriveSetup.exe" } catch { }

#Download and install the new OneDriveSetup.exe

# Define variables
$softwareEXE = "OneDriveSetup.exe"
$softwarePath = "C:\Software\OneDrive\$softwareEXE"
$softwareArguments = "/allusers"
$softwareExtractPath = "C:\Software\OneDrive\"
$softwareURL = "https://go.microsoft.com/fwlink/p/?LinkId=248256"


# Check if the software file exists locally
if (!(Test-Path $softwarePath)) {
    Write-Host "$($softwareEXE) file not found locally. Downloading from $softwareURL..."
    mkdir $softwareExtractPath
	Invoke-WebRequest -Uri $softwareURL -OutFile $softwarePath
}
 
# Check if the software file exists in the extracted folder
if ((Test-Path $softwarePath)) {
    Write-Host "Installing $softwareEXE..."
    try {
    	        Invoke-Expression "$($softwarePath) $($softwareArguments)"
                exit 0
    	} catch {
    		Write-Error "Failed to run $($softwareEXE)."
                exit 1
    	}
    exit
}

