#Requires –Modules Util

Function Set-WebserverAgentConfiguration([string]$InstallPath, [PSObject]$Config)
{
<#
.SYNOPSIS
    Writes Dynatrace Webserver Agent configuration in dtwsagent.ini
.PARAMETER InstallPath
    "root" directory of the Dynatrace agent's. Configuration is referenced relative from this directory <InstallPath>\agent\conf\dtwsagent.ini
.PARAMETER Config
    Object containing the configuration. 
    Example:
    @{ Name = 'MyAgent'
       Server = 'localhost'
       Loglevel = 'info' } 
#>
	"Writing Webserver Agent Config..."

	if (!(Test-Path "$InstallPath\agent\conf\")) {
		New-Item -ItemType Directory -Force -Path "$InstallPath\agent\conf\"
	}

	$stream = [System.IO.StreamWriter] "$InstallPath\agent\conf\dtwsagent.ini"
	
	foreach ($e in $Config.GetEnumerator()) {
		"Add $($e.Name): $($e.Value)"
		$stream.WriteLine("$($e.Name) $($e.Value)")	
	}
	$stream.close()
	"Complete."
}

Function Install-WebserverAgentModuleIIS([string]$InstallPath, [Boolean]$Use64Bit)
{
<#
.SYNOPSIS
    Enables Dynatrace Webserver (slave) agent in IIS as a native module named 'Dynatrace Webserver Agent'
.PARAMETER InstallPath
    "root" directory of the Dynatrace agent's. Agent DLL's are referenced relative from this directory <InstallPath>\agent\lib\dtagent.dll
.PARAMETER Use64Bit
    Boolean value to force usage of 64-bit agent
#>
	"Install Web Agent Module..."
	$appcmd = [System.Environment]::GetEnvironmentVariable("windir") + "\system32\inetsrv\appcmd.exe"

	if ($Use64Bit)
	{
		$arguments =  "install module /name:'Dynatrace Webserver Agent (64bit)' /image:'$InstallPath\agent\lib64\dtagent.dll' /add:true /lock:true"
	}
	else
	{
		$arguments =  "install module /name:'Dynatrace Webserver Agent (32bit)' /image:'$InstallPath\agent\lib\dtagent.dll' /add:true /lock:true"
	}

	iex "$appcmd $arguments"

	if ($LASTEXITCODE -gt 0)
	{
	  "'$appcmd $arguments' failed, return code is " + ($LASTEXITCODE -as [string])
	}

	"Complete."
}

Function Install-WebserverAgentService([string]$ServiceName, [string]$InstallPath, [string]$Username, [string]$Password)
{
<#
.SYNOPSIS
    Installs Dynatrace Webserver (master) agent as Windows service. 
.PARAMETER ServiceName
    Name of windows service. Example: "Dynatrace Webserver Agent Service"
.PARAMETER InstallPath
    "root" directory of the Dynatrace agent's. Agent DLL's are referenced relative from this directory <InstallPath>\agent\lib\dtagent.dll
.PARAMETER UserName
    Optional. User-Account in which context the service should run.
    If not given, service will be installed as "Local System"
.PARAMETER UserName
    Optional. Password of the User-Account in which context the service should run
#>
	"Install Web Agent Service..."

	if ($Username.Length -gt 0)
	{
		$securePassword = convertto-securestring -String $Password -AsPlainText -Force  
		$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username, $securePassword
		New-Service -BinaryPathName "$InstallPath\agent\lib\dtwsagent.exe -service" -Name $ServiceName  -DisplayName $ServiceName -StartupType Automatic -Credential $cred -Description "Dynatrace Master Webserver Agent"
	}
	else #install as Local Service
	{
		New-Service -BinaryPathName "$InstallPath\agent\lib\dtwsagent.exe -service" -Name $ServiceName -DisplayName $ServiceName -StartupType Automatic -Description "Dynatrace Master Webserver Agent"
	}
	"Service installed."
	"Starting the service..."
	Start-Service $ServiceName
	"Completed."
}

Function Uninstall-WebserverAgentModule([Boolean]$64Bit)
{
<#
.SYNOPSIS
    Removes Dynatrace Webserver agent module from IIS.
.PARAMETER 64Bit
    Boolean value wheter to search for 64-bit module 
#>
	$appcmd = [System.Environment]::GetEnvironmentVariable("windir") + "\system32\inetsrv\appcmd.exe"
	
	$moduleName = 'Dynatrace Webserver Agent (64bit)'
	if (!$64Bit)
	{
		$moduleName = 'Dynatrace Webserver Agent (32bit)'
	}
	
	"Uninstall module '$moduleName'"
	$arguments = "uninstall module '$moduleName'"

	iex "$appcmd $arguments"
	
	
	if ($LASTEXITCODE -gt 0)
	{
	  "'$appcmd $arguments' failed, return code is " + ($LASTEXITCODE -as [string])
	}

}


Function Uninstall-WebserverAgentService([string]$ServiceName)
{
<#
.SYNOPSIS
    Uninstalls Dynatrace (master) Webserver agent which is running as Windows Services. 
    Service automatically gets stopped before uninstalling.
.PARAMETER ServiceName
    Name of the Windows service it was installed with Install-WebserverAgentService.
#>
	"Uninstall Web Agent Service"
	$existingService = Get-WmiObject -Class Win32_Service -Filter "Name='$ServiceName'"

	if ($existingService) 
	{
	  "'$ServiceName' exists already. Stopping..."
	  Stop-Service $ServiceName
	  "Waiting 5 seconds to allow master agent service to stop..."
	  Start-Sleep -s 5
	  "Deleting..."
	  $existingService.Delete()
	  "Waiting 5 seconds to allow master agent service to be uninstalled..."
	  Start-Sleep -s 5  
	  "Completed."
	}
}