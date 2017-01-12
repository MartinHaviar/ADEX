function devip {

<#
.SYNOPSIS
Generate table of exchange receive connectors with allowed annonymous Authentication.
.DESCRIPTION
Generate table of exchange receive connectors with allowed annonymous Authentication used for devices and printers.
.Notes 
    NAME:  devip
    AUTHOR: martin haviar, mcsa
    LASTEDIT: 03/21/2015
    KEYWORDS: receive connector, annonymous Authentication
#>
		
$ip1=((Get-ReceiveConnector -identity "chby01\devices").remoteipranges | sort -descending | Out-String).Split("`n")
		
$ip2=((Get-ReceiveConnector -identity "chby02\devices").remoteipranges | sort -descending | Out-String).Split("`n")

$ip3=((Get-ReceiveConnector -identity "chby03\devices").remoteipranges | sort -descending | Out-String).Split("`n")
		
$ip4=((Get-ReceiveConnector -identity "chby04\devices").remoteipranges | sort -descending | Out-String).Split("`n")

$count1=($ip1.Count | Out-String)
$count2=($ip2.Count | Out-String)
$count3=($ip3.Count | Out-String)
$count4=($ip4.Count | Out-String)

$counter=($count1+$count2+$count3+$count4).split()
$countmax=($counter | measure -Maximum).Maximum

$array=@()
for ($i=0; $i -le $countmax; $i +=1) 
{
$prop= @{'CHBY01'= $ip1[$i]; 'CHBY02' = $ip2[$i]; 'CHBY03' = $ip3[$i]; 'CHBY04' = $ip4[$i]}
$obj = New-Object –TypeName PSObject –Prop $prop
$array+=$obj
}
$array | ft chby01,chby02,chby03,chby04 -AutoSize -Wrap}







function addevip {

<#
.SYNOPSIS
Add device IP to exchange receive connectors with allowed annonymous Authentication.
.DESCRIPTION
Add device IP to exchange receive connectors with allowed annonymous Authentication.
.Notes 
    NAME:  adddevip
    AUTHOR: martin haviar, mcsa
    LASTEDIT: 03/21/2015
    KEYWORDS: receive connector, annonymous Authentication
#>
 	
 	param ($newip= $(read-host 'please input NewIP'))
		$connector1=Get-ReceiveConnector -identity 'chby01\devices'
		$connector1.remoteipranges += $newip
		$connector2=Get-ReceiveConnector -identity 'chby02\devices'
		$connector2.remoteipranges += $newip
		$connector3=Get-ReceiveConnector -identity 'chby03\devices'
		$connector3.remoteipranges += $newip
		$connector4=Get-ReceiveConnector -identity 'chby04\devices'
		$connector4.remoteipranges += $newip	
						
		set-receiveconnector chby01\devices -remoteipranges $connector1.remoteipranges
		set-receiveconnector chby02\devices -remoteipranges $connector2.remoteipranges
		set-receiveconnector chby03\devices -remoteipranges $connector3.remoteipranges
		set-receiveconnector chby04\devices -remoteipranges $connector4.remoteipranges
        devip}




function redevip {

<#
.SYNOPSIS
Remove device IP from exchange receive connectors with allowed annonymous Authentication.
.DESCRIPTION
Remove device IP from exchange receive connectors with allowed annonymous Authentication.
.Notes 
    NAME:  redevip
    AUTHOR: martin haviar, mcsa
    LASTEDIT: 03/21/2015
    KEYWORDS: receive connector, annonymous Authentication
#>

 	param ($oldip= $(read-host 'please input OldIP'))
		$connector1=Get-ReceiveConnector -identity 'chby01\devices'
		$connector1.remoteipranges.remove("$oldip")
		$connector2=Get-ReceiveConnector -identity 'chby02\devices'
		$connector2.remoteipranges.remove("$oldip")
		$connector3=Get-ReceiveConnector -identity 'chby03\devices'
		$connector3.remoteipranges.remove("$oldip")
		$connector4=Get-ReceiveConnector -identity 'chby04\devices'
		$connector4.remoteipranges.remove("$oldip")	
		set-receiveconnector chby01\devices -remoteipranges $connector1.remoteipranges
        	set-receiveconnector chby02\devices -remoteipranges $connector2.remoteipranges
		set-receiveconnector chby03\devices -remoteipranges $connector3.remoteipranges
		set-receiveconnector chby04\devices -remoteipranges $connector4.remoteipranges
	devip
		invoke-item \\mil.sk\HOME\HOME_Y\haviarm\MIL2\2-EX10\DevConIPranges\chby04.txt
}






function addevipsp {

<#
.SYNOPSIS
ADD device IP to specific exchange receive connector.
.DESCRIPTION
ADD device IP to specific exchange receive connector with allowed annonymous Authentication.
.Notes 
    NAME:  addevipsp
    AUTHOR: martin haviar, mcsa
    LASTEDIT: 03/21/2015
    KEYWORDS: receive connector, annonymous Authentication
#>

		param ($newip= $(read-host 'please input NewIP'),$cas =$(read-host 'please input number of CAS server'))
			$connector=Get-ReceiveConnector -identity "chby0+$cas+\devices"
			$connector.remoteipranges += $newip
			set-receiveconnector "chby0+$cas+\devices" -remoteipranges $connector.remoteipranges
		devip}
			






function redevipsp {

<#
.SYNOPSIS
Remove device IP from specific exchange receive connector.
.DESCRIPTION
Remove device IP from specific exchange receive connector with allowed annonymous Authentication.
.Notes 
    NAME:  redevipsp
    AUTHOR: martin haviar, mcsa
    LASTEDIT: 03/21/2015
    KEYWORDS: receive connector, annonymous Authentication
#>

		param ($oldip= $(read-host 'please input OldIP'),$cas =$(read-host 'please input number of CAS server'))
			$connector=Get-ReceiveConnector -identity "chby0+$cas+\devices"
			$connector.remoteipranges.remove("$oldip")
			set-receiveconnector "chby0+$cas+\devices" -remoteipranges $connector.remoteipranges
		devip}
			





function set-database {

<#
.SYNOPSIS
Activate mailbox databases on default mailbox servers.
.DESCRIPTION
If some of mailbox server which is a part of dag go down, databese copy automatically mount on 
another server which is up. After down server go up, databases must be manually mounted, for example using this script.
.Notes 
    NAME:  set-database
    AUTHOR: martin haviar, mcsa
    LASTEDIT: 01/15/2014
    KEYWORDS: receive connector, annonymous Authentication
#>


#MBXY01
if ((Get-MailboxDatabase dby01).server -eq "mbxy01") {write-host "database DBY01 is already mounted on MBXY01" -ForegroundColor Cyan}
else {Move-ActiveMailboxDatabase -Identity 'DBY01' -ActivateOnServer 'MBXY01' -MountDialOverride 'None'; write-host "database DBY01 is already mounting to MBXY01" -ForegroundColor Yellow}

if ((Get-MailboxDatabase dbw01).server -eq "mbxy01") {write-host "database DBW01 is already mounted on MBXY01" -ForegroundColor Cyan}
else {Move-ActiveMailboxDatabase -Identity 'DBW01' -ActivateOnServer 'MBXY01' -MountDialOverride 'None'; write-host "database DBW01 is already mounting to MBXY01" -ForegroundColor Yellow}

if ((Get-MailboxDatabase DBZ02).server -eq "mbxy01") {write-host "database DBZ02 is already mounted on MBXY01" -ForegroundColor Cyan}
else {Move-ActiveMailboxDatabase -Identity 'DBZ02' -ActivateOnServer 'MBXY01' -MountDialOverride 'None'; write-host "database DBZ02 is already mounting to MBXY01" -ForegroundColor Yellow}



if ((Get-MailboxDatabase DBP02).server -eq "mbxy01") {write-host "database DBP02 is already mounted on MBXY01" -ForegroundColor Cyan}
else {Move-ActiveMailboxDatabase -Identity 'DBP02' -ActivateOnServer 'MBXY01' -MountDialOverride 'None'; write-host "database DBP02 is already mounting to MBXY01" -ForegroundColor Yellow}



if ((Get-MailboxDatabase TSYP01).server -eq "mbxy01") {write-host "database TSYP01 is already mounted on MBXY01" -ForegroundColor Cyan}
else {Move-ActiveMailboxDatabase -Identity 'TSYP01' -ActivateOnServer 'MBXY01' -MountDialOverride 'None'; write-host "database TSYP01 is already mounting to MBXY01" -ForegroundColor Yellow}



#MBXY02

if ((Get-MailboxDatabase DBY02).server -eq "mbxy02") {write-host "database DBY02 is already mounted on MBXY02" -ForegroundColor Cyan}
else {Move-ActiveMailboxDatabase -Identity 'DBY02' -ActivateOnServer 'MBXY02' -MountDialOverride 'None'; write-host "database DBY02 is already mounting to MBXY02" -ForegroundColor Yellow}



if ((Get-MailboxDatabase DBW02).server -eq "mbxy02") {write-host "database DBW02 is already mounted on MBXY02" -ForegroundColor Cyan}
else {Move-ActiveMailboxDatabase -Identity 'DBW02' -ActivateOnServer 'MBXY02' -MountDialOverride 'None'; write-host "database DBW02 is already mounting to MBXY02" -ForegroundColor Yellow}



if ((Get-MailboxDatabase DBZ03).server -eq "mbxy02") {write-host "database DBZ03 is already mounted on MBXY02" -ForegroundColor Cyan}
else {Move-ActiveMailboxDatabase -Identity 'DBZ03' -ActivateOnServer 'MBXY02' -MountDialOverride 'None'; write-host "database DBZ03 is already mounting to MBXY02" -ForegroundColor Yellow}



if ((Get-MailboxDatabase VIPYP01).server -eq "mbxy02") {write-host "database VIPYP01 is already mounted on MBXY02" -ForegroundColor Cyan}
else {Move-ActiveMailboxDatabase -Identity 'VIPYP01' -ActivateOnServer 'MBXY02' -MountDialOverride 'None'; write-host "database VIPYP01 is already mounting to MBXY02" -ForegroundColor Yellow}

#MBXY03

if ((Get-MailboxDatabase DBY03).server -eq "mbxy03") {write-host "database DBY03 is already mounted on MBXY03" -ForegroundColor Cyan}
else {Move-ActiveMailboxDatabase -Identity 'DBY03' -ActivateOnServer 'MBXY03' -MountDialOverride 'None'; write-host "database DBY03 is already mounting to MBXY03" -ForegroundColor Yellow}



if ((Get-MailboxDatabase DBW03).server -eq "mbxy03") {write-host "database DBW03 is already mounted on MBXY03" -ForegroundColor Cyan}
else {Move-ActiveMailboxDatabase -Identity 'DBW03' -ActivateOnServer 'MBXY03' -MountDialOverride 'None'; write-host "database DBW03 is already mounting to MBXY03" -ForegroundColor Yellow}



if ((Get-MailboxDatabase DBZ04).server -eq "mbxy03") {write-host "database DBZ04 is already mounted on MBXY03" -ForegroundColor Cyan}
else {Move-ActiveMailboxDatabase -Identity 'DBZ04' -ActivateOnServer 'MBXY03' -MountDialOverride 'None'; write-host "database DBZ04 is already mounting to MBXY03" -ForegroundColor Yellow}



if ((Get-MailboxDatabase VIPWZ01).server -eq "mbxy03") {write-host "database VIPWZ01 is already mounted on MBXY03" -ForegroundColor Cyan}
else {Move-ActiveMailboxDatabase -Identity 'VIPWZ01' -ActivateOnServer 'MBXY03' -MountDialOverride 'None'; write-host "database VIPWZ01 is already mounting to MBXY03" -ForegroundColor Yellow}



if ((Get-MailboxDatabase TSWZ01).server -eq "mbxy03") {write-host "database TSWZ01 is already mounted on MBXY03" -ForegroundColor Cyan}
else {Move-ActiveMailboxDatabase -Identity 'TSWZ01' -ActivateOnServer 'MBXY03' -MountDialOverride 'None'; write-host "database TSWZ01 is already mounting to MBXY03" -ForegroundColor Yellow}



#MBXY04

if ((Get-MailboxDatabase DBY04).server -eq "mbxy04") {write-host "database DBY04 is already mounted on MBXY04" -ForegroundColor Cyan}
else {Move-ActiveMailboxDatabase -Identity 'DBY04' -ActivateOnServer 'MBXY04' -MountDialOverride 'None'; write-host "database DBY04 is already mounting to MBXY04" -ForegroundColor Yellow}



if ((Get-MailboxDatabase DBZ01).server -eq "mbxy04") {write-host "database DBZ01 is already mounted on MBXY04" -ForegroundColor Cyan}
else {Move-ActiveMailboxDatabase -Identity 'DBZ01' -ActivateOnServer 'MBXY04' -MountDialOverride 'None'; write-host "database DBZ01 is already mounting to MBXY04" -ForegroundColor Yellow}



if ((Get-MailboxDatabase DBP01).server -eq "mbxy04") {write-host "database DBP01 is already mounted on MBXY04" -ForegroundColor Cyan}
else {Move-ActiveMailboxDatabase -Identity 'DBP01' -ActivateOnServer 'MBXY04' -MountDialOverride 'None'; write-host "database DBP01 is already mounting to MBXY04" -ForegroundColor Yellow}



if ((Get-MailboxDatabase SMBX01).server -eq "mbxy04") {write-host "database SMBX01 is already mounted on MBXY04" -ForegroundColor Cyan}
else {Move-ActiveMailboxDatabase -Identity 'SMBX01' -ActivateOnServer 'MBXY04' -MountDialOverride 'None'; write-host "database SMBX01 is already mounting to MBXY04" -ForegroundColor Yellow}


write-host `n
write-host "Script successfully finished!" -foregroundcolor red

}