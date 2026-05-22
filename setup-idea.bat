@echo off
setlocal enabledelayedexpansion

:: Git Wrapper Setup for IntelliJ IDEA
:: Configures IDEA to use the git wrapper instead of direct git.exe

set "WRAPPER_DIR=%~dp0"
set "WRAPPER_SCRIPT=%WRAPPER_DIR%git-wrapper.bat"

:: Check if wrapper exists
if not exist "%WRAPPER_SCRIPT%" (
    echo ERROR: git-wrapper.bat not found at: %WRAPPER_SCRIPT%
    pause
    exit /b 1
)

:: Convert to Windows short path (no spaces)
for %%A in ("%WRAPPER_SCRIPT%") do set "WRAPPER_SHORT_PATH=%%~sA"

cls
echo ============================================
echo    Git Wrapper Setup for IntelliJ IDEA
echo    (PowerShell Version)
echo ============================================
echo.
echo This will configure IDEA to use the git wrapper
echo for logging all git commands executed by plugins.
echo.
echo Wrapper: PowerShell  (more reliable than batch)
echo Log dir: %%USERPROFILE%%\.git-wrapper-logs\
echo.
echo Wrapper location: %WRAPPER_SCRIPT%
echo.

:: Find common IDEA config locations
set "IDEA_CONFIG_DIRS="

:: Check for JetBrains Toolbox installations
if exist "%LOCALAPPDATA%\JetBrains\Toolbox\apps" (
    for /d %%D in ("%LOCALAPPDATA%\JetBrains\Toolbox\apps\IDEA\*") do (
        for /d %%C in ("%%D\*") do (
            if exist "%%C\config\options" (
                set "IDEA_CONFIG_DIRS=!IDEA_CONFIG_DIRS! %%C\config\options"
            )
        )
    )
)

:: Check for standalone installations
if exist "%APPDATA%\JetBrains" (
    for /d %%D in ("%APPDATA%\JetBrains\IntelliJIdea*") do (
        if exist "%%D\config\options" (
            set "IDEA_CONFIG_DIRS=!IDEA_CONFIG_DIRS! %%D\config\options"
        )
    )
)

if "%IDEA_CONFIG_DIRS%"=="" (
    echo Could not find IDEA configuration directories.
    echo.
    echo Please manually configure IDEA:
    echo 1. Open IDEA
    echo 2. Go to Settings ^> Version Control ^> Git
    echo 3. Set "Path to Git executable" to:
    echo    %WRAPPER_SCRIPT%
    echo 4. Apply and restart IDEA
    echo.
    pause
    exit /b 1
)

echo Found IDEA config directories:
echo.

set "IDX=0"
for %%D in (%IDEA_CONFIG_DIRS%) do (
    set /a "IDX+=1"
    echo !IDX!. %%D
)
echo.

set /p choice="Select config directory to modify (or 0 for manual instructions): "

if "%choice%"=="0" goto manual

:: Validate selection
set "SELECTED_DIR="
set "IDX=0"
for %%D in (%IDEA_CONFIG_DIRS%) do (
    set /a "IDX+=1"
    if "!IDX!"=="%choice%" set "SELECTED_DIR=%%D"
)

if "!SELECTED_DIR!"=="" (
    echo Invalid selection.
    pause
    exit /b 1
)

:: Backup existing config
set "GIT_CONFIG_FILE=!SELECTED_DIR!\git.xml"
if exist "%GIT_CONFIG_FILE%" (
    copy "%GIT_CONFIG_FILE%" "%GIT_CONFIG_FILE%.backup" > nul
    echo Backed up existing config to: %GIT_CONFIG_FILE%.backup
)

:: Create or update git.xml
echo ^<?xml version="1.0" encoding="UTF-8"?^> > "%GIT_CONFIG_FILE%"
echo ^<application^> >> "%GIT_CONFIG_FILE%"
echo   ^<component name="Git.Application.Settings"^> >> "%GIT_CONFIG_FILE%"
echo     ^<option name="GIT_EXECUTABLE" value="%WRAPPER_SHORT_PATH%" /^> >> "%GIT_CONFIG_FILE%"
echo   ^</component^> >> "%GIT_CONFIG_FILE%"
echo ^</application^> >> "%GIT_CONFIG_FILE%"

echo.
echo Configuration updated: %GIT_CONFIG_FILE%
echo.
echo ============================================
echo IMPORTANT: Restart IntelliJ IDEA for changes to take effect
echo ============================================
echo.
echo To verify:
echo 1. Open IDEA
echo 2. Go to Settings ^> Version Control ^> Git
echo 3. Confirm "Path to Git executable" shows the wrapper path
echo 4. Run any git command and check logs folder
echo.
echo Logs will be saved to: %WRAPPER_DIR%logs\
echo.

pause
exit /b 0

:manual
cls
echo ============================================
echo    Manual Configuration Instructions
echo ============================================
echo.
echo 1. Open IntelliJ IDEA
echo.
echo 2. Navigate to:
echo    File ^> Settings ^> Version Control ^> Git
echo    (or press Ctrl+Alt+S, then search for "Git")
echo.
echo 3. Find "Path to Git executable"
echo.
echo 4. Set it to:
echo    %WRAPPER_SCRIPT%
echo.
echo 5. Click "Test" to verify it works
echo    (should show git version)
echo.
echo 6. Click "Apply" and "OK"
echo.
echo 7. Restart IDEA
echo.
echo ============================================
echo Logs will be saved to: %WRAPPER_DIR%logs\
echo ============================================
echo.

pause
exit /b 0
