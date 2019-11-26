Write-host "Would you like to create a restore point (Default is No)" -ForegroundColor Yellow 
$Readhost = Read-Host "[Y/N]" 
Switch ($ReadHost) { 
  Y {
    Write-Host "Creating restore point..." -ForegroundColor Gray;
    Write-host Checkpoint-Computer -Description "CYBERPOLICE-RestorePoint" -RestorePointType "MODIFY_SETTINGS"; 
    Write-Host "Restore point made!" -ForegroundColor Green
  } 
  N { Write-Host "Restore point not created." -ForegroundColor Red } 
  Default { Write-Host "Restore point not created." -ForegroundColor Red } 
} 

