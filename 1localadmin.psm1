Function Get-LocalGroup {

<#
.SYNOPSIS
Retrieves membership of local administrators group.
.DESCRIPTION
Scan every accessible computer inside domain and then enumerate membership of local administrator group using [ADSI] provider.
Generate seven excel tables with legal and illegal users.
.PARAMeter user
user account which have problems with authentification
.Notes 
    NAME:  Get-LocalGroup
    AUTHOR: martin haviar, mcsa
    LASTEDIT: 08/25/2016
    KEYWORDS: [ADSI], membership,local admin group
#>

[CmdletBinding()]
param([string]$outputdir = "D:\usersdata\haviarm\Desktop\testL\localadm",
      [string]$OU = $(read-host 'please input DN of search OU in AD, for example: OU=TN,OU=RS,DC=mil,DC=sk'))

	
begin {

    $time=(get-date).ToString("dd.MM.yyyy HH:mm:ss")
    $time1=(get-date).ToString("dd.MM.yyyy_HH.mm.ss")
    $x=0
    $y=0
    $z=0
    $i=0
    $c=0
    $a=0
    $b=0
    $f=0
    $g=0
    
    $sw=$(((get-date).adddays(-42) - [datetime]::parse('1601-01-01')).ticks)
    $comps=Get-ADComputer -Searchbase "$ou" -Properties name,lastlogontimestamp -Filter  {lastLogonTimestamp -ge $sw} | select name
    $count=$comps.count
   	$LocalGroupName = "Administrators"
    $OUT=$OutputDir+"\"+$OU.substring(3,1)+$time1
    $OutputDir=new-item -ItemType directory -Path "$OUT"

	$OutputFile  = Join-Path $OutputDir "Online_$time1.csv"
    $outputfile1 = Join-Path $OutputDir "Offline_$time1.csv"
    $outputfile2 = Join-Path $OutputDir "FailedQueryMembers_$time1.csv"
    $outputfile3 = Join-Path $OutputDir "UnRecognizedMember_$time1.csv"
    $outputfile4 = Join-Path $OutputDir "IllegalMembers_$time1.csv"
    $outputfile5 = Join-Path $OutputDir "LegalMembers_$time1.csv"
    $outputfile6 = Join-Path $OutputDir "ComputersIllegalMembers_$time1.csv"
    $outputfile7 = Join-Path $OutputDir "ComputersLegalMembers_$time1.csv"

	Write-Host "Script will write the output to $OutputFile, $outputfile1, $outputfile2, $outputfile3, $OutPutFile4, $OutPutFile5, $OutPutFile6, $OutPutFile7" -ForegroundColor Gray

	Add-Content -Path $OutPutFile -Value @("","$time","ComputerName, LocalGroupName, Status, MemberType, MemberDomain, MemberName, Count") #online, admin group and members are queryable
    Add-Content -Path $OutPutFile1 -Value @("","$time","ComputerName, Status, Count")                                                      #offline, not pingable
    Add-Content -Path $OutPutFile2 -Value @("","$time","Count,ComputerName, Status, Reason")                                               #online, admin group not queryable
    Add-Content -Path $OutPutFile3 -Value @("","$time","Count,ComputerName, LocalGroupName, Status, Reason")                               #online, admin group queryable, but members are NOT queryable
    Add-Content -Path $OutPutFile4 -Value @("","$time","ComputerName, LocalGroupName, Status, MemberType, MemberDomain, MemberName, Count")
    Add-Content -Path $OutPutFile5 -Value @("","$time","ComputerName, LocalGroupName, Status, MemberType, MemberDomain, MemberName, Count")
    Add-Content -Path $OutPutFile6 -Value @("","$time","ComputerName, LocalGroupName, Status, MemberType, MemberDomain, MemberName, UserPerCompCount, CompleteCount")
    Add-Content -Path $OutPutFile7 -Value @("","$time","ComputerName, LocalGroupName, Status, MemberType, MemberDomain, MemberName, Count")
    }


process {


	ForEach($Computer in $Comps) {$c++; $computer=$Computer.name;
		Write-host "Working on $Computer" -ForegroundColor Cyan
		If(!(Test-Connection -ComputerName $Computer -Count 1 -Quiet)) 
            {$x++;Write-host "$Computer is offline. Proceeding with next computer, count $x" -ForegroundColor Green
			Add-Content -Path $OutputFile1 -Value "$Computer, Offline, $x"}
            


         else {

            $membernames=@()
            $MemberTypes=@()
            $MemberDomains=@()
            $membernames1=@()
            $MemberTypes1=@()
            $MemberDomains1=@()
            
			Write-host "connecting on $computer local users and groups.." -BackgroundColor DarkMagenta
			try {
				$group = [ADSI]"WinNT://$Computer/$LocalGroupName"
				$members = @($group.Invoke("Members"))
                if ($group) {$i++}
				Write-host "Successfully queries the members of $computer, Count $i " -BackgroundColor magenta -ForegroundColor Cyan
				if(!$members) {
					Add-Content -Path $OutputFile -Value "$Computer,$LocalGroupName,NoMembersFound,$i"
					Write-host "No members found in the group on $computer" -ForegroundColor DarkCyan
					continue}}		
			catch {$y++;
				Write-host "Count $y, failed to query the members of $computer. Reason is: $_" -ForegroundColor Yellow -BackgroundColor DarkGreen
				Add-Content -Path $OutputFile2 -Value "$y,$Computer,FailedToQuery, $_"
				Continue}

			foreach($member in $members) {
				try {
					$MemberName = $member.GetType.Invoke().Invokemember("Name","GetProperty",$null,$member,$null)
					$MemberType = $member.GetType.Invoke().Invokemember("Class","GetProperty",$null,$member,$null)
					$MemberPath = $member.GetType.Invoke().Invokemember("ADSPath","GetProperty",$null,$member,$null)
					$MemberDomain = $null

					if($MemberPath -match "^Winnt\:\/\/(?<domainName>\S+)\/(?<CompName>\S+)\/") 
						{if($MemberType -eq "User") 
							{$MemberType = "LocalUser"}
						 elseif($MemberType -eq "Group")
							{$MemberType = "LocalGroup"}
						$MemberDomain = $matches["CompName"]}

                        elseif($MemberPath -match "^WinNT\:\/\/(?<domainname>\S+)/") 
						{if($MemberType -eq "User") 
							{$MemberType = "DomainUser"}
						 elseif($MemberType -eq "Group")
							{$MemberType = "DomainGroup"}
						$MemberDomain = $matches["domainname"]}

                        else {$MemberType = "Unknown"
						      $MemberDomain = "Unknown"
                                $z++;
					Write-host "Count $z, Unknown SID" -BackgroundColor DarkRed -ForegroundColor Cyan
					Add-Content -Path $OutputFile3 -Value "$z,$Computer, $LocalGroupName, FailedRecognizeMember, $_"}

                    $membernames1+=$membername
                    $MemberTypes1+=$MemberType
                    $MemberDomains1+=$MemberType
                    
                    $membernames+='"'+$membername+'"'+'&CHAR(10)&'
                    $MemberTypes+='"'+$MemberType+'"'+'&CHAR(10)&'
                    $MemberDomains+='"'+$MemberDomain+'"'+'&CHAR(10)&'
                                        
                   
                    if($MemberName -ne "sccm.deploy" -and $MemberName -ne "manmil" -and $MemberName -ne "SG_G_Y_ADMINS_PC" -and $MemberName -ne "SG_G_W_ADMINS_PC" -and $MemberName -ne "sccm_admins"`
                       -and $MemberName -ne "SG_G_P_ADMINS_PC" -and $MemberName -ne "SG_G_Z_ADMINS_PC" -and $MemberName -ne "administrator" -and $MemberName -ne "Domain Admins" -and $Membername -ne "ADMIN-PC") 
                        {$a++; write-host "contain unauthorized account:$membername, between local admins.. count $a" -BackgroundColor Red -ForegroundColor Yellow
                         Add-Content -Path $outputfile4 -Value "$computer, $LocalGroupName, Illegal, $MemberType, $MemberDomain, $MemberName, $a"}
                         else {$b++; write-host "contain authorized account:$membername, between local admins.. count $b" -BackgroundColor Green -ForegroundColor Blue
                               Add-Content -Path $outputfile5 -Value "$computer, $LocalGroupName, legal, $MemberType, $MemberDomain, $MemberName, $b"}

				    }

                    catch {$z++;
					Write-host "Count $z, failed to query details of a member. Reason is: $_" -BackgroundColor DarkRed -ForegroundColor Cyan
					Add-Content -Path $OutputFile3 -Value "$z,$Computer, $LocalGroupName, FailedRecognizeMember, $_"}
				                        }


                    $membernames='='+($membernames)
                    $membernames=($membernames).trimend("&CHAR(10)&")
                    $MemberTypes='='+($MemberTypes)
                    $MemberTypes=($MemberTypes).trimend("&CHAR(10)&")
                    $MemberDomains='='+($MemberDomains)
                    $MemberDomains=($MemberDomains).trimend("&CHAR(10)&")
				    
                    Add-Content -Path $OutPutFile -Value "$Computer,$LocalGroupName,MembersFound,$MemberTypes,$MemberDomains,$MemberNames,$i"



            $e=0
            foreach ($membername in $membernames1) 
            {if ($MemberName -ne "sccm.deploy" -and $MemberName -ne "manmil" -and $MemberName -ne "SG_G_Y_ADMINS_PC" -and $MemberName -ne "SG_G_W_ADMINS_PC" -and $MemberName -ne "sccm_admins"`
            -and $MemberName -ne "SG_G_P_ADMINS_PC" -and $MemberName -ne "SG_G_Z_ADMINS_PC" -and $MemberName -ne "administrator" -and $MemberName -ne "Domain Admins" -and $Membername -ne "ADMIN-PC"){$e++}} 
            if ($e -ne 0) {$f++;Add-Content -Path $OutPutFile6 -Value "$Computer,$LocalGroupName,IllegalMembersFound,$MemberTypes,$MemberDomains,$MemberNames,$e,$f"
                                write-host "Total count of computers with illegal account: $f" -ForegroundColor White} 
                          else {$g++;Add-Content -Path $OutPutFile7 -Value "$Computer,$LocalGroupName,OnlylegalMembersFound,$MemberTypes,$MemberDomains,$MemberNames,$g"
          		                write-host "Total count of computers with legal account: $g" -ForegroundColor White}
          
          }
    $comps=$comps.Count
    Write-Progress -Activity "dotazujem clenstvo local admin skupin v $OU" -status `
    "overenych $c z $count PC, Offline $x, FailedQueryMembers $y, UnRecognizedMember $z, IllegalMembers $a, LegalMembers $b, illegal comps: $f, legal comps $g"
	}}

end {$j=$i+$y; 
    write-host "Target scope:$OU, spolu $c, online $j, offline $x, SuccQueryMembers $i, FailedQueryMembers $y, UnRecognizedMembers $z, legalMembers=$b, IllegalMembers=$a, ComputerLegalMembers=$g, ComputerIllegalMembers=$f" -ForegroundColor Yellow
    Add-Content -Path $OutPutFile -Value @("Target scope:$OU", "totalPC=$c", "online=$j", "offline=$x", "SuccQueryMembers=$i", "FailedQueryMembers=$y",`
    "UnRecognizedMembers=$z", "legalMembers=$b", "IllegalMembers=$a", "ComputerLegalMembers=$g", "ComputerIllegalMembers=$f")
    Add-Content -path $outputfile1 -Value @("Target scope:$OU","total=$x") #Offline
    Add-Content -path $outputfile2 -Value @("Target scope:$OU","total=$y") #FailedQueryMembers
    Add-Content -path $outputfile3 -Value @("Target scope:$OU","total=$z") #UnRecognizedMembers
    Add-Content -path $outputfile4 -Value @("Target scope:$OU","total=$a","totalPC=$c", "online=$j", "offline=$x", "SuccQueryMembers=$i", "FailedQueryMembers=$y",`
    "UnRecognizedMembers=$z", "legalMembers=$b", "IllegalMembers=$a", "ComputerLegalMembers=$g", "ComputerIllegalMembers=$f") #IllegalMembers
    Add-Content -path $outputfile5 -Value @("Target scope:$OU","total=$b","totalPC=$c", "online=$j", "offline=$x", "SuccQueryMembers=$i", "FailedQueryMembers=$y",`
    "UnRecognizedMembers=$z", "legalMembers=$b", "IllegalMembers=$a", "ComputerLegalMembers=$g", "ComputerIllegalMembers=$f") #LegalMembers
    Add-Content -path $outputfile6 -Value @("Target scope:$OU","total=$f") #ComputersIllegalMembers
    Add-Content -path $outputfile7 -Value @("Target scope:$OU","total=$g") #ComputersLegalMembers
    }    
    
    
    }
