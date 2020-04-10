## Invoke-VisualGroupMembership

#### Beta - In progress

The goal of the script was to help visualise which users are members of more than one primary group at an OU level. 
Due to Forcepoint requiring that users are a member of only a single policy that is filtered by Security group, this script should help to validate that users are receiving the expected policy

Users that are members of two or more security groups at the OU level will be highlighted in red in the visual diagram and report which can be exported to CSV or PDF. 

The visual elements of the script rely on a third party powershell module PSWriteHTML, which can be installed with powershell when prior to running the script or by running Invoke-VisualGroupMembership.ps1 as an administrator

Manual Install: Install-Module -Name PSWriteHTML -AllowClobber -Force

![Example](images/example.png)
