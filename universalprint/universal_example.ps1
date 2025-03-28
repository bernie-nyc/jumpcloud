# Define variables
# What is the name of the printer, as it will show up on the user's machine?
# it should follow the convention NYC|WMS|WLS - Floor - Printer Common Name
$printerName = "NYC-4th Fl MLS-Library"
# What is the IP address of that printer?
$printerIP = "192.168.32.74"

# pull down and execute the universal print section
# the path for Konica is: https://thewindwardschool.io/winpatch/printer/konica_universal.ps1
# the path for Ricoh is: https://thewindwardschool.io/winpatch/printer/ricoh_universal.ps1

try {
    # Use Invoke-RestMethod to auto-convert response correctly
    $scriptContent = Invoke-RestMethod -Uri "https://thewindwardschool.io/winpatch/printer/konica_universal.ps1" -UseBasicParsing

    # Optional: Confirm content is text before execution (for safety/debugging)
    if ($scriptContent -is [string] -and $scriptContent.Length -gt 0) {
        Invoke-Expression $scriptContent
        Write-Host "Script executed successfully."
    }
    else {
        throw "Downloaded content is not valid PowerShell script text."
    }
}
catch {
    Write-Error "Failed to download or execute script snippet: $_"
}
