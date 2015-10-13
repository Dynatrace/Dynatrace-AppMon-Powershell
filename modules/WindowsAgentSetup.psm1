#Requires –Modules Util, InstallWebserverAgent, InstallDotNETAgent

Function Install-DynatraceASPNET([string]$Installer, [string]$InstallPath, [string]$CollectorHost, [string]$WebserverAgentName, [string]$DotNETAgentName, [Boolean]$Use64Bit, [Boolean]$ForceIISReset )
{
<#
.SYNOPSIS
    Basic installation of Dynatrace agents for ASP.NET, which includes .NET agent monitoring for w3wp.exe as well as WebServer Agent for IIS (inclusive (master) Webserver Agent service)
    Skips installation if InstallPath already exists.
.PARAMETER
    Full path to the agent's MSI installer.
.PARAMETER InstallPath
    "root" directory of the Dynatrace agent's. Agent DLL's are referenced relative from this directory <InstallPath>\agent\lib\dtagent.dll
.PARAMETER CollectorHost
    <HostnameOrIP>[:Port]
.PARAMETER WebserverAgentName
    Webserver agent's name as shown in Dynatrace
.PARAMETER DotNETAgentName
    .NET agent's name as shown in Dynatrace
.PARAMETER Use64Bit
    Boolean value to force usage of 64-bit agent
.PARAMETER ForceIISReset
    Forces IISReset at the end of installation. If installation is skipped, no IISReset is performed.
#>

	if (!(Test-Path $InstallPath)) #already installed?
	{
		if (!(Test-Path $Installer)) 
		{
			"Installer not available - installation failed!"
		}
		else
		{
			"Extract Files From Installer..."
			$arg = "/a $Installer /qn TARGETDIR=""$InstallPath"""
			$ret = Wait-For "msiexec" $arg
			if ($ret -gt 0)
			{
				"'msiexec $arg' failed, return code is " + ($ret -as [string])
			}
			"Complete."

            "Delete 'dynaTraceWebServerSharedMemory'"
            Remove-Item "$InstallPath\agent\conf\dynaTraceWebServerSharedMemory" 

			Set-WebserverAgentConfiguration $InstallPath @{ Name = $WebserverAgentName
											 Server = $CollectorHost
											 Loglevel = 'info' }

			Install-WebserverAgentService "Dynatrace Webserver Agent" $InstallPath 

			Install-WebserverAgentModuleIIS $InstallPath $Use64Bit 

			Enable-DotNETAgent $InstallPath $DotNETAgentName $CollectorHost $Use64Bit @( "w3wp.exe" )

            if ($ForceIISReset)
            {
			    "Restart IIS"
			    Wait-For "iisreset"
			    iex "net start w3svc"
            }

			
	
		}
	}
	else
	{
		"Dynatrace already installed - setup skipped!"
	}
}


Function Install-DynatraceDotNET([string]$Installer, [string]$InstallPath, [string]$CollectorHost, [string]$DotNETAgentName, [Boolean]$Use64Bit, [Array]$ProcessList )
{
<#
.SYNOPSIS
    Basic installation of Dynatrace agents for ASP.NET, which includes .NET agent monitoring for w3wp.exe, WaWorkerHost.exe and WaWebHost.exe as well as WebServer Agent for IIS (inclusive (master) Webserver Agent service)
    Skips installation if InstallPath already exists.
.PARAMETER
    Full path to the agent's MSI installer.
.PARAMETER InstallPath
    "root" directory of the Dynatrace agent's. Agent DLL's are referenced relative from this directory <InstallPath>\agent\lib\dtagent.dll
.PARAMETER CollectorHost
    <HostnameOrIP>[:Port]
.PARAMETER DotNETAgentName
    .NET agent's name as shown in Dynatrace
.PARAMETER Use64Bit
    Boolean value to force usage of 64-bit agent
#>

	if (!(Test-Path $InstallPath)) #already installed?
	{
		if (!(Test-Path $Installer)) 
		{
			"Installer not available - installation failed!"
		}
		else
		{
			"Extract Files From Installer..."
			$arg = "/a $Installer /qn TARGETDIR=""$InstallPath"""
			$ret = Wait-For "msiexec" $arg
			if ($ret -gt 0)
			{
				"'msiexec $arg' failed, return code is " + ($ret -as [string])
			}
			"Complete."

			Enable-DotNETAgent $InstallPath $DotNETAgentName $CollectorHost $Use64Bit $ProcessList
		}
	}
	else
	{
		"Dynatrace already installed - setup skipped!"
	}
}