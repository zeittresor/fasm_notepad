@echo off
setlocal EnableExtensions
cd /d "%~dp0"

where powershell.exe >nul 2>&1
if errorlevel 1 (
    echo ERROR: Windows PowerShell was not found.
    exit /b 1
)

rem This wrapper applies ExecutionPolicy Bypass only to this PowerShell process.
rem It does not modify the user's or machine's persistent execution policy.
powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%~dp0get_fasm.ps1" %*
if errorlevel 1 (
    echo.
    echo ERROR: FASM bootstrap failed.
    exit /b 1
)

exit /b 0
