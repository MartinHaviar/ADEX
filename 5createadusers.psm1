function genra {

<#
.SYNOPSIS
Generates random password from ASCII characters number from 33 to 122 in ASCII table.
.PARAMeter length
required length of password.
#>


Param([int]$length=$(read-host 'please input length of generated password'))

$ascii=$NULL;
For ($a=33;$a –le 122;$a++) {$ascii+=,[char][byte]$a}
 

For ($loop=1; $loop –le $length; $loop++) 

    {$Password+=($ascii | GET-RANDOM)}

write-host $Password

$password | clip}




function ctus {

<#
.SYNOPSIS
Create test users
.DESCRIPTION
Create required number of test users with universal naming, like tester01 to tester99
.PARAMeter san
samaccountame which will be used during logon process for example: tester
#>

param ($san=$(read-host 'please input user logon name'),
                                 $pwd=(convertto-securestring $(read-host 'please input password') -asplaintext -force),
                                 $path=$(read-host 'please input DN of target OU, i.e. OU=general,OU=SEPAS,OU=TEST,DC=mil,DC=sk'),
                                 [int]$numberfrom=$(read-host 'please input the number from which will start creating of new users'),
                                 [int]$number=$(read-host 'please input the finish number of new users'),
                                 $des=$(read-host 'please input description of test user'))

begin {"Vytvaraju sa novy pouzivatelia.."}

process {
for  ($i=$numberfrom;$i-le $number;$i++) { $fsan=$san+$i; $upn=$fsan + '@mil.sk'

New-ADUser  -Name "$fsan" -DisplayName "$fsan" -SamAccountName "$fsan" -UserPrincipalName "$upn" -Path $path -Type:"user" -Server:"DCY03.mil.sk" -description $des
 
Set-ADAccountPassword -Identity:"$fsan" -NewPassword:$pwd -Reset:$true -Server:"DCY03.mil.sk"

Enable-ADAccount -Identity:"$fsan" -Server:"DCY03.mil.sk"

Set-ADAccountControl -AccountNotDelegated:$false -AllowReversiblePasswordEncryption:$false -CannotChangePassword:$false -DoesNotRequirePreAuth:$false -Identity:"$fsan" -PasswordNeverExpires:$true -Server:"DCY03.mil.sk" -UseDESKeyOnly:$false 

Set-ADUser -ChangePasswordAtLogon:$false -Identity:"$fsan" -Server:"DCY03.mil.sk" -SmartcardLogonRequired:$false
       
       Write-Progress -Activity "vytvaram pouzivatelov v AD" `
         -status "vytvoreny $fsan"}
 }

end {$f=$i-1;"vytvorenych $numberfrom - $f pouzivatelov"}

}




function ccu { 

<#
.SYNOPSIS
Create complet user with mailbox and home folder.
#>

param    ($givenname= $(read-host 'please input GivenName'),
			$surname= $(read-host 'please input Surname'),
			$pwd=(convertto-securestring $(read-host 'please input password') -asplaintext -force),
			$region=$(read-host 'please input symbol of region'),
			$dep=$(read-host 'please input user`s function'),
			$tit=$(read-host 'please input user`s titul'),
			$rank=$(read-host 'please input user`s rank'),
			$office=$(read-host 'please input user`s stationary'),
			$phone=$(read-host 'please input user`s OfficePhone'))

begin {"Vytvara sa novy pouzivatel:"}

process {
			$surnameTU=$surname.toupper()
			$san=$surname + $givenname.substring(0,1)
			$upn=$surname + $givenname.substring(0,1) + '@mil.sk'
			$homedir='\\mil.sk\home\HOME_'+$region+'\'+$san
			$mail=$givenname + '.' +$surnameTU + '@mil.sk'
			$des="$givenname $surname" + ',' + ' ' + $rank + '.' + ' ' + $tit + '.'
			$title=$tit + '.'
			$db='db'+ $region + '01' 					
	      
switch ($region) {
				"Y" {$path="OU=MIL,OU=Users,OU=TN,DC=mil,DC=sk"}
				"W" {$path="OU=MIL,OU=MOSR,OU=Users,OU=BA,DC=mil,DC=sk"}
				"Z" {$path="OU=MIL,OU=Users,OU=ZV,DC=mil,DC=sk"}
				"P" {$path="OU=MIL,OU=Users,OU=PO,DC=mil,DC=sk"}
				Default {"$_ - This is not correct symbol of region"}}

New-ADUser -GivenName:$givenname -Surname:$surname -Name:"$surnameTU $givenname" -DisplayName:"$surnameTU $givenname" `
-SamAccountName:$san -UserPrincipalName:$upn -Path:$path -HomeDirectory:$homedir -HomeDrive:"U:" -Type:"user" -Server:"DCY01.mil.sk" `
-department:$dep -description:$des -emailaddress:$mail -office:$office -officephone:$phone -state:"SK" -title:$title
 
Set-ADAccountPassword -Identity:$san -NewPassword:$pwd -Reset:$true -Server:"DCY01.mil.sk"

Enable-ADAccount -Identity:$san -Server:"DCY01.mil.sk"

Set-ADAccountControl -AccountNotDelegated:$false -AllowReversiblePasswordEncryption:$false -CannotChangePassword:$false `
-DoesNotRequirePreAuth:$false -Identity:$san -PasswordNeverExpires:$false -Server:"DCY01.mil.sk" -UseDESKeyOnly:$false 

Set-ADUser -ChangePasswordAtLogon:$true -Identity:$san -Server:"DCY01.mil.sk" -SmartcardLogonRequired:$false

Enable-Mailbox -Identity:$san -alias:$san -database:$db -DomainController dcy01
$path

md $homedir
}
			
end {"Mailbox v databaze $db Dokonceny."}

}


