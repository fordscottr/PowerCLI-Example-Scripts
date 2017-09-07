Add-pssnapin VMware.VimAutomation.Core
Import-Module VMware.PowerCLI
   <#
    .SYNOPSIS Edits snapshots of VM's to have the users fully qualified domain name to be first
	.Needed before running 
    .NOTES  Author:  Scott Ford
    .NOTES  Twitter: 
    #>

    param( 
        $domain = $(read-host  "Enter Your Domain")
    )

foreach ($snap in Get-VM | Get-Snapshot)
{$snapevent = Get-VIEvent -Entity $snap.VM -Types Info -Finish $snap.Created -MaxSamples 1 | Where-Object {$_.FullFormattedMessage -imatch 'Task: Create virtual machine snapshot'}
if ($snapevent -ne $null){
	$description = $snap.Description | Out-String
	if ($description -notlike '*$domain\*'){
		$username = $snapevent.UserName 
		Write-Host $description
		Set-Snapshot $snap -Description "$username  $description"
		Write-Host ( "VM: "+ $snap.VM + ". Snapshot '" + $snap + "' created on " + $snap.Created.DateTime + " by " + $snapevent.UserName +".")}
	
}}
#
$From = "ZeusCreatedSnapshots@bluemedora.com"
$To = "sysadmins@bluemedora.com"
#$Cc = "engops@bluemedora.com"
$Subject = "Snapshot Description Complete"
$Body = "Snapshots are now labeled by user"
$SMTPServer = "smtp-relay.gmail.com"
$SMTPPort = "25"
Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SMTPServer $SMTPServer -port $SMTPPort  


foreach ($center in $viserver) {
	disConnect-VIServer $center -confirm:$false
	}