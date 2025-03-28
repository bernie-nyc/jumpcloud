# Self-elevate if not running as admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
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
