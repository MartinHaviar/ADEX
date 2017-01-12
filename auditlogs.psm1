


function getcreatordn  {

<#
.SYNOPSIS
Find account which create an AD object based on distinguished name of object.
.DESCRIPTION
Before first use, fill $server variable with your DNS host names of Domain Controllers.
Find account which create an AD object based on distinguished name of object.
.Notes 
    NAME:  getcreatordn
    AUTHOR: martin haviar, mcsa
    LASTEDIT: 08/19/2016
    KEYWORDS: directory service object was modified, ID 5136
#>


[CmdletBinding()]

param([string]$DN = $(read-host 'please input Distinguished Name'))
$server = @("dcy01","dcy02","dcy03","dcz01","dcz02","dcw01","dcw02")
$sess1 = new-pssession $server

invoke-command -asjob -JobName gg -Session $sess1 -InputObject $dn -ScriptBlock `
{get-WinEvent -FilterHashtable @{LogName='Security';Id=(5136);data="$input"} -ErrorAction SilentlyContinue |
ft @{n="ObjectName";e={$_.Properties.value[8]}},@{n="SubjectName";e={$_.properties.value[3]}},TimeCreated,`
id,message -AutoSize -ErrorAction SilentlyContinue}

     
get-job | wait-job 
get-job | where {$_.HasMoreData -eq $true} | Receive-Job -OutVariable out

if ($out -ne $null ) {write-host "there are successfull changes" -foregroundcolor cyan} 
else {write-host "DCs has no changes within actual logs" -foregroundcolor cyan}

get-job | Remove-Job

Get-PSSession | Remove-PSSession

}





function getcreator  {

<#
.SYNOPSIS
Find account which create an AD object based on samaccountname of object.
.DESCRIPTION
Before first use, fill $server variable with your DNS host names of Domain Controllers.
Find account which create an AD object based on samaccountname of object.
.Notes 
    NAME:  getcreator
    AUTHOR: martin haviar, mcsa
    LASTEDIT: 08/19/2016
    KEYWORDS: directory service object was modified, ID 5136
#>

[CmdletBinding()]

param([string]$CN = $(read-host 'please input samaccountname'))
$dn=(Get-ADObject -Filter {samaccountname -like $CN} -SearchScope Subtree).distinguishedname
$server = @("dcy01","dcy02","dcy03","dcz01","dcz02","dcw01","dcw02")
$sess1 = new-pssession $server

invoke-command -asjob -JobName gg -Session $sess1 -InputObject $dn -ScriptBlock `
{get-WinEvent -FilterHashtable @{LogName='Security';Id=(5136);data="$input"} -ErrorAction SilentlyContinue |
ft @{n="ObjectName";e={$_.Properties.value[8]}},@{n="SubjectName";e={$_.properties.value[3]}},TimeCreated,`
@{n="AttributeLDAPDisplayName";e={$_.properties.value[11]}},`
id,message -AutoSize -ErrorAction SilentlyContinue}

     
get-job | wait-job 
get-job | where {$_.HasMoreData -eq $true} | Receive-Job -OutVariable out

if ($out -ne $null ) {write-host "there are successfull changes" -foregroundcolor cyan} 
else {write-host "DCs has no changes within actual logs" -foregroundcolor cyan}

get-job | Remove-Job

Get-PSSession | Remove-PSSession

}





function fUPNip {

<#
.SYNOPSIS
Find userprincipalname using IP from which was logged on.
.DESCRIPTION
Before first use, fill $server variable with your DNS host names of Domain Controllers.
Find userprincipalname using IP from which was logged on.
#>

[CmdletBinding()]

param([string]$IP = $(read-host 'please input IP'))
$server = @("dcy01","dcy02","dcy03","dcz01","dcz02","dcw01","dcw02")

$sess1 = new-pssession $server

invoke-command -asjob -JobName gg -Session $sess1 -InputObject $IP -ScriptBlock `
{get-WinEvent -FilterHashtable @{LogName='Security';Id=(4624);data="$input"} -MaxEvents 1 -ErrorAction SilentlyContinue|  
ft MachineName,@{n="UPN";e={$_.Properties.value[5]}},@{n="LT";e={$_.Properties.value[8]}},@{n="LP";e={$_.Properties.value[9]}},TimeCreated,`
@{n="IP";e={$_.properties.value[18]}},id,message -AutoSize -ErrorAction SilentlyContinue}

     
get-job | wait-job 
get-job | where {$_.HasMoreData -eq $true} | Receive-Job -OutVariable upn

if ($upn -ne $null ) {write-host "there are successfull logons from $IP" -foregroundcolor cyan} 
else {write-host "DCs has no logons from $IP" -foregroundcolor cyan}

get-job | Remove-Job

Get-PSSession | Remove-PSSession}






function fIPupn {[CmdletBinding()]

<#
.SYNOPSIS
Find IP using userprincipalname with which was logged on.
.DESCRIPTION
Before first use, fill $server variable with your DNS host names of Domain Controllers.
Find IP using userprincipalname with which was logged on.
#>

param([string]$UPN = $(read-host 'please input UPN'))
$server = @("dcy01","dcy02","dcy03","dcz01","dcz02","dcw01","dcw02")

$sess1 = new-pssession $server

invoke-command -asjob -JobName gg -Session $sess1 -InputObject $UPN -ScriptBlock `
{get-WinEvent -FilterHashtable @{LogName='Security';Id=(4624);data="$input"} -MaxEvents 1 -ErrorAction SilentlyContinue | 
where {$_.properties[18].value -like "*.*" } | 
ft MachineName,@{n="UPN";e={$_.Properties.value[5]}},@{n="LT";e={$_.Properties.value[8]}},@{n="LP";e={$_.Properties.value[9]}},TimeCreated,`
@{n="IP";e={$_.properties.value[18]}},id,message -AutoSize -ErrorAction SilentlyContinue}

     
get-job | wait-job 
get-job | where {$_.HasMoreData -eq $true} | Receive-Job -OutVariable upn

if ($upn -ne $null ) {write-host "there are successfull logons from $UPN" -foregroundcolor cyan} 
else {write-host "DCs has no logons from $UPN" -foregroundcolor cyan}

get-job | Remove-Job

Get-PSSession | Remove-PSSession}





function fUPNcmp {[CmdletBinding()]

<#
.SYNOPSIS
Find userprincipalname using IP from which was logged on.
.DESCRIPTION
Before first use, fill $server variable with your DNS host names of Domain Controllers.
Find userprincipalname using IP from which was logged on.
#>

param([string]$comp = $(read-host 'please input comp name'))

$ip=(nslookup $comp)
$ip1=$ip.split("`n")
$ip2=$ip1[4].substring(10)

$server = @("dcy01","dcy02","dcy03","dcz01","dcz02","dcw01","dcw02")

$sess1 = new-pssession $server

invoke-command -asjob -JobName gg -Session $sess1 -InputObject $ip2 -ScriptBlock `
{get-WinEvent -FilterHashtable @{LogName='Security';Id=(4624);data="$input"} -MaxEvents 1 -ErrorAction SilentlyContinue|  
ft MachineName,@{n="UPN";e={$_.Properties.value[5]}},@{n="LT";e={$_.Properties.value[8]}},@{n="LP";e={$_.Properties.value[9]}},TimeCreated,`
@{n="IP";e={$_.properties.value[18]}},id,message -AutoSize -ErrorAction SilentlyContinue}

     
get-job | wait-job 
get-job | where {$_.HasMoreData -eq $true} | Receive-Job -OutVariable upn

if ($upn -ne $null ) {write-host "there are successfull logons from $comp" -foregroundcolor cyan} 
else {write-host "DCs has no logons from $comp" -foregroundcolor cyan}

get-job | Remove-Job

Get-PSSession | Remove-PSSession}





function fCMPupn {

<#
.SYNOPSIS
Find computername using userprincipalname from which was logged on.
.DESCRIPTION
Before first use, fill $server variable with your DNS host names of Domain Controllers.
Find computername using userprincipalname from which was logged on.
#>

[CmdletBinding()]

param([string]$UPN = $(read-host 'please input UPN'))
$server = @("dcy01","dcy02","dcy03","dcz01","dcz02","dcw01","dcw02")

$sess1 = new-pssession $server

invoke-command -asjob -JobName gg -Session $sess1 -InputObject $UPN -ScriptBlock `
{get-WinEvent -FilterHashtable @{LogName='Security';Id=(4624);data="$input"} -MaxEvents 500 -ErrorAction SilentlyContinue | where {$_.properties.value[9] -like "*NtLm*"} |
ft @{n="CompName";e={$_.properties.value[11]}},MachineName,@{n="UPN";e={$_.Properties.value[5]}},@{n="LT";e={$_.Properties.value[8]}},@{n="LP";e={$_.Properties.value[9]}},TimeCreated,`
@{n="IP";e={$_.properties.value[18]}},id,message -AutoSize -ErrorAction SilentlyContinue}

     
get-job | wait-job 
get-job | where {$_.HasMoreData -eq $true} | Receive-Job -OutVariable upn

if ($upn -ne $null ) {write-host "there are successfull logons from $UPN" -foregroundcolor cyan} 
else {write-host "DCs has no logons from $UPN" -foregroundcolor cyan}

get-job | Remove-Job

Get-PSSession | Remove-PSSession
}





function findrdp {[CmdletBinding()]

<#
.SYNOPSIS
Find computer from which was user logged on using RDP protocol.
.DESCRIPTION
Before first use, fill $server variable with your DNS host names of Domain Controllers.
Find computer from which was user logged on using RDP protocol.
#>

param([string]$UPN = $(read-host 'please input UPN'))
$server = @("dcy01","dcy02","dcy03","dcz01","dcz02","dcw01","dcw02")

$sess1 = new-pssession $server

invoke-command -asjob -JobName gg -Session $sess1 -InputObject $UPN -ScriptBlock `
{get-WinEvent -FilterHashtable @{LogName='Security';Id=(4624);data="$input"} -MaxEvents 1000 -ErrorAction SilentlyContinue | where {$_.properties[8].value -like "*10*"} |
ft @{n="CompName";e={$_.properties.value[11]}},MachineName,@{n="UPN";e={$_.Properties.value[5]}},@{n="LT";e={$_.Properties.value[8]}},@{n="LP";e={$_.Properties.value[9]}},TimeCreated,`
@{n="IP";e={$_.properties.value[18]}},id,message -AutoSize -ErrorAction SilentlyContinue}

     
get-job | wait-job 
get-job | where {$_.HasMoreData -eq $true} | Receive-Job -OutVariable upn

if ($upn -ne $null ) {write-host "there are successfull logons from $IP" -foregroundcolor cyan} 
else {write-host "DCs has no logons from $UPN" -foregroundcolor cyan}

get-job | Remove-Job

Get-PSSession | Remove-PSSession }










