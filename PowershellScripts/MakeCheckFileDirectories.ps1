Write-Host Making required folders and files... -ForegroundColor Gray
$thispath=Split-Path -parent $MyInvocation.MyCommand.Definition
$path = Split-Path -parent $thispath
$path2=Get-content $path/CyberPoliceOutput/path.txt

if(!(Test-Path "$path2\CheckFilesOutput\")){New-Item -ItemType Directory -Force -Path $path2\CheckFilesOutput\}
if(!(Test-Path "$path2\CheckFilesOutput\VerySuspicious\")){New-Item -ItemType Directory -Force -Path $path2\CheckFilesOutput\VerySuspicious\}
if(!(Test-path "$path2\CheckFilesOutput\VerySuspicious\FoundInUsers.txt")){New-Item -path $path2\CheckFilesOutput\VerySuspicious\ -name FoundInUsers.txt -type "file"}
if(!(Test-Path "$path2\CheckFilesOutput\FoundInAppData\")){New-Item -ItemType Directory -Force -Path $path2\CheckFilesOutput\FoundInAppData\}
if(!(Test-path "$path2\CheckFilesOutput\FoundInAppData\FoundInAppData.txt")){New-Item -path $path2\CheckFilesOutput\FoundInAppData\ -name FoundInAppData.txt -type "file"}
if(!(Test-Path "$path2\CheckFilesOutput\Extentions\")){New-Item -ItemType Directory -Force -Path $path2\CheckFilesOutput\Extentions\}
if(!(Test-Path "$path2\CheckFilesOutput\Tools\")){New-Item -ItemType Directory -Force -Path $path2\CheckFilesOutput\Tools\}