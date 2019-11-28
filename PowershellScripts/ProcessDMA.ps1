Write-Host "The CYBER POLICE are managing services..." -ForegroundColor Gray
$thispath = Split-Path -parent $MyInvocation.MyCommand.Definition
$path = Split-Path -parent $thispath
$serviceConfigpath = "$path/ConfigFiles/Services"
$path2 = Get-content $path/CyberPoliceOutput/path.txt
$servicesD = @()
$servicesM = @()
$servicesA = @()

if (!(Test-path "$path2\Services\ChangedServices.txt")) { New-Item -path $path2\Services\ChangedServices -name ChangedServices.txt -type "file" -Force | Out-Null}

Write-host "Would you like the CYBER POLICE to manage services (Default is No)" -ForegroundColor Yellow 
$Readhost = Read-Host "[Y/N]" 
Switch ($ReadHost) { 
    Y {
        Write-Host "The CYBER POLICE will go ahead and enforce the law!" -ForegroundColor Green

        foreach ($line in Get-Content $serviceConfigpath/Disabled.txt) {
            $servicesD += $line
        }
        foreach ($line in Get-Content $serviceConfigpath/Manual.txt) {
            $servicesM += $line
        }
        foreach ($line in Get-Content $serviceConfigpath/Auto.txt) {
            $servicesA += $line
        }

        Write-Host "CYBER POLICE are disabling bad services..." -ForegroundColor Gray
        foreach ($ser in $servicesD) {
            $serviceCheck = Get-Service -Name $ser -ErrorAction SilentlyContinue
            if ($serviceCheck.Length -gt 0) {
                Write-Host "Disabling service: $ser" -ForegroundColor Yellow
                $serST = Get-WmiObject -Class Win32_Service -Filter "Name='$ser'"
                $starttype = $serST | Select-Object StartMode
                if (!($starttype -like '*Disabled*')) {
                    Write-Host "$ser status changed!" -ForegroundColor Cyan
                    "$ser set to Disabled">>$path2\Services\ChangedServices.txt 
                }
                Set-Service $ser -StartupType Disabled
                Stop-Service $ser -Force
                Write-Host "$ser has been disabled" -ForegroundColor Green
            }
            else {
                Write-Host "$ser does not exist, nothing happened!" -ForegroundColor Red
            }
        }
        Write-Host "CYBER POLICE disabled bad services" -ForegroundColor Green
        Write-Host "CYBER POLICE are setting services to manual..." -ForegroundColor Gray 
        foreach ($ser in $servicesM) {
            $serviceCheck = Get-Service -Name $ser -ErrorAction SilentlyContinue
            if ($serviceCheck.Length -gt 0) {
                Write-Host "Making service manual: $ser" -ForegroundColor Yellow
                $serST = Get-WmiObject -Class Win32_Service -Filter "Name='$ser'"
                $starttype = $serST | Select-Object StartMode
                if (!($starttype -like '*Manual*')) {
                    Write-Host "$ser status changed!" -ForegroundColor Cyan
                    "$ser set to Manual">>$path2\Services\ChangedServices.txt 
                }
                Set-Service $ser -StartupType Manual
                Write-Host "$ser has been set to manual" -ForegroundColor Green
            }
            else {
                Write-Host "$ser does not exist, nothing happened!" -ForegroundColor Red
            }
        }
        Write-Host "CYBER POLICE made services manual" -ForegroundColor Green
        Write-Host "CYBER POLICE are setting services to automatic..." -ForegroundColor Gray
        foreach ($ser in $servicesA) {
            $serviceCheck = Get-Service -Name $ser -ErrorAction SilentlyContinue
            if ($serviceCheck.Length -gt 0) {
                Write-Host "Making service automatic: $ser" -ForegroundColor Yellow
                $serST = Get-WmiObject -Class Win32_Service -Filter "Name='$ser'"
                $starttype = $serST | Select-Object StartMode
                if (!($starttype -like '*Auto*')) {
                    Write-Host "$ser status changed!" -ForegroundColor Cyan
                    "$ser set to Automatic">>$path2\Services\ChangedServices.txt 
                }
                Set-Service $ser -StartupType Automatic
                Write-Host "$ser has been set to automatic" -ForegroundColor Green
            }
            else {
                Write-Host "$ser does not exist, nothing happened!" -ForegroundColor Red
            }
        }
        Write-Host "CYBER POLICE made services automatic" -ForegroundColor Green
        Write-Host "CYBER POLICE are done managing services!" -ForegroundColor Green
    } 
    N { Write-Host "CYBER POLICE will not enforce the law." -ForegroundColor Red } 
    Default { Write-Host "YBER POLICE will not enforce the law." -ForegroundColor Red } 
}
