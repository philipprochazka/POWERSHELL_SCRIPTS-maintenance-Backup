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
            IP        = $ip
            Status    = "Online"
            OpenPorts = $openPorts -join ","
            Hostname  = try { [System.Net.Dns]::GetHostEntry($ip).HostName } catch { "Unknown" }
        }
    }
} -ThrottleLimit 50 | ForEach-Object { 
    $onlineHosts += $_
    Write-Host "$($_.IP) is online - Ports: $($_.OpenPorts)" -ForegroundColor Green 
}