# Consolidated ECSM-CSUA Uninstall and MSI Reg Cleanup
# Log file for errors
$logFile = "C:\tws\exclaimer_script_errors.log"

function LogError($message) {
    "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) - ERROR: $message" | Out-File -FilePath $logFile -Append
}

# Ensure the log directory exists
if (-not (Test-Path -Path "C:\tws")) {
    New-Item -ItemType Directory -Path "C:\tws" -Force
}

# Uninstall ECSM-CSUA
try {
    # Your Uninstall script content
    # Replace this comment with actual uninstall commands from ecsm-CSUA-Uninstall.ps1

    Write-Output "ECSM-CSUA uninstall script executed successfully."
}
catch {
    LogError "Failed to uninstall ECSM-CSUA: $_"
}

# MSI Registry Cleanup
try {
    # Your MSI Registry Cleanup script content
    # Replace this comment with actual registry cleanup commands from ecsm-CSUA-MSI-Reg-Cleanup.ps1

    Write-Output "MSI Registry Cleanup executed successfully."
}
catch {
    LogError "Failed during MSI Registry cleanup: $_"
}

Write-Output "Script execution completed."
