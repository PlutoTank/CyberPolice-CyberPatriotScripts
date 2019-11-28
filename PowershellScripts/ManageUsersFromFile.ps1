Write-Host "The CYBER POLICE are managing users by file..." -ForegroundColor Gray
$thispath = Split-Path -parent $MyInvocation.MyCommand.Definition
$path = Split-Path -parent $thispath
$configpath = "$path/ConfigFiles"
$output = Get-Content $path/CyberPoliceOutput/path.txt
$userMgmtFilePath = ""
$accounts = Get-Wmiobject Win32_UserAccount -filter 'LocalAccount=TRUE' | select-object -expandproperty Name

$rawAdminData = @()
$rawUserData = @()
$rawOtherData = @()

$admins = @()
$adminPasswords = @()
$users = @()

function EditCheck {
    (Get-Content $configpath/PasteUsersHere.txt) | ? { $_.trim() -ne "" } | Set-Content $configpath/PasteUsersHere.txt
    Write-Host "Getting contents of raw user data..." -ForegroundColor Yellow
    Write-Host "Start of print out." -ForegroundColor Gray
    foreach ($line in Get-Content $configpath/PasteUsersHere.txt) {
        Write-Host $line -ForegroundColor Cyan
    }
    Write-Host "End of print out." -ForegroundColor Gray
    Write-host "Would you like to change the contents of this file? (Default is No)" -ForegroundColor Yellow 
    $Readhost = Read-Host "[Y/N]" 
    Switch ($ReadHost) { 
        Y { ChangeUserFile } 
        N { BeginUserManagement } 
        Default { BeginUserManagement } 
    }
} 

function ChangeUserFile {
    Write-Host "Waiting for user to edit..." -ForegroundColor Gray
    Start-Process notepad.exe $userMgmtFilePath -Wait
    Write-Host "Start of print out." -ForegroundColor Gray
    foreach ($line in Get-Content $configpath/PasteUsersHere.txt) {
        Write-Host $line -ForegroundColor Cyan
    }
    Write-Host "End of print out." -ForegroundColor Gray
    EditCheck
}
function BeginUserManagement {
    $writeTo = "Other"
    Write-Host "CYBER POLICE are starting user management..."
    foreach ($line in Get-Content $userMgmtFilePath) {
        if ($line -like "*Authorized Users*") {
            $writeTo = "User"
        }
        elseif ($line -like "*Authorized Administrators*") {
            $writeTo = "Admin"
        }
        Switch ($writeTo) {
            User { $rawUserData = $rawUserData + $line }
            Admin { $rawAdminData = $rawAdminData + $line }
            Default { $rawOtherData = $rawOtherData + $line }
        }
    }
    if ($rawOtherData.count -gt 0) {
        Write-Host "The CYBER POLICE found some extra data in PasteUsersHere.txt!" -ForegroundColor Red
        Write-Host "The file may have been created poorly or there was an error in editing!" -ForegroundColor Yellow
        Write-Host "Misc stuff found..." -ForegroundColor Gray
        $first, $rawOtherData = $rawOtherData
        foreach ($misc in $rawOtherData) {
            Write-Host $misc -ForegroundColor Cyan
        }
        Write-Host "End of misc stuff." -ForegroundColor Gray
    }
    Write-Host "Admins Found..." -ForegroundColor Gray
    $first, $rawAdminData = $rawAdminData
    foreach ($admin in $rawAdminData) {
        if ($admin -like "*password:*") {
            $password = $admin.split(":")
            $adminPasswords = $adminPasswords + $password[1].trim()
        }
        else {
            $adminSplit = $admin.split(" ")
            $admins = $admins + $adminSplit[0]
        }
    }
    for ($i = 0; $i -lt $admins.count; $i++) {
        Add-Content $output\ManagedUserOutput\authAdmins.txt "$($admins[$i]) $($adminPasswords[$i])"
        Write-Host "Admin: " -ForegroundColor Gray -NoNewline
        Write-Host $admins[$i] -ForegroundColor Cyan -NoNewline
        Write-Host " Password: " -ForegroundColor Gray -NoNewline
        Write-Host $adminPasswords[$i] -ForegroundColor Cyan
    }

    Write-Host "End of admins found." -ForegroundColor Gray
    Write-Host "Users Found..."
    $first, $rawUserData = $rawUserData
    foreach ($user in $rawUserData) {
        $users = $users + $user
        Add-Content $output\ManagedUserOutput\authUsers.txt $user
        Write-Host $user -ForegroundColor Cyan
    }
    Write-Host "End of users found." -ForegroundColor Gray
}

if (!(Test-Path $configpath/PasteUsersHere.txt -PathType Leaf)) {
    Write-Host "Raw users from README is not available!" -ForegroundColor Red
    Write-Host "Creating file..." -ForegroundColor Yellow
    New-Item -Path $configpath/PasteUsersHere.txt -ItemType "file" -Force
}

$userMgmtFilePath = "$configpath/PasteUsersHere.txt"
New-Item -path $output\ManagedUserOutput -name authAdmins.txt -type "file" -Force
New-Item -path $output\ManagedUserOutput -name authUsers.txt -type "file" -Force
EditCheck