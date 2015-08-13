<#
.SYNOPSIS
    Extracts files from an MSI-installer without executing the installer.
.DESCRIPTION
    Doesn't extract files if targetfolder already exists. Wait's until all files are extracted.
.PARAMETER Installer
    Installer file
.PARAMETER InstallPath
    Targetfolder 
        
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory=$True)]
	[string]$InstallPath,
	
	[Parameter(Mandatory=$True)]
	[string]$Installer
)

Import-Module "../modules/Util"

Get-FilesFromMSI -Installer $Installer -InstallPath $InstallPath