# Sanitize printer name immediately to prevent colons or whitespace issues
$printerName = $printerName -replace '^[:\s]+', ''

# --------------------
# Driver setup variables
# --------------------
$driverName = "KM-UniversalPCL"
$printDriverName = "KONICA MINOLTA Universal PCL"
$driverZipPath = "C:\Drivers\Printers\$driverName.zip"
$driverExtractPath = "C:\Drivers\Printers\$driverName"
$driverURL = "https://thewindwardschool.io/winpatch/KM_UniversalDriver_PCL6_398200MU.zip"
$infFilePath = "C:\Drivers\Printers\KM-UniversalPCL\driver\win_x64\KOAWUJ__.INF"
$expectedFileSize = 49027014

# --------------------
# Port configuration
# --------------------
$portName = "IP_$printerIP"
$portNumber = 9100
$lprQueueName = ""

# --------------------
# Separator Page (Optional)
# --------------------
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
    Write-Host "Printer $printerName already exists. Exiting script."
    exit
}

# --------------------
# Validate driver ZIP file
# --------------------
if (Test-Path $driverZipPath) {
    $actualSize = (Get-Item $driverZipPath).Length
    if ($actualSize -ne $expectedFileSize) {
        Write-Host "File size mismatch detected. Deleting incorrect driver file and folder."
        Remove-Item $driverZipPath -Force
        if (Test-Path $driverExtractPath) { Remove-Item $driverExtractPath -Force -Recurse }
    }
}

# --------------------
# Download the driver ZIP file
# --------------------
if (!(Test-Path $driverZipPath)) {
    if (!(Test-Path "C:\Drivers\Printers")) { mkdir "C:\Drivers\Printers" }
    Write-Host "Downloading driver zip file from $driverURL..."
    Invoke-WebRequest -Uri $driverURL -OutFile $driverZipPath
    Start-Sleep -Seconds 10
}

# --------------------
# Extract the driver files
# --------------------
if (!(Test-Path $driverExtractPath)) {
    Write-Host "Unpacking the driver zip file..."
    Expand-Archive -Path $driverZipPath -DestinationPath $driverExtractPath -Force
}

# --------------------
# Confirm INF file exists
# --------------------
if (!(Test-Path $infFilePath)) {
    Write-Host "Driver .inf file not found. Extracting again..."
    Expand-Archive -Path $driverZipPath -DestinationPath $driverExtractPath -Force
}

# --------------------
# Install the printer driver
# --------------------
if (!((Get-PrinterDriver | Where-Object { $_.Name -eq $printDriverName }).name -gt 0)) {
    Write-Host "Installing printer driver..."
    pnputil.exe /add-driver "$infFilePath" /install
    Add-PrinterDriver -Name $printDriverName
    Start-Sleep -Seconds 3
}

# --------------------
# Add the printer port
# --------------------
if (!(Get-PrinterPort -Name $portName -ErrorAction SilentlyContinue)) {
    Write-Host "Adding printer port..."
    if (!$lprQueueName) {
        Add-PrinterPort -Name $portName -PrinterHostAddress $printerIP -PortNumber $portNumber
    } else {
        Add-PrinterPort -Name $portName -PrinterHostAddress $printerIP -PortNumber $portNumber -LprQueue $lprQueueName
    }
} else {
    # Port exists: verify printer driver
    Write-Host "Printer port exists. Verifying printer driver..."
    $existingPrinter = Get-Printer -Name $printerName -ErrorAction SilentlyContinue
    if ($existingPrinter -and $existingPrinter.DriverName -ne $printDriverName) {
        Write-Host "Existing printer has wrong driver. Reinstalling printer with correct driver..."
        Remove-Printer -Name $printerName -ErrorAction SilentlyContinue
    } elseif ($existingPrinter) {
        Write-Host "Printer port and driver configuration are correct."
        Write-Host "No further action required. Exiting script."
        exit
    }
}

# --------------------
# Dump existing printers
# --------------------
Write-Host "Listing all existing printers:"
Get-Printer | ForEach-Object { Write-Host " - [$($_.Name)]" }

# --------------------
# Remove all printers matching this name (colon or weird prefix variants too)
# --------------------
Get-Printer | Where-Object {
    $_.Name -replace '^[^A-Za-z0-9]+' -eq $printerName -or $_.Name -like "*$printerName*"
} | ForEach-Object {
    Write-Host "Removing conflicting printer: [$($_.Name)]"
    try {
        Remove-Printer -Name $_.Name -ErrorAction Stop
    } catch {
        Write-Warning "Failed to remove printer [$($_.Name)]: $_"
    }
}

# --------------------
# Final printer installation (Add-Printer only)
# --------------------
Write-Host "Adding printer via Add-Printer..."

try {
    if ($separatorPageFile) {
        Add-Printer -Name $printerName -DriverName $printDriverName -PortName $portName -SeparatorPageFile $separatorPageFile
    } else {
        Add-Printer -Name $printerName -DriverName $printDriverName -PortName $portName
    }
    Write-Host "Printer $printerName successfully installed using Add-Printer."
} catch {
    Write-Warning "Failed to install printer: $_"
}

exit
