# Scan and export to CSV
$scanResults = 1..254 | ForEach-Object -Parallel {
    $ip = "10.60.12.$_"
    [PSCustomObject]@{
        IP        = $ip
        Online    = (Test-Connection -ComputerName $ip -Count 1 -Quiet -TimeoutSeconds 1)
        Timestamp = Get-Date
    }
} -ThrottleLimit 50

$scanResults | Export-Csv -Path "${env:userprofile}\lan_scan\lan_scan_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv" -NoTypeInformation
$scanResults | Where-Object Online | Format-Table
$openResults | 
else {
    Write-Host "$ip is offline" -ForegroundColor Red
}
}