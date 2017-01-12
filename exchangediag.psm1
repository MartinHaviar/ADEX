

function stats {

<#
.SYNOPSIS
Generate user mailbox statistics.
.DESCRIPTION
Generate user mailbox statistics accross slovak republic through local branches.
.Notes 
    NAME:  stats
    AUTHOR: martin haviar, mcsa
    LASTEDIT: 03/25/2015
    KEYWORDS: receive connector, annonymous Authentication
#>

get-aduser -Server dcy03  -filter {enabled -eq "false"} | Set-ADUser -add @{extensionattribute4 = "1"}

Start-Sleep 1

$tn=get-dynamicdistributiongroup tnusers
$ba=get-dynamicdistributiongroup bausers
$po=get-dynamicdistributiongroup pousers
$zv=get-dynamicdistributiongroup zvusers
$na=get-dynamicdistributiongroup nausers
$eu=get-dynamicdistributiongroup euusers



$tnc=(Get-Recipient -DomainController dcy03 -ResultSize unlimited -RecipientPreviewFilter "((((-not(CustomAttribute4 -eq '1')) -and `
(RecipientType -eq 'UserMailbox'))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*'))`
 -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox'))`
  -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')))" -OrganizationalUnit $tn.recipientcontainer | measure)



$tnco=$tnc.count



$bac=(Get-Recipient -DomainController dcy03 -ResultSize unlimited -RecipientPreviewFilter "((((-not(CustomAttribute4 -eq '1')) -and `
(RecipientType -eq 'UserMailbox'))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*'))`
 -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox'))`
  -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')))" -OrganizationalUnit $ba.recipientcontainer | measure)



$baco=$bac.count

$zvc=(Get-Recipient -DomainController dcy03 -ResultSize unlimited -RecipientPreviewFilter "((((-not(CustomAttribute4 -eq '1')) -and `
(RecipientType -eq 'UserMailbox'))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*'))`
 -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox'))`
  -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')))" -OrganizationalUnit $zv.recipientcontainer | measure)



$zvco=$zvc.count



$poc=(Get-Recipient -DomainController dcy03 -ResultSize unlimited -RecipientPreviewFilter "((((-not(CustomAttribute4 -eq '1')) -and `
(RecipientType -eq 'UserMailbox'))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*'))`
 -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox'))`
  -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')))" -OrganizationalUnit $po.recipientcontainer | measure)



$poco=$poc.count



$nac=(Get-Recipient -DomainController dcy03 -ResultSize unlimited -RecipientPreviewFilter "((((-not(CustomAttribute4 -eq '1')) -and `
(RecipientType -eq 'UserMailbox'))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*'))`
 -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox'))`
  -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')))" -OrganizationalUnit $na.recipientcontainer | measure)



$naco=$nac.count



$euc=(Get-Recipient -DomainController dcy03 -ResultSize unlimited -RecipientPreviewFilter "((((-not(CustomAttribute4 -eq '1')) -and `
(RecipientType -eq 'UserMailbox'))) -and (-not(Name -like 'SystemMailbox{*')) -and (-not(Name -like 'CAS_{*'))`
 -and (-not(RecipientTypeDetailsValue -eq 'MailboxPlan')) -and (-not(RecipientTypeDetailsValue -eq 'DiscoveryMailbox'))`
  -and (-not(RecipientTypeDetailsValue -eq 'ArbitrationMailbox')))" -OrganizationalUnit $eu.recipientcontainer | measure)



$euco=$euc.count




$sum=$TNCO+$BACO+$ZVCO+$POCO+$NACO+$EUCO




Write-Host "Pocty mailboxov (only enabled users) pre jednotlive lokality:" -ForegroundColor Cyan



WRITE-HOST ""

write-host "ZAPAD:   $TNCO" -ForegroundColor Yellow



write-host "JUH:     $BACO" -ForegroundColor Yellow



write-host "STRED:   $ZVCO" -ForegroundColor Yellow



write-host "VYCHOD:  $POCO" -ForegroundColor Yellow



write-host "NA:      $NACO" -ForegroundColor Yellow



write-host "EU:      $EUCO" -ForegroundColor Yellow



WRITE-HOST ""



Write-Host "SPOLU:   $sum" -ForegroundColor Magenta
}


function dag {

$dag=(Get-DatabaseAvailabilityGroup DAGY01).servers
foreach ($server in $dag)

{ Get-MailboxDatabaseCopyStatus -Server $server }}


function testrepl {

$dag=(Get-DatabaseAvailabilityGroup DAGY01).servers
foreach ($server in $dag)

{ test-replicationhealth -server $server  }}


function dagadv {
$clientready=$false
$dag=(Get-DatabaseAvailabilityGroup DAGY01).servers
foreach ($server in $dag)

{ 
Do {
		    If ((Get-MailboxDatabaseCopyStatus -Server $server).status -eq "servicedown" -or (Get-MailboxDatabaseCopyStatus -Server $server).status -eq "failed" ) 
			{		
			write-output "$server DAG's databases are not ready yet besause replication service is already starting."
			start-sleep -s 1
			}
		    else {$clientready = $true; Get-MailboxDatabaseCopyStatus -Server $server}
		   }
		until ($clientReady)}}




















