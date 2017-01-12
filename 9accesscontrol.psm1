function getace { 
<#   
.Synopsis
Retrieves access control entry for defined object. 
.Description
The GETACE cmdlet retrieves entries for specified object upon queued attribute, i.e. members of group. 
.Example
getace haviarm group sepas member

Returns 

AceType       Principal     AccessMask    InheritedFrom AppliesTo     OnlyAppliesHe
                                                                      re           
-------       ---------     ----------    ------------- ---------     -------------
AccessAllowed MIL\haviarm   Write member  <not inherite  O            False        
                           
.Parameter object
switch by user, group, computer, organizationalunit   
#>


param ($principal=$(read-host 'please insert principal'),
			$object=$(read-host 'please insert type of AD object'),
			$name=$(read-host 'please insert name of AD object'))
			$aceattr=$(read-host 'please input the name of checked attribute')
		
switch ($object) {
				"user"  {get-aduser $identity | get-accesscontrolentry -objectacetype $aceattr -principal $principal}
				"group" {get-adgroup $identity | get-accesscontrolentry -objectacetype $aceattr -principal $principal}
				"computer" {get-adcomputer $identity | get-accesscontrolentry -objectacetype $aceattr -principal $principal}
				"organizationalunit" {get-adorganizationalunit $identity | get-accesscontrolentry -objectacetype $aceattr -principal $principal}
				Default {"$_ - This is not correct name for object"}}
}






function geteffacc {

<#
.SYNOPSIS
Retrieves access control entry for defined principal and atribute of object.
.DESCRIPTION
The geteffacc cmdlet retrieves entries for principal and specified object upon queued attribute, i.e. members of group. 
.PARAMeter principal
referal object which must be authorize with appropriate rights
.PARAMeter object
switch by user, group, computer, organizationalunit 
.PARAMeter identity
name of AD object with SACL
.PARAMeter aceattr
name of checked attribute
#>

param ($principal=$(read-host 'please insert principal'),
			$object=$(read-host 'please insert type of AD object'),
			$identity=$(read-host 'please insert name of AD object'),
			$aceattr=$(read-host 'please input the name of checked attribute'))

switch ($object) {
				"user"  {get-aduser $identity | Get-EffectiveAccess -objectacetypes $aceattr -principal $principal -erroraction silentlycontinue | ft -auto -Wrap}
				"group" {get-adgroup $identity | Get-EffectiveAccess -objectacetypes $aceattr -principal $principal -erroraction silentlycontinue | ft -auto -Wrap}
				"computer" {get-adcomputer $identity | Get-EffectiveAccess -objectacetypes $aceattr -principal $principal -erroraction silentlycontinue | ft -auto -Wrap}
				"organizationalunit" {get-adorganizationalunit $identity | Get-EffectiveAccess -objectacetypes $aceattr -principal $principal -erroraction silentlycontinue | ft -auto -Wrap}
				Default {"$_ - This is not correct name for object"}}

}

function getacl    {param ($principal=$(read-host 'please insert principal'),
			$object=$(read-host 'please insert type of AD object'),
			$identity=$(read-host 'please insert name of AD object'))
			

switch ($object) {
				"user"  {(Get-ACL "AD:$((Get-ADUser $identity).distinguishedname)").access | where {$_.IdentityReference -like "*$principal*"} }
				"group" {(Get-ACL "AD:$((Get-ADgroup $identity).distinguishedname)").access | where {$_.IdentityReference -like "*$principal*"} }
				"computer" {(Get-ACL "AD:$((Get-ADcomputer $identity).distinguishedname)").access | where {$_.IdentityReference -like "*$principal*"} }
				"organizationalunit" {(Get-ACL "AD:$((Get-ADorganizationalunit $identity).distinguishedname)").access | where {$_.IdentityReference -like "*$principal*"} }
				Default {"$_ - This is not correct name for object"}}

}



function joindomain {

<#
.SYNOPSIS
Set  ACL rights to perform domain join.
.DESCRIPTION
Set minimum ACL rights to perform domain join for specified user and computer account.
.PARAMeter principal
Define principal under which will be computer joined to domain.
.PARAMeter computer
Name of computer object which will be joined to domain.
#>


param ($principal=$(read-host 'please insert principal'),
			$computer=$(read-host 'please insert name of AD computer'))
			


Add-AccessControlEntry -SDObject (Get-ADcomputer $computer).distinguishedname -ActiveDirectoryRights ExtendedRight -Principal $principal `
-ObjectAceType "00299570-246D-11D0-A768-00AA006E0529" -AceType AccessAllowed -AppliesTo Object -OnlyApplyToThisContainer


Add-AccessControlEntry -SDObject (Get-ADcomputer $computer).distinguishedname -ActiveDirectoryRights self -Principal $principal `
-ObjectAceType "f3a64788-5306-11d1-a9c5-0000f80367c1" -AceType AccessAllowed -AppliesTo Object -OnlyApplyToThisContainer


Add-AccessControlEntry -SDObject (Get-ADcomputer $computer).distinguishedname -ActiveDirectoryRights self -Principal $principal `
-ObjectAceType "72e39547-7b18-11d1-adef-00c04fd8d5cd" -AceType AccessAllowed -AppliesTo Object -OnlyApplyToThisContainer


Add-AccessControlEntry -SDObject (Get-ADcomputer $computer).distinguishedname -ActiveDirectoryRights writeproperty -Principal $principal `
-ObjectAceType "4c164200-20c0-11d0-a768-00aa006e0529" -AceType AccessAllowed -AppliesTo Object -OnlyApplyToThisContainer


Get-AccessControlEntry -Principal haviarm -inputobject (Get-ADcomputer $computer).distinguishedname  | ft -AutoSize


}






