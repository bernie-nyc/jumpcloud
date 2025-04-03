
# Sanitize printer name immediately to prevent colons or whitespace issues
$printerName = $printerName -replace '^[:\s]+', ''

# --------------------
# Driver setup variables
# --------------------
$driverName = "RICOH_PCL6_UniversalDriver"
$printDriverName = "RICOH PCL6 UniversalDriver V4.41"
$driverZipPath = "C:\Drivers\Printers\$driverName.zip"
$driverExtractPath = "C:\Drivers\Printers\$driverName"
$driverURL = "https://thewindwardschool.io/winpatch/RicohPCL6.zip"
$infFilePath = "C:\Drivers\Printers\RICOH_PCL6_UniversalDriver\oemsetup.inf"

 
# Printer port configuration variables
$portName = "IP_$printerIP"
$portNumber = 9100   # Default port number for Raw protocol 9100, for LPR protocol 515
$lprQueueName = ""   # Leave empty if not using LPR
 
#Separator Page File Locaiton - leave blank / comment out if not using
$separatorPageFile = "C:\Windows\System32\pcl.sep"

# --------------------
# Function: Check if printer exists and has correct driver
# --------------------
function PrinterExists {
    $printer = Get-Printer -Name $printerName -ErrorAction SilentlyContinue
    if ($printer) {
        if (($printer.DriverName) -eq $printDriverName) {
            return $true
        } else {
            Write-Host "Printer $printerName already exists, but has incorrect print driver. Removing printer."
            Remove-Printer -Name $printerName -ErrorAction SilentlyContinue
            return $false
        }
    } else {
        return $false
    }
}

# --------------------
# Exit early if correct printer already exists
# --------------------
if (PrinterExists) {
    Write-Host "Printer $printerName already exists with correct driver. Exiting script."
    exit
}

# --------------------
# Ensure driver zip file is available
# --------------------
if (!(Test-Path $driverZipPath)) {
    Write-Host "Driver zip not found, downloading..."
    Invoke-WebRequest -Uri $driverURL -OutFile $driverZipPath
}

# --------------------
# Extract driver if not already extracted
# --------------------
if (!(Test-Path $driverExtractPath)) {
    Expand-Archive -LiteralPath $driverZipPath -DestinationPath $driverExtractPath
}

# --------------------
# Add printer port if not exists
# --------------------
if (-not (Get-PrinterPort -Name $portName -ErrorAction SilentlyContinue)) {
    Add-PrinterPort -Name $portName -PrinterHostAddress $printerIP -PortNumber $portNumber
}

# --------------------
# Install printer driver if not present
# --------------------
if (-not (Get-PrinterDriver -Name $printDriverName -ErrorAction SilentlyContinue)) {
    pnputil.exe /add-driver $infFilePath /install
}

# --------------------
# Add printer
# --------------------
Add-Printer -Name $printerName -DriverName $printDriverName -PortName $portName

# --------------------
# Set separator page if defined
# --------------------
if ($separatorPageFile -and (Test-Path $separatorPageFile)) {
    Set-Printer -Name $printerName -SeparatorPageFile $separatorPageFile
}

Write-Host "Printer installation complete."
