# Title: Ping_LAN_range
#
\\ Automation Script for Pinging a LAN Range
\\ Author  :Philip Prochazka
\\ Revision:1.0
\\ Repository: https://github.com/philprohazka/Lazyadmin/Ping-LAN-Range
## Method 1: Simple Sequential Ping
```powershell

# Ping all IPs in the range
1..254 | ForEach-Object {
    $ip = "10.60.12.$_"
    if (Test-Connection -ComputerName $ip -Count 1 -Quiet) {
        Write-Host "$ip is online" -ForegroundColor Green
    } else {
        Write-Host "$ip is offline" -ForegroundColor Red
    }
}
```

## Method 2: Parallel Ping (Much Faster)
```powershell
# Parallel processing for faster results
1..254 | ForEach-Object -Parallel {
    $ip = "10.60.12.$_"
    if (Test-Connection -ComputerName $ip -Count 1 -Quiet -TimeoutSeconds 1) {
        Write-Host "$ip is online" -ForegroundColor Green
    }
} -ThrottleLimit 50
```

## Method 3: Detailed Results with Timing
```powershell
# Get detailed ping results
$results = @()
1..254 | ForEach-Object {
    $ip = "10.60.12.$_"
    try {
        $ping = Test-Connection -ComputerName $ip -Count 1 -ErrorAction Stop
        $results += [PSCustomObject]@{
            IP = $ip
            Status = "Online"
            ResponseTime = $ping.ResponseTime
            Hostname = try { [System.Net.Dns]::GetHostEntry($ip).HostName } catch { "Unknown" }
        }
        Write-Host "$ip is online (${($ping.ResponseTime)}ms)" -ForegroundColor Green
    }
    catch {
        $results += [PSCustomObject]@{
            IP = $ip
            Status = "Offline"
            ResponseTime = $null
            Hostname = $null
        }
    }
}

# Display summary
$results | Where-Object Status -eq "Online" | Format-Table -AutoSize
```

## Method 4: Fast Network Discovery with Jobs
```powershell
# Using background jobs for maximum speed
$jobs = @()
1..254 | ForEach-Object {
    $ip = "10.60.12.$_"
    $jobs += Start-Job -ScriptBlock {
        param($target)
        if (Test-Connection -ComputerName $target -Count 1 -Quiet -TimeoutSeconds 1) {
            return $target
        }
    } -ArgumentList $ip
}

# Wait for all jobs and collect results
$onlineHosts = $jobs | Wait-Job | Receive-Job | Where-Object { $_ }
$jobs | Remove-Job

Write-Host "Online hosts found:" -ForegroundColor Yellow
$onlineHosts | ForEach-Object { Write-Host $_ -ForegroundColor Green }
```

## Method 5: One-Liner for Quick Scan
```powershell
# Quick one-liner to show only online hosts
1..254 | Where-Object {Test-Connection -ComputerName "10.60.12.$_" -Count 1 -Quiet} | ForEach-Object {"10.60.12.$_ is online"}
```

## Method 6: Advanced Scan with Port Check
```powershell
# Ping + common port check
$onlineHosts = @()
1..254 | ForEach-Object -Parallel {
    $ip = "10.60.12.$_"
    if (Test-Connection -ComputerName $ip -Count 1 -Quiet -TimeoutSeconds 1) {
        # Test common ports
        $ports = @(22, 80, 135, 139, 443, 445)
        $openPorts = @()
        
        foreach ($port in $ports) {
            if (Test-NetConnection -ComputerName $ip -Port $port -InformationLevel Quiet -WarningAction SilentlyContinue) {
                $openPorts += $port
            }
        }
        
        [PSCustomObject]@{
            IP = $ip
            Status = "Online"
            OpenPorts = $openPorts -join ","
            Hostname = try { [System.Net.Dns]::GetHostEntry($ip).HostName } catch { "Unknown" }
        }
    }
} -ThrottleLimit 50 | ForEach-Object { 
    $onlineHosts += $_
    Write-Host "$($_.IP) is online - Ports: $($_.OpenPorts)" -ForegroundColor Green 
}
```

## Method 7: Export Results to File
```powershell
# Scan and export to CSV
$scanResults = 1..254 | ForEach-Object -Parallel {
    $ip = "10.60.12.$_"
    [PSCustomObject]@{
        IP = $ip
        Online = (Test-Connection -ComputerName $ip -Count 1 -Quiet -TimeoutSeconds 1)
        Timestamp = Get-Date
    }
} -ThrottleLimit 50

$scanResults | Export-Csv -Path "lan_scan_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv" -NoTypeInformation
$scanResults | Where-Object Online | Format-Table
```

**Recommendations:**
- Use **Method 2** for fastest results on large networks
- Use **Method 3** for detailed information including response times
- Use **Method 6** if you also want to check for common services
- Adjust `-ThrottleLimit` based on your network capacity (higher = faster but more network load)

The parallel methods will complete much faster than sequential scanning, especially on larger network ranges.