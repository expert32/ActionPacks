﻿#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Gets the properties from the Hyper-V host
    
    .DESCRIPTION  
        Use "Win2K12R2 or Win8.x" for execution on Windows Server 2012 R2 or on Windows 8.1,
        when execute on Windows Server 2016 / Windows 10 or newer, use "Newer Systems"

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .COMPONENT
        Requires Module Hyper-V

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Hyper-V/Host
    
    .Parameter VMHostName
        Specifies the name of the Hyper-V host

    .Parameter HostName
        Specifies the name of the Hyper-V host

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action

    .Parameter Properties
        List of properties to expand, comma separated e.g. Name,Description. Use * for all properties
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [string]$VMHostName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$HostName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [PSCredential]$AccessAccount,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$Properties="ComputerName,VirtualHardDiskPath,VirtualMachinePath,LogicalProcessorCount,MemoryCapacity,MacAddressMinimum,MacAddressMaximum,FullyQualifiedDomainName"
)

Import-Module Hyper-V

try {
    $Script:output
    if($PSCmdlet.ParameterSetName  -eq "Win2K12R2 or Win8.x"){
        $HostName=$VMHostName
    }   
    if([System.String]::IsNullOrWhiteSpace($HostName)){
        $HostName = "."
    }
    if([System.String]::IsNullOrWhiteSpace($Properties)){
        $Properties='*'
    }     
    if($null -eq $AccessAccount){
        $Script:output = Get-VMHost -ComputerName $HostName -ErrorAction Stop | Select-Object $Properties.Split(',')
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        $Script:output = Get-VMHost -CimSession $Script:Cim -ErrorAction Stop | Select-Object $Properties.Split(',')
    }     
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:output
    }    
    else {
        Write-Output $Script:output
    }
}
catch {
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}