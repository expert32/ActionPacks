#Requires -Version 4.0

<#
.SYNOPSIS
    Gets DNS server IP addresses from the TCP/IP properties on an interface

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Network

.Parameter AdapterName
    Specifies the friendly name of the interface. If the parameter is empty, the ip addresses from all adapters are retrieved
    
.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the dns client
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Properties
    List of properties to expand, comma separated e.g. Name,Description. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [string]$AdapterName,
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [string]$Properties = "ServerAddresses,ElementName,Name,InterfaceAlias,InterfaceIndex,Address,EnabledState"
)

$Script:Cim
try{
    if([System.String]::IsNullOrWhiteSpace($AdapterName)){
        $AdapterName= "*"
    }
    if([System.String]::IsNullOrWhiteSpace($Properties)){
        $Properties=@('*')
    }
    [string[]]$Script:props = $Properties.Replace(' ','').Split(',')
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim =New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim =New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    $Script:Msg = Get-DnsClientServerAddress -CimSession $Script:Cim | Where-Object{$_.InterfaceAlias -like $AdapterName } | Select-Object $Script:props
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Msg 
    }
    else{
        Write-Output $Script:Msg
    }
}
catch{
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}