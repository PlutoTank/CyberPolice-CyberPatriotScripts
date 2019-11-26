@echo off
color 0D
setlocal
cd /d %~dp0
set ip_address_string="IPv4 Address"
set adapter="LAN"
set adapterfound=false
echo ===========================================
echo Elite Gamer Hacking Squad: Epic Net Hacker!
echo ===========================================
:start
for /f "delims=: tokens=2" %%a in ('ipconfig ^| find "IPv4"') do set IPAddress=%%a
echo Your IP: %IPAddress%
echo Hit [1] for connection test
echo Hit [2] for open port checker
echo hit [x] to escape
choice /n /c:x12 >nul
echo.
if %errorlevel%==1 (goto finished)
if %errorlevel%==2 (goto connect)
if %errorlevel%==3 (goto port)
goto finished
:connect
set /P ip=Target IP: 
powershell -ExecutionPolicy RemoteSigned -File "%cd%/QPingTest.ps1" %ip%
goto yn


:port
set /P ip=Target IP:  
set /P port=Port: 
echo running from %cd%...
powershell -ExecutionPolicy RemoteSigned -File "%cd%/QTelnet.ps1" %ip% %port% 
goto yn
:yn
choice /m "continue" /c yn 
echo.
echo.
if %errorlevel%==1 (goto start)
if %errorlevel%==2 (goto finished)
goto finished
:finished