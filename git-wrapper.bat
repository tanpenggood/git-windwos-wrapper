@echo off
:: Git Wrapper Launcher - calls PowerShell wrapper, avoids batch parsing issues
:: Set this .bat as the git executable in IDEA

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0git-wrapper.ps1" %*
exit /b %ERRORLEVEL%
