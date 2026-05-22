param([string]$logFile)

$lines = Get-Content $logFile

if (-not $lines) {
    Write-Host "No entries"
    exit
}

Write-Host ("Total commands: " + $lines.Count)

$durations = @()
$cmds = @()

foreach ($line in $lines) {
    if ($line -match ',(\d+)ms,') {
        $durations += [int]$matches[1]
    }
    if ($line -match '^[^,]*,[^,]*,"(.*?)"') {
        $c = $matches[1].Trim().Split()[0]
        if ($c -and $c -ne '-c') {
            $cmds += $c
        }
    }
}

if ($durations.Count -gt 0) {
    $avg = [math]::Round(($durations | Measure-Object -Average).Average)
    $max = ($durations | Measure-Object -Maximum).Maximum
    Write-Host ("Avg duration: " + $avg + "ms")
    Write-Host ("Max duration: " + $max + "ms")
}

$cmdGroups = $cmds | Group-Object | Sort-Object Count -Descending | Select-Object -First 10
Write-Host "Top commands:"
$cmdGroups | ForEach-Object {
    Write-Host ("  " + $_.Count.ToString().PadLeft(5) + "x  " + $_.Name)
}
