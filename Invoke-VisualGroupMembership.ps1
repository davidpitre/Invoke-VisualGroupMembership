<#
	.SYNOPSIS
		Web Filtering Group Membership visualiser
	
	.DESCRIPTION
		Forcepoint Web Securtiy requires that users are a member of a single policy 
		This script generates a diagram which visualises group membership. 

		Point the Security group enumeration script to an OU
		OU=ForcePoint Web Security,OU=Groups,DC=<CUST>,DC=<LOCAL>

		The structure should be similar to as below. Nested groups are not recommended. 
		OU=ForcePoint Web Security
			SG=Standard
				User1
				user2
			SG=Marketing
				User1
			SG=HR
				User2

		Install the below module as an administrator
		Install-Module -Name PSWriteHTML -AllowClobber -Force
	
	.NOTES
	===========================================================================
	 Created on:   		08/04/2020
	 Created by:   		David Pitre
	 Filename:     		Invoke-VisualiseGroupMembership.ps1
	 Version:			0.1
	 Classification:	Public

	 TODO
	 1.	Allow the script to be ran from workstations
	 2. Incorporate the ability to visualise any OU and nested group structure.
	 3. Make the script universal
	===========================================================================

	.EXAMPLE
		PS C:\> Invoke-VisualGroupMembership.ps1
	
	.LINK
		https://github.com/davidpitre/Invoke-VisualiseGroupMembership

#>

BEGIN
{
	Write-Verbose -Message "Invoke-VisualGroupMembership.: Begin"
	if (!(Get-Module PSWriteHTML))
	{
		Install-Module -Name PSWriteHTML -AllowClobber -Force
	}
}
PROCESS
{
	$WebFilteringMembership = Import-Csv -Path "GroupMembershipRecursive.csv"
	$UniqueGroups = $WebFilteringMembership | Select-Object SecurityGroup -Unique
	New-HTML -TitleText 'Security Group Membership' -UseCssLinks -UseJavaScriptLinks -FilePath $PSScriptRoot\GroupMembershipRecursive.html {
		New-HTMLSection -HeaderText "Group Memberships Diagram" {
			New-HTMLDiagram {
				New-DiagramOptionsInteraction -Hover $true
				New-DiagramOptionsPhysics -Enabled $true -StabilizationEnabled $true -MaxVelocity 10
				foreach ($Group in $UniqueGroups)
				{
					New-DiagramNode -Label $Group.SecurityGroup -ColorBackground Bisque
				}
				foreach ($user in $WebFilteringMembership)
				{
					if (($WebFilteringMembership | Where-Object { $_.GroupMemberName -eq $user.GroupMemberName }).count -gt 1)
					{
						New-DiagramNode -Label $user.GroupMemberName -To $user.SecurityGroup -Level 1 -ImageType circularImage `
										-ColorBorder red -Image "https://cdn.imgbin.com/22/5/16/imgbin-computer-icons-user-profile-profile-ico-man-s-profile-illustration-M4UwtQzjtzd9LFP69LEzngUuR.jpg"
					}
					else
					{
						New-DiagramNode -Label $user.GroupMemberName -To $user.SecurityGroup -Level 2 -ImageType circularImage `
										-Image "https://cdn.imgbin.com/22/5/16/imgbin-computer-icons-user-profile-profile-ico-man-s-profile-illustration-M4UwtQzjtzd9LFP69LEzngUuR.jpg"
					}
				}
			}
		}
		New-HTMLSection -HeaderText "Group Memberships Table" {
			New-HTMLTable -DataTable $WebFilteringMembership {
			}
		}
	} -ShowHTML
}
END
{
	Write-Verbose -Message "Invoke-VisualGroupMembership.: End"
}
