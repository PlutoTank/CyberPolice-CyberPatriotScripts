@Echo Off

SETLOCAL EnableDelayedExpansion

set functions=checkfiles services lsp backuplsp passwordPol audit lockout features

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

set powershellPath=%SYSTEMROOT%\System32\WindowsPowerShell\v1.0\powershell.exe
set wmicPath=%SystemRoot%\System32\Wbem\wmic.exe
set lgpo=%toolsPath%/LGPO.exe

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

set dism=%toolsPath%\DISM%proArc%\DISM\dism.exe

%powershellPath% -ExecutionPolicy Bypass -File "%powershellScriptPath%/CreateRestorePoint.ps1"
%powershellPath% -ExecutionPolicy Bypass -File "%powershellScriptPath%/UserList.ps1"

echo.
call :colorEcho 0a "The CYBER POLICE have finished initializing!"
echo.
echo Press any key to begin CYBER POLICE OPS...
pause>nul

:manual

echo.
call :colorEcho 0f "Type"
call:colorEcho 0b " exit"
call :colorEcho 0f " to"
call:colorEcho 0c " exit"
call :colorEcho 0f " and"
call:colorEcho 0b " help"
call :colorEcho 0f " for"
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
call:servicesLoop "reg export HKLM\Software\Microsoft\Windows\CurrentVersion\Run"  "Run.reg"
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
rem harden firewall

:regHarden
rem harden and set secure registy values

:groupPol
rem set a secure group policy

:eventview
rem filter and find sketchy events in event viewer

:userRights
rem set user rights

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

:userMgmt
rem set user properties, set user passwords (use copy paste from README), add users (based on README), disable users (based on README), set user groups, disable admin and guest and rename

:rdp
rem ask if user wants remote desktop enabled, do stuff

:secRDP
rem secure rdp

:autoUpdate
rem turn on auto update

:verifySys
echo "CYBER POLICE are verifying system files..."
call:colorEcho 0e "This will take a while, get a snack..."
sfc /verifyonly
call:colorEcho 0a "CYBER POLICE are finally done"
goto:EOF

:virusScan
rem run CYBER POLICE virus scan

:checkHosts
rem back up and show HOSTS file then flush dns

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
goto:EOF

:colorEcho
echo off
<nul set /p ".=%DEL%" > "%~2"
findstr /v /a:%1 /R "^$" "%~2" nul
del "%~2" > nul 2>&1i
goto:EOF