<#
.SYNOPSIS
    Enables Dynatrace Webserver (slave) agent in IIS as a native module named 'Dynatrace Webserver Agent'
.DESCRIPTION
    Checks if module is already installed. If 
.PARAMETER InstallPath
    "root" directory of the Dynatrace agent's. Agent DLL's are referenced relative from this directory <InstallPath>\agent\lib\dtagent.dll
.PARAMETER -Use64Bit
    Switch to force usage of 64-bit agent
.Parameter -ForceIISReset
    Switch to force restart of IIS (only if module hasn't already been installed) 
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory=$True)]
	[string]$InstallPath,
	
	[Switch]$Use64Bit, 

    [Switch]$ForceIISReset
)

Set-ExecutionPolicy Unrestricted

Import-Module "../modules/Util"
Import-Module "../modules/InstallWebserverAgent"

$appcmd = [System.Environment]::GetEnvironmentVariable("windir") + "\system32\inetsrv\appcmd.exe"

"Checking IIS module configuration..."
$xmlStr = iex "$appcmd LIST modules /xml"  
$xmlObj = [xml]$xmlStr 
$loadedModules = $xmlObj.SelectNodes("//appcmd/MODULE[contains(@MODULE.NAME,'Dynatrace')]") | select MODULE.NAME | Select-Object -ExpandProperty 'MODULE.NAME'
if ($loadedModules.Length -eq 0)
{
    "No IIS Agent module found."
    Install-WebserverAgentModuleIIS $InstallPath $Use64Bit 

    if ($ForceIISReset)
    {
        "Restart IIS"
        Wait-For "iisreset"
        iex "net start w3svc"
    }
}
else
{
    "IIS Agent module already added - installation skipped."
}

