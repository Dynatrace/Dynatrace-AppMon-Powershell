# Dynatrace-Powershell
This repository contains a set of PowerShell scripts and -modules to automate Dynatrace AppMon deployments on Microsoft Windows and Azure. 

##Features
###Agents
- Install, Uninstall and Re-Configure without running the installer. 
- .NET Agent, Webserver Agent for IIS 7+ (Slave), Webserver Agent Service (Master)
- Windows Server 2008+, Azure Cloud-Service WebRole and WorkerRole

##Folders
###/modules/
A set of functionality to build up automation scripts around dynatrace.
 
***For further information see documentation within the modules***

###/scripts/
Contains blueprint scripts covering common use-cases:

- **InstallAgentsInAzureWebRole.ps1** Installs .NET and IIS agents in Microsoft Azure Cloud-Service WebRole. For a detailed tutorial see [How to deploy Dynatrace Agents in MS Azure Cloud-Service](https://community.dynatrace.com/community/display/LEARN/How+to+deploy+Dynatrace+Agents+in+MS+Azure+Cloud-Service) 
- **InstallAgentsInAzureWorkerRole.ps1** Installs .NET agent in a Microsoft Azure Cloud-Service WorkerRole.For a detailed tutorial see [How to deploy Dynatrace Agents in MS Azure Cloud-Service](https://community.dynatrace.com/community/display/LEARN/How+to+deploy+Dynatrace+Agents+in+MS+Azure+Cloud-Service) 
- **InstallDotNetAgent.ps1** Enables Dynatrace .NET agent.
- **InstallWSAgentModuleIIS.ps1** Enables Dynatrace Webserver (slave) agent in IIS as a native module
- **InstallWSAgentService.ps1** Installs Dynatrace (master) Webserver Agent as Windows Service.
- **InstallMSI.ps1** Extracts files from an MSI-installer without executing the installer.

***For detailed infos on parameters, see the documentation within the scripts***  

## License
[Dynatrace BSD](https://community.dynatrace.com/community/download/attachments/5144912/dynaTraceBSD.txt?version=3&modificationDate=1365418216030&api=v2)
[![analytics](https://www.google-analytics.com/collect?v=1&t=pageview&_s=1&dl=https%3A%2F%2Fgithub.com%2FdynaTrace&dp=%2FDynatrace-Powershell&dt=Dynatrace-Powershell&_u=Dynatrace~&cid=github.com%2FdynaTrace&tid=UA-54510554-5&aip=1)]()
