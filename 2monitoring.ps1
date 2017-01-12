


<#
.SYNOPSIS
Complete monitoring of critical infrastructure servicies.
.DESCRIPTION
Monitoring of replication between domain controllers across europe, group policy engine check, 
replication of mailbox databeses, Exchange hub transport queues.
If something go wrong, the appropriate line change to red color.
 
.Notes 
    NAME:  monitoring
    AUTHOR: martin haviar, mcsa
    LASTEDIT: 04/09/2016
    KEYWORDS: AD replication, DAG replication, transport queues
#>


$a = "<style>"
$a = $a + "BODY{background-color:#C6ECEE;}"
$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$a = $a + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:#00FF00}"
$a = $a + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black}"
$a = $a + "</style>"
#;background-color:#00FF00}"
#background-color:#0FF1E2}"



Get-ChildItem -Recurse \\mil.sk\SYSVOL\mil.sk\Policies -ReadOnly | Set-Variable item 
if ($item.exists) 
{$item | select * | convertto-html -Head "<H2>Get-ChildItem -Recurse \\mil.sk\SYSVOL\mil.sk\Policies -ReadOnly:</H2>"`
-Body "<H2><font color=red>There ARE group policy objects with READ-ONLY attribute:</font></H2>" | out-string | Set-Variable gphtm}
else
{convertto-html -Head "<H2>Get-ChildItem -Recurse \\mil.sk\SYSVOL\mil.sk\Policies -ReadOnly:</H2>"`
-Body "<H2><font color=green>ANY of group policy objects do NOT contain READ-ONLY attribute.</font></H2>" | out-string | Set-Variable gphtm}




set-Content -Path G:\modules\txt\csvhtml.txt -Value "DSA delta fails total %% error"
invoke-command dcy01 -scriptblock {repadmin /replsum} | Set-Variable array1
#$array2=@($array1[12..70])
$array12=@()
$i=0
foreach ($object in $array1)
{
if ($object -like "*dc*")
{
$obj1=$object.replace('/',' ')
$obj1= $obj1 -replace '\s+', ' '
$obj1= $obj1.Remove(0,1)
$rep = new-Object -TypeName PSObject
$rep | add-member -type NoteProperty -name repadmin -Value $obj1
$array12+=$rep }
}
$array12.repadmin | Add-Content -Path G:\modules\txt\csvhtml.txt
$import= import-csv -Path G:\modules\txt\csvhtml.txt -Delimiter " "

$import | ConvertTo-Html -head $a -Body "<H2>repadmin /replsum<H2>"|` 
foreach {if($_ -like "*<td>0</td><td></td></tr>*"){$_ -replace "<tr>", "<tr bgcolor=0FF1E2>"}
#elseif($_ -like "*dsa*"){$_ -replace "<tr>", "<tr bgcolor=00FF00>"}
elseif($_ -notlike "*</td><td>0</td><td>*"){$_ -replace "<tr>", "<tr bgcolor=red>"} else{$_}} |`
out-string | Set-Variable repadmin


$item=Get-TransportServer | Get-Queue | Get-Message
if ($item -eq $null)
{ConvertTo-Html -Body "<H2>The result of Get-TransportServer | Get-Queue | Get-Message: There are no messages now!</H2>" |`
out-string | set-variable qshtm}
else
{$item | select queue,fromaddress,size,scl,datereceived,MessageLatency,lasterror,subject | `
sort queue -descending | ConvertTo-Html -head $a -Body "<H2>The result of Get-TransportServer | Get-Queue | Get-Message:</H2>" | `
foreach {if($_ -like "*Shadow*"){$_ -replace "<tr>", "<tr bgcolor=0FF1E2>"}
#elseif($_ -like "*queue*"){$_ -replace "<tr>", "<tr bgcolor=00FF00>"}
elseif($_ -notlike "*shadow*"){$_ -replace "<tr>", "<tr bgcolor=red>"} else{$_}} |`
out-string | set-variable qshtm}



$item1=Get-TransportServer | Get-Queue | WHERE {$_.messagecount -notlike "0"}
if ($item -eq $null)
{ConvertTo-Html -Body "<H2>The result of Get-TransportServer | Get-Queue | WHERE {$_.messagecount -notlike 0}: There are no queues now!</H2>" |`
out-string | set-variable tqhtm}
else
{$item1 | select identity, deliverytype, status, messagecount, nexthopdomain, lasterror | `
ConvertTo-Html -head $a -Body "<H2>The result of Get-TransportServer | Get-Queue | WHERE {$_.messagecount -notlike 0}</H2>" | `
foreach {if($_ -like "*shadow*"){$_ -replace "<tr>", "<tr bgcolor=0FF1E2>"}
elseif($_ -notlike "*shadow*"){$_ -replace "<tr>", "<tr bgcolor=red>"} else{$_}} |`
out-string | set-variable tqhtm}




$dag=(Get-DatabaseAvailabilityGroup DAGY01).servers
              foreach ($server in $dag)                            
{$rep1=Get-MailboxDatabaseCopyStatus -Server $server; $reps1+=$rep1;
$rep= test-replicationhealth -server $server; $reps+=$rep}

$repss1=$reps1 | `
select name, status, LatestFullBackupTime, LatestIncrementalBackupTime, copyqueuelength, `
replayqueuelength, lastinspectedlogtime, contentindexstate

$repss=$reps | select PSComputerName,Server,Check,CheckDescription,Result,Error,Isvalid

$repss1 | ConvertTo-Html -head $a -Body "<H2>The result of Get-MailboxDatabaseCopyStatus:</H2>" | `
foreach {if({$_ -like "*healthy*" -and {-like "*mounted*"}} -or {$_ -like "*Healthy*" -and {-like "td><td>0</td><td>0</td><td>"}} )
{$_ -replace "<tr>", "<tr bgcolor=0FF1E2>"}
else{$_ -replace "<tr>", "<tr bgcolor=red>"}} | out-string | set-variable testdag

$repss | ConvertTo-Html -head $a -Body "<H2>The result of test-replicationhealth:</H2>" | `
foreach {if($_ -like "*passed*")
{$_ -replace "<tr>", "<tr bgcolor=0FF1E2>"}
else{$_ -replace "<tr>", "<tr bgcolor=red>"}} | out-string | set-variable testrep



$all=$gphtm+$repadmin+$qshtm+$tqhtm+$testdag+$testrep
Send-MailMessage  -From SystemMonitoring@mil.sk -To sepas@mil.sk -Subject "AD replication and EX queues" -BodyAsHtml -body $all -Priority High -SmtpServer exchange.mil.sk
