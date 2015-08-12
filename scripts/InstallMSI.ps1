[CmdletBinding()]
param(
	[Parameter(Mandatory=$True)]
	[string]$InstallPath,
	
	[Parameter(Mandatory=$True)]
	[string]$Installer
)

Import-Module "../modules/Util"

Get-FilesFromMSI -Installer $Installer -InstallPath $InstallPath