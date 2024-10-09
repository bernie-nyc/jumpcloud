#Create/Update Web Shortcut

#Variables
##Shortcut File Path
#$desktop = [System.Environment]::GetFolderPath('Desktop')
$desktop = [System.Environment]::GetFolderPath('CommonDesktopDirectory')
##Shortcut File Name
$shortcut_filename = "The Windward School.lnk"
##Shortcut Icon File
$shortcut_url_ico_file = "https://tws-mdm-filestore.s3.amazonaws.com/tws_favicon.ico"
$shortcut_ico_file = "tws_favicon.ico"
$shortcut_ico_path = "C:\Resources\"
##Shortcut Target Location/URL
$shortcut_targetpath = "https://www.thewindwardschool.org/"
##Current Computer's name
$computername = gc env:computername

#Functions 
function CreateShortcut {
 checkIcon
 try{ 
	 $shell = New-Object -ComObject WScript.Shell
	 $shortcut = $shell.CreateShortcut("$($desktop)\$($shortcut_filename)")
	 $shortcut.IconLocation = "$($shortcut_ico_path)$($shortcut_ico_file)"
	 $shortcut.TargetPath = $shortcut_targetpath
	 $shortcut.Save()
	 write-host "Created shortcut" 
 } catch { write-host "Error creating shortcut" }
}

function UpdateShortcut {
 checkIcon
 try {
	 $shell = New-Object -ComObject WScript.Shell
	 $shortcut = $shell.CreateShortcut("$($desktop)\$($shortcut_filename)")
	 if ($shortcut.targetpath -ne $shortcut_targetpath ) {
	  #write-host "Shortcut found and target ("$shortcut.targetpath") out of date - Updating Shortcut`r`r" 
	  $shortcut.IconLocation = "$($shortcut_ico_path)$($shortcut_ico_file)"
	  $shortcut.TargetPath = $shortcut_targetpath
	  $shortcut.Save()
	  write-host "Updated shortcut: $($desktop)\$($shortcut_filename)"
	 }
 } catch { write-host "Error updating shortcut" }
}

function RemoveShortcut {
 try {
	 #write-host "Shortcut found and target ("$shortcut.targetpath") - Removing Shortcut`r`r" 
	 Remove-Item "$($desktop)\$($shortcut_filename)"
 } catch { write-host "Error removing shortcut" }
}

function checkIcon {
	try {
		if (!(Test-Path "$($shortcut_ico_path)")) {
			mkdir $shortcut_ico_path
			write-host "Created shortcut ico path: $($shortcut_ico_path)"
		}
		if (!(Test-Path "$($shortcut_ico_path)$($shortcut_ico_file)")) {
			[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
			Invoke-WebRequest -Uri $shortcut_url_ico_file -OutFile "$($shortcut_ico_path)$($shortcut_ico_file)"
			write-host "Downloaded icon file: $($shortcut_ico_path)$($shortcut_ico_file)"
		}
	} catch { write-host "Error creating icon file" }
}

#Main Function
##If file exists, check the existing file. Else, create a file.

if ( Test-Path "$($desktop)\$($shortcut_filename)" ) {
 UpdateShortcut
 #RemoveShortcut
} else {
 CreateShortcut 
}

