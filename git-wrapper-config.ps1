# Git Wrapper Configuration - PowerShell Version

# Enable/disable logging
$global:GIT_WRAPPER_ENABLED = $true

# Log directory (MUST be outside the project directory to avoid feedback loop)
$global:GIT_WRAPPER_LOG_DIR = Join-Path $env:USERPROFILE ".git-wrapper-logs"

# Log file name
$global:GIT_WRAPPER_LOG_FILE = "git-commands.log"

# Path to the real git executable
# Leave as "git.exe" if git is in PATH, otherwise specify full path
$global:GIT_WRAPPER_REAL_GIT = "git.exe"
