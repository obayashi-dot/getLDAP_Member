#############################################
#Variables
#############################################
$dt = (get-date -format yyyyMMddHHmm)
$scriptfile = $MyInvocation.MyCommand.Name.Tostring()
$scriptDir = (Split-Path $MyInvocation.MyCommand.Path -parent).Tostring() + "\"
$scriptFullpath = $MyInvocation.MyCommand.Path.Tostring()
$logDir = $scriptDir + "\logs\$dt\"
$logFile = $logDir + $scriptFullpath.split("\")[-1] + "_" + $dt +".log"
$resultFile = $logDir + "Result" + "_" + $dt +".csv"

############################################
#Make log directory
############################################
if ( ( Test-Path -LiteralPath $logDir -PathType Container) -eq $False ) {
	New-Item $logDir -ItemType Directory |out-null
}

############################################
#main
############################################
$directory = "LDAP://<your_ldap_address>"
$root = New-Object -TypeName System.DirectoryServices.DirectoryEntry($directory,$null,$null,'FastBind')
$query = New-Object System.DirectoryServices.DirectorySearcher($root,"(objectclass=Person)")
foreach ($user in $($query.findall())){
	[array]$Allmembers += New-object -TypeName PSObject -Property @{
		"department" = if($user.Properties.physicaldeliveryofficename.count -ne 0){$user.Properties.physicaldeliveryofficename[0]}else{""}
		"title" = if($user.Properties.title.count -ne 0){$user.Properties.title}else{""} 
		"mailaddress" = if($user.Properties.mail.count -ne 0){$user.Properties.mail[0]}else{""}
		"name" = if($user.Properties.'display-name'.count -ne 0){$user.Properties.'display-name'[0]}else{""}
		"uid" = if($user.Properties.uid.count -ne 0){$user.Properties.uid[0]}else{""}
		}
}

############################################
#Output CSV file
############################################
$Allmembers | export-csv $resultFile -Encoding utf8 -NoTypeInformation