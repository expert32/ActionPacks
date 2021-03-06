﻿#Requires -Version 4.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Removes the Active Directory group
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .COMPONENT
        Requires Module ActiveDirectory

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/ActiveDirectory/Groups

    .Parameter OUPath
        Specifies the AD path

    .Parameter GroupName
        DistinguishedName or SamAccountName of the Active Directory group
    
    .Parameter DomainAccount
        Active Directory Credential for remote execution on jumphost without CredSSP
    
    .Parameter DomainName
        Name of Active Directory Domain
        
    .Parameter SearchScope
        Specifies the scope of an Active Directory search

    .Parameter AuthType
        Specifies the authentication method to use
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$OUPath,  
    [Parameter(Mandatory = $true,ParameterSetName = "Local or Remote DC")]
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [string]$GroupName,
    [Parameter(Mandatory = $true,ParameterSetName = "Remote Jumphost")]
    [PSCredential]$DomainAccount,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [string]$DomainName,
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('Base','OneLevel','SubTree')]
    [string]$SearchScope='SubTree',
    [Parameter(ParameterSetName = "Local or Remote DC")]
    [Parameter(ParameterSetName = "Remote Jumphost")]
    [ValidateSet('Basic', 'Negotiate')]
    [string]$AuthType="Negotiate"
)

Import-Module ActiveDirectory

#Clear
#$ErrorActionPreference='Stop'

try{
    $Script:Grp
    if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
        if([System.String]::IsNullOrWhiteSpace($DomainName)){
            $Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType -Credential $DomainAccount -ErrorAction Stop
        }
        else{
            $Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType -Credential $DomainAccount -ErrorAction Stop
        }
        $Script:Grp= Get-ADGroup -Server $Domain.PDCEmulator -Credential $DomainAccount -AuthType $AuthType `
            -SearchBase $OUPath -SearchScope $SearchScope `
            -Filter {(SamAccountName -eq $GroupName) -or (DistinguishedName -eq $GroupName)} -ErrorAction Stop
    }
    else{
        if([System.String]::IsNullOrWhiteSpace($DomainName)){
            $Domain = Get-ADDomain -Current LocalComputer -AuthType $AuthType  -ErrorAction Stop
        }
        else{
            $Domain = Get-ADDomain -Identity $DomainName -AuthType $AuthType  -ErrorAction Stop
        }
        $Script:Grp= Get-ADGroup -Server $Domain.PDCEmulator -AuthType $AuthType  `
            -SearchBase $OUPath -SearchScope $SearchScope `
            -Filter {(SamAccountName -eq $GroupName) -or (DistinguishedName -eq $GroupName)}      -ErrorAction Stop
    }
    if($null -ne $Script:Grp){
        if($PSCmdlet.ParameterSetName  -eq "Remote Jumphost"){
            Remove-ADGroup -Credential $DomainAccount -Server $Domain.PDCEmulator -AuthType $AuthType -Identity $Script:Grp -Confirm:$false -ErrorAction Stop
        }
        else{
            Remove-ADGroup -Server $Domain.PDCEmulator -AuthType $AuthType -Identity $Script:Grp -Confirm:$false -ErrorAction Stop
        }
        if($SRXEnv) {
            $SRXEnv.ResultMessage="Group $($GroupName) deleted"
        }
        else
        {
            Write-Output "Group $($GroupName) deleted"
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Group $($GroupName) not found"
        }    
        Throw "Group $($GroupName) not found"
    }   
}
catch{
    throw
}
finally{
}