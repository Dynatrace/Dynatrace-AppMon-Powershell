<#
.SYNOPSIS
    Installs Dynatrace (master) Webserver Agent as Windows Service. 
.DESCRIPTION
    If service already installed, configuration is updated. If configuration has changed, service will be restarted.
.PARAMETER InstallPath
    "root" directory of the Dynatrace agent's. Configuration is referenced relative from this directory <InstallPath>\agent\conf\dtwsagent.ini
.PARAMETER JSONConfig
    JSON string containing an object with the the configuration. 
    Example:
    '{ "Name": "IIS", "Server": "localhost", "Loglevel": "info" }'
#>

[CmdletBinding()]
param(
	[Parameter(Mandatory=$True)]
	[string]$InstallPath,
	
	[Parameter(Mandatory=$True)]
	[string]$JSONConfig # Sample: { Name: "IIS", Server: "localhost", Loglevel: "info" }
)

Import-Module "../modules/Util" 
Import-Module "../modules/InstallWebserverAgent" 

Set-ExecutionPolicy Unrestricted


$ServiceName = "Dynatrace Webserver Agent"

$cfg = $JSONConfig | ConvertFrom-Json

#convert json object into hashtable
$hashTable = $cfg.psobject.properties | foreach -begin {$h=@{}} -process {$h."$($_.Name)" = $_.Value} -end {$h}
if ((Test-ServiceInstallation $ServiceName) -eq $FALSE)
{
    Set-WebserverAgentConfiguration $InstallPath $hashTable 

    Install-WebserverAgentService $ServiceName $InstallPath 
}
else
{

    $iniContent = Get-IniContent "$InstallPath\agent\conf\dtwsagent.ini"
    
    $configChanged = $FALSE
    "Checking configuration changes..."
	foreach ($e in $hashTable.GetEnumerator()) 
    {
		 "Validate key '$($e.Name)'..."
         if ($iniContent[$e.Name] -ne $e.Value)
         {
            "mismatch."
            Set-WebserverAgentConfiguration $InstallPath $hashTable
            "Restarting Webserver Agent..."
            Restart-Service $ServiceName

            $configChanged = $TRUE
            break;
         }
         else
         {
            "Ok."
         }
	}
    if ($configChanged -eq $FALSE)
    {
        "Resetting" 
    }

    
}

