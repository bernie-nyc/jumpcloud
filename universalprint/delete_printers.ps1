# Define the patterns to match printers to delete
$printerPatterns = 'NYC|MMS|MLS|WMS|WLS'

# Get mapped printers matching the patterns
Get-Printer | Where-Object {
    $_.Type -eq 'Connection' -and $_.Name -match $printerPatterns
} | ForEach-Object {
    try {
        Remove-Printer -Name $_.Name -Confirm:$false -ErrorAction Stop
        Write-Host "Removed printer: $($_.Name)" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to remove printer: $($_.Name). $_"
    }
}
