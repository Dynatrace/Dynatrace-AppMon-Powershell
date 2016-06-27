<#
.SYNOPSIS
    Installs Dynatrace agents in Microsoft Azure Cloud-Service WebRole. 
.DESCRIPTION
    Reads configuration from RoleEnvironemnt: 
    DTCollectorHost        ... [required] <HostnameOrIP>[:Port] 
    DTInstaller            ... [required] Name of the Dynatrace agent MSI-Installer file deployed with the application.
    DTInstallPath          ... [optional] Path where Dynatrace should be installed. Default: %RoleRoot%\sitesroot\0\App_Data\Dynatrace
    DTWebserverAgentName   ... [optional] Default: IIS
    DTDotNETAgentName      ... [optional] Default: ASP.NET
    DTUse64Bit             ... [optional] Default: True
.PARAMETER InstallerPath
	Path to the installer, either relative (from script root) or absolute.        
#>
[CmdletBinding()]
param(
	[string]$InstallerPath 
)

Import-Module "../modules/Util" 
Import-Module "../modules/InstallWebserverAgent" 
Import-Module "../modules/InstallDotNETAgent" 
Import-Module "../modules/WindowsAgentSetup" 
Import-Module "../modules/AzureCloudServiceAgentSetup" 

if ($InstallerPath.Length -gt 0)
{
	"Switching ScriptRoot '$InstallerPath'"
	Push-Location
		"$PSScriptRoot"
		Set-Location -Path $InstallerPath
		Install-DynatraceInWebRole
	Pop-Location
	"ScriptRoot restored."
	"$PSScriptRoot"
}
else
{
	Install-DynatraceInWebRole
}

