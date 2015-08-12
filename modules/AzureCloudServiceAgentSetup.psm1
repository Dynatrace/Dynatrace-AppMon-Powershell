#Requires –Modules WindowsAgentSetup

Function Install-DynatraceInWebRole( )
{

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

	Install-DynatraceASPNET -Installer $Installer  -InstallPath $InstallPath -CollectorHost $CollectorHost -WebserverAgentName $WebserverAgentName -DotNETAgentName $DotNETAgentName -use64Bit $TRUE
	
}


