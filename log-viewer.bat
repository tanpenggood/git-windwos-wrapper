@echo off
:: Git Command Log Viewer (PowerShell version)
:: Displays and analyzes logged git commands

set "LOG_DIR=%USERPROFILE%\.git-wrapper-logs"
set "LOG_FILE=%LOG_DIR%\git-commands.log"
set "PS_STATS=%~dp0log-stats.ps1"
set "PS_SLOW=%~dp0log-slow.ps1"
set "PS_TAIL=%~dp0log-tail.ps1"

if not exist "%LOG_FILE%" (
    echo No log file found at: %LOG_FILE%
    echo Run some git commands first to generate logs.
    pause
    exit /b 1
)

:menu
cls
echo ============================================
echo    Git Command Log Viewer (PowerShell Wrapper)
echo ============================================
echo Log file: %LOG_FILE%
echo ============================================
echo.
echo 1. View all logs (last 50 entries)
echo 2. View slow commands (over 1000ms)
echo 3. Search by command keyword
echo 4. Statistics summary
echo 5. Live tail (follow new entries)
echo 6. Clear logs
echo 7. Exit
echo.

set /p choice="Select option: "

if "%choice%"=="1" goto view_all
if "%choice%"=="2" goto view_slow
if "%choice%"=="3" goto search
if "%choice%"=="4" goto stats
if "%choice%"=="5" goto live
if "%choice%"=="6" goto clear
if "%choice%"=="7" exit /b

echo Invalid option.
pause
goto menu

:view_all
cls
echo ============================================
echo    Last 50 Log Entries
echo ============================================
echo.
powershell -NoProfile -Command "Get-Content '%LOG_FILE%' -Tail 50 | ForEach-Object { Write-Host $_ }"
echo.
echo Press any key to return...
pause > nul
goto menu

:view_slow
cls
echo ============================================
echo    Slow Commands (over 1000ms)
echo ============================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SLOW%" "%LOG_FILE%" 1000
echo.
echo Press any key to return...
pause > nul
goto menu

:search
cls
echo ============================================
echo    Search Logs
echo ============================================
echo.
set /p keyword="Enter search keyword: "
if "%keyword%"=="" goto menu
echo.
powershell -NoProfile -Command "Get-Content '%LOG_FILE%' | Select-String -Pattern '%keyword%' | ForEach-Object { Write-Host $_ }"
echo.
echo Press any key to return...
pause > nul
goto menu

:stats
cls
echo ============================================
echo    Log Statistics
echo ============================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_STATS%" "%LOG_FILE%"
echo.
echo Press any key to return...
pause > nul
goto menu

:live
cls
echo ============================================
echo    Live Log Tail
echo ============================================
echo Watching for new entries (press Ctrl+C to stop)...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_TAIL%" "%LOG_FILE%" 10
echo.
pause
goto menu

:clear
cls
echo ============================================
echo    Clear Logs
echo ============================================
echo.
set /p confirm="Clear all logs? (y/N): "
if /i "%confirm%"=="y" (
    echo. > "%LOG_FILE%"
    echo Logs cleared.
) else (
    echo Cancelled.
)
echo.
pause
goto menu
