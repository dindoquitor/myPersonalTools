@echo off
Title Checking Internet Connection & Mode 70,7 & color 0B
::-------------------------------------------------------------------------------------
REM First We Check The Status Of The Internet Connection
Call :Check_Connection
::-------------------------------------------------------------------------------------
:Main
Title Your External IP Address
Mode 50,7 & Color 0A
for /f "tokens=2 delims=: " %%A in (
  'nslookup myip.opendns.com. resolver1.opendns.com 2^>NUL^|find "Address:" ^| findstr /v "208.67.222.222" '
) do ( 
  If "%%A" NEQ "127.0.0.1" (
    set "ExtIP=%%A"
  ) else (
    Color 0C & echo(
    echo              No internet connection !
  )
)
echo(
If defined ExtIP (
  echo       You are connected to the internet !
  echo       Your External IP is : %ExtIP%
  echo       Your Internal IP is : %IntIP%
  echo       Your MAC Address is : %MAC%
  echo       Response Time: %responseTime% ms
  echo       Created by: Dindo O. Quitor, CPA
)
Pause>nul & Exit
::-------------------------------------------------------------------------------------
:Check_Connection
Title Checking Internet Connection ...
SetLocal EnableDelayedExpansion
Mode 50,7 & Color 0B
echo(
echo(  Please Wait... Checking Internet Connection ...
Timeout /T 1 /NoBreak>nul
Ping www.google.nl -n 1 -w 1000 >nul
cls
echo(
if [!errorlevel!] EQU [1] (
  Color 0C & set "internet=Not Connected To Internet"
  echo(  Connection Status : !Internet!
  CMD /C %SystemRoot%\system32\msdt.exe ^
  Skip TRUE -path %Windir%\diagnostics\system\networking -ep NetworkDiagnosticsPNI
  Timeout /T 1 /NoBreak>nul & Goto Check_Connection
) else (
  Color 0A & set "internet=Connected To Internet"
  echo(    Connection Status : !Internet!
  
  REM Measure Response Time
  for /f "tokens=5 delims==< " %%B in (
    'ping -n 1 www.google.com ^| find "time="'
  ) do (
    set "responseTime=%%B"
  )

  REM Get Internal IP Address
  for /f "tokens=2 delims=:" %%B in (
    'ipconfig ^| findstr /i "IPv4 Address"'
  ) do (
    set "IntIP=%%B"
  )

  REM Get Ethernet MAC Address
  for /f "skip=1 tokens=2 delims=," %%C in (
  'wmic nic where "NetConnectionID like '%%Ethernet%%'" get MACAddress /format:csv'
  ) do (
    set "MAC=%%C"
  )
  
  Timeout /T 1 /NoBreak>nul & Goto Main
)
EndLocal
::-------------------------------------------------------------------------------------