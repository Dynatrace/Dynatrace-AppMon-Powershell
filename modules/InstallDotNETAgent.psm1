Function Set-WhitelistProcess([int]$Index, [string]$NetProcess, [string]$AgentName)
{
<#
.SYNOPSIS
Configures additional process to be monitored  with the Dynatrace .NET agent. 
#>

  $regPath = "HKLM:\SOFTWARE\Wow6432Node\dynaTrace"
  if (!(Test-Path $regPath)) { md $regPath }

  $regPath = $regPath + "\Agent"
  if (!(Test-Path $regPath)) { md $regPath }

  $regPath = $regPath + "\Whitelist"
  if (!(Test-Path $regPath)) { md $regPath }

  $regPath = $regPath + "\" + ($Index -as [string])
  if (!(Test-Path $regPath)) { md $regPath }

  "Setting up .NET Agent for '" + $netProcess + "'..."
	Set-ItemProperty -Path $regPath -Name "active" -Value "TRUE"
	Set-ItemProperty -Path $regPath -Name "path" -Value "*"
	Set-ItemProperty -Path $regPath -Name "name" -Value $AgentName
	Set-ItemProperty -Path $regPath -Name "exec" -Value $NetProcess
}

Function Test-DotNETAgentInstallation
{
<#
.SYNOPSIS
Tests if Dynatrace .NET agent is installed based on COR_PROFILER environment variable. 
.DESCRIPTION
Returns 
1  .. if dynatrace .NET agent is configured
0  .. if nothing is configured
-1 .. if another .NET profiler is configured
#>

    $profiler = [System.Environment]::GetEnvironmentVariable('COR_PROFILER', 'Machine')
    if ($profiler -eq '{DA7CFC47-3E35-4C4E-B495-534F93B28683}') #dynatrace 
    {
        return 1
    }
    elseif ($profiler.Length -gt 0) #other profiler 
    {
        return -1
    }
    else #no profiler
    {
        return 0
    }
}

Function Enable-DotNETAgent([string] $InstallPath, [string]$AgentName, [string]$CollectorHost, [Boolean]$Use64Bit, [Array] $ProcessList)
{
<#
.SYNOPSIS
    Enables Dynatrace .NET agent.
.PARAMETER InstallPath
    "root" directory of the Dynatrace agent's. Agent DLL's are referenced relative from this directory <InstallPath>\agent\lib\dtagent.dll
.PARAMETER AgentName
    Agent's name as shown in Dynatrace
.PARAMETER CollectorHost
    <HostnameOrIP>[:Port]
.PARAMETER Use64Bit
    Boolean value to force usage of 64-bit agent
.PARAMETER ProcessList
    string array of processes to whitelist. 
    NOTE: If NO processes are whitelisted, agent instruments ALL .NET processes when they are started!
.NOTE 
    NOTE: If NO processes are whitelisted, agent instruments ALL .NET processes when they are started!
#>
	"Setting up .NET Agent '$AgentName'..."

	#.NET Agent Configuration
    if ($ProcessList.Length -gt 0)
    {
    	$index = 1

        #find new index in registry 
	    $regPath = "HKLM:\SOFTWARE\Wow6432Node\dynaTrace\Agent\Whitelist"
	    while (Test-Path ($regPath+"\"+($index -as [string])))
	    {
		    $index++
		    if ($index -gt 15) 
		    {
		        "Too many processes to instrument (15 processes already exceeded)."
		        return
		    }
	    }
	
	    #add process
	    foreach ($process in $ProcessList) 
	    {
		    Set-WhitelistProcess $index $process $AgentName
		    $index++
	    }		
    }

	#configure environment variables
	$EnvironmentVariableTarget = 'Machine'
	[System.Environment]::SetEnvironmentVariable('DT_SERVER',$CollectorHost, $EnvironmentVariableTarget) 
	[System.Environment]::SetEnvironmentVariable('COR_ENABLE_PROFILING','1', $EnvironmentVariableTarget) 
	[System.Environment]::SetEnvironmentVariable('COR_PROFILER','{DA7CFC47-3E35-4C4E-B495-534F93B28683}', $EnvironmentVariableTarget) 
	if ($Use64Bit)
	{
		[System.Environment]::SetEnvironmentVariable('COR_PROFILER_PATH',"$InstallPath\agent\lib64\dtagent.dll", $EnvironmentVariableTarget) 
	}
	else
	{
		[System.Environment]::SetEnvironmentVariable('COR_PROFILER_PATH',"$InstallPath\agent\lib\dtagent.dll", $EnvironmentVariableTarget) 
	}
	"Complete."
}

Function Remove-WhitelistedProcesses
{
<#
.SYNOPSIS
    Removes all whitelisted processes from configuration for Dynatrace .NET agent
#>
  "Remove Whitelisted Processes"

  $regPath = "HKLM:\SOFTWARE\Wow6432Node\dynaTrace"
  if (Test-Path $regPath) { 
	Remove-Item $regPath -Recurse
  }
  
}

Function Disable-DotNETAgent
{
<#
.SYNOPSIS
    Disables Dynatrace .NET agent and removes it's configuration
#>
	"Disable .NET Agent"

	Remove-WhitelistedProcesses

	$EnvironmentVariableTarget = 'Machine'
	[System.Environment]::SetEnvironmentVariable('DT_SERVER',$null, $EnvironmentVariableTarget) 
	[System.Environment]::SetEnvironmentVariable('COR_ENABLE_PROFILING',$null, $EnvironmentVariableTarget) 
	[System.Environment]::SetEnvironmentVariable('COR_PROFILER',$null, $EnvironmentVariableTarget) 
	[System.Environment]::SetEnvironmentVariable('COR_PROFILER_PATH',$null, $EnvironmentVariableTarget) 
	
}