param([string]$logFile, [int]$minDuration = 1000)

$lines = Get-Content $logFile

$lines | Where-Object {
    $_ -match ',(\d+)ms,'
} | Where-Object {
    [int]$matches[1] -gt $minDuration
} | Sort-Object {
    if ($_ -match ',(\d+)ms,') { [int]$matches[1] } else { 0 }
} -Descending | ForEach-Object {
    Write-Host $_
}
