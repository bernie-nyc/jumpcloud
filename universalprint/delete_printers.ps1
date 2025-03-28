# Check if script runs as administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltinRole] "Administrator"))
{
    Write-Warning "This script requires Administrator privileges. Please restart PowerShell as Administrator."
    break
}

# Patterns for printer names to remove
$printerPatterns = 'NYC|MMS|MLS|WMS|WLS'

# Remove matching printers
Get-Printer | Where-Object {
    $_.Name -match $printerPatterns
} | ForEach-Object {
    try {
        Remove-Printer -Name $_.Name -Confirm:$false -ErrorAction Stop
        Write-Host "Removed printer: $($_.Name)" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to remove printer: $($_.Name). $_"
    }
}
