
#Create a pop up window to notify of connection
function Alert ( $info ){
	$wshell = New-Object -ComObject Wscript.Shell
	$wshell.Popup("Connection found",0,"NOOO!",0x1)

	$log = "D:\Desktop\local_net_check.log"
	
	Write-output $(Get-Date)| Out-File -FilePath $log -append
	Write-output $info | Out-File -FilePath $log -append
	Write-output "========================================================" |
	Out-File -FilePath $log -append
	
	& $command $log
}

#Removes last octet of IP address and appends wildcard *
function IPnetFix ( $str ){
		while ($str.SubString($str.Length-1) -notmatch "\."){

			#Write-output $str.SubString($str.length-1)
			$str = $str.SubString(0,$str.length-1)
			#Write-output $str
		}
	return $str + "*"
}

#Get IP address of PC
#Select used on the end because of VMware adapter IP is listed also
function GetIP{
	return Get-NetIPAddress -InterfaceAlias LAN |
	Where { $_.IPAddress } | Select -Expand IPAddress
}

$IP = GetIP
$IPnet = IPnetFix( $IP )

Write-output $IP
Write-output $IPnet
Write-output "==========================================="

while($true){

	$cons = netstat -n
	$cons = $cons[4..$cons.count];
	$formatted = @()

	foreach ($line in $cons) {	

		$line = $line -replace '^\s+', ''
		$line = $line -split '\s+'
		
		$properties = @{
			Proto = $line[0]
			Laddr = $line[1]
			Faddr = $line[2]
			State = $line[3]	
		}
		
		$formatted += New-Object -TypeName PSObject -Property $properties
	 }

	 foreach ($prop in $formatted) {

	 
		if( $prop.Faddr -match $IPnet ) {
			Alert( $prop )
			sleep 30
		}
	 }

	write-output "NOTHING..."

	sleep 10
}