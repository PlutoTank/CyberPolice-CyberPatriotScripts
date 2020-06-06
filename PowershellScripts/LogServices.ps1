Write-Host "CYBER POLICE [Covert Ops] are now going to log all current services..." -ForegroundColor Magenta
$thispath = Split-Path -parent $MyInvocation.MyCommand.Definition
$path = Split-Path -parent $thispath
$output = Get-content $path/CyberPoliceOutput/path.txt
Get-Service | Out-File -FilePath $output/logs/RawServicesLog.txt
Get-Service
Write-Host "The CYBER POLICE [Covert Ops]: End of File" -ForegroundColor Magenta