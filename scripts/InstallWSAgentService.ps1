[CmdletBinding()]
param(
	[Parameter(Mandatory=$True)]
	[string]$InstallPath,
	
	[Parameter(Mandatory=$True)]
	[string]$JSONConfig # Sample: { Name: "IIS", Server: "localhost", Loglevel: "info" }
)

Import-Module "../modules/Util" 
Import-Module "../modules/InstallWebserverAgent" -Verbose

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
     
    "Checking configuration changes..."    
	foreach ($e in $hashTable.GetEnumerator()) 
    {
		 "Validate key '$($e.Name)'..."
         if ($iniContent[$e.Name] -ne $e.Value)
         {
            "Failed."
            Set-WebserverAgentConfiguration $InstallPath $hashTable
            "Restarting Webserver Agent..."
            Restart-Service $ServiceName
            break;
         }
         else
         {
            "Ok."
         }
	}

    
}

