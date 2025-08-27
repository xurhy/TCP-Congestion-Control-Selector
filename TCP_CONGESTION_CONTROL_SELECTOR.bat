@echo off
title xury TCP Congestion Control Selector - CUBIC/BBR/BBR2
setlocal enabledelayedexpansion

:menu
cls
echo =======================================================
echo        xury TCP CONGESTION CONTROL SELECTOR
echo =======================================================
echo.
echo   1. CUBIC (default - fair)
echo   2. BBR (high performance, low latency)
echo   3. BBR2 (improved BBR if supported)
echo   4. Check current settings
echo   5. Exit
echo.

choice /C 12345 /N /M "Select option [1-5]: "
if errorlevel 5 exit /b
if errorlevel 4 goto CHECK
if errorlevel 3 goto BBR2
if errorlevel 2 goto BBR
if errorlevel 1 goto CUBIC

:CUBIC
cls
echo [*] Configuring CUBIC...
%= One-line configuration for all templates =%
for %%A in (Internet Datacenter Compat DatacenterCustom InternetCustom Automatic) do (
    netsh int tcp set supplemental Template=%%A CongestionProvider=CUBIC >nul
)
echo [+] CUBIC enabled successfully
timeout /t 1 >nul
goto menu

:BBR
cls
echo [*] Configuring BBR...
for %%A in (Internet Datacenter Compat DatacenterCustom InternetCustom Automatic) do (
    netsh int tcp set supplemental Template=%%A CongestionProvider=BBR >nul
)
echo [+] BBR enabled successfully
timeout /t 1 >nul
goto menu

:BBR2
cls
echo [*] Attempting BBR2 configuration...
netsh int tcp set supplemental Template=Internet CongestionProvider=BBR2 >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] BBR2 not supported - defaulting to BBR
    timeout /t 1 >nul
    goto BBR
)
for %%A in (Datacenter Compat DatacenterCustom InternetCustom Automatic) do (
    netsh int tcp set supplemental Template=%%A CongestionProvider=BBR2 >nul
)
echo [+] BBR2 enabled successfully
timeout /t 1 >nul
goto menu

:CHECK
cls
echo [*] Current TCP Settings:
echo.
powershell "Get-NetTCPSetting | Select-Object SettingName, CongestionProvider | Format-Table -AutoSize"
echo.
echo Press any key to continue...
pause >nul
goto menu