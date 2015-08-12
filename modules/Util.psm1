Function Wait-For ([string]$fileName, [string]$arguments)
{
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
		}
	}
}

Function Test-ServiceInstallation([string]$ServiceName)
{
	$res = Get-WmiObject -Class Win32_Service -Filter "Name='$ServiceName'"
    return ($res -ne $null)
}


Function Get-IniContent {  
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
            write-host "$name $value"
        }  
    }  

    return $ini  
} 