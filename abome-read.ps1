# Define variables
$softwareEXE = "AcroRdrDC_en_US.exe"
$softwarePath = "C:\Software\AcroRdrDC\$softwareEXE"
$softwareArguments = "/sAll"
$softwareExtractPath = "C:\Software\AcroRdrDC\"
#URL Pulled from https://get.adobe.com/reader/download site code
$softwareURL = "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2400221005/AcroRdrDC2400221005_en_US.exe"


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

