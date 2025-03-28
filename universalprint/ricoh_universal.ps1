$driverName = "RICOH_PCL6_UniversalDriver"
$printDriverName = "RICOH PCL6 UniversalDriver V4.41"
$driverZipPath = "C:\Drivers\Printers\$driverName.zip"
$driverExtractPath = "C:\Drivers\Printers\$driverName"
$driverURL = "https://thewindwardschool.io/winpatch/RicohPCL6.zip"
$infFilePath = "$driverExtractPath\RicoPCL6\oemsetup.inf"

 
# Printer port configuration variables
$portName = "IP_$printerIP"
$portNumber = 9100   # Default port number for Raw protocol 9100, for LPR protocol 515
$lprQueueName = ""   # Leave empty if not using LPR
 
#Separator Page File Locaiton - leave blank / comment out if not using
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
