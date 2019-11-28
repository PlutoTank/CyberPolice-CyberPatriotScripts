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

Clear-content "$path2\users.txt"
foreach($l in $accounts){
   Add-Content -Path $path2\users.txt -Value $l -PassThru
}
Write-Host "Users added to text file!" -ForegroundColor Yellow;
