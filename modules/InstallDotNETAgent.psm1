Function Set-WhitelistProcess([int]$index, [string]$netProcess, [string]$agentName)
{

  $regPath = "HKLM:\SOFTWARE\Wow6432Node\dynaTrace"
  if (!(Test-Path $regPath)) { md $regPath }

  $regPath = $regPath + "\Agent"
  if (!(Test-Path $regPath)) { md $regPath }

  $regPath = $regPath + "\Whitelist"
  if (!(Test-Path $regPath)) { md $regPath }

  $regPath = $regPath + "\" + ($index -as [string])
  if (!(Test-Path $regPath)) { md $regPath }

  "Setting up .NET Agent for '" + $netProcess + "'..."
	Set-ItemProperty -Path $regPath -Name "active" -Value "TRUE"
	Set-ItemProperty -Path $regPath -Name "path" -Value "*"
	Set-ItemProperty -Path $regPath -Name "name" -Value $agentName
	Set-ItemProperty -Path $regPath -Name "exec" -Value $netProcess
}

Function Enable-DotNETAgent([string] $InstallPath, [string]$agentName, [string]$collectorHost, [Boolean]$use64Bit, [Array] $processList)
{
	"Setting up .NET Agent '$agentName'..."

	#.NET Agent Configuration
	
	#find new index in registry 
	$index = 1
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
	foreach ($process in $processList) 
	{
		Set-WhitelistProcess $index $process $agentName
		$index++
	}		

	#configure environment variables
	$EnvironmentVariableTarget = 'Machine'
	[System.Environment]::SetEnvironmentVariable('DT_SERVER',$collectorHost, $EnvironmentVariableTarget) 
	[System.Environment]::SetEnvironmentVariable('COR_ENABLE_PROFILING','1', $EnvironmentVariableTarget) 
	[System.Environment]::SetEnvironmentVariable('COR_PROFILER','{DA7CFC47-3E35-4C4E-B495-534F93B28683}', $EnvironmentVariableTarget) 
	if ($use64Bit)
	{
		[System.Environment]::SetEnvironmentVariable('COR_PROFILER_PATH',"$InstallPath\agent\lib64\dtagent.dll", $EnvironmentVariableTarget) 
	}
	else
	{
		[System.Environment]::SetEnvironmentVariable('COR_PROFILER_PATH',"$InstallPath\agent\lib\dtagent.dll", $EnvironmentVariableTarget) 
	}
	"Complete."
}

Function Remove-WhitelistedProcesses()
{
  "Remove Whitelisted Processes"

  $regPath = "HKLM:\SOFTWARE\Wow6432Node\dynaTrace"
  if (Test-Path $regPath) { 
	Remove-Item $regPath -Recurse
  }
  
}

Function Disable-DotNETAgent
{
	"Disable .NET Agent"

	Remove-WhitelistedProcesses

	$EnvironmentVariableTarget = 'Machine'
	[System.Environment]::SetEnvironmentVariable('DT_SERVER',$null, $EnvironmentVariableTarget) 
	[System.Environment]::SetEnvironmentVariable('COR_ENABLE_PROFILING',$null, $EnvironmentVariableTarget) 
	[System.Environment]::SetEnvironmentVariable('COR_PROFILER',$null, $EnvironmentVariableTarget) 
	[System.Environment]::SetEnvironmentVariable('COR_PROFILER_PATH',$null, $EnvironmentVariableTarget) 
	
}