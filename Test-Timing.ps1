# Quick debug test
$start = [System.Diagnostics.Stopwatch]::StartNew()

$result = pwsh -NoProfile -Command "Write-Host 'Test'; Start-Sleep -Milliseconds 100; exit 0"

$start.Stop()
$elapsed = $start.Elapsed.TotalMilliseconds

Write-Host "Elapsed time: ${elapsed:F2}ms" -ForegroundColor Green
Write-Host "Last exit code: $LASTEXITCODE" -ForegroundColor Yellow
