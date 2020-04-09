<#
	.SYNOPSIS
		Get Group Members for OU - Recursive
	
	.DESCRIPTION
		Get all users that are members of groups within an OU
	
	.PARAMETER OrganisationalUnit
		A description of the OrganisationalUnit parameter.
	
	.EXAMPLE
		PS C:\> Get-GroupMembersOURecursive.ps1 -OrganisationalUnit "OU=Security Group,OU=Customer,DC=Customer,DC=Local"
	
	.NOTES
		===========================================================================
		 Created on:		08/04/2020
		 Created by:		David Pitre
		 Filename:		Get-GroupMembersOURecursive.ps1
		 Version:		0.1
		 Classification:	Public
		
		 TODO
		 1. Allow the script to be ran from workstations
		 2. Incorporate the ability to visualise any OU and nested group structure.
		 3. Make the script universal
		
		 REQUIREMENTS
		 PSWriteHTML is used to visualise the relationships between users and their
		 respective web filtering groups.
		===========================================================================
	
	.LINK
		https://github.com/davidpitre/Invoke-VisualiseGroupMembership
#>
[CmdletBinding(ConfirmImpact = 'None')]
param
(
	[string]$OrganisationalUnit
)

<# Run this if you need to install the RSAT tools
if ((Get-WindowsCapability -Name RSAT.Active* -Online).state -eq "NotPresent")
{
	Get-WindowsCapability -Name RSAT.Active* -Online | Add-WindowsCapability -Online
}
#>

BEGIN 
{
	Write-Verbose -Message "Get-GroupMembersOURecursive: Begin"
	import-module activedirectory
}
PROCESS
{
	[array]$WebFilteringGroups = Get-ADGroup -SearchBase [string]$OrganisationalUnit -filter { GroupCategory -eq "Security" }
	[array]$GroupMembership = $null
	
	foreach ($SecurityGroup in $WebFilteringGroups)
	{
		
		[array]$GroupMembers = Get-ADGroupMember -Identity $SecurityGroup.sAMAccountName -Recursive
		
		foreach ($User in $GroupMembers)
		{
			[object]$GroupMemberObject = New-Object -TypeName PSCustomObject -Property @{
				SecurityGroup = $SecurityGroup.sAMAccountName
				GroupMemberName = $user.sAMAccountName
			}
			[array]$GroupMembership += [object]$GroupMemberObject
		}
	}
	[array]$GroupMembership | export-csv -Path "GroupMembershipRecursive.csv" -Force -NoClobber -NoTypeInformation
}
END
{
	Write-Verbose -Message "Get-GroupMembersOURecursive: End"
}
