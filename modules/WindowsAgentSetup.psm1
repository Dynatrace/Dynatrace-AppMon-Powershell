#Requires –Modules Util, InstallWebserverAgent, InstallDotNETAgent

Function Install-DynatraceASPNET([string]$Installer, [string]$InstallPath, [string]$CollectorHost, [string]$WebserverAgentName, [string]$DotNETAgentName, [Boolean]$Use64Bit )
{
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

			Set-WebserverAgentConfiguration $InstallPath @{ Name = $WebserverAgentName
											 Server = $CollectorHost
											 Loglevel = 'info' }

			Install-WebserverAgentService "Dynatrace Webserver Agent" $InstallPath 

			Install-WebserverAgentModuleIIS $InstallPath $Use64Bit 

			Enable-DotNETAgent $InstallPath $DotNETAgentName $CollectorHost $Use64Bit @( "w3wp.exe", 
																					 "WaWorkerHost.exe", 
																					 "WaWebHost.exe")

			"Restart IIS"
			Wait-For "iisreset"
			iex "net start w3svc"
		}
	}
	else
	{
		"Dynatrace already installed - setup skipped!"
	}
}


