Write-Host The CYBER POLICE are searching for unauthorized files... -ForegroundColor Gray
$thispath=Split-Path -parent $MyInvocation.MyCommand.Definition
$path = Split-Path -parent $thispath
$configpath = "$path/ConfigFiles"
$path2=Get-content $path/CyberPoliceOutput/path.txt
$extensions =@()
$tools =@()

foreach($line in Get-Content $configpath/extentions.txt) {
    $extensions += $line
}
foreach($line in Get-Content $configpath/badtools.txt) {
    $tools += $line
}

if(Test-path "$path2\CheckFilesOutput\VerySuspicious\FoundInUsers.txt") {Clear-content "$path2\CheckFilesOutput\VerySuspicious\FoundInUsers.txt"}
if(Test-path "$path2\CheckFilesOutput\VerySuspicious\FoundInAppData.txt") {Clear-content "$path2\CheckFilesOutput\VerySuspicious\FoundInAppData.txt"}

Write-host "The CYBER POLICE are checking the $extensions..." -ForegroundColor Cyan
foreach($ext in $extensions){
	Write-host "Checking for .$ext files"
	if(!(Test-path "$path2\CheckFilesOutput\Extentions\$ext.txt")){New-Item -path $path2\CheckFilesOutput\Extentions\$ext.txt -name $ext.txt -type "file" | Out-Null}
    else{Clear-content "$path2\CheckFilesOutput\Extentions\$ext.txt"}
	C:\Windows\System32\cmd.exe /C dir C:\*.$ext /s /b | Out-File "$path2\CheckFilesOutput\Extentions\$ext.txt"

    if(!((gc $path2\CheckFilesOutput\Extentions\$ext.txt) -eq $null)){Write-Host "Stuff Found!" -ForegroundColor Yellow}

    foreach($line in Get-Content $path2\CheckFilesOutput\Extentions\$ext.txt) {
        if(($line -like '*C:\Users\*') -and !($line -like '*AppData*') -and !($line -like '*CyberPatriotScriptsQ*')) {
            $line >> $path2\CheckFilesOutput\VerySuspicious\FoundInUsers.txt
            Write-Host "The CYBER POLICE have found a very suspicious file!" -ForegroundColor Red
            Write-Host "Location: $line" -ForegroundColor Magenta 
        }
        elseif (($line -like '*C:\Users\*') -and ($line -like '*AppData*')) { 
            $line >> $path2\CheckFilesOutput\FoundInAppData\FoundInAppData.txt
        }
    }
}
Write-host "CYBER POLICE are done busting files via extentions" -ForegroundColor Green
Write-host "The CYBER POLICE are checking for $tools..." -ForegroundColor Cyan
foreach($tool in $tools){
	Write-host "Checking for $tool"
	if(!(Test-path $path2\CheckFilesOutput\Tools\$tool.txt)){New-Item -path $path2\CheckFilesOutput\Tools\$tool.txt -name $tool.txt -type "file" | Out-Null}
    else{Clear-content "$path2\CheckFilesOutput\Tools\$tool.txt"}
	C:\Windows\System32\cmd.exe /C dir C:\*$tool* /s /b | Out-File "$path2\CheckFilesOutput\Tools\$tool.txt"
    
    if(!((gc $path2\CheckFilesOutput\Tools\$tool.txt) -eq $null)){Write-Host "Stuff Found!" -ForegroundColor Yellow}

    foreach($line in Get-Content $path2\CheckFilesOutput\Tools\$tool.txt) {
        if(($line -like '*C:\Users\*') -and !($line -like '*AppData*') -and !($line -like '*CyberPatriotScriptsQ*')) {
            $line >> $path2\CheckFilesOutput\VerySuspicious\FoundInUsers.txt
            Write-Host "The CYBER POLICE have found a very suspicious file!" -ForegroundColor Red
            Write-Host "Location: $line" -ForegroundColor Magenta 
        }
        elseif (($line -like '*C:\Users\*') -and ($line -like '*AppData*')) { 
            $line >> $path2\CheckFilesOutput\FoundInAppData\FoundInAppData.txt
        }
    }
}
Write-host "CYBER POLICE are done busting bad tools" -ForegroundColor Green