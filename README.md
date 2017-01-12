function get-troubleuser11 {

<#
.SYNOPSIS
Retrieves relevant LDAP attributes and security log for problematic user.
.DESCRIPTION
Scan for security event logs susch as successfull logon, unsuccessfull logon, lockout and 
also scan for replicated key attributes susch as AccountLockoutTime, lastLogonTimestamp, PasswordLastSet
and parse useful data like IP from which was generated logon attempts, logon type and protocol.
Before first use, fill $server variable with your DNS host names of Domain Controllers.
.PARAMeter user
user account which have problems with authentication.
.Notes 
    NAME:  get-troubleuser11
    AUTHOR: martin haviar, mcsa
    LASTEDIT: 07/29/2015
    KEYWORDS: lastbadpwdattempt,badlogoncount, Id=4624, Id=4625, Id=4740
#>

[CmdletBinding()]

param([string]$user = $(read-host 'please input user logon name'))
$server = @("dcy01","dcy02","dcy03","dcz01","dcz02","dcw01","dcw02")

$sess1 = new-pssession $server
$sess2 = new-PSSession $server

invoke-command -asjob -JobName gg -Session $sess1 -InputObject $user -ScriptBlock `
{get-WinEvent -FilterHashtable @{LogName='Security';Id=(4624);data="$input"} -MaxEvents 20 -ErrorAction SilentlyContinue| where {$_.properties[18].value -like "*.*" } |  
ft MachineName,@{n="UPN";e={$_.Properties.value[5]}},@{n="LT";e={$_.Properties.value[8]}},@{n="LP";e={$_.Properties.value[9]}},TimeCreated,@{n="IP";e={$_.properties.value[18]}},id,message -AutoSize -ErrorAction SilentlyContinue}

invoke-command -asjob -JobName gb -Session $sess2 -InputObject $user -ScriptBlock `
{get-WinEvent -FilterHashtable @{LogName='Security';Id=4625;data="$input"} -MaxEvents 3 -ErrorAction SilentlyContinue |
ft MachineName,@{n="UPN";e={$_.Properties.value[5]}},@{n="Status";e={$_.Properties.value[7]}},@{n="SubStatus";e={$_.Properties.value[9]}},TimeCreated,@{n="IP";e={$_.properties.value[19]}},id,message -AutoSize -ErrorAction SilentlyContinue }

invoke-command -asjob -JobName bb -ComputerName dcy01 -InputObject $user -ScriptBlock `
{get-WinEvent -FilterHashtable @{LogName='Security';Id=4740;data="$input"} -MaxEvents 3 -ErrorAction SilentlyContinue |
ft MachineName,@{n="UPN";e={$_.Properties.value[0]}},TimeCreated,@{n="ClientName";e={$_.properties.value[1]}},id,message -AutoSize -ErrorAction SilentlyContinue }


$array1=@()
$array2=@()
$array12=@()
$array6=@()
$array7=@()
$array6738=@()
$arrai4=@()
$arrai5=@()
$arrai5146=@()  
$i=0
$x=0
$z=0

foreach ($dc in $server)

{$first=Get-ADUser $user -Server $dc -Properties LastBadPasswordAttempt, badpwdcount, badlogoncount, lastlogon | select lastlogon, lastbadpasswordattempt, badpwdcount, badlogoncount, @{label='dcname'; expression={$dc}}; $array1+=$first}

foreach ($tm in $array1)

{$tc=$tm.lastbadpasswordattempt.ticks ;$array2+=$tc}

foreach ($object in $array1)

{ $lockdc = new-Object -TypeName PSObject
  $lockdc | add-member -type NoteProperty -Name lastlogon -Value $array1.lastlogon[$i]   
  $lockdc | add-member -type NoteProperty -Name lastbadpwdattempt -Value $array2[$i]
  $lockdc | add-member -type NoteProperty -Name badpwdcount -Value $array1.badpwdcount[$i]
  $lockdc | add-member -type NoteProperty -Name badlogoncount -Value $array1.badlogoncount[$i]
  $lockdc | add-member -type NoteProperty -Name dcname -Value $array1.dcname[$i]
  $array12+=$lockdc
  $i++}

$array3 = $array12 | sort -property lastlogon -Descending
$array4 = $array3 | select lastlogon
$array5 = $array3 | select lastbadpwdattempt
    
foreach ($tt1 in $array4)
{if ($tt1.lastlogon -ne $null) {$ttc1= (get-date $tt1.lastlogon).ToString("dd.MM.yyyy HH:mm:ss")} else {$ttc1="never"}  ; $array6+=$ttc1}

foreach ($tt2 in $array5)
{if ($tt2.lastbadpwdattempt -ne $null) {$ttc2= (get-date $tt2.lastbadpwdattempt).ToString("dd.MM.yyyy HH:mm:ss")} else {$ttc2="never"}  ; $array7+=$ttc2}

$array8 = $array3 | select dcname

foreach ($object in $array8)

{ $lastlog = new-Object -TypeName PSObject
  $lastlog | add-member -type NoteProperty -Name lastlogon -Value $array6[$x]
  $lastlog | add-member -type NoteProperty -Name lastbadpwdattempt -Value $array7[$x]
  $lastlog | add-member -type NoteProperty -Name badpwdcount -Value $array3.badpwdcount[$x]
  $lastlog | add-member -type NoteProperty -Name badlogoncount -Value $array3.badlogoncount[$x]
  $lastlog | add-member -type NoteProperty -Name dcname -Value $array8.dcname[$x]
  $array6738+=$lastlog
  $x++}

  #tvorba druheho pola

$arrai1 = $array12 | sort -Property lastbadpwdattempt -Descending
$arrai2 = $arrai1 | select lastlogon
$arrai3 = $arrai1 | select lastbadpwdattempt

foreach ($tti1 in $arrai2)
{if ($tti1.lastlogon -ne $null) {$ttci1= (get-date $tti1.lastlogon).ToString("dd.MM.yyyy HH:mm:ss")} else {$ttci1="never"}  ; $arrai4+=$ttci1}

foreach ($tti2 in $arrai3)
{if ($tti2.lastbadpwdattempt -ne $null) {$ttci2= (get-date $tti2.lastbadpwdattempt).ToString("dd.MM.yyyy HH:mm:ss")} else {$ttci2="never"}  ; $arrai5+=$ttci2}

$arrai6 = $arrai1 | select dcname

foreach ($object in $arrai6)

{ $lastbad = new-Object -TypeName PSObject
  $lastbad | add-member -type NoteProperty -Name lastbadpwdattempt -Value $arrai5[$z]
  $lastbad | add-member -type NoteProperty -Name badpwdcount -Value $arrai1.badpwdcount[$z]
  $lastbad | add-member -type NoteProperty -Name badlogoncount -Value $arrai1.badlogoncount[$z]
  $lastbad | add-member -type NoteProperty -Name lastlogon -Value $arrai4[$z]
  $lastbad | add-member -type NoteProperty -Name dcname -Value $arrai6.dcname[$z]
  $arrai5146+=$lastbad
  $z++}

 #definicia premennych pre hash riadky
 $array9=$array6738 | sort -Property badlogoncount -Descending
 $hash1=$array9.badpwdcount[0].ToString() + "                        " + $array9.dcname[0].ToString()
 $hash2=$array9.badlogoncount[0].ToString() + "                        " + $array9.dcname[0].ToString()
 $hash3=$arrai5146.lastbadpwdattempt[0].tostring() + "      " + $arrai1.dcname[0].ToString()
 $hash4=$array6738.lastlogon[0].ToString() + "      " + $array3.dcname[0].tostring()

 $ga=Get-ADUser $user -Server dcy01 -Properties lockedout,accountlockouttime,lastlogontimestamp,passwordlastset | select lockedout,accountlockouttime,lastlogontimestamp,passwordlastset
 $hash5=$ga.lockedout
 if ($ga.accountlockouttime -ne $null) {$hash6=$ga.accountlockouttime.ToString("dd.MM.yyyy HH:mm:ss")} else {$hash6 = "not locked"}
 $hash7=(get-date $ga.lastLogonTimestamp).ToString("dd.MM.yyyy HH:mm:ss")
 $hash8=$ga.PasswordLastSet.ToString("dd.MM.yyyy HH:mm:ss")


 #zobrazenie
 write-host `n
 write-host "sort by lastlogon:" -ForegroundColor Cyan
 $array6738 | ft -AutoSize 

 write-host "sort by lastlbadpwdattempt:" -ForegroundColor Cyan
 $arrai5146 | ft -AutoSize 


 
 Write-Host "Summary:" -ForegroundColor Yellow

 write-host "LockedOut                    $hash5"
 write-host `n


 Write-Host "Replicated values to dcy01" -ForegroundColor Yellow 
  
 write-host "AccountLockoutTime           $hash6"
 write-host "lastLogonTimestamp           $hash7"
 write-host "PasswordLastSet              $hash8"
 write-host `n


 write-host "Specific most actual values per DC" -ForegroundColor Yellow
 
 write-host "badPwdCount                  $hash1"
 write-host "BadLogonCount                $hash2"
 write-host "LastBadPasswordAttempt       $hash3"
 write-host "lastLogon                    $hash4"
 write-host `n

 
 wait-job -Name gg
 write-host "Successfull logons:" -ForegroundColor cyan
 receive-job gg

  
 Wait-Job -Name gb
 write-host "UnSuccessfull logons:" -ForegroundColor cyan 
 Receive-Job -Name gb


 
 Wait-Job -Name bb
 write-host "Lockout Parameters:" -ForegroundColor cyan
 Receive-Job -Name bb


get-job | remove-job 
get-pssession | Remove-PSSession
 }





function unpwdnotreq {

<#
.SYNOPSIS
Change UAC flag from PasswordNotRequired to PasswordRequired
.PARAMeter searchbase
Distinguished name of LDAP tree level from which will start scan for users with PasswordNotRequired UAC flag
#>

param([string]$searchbase = $(read-host 'please input SearchBase to start scan, f.e. OU=TestPermission,OU=TEST,DC=mil,DC=sk'))
$t=(get-date).DateTime
$i=0
$x=0
$y=0

$users=Get-ADUser -filter {PasswordNotRequired -eq $true} -Properties distinguishedname,samaccountname,PasswordNotRequired -SearchBase $searchbase -SearchScope Subtree

$count=$users.count
add-content -Path C:\Users\haviarm\Desktop\testL\PassNotReq\succ.txt -Value ""
add-content -Path C:\Users\haviarm\Desktop\testL\PassNotReq\succ.txt -Value "$t"
add-content -Path C:\Users\haviarm\Desktop\testL\PassNotReq\succ.txt -Value "$count users with PasswordNotRequired set to `$true attr was founded:"

foreach ($u in $users)

{$i++;$dn=$u.distinguishedname;$sam=$u.samaccountname;

Set-ADUser $sam -PasswordNotRequired:$false -Server dcy03
start-sleep 0.01
$res=(get-aduser $sam -Properties PasswordNotRequired -Server dcy03).PasswordNotRequired
if ($res -eq $false) {$x++;add-content -Path C:\Users\haviarm\Desktop\testL\PassNotReq\succ.txt -Value "$dn has successfully changed attr PasswordNotRequired from `$true to `$false, count $x" -PassThru}
else {$y++;add-content -Path C:\Users\haviarm\Desktop\testL\PassNotReq\unsucc.txt -Value "$dn has unsuccessfully changed attr PasswordNotRequired and is still `$true, count $y" -PassThru;
           add-content -Path C:\Users\haviarm\Desktop\testL\PassNotReq\succ.txt -Value "$dn has unsuccessfully changed attr PasswordNotRequired and is still `$true, count $y" -PassThru}
Write-Progress -Activity "prepisujem attr PasswordNotRequired" -status "najdenych $i, prepisanych $x"
Write-host "najdenych $i, prepisanych $x" -ForegroundColor Cyan
}

add-content -Path C:\Users\haviarm\Desktop\testL\PassNotReq\succ.txt -Value "Najdenych $i, opravenych $x"
}





function setsmartcardreq {
<#
.SYNOPSIS
Change UAC flag on SmartcardLogonRequired
.PARAMeter searchbase
Distinguished name of LDAP tree level from which will start scan for users with not setted SmartcardLogonRequired
flag and then set it.
#>

param([string]$searchbase = $(read-host 'please input SearchBase to start scan, f.e. OU=TestPermission,OU=TEST,DC=mil,DC=sk'))
$t=(get-date).DateTime
$i=0
$x=0
$y=0

$users=Get-ADUser -filter {(SmartcardLogonRequired -eq $false) -and (SamAccountName -neq haviarmsp)`
-and (SamAccountName -neq tvaroskarsp) -and (SamAccountName -neq hrochtsp) -and (SamAccountName -neq pjescakovavsp)}`
-Properties distinguishedname,samaccountname,SmartcardLogonRequired -SearchBase $searchbase -SearchScope Subtree

$count=$users.count
add-content -Path C:\Users\haviarm\Desktop\testL\PassNotReq\succ.txt -Value ""
add-content -Path C:\Users\haviarm\Desktop\testL\PassNotReq\succ.txt -Value "$t"
add-content -Path C:\Users\haviarm\Desktop\testL\PassNotReq\succ.txt -Value "$count users with SmartcardLogonRequired set to `$false attr was founded:"

foreach ($u in $users)

{$i++;$dn=$u.distinguishedname;$sam=$u.samaccountname;

Set-ADUser $sam -SmartcardLogonRequired:$true -server dcy03
start-sleep 0.01
$res=(get-aduser $sam -Properties SmartcardLogonRequired -Server dcy03).SmartcardLogonRequired
if ($res -eq $true) {$x++;add-content -Path C:\Users\haviarm\Desktop\testL\PassNotReq\succ.txt -Value "$dn has succesfully changed attr SmartcardLogonRequired from `$false to `$true, count $x" -PassThru}
else {$y++;add-content -Path C:\Users\haviarm\Desktop\testL\PassNotReq\unsucc.txt -Value "$dn has unsuccesfully changed attr SmartcardLogonRequired and is still `$false, count $y" -PassThru;
           add-content -Path C:\Users\haviarm\Desktop\testL\PassNotReq\succ.txt -Value "$dn has unsuccesfully changed attr SmartcardLogonRequired and is still `$false, count $y"}
Write-Progress -Activity "overwriting attr SmartcardLogonRequired" -status "finded $i, overwrited $x"
Write-host "finded $i, overwrited $x" -ForegroundColor Cyan
}
add-content -Path C:\Users\haviarm\Desktop\testL\PassNotReq\succ.txt -Value "finded $i, overwrited $x"
}
