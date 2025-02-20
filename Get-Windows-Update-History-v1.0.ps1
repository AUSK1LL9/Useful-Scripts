#########################################################################################################
# Tool Name:        Get Windows Update History and Status by AUSK1LL9
# Script Name:      Get-Windows-Update-History-v1.0.ps1
# Script Purpose:   This PowerShell script retrieves, formats, and displays Windows Update history. Can export to CSV
# Current Version:  1.0
# Tested on:        Win10, Win11, Server 22
# Tested with:      PowerShell 5.1 and PowerShell 7.x
# Script Author:    AUSK1LL9 #AUSK1LL9
# GitHub Profile:   https://github.com/AUSK1LL9
# Usage:            Run script in PowerShell. 
#                   This script will need to be run with approriate permissions to run
# Change Notes:     1.0 - Script creation  
######################################################################################################
function Convert-WuaResultCodeToName
{
		param( [Parameter(Mandatory=$true)]
			[int] $ResultCode
	)
		$Result = $ResultCode
	switch($ResultCode)
		{
			2
		{
	$Result = "Succeeded"
		}
			3
		{
	$Result = "Succeeded With Errors"
		}
			4
		{
	$Result = "Failed"
	}
}
return $Result
}
	function Get-WuaHistory
{
# Get a WUA Session
$session = (New-Object -ComObject 'Microsoft.Update.Session')
# Query the latest 1000 History starting with the first recordp
$history = $session.QueryHistory("",0,50) | ForEach-Object {
$Result = Convert-WuaResultCodeToName -ResultCode $_.ResultCode
# Make the properties hidden in com properties visible.
$_ | Add-Member -MemberType NoteProperty -Value $Result -Name Result
$Product = $_.Categories | Where-Object {$_.Type -eq 'Product'} | Select-Object -First 1 -ExpandProperty Name
$_ | Add-Member -MemberType NoteProperty -Value $_.UpdateIdentity.UpdateId -Name UpdateId
$_ | Add-Member -MemberType NoteProperty -Value $_.UpdateIdentity.RevisionNumber -Name RevisionNumber
$_ | Add-Member -MemberType NoteProperty -Value $Product -Name Product -PassThru
Write-Output $_
	}
		#Remove null records and only return the fields we want
		$history |
		Where-Object {![String]::IsNullOrWhiteSpace($_.title)} |
		Select-Object Result, Date, Title, SupportUrl, Product, UpdateId, RevisionNumber
	}
#Get-WuaHistory | Format-Table
Get-WuaHistory #| Export-Csv -Path C:\temp\results.csv -UseCulture -NoTypeInformation
