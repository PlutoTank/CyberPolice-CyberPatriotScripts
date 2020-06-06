Write-Host "CYBER POLICE [Covert Ops] are now going to log firewall rules..." -ForegroundColor Magenta
$thispath = Split-Path -parent $MyInvocation.MyCommand.Definition
$path = Split-Path -parent $thispath
$output = Get-content $path/CyberPoliceOutput/path.txt
get-netfirewallrule | select-object name, group, action, enabled, profile | export-csv $output/logs/FirewallLog.csv
Write-Host "The CYBER POLICE [Covert Ops]: End of logging. Check logs folder in output!" -ForegroundColor Magenta