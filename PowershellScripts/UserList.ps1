Write-Host Getting data on users... -ForegroundColor Gray
$thispath=Split-Path -parent $MyInvocation.MyCommand.Definition
$path = Split-Path -parent $thispath
#Write-Host $path
$path2=Get-content $path/CyberPoliceOutput/path.txt
#Write-Host $path2
$accounts = Get-Wmiobject Win32_UserAccount -filter 'LocalAccount=TRUE' | select-object -expandproperty Name

if (!(Test-Path "$path2/users.txt"))
{
   New-Item $path2/users.txt -ItemType file | Out-Null
   Write-Host "Created users.txt file!" -ForegroundColor Yellow
}

Write-host "Are you on an AD (Default is No)" -ForegroundColor Yellow 
$Readhost = Read-Host "[Y/N]" 
Switch ($ReadHost) { 
  Y {
   if (!(Test-Path "$path2/usersAD.txt"))
   {
      New-Item $path2/usersAD.txt -ItemType file | Out-Null
      Write-Host "Created usersAD.txt file!" -ForegroundColor Yellow
   }
   if (!(Test-Path "$path2/ADConnectedComputers.txt"))
   {
      New-Item $path2/ADConnectedComputers.txt -ItemType file | Out-Null
      Write-Host "Created ADConnectedComputers.txt file!" -ForegroundColor Yellow
   }
   Get-ADComputer -Filter * -Properties ipv4Address, OperatingSystem, OperatingSystemServicePack | Format-List name, ipv4*, oper* | Out-File -FilePath $path2/ADConnectedComputers.txt
   Write-Host "[AD] Connected Computers added to text file!" -ForegroundColor Yellow;
   Get-ADUser -Filter *  | Out-File -FilePath $path2/usersAD.txt
   Write-Host "[AD] Users added to text file!" -ForegroundColor Yellow;
  } 
  N { Write-Host "Ok." -ForegroundColor Gray } 
  Default { Write-Host "Ok." -ForegroundColor Gray } 
} 

Clear-content "$path2\users.txt"
foreach($l in $accounts){
   Add-Content -Path $path2\users.txt -Value $l -PassThru
}

Write-Host "Users added to text file!" -ForegroundColor Yellow;
