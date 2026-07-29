@echo off
call "%~dp0build.cmd"
if errorlevel 1 exit /b %errorlevel%
start "" "%~dp0bin\FasmNotepad.exe"
