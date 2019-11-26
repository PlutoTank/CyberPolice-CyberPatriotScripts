Write-Host "CYBER POLICE are now disabling bad Windows features..." -ForegroundColor Gray
$thispath = Split-Path -parent $MyInvocation.MyCommand.Definition
$path = Split-Path -parent $thispath
$WinFeatConfigFile = "$path\ConfigFiles\BadWinFeatures.txt"
$tools="$path\Tools"
$output = Get-content $path/CyberPoliceOutput/path.txt
$cpuArc="$output\CPUARCHITECTURE.txt" 
Switch ($cpuArc) { 
    AMD64 {$DISM="$tools\DISMAMD64"} 
    ARM64 {$DISM="$tools\DISMARM64"} 
    ARM {$DISM="$tools\DISMARM"}
    Default {$DISM="$tools\DISMAMD64"} 
}

Write-Host "Using DISM from location: $DISM\DISM" -ForegroundColor Gray
Import-Module "$DISM\DISM"

foreach ($line in Get-Content $WinFeatConfigFile) {
    Write-Host $allFeatures
    $check=Get-WindowsOptionalFeature -Online -FeatureName $line
    Write-Host $check
    pause
    Disable-WindowsOptionalFeature -Online -FeatureName $line
}

Write-Host "The CYBER POLICE have disabled bad Windows Features" -ForegroundColor Gray