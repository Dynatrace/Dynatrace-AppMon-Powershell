Function Wait-For ([string]$fileName, [string]$arguments)
{
<#
.SYNOPSIS
   Runs processes, waiting until the exit. 
.PARAMETER filename
    Process to execute
.PARAMETER arguments
    Arguments to be passed to the process.
        
#>
	if ($arguments.Length -gt 0)
	{
		return (Start-Process -FilePath $fileName -ArgumentList $arguments -NoNewWindow -Wait -Passthru).ExitCode
	}
	else
	{
		return (Start-Process -FilePath $fileName -NoNewWindow -Wait -Passthru).ExitCode
	}
}

Function Get-FilesFromMSI([string]$Installer, [string]$InstallPath)
{
<#
.SYNOPSIS
    Extracts files from an MSI-installer without executing the installer.
.DESCRIPTION
    Doesn't extract files if targetfolder already exists. Wait's until all files are extracted.
.PARAMETER Installer
    Installer file
.PARAMETER InstallPath
    Targetfolder 
        
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
		}
	}
    else
    {
        "Skipped extracting files from MSI - targetfolder already exists."
    }
}

Function Test-ServiceInstallation([string]$ServiceName)
{
<#
.SYNOPSIS
    Tests if a specifc windows service is already installed.
.PARAMETER ServiceName
    Name of the service to check.
#>
	$res = Get-WmiObject -Class Win32_Service -Filter "Name='$ServiceName'"
    return ($res -ne $null)
}


Function Get-IniContent 
{  
<#
.SYNOPSIS
    Reads key/values of an .ini file into a hash-table. 
.DESCRIPTION
    Only suppoerts key/value entries separated with spaces 
.PARAMETER FilePath
    Filename of the ini-file
#>
    [CmdletBinding()]  
    Param(  
        [ValidateNotNullOrEmpty()]  
        [ValidateScript({(Test-Path $_) -and ((Get-Item $_).Extension -eq ".ini")})]  
        [Parameter(ValueFromPipeline=$True,Mandatory=$True)]  
        [string]$FilePath  
    )  
      
    $ini = @{}  
    switch -regex -file $FilePath  
    {  

        "^\s*(\w+)\s*(.*)\s*$" # Key  
        {  
            $name,$value = $matches[1..2]  
            $ini[$name] = $value  
        }  
    }  

    return $ini  
} 