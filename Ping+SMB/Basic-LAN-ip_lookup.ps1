1..254 | ForEach-Object {
    $ip = "10.60.12.$_"
    if (Test-Connection -ComputerName $ip -Count 1 -Quiet) {
        Write-Host "$ip is online" -ForegroundColor Green
    }
    else {
        Write-Host "$ip is offline" -ForegroundColor Red
    }
}