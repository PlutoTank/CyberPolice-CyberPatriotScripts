Write-Host "CYBER POLICE [Covert Ops] are now going to generate reports on this system's GPOs..." -ForegroundColor Magenta
$thispath = Split-Path -parent $MyInvocation.MyCommand.Definition
$path = Split-Path -parent $thispath
$output = Get-content $path/CyberPoliceOutput/gpoInfo/gpoReports
Import-Module GroupPolicy
Get-GPOReport -All -ReportType HTML -Path $output
Write-Host "The CYBER POLICE [Covert Ops]: End of operation" -ForegroundColor Magenta