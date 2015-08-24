#Requires –Modules WindowsAgentSetup

Function Install-DynatraceInWebRole( )
{
<#
.SYNOPSIS
    Installs Dynatrace agents in Microsoft Azure Cloud-Service's WebRole. 
.DESCRIPTION
    Reads configuration from RoleEnvironment: 
    DTCollectorHost        ... [required] <HostnameOrIP>[:Port] 
    DTInstaller            ... [required] Name of the Dynatrace agent MSI-Installer file deployed with the application.
    DTInstallPath          ... [optional] Path where Dynatrace should be installed. Default: E:\sitesroot\0\App_Data\Dynatrace
    DTWebserverAgentName   ... [optional] Default: IIS
    DTDotNETAgentName      ... [optional] Default: ASP.NET
    DTUse64Bit             ... [optional] Default: True
        
#>

    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.WindowsAzure.ServiceRuntime")

	# Only run within an Azure Cloud Service 
	try
	{
	  if (![Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::IsAvailable)
	  {
		"RoleEnvironment is not available"
		return
	  }
	}
	catch
	{
	  "RoleEnvironment is not available"
	  return
	}

	# Don't install in emulated mode
	if ([Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::IsEmulated)
	{
		"Do not install in emulator"
		return
	}

	$instanceId = ([Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::CurrentRoleInstance.Id)
	$roleName = ([Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::CurrentRoleInstance.Role.Name)

	"Reading Configuration..."
	
	try { $CollectorHost = [Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::GetConfigurationSettingValue("DTCollectorHost") }
	catch 
	{ 
		"Failed to read 'DTCollectorHost'" 
		return 
	}

	try { $Installer = [Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::GetConfigurationSettingValue("DTInstaller") }
	catch 
	{ 
		"Failed to read 'DTInstaller'" 
		return 
	}

	$InstallPath = 'E:\sitesroot\0\App_Data\Dynatrace'
	try { $InstallPath = [Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::GetConfigurationSettingValue("DTInstallPath") }
	catch { "Failed to read 'DTInstallPath', default is '$InstallPath'" }
	
	$WebserverAgentName='IIS'
	try { $WSAgentName = [Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::GetConfigurationSettingValue("DTWebserverAgentName") }
	catch { "Failed to read 'DTWebserverAgentName', default is '$WebserverAgentName'" }
	
	$DotNETAgentName='ASP.NET'
	try { $DotNETAgentName = [Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::GetConfigurationSettingValue("DTDotNETAgentName") }
	catch { "Failed to read 'DTDotNETAgentName', default is '$DotNETAgentName'"  }
	
	$use64Bit = $TRUE
	try { $use64Bit = [Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::GetConfigurationSettingValue("DTUse64Bit") }
	catch { "Failed to read 'DTUse64Bit', default is '$use64Bit'" }

	"Complete."
	
	"Set Special Agent flags for Azure"
	$EnvironmentVariableTarget = 'Machine'
	[System.Environment]::SetEnvironmentVariable('DT_AZURE_ROLENAME',$roleName, $EnvironmentVariableTarget) 
	[System.Environment]::SetEnvironmentVariable('DT_AZURE_INSTANCEID',$instanceId, $EnvironmentVariableTarget) 

	Install-DynatraceASPNET -Installer $Installer  -InstallPath $InstallPath -CollectorHost $CollectorHost -WebserverAgentName $WebserverAgentName -DotNETAgentName $DotNETAgentName -Use64Bit $use64Bit -ForceIISReset $TRUE
	
}

Function Install-DynatraceInWorkerRole( )
{
<#
.SYNOPSIS
    Installs Dynatrace agents in Microsoft Azure Cloud-Service's WebRole. 
.DESCRIPTION
    Reads configuration from RoleEnvironment: 
    DTCollectorHost        ... [required] <HostnameOrIP>[:Port] 
    DTInstaller            ... [required] Name of the Dynatrace agent MSI-Installer file deployed with the application.
    DTInstallPath          ... [optional] Path where Dynatrace should be installed. Default: E:\approot\Dynatrace
    DTDotNETAgentName      ... [optional] Default: .NET
    DTUse64Bit             ... [optional] Default: True
        
#>

    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.WindowsAzure.ServiceRuntime")

	# Only run within an Azure Cloud Service 
	try
	{
	  if (![Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::IsAvailable)
	  {
		"RoleEnvironment is not available"
		return
	  }
	}
	catch
	{
	  "RoleEnvironment is not available"
	  return
	}

	# Don't install in emulated mode
	if ([Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::IsEmulated)
	{
		"Do not install in emulator"
		return
	}

	$instanceId = ([Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::CurrentRoleInstance.Id)
	$roleName = ([Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::CurrentRoleInstance.Role.Name)

	"Reading Configuration..."
	
	try { $CollectorHost = [Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::GetConfigurationSettingValue("DTCollectorHost") }
	catch 
	{ 
		"Failed to read 'DTCollectorHost'" 
		return 
	}

	try { $Installer = [Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::GetConfigurationSettingValue("DTInstaller") }
	catch 
	{ 
		"Failed to read 'DTInstaller'" 
		return 
	}

	$InstallPath = 'E:\approot\Dynatrace'
	try { $InstallPath = [Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::GetConfigurationSettingValue("DTInstallPath") }
	catch { "Failed to read 'DTInstallPath', default is '$InstallPath'" }
	
	$DotNETAgentName='.NET'
	try { $DotNETAgentName = [Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::GetConfigurationSettingValue("DTDotNETAgentName") }
	catch { "Failed to read 'DTDotNETAgentName', default is '$DotNETAgentName'"  }
	
	$use64Bit = $TRUE
	try { $use64Bit = [Microsoft.WindowsAzure.ServiceRuntime.RoleEnvironment]::GetConfigurationSettingValue("DTUse64Bit") }
	catch { "Failed to read 'DTUse64Bit', default is '$use64Bit'" }

	"Complete."
	
	"Set Special Agent flags for Azure"
	$EnvironmentVariableTarget = 'Machine'
	[System.Environment]::SetEnvironmentVariable('DT_AZURE_ROLENAME',$roleName, $EnvironmentVariableTarget) 
	[System.Environment]::SetEnvironmentVariable('DT_AZURE_INSTANCEID',$instanceId, $EnvironmentVariableTarget) 

	Install-DynatraceDotNET -Installer $Installer  -InstallPath $InstallPath -CollectorHost $CollectorHost -DotNETAgentName $DotNETAgentName -Use64Bit $use64Bit -ProcessList @( "WaWorkerHost.exe")
	
	#Restart WaHostBootStrapper to get agent injected...
	if ([System.Environment]::GetEnvironmentVariable('DT_INSTALLED', $EnvironmentVariableTarget) -ne "1")
	{
		if (Get-Process "WaHostBootStrapper" -ErrorAction silentlycontinue) 
		{
		  [System.Environment]::SetEnvironmentVariable('DT_INSTALLED',"1", $EnvironmentVariableTarget) 
		  "WaHostBootStrapper is running. Trying to kill..."
		  Stop-Process -Name "WaHostBootStrapper*" -Force
		  "Process killed."
		}
	}
	
	
}
