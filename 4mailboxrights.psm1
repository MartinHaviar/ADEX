function addmr {

<#
.SYNOPSIS
Add mailbox rights.
.DESCRIPTION
Add mailbox rights for user to specified mailbox.
.parameter identity
name of mailbox.
.parameter user
logon name of user which will access the mailbox
.parameter right
choose one of the basic rights. Will be showed after run function.
.Notes 
    NAME:  addmr
    AUTHOR: martin haviar, mcsa
    LASTEDIT: 03/25/2015
    KEYWORDS: mailbox rights
#>

param ($identity = $(read-host 'please input mailbox name'))
       

$exclusions1 = @("/Recoverable Items"
                "/Deletions"
                "/Purges"
                "/Audits"
                "/Versions"                                
                )
$exclus=Get-MailboxFolderStatistics $identity | Where {!($exclusions1 -contains $_.FolderPath)}

$arr=@()
ForEach($f in $exclus) {
 $fname = $identity+ ":" + $f.FolderPath.Replace("/","\");
 if ($fname -like "*ukladanie*")
    {$fname = $fname.split("\")[0];$fname=$fname+ "\"} else {if ($fname -match "Top of Information Store") 
    {$fname = $fname.Replace(“\Top of Information Store”,”\”)}}
 $sel=get-MailboxFolderPermission $fname | select @{n="folderpath";e={$fname}},identity,accessrights;$arr+=$sel}
 $arr | ft -autosize 
 Write-Host "Opravnenia mimo default a anonymous" -ForegroundColor Cyan
 $arr | where {$_.identity -ne "default" -and $_.identity -ne "anonymous"} | ft

write-host " "
write-host " "
$user = $(read-host 'please input user logon name')
write-host ""
Write-Host "Select to which folder do you want to assign permissions(type ALL, if you watnt to select all):" -ForegroundColor Cyan
write-host ""


$fol=$(read-host 'please select folder')
if ($fol -eq "all") {$folder=($arr | where {$_.identity -EQ "default"}).folderpath}
else {$folder=$fol.split()}

write-host `
"
Author               CreateItems, DeleteOwnedItems, EditOwnedItems, FolderVisible, ReadItems
Contributor          CreateItems, FolderVisible
Editor               CreateItems, DeleteAllItems, DeleteOwnedItems, EditAllItems, EditOwnedItems, FolderVisible, ReadItems
None                 FolderVisible
NonEditingAuthor     CreateItems, FolderVisible, ReadItems
Owner                CreateItems, CreateSubfolders, DeleteAllItems, DeleteOwnedItems, EditAllItems, EditOwnedItems, FolderContact, FolderOwner, FolderVisible, ReadItems
PublishingEditor     CreateItems, CreateSubfolders, DeleteAllItems, DeleteOwnedItems, EditAllItems, EditOwnedItems, FolderVisible, ReadItems
PublishingAuthor     CreateItems, CreateSubfolders, DeleteOwnedItems, EditOwnedItems, FolderVisible, ReadItems
Reviewer             FolderVisible, ReadItems"

write-host ""

$right=$(read-host 'please choose apropriate right')

foreach($f in $folder) {
Add-MailboxFolderPermission -Identity $f -User $user -AccessRights $right}


$DN=(get-aduser $user).DistinguishedName
set-aduser $identity -Add @{msExchDelegateListLink=$DN}
}








function remmr {


<#
.SYNOPSIS
remove mailbox rights.
.DESCRIPTION
Remove mailbox rights for user from specified mailbox.
.parameter identity
name of mailbox.
.parameter user
logon name of user which will access the mailbox
.Notes 
    NAME:  remmr
    AUTHOR: martin haviar, mcsa
    LASTEDIT: 03/25/2015
    KEYWORDS: mailbox rights
#>


param ($identity = $(read-host 'please input identity logon name'))
       

$exclusions1 = @("/Recoverable Items"
                "/Deletions"
                "/Purges"
                "/Audits"
                "/Versions"                                
                )
$exclus=Get-MailboxFolderStatistics $identity | Where {!($exclusions1 -contains $_.FolderPath)}

$arr=@()
ForEach($f in $exclus) {
 $fname = $identity+ ":" + $f.FolderPath.Replace("/","\");
 if ($fname -like "*ukladanie*")
    {$fname = $fname.split("\")[0];$fname=$fname+ "\"} else {if ($fname -match "Top of Information Store") 
    {$fname = $fname.Replace(“\Top of Information Store”,”\”)}}
 $sel=get-MailboxFolderPermission $fname | select @{n="folderpath";e={$fname}},identity,accessrights;$arr+=$sel}
 $arr | ft -autosize 
 Write-Host "Opravnenia mimo default a anonymous" -ForegroundColor Cyan
 $arr | where {$_.identity -ne "default" -and $_.identity -ne "anonymous"} | ft

write-host " "
write-host " "
$user = $(read-host 'please input user logon name')
write-host ""
Write-Host "Select to which folder do you want to REMOVE permissions(type ALL, if you watnt to select all):" -ForegroundColor Cyan
write-host ""

$fol=$(read-host 'please select folder')

$dis=(get-aduser $user -Properties displayname).displayname
if ($fol -eq "all") {$folder=($arr | where {$_.identity -match $dis}).folderpath; 
$DN=(get-aduser $user).DistinguishedName
set-aduser $identity -remove @{msExchDelegateListLink=$DN}}
else {$folder=$fol.split()}


foreach($f in $folder) {
remove-MailboxFolderPermission -Identity $f -User $user}
}







function getmr {


<#
.SYNOPSIS
Add mailbox rights.
.DESCRIPTION
Get mailbox rights for specified mailbox.
.parameter identity
name of mailbox.
.Notes 
    NAME:  getmr
    AUTHOR: martin haviar, mcsa
    LASTEDIT: 03/26/2015
    KEYWORDS: mailbox rights
#>


param ($identity = $(read-host 'please input identity logon name'))
       
$exclusions1 = @("/Recoverable Items"
                "/Deletions"
                "/Purges"
                "/Audits"
                "/Versions"                                
                )
$exclus=Get-MailboxFolderStatistics $identity | Where {!($exclusions1 -contains $_.FolderPath)}

$arr=@()
ForEach($f in $exclus) {
 $fname = $identity+ ":" + $f.FolderPath.Replace("/","\");
 if ($fname -like "*ukladanie*")
    {$fname = $fname.split("\")[0];$fname=$fname+ "\"} else {if ($fname -match "Top of Information Store") 
    {$fname = $fname.Replace(“\Top of Information Store”,”\”)}}
 $sel=get-MailboxFolderPermission $fname | select @{n="folderpath";e={$fname}},identity,accessrights;$arr+=$sel}
 $arr | ft -autosize 
 Write-Host ""
 Write-Host "Opravnenia mimo default a anonymous" -ForegroundColor Cyan
 $arr | where {$_.identity -ne "default" -and $_.identity -ne "anonymous"} | ft
}

