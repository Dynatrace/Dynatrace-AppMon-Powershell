[CmdletBinding()]
param(
	[Parameter(Mandatory=$True)]
	[string]$InstallPath,
	
	[Switch]$Use64Bit
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

    "Restart IIS"
    Wait-For "iisreset"
    iex "net start w3svc"
}
else
{
    "IIS Agent module already added - installation skipped."
}

