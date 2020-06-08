Write-Host "CYBER POLICE [Covert Ops] are now going to attempt to backup event logs (last 7 days)..." -ForegroundColor Magenta
$thispath = Split-Path -parent $MyInvocation.MyCommand.Definition
$path = Split-Path -parent $thispath
$output = Get-content $path/CyberPoliceOutput/path.txt
New-Item -ItemType Directory -Force -Path $output/logs/eventLogsBackup | Out-Null

Set-Variable -Name EventAgeDays -Value 7
Set-Variable -Name LogNames -Value @("Application", "System", "Security")
Set-Variable -Name ExportFolder -Value $output\logs\eventLogsBackup\

Set-Variable -Name ServerNames -Value $env:computername
 
$now=get-date
$startdate=$now.adddays(-$EventAgeDays)

$quick=0

Write-host "Are you on an AD (Default is No)" -ForegroundColor Yellow
$Readhost = Read-Host "[Y/N]" 
Switch ($ReadHost) { 
  Y {
    $ServerNames = Get-ADComputer -Filter * | Format-List name | Out-String
    $ServerNames = $ServerNames.split(':')[1] 
    $ServerNames = $ServerNames -replace '\s',''
    $LogNames += "DNS Server"
    $LogNames += "Directory Service"
    Write-Host "Ok." -ForegroundColor Green
  } 
  N { Write-Host "Ok." -ForegroundColor Gray } 
  Default { Write-Host "Ok." -ForegroundColor Gray } 
} 
Write-host "Do you want to save message information... its slower (Default is No)" -ForegroundColor Yellow
$doQuick = Read-Host "[Y/N]" 
Switch ($doQuick) { 
  Y {
   $quick=1
   Write-Host "Ok." -ForegroundColor Green
  } 
  N { 
    $quick=0
    Write-Host "Ok." -ForegroundColor Gray } 
  Default { 
    $quick=0
    Write-Host "Ok." -ForegroundColor Gray } 
} 
Write-host "Found computers:" -ForegroundColor Yellow
Write-Host $ServerNames -ForegroundColor Cyan

Write-host "Please enter the name of the computer you want to back up the logs of (Case sensitive)" -ForegroundColor Yellow
$comp = Read-Host "Server Name" 

foreach($log in $LogNames)
{
    Write-Host Processing $comp\$log -ForegroundColor Yellow
    $el = get-eventlog -ComputerName $comp -log $log -After $startdate
    $el_c = $el | Sort-Object TimeGenerated 
    $ExportFile=$ExportFolder + $comp + "-" + $log + "-Log-" + $now.ToString("yyyy-MM-dd---hh-mm-ss") + ".csv"
    Write-Host Exporting $log Log to $ExportFile
    if ($quick -eq 1) {
      $el_c | Select EntryType, TimeGenerated, Source, EventID, MachineName, Message | Export-CSV $ExportFile -NoTypeInfo
    }
    else {
      $el_c | Select EntryType, TimeGenerated, Source, EventID, MachineName | Export-CSV $ExportFile -NoTypeInfo
    }
    Write-Host Complete!
    Write-Host Done exporting $log on $comp! -ForegroundColor Green
}
Write-Host "The CYBER POLICE [Covert Ops]: done backing up event logs for" + $comp -ForegroundColor Magenta