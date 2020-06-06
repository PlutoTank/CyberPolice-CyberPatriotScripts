@Echo Off

SETLOCAL EnableDelayedExpansion

set functions=checkfiles usermgmtff userprop services firewall features passwordpol audit lockout rdp power sessions shares checkdns uac windef backuplsp lsp regharden verifysys auto logging
set analysisFunctions=allgpo listgpos listdisabledgpos gpoinfo gporeport backupgpos logfirewall logservices netstat checksync manual

for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "DEL=%%a"
)

echo CYBER POLICE are initializing...

set path=%~dp0
if not exist "%path%CyberPoliceOutput" mkdir "%path%CyberPoliceOutput"
set output=%path%CyberPoliceOutput
set powershellScriptPath=%path%PowershellScripts
set vbScriptPath=%path%VBScripts
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
if not exist "%output%\gpoInfo" mkdir "%output%\gpoInfo"
if not exist "%output%\gpoInfo\gpoReports" mkdir "%output%\gpoInfo\gpoReports"
if not exist "%output%\logs" mkdir "%output%\logs"

set lspEditOs = "Windows10"

echo %path%CyberPoliceOutput>%output%\path.txt

echo The CYBER POLICE are running from: %path%

echo.
echo Checking if the CYBER POLICE have Administrative rights...
NET SESSION >nul 2>&1
if %errorlevel%==0 (
	cecho {0a}CYBER POLICE are enforcing as admin!{#}
	echo.
) else (
	echo.
	cecho {0c}No admin!{#}
	echo.
	echo Please INITIATE the CYBER POLICE taskforce as admin
	echo There may be errors...
	cecho {0e}Here are some solutions that may work:{#}
	echo.
	cecho	1. Making a shortcut to the CyberPolice batch file.
	echo.
	cecho	   - Then going to the shortcut's propetries and appending:
	echo.
	cecho      - runas /user:{0b}YourAdminUsername{#} /savecred
	echo.
	cecho	   - infront of the loaction of the CyberPolice file
	echo.
	cecho	   - Note: This error may still come up but the commands will work. 
	echo.
	cecho		   Sometimes though it still says you lack permission to do things.
	echo.
	cecho	2. Check your Local Security Policies and Group Policies to see if they are affecting the program [theres a lot]
	echo.
	echo Press any key to continue...
	pause>nul
	echo.
)

echo Checking for powershell...
FOR /F "tokens=3" %%A IN ('REG QUERY "HKLM\SOFTWARE\Microsoft\PowerShell\1" /v Install ^| FIND "Install"') DO SET PowerShellInstalled=%%A

IF NOT "%PowerShellInstalled%"=="0x1" (
	echo Powershell installed: false > %output%\PowershellStatus.txt
	cecho {0c}POWERSHELL NOT INSTALLED!{#}
	echo.
	cecho {0c}The CYBER POLICE can't enforce without it!{#}
	echo.
	pause>nul
	exit
)

FOR /F "tokens=3" %%A IN ('REG QUERY "HKLM\SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine" /v PowerShellVersion ^| FIND "PowerShellVersion"') DO SET PowerShellVersion=%%A

echo Powershell installed: true Version: %PowerShellVersion% > %output%\PowershellStatus.txt
cecho {0a}Powershell is installed!!{#}
echo.
echo.
cecho Note: If you plan on using the Logging function you need {0b}cscript.exe{#}!
echo.
echo.

for /f "delims=: tokens=2" %%a in ('systeminfo ^| find "OS Name"') do set os=%%a
for /f "tokens=* delims= " %%a in ("%os%") do set os=%%a
cecho {0b}The CYBER POLICE have detected {0d}%os% {0b}as host's OS{#}
echo.
echo %os%>%output%\"OSVERSION.txt"

for /f %%a in ('set ^| find "PROCESSOR_ARCHITECTURE"') do set proArc=%%a
set proArc=%proArc:~23%
cecho {0b}The CYBER POLICE have detected {0d}%proArc% {0b}as host's CPU architecture{#}
echo.
echo %proArc%>%output%\"CPUARCHITECTURE.txt"

for /f "delims=: tokens=2" %%a in ('systeminfo ^| find "Domain:"') do set domain=%%a
for /f "tokens=* delims= " %%a in ("%domain%") do set domain=%%a
cecho {0b}The CYBER POLICE have detected {0d}%domain% {0b}as host's domain{#}
echo.
echo %domain%>%output%\"Domain.txt"

cecho {0b}Running as user {0a}%you%{#}
echo.
echo.

set dism=%toolsPath%\DISM%proArc%\DISM\dism.exe

%powershellPath% -ExecutionPolicy Bypass -File "%powershellScriptPath%/CreateRestorePoint.ps1"
echo.
%powershellPath% -ExecutionPolicy Bypass -File "%powershellScriptPath%/UserList.ps1"

echo.
cecho {0a}The CYBER POLICE have finished initializing!{#}
echo.
echo Press any key to begin CYBER POLICE OPS...
pause>nul

echo.
cecho {0e}Do you want [{0a}A{0e}]uto, [{0b}M{0e}]anual or [{0d}L{0e}]ogging/Analysis (Default is [{0b}M{0e}]anual){#}
echo.
set /p aus="[A/M/L]: "
if /i "%aus%"=="L" goto:logging
if /i "%aus%"=="A" goto:auto
goto:manual

:auto
for %%A in (%functions%) do call:autoCheck %%A
cecho {0a}The CYBER POLICE have finished running auto{#}
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
cecho {07}Type {0b}exit {07}to {0c}exit {07}and {0b}help {07}for {0a}help{#} 
echo.

set /p act="What should the CYBER POLICE do: "
if "%act%"=="exit" exit
if "%act%"=="help" (
	echo CYBER POLICE available actions:
	for %%F in (%functions%) do (
		cecho {0b}%%F{#}
		echo.
	)
	pause>nul
	goto:manual
)
for %%F in (%functions%) do (
	if %%F==%act% (
		cecho {0a}CYBER POLICE are executing {0b}%act%{#}
		echo.
		echo.
		call:%act%
		cecho {0a}CYBER POLICE have finished executing {0b}%act%{#}
		echo.
		goto:endOfManual
	)
)
cecho {0c}CYBER POLICE could not find {0b}%act% {0c}operation!{#}
echo.
:endOfManual
pause>nul
goto:manual

:logging
echo.
cecho {07}Type {0b}exit {07}to {0c}exit {07}and {0b}help {07}for {0a}help{#} [analysis mode]
echo.
set /p act="What should the CYBER POLICE [Covert Ops] check: "
if "%act%"=="exit" exit
if "%act%"=="help" (
	echo CYBER POLICE [Covert Ops] available actions:
	for %%F in (%analysisFunctions%) do (
		cecho {0d}%%F{#}
		echo.
	)
	pause>nul
	goto:logging
)
for %%F in (%analysisFunctions%) do (
	if %%F==%act% (
		cecho {0a}CYBER POLICE [Covert Ops] are executing {0b}%act%{#}
		echo.
		echo.
		call:%act%
		cecho {0a}CYBER POLICE [Covert Ops] have finished executing {0b}%act%{#}
		echo.
		goto:endOfLogging
	)
)
cecho {0c}CYBER POLICE [Covert Ops] could not find {0b}%act% {0c}operation!{#}
echo.
:endOfLogging
pause>nul
goto:logging

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
	cecho {0e}%~2 failed to write!{#}
	echo.
	cecho {0e}Creating file and trying again...{#}
	echo.
	call :createFile "%path%\CyberPoliceOutput\Services\%~2" %~2
	if %errorlevel%==1 (
		cecho {0c}%~2 could not be written to!{#}
		echo.
	)
	else (
		cecho {0a}%~2 was successfully written to!{#}
		echo.
		goto:EOF
	)
) else (
	cecho {0a}%~2 was successfully written to!{#}
	echo.
)
goto:EOF

:windef
echo CYBER POLICE are setting windows defender settings...
%powershellPath% Set-MpPreference -MAPSReporting Advanced
%powershellPath% Set-MpPreference -SubmitSamplesConsent Always
%powershellPath%  Set-MpPreference -EnableNetworkProtection Enabled
goto:EOF

:passwordpol
echo The CYBER POLICE are setting a password policy...
net accounts /lockoutthreshold:5 /MINPWLEN:8 /MAXPWAGE:30 /MINPWAGE:15 /UNIQUEPW:15 
cecho {0a}Password policy set!
echo.
cecho {0e}(NOTICE) The CYBER POLICE cannot set the following functions through script...
echo.
cecho {07}Password policy must meet complexity to {0b}enabled
echo.
cecho {07}Store passwords using reversible encryption to {0b}disabled{#}
echo.
call:manualVerify "secpol.msc"
goto:EOF

:lockout
echo The CYBER POLICE are setting a lockout policy...
echo.
net accounts /lockoutduration:30
net accounts /lockoutthreshold:5
net accounts /lockoutwindow:30
cecho {0a}The CYBER POLICE have successfully set a lockout policy{#}
echo.
call:manualVerify "secpol.msc"
goto:EOF

:audit
echo The CYBER POLICE are setting auditing success and failure for all categories...
auditpol /set /category:* /success:enable
auditpol /set /category:* /failure:enable
cecho {0a}The CYBER POLICE have successfully set an audit policy{#}
echo.
call:manualVerify "secpol.msc"
goto:EOF

:lsp
echo CYBER POLICE are starting Local Security Policy setup...
cecho {0e}(NOTICE) this will make changes to Local Secuity Policy. Things you have set may be changed.{#}
echo.
call:backuplsp
goto:managelsp

:managelsp
echo.
cecho {0b}You are running {0d}%os%{#}
echo.
echo CYBER POLICE found these OS' that have available LSP files:
set i=0
for /f %%G in ('dir %configPath%\lgpoTemplates /a:d /b') do (
	set /a i+=1
	set osChoices[!i!]=%%~G
	cecho {0b}%%G{#}
	echo.
)
echo.
set osChoicesFiles=%i%

echo Select an os...
cecho {0e}(NOTE) input is case sensitive. {0c}(exit to exit){#}
echo.
set /p selOs="OS: "
if "%selOs%"=="exit" (
	cecho {0c}Local Security Policy was not configured{#}
	echo.
	call:manualVerify "secpol.msc"
	goto:EOF
)
for /L %%i in (1,1,%osChoicesFiles%) do (
	if !osChoices[%%i]!==%selOs% (
		cecho {0a}Os set to configure Local Security Policy is {0b}!osChoices[%%i]!{#}
		echo.
		set lspEditOs=!osChoices[%%i]!
		goto:pickLspType
		goto:EOF
	)
)
cecho {0b}%selOs% {0c}is not a valid os{#}
echo.
set /p aus="Continue? [Y/(N)]: "
if /i "%aus%" == "Y" goto:managelsp
echo.
goto:EOF

:pickLspType
cecho {08}CYBER POLICE found these LSP templates for {0b}%lspEditOs%{#}
echo.
set i=0
for /f %%G in ('dir %configPath%\lgpoTemplates\%lspEditOs% /a:d /b') do (
	set /a i+=1
	set temChoices[!i!]=%%~G
	cecho {0b}%%G{#}
	echo.
)
echo.
set temChoicesFiles=%i%

echo Select a LSP template...
cecho {0e}(NOTE) input is case sensitive. {0c}(exit to exit){#}
echo.
set /p selTem="LSP Template: "
if "%selTem%"=="exit" (
	cecho {0c}Local Security Policy was not configured{#}
	echo.
	call:manualVerify "secpol.msc"
	goto:EOF
)
for /L %%i in (1,1,%temChoicesFiles%) do (
	if !temChoices[%%i]!==%selTem% (
		cecho {0a}Set to configure Local Security Policy {0b}!temChoices[%%i]!{#}
		echo.
		%lgpo% /g %configPath%\lgpoTemplates\%lspEditOs%\!temChoices[%%i]! /v
		cecho {0a}The CYBER POLICE have now set {0b}%lspEditOs% {0a}Local Security Policy to {0b}!temChoices[%%i]!{#}
		echo.
		call:manualVerify "secpol.msc"
		goto:EOF
	)
)
cecho {0b}%selTem% {0c}is not a valid template{#}
echo.
set /p aus="Continue? [Y/(N)]: "
if /i "%aus%" == "Y" goto:pickLspType
echo.
goto:EOF

:backuplsp
cecho {0b}A back up of secpol.msc will be created...{#}
echo.
set /p aus="Make backup? [Y/N]: "
if /i "%aus%" == "Y" (
	if not exist "%output%\lgpoBackup" mkdir "%output%\lgpoBackup"
	%lgpo% /b "%output%\lgpoBackup"
	cecho {0a}Backup of LSP created{#}
	echo.
) else (
	cecho {0c}Backup of LSP not created{#}
	echo.
)
goto:EOF

:firewall
echo The CYBER POLICE will now try to enable the firewall...
netsh advfirewall set allprofiles state on
netsh advfirewall set publicprofile firewallpolicy blockinboundalways,allowoutbound
cecho {0a}The CYBER POLICE have enabled the firewall{#}
echo.
echo The CYBER POLICE will now do some basic firewall hardening...
for /f "tokens=*" %%A in (%configPath%\FirewallRulesOFF.txt) do (
	set comCheck=%%%A:~0,1%
	if "!comCheck!" neq "#" (
		netsh advfirewall firewall set rule name="%%A" new enable=no 
	)
)
cecho {0a}The CYBER POLICE finished basic firewall hardening{#}
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
		cecho {07}Editing key {0b}!regKey!{#}
		echo.
		cecho {07}Editing variable type {0d}!regType!{#}
		echo.
		cecho {07}Applying value {0a}!regVal!{#}
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
		cecho {0a}Properties for {0b}%%A {0a}were changed{#}
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
cecho {0a}List has been made!{#}
echo.
echo CYBER POLICE will now look at windows features...
for /f "tokens=*" %%A in (%configPath%\BadWinFeatures.txt) do (
	cecho {07}CYBER POLICE are looking at feature {0b}%%A{#}
	echo.
	for /f "tokens=2 delims=:" %%B in ('%dism% /online /get-featureinfo /featurename:%%A ^| Find "State"') do set wfStatus=%%B
	for /f "tokens=* delims= " %%C in ("!wfStatus!") do set wfStatus=%%C
	
	cecho {0b}%%A{07}'s current status is {0b}!wfStatus!{#}
	echo.
	if "!wfStatus!" == "Disabled" (
		cecho {0e}No need to disable {0b}%%A{#}
		echo.
	) else (
		echo %%A>>%wfOutput%\DisabledWinFeatures.txt
		%dism% /online /disable-feature /featurename:%%A
		cecho {0a}Disabled feature {0b}%%A{#}
		echo.
	)
)
%dism% /online /Get-Features>%wfOutput%\StatusWFAfter.txt
echo CYBER POLICE are stopping misc connections...
net stop WinRM
%wmicPath% /interactive:off nicconfig where TcpipNetbiosOptions=1 call SetTcpipNetbios 2
%powershellPath% Disable-WindowsOptionalFeature -Online -FeatureName smb1protocol
%powershellPath% Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2
%powershellPath% Disable-WindowsOptionalFeature -Online -FeatureName MicrosoftWindowsPowerShellV2Root
cecho {0a}CYBER POLICE are done finding bad Windows features{#}
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
		cecho {0b}%%A {07}account is {0b}Disabled{#}
		echo.
	 ) else (
		cecho {0b}%%A {07}account is {0b}Enabled{#}
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
			cecho {0b}%~1 {0a}found!{#}
			echo.
			goto:EOF
		)
	)
)
for /f "tokens=* delims=" %%D in (%uOutDir%\authUsers.txt) do (
	set userChk=%%D
	if "%~1"=="!userChk!" (
		cecho {0b}%~1 {0a}found{#}
		echo.
		goto:EOF
	)
)

cecho {0b}%~1 {0c}not found{#}
echo.
cecho {0e}Disabling {0b}%~1{#}
echo.
net user %~1 /active:no
goto:EOF

:checkusersadmin
endlocal & set "user=%~1"
endlocal & set "pass=%~2"
for /f "tokens=*" %%B in (!uOutDir!\enabledUsers.txt) do (
	if "!user!"=="%%B" (
		cecho {0b}!user! {0a}admin found{#}
		echo.
		cecho {07}Giving {0b}!user! {07}password{#}
		echo.
		%powershellPath% Write-Host -Foregroundcolor Gray -NoNewLine ": "
		%powershellPath% Write-Host -Foregroundcolor Cyan "!pass!"
		net user !user! !pass!
		if %ERRORLEVEL% neq 0 (
			call:userError !user!
		)
		cecho {07}Managing {0b}!user! {07}admin{#}
		echo.
		%net% localgroup "Administrators" "!user!" /add
		goto:EOF
	) 
)
cecho {0b}!user! {0c}admin not found{#}
echo.
cecho {07}Creating {0b}!user! {07}and giving password{#}
echo.
%powershellPath% Write-Host -Foregroundcolor Gray -NoNewLine ": "
%powershellPath% Write-Host -Foregroundcolor Cyan "!pass!"
%net% user "!user!" "!pass!" /add
if %ERRORLEVEL% neq 0 (
	call:userError !user!
)
cecho {07}Managing {0b}!user! {07}admin{#}
echo.
%net% localgroup "Administrators" "!user!" /add
goto:EOF

:checkusers
endlocal & set "user=%~1"
endlocal & set "pass=%~2"
for /f "tokens=*" %%B in (!uOutDir!\enabledUsers.txt) do (
	if "!user!"=="%%B" (
		cecho {0b}!user! {0a}found{#}
		echo.
		cecho {07}Giving {0b}!user! {07} password{#}
		echo.
		%powershellPath% Write-Host -Foregroundcolor Gray -NoNewLine ": "
		%powershellPath% Write-Host -Foregroundcolor Cyan "!pass!"
		net user !user! !pass! 
		cecho {07}Managing {0b}!user! {07}user{#}
		echo.
		%net% localgroup "Users" "!user!" /add
		%net% localgroup "Administrators" "!user!" /delete
		goto:EOF
	) 
)
cecho {0b}!user! {0c}not found{#}
echo.
cecho {07}Creating {0b}!user! {07}with password{#}
echo.
%powershellPath% Write-Host -Foregroundcolor Gray -NoNewLine ": "
%powershellPath% Write-Host -Foregroundcolor Cyan "!pass!"
echo.
%net% user "!user!" "!pass!" /add 
cecho {07}Managing {0b}!user! {07}user{#}
echo.
%net% localgroup "Users" "!user!" /add
%net% localgroup "Administrators" "!user!" /delete
goto:EOF

:userError
cecho {0c}Looks like there was an error configuring {0b}%~1{#}
echo.
cecho {0e}It could be a password problem...{#}
echo.
cecho {0e}Change thier password to a default password, user might not be created if No (Default is Yes){#}
echo.
set /p aus="[Y/N]: "
if /i "%aus%" neq "N" (
	cecho {07}Current default password{#}
	%powershellPath% Write-Host -Foregroundcolor Gray -NoNewLine ": "
	%powershellPath% Write-Host -Foregroundcolor Cyan "!password!" 
	echo.
	%net% user "%~1" "!password!" /add

) else (
	cecho {0b}%~1 {0c}was not created{#}
	echo.
)
%net% user %~1 /active:yes
goto:EOF

:sessions
echo The CYBER POLICE will display connected remote sessions
net session
net session > %output%/CurrentRemoteSessions.txt
cecho {0a}Sessions are done showing{#}
echo.
goto:EOF

:rdp
echo The CYBER POLICE will manage Remote Desktop...
cecho {0e}Enable remote desktop (Default will loop back){#}
echo.
set /p rdpChk="[Y/N]:"
if %rdpChk%==y (
	echo Enabling remote desktop...
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v AllowTSConnections /t REG_DWORD /d 1 /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fAllowToGetHelp /t REG_DWORD /d 1 /f
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v UserAuthentication /t REG_DWORD /d 1 /f
	REG ADD "HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
	netsh advfirewall firewall set rule group="remote desktop" new enable=yes
	cecho {07}The CYBER POLICE suggest you check{#}
	echo.
	cecho {0b}Allow connections only from computers running Remote Desktop with Network Level Authentication{#}
	echo.
	call:manualVerify SystemPropertiesRemote.exe
	pause>nul
	cecho {0a}The CYBER POLICE enabled RDP{#}
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
	cecho {0a}The CYBER POLICE disabled RDP{#}
	echo.
	goto:EOF
)
cecho {0c}Invalid input {0b}%rdpChk%{#}
echo.
goto rdp

:secRDP
rem secure rdp

:power
echo the CYBER POLICE are setting power settings...
powercfg -SETDCVALUEINDEX SCHEME_BALANCED SUB_NONE CONSOLELOCK 1
powercfg -SETDCVALUEINDEX SCHEME_MIN SUB_NONE CONSOLELOCK 1
powercfg -SETDCVALUEINDEX SCHEME_MAX SUB_NONE CONSOLELOCK 1
cecho {0a}The CYBER POLICE set power settings!{#}
echo.
goto:EOF

:shares
echo The CYBER POLICE are logging shares...
net share
net share > %output%\shares.txt
cecho {0a}Shares have been logged{#}
echo.
echo.
call:manualVerify fsmgmt.msc
goto:EOF

:uac
echo The CYBER POLICE are enabling UAC...
reg ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 1 /f
cecho {0a}The CYBER POLICE have enabled UAC{#}
echo.
goto:EOF

:verifysys
echo "CYBER POLICE are verifying system files..."
cecho {0e}This will take a while, get a snack...{#}
echo.
sfc /verifyonly
cecho {0a}CYBER POLICE are finally done{#}
echo.
goto:EOF

:checkdns
echo The CYBER POLICE will display current dns...
ipconfig /displaydns
ipconfig /displaydns > %output%/CurrentDNS.txt
cecho {0d}Output ends here{#}
echo.
echo The CYBER POLICE will display hosts file
type C:\Windows\System32\Drivers\etc\hosts
type C:\Windows\System32\Drivers\etc\hosts > %output%/CurrentHOSTS.txt
cecho {0d}Output ends here{#}
echo.
echo The CYBER POLICE will now flush dns...
ipconfig /flushdns
cecho {0a}The CYBER POLICE have flushed dns{#}
echo.
echo The CYBER POLICE will now clear C:\Windows\System32\drivers\etc\hosts...
attrib -r -s C:\WINDOWS\system32\drivers\etc\hosts
echo > C:\Windows\System32\drivers\etc\hosts
attrib +r +s C:\WINDOWS\system32\drivers\etc\hosts
cecho {0a}The CYBER POLICE have cleared the HOSTS file{#}
echo.
goto:EOF

:allgpo
%powershellPath% -ExecutionPolicy Bypass -File "%powershellScriptPath%/AllGPOs.ps1"
goto:EOF

:backupgpos
if not exist "%output%\gpoBackups" mkdir "%output%\gpoBackups"
cscript.exe %vbScriptPath%\BackupAllGPOs.wsf %output%\gpoBackups /Comment:"Cyber Police Backup" /Domain:%domain%
goto:EOF

:listgpos
cscript.exe %vbScriptPath%\ListAllGPOs.wsf > %output%\gpoInfo\GposInfoNameAndIDs.txt
cscript.exe %vbScriptPath%\ListAllGPOs.wsf /v > %output%\gpoInfo\GposInfoNameAndIDsVerbose.txt
cecho If you want to delete a GPO run {0a}Remove-GPO -Name {0b}[name]{#} in powershell{#}
echo.
echo. 2>%output%\gpoInfo\Gpos.txt
echo GPOs in this domain:
for /f "tokens=* delims=" %%i in (%output%\gpoInfo\GposInfoNameAndIDs.txt) do (
	echo.%%i|findstr /C:"Name:" >nul 2>&1
	if not errorlevel 1 (
		for /f "delims=: tokens=2" %%j in ('echo %%i') do set gponame=%%j
		set gponame=!gponame:~1!
		cecho {0b}!gponame!{#}
		echo.
		echo !gponame! >> %output%\gpoInfo\Gpos.txt
	)
)
echo.
goto:EOF

:listdisabledgpos
cscript.exe %vbScriptPath%\FindDisabledGPOs.wsf 
goto:EOF

:gpoinfo
echo Getting all GPOS...
call:listgpos
for /f "tokens=* delims=" %%a in (%output%\gpoInfo\Gpos.txt) do (
	set currgpo=%%a
	set currgpo=!currgpo:~0,-1!
	cecho {0d}Getting {0b}!currgpo!{0d} info{#}
	echo. 
  	cscript.exe %vbScriptPath%\DumpGPOInfo.wsf "!currgpo!" 
	cecho {0d}End of {0b}!currgpo!{0d} info...{#}
	echo.
)
goto:EOF

:gporeport
rem %powershellPath% -ExecutionPolicy Bypass -File "%powershellScriptPath%/GPOReport.ps1"
cscript.exe %vbScriptPath%\GetReportsForAllGPOs.wsf %output%\gpoInfo\gpoReports
goto:EOF

:logfirewall
%powershellPath% -ExecutionPolicy Bypass -File "%powershellScriptPath%/LogFirewall.ps1"
netsh advfirewall export "%output%\logs\fwBackup.wfw"
goto:EOF

:logservices
%powershellPath% -ExecutionPolicy Bypass -File "%powershellScriptPath%/LogServices.ps1"
goto:EOF

:netstat
netstat -abno 
netstat -abno > %output%\logs\netstatlog.txt
goto:EOF

:checksync
dcdiag /q
dcdiag /q > %output%\logs\synclog.txt
goto:EOF

:createFile
%powershellPath% -ExecutionPolicy Bypass -File "%powershellScriptPath%/CreateFile.ps1" %~1 %~2
goto:EOF

:manualVerify
cecho {0b}Do you want to manually look at %~1 (Default is No){#}
echo.
set /p aus="[Y/N]: "
if /i "%aus%" neq "Y" goto:EOF
echo Running %~1...
echo.
start %~1 /wait
echo.
cecho {0e}Press any key to let the CYBER POLICE continue...{#}
echo.
pause >nul
goto:EOF