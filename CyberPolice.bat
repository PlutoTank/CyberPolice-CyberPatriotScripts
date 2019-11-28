@Echo Off

SETLOCAL EnableDelayedExpansion

set functions=checkfiles usermgmtff userprop services firewall features passwordPol audit lockout rdp power sessions shares checkdns uac backuplsp lsp regharden verifysys auto

for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "DEL=%%a"
)

echo CYBER POLICE are initializing...

set path=%~dp0
if not exist "%path%CyberPoliceOutput" mkdir "%path%CyberPoliceOutput"
set output=%path%CyberPoliceOutput
set powershellScriptPath=%path%PowershellScripts
set configPath=%path%ConfigFiles
set toolsPath=%path%Tools
set batchScripts=%path%BatchScripts

set powershellPath=%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe
set wmicPath=%SystemRoot%\System32\Wbem\wmic.exe
set net=%SystemRoot%\system32\net.exe
set lgpo=%toolsPath%/LGPO.exe

set you=%username%

for /f "tokens=*" %%A in (%configPath%\DefaultPassword.txt) do (
	setlocal DisableDelayedExpansion
	set "password=%%A"
	setlocal enabledelayedexpansion
) 

echo CYBER POLICE are making required directories...
if not exist "%output%\WindowsFeatures" mkdir "%output%\WindowsFeatures"

set lspEditOs = "Windows10"

echo %path%CyberPoliceOutput>%output%\path.txt

echo The CYBER POLICE are running from: %path%

echo.
echo Checking if the CYBER POLICE have Administrative rights...
NET SESSION >nul 2>&1
if %errorlevel%==0 (
	call :colorEcho 0a "CYBER POLICE are enforcing as admin!"
	echo.
) else (
	echo.
	echo No admin
	echo Please INITIATE the CYBER POLICE taskforce as admin
	pause>nul
	exit
)

echo Checking for powershell...
FOR /F "tokens=3" %%A IN ('REG QUERY "HKLM\SOFTWARE\Microsoft\PowerShell\1" /v Install ^| FIND "Install"') DO SET PowerShellInstalled=%%A

IF NOT "%PowerShellInstalled%"=="0x1" (
	echo Powershell installed: false > %output%\PowershellStatus.txt
	call :colorEcho 0c "POWERSHELL NOT INSTALLED!"
	echo.
	call :colorEcho 0c "The CYBER POLICE can't enforce without it!"
	echo.
	pause>nul
	exit
)

FOR /F "tokens=3" %%A IN ('REG QUERY "HKLM\SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine" /v PowerShellVersion ^| FIND "PowerShellVersion"') DO SET PowerShellVersion=%%A

echo Powershell installed: true Version: %PowerShellVersion% > %output%\PowershellStatus.txt
call :colorEcho 0a "Powershell is installed!!"
echo.

for /f "delims=: tokens=2" %%a in ('systeminfo ^| find "OS Name"') do set os=%%a
for /f "tokens=* delims= " %%a in ("%os%") do set os=%%a
call:colorEcho 0b "The CYBER POLICE have detected"
call:colorEcho 0d " %os%"
call:colorEcho 0b " as host's OS"
echo.
echo %os%>%output%\"OSVERSION.txt"

for /f %%a in ('set ^| find "PROCESSOR_ARCHITECTURE"') do set proArc=%%a
set proArc=%proArc:~23%
call:colorEcho 0b "The CYBER POLICE have detected"
call:colorEcho 0d " %proArc%"
call:colorEcho 0b " as host's CPU architecture"
echo.
echo %proArc%>%output%\"CPUARCHITECTURE.txt"

call:colorEcho 0b "Running as user"
call:colorEcho 0a " %you%"
echo.

set dism=%toolsPath%\DISM%proArc%\DISM\dism.exe

%powershellPath% -ExecutionPolicy Bypass -File "%powershellScriptPath%/CreateRestorePoint.ps1"
%powershellPath% -ExecutionPolicy Bypass -File "%powershellScriptPath%/UserList.ps1"

echo.
call :colorEcho 0a "The CYBER POLICE have finished initializing!"
echo.
echo Press any key to begin CYBER POLICE OPS...
pause>nul

echo.
call:colorEcho 0e "Do you want [A]uto or [M]anual (Default is [M]anual)"
echo.
set /p aus="[A/M]: "
if /i "%aus%" neq "A" goto:manual
goto:auto

:auto
for %%A in (%functions%) do call:autoCheck %%A
call :colorEcho 0a "The CYBER POLICE have finished running auto"
echo.
echo Press any key to switch to manual...
pause>nul
goto:manual

:autoCheck
if "%~1"=="backuplsp" (
	goto:EOF	
)
if "%~1"=="auto" (
	goto:EOF	
)
call:%~1
goto:EOF
:manual

echo.
call :colorEcho 07 "Type"
call:colorEcho 0b " exit"
call :colorEcho 07 " to"
call:colorEcho 0c " exit"
call :colorEcho 07 " and"
call:colorEcho 0b " help"
call :colorEcho 07 " for"
call :colorEcho 0a " help"
echo.

set /p act="What should the CYBER POLICE do: "
if "%act%"=="exit" exit
if "%act%"=="help" (
	echo CYBER POLICE available actions:
	for %%F in (%functions%) do (
		call:colorEcho 0b "%%F"
		echo.
	)
	pause>nul
	goto:manual
)
for %%F in (%functions%) do (
	if %%F==%act% (
		call:colorEcho 0a "CYBER POLICE are executing"
		call:colorEcho 0b " %act%"
		echo.
		echo.
		call:%act%
		call:colorEcho 0a "CYBER POLICE have finished executing"
		call:colorEcho 0b " %act%"
		echo.
		goto:endOfManual
	)
)
call:colorEcho 0c "CYBER POLICE could not find"
call:colorEcho 0b " %act%"
call:colorEcho 0c " operation!"
echo.
:endOfManual
pause>nul
goto:manual

:checkfiles
%powershellPath% -ExecutionPolicy Bypass -File "%powershellScriptPath%/MakeCheckFileDirectories.ps1"
%powershellPath% -ExecutionPolicy Bypass -File "%powershellScriptPath%/CheckFiles.ps1"
call:manualVerify "explorer.exe"
goto:EOF

:services
echo The CYBER POLICE are checking services...
call:servicesLoop "%wmicPath% process list brief>" "BriefProcesses.txt"
call:servicesLoop "%wmicPath% process list full>" "FullProcesses.txt"
call:servicesLoop "%wmicPath% startup list full>" "StartupLists.txt"
call:servicesLoop "net start>" "StartedProcesses.txt"
call:servicesLoop "reg export HKLM\Software\Microsoft\Windows\CurrentVersion\Run"  "Run.txt"
%powershellPath% -ExecutionPolicy Bypass -File "%powershellScriptPath%/ProcessDMA.ps1"
call:manualVerify "services.msc"
goto:EOF

:servicesLoop
%~1 %path%\CyberPoliceOutput\Services\%~2
if %errorlevel%==1 (
	call :colorEcho 0e "%~2 failed to write!"
	echo.
	call :colorEcho 0e "Creating file and trying again..."
	echo.
	call :createFile "%path%\CyberPoliceOutput\Services\%~2" %~2
	if %errorlevel%==1 (
		call :colorEcho 0c "%~2 could not be written to!"
		echo.
	)
	else (
		call :colorEcho 0a "%~2 was successfully written to!"
		echo.
		goto:EOF
	)
) else (
	call :colorEcho 0a "%~2 was successfully written to!"
	echo.
)
goto:EOF

:passwordPol
echo The CYBER POLICE are setting a password policy...
net accounts /lockoutthreshold:5 /MINPWLEN:8 /MAXPWAGE:30 /MINPWAGE:15 /UNIQUEPW:15 
call:colorEcho 0a "Password policy set!"
echo.
call:colorEcho 0e "(NOTICE) The CYBER POLICE cannot set the following functions through script..."
echo.
call:colorEcho 07 "Password policy must meet complexity to"
call:colorEcho 0b " enable"
echo.
call:colorEcho 07 "Store passwords using reversible encryption to"
call:colorEcho 0b " disabled" 
echo.
call:manualVerify "secpol.msc"
goto:EOF

:lockout
echo The CYBER POLICE are setting a lockout policy...
echo.
net accounts /lockoutduration:30
net accounts /lockoutthreshold:5
net accounts /lockoutwindow:30
call:colorEcho 0a "The CYBER POLICE have successfully set a lockout policy"
echo.
call:manualVerify "secpol.msc"
goto:EOF

:audit
echo The CYBER POLICE are setting auditing success and failure for all categories...
auditpol /set /category:* /success:enable
auditpol /set /category:* /failure:enable
call:colorEcho 0a "The CYBER POLICE have successfully set an audit policy"
echo.
call:manualVerify "secpol.msc"
goto:EOF

:lsp
echo CYBER POLICE are starting Local Security Policy setup...
call:colorEcho 0e "(NOTICE) this will make changes to Local Secuity Policy. Things you have set may be changed."
echo.
call:backuplsp
goto:managelsp

:managelsp
echo.
call:colorEcho 0b "You are running"
call:colorEcho 0d " %os%"
echo.
echo CYBER POLICE found these OS' that have available LSP files:
set i=0
for /f %%G in ('dir %configPath%\lgpoTemplates /a:d /b') do (
	set /a i+=1
	set osChoices[!i!]=%%~G
	call:colorEcho 0b "%%G"
	echo.
)
echo.
set osChoicesFiles=%i%

echo Select an os...
call:colorEcho 0e "(NOTE) input is case sensitive."
call:colorEcho 0c " (exit to exit)"
echo.
set /p selOs="OS: "
if "%selOs%"=="exit" (
	call:colorEcho 0c "Local Security Policy was not configured"
	echo.
	call:manualVerify "secpol.msc"
	goto:EOF
)
for /L %%i in (1,1,%osChoicesFiles%) do (
	if !osChoices[%%i]!==%selOs% (
		call:colorEcho 0a "Os set to configure Local Security Policy is"
		call:colorEcho 0b " !osChoices[%%i]!"
		echo.
		set lspEditOs=!osChoices[%%i]!
		goto:pickLspType
		goto:EOF
	)
)
call:colorEcho 0b "%selOs%"
call:colorEcho 0c " is not a valid os"
echo.
set /p aus="Continue? [Y/(N)]: "
if /i "%aus%" == "Y" goto:managelsp
echo.
goto:EOF

:pickLspType
call:colorEcho 08 "CYBER POLICE found these LSP templates for"
call:colorEcho 0b " %lspEditOs%"
echo.
set i=0
for /f %%G in ('dir %configPath%\lgpoTemplates\%lspEditOs% /a:d /b') do (
	set /a i+=1
	set temChoices[!i!]=%%~G
	call:colorEcho 0b "%%G"
	echo.
)
echo.
set temChoicesFiles=%i%

echo Select a LSP template...
call:colorEcho 0e "(NOTE) input is case sensitive."
call:colorEcho 0c " (exit to exit)"
echo.
set /p selTem="LSP Template: "
if "%selTem%"=="exit" (
	call:colorEcho 0c "Local Security Policy was not configured"
	echo.
	call:manualVerify "secpol.msc"
	goto:EOF
)
for /L %%i in (1,1,%temChoicesFiles%) do (
	if !temChoices[%%i]!==%selTem% (
		call:colorEcho 0a "Set to configure Local Security Policy"
		call:colorEcho 0b " !temChoices[%%i]!"
		echo.
		%lgpo% /g %configPath%\lgpoTemplates\%lspEditOs%\!temChoices[%%i]! /v
		call:colorEcho 0a "The CYBER POLICE have now set"
		call:colorEcho 0b " %lspEditOs%"
		call:colorEcho 0a " Local Security Policy to"
		call:colorEcho 0b " !temChoices[%%i]!"
		echo.
		call:manualVerify "secpol.msc"
		goto:EOF
	)
)
call:colorEcho 0b "%selTem%"
call:colorEcho 0c " is not a valid template"
echo.
set /p aus="Continue? [Y/(N)]: "
if /i "%aus%" == "Y" goto:pickLspType
echo.
goto:EOF

:backuplsp
call:colorEcho 0b "A back up of secpol.msc will be created..."
echo.
set /p aus="Make backup? [Y/N]: "
if /i "%aus%" == "Y" (
	%lgpo% /b "%output%/lgpoBackup"
	call:colorEcho 0a "Backup of LSP created"
	echo.
) else (
	call:colorEcho 0c "Backup of LSP not created"
	echo.
)
goto:EOF

:firewall
echo The CYBER POLICE will now try to enable the firewall...
netsh advfirewall set allprofiles state on
call:colorEcho 0a "The CYBER POLICE have enabled the firewall"
echo.
echo The CYBER POLICE will now do some basic firewall hardening...
for /f "tokens=*" %%A in (%configPath%\FirewallRulesOFF.txt) do (
	set comCheck=%%%A:~0,1%
	if "!comCheck!" neq "#" (
		netsh advfirewall firewall set rule name="%%A" new enable=no 
	)
)
call:colorEcho 0a "The CYBER POLICE finished basic firewall hardening"
echo.
call:manualVerify wf.msc
goto:EOF

:regharden
echo The CYBER POLICE will do some system hardening through the registry...
for /f "tokens=*" %%A in (%configPath%\RegistyHardenData.txt) do (
	endlocal & set "regLine=%%A"
	set comCheck=!regLine:~0,1!
	if "!comCheck!" neq "#" (
		for /f "tokens=1,2,3,4 delims=:" %%G in ("!regLine!") do (
			set regPath=%%G
			set regKey=%%H
			set regType=%%I
			set regVal=%%J
		)
		echo "Editing registry path !regPath!"
		call:colorEcho 07 "Editing key"
		call:colorEcho 0b " !regKey!"
		echo.
		call:colorEcho 07 "Editing variable type"
		call:colorEcho 0d " !regType!"
		echo.
		call:colorEcho 07 "Applying value"
		call:colorEcho 0a " !regVal!"
		echo.
		reg add "!regPath!" /v !regKey! /t !regType! /d !regVal! /f
	)
)
call:manualVerify regedit.exe
goto:EOF

:groupPol
rem set a secure group policy

:eventview
rem filter and find sketchy events in event viewer

:userprop
for /f "tokens=*" %%A in (%output%\users.txt) do (
	if "%%A" neq "%you%" (
		echo.
		%wmicPath% UserAccount where Name='%%A' set PasswordExpires=True
		%wmicPath%  UserAccount where Name='%%A' set PasswordChangeable=True
		%wmicPath%  UserAccount where Name='%%A' set PasswordRequired=True
		%net% user %%A /logonpasswordchg:yes
		call:colorEcho 0a "Properties for"
		call:colorEcho 0b " %%A"
		call:colorEcho 0a " were changed"
		echo.
	) 
)
call:manualVerify lusrmgr.msc
goto:EOF

:features
set wfOutput=%output%\WindowsFeatures
echo CYBER POLICE are making list of the status of current Windows features...
%dism% /online /Get-Features>%wfOutput%\StatusWFBefore.txt
echo.>%wfOutput%\DisabledWinFeatures.txt
call:colorEcho 0a "List has been made"
echo.
echo CYBER POLICE will now look at windows features...
for /f "tokens=*" %%A in (%configPath%\BadWinFeatures.txt) do (
	call:colorEcho 07 "CYBER POLICE are looking at feature"
	call:colorEcho 0b " %%A"
	echo.
	for /f "tokens=2 delims=:" %%B in ('%dism% /online /get-featureinfo /featurename:%%A ^| Find "State"') do set wfStatus=%%B
	for /f "tokens=* delims= " %%C in ("!wfStatus!") do set wfStatus=%%C
	
	call:colorEcho 0b "%%A"
	call:colorEcho 07 "'s current status is"
	call:colorEcho 0b " !wfStatus!"
	echo.
	if "!wfStatus!" == "Disabled" (
		call:colorEcho 0e "No need to disable"
		call:colorEcho 0b " %%A"
		echo.
	) else (
		echo %%A>>%wfOutput%\DisabledWinFeatures.txt
		%dism% /online /disable-feature /featurename:%%A
		call:colorEcho 0a "Disabled feature"
		call:colorEcho 0b " %%A"
		echo.
	)
)
%dism% /online /Get-Features>%wfOutput%\StatusWFAfter.txt
call:colorEcho 0a "CYBER POLICE are done finding bad Windows features"
echo.
goto:EOF

:usermgmtff 
%powershellPath% -ExecutionPolicy Bypass -File "%powershellScriptPath%/ManageUsersFromFile.ps1"
echo Finding current users...
set uOutDir=%output%\ManagedUserOutput
break>"!uOutDir!\enabledUsers.txt"
for /f "tokens=*" %%A in (%output%\users.txt) do (
	for /f "tokens=3 delims= " %%B in ('%net% user "%%A" ^| Find "active"') do set userStatus=%%B
	if "!userStatus!"=="No" (
		call:colorEcho 0b "%%A"
		call:colorEcho 07 " account is"
		call:colorEcho 0b " Disabled"
		echo.
	 ) else (
		call:colorEcho 0b "%%A"
		call:colorEcho 07 " account is"
		call:colorEcho 0b " Enabled"
		echo.
		echo %%A>>!uOutDir!\enabledUsers.txt
	 )
)
echo.
echo The CYBER POLICE are now applying admins...
for /f "tokens=*" %%A in (%uOutDir%\authAdmins.txt) do (
	endlocal & set "line=%%A"
	for /f "tokens=1 delims= " %%C in ("!line!") do (
		endlocal & set "user=%%C"
	)
	for /f "tokens=2 delims= " %%C in ("!line!") do (
		endlocal & set "pass=%%C"
	)
	call:checkusersadmin !user! !pass!
)
echo The CYBER POLICE are now applying users...
for /f "tokens=* delims=" %%A in (%uOutDir%\authUsers.txt) do (
	call:checkusers %%A !password!
)
echo CYBER POLICE are checking users...
for /f "tokens=*" %%A in (%uOutDir%\enabledUsers.txt) do (
	call:checkcurrusers %%A
)
%powershellPath% -ExecutionPolicy Bypass -File "%powershellScriptPath%/UserList.ps1"
call:manualVerify lusrmgr.msc
goto:EOF

:checkcurrusers
for /f "tokens=* delims=" %%B in (%uOutDir%\authAdmins.txt) do (
	endlocal & set "line=%%B"
	for /f "tokens=1 delims= " %%C in ("!line!") do (
		endlocal & set "userChk=%%C"
		if "%~1"=="!userChk!" (
			call:colorEcho 0b "%~1"
			call:colorEcho 0a " found"
			echo.
			goto:EOF
		)
	)
)
for /f "tokens=* delims=" %%D in (%uOutDir%\authUsers.txt) do (
	set userChk=%%D
	if "%~1"=="!userChk!" (
		call:colorEcho 0b "%~1"
		call:colorEcho 0a " found"
		echo.
		goto:EOF
	)
)

call:colorEcho 0b "%~1"
call:colorEcho 0c " not found"
echo.
call:colorEcho 0e "Disabling"
call:colorEcho 0b " %~1"
echo.
net user %~1 /active:no
goto:EOF

:checkusersadmin
endlocal & set "user=%~1"
endlocal & set "pass=%~2"
for /f "tokens=*" %%B in (!uOutDir!\enabledUsers.txt) do (
	if "!user!"=="%%B" (
		call:colorEcho 0b "!user!"
		call:colorEcho 0a " admin found"
		echo.
		call:colorEcho 07 "Giving"
		call:colorEcho 0b " !user!"
		call:colorEcho 07 " password"
		%powershellPath% Write-Host -Foregroundcolor Gray -NoNewLine ": "
		%powershellPath% Write-Host -Foregroundcolor Cyan "!pass!"
		net user !user! !pass!
		if %ERRORLEVEL% neq 0 (
			call:userError !user!
		)
		call:colorEcho 07 "Managing"
		call:colorEcho 0b " !user!"
		call:colorEcho 07 " admin"
		echo.
		%net% localgroup "Administrators" "!user!" /add
		goto:EOF
	) 
)
call:colorEcho 0b "!user!"
call:colorEcho 0c " admin not found"
echo.
call:colorEcho 07 "Creating"
call:colorEcho 0b " !user!"
call:colorEcho 07 " and giving password"
%powershellPath% Write-Host -Foregroundcolor Gray -NoNewLine ": "
%powershellPath% Write-Host -Foregroundcolor Cyan "!pass!"
%net% user "!user!" "!pass!" /add
if %ERRORLEVEL% neq 0 (
	call:userError !user!
)
call:colorEcho 07 "Managing"
call:colorEcho 0b " !user!"
call:colorEcho 07 " admin"
echo.
%net% localgroup "Administrators" "!user!" /add
goto:EOF

:checkusers
endlocal & set "user=%~1"
endlocal & set "pass=%~2"
for /f "tokens=*" %%B in (!uOutDir!\enabledUsers.txt) do (
	if "!user!"=="%%B" (
		call:colorEcho 0b "!user!"
		call:colorEcho 0a " found"
		echo.
		call:colorEcho 07 "Giving"
		call:colorEcho 0b " !user!"
		call:colorEcho 07 " password"
		%powershellPath% Write-Host -Foregroundcolor Gray -NoNewLine ": "
		%powershellPath% Write-Host -Foregroundcolor Cyan "!pass!"
		net user !user! !pass! 
		call:colorEcho 07 "Managing"
		call:colorEcho 0b " !user!"
		call:colorEcho 07 " user"
		echo.
		%net% localgroup "Users" "!user!" /add
		%net% localgroup "Administrators" "!user!" /delete
		goto:EOF
	) 
)
call:colorEcho 0b "!user!"
call:colorEcho 0c " not found"
echo.
call:colorEcho 07 "Creating"
call:colorEcho 0b " !user!"
call:colorEcho 07 " with password"
%powershellPath% Write-Host -Foregroundcolor Gray -NoNewLine ": "
%powershellPath% Write-Host -Foregroundcolor Cyan "!pass!"
echo.
%net% user "!user!" "!pass!" /add 
call:colorEcho 07 "Managing"
call:colorEcho 0b " !user!"
call:colorEcho 07 " user"
echo.
%net% localgroup "Users" "!user!" /add
%net% localgroup "Administrators" "!user!" /delete
goto:EOF

:userError
call:colorEcho 0c "Looks like there was an error configuring"
call:colorEcho 0b " %~1"
echo.
call:colorEcho 0e "it could be a password problem..."
echo.
call:colorEcho 0e "Change thier password to a default password, user might not be created if No (Default is Yes)"
echo.
set /p aus="[Y/N]: "
if /i "%aus%" neq "N" (
	call:colorEcho 07 "Current default password"
	%powershellPath% Write-Host -Foregroundcolor Gray -NoNewLine ": "
	%powershellPath% Write-Host -Foregroundcolor Cyan "!password!" 
	echo.
	%net% user "%~1" "!password!" /add

) else (
	call:colorEcho 0b "%~1"
	call:colorEcho 0c " was not created"
	echo.
)
%net% user %~1 /active:yes
goto:EOF

:sessions
echo The CYBER POLICE will display connected remote sessions
net session
net session > %output%/CurrentRemoteSessions.txt
call:colorEcho 0a "Sessions are done showing"
echo.
goto:EOF

:rdp
echo The CYBER POLICE will manage Remote Desktop...
call:colorEcho 0e "Enable remote desktop (Default will loop back)"
echo.
set /p rdpChk="[Y/N]:"
if %rdpChk%==y (
	echo Enabling remote desktop...
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v AllowTSConnections /t REG_DWORD /d 1 /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fAllowToGetHelp /t REG_DWORD /d 1 /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 1 /f
	REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
	netsh advfirewall firewall set rule group="remote desktop" new enable=yes
	call:colorEcho 07 "The CYBER POLICE suggest you check"
	call:colorEcho 0b "Allow connections only from computers running Remote Desktop with Network Level Authentication"
	echo.
	call:manualVerify SystemPropertiesRemote.exe
	pause>nul
	call:colorEcho 0a "The CYBER POLICE enabled RDP"
	echo.
	goto:EOF
)
if %rdpChk%==n (
	echo Disabling remote desktop...
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 1 /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v AllowTSConnections /t REG_DWORD /d 0 /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fAllowToGetHelp /t REG_DWORD /d 0 /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 0 /f
	netsh advfirewall firewall set rule group="remote desktop" new enable=no
	call:colorEcho 0a "The CYBER POLICE disabled RDP"
	echo.
	goto:EOF
)
call:colorEcho 0c "Invalid input"
call:colorEcho 0b " %rdpChk%"
echo.
goto rdp

:secRDP
rem secure rdp

:power
echo the CYBER POLICE are setting power settings...
powercfg -SETDCVALUEINDEX SCHEME_BALANCED SUB_NONE CONSOLELOCK 1
powercfg -SETDCVALUEINDEX SCHEME_MIN SUB_NONE CONSOLELOCK 1
powercfg -SETDCVALUEINDEX SCHEME_MAX SUB_NONE CONSOLELOCK 1
call:colorEcho 0a "The CYBER POLICE set power settings"
echo.
goto:EOF

:shares
echo The CYBER POLICE are logging shares...
net share
net share > %output%\shares.txt
call:colorEcho 0a "Shares have been logged"
echo.
call:manualVerify fsmgmt.msc
goto:EOF

:uac
echo The CYBER POLICE are enabling UAC...
reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 1 /f
call:colorEcho 0a "The CYBER POLICE have enabled UAC"
echo.
goto:EOF

:verifysys
echo "CYBER POLICE are verifying system files..."
call:colorEcho 0e "This will take a while, get a snack..."
sfc /verifyonly
call:colorEcho 0a "CYBER POLICE are finally done"
goto:EOF

:checkdns
echo The CYBER POLICE will display current dns...
ipconfig /displaydns
ipconfig /displaydns > %output%/CurrentDNS.txt
call:colorEcho 0d "Output ends here"
echo.
echo The CYBER POLICE will display hosts file
type C:\Windows\System32\Drivers\etc\hosts
type C:\Windows\System32\Drivers\etc\hosts > %output%/CurrentHOSTS.txt
call:colorEcho 0d "Output ends here"
echo.
echo The CYBER POLICE will now flush dns...
ipconfig /flushdns
call:colorEcho 0a "The CYBER POLICE have flushed dns"
echo.
echo The CYBER POLICE will now clear C:\Windows\System32\drivers\etc\hosts...
attrib -r -s C:\WINDOWS\system32\drivers\etc\hosts
echo > C:\Windows\System32\drivers\etc\hosts
attrib +r +s C:\WINDOWS\system32\drivers\etc\hosts
call:colorEcho 0a "The CYBER POLICE have cleared the HOSTS file"
echo.
goto:EOF

:createFile
%powershellPath% -ExecutionPolicy Bypass -File "%powershellScriptPath%/CreateFile.ps1" %~1 %~2
goto:EOF

:manualVerify
call:colorEcho 0b "Do you want to manually look at %~1 (Default is No)"
echo.
set /p aus="[Y/N]: "
if /i "%aus%" neq "Y" goto:EOF
call:colorEcho 0b "Running %~1..."
echo.
start %~1 /wait
echo.
call:colorEcho 0e "Press any key to let the CYBER POLICE continue..."
echo.
pause >nul
goto:EOF

:colorEcho
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1i
goto:EOF