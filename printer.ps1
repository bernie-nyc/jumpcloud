# Define variables
#Name of the printer, as the user will see it
$printerName = "Division Abbreviation - Physical Location - Brand and Model"
#IP Address of the Printer
$printerIP = "ipv4 address"
#Name of the zip file that will be downloaded from source
$driverName = "somewindowsfilename"
#name of the driver, windows name
$printDriverName = "get this from a manual windows install"
#location that the driver will get downloaded to
$driverZipPath = "C:\Drivers\Printers\$driverName.zip"
#location the driver will get extracted to, after download
$driverExtractPath = "C:\Drivers\Printers\$driverName"
#the source file of the driver that needs to be downloaded. If this is a widespread driver, talk to CTO to get it uploaded
$driverURL = "https://thewindwardschool.io/winpatch/Kxv4Driver_signed.zip"
#look for the inf file that windows needs to map the printer, once the downloaded file is extracted
$infFilePath = Get-ChildItem -Path $driverExtractPath -Recurse -Filter oemsetup.inf | Select-Object -First 1

#getting to work - this process may take anywhere from 7-10 minutes, depending on driver size, and bandwidth/connectivity
# Printer port configuration variables
$portName = "IP_$printerIP"
$portNumber = 9100   # Default port number for Raw protocol 9100, for LPR protocol 515
$lprQueueName = ""   # Leave empty if not using LPR
 
#Separator Page File Locaiton -driver must be PCL for this to work, otherwise it will break printing. If driver is not PCL, comment next line out
$separatorPageFile = "C:\Windows\System32\pcl.sep"

# Function to check if the printer already exists
function PrinterExists {
    $printer = Get-Printer -Name $printerName -ErrorAction SilentlyContinue
    if ($printer) {
        if(($printer.DriverName) -eq $printDriverName) {
        	return $true
       } else {
		Write-Host "Printer $printerName already exists, but has incorrect print driver. Removing printer and reinstalling correct driver."
       	Remove-Printer -Name $printerName -ErrorAction SilentlyContinue
        return $false
       }
    } else {
        return $false
    }
}
 
# Check if the printer is already installed
if (PrinterExists) {
    Write-Host "Printer $printerName already exists. Exiting script."
    exit
}
 
# Check if the driver zip file exists locally
if (!(Test-Path $driverZipPath)) {
    if(!(Test-Path "C:\Drivers\Printers")) { mkdir C:\Drivers\Printers }
    Write-Host "Driver zip file not found locally. Downloading from $driverURL..."
	Invoke-WebRequest -Uri $driverURL -OutFile $driverZipPath
    sleep 10
}
 
# Unpack the driver if it hasn't been unpacked yet
if (!(Test-Path $driverExtractPath)) {
    Write-Host "Unpacking the driver zip file..."
    Expand-Archive -Path $driverZipPath -DestinationPath $driverExtractPath -Force
}
 
# Check if the .inf file exists in the extracted folder
if (!(Test-Path $infFilePath)) {
    Write-Host "Driver .inf file not found. Trying to extract again..."
    Expand-Archive -Path $driverZipPath -DestinationPath $driverExtractPath -Force
}
 
# Install the printer driver
if (!((Get-PrinterDriver | ? { $_.Name -eq $printDriverName }).name -gt 0)) {
Write-Host "Installing printer driver..."
Invoke-Expression "pnputil.exe -a ""$($infFilePath)"""
Add-PrinterDriver -Name $printDriverName
}
  
# Add the printer port with specified protocol and port number
if (!(Get-PrinterPort -name $portName -ErrorAction SilentlyContinue)) {
	Write-Host "Adding printer port..."
	if (!($lprQueueName)) {
		# Add Raw protocol port
		Add-PrinterPort -Name $portName -PrinterHostAddress $printerIP -PortNumber $portNumber
	} else {
		# Add LPR protocol port
		Add-PrinterPort -Name $portName -PrinterHostAddress $printerIP -PortNumber $portNumber -LprQueue $lprQueueName
	}
} else { Write-Host "Printer port exists, skipping..." }
 
# Install the printer
Write-Host "Adding printer..."
if ($separatorPageFile) {
  Add-Printer -Name $printerName -DriverName $printDriverName -PortName $portName -SeparatorPageFile $separatorPageFile
  Write-Host "Printer $printerName installed and configured successfully."
} else {
  Add-Printer -Name $printerName -DriverName $printDriverName -PortName $portName
  Write-Host "Printer $printerName installed and configured successfully."
}
 
exit
