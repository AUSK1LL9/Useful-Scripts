#########################################################################################################
# Tool Name:        Windows Firewall CLI tool by AUSK1LL9
# Script Name:      Windows-Firewall-CLI-tool-v1.3.ps1
# Script Purpose:   This Script will Prompt for Firewall Input and Generate and set a Windows Firewall Rule dynamically on each run
# Current Version:  1.3
# Tested on:        Win10, Win11
# Tested with:      PowerShell 5.1 and PowerShell 7.x
# Script Author:    AUSK1LL9 #AUSK1LL9
# GitHub Profile:   https://github.com/AUSK1LL9
# Usage:            Just enter the firewall rule name, port number, protocol (tcp/udp), traffic flow direction (inbound/outbound) and status (allow/deny)
#                   This script will need to be run with approriate permissions to run New-NetFirewallRule
# Change Notes:     1.2 - Allow for creation of Block and Deny rules
#                   1.1 - Allow for creation of Inbound and Outbound rules       
######################################################################################################
$rulename = Read-Host -Prompt "Enter rule name: "
$portNumber = Read-Host -Prompt "Enter Port Number: "
$protchoice = $Host.UI.PromptForChoice('Protocol Type','Enter Protocol (TCP/UDP): ',('&TCP','&UDP'),0)
if($protchoice -eq 0)
    {
        $protchoice02 = 'TCP'
        $dirChoice = $Host.UI.PromptForChoice('Traffic Flow','Enter Traffic Flow direction (inbound/outbound): ',('&inbound','&outbound'),0)
            if($dirChoice -eq 0)
                {
                    $dirChoices = 'Inbound'
                    $allowdenyChoice = $Host.UI.PromptForChoice('Traffic Allowance','Allow/Deny Traffic (allow/deny): ',('&allow','&deny'),0)
                        if($allowdenyChoice -eq '0')
                            { 
                            $allowdenyChoices = 'Allow'
                            $Output | New-NetFirewallRule -DisplayName $rulename -Direction $dirChoices -LocalPort $portNumber -Protocol $protchoice02 -Action $allowdenyChoices
                            }
                        else
                {
        $allowedenyChoices = 'Deny'
            New-NetFirewallRule -DisplayName $rulename -Direction $dirChoices  -LocalPort $portNumber -Protocol $protchoice02 -Action $allowdenyChoices
            }
    }
        else
            {
                $dirChoices = 'Outbound'
                $allowdenyChoice = $Host.UI.PromptForChoice('Traffic Allowance','Allow/Deny Traffic (allow/deny): ',('&allow','&deny'),0)
                if($allowdenyChoice -eq '0')
                    { 
                        $allowdenyChoices = 'Allow'
                        New-NetFirewallRule -DisplayName $rulename -Direction $dirChoices -LocalPort $portNumber -Protocol $protchoice02 -Action $allowdenyChoices
                    }
                else
                    {
                        $allowedenyChoices = 'Deny'
                        New-NetFirewallRule -DisplayName $rulename -Direction $dirChoices  -LocalPort $portNumber -Protocol $protchoice02 -Action $allowdenyChoices
                    }
            }
    }
else
    { 
        $protchoice02 = 'UDP'
        $dirChoice = $Host.UI.PromptForChoice('Traffic Flow','Enter Traffic Flow direction (inbound/outbound): ',('&inbound','&outbound'),0)
            if($dirChoice -eq 0)
                {
                    $dirChoices = 'Inbound'
                    $allowdenyChoice = $Host.UI.PromptForChoice('Traffic Allowance','Allow/Deny Traffic (allow/deny): ',('&allow','&deny'),0)
                        if($allowdenyChoice -eq '0')
                            { 
                                $allowdenyChoices = 'Allow'
                                New-NetFirewallRule -DisplayName $rulename -Direction $dirChoices -LocalPort $portNumber -Protocol $protchoice02 -Action $allowdenyChoices
                            }
                        else
                            {
                                $allowedenyChoices = 'Deny'
                                New-NetFirewallRule -DisplayName $rulename -Direction $dirChoices -LocalPort $portNumber -Protocol $protchoice02 -Action $allowdenyChoices
                            }
                 }
            else
        {
            $dirChoices = 'Outbound'
            $allowdenyChoice = $Host.UI.PromptForChoice('Traffic Allowance','Allow/Deny Traffic (allow/deny): ',('&allow','&deny'),0)
                if($allowdenyChoice -eq '0')
                    { 
                        $allowdenyChoices = 'Allow'
                        New-NetFirewallRule -DisplayName $rulename -Direction $dirChoices -LocalPort $portNumber -Protocol $protchoice02 -Action $allowdenyChoices
                    }
                else
                    {
                        $allowedenyChoices = 'Deny'
                        New-NetFirewallRule -DisplayName $rulename -Direction $dirChoices -LocalPort $portNumber -Protocol $protchoice02 -Action $allowdenyChoices
                    }
        }
    }  