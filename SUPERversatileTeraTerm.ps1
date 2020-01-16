#POS��ю�
#20181227 ���ō쐬

############################################
# �ϐ���`
############################################
[System.String]$timeStamp = date -Format "yyyyMMddHHmm"
[System.String]$scriptfile = $MyInvocation.MyCommand.Name.Tostring()
[System.String]$scriptDir = (Split-Path $MyInvocation.MyCommand.Path -parent).Tostring() + "\"
[System.String]$scriptFullpath = $MyInvocation.MyCommand.Path.Tostring()
[System.String]$logDir = "${scriptDir}Logs\"
[System.String]$logFile = $logDir + $scriptFullpath.split("\")[-1] + ".log"
[System.String]$confDir = "${scriptDir}env\"
[System.String]$confFile = "${confDir}test.json"
[System.String]$teraMacroExe = "C:\Program Files\teraterm\ttpmacro.exe"
[System.String]$teraTTLFile = "${confDir}TeraTermMacro.ttl"
[System.String]$comFile = "${scriptDir}commands.txt"

#�ݒ�t�@�C���ǎ�
$confData = Get-Content $confFile | ConvertFrom-Json
[System.String]$IP = $confData.Server.IP
[System.String]$Port = $confData.Server.Port
[System.String]$Prompt = $confData.Server.prompt
[System.String]$User = $confData.User.UserName
[System.String]$Password = $confData.User.Password
[System.String]$teraLog = "${logDir}${timeStamp}_${IP}.log"
[System.String]$KANJICODE = $confData.Server.KANJICODE

############################################
#���O�p�t�H���_�쐬
############################################
if ( ( Test-Path -LiteralPath $logDir -PathType Container) -eq $False ) {
	New-Item $logDir -ItemType Directory |out-null
}

############################################
#�R�}���h�t�@�C���ǎ�
############################################
[array]$commandData = Get-Content $comFile

############################################
#TeraTerm�p�}�N���t�@�C���쐬
############################################
#�����R�[�h����
switch($KANJICODE){
	"UTF8"{
		[System.String]$terainiFile = "${confDir}UTF8.INI"
	}
	"EUC"{
		[System.String]$terainiFile = "${confDir}EUC.INI"

	}
	"SJIS"{
		[System.String]$terainiFile = "${confDir}SJIS.INI"
	}
	default{
	}
}
${prompt}

#�ڑ��p�R�}���h�쐬
Write-Output ("connect `' ${IP}:${Pprt} /ssh /2 /auth=password /user=${User} /passwd=${Password} /f=${terainiFile}`'")  | out-file $teraTTLFile Default
#���O�C�����̃v�����v�g�ҋ@
Write-Output "wait ${prompt}" | out-file $teraTTLFile Default -Append

#���O�L�^�J�n
Write-Output ("logopen `'" + $teraLog + "`' 0 0") | out-file $teraTTLFile Default -Append

foreach($command in $commandData){
	#�R�}���h���s
	Write-Output "sendln `'$command`'" | out-file $teraTTLFile Default -Append
	#Write-Output "wait ${prompt}"
	Write-Output "wait ${prompt}" | out-file $teraTTLFile Default -Append    
}
Write-Output "logclose"  | out-file $teraTTLFile Default -Append 
Write-Output "sendln `'exit`'"| out-file $teraTTLFile Default -Append
Write-Output "end"| out-file $teraTTLFile Default -Append


Start-Process -FilePath $teraMacroExe -ArgumentList $teraTTLFile -Wait