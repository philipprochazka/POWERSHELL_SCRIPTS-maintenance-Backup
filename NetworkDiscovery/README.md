# NetworkDiscovery Module

A comprehensive PowerShell module for network discovery and enumeration using Ping+SMB scanning techniques.

## Features

### 🌐 Network Discovery
- **Concurrent ICMP ping scanning** with configurable parallelism
- **TCP port scanning** for common services (HTTP, HTTPS, SSH, SMB, RDP, etc.)
- **Device type detection** (Windows/SMB, Linux/Unix, Web Server, RDP hosts)
- **DNS resolution** and reverse lookup capabilities
- **Performance optimized** with PowerShell runspace pools

### 📡 Connectivity Testing
- **Multi-method connectivity testing** (ICMP, TCP, SMB, WMI)
- **Service identification** for discovered open ports
- **Response time measurement** for performance analysis
- **Comprehensive reporting** with detailed results

### 📂 SMB Enumeration
- **SMB/CIFS share discovery** with anonymous and authenticated modes
- **Share accessibility testing** with permission validation
- **Hidden administrative shares** enumeration (C$, ADMIN$, IPC$)
- **Cross-platform compatibility** (Windows PowerShell and PowerShell Core)

## Quick Start

### Installation
```powershell
# Import the module
Import-Module .\NetworkDiscovery\NetworkDiscovery.psd1

# Or add to your PowerShell profile for automatic loading
```

### Basic Usage

#### Network Discovery
```powershell
# Scan a subnet for active devices
Find-NetworkDevices -NetworkRange "192.168.1.0/24"

# Advanced scan with SMB enumeration
Find-NetworkDevices -NetworkRange "10.0.0.0/16" -EnableSMBScan -MaxConcurrency 100

# Custom port scanning
Find-NetworkDevices -NetworkRange "192.168.1.0/24" -CustomPorts @(8080, 9090, 8443)
```

#### Connectivity Testing
```powershell
# Test connectivity to a specific host
Test-NetworkConnectivity -ComputerName "server01"

# Comprehensive testing with SMB and WMI
Test-NetworkConnectivity -ComputerName "192.168.1.100" -EnableSMBTest -EnableWMITest

# Custom port testing
Test-NetworkConnectivity -ComputerName "web-server" -Ports @(80, 443, 8080)
```

#### SMB Share Enumeration
```powershell
# Enumerate accessible SMB shares
Get-SMBShares -ComputerName "file-server"

# Include hidden administrative shares
Get-SMBShares -ComputerName "192.168.1.10" -IncludeHidden

# Authenticated enumeration
$Creds = Get-Credential
Get-SMBShares -ComputerName "domain-server" -Credential $Creds
```

## Advanced Examples

### Enterprise Network Audit
```powershell
# Discover all devices in multiple subnets
$Networks = @("192.168.1.0/24", "192.168.2.0/24", "10.0.0.0/16")
$AllDevices = @()

foreach ($Network in $Networks) {
    Write-Host "Scanning $Network..." -ForegroundColor Cyan
    $Devices = Find-NetworkDevices -NetworkRange $Network -EnableSMBScan -MaxConcurrency 50
    $AllDevices += $Devices
}

# Generate summary report
$AllDevices | Group-Object DeviceType | Sort-Object Count -Descending
```

### Security Assessment
```powershell
# Find devices with open SMB ports
$SMBDevices = Find-NetworkDevices -NetworkRange "192.168.1.0/24" | 
    Where-Object { 445 -in $_.OpenPorts -or 139 -in $_.OpenPorts }

# Test SMB share accessibility
foreach ($Device in $SMBDevices) {
    Write-Host "Checking SMB shares on $($Device.IPAddress)..." -ForegroundColor Yellow
    $Shares = Get-SMBShares -ComputerName $Device.IPAddress
    
    # Report accessible shares
    $AccessibleShares = $Shares | Where-Object { $_.IsAccessible }
    if ($AccessibleShares) {
        Write-Warning "Found $($AccessibleShares.Count) accessible shares on $($Device.IPAddress)"
        $AccessibleShares | Format-Table ShareName, ShareType, AccessTest
    }
}
```

### Performance Monitoring
```powershell
# Monitor network response times
$CriticalHosts = @("domain-controller", "file-server", "web-server", "database-server")

foreach ($Host in $CriticalHosts) {
    $Result = Test-NetworkConnectivity -ComputerName $Host
    
    if ($Result.IsOnline) {
        $Color = if ($Result.PingResponseTime -lt 10) { "Green" } 
                elseif ($Result.PingResponseTime -lt 50) { "Yellow" } 
                else { "Red" }
        
        Write-Host "$Host : $($Result.PingResponseTime)ms" -ForegroundColor $Color
    } else {
        Write-Host "$Host : OFFLINE" -ForegroundColor Red
    }
}
```

## Function Reference

### Find-NetworkDevices
Discovers active devices on a network range using concurrent ping and port scanning.

**Parameters:**
- `NetworkRange` - CIDR notation network range (e.g., "192.168.1.0/24")
- `CustomPorts` - Array of additional ports to scan
- `EnableSMBScan` - Enable SMB enumeration for discovered devices
- `Timeout` - Network operation timeout in milliseconds (default: 1000)
- `MaxConcurrency` - Maximum concurrent operations (default: 50)
- `IncludeOffline` - Include unreachable devices in results

### Test-NetworkConnectivity
Performs comprehensive connectivity testing for specific hosts.

**Parameters:**
- `ComputerName` - Target hostname or IP address
- `Ports` - Array of ports to test (default: common ports)
- `EnableSMBTest` - Enable SMB connectivity testing
- `EnableWMITest` - Enable WMI connectivity testing
- `Timeout` - Network operation timeout in milliseconds (default: 3000)

### Get-SMBShares
Enumerates SMB/CIFS shares on Windows systems.

**Parameters:**
- `ComputerName` - Target hostname or IP address
- `Credential` - Credential object for authenticated access
- `IncludeHidden` - Include administrative shares (C$, ADMIN$, etc.)

## Output Objects

### NetworkDevice (Find-NetworkDevices)
```powershell
[PSCustomObject]@{
    IPAddress = "192.168.1.100"
    Hostname = "server01.domain.com"
    IsOnline = $true
    ResponseTime = 15
    OpenPorts = @(80, 443, 445)
    SMBInfo = @{ NetBIOSName = "SERVER01"; Domain = "DOMAIN" }
    Services = @(
        @{ Port = 80; Service = "HTTP"; State = "Open" },
        @{ Port = 443; Service = "HTTPS"; State = "Open" },
        @{ Port = 445; Service = "SMB/CIFS"; State = "Open" }
    )
    LastSeen = "2024-01-15T10:30:00"
    DeviceType = "Windows/SMB"
}
```

### ConnectivityResult (Test-NetworkConnectivity)
```powershell
[PSCustomObject]@{
    ComputerName = "server01"
    IPAddress = "192.168.1.100"
    IsOnline = $true
    PingResponseTime = 12
    PortTests = @(
        @{ Port = 80; Status = "Open"; ResponseTime = 15.5; Service = "HTTP" },
        @{ Port = 443; Status = "Open"; ResponseTime = 18.2; Service = "HTTPS" }
    )
    SMBConnectivity = @{ IsReachable = $true; SharesAccessible = $true }
    WMIConnectivity = @{ IsReachable = $true; OSInfo = @{ Caption = "Windows Server 2019" } }
    DNSResolution = "Success"
    Timestamp = "2024-01-15T10:30:00"
}
```

### SMBShareInfo (Get-SMBShares)
```powershell
[PSCustomObject]@{
    ComputerName = "file-server"
    ShareName = "Documents"
    ShareType = "Disk"
    Comment = "Shared Documents"
    Path = "C:\Shares\Documents"
    IsAccessible = $true
    AccessTest = "Anonymous access successful"
    Size = "1024 items"
    Timestamp = "2024-01-15T10:30:00"
}
```

## Performance Considerations

- **Concurrent Operations**: Use `MaxConcurrency` parameter to balance speed vs. resource usage
- **Network Timeouts**: Adjust `Timeout` values based on network conditions
- **Large Networks**: Consider scanning subnets separately for very large networks
- **Resource Usage**: Monitor memory usage when scanning thousands of hosts
- **Credentials**: Cache credentials when performing authenticated operations

## Troubleshooting

### Common Issues

1. **Access Denied Errors**
   - Run PowerShell as Administrator
   - Check Windows Firewall settings
   - Verify network connectivity

2. **Performance Issues**
   - Reduce `MaxConcurrency` value
   - Increase `Timeout` values
   - Scan smaller network ranges

3. **SMB Enumeration Failures**
   - Verify SMB ports (139, 445) are accessible
   - Check SMB protocol versions
   - Test with different credentials

### Debug Output
Enable verbose output for troubleshooting:
```powershell
Find-NetworkDevices -NetworkRange "192.168.1.0/24" -Verbose
```

## Requirements

- **PowerShell**: 5.1 or later (Windows PowerShell or PowerShell Core)
- **Operating System**: Windows 10/Server 2016 or later, Linux, macOS
- **Modules**: NetTCPIP (Windows only)
- **Permissions**: Administrative privileges recommended for comprehensive scanning
- **.NET Framework**: 4.7.2 or later (Windows PowerShell)

## License

This module is released under the MIT License. See LICENSE file for details.

## Contributing

Contributions are welcome! Please submit pull requests or issues through the project repository.

## Changelog

### v1.0.0 (2024-01-15)
- Initial release
- Basic network discovery functionality
- SMB share enumeration
- Connectivity testing features
- Cross-platform compatibility
- Performance optimizations with runspace pools
