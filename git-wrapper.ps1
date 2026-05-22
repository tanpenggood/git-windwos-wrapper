# Git Wrapper for IDEA - PowerShell Version
# Logs all git commands with timestamp, duration, working directory, and exit code

# Configuration
$wrapperDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configFile = Join-Path $wrapperDir "git-wrapper-config.ps1"
$defaultLogDir = Join-Path $env:USERPROFILE ".git-wrapper-logs"
$defaultLogFile = "git-commands.log"
$realGit = "git.exe"

# Load configuration
if (Test-Path $configFile) {
    . $configFile
}

# Apply defaults
if (-not $global:GIT_WRAPPER_LOG_DIR) { $global:GIT_WRAPPER_LOG_DIR = $defaultLogDir }
if (-not $global:GIT_WRAPPER_LOG_FILE) { $global:GIT_WRAPPER_LOG_FILE = $defaultLogFile }
if (-not $global:GIT_WRAPPER_REAL_GIT) { $global:GIT_WRAPPER_REAL_GIT = $realGit }
if (-not $global:GIT_WRAPPER_ENABLED) { $global:GIT_WRAPPER_ENABLED = $true }

if (-not $global:GIT_WRAPPER_ENABLED) {
    & $global:GIT_WRAPPER_REAL_GIT $args
    exit $LASTEXITCODE
}

# Create log directory if needed
if (-not (Test-Path $global:GIT_WRAPPER_LOG_DIR)) {
    New-Item -ItemType Directory -Path $global:GIT_WRAPPER_LOG_DIR -Force | Out-Null
}

$logFile = Join-Path $global:GIT_WRAPPER_LOG_DIR $global:GIT_WRAPPER_LOG_FILE
$workDir = (Get-Location).Path
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$startTime = Get-Date

# Build clean command string (strip -c config args)
$cleanArgs = @()
$skipNext = $false
foreach ($arg in $args) {
    if ($skipNext) { $skipNext = $false; continue }
    if ($arg -eq '-c') { $skipNext = $true; continue }
    if ($arg -like '-c *') { continue }
    $cleanArgs += $arg
}
$command = "git " + ($cleanArgs -join " ").Replace('"', '""')
if ([string]::IsNullOrEmpty($command.Trim())) { $command = "(no arguments)" }

# Execute real git
& $global:GIT_WRAPPER_REAL_GIT $args
$exitCode = $LASTEXITCODE
$endTime = Get-Date
$durationMs = [math]::Round(($endTime - $startTime).TotalMilliseconds)

# Format log entry (CSV)
$logEntry = '"' + $timestamp + '","' + $workDir + '","' + $command + '",' + $durationMs + 'ms,' + $exitCode

# Write to log file (with retry)
$maxRetries = 3
$retryCount = 0
$logged = $false
while (-not $logged -and $retryCount -lt $maxRetries) {
    try {
        Add-Content -Path $logFile -Value $logEntry -Encoding UTF8 -ErrorAction Stop
        $logged = $true
    } catch {
        $retryCount++
        Start-Sleep -Milliseconds 10
    }
}

exit $exitCode
