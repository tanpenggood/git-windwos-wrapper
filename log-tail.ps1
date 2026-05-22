param([string]$logFile, [int]$tailCount = 10)

$maxRetries = 5
$retryDelay = 200

for ($attempt = 0; $attempt -lt $maxRetries; $attempt++) {
    try {
        Get-Content -Path $logFile -Tail $tailCount -Wait -ErrorAction Stop
        break
    } catch {
        if ($attempt -lt ($maxRetries - 1)) {
            Start-Sleep -Milliseconds $retryDelay
        } else {
            Write-Host "Error: $_"
        }
    }
}
