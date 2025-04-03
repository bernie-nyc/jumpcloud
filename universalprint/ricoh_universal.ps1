import re

# Extracting the Ricoh-specific variables from the original Ricoh script
ricoh_variables_section = re.search(r'(\$driverName.+?\$separatorPageFile\s*=.+?)\n\n', ricoh_script, re.DOTALL).group(1)

# Define the new structured Ricoh script based on the Konica format, keeping Ricoh-specific variables intact
ricoh_updated_script = f"""
# Sanitize printer name immediately to prevent colons or whitespace issues
$printerName = $printerName -replace '^[:\\s]+', ''

# --------------------
# Driver setup variables
# --------------------
{ricoh_variables_section}

# --------------------
# Function: Check if printer exists and has correct driver
# --------------------
function PrinterExists {{
    $printer = Get-Printer -Name $printerName -ErrorAction SilentlyContinue
    if ($printer) {{
        if (($printer.DriverName) -eq $printDriverName) {{
            return $true
        }} else {{
            Write-Host "Printer $printerName already exists, but has incorrect print driver. Removing printer."
            Remove-Printer -Name $printerName -ErrorAction SilentlyContinue
            return $false
        }}
    }} else {{
        return $false
    }}
}}

# --------------------
# Exit early if correct printer already exists
# --------------------
if (PrinterExists) {{
    Write-Host "Printer $printerName already exists with correct driver. Exiting script."
    exit
}}

# --------------------
# Ensure driver zip file is available
# --------------------
if (!(Test-Path $driverZipPath)) {{
    Write-Host "Driver zip not found, downloading..."
    Invoke-WebRequest -Uri $driverURL -OutFile $driverZipPath
}}

# --------------------
# Extract driver if not already extracted
# --------------------
if (!(Test-Path $driverExtractPath)) {{
    Expand-Archive -LiteralPath $driverZipPath -DestinationPath $driverExtractPath
}}

# --------------------
# Add printer port if not exists
# --------------------
if (-not (Get-PrinterPort -Name $portName -ErrorAction SilentlyContinue)) {{
    Add-PrinterPort -Name $portName -PrinterHostAddress $printerIP -PortNumber $portNumber
}}

# --------------------
# Install printer driver if not present
# --------------------
if (-not (Get-PrinterDriver -Name $printDriverName -ErrorAction SilentlyContinue)) {{
    pnputil.exe /add-driver $infFilePath /install
}}

# --------------------
# Add printer
# --------------------
Add-Printer -Name $printerName -DriverName $printDriverName -PortName $portName

# --------------------
# Set separator page if defined
# --------------------
if ($separatorPageFile -and (Test-Path $separatorPageFile)) {{
    Set-Printer -Name $printerName -SeparatorPageFile $separatorPageFile
}}

Write-Host "Printer installation complete."
"""

# Save updated script to a file
updated_ricoh_path = '/mnt/data/ricoh_universal_updated.ps1'
with open(updated_ricoh_path, 'w') as file:
    file.write(ricoh_updated_script)

updated_ricoh_path
