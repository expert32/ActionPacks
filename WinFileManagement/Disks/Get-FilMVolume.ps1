#Requires -Version 4.0

<#
.SYNOPSIS
    Gets the specified volume object or all volume objects

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/Disks

.Parameter DriveLetter
    Specifies a letter used to identify a drive or volume in the system. If the parameter empty, all volume objects are retrieved

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the volume object informations. If Computername is not specified, the current computer is used.
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Properties
    List of properties to expand, comma separated e.g. Name,Description. Use * for all properties
#>

[CmdLetBinding()]
Param(    
    [string]$DriveLetter,
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [string]$Properties = "DriveLetter,DriveType,HealthStatus,FileSystemType,AllocationUnitSize,Size,SizeRemaining,FileSystemLabel"
)

$Script:Cim=$null
$Script:output = @()

try{
    if($DriveLetter.Length -gt 0){
        $DriveLetter = $DriveLetter.Substring(0,1)
        if(-not [System.Char]::IsLetter($DriveLetter)){
            $DriveLetter = ""
        } 
    }
    if([System.String]::IsNullOrWhiteSpace($Properties)){
        $Properties=@('*')
    }
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim =New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim =New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }        
    if([System.String]::IsNullOrWhiteSpace($DriveLetter)){
        $Script:output = Get-Volume -CimSession $Script:Cim -ErrorAction Stop | Select-Object $Properties.Split(',')
    } 
    else{
        $Script:output = Get-Volume -CimSession $Script:Cim -DriveLetter $DriveLetter -ErrorAction Stop | Select-Object $Properties.Split(',')
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage =$Script:output
    }
    else{
        Write-Output $Script:output
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