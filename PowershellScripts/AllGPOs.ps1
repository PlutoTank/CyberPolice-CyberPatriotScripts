Write-Host "CYBER POLICE [Covert Ops] are now going to show all GPOs in domain..." -ForegroundColor Magenta
$thispath = Split-Path -parent $MyInvocation.MyCommand.Definition
$path = Split-Path -parent $thispath
$output = Get-content $path/CyberPoliceOutput/path.txt
Get-GPO -all | Out-File -FilePath $output/logs/AllGPOsLog.txt
Get-Content $output/logs/AllGPOsLog.txt
Write-Host "The CYBER POLICE [Covert Ops]: End of File" -ForegroundColor Magenta