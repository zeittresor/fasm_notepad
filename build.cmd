@echo off
setlocal EnableExtensions
cd /d "%~dp0"

if not exist "bin" mkdir "bin"

set "FASM_EXE="
set "FASM_DIR="
set "FASM_INCLUDE="

call :find_local_fasm

rem 2) Otherwise use FASM_HOME.
if not defined FASM_EXE if defined FASM_HOME if exist "%FASM_HOME%\fasm.exe" set "FASM_EXE=%FASM_HOME%\fasm.exe"

rem 3) Otherwise search PATH.
if not defined FASM_EXE for /f "delims=" %%F in ('where fasm.exe 2^>nul') do if not defined FASM_EXE if exist "%%~fF" set "FASM_EXE=%%~fF"

rem 4) First-run bootstrap from the official FASM package.
if not defined FASM_EXE (
    echo FASM was not found. Attempting to download the official compiler package...
    call "%~dp0get_fasm.cmd"
    if errorlevel 1 (
        echo.
        echo ERROR: The automatic FASM download failed.
        echo You may also extract the official Windows package manually below tools\fasm.
        echo Download page: https://flatassembler.net/download.php
        pause
        exit /b 1
    )
    call :find_local_fasm
)

if not defined FASM_EXE (
    echo.
    echo ERROR: fasm.exe was not found after the bootstrap step.
    echo Extract FASM below tools\fasm, set FASM_HOME, or add FASM to PATH.
    pause
    exit /b 1
)

for %%D in ("%FASM_EXE%") do set "FASM_DIR=%%~dpD"

rem Prefer the normal package layout next to fasm.exe.
if exist "%FASM_DIR%INCLUDE\win32wx.inc" set "FASM_INCLUDE=%FASM_DIR%INCLUDE"
if not defined FASM_INCLUDE if exist "%FASM_DIR%include\win32wx.inc" set "FASM_INCLUDE=%FASM_DIR%include"

rem Search only for files that really exist. FOR /R with a literal filename can
rem manufacture non-existent paths, so WHERE /R is deliberately used here.
if not defined FASM_INCLUDE for /f "delims=" %%I in ('where /r "%FASM_DIR%" win32wx.inc 2^>nul') do if not defined FASM_INCLUDE if exist "%%~fI" set "FASM_INCLUDE=%%~dpI"
if not defined FASM_INCLUDE for /f "delims=" %%I in ('where /r "%CD%\tools" win32wx.inc 2^>nul') do if not defined FASM_INCLUDE if exist "%%~fI" set "FASM_INCLUDE=%%~dpI"

if not defined FASM_INCLUDE (
    echo.
    echo ERROR: win32wx.inc was not found.
    echo The complete Windows FASM package, including its INCLUDE directory, is required.
    pause
    exit /b 1
)

set "INCLUDE=%FASM_INCLUDE%"

echo.
echo Compiler: "%FASM_EXE%"
echo Includes: "%INCLUDE%"
echo.

"%FASM_EXE%" "src\FasmNotepad.asm" "bin\FasmNotepad.exe"
if errorlevel 1 (
    echo.
    echo BUILD FAILED.
    pause
    exit /b 1
)

echo.
echo BUILD SUCCESSFUL: bin\FasmNotepad.exe
exit /b 0

:find_local_fasm
rem Check common project-local layouts first.
if not defined FASM_EXE if exist "%CD%\tools\fasm.exe" set "FASM_EXE=%CD%\tools\fasm.exe"
if not defined FASM_EXE if exist "%CD%\tools\fasm\fasm.exe" set "FASM_EXE=%CD%\tools\fasm\fasm.exe"

rem Then search recursively, but accept only paths returned for real files.
if not defined FASM_EXE for /f "delims=" %%F in ('where /r "%CD%\tools" fasm.exe 2^>nul') do if not defined FASM_EXE if exist "%%~fF" set "FASM_EXE=%%~fF"
exit /b 0
