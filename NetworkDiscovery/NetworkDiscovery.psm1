# ========================================
# NetworkDiscovery.psm1
# Network Discovery Module with Ping+SMB
# ========================================

#Requires -Version 5.1
#Requires -Modules @{ ModuleName="NetTCPIP"; ModuleVersion="1.0" }

# Import required .NET types
Add-Type -AssemblyName System.Net.NetworkInformation
Add-Type -AssemblyName System.DirectoryServices

# Module variables
$script:DefaultPorts = @(21, 22, 23, 25, 53, 80, 110, 135, 139, 143, 443, 445, 993, 995, 1433, 3389, 5985, 5986)
$script:NetworkCache = @{}
$script:ScanResults = @{}

<#
.SYNOPSIS
Discovers devices on the local network using ping and port scanning.

.DESCRIPTION
Performs comprehensive network discovery combining ICMP ping, TCP port scanning,
and SMB enumeration to identify active devices and services.

.PARAMETER NetworkRange
Network range to scan (e.g., "192.168.1.0/24")

.PARAMETER CustomPorts
Array of custom ports to scan in addition to defaults

.PARAMETER EnableSMBScan
Enable SMB/CIFS enumeration for discovered Windows devices

.PARAMETER Timeout
Timeout in milliseconds for network operations (default: 1000)

.PARAMETER MaxConcurrency
Maximum concurrent ping/scan operations (default: 50)

.PARAMETER IncludeOffline
Include offline/unreachable devices in results

.EXAMPLE
Find-NetworkDevices -NetworkRange "192.168.1.0/24" -EnableSMBScan

.EXAMPLE
Find-NetworkDevices -NetworkRange "10.0.0.0/16" -CustomPorts @(8080, 9090) -MaxConcurrency 100
#>
function Find-NetworkDevices {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Mandatory)]
        [ValidatePattern('^(\d{1,3}\.){3}\d{1,3}/\d{1,2}$')]
        [string]$NetworkRange,
        
        [int[]]$CustomPorts = @(),
        
        [switch]$EnableSMBScan,
        
        [ValidateRange(100, 10000)]
        [int]$Timeout = 1000,
        
        [ValidateRange(1, 200)]
        [int]$MaxConcurrency = 50,
        
        [switch]$IncludeOffline
    )
    
    Write-Host "🌐 Starting network discovery for $NetworkRange..." -ForegroundColor Cyan
    
    try {
        # Parse network range
        $Network = Get-NetworkRange -CIDR $NetworkRange
        Write-Host "📡 Scanning $($Network.IPAddresses.Count) IP addresses..." -ForegroundColor Yellow
        
        # Combine default and custom ports
        $AllPorts = $script:DefaultPorts + $CustomPorts | Sort-Object -Unique
        
        # Initialize progress tracking
        $TotalHosts = $Network.IPAddresses.Count
        $CompletedHosts = 0
        $DiscoveredDevices = @()
        
        # Create runspace pool for concurrent operations
        $RunspacePool = [runspacefactory]::CreateRunspacePool(1, $MaxConcurrency)
        $RunspacePool.Open()
        
        # Create jobs for ping scanning
        $PingJobs = @()
        foreach ($IP in $Network.IPAddresses) {
            $PowerShell = [powershell]::Create()
            $PowerShell.RunspacePool = $RunspacePool
            
            $ScriptBlock = {
                param($IPAddress, $Timeout, $Ports, $EnableSMB)
                
                $Result = [PSCustomObject]@{
                    IPAddress    = $IPAddress
                    Hostname     = $null
                    IsOnline     = $false
                    ResponseTime = $null
                    OpenPorts    = @()
                    SMBInfo      = $null
                    Services     = @()
                    LastSeen     = Get-Date
                    DeviceType   = "Unknown"
                }
                
                try {
                    # ICMP Ping test
                    $Ping = New-Object System.Net.NetworkInformation.Ping
                    $PingReply = $Ping.Send($IPAddress, $Timeout)
                    
                    if ($PingReply.Status -eq 'Success') {
                        $Result.IsOnline = $true
                        $Result.ResponseTime = $PingReply.RoundtripTime
                        
                        # Reverse DNS lookup
                        try {
                            $HostEntry = [System.Net.Dns]::GetHostEntry($IPAddress)
                            $Result.Hostname = $HostEntry.HostName
                        }
                        catch {
                            # DNS lookup failed, continue without hostname
                        }
                        
                        # Port scanning
                        $OpenPorts = @()
                        foreach ($Port in $Ports) {
                            try {
                                $TcpClient = New-Object System.Net.Sockets.TcpClient
                                $Connection = $TcpClient.BeginConnect($IPAddress, $Port, $null, $null)
                                $Wait = $Connection.AsyncWaitHandle.WaitOne(500, $false)
                                
                                if ($Wait -and $TcpClient.Connected) {
                                    $OpenPorts += $Port
                                    
                                    # Identify common services
                                    $ServiceName = switch ($Port) {
                                        21 { "FTP" }
                                        22 { "SSH" }
                                        23 { "Telnet" }
                                        25 { "SMTP" }
                                        53 { "DNS" }
                                        80 { "HTTP" }
                                        110 { "POP3" }
                                        135 { "RPC" }
                                        139 { "NetBIOS" }
                                        143 { "IMAP" }
                                        443 { "HTTPS" }
                                        445 { "SMB/CIFS" }
                                        993 { "IMAPS" }
                                        995 { "POP3S" }
                                        1433 { "SQL Server" }
                                        3389 { "RDP" }
                                        5985 { "WinRM HTTP" }
                                        5986 { "WinRM HTTPS" }
                                        default { "Unknown" }
                                    }
                                    
                                    $Result.Services += [PSCustomObject]@{
                                        Port    = $Port
                                        Service = $ServiceName
                                        State   = "Open"
                                    }
                                }
                                
                                $TcpClient.Close()
                            }
                            catch {
                                # Port scan failed, continue
                            }
                        }
                        
                        $Result.OpenPorts = $OpenPorts
                        
                        # Device type detection
                        if (445 -in $OpenPorts -or 139 -in $OpenPorts) {
                            $Result.DeviceType = "Windows/SMB"
                        }
                        elseif (22 -in $OpenPorts) {
                            $Result.DeviceType = "Linux/Unix"
                        }
                        elseif (80 -in $OpenPorts -or 443 -in $OpenPorts) {
                            $Result.DeviceType = "Web Server"
                        }
                        elseif (3389 -in $OpenPorts) {
                            $Result.DeviceType = "Windows RDP"
                        }
                        
                        # SMB enumeration if enabled and SMB port is open
                        if ($EnableSMB -and (445 -in $OpenPorts -or 139 -in $OpenPorts)) {
                            try {
                                $SMBInfo = Get-SMBInformation -IPAddress $IPAddress
                                $Result.SMBInfo = $SMBInfo
                            }
                            catch {
                                # SMB enumeration failed
                            }
                        }
                    }
                }
                catch {
                    # Ping failed, device is offline or unreachable
                }
                
                return $Result
            }
            
            $null = $PowerShell.AddScript($ScriptBlock).AddArgument($IP).AddArgument($Timeout).AddArgument($AllPorts).AddArgument($EnableSMBScan.IsPresent)
            $PingJobs += [PSCustomObject]@{
                PowerShell = $PowerShell
                Handle     = $PowerShell.BeginInvoke()
                IPAddress  = $IP
            }
        }
        
        # Collect results
        Write-Host "⏳ Waiting for scan completion..." -ForegroundColor Yellow
        
        foreach ($Job in $PingJobs) {
            try {
                $Result = $Job.PowerShell.EndInvoke($Job.Handle)
                
                if ($Result.IsOnline -or $IncludeOffline) {
                    $DiscoveredDevices += $Result
                }
                
                $CompletedHosts++
                $PercentComplete = [math]::Round(($CompletedHosts / $TotalHosts) * 100, 1)
                Write-Progress -Activity "Network Discovery" -Status "Scanning $($Job.IPAddress)" -PercentComplete $PercentComplete
                
            }
            catch {
                Write-Warning "Failed to process results for $($Job.IPAddress): $($_.Exception.Message)"
            }
            finally {
                $Job.PowerShell.Dispose()
            }
        }
        
        Write-Progress -Activity "Network Discovery" -Completed
        $RunspacePool.Close()
        $RunspacePool.Dispose()
        
        # Cache results
        $script:ScanResults[$NetworkRange] = @{
            Timestamp = Get-Date
            Results   = $DiscoveredDevices
        }
        
        Write-Host "✅ Discovery complete! Found $($DiscoveredDevices.Count) devices" -ForegroundColor Green
        
        return $DiscoveredDevices | Sort-Object { [System.Net.IPAddress]::Parse($_.IPAddress).Address }
        
    }
    catch {
        Write-Error "❌ Network discovery failed: $($_.Exception.Message)"
        throw
    }
}

<#
.SYNOPSIS
Tests connectivity to a specific host using various methods.

.DESCRIPTION
Performs comprehensive connectivity testing including ICMP ping, TCP port tests,
and optional SMB/WMI tests for detailed host analysis.

.PARAMETER ComputerName
Target computer name or IP address

.PARAMETER Ports
Array of ports to test (defaults to common ports)

.PARAMETER EnableSMBTest
Enable SMB connectivity and enumeration tests

.PARAMETER EnableWMITest
Enable WMI connectivity tests

.PARAMETER Timeout
Timeout in milliseconds for network operations

.EXAMPLE
Test-NetworkConnectivity -ComputerName "192.168.1.100" -Ports @(80, 443, 22)

.EXAMPLE
Test-NetworkConnectivity -ComputerName "server01" -EnableSMBTest -EnableWMITest
#>
function Test-NetworkConnectivity {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$ComputerName,
        
        [int[]]$Ports = @(80, 443, 22, 135, 139, 445, 3389, 5985),
        
        [switch]$EnableSMBTest,
        
        [switch]$EnableWMITest,
        
        [ValidateRange(100, 10000)]
        [int]$Timeout = 3000
    )
    
    begin {
        Write-Host "🔍 Testing connectivity to targets..." -ForegroundColor Cyan
    }
    
    process {
        Write-Host "📡 Testing: $ComputerName" -ForegroundColor Yellow
        
        $ConnectivityResult = [PSCustomObject]@{
            ComputerName     = $ComputerName
            IPAddress        = $null
            IsOnline         = $false
            PingResponseTime = $null
            PortTests        = @()
            SMBConnectivity  = $null
            WMIConnectivity  = $null
            DNSResolution    = $null
            Timestamp        = Get-Date
        }
        
        try {
            # DNS Resolution
            try {
                $IPAddress = [System.Net.Dns]::GetHostAddresses($ComputerName)[0].IPAddressToString
                $ConnectivityResult.IPAddress = $IPAddress
                $ConnectivityResult.DNSResolution = "Success"
                Write-Host "  ✅ DNS Resolution: $IPAddress" -ForegroundColor Green
            }
            catch {
                $ConnectivityResult.DNSResolution = "Failed: $($_.Exception.Message)"
                Write-Host "  ❌ DNS Resolution failed" -ForegroundColor Red
                return $ConnectivityResult
            }
            
            # ICMP Ping Test
            try {
                $Ping = New-Object System.Net.NetworkInformation.Ping
                $PingReply = $Ping.Send($ComputerName, $Timeout)
                
                if ($PingReply.Status -eq 'Success') {
                    $ConnectivityResult.IsOnline = $true
                    $ConnectivityResult.PingResponseTime = $PingReply.RoundtripTime
                    Write-Host "  ✅ Ping: $($PingReply.RoundtripTime)ms" -ForegroundColor Green
                }
                else {
                    Write-Host "  ❌ Ping failed: $($PingReply.Status)" -ForegroundColor Red
                }
            }
            catch {
                Write-Host "  ❌ Ping error: $($_.Exception.Message)" -ForegroundColor Red
            }
            
            # Port Tests
            foreach ($Port in $Ports) {
                $PortResult = [PSCustomObject]@{
                    Port         = $Port
                    Status       = "Closed"
                    ResponseTime = $null
                    Service      = $null
                }
                
                try {
                    $StartTime = Get-Date
                    $TcpClient = New-Object System.Net.Sockets.TcpClient
                    $Connection = $TcpClient.BeginConnect($ConnectivityResult.IPAddress, $Port, $null, $null)
                    $Wait = $Connection.AsyncWaitHandle.WaitOne($Timeout, $false)
                    
                    if ($Wait -and $TcpClient.Connected) {
                        $EndTime = Get-Date
                        $PortResult.Status = "Open"
                        $PortResult.ResponseTime = ($EndTime - $StartTime).TotalMilliseconds
                        
                        # Identify service
                        $PortResult.Service = switch ($Port) {
                            80 { "HTTP" }
                            443 { "HTTPS" }
                            22 { "SSH" }
                            135 { "RPC" }
                            139 { "NetBIOS" }
                            445 { "SMB/CIFS" }
                            3389 { "RDP" }
                            5985 { "WinRM HTTP" }
                            5986 { "WinRM HTTPS" }
                            default { "Unknown" }
                        }
                        
                        Write-Host "  ✅ Port $Port ($($PortResult.Service)): Open" -ForegroundColor Green
                    }
                    else {
                        Write-Host "  ❌ Port $Port : Closed" -ForegroundColor Red
                    }
                    
                    $TcpClient.Close()
                }
                catch {
                    Write-Host "  ❌ Port $Port error: $($_.Exception.Message)" -ForegroundColor Red
                }
                
                $ConnectivityResult.PortTests += $PortResult
            }
            
            # SMB Connectivity Test
            if ($EnableSMBTest) {
                try {
                    $SMBResult = Test-SMBConnectivity -ComputerName $ComputerName
                    $ConnectivityResult.SMBConnectivity = $SMBResult
                    Write-Host "  ✅ SMB Test completed" -ForegroundColor Green
                }
                catch {
                    $ConnectivityResult.SMBConnectivity = "Failed: $($_.Exception.Message)"
                    Write-Host "  ❌ SMB Test failed" -ForegroundColor Red
                }
            }
            
            # WMI Connectivity Test
            if ($EnableWMITest) {
                try {
                    $WMIResult = Test-WMIConnectivity -ComputerName $ComputerName
                    $ConnectivityResult.WMIConnectivity = $WMIResult
                    Write-Host "  ✅ WMI Test completed" -ForegroundColor Green
                }
                catch {
                    $ConnectivityResult.WMIConnectivity = "Failed: $($_.Exception.Message)"
                    Write-Host "  ❌ WMI Test failed" -ForegroundColor Red
                }
            }
            
        }
        catch {
            Write-Error "❌ Connectivity test failed for $ComputerName : $($_.Exception.Message)"
        }
        
        return $ConnectivityResult
    }
    
    end {
        Write-Host "✅ Connectivity testing completed" -ForegroundColor Green
    }
}

<#
.SYNOPSIS
Scans for SMB shares on discovered devices.

.DESCRIPTION
Enumerates SMB/CIFS shares on Windows devices and attempts to gather
share information including permissions and accessibility.

.PARAMETER ComputerName
Target computer name or IP address

.PARAMETER Credential
Optional credential for authenticated scanning

.PARAMETER IncludeHidden
Include hidden administrative shares (C$, ADMIN$, etc.)

.EXAMPLE
Get-SMBShares -ComputerName "192.168.1.100"

.EXAMPLE
Get-SMBShares -ComputerName "server01" -Credential $Creds -IncludeHidden
#>
function Get-SMBShares {
    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$ComputerName,
        
        [System.Management.Automation.PSCredential]$Credential,
        
        [switch]$IncludeHidden
    )
    
    begin {
        Write-Host "📂 Scanning for SMB shares..." -ForegroundColor Cyan
    }
    
    process {
        Write-Host "🔍 Enumerating shares on: $ComputerName" -ForegroundColor Yellow
        
        $ShareResults = @()
        
        try {
            # Test SMB connectivity first
            if (-not (Test-NetConnection -ComputerName $ComputerName -Port 445 -InformationLevel Quiet)) {
                Write-Warning "SMB port 445 not accessible on $ComputerName"
                return $ShareResults
            }
            
            # Use different methods based on credential availability
            if ($Credential) {
                # Authenticated enumeration
                try {
                    $Shares = Get-SmbShare -CimSession (New-CimSession -ComputerName $ComputerName -Credential $Credential)
                }
                catch {
                    Write-Warning "Authenticated SMB enumeration failed: $($_.Exception.Message)"
                    return $ShareResults
                }
            }
            else {
                # Anonymous/guest enumeration using net view
                try {
                    $NetViewOutput = & net view "\\$ComputerName" 2>&1
                    
                    if ($LASTEXITCODE -eq 0) {
                        $Shares = @()
                        foreach ($Line in $NetViewOutput) {
                            if ($Line -match '^(\S+)\s+(\S+)\s+(.*)$') {
                                $ShareName = $matches[1]
                                $ShareType = $matches[2]
                                $Comment = $matches[3]
                                
                                # Skip system shares unless requested
                                if (-not $IncludeHidden -and $ShareName -match '\$$') {
                                    continue
                                }
                                
                                $Shares += [PSCustomObject]@{
                                    Name      = $ShareName
                                    ShareType = $ShareType
                                    Comment   = $Comment
                                    Path      = $null
                                }
                            }
                        }
                    }
                    else {
                        Write-Warning "Net view failed for $ComputerName"
                        return $ShareResults
                    }
                }
                catch {
                    Write-Warning "Anonymous SMB enumeration failed: $($_.Exception.Message)"
                    return $ShareResults
                }
            }
            
            # Process discovered shares
            foreach ($Share in $Shares) {
                $ShareInfo = [PSCustomObject]@{
                    ComputerName = $ComputerName
                    ShareName    = $Share.Name
                    ShareType    = if ($Share.ShareType) { $Share.ShareType } else { "Unknown" }
                    Comment      = if ($Share.Comment) { $Share.Comment } else { "" }
                    Path         = if ($Share.Path) { $Share.Path } else { $null }
                    IsAccessible = $false
                    AccessTest   = $null
                    Size         = $null
                    Timestamp    = Get-Date
                }
                
                # Test accessibility
                try {
                    $UNCPath = "\\$ComputerName\$($Share.Name)"
                    
                    if ($Credential) {
                        # Use New-PSDrive for authenticated access test
                        $TempDrive = New-PSDrive -Name "TempSMBTest" -PSProvider FileSystem -Root $UNCPath -Credential $Credential -ErrorAction Stop
                        $ShareInfo.IsAccessible = $true
                        $ShareInfo.AccessTest = "Authenticated access successful"
                        Remove-PSDrive -Name "TempSMBTest" -Force
                    }
                    else {
                        # Test anonymous/guest access
                        if (Test-Path $UNCPath -ErrorAction SilentlyContinue) {
                            $ShareInfo.IsAccessible = $true
                            $ShareInfo.AccessTest = "Anonymous/guest access successful"
                            
                            # Try to get directory info for size estimation
                            try {
                                $DirInfo = Get-ChildItem $UNCPath -ErrorAction SilentlyContinue | Measure-Object
                                $ShareInfo.Size = "$($DirInfo.Count) items"
                            }
                            catch {
                                # Size enumeration failed
                            }
                        }
                        else {
                            $ShareInfo.AccessTest = "Access denied or authentication required"
                        }
                    }
                }
                catch {
                    $ShareInfo.AccessTest = "Failed: $($_.Exception.Message)"
                }
                
                $ShareResults += $ShareInfo
                
                $AccessSymbol = if ($ShareInfo.IsAccessible) { "✅" } else { "❌" }
                Write-Host "  $AccessSymbol $($Share.Name) ($($ShareInfo.ShareType)) - $($ShareInfo.AccessTest)" -ForegroundColor $(if ($ShareInfo.IsAccessible) { "Green" } else { "Red" })
            }
            
        }
        catch {
            Write-Error "❌ SMB enumeration failed for $ComputerName : $($_.Exception.Message)"
        }
        
        return $ShareResults
    }
    
    end {
        Write-Host "✅ SMB share scanning completed" -ForegroundColor Green
    }
}

# Helper functions
function Get-NetworkRange {
    param([string]$CIDR)
    
    $Network, $MaskBits = $CIDR -split '/'
    $MaskBits = [int]$MaskBits
    
    $NetworkBytes = [System.Net.IPAddress]::Parse($Network).GetAddressBytes()
    $Mask = [uint32]((0xFFFFFFFF) -shl (32 - $MaskBits))
    
    $NetworkAddress = [System.BitConverter]::ToUInt32($NetworkBytes, 0) -band $Mask
    $BroadcastAddress = $NetworkAddress -bor (0xFFFFFFFF -shr $MaskBits)
    
    $IPAddresses = @()
    for ($i = $NetworkAddress + 1; $i -lt $BroadcastAddress; $i++) {
        $Bytes = [System.BitConverter]::GetBytes($i)
        $IPAddresses += "$($Bytes[0]).$($Bytes[1]).$($Bytes[2]).$($Bytes[3])"
    }
    
    return @{
        Network     = $Network
        MaskBits    = $MaskBits
        IPAddresses = $IPAddresses
    }
}

function Get-SMBInformation {
    param([string]$IPAddress)
    
    try {
        $SMBInfo = @{
            NetBIOSName = $null
            Domain      = $null
            OSVersion   = $null
            Shares      = @()
        }
        
        # NetBIOS name resolution
        try {
            $HostEntry = [System.Net.Dns]::GetHostEntry($IPAddress)
            $SMBInfo.NetBIOSName = $HostEntry.HostName.Split('.')[0]
        }
        catch {
            # NetBIOS resolution failed
        }
        
        return $SMBInfo
    }
    catch {
        return $null
    }
}

function Test-SMBConnectivity {
    param([string]$ComputerName)
    
    $Result = @{
        IsReachable      = $false
        SupportsNTLM     = $false
        SupportsKerberos = $false
        SharesAccessible = $false
        ErrorMessage     = $null
    }
    
    try {
        # Test basic SMB connectivity
        if (Test-NetConnection -ComputerName $ComputerName -Port 445 -InformationLevel Quiet) {
            $Result.IsReachable = $true
            
            # Test share enumeration
            try {
                $NetViewOutput = & net view "\\$ComputerName" 2>&1
                if ($LASTEXITCODE -eq 0) {
                    $Result.SharesAccessible = $true
                }
            }
            catch {
                $Result.ErrorMessage = $_.Exception.Message
            }
        }
    }
    catch {
        $Result.ErrorMessage = $_.Exception.Message
    }
    
    return $Result
}

function Test-WMIConnectivity {
    param([string]$ComputerName)
    
    $Result = @{
        IsReachable  = $false
        OSInfo       = $null
        ErrorMessage = $null
    }
    
    try {
        $OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName -ErrorAction Stop
        $Result.IsReachable = $true
        $Result.OSInfo = @{
            Caption      = $OS.Caption
            Version      = $OS.Version
            Architecture = $OS.OSArchitecture
        }
    }
    catch {
        $Result.ErrorMessage = $_.Exception.Message
    }
    
    return $Result
}

# Export module members
Export-ModuleMember -Function @(
    'Find-NetworkDevices',
    'Test-NetworkConnectivity', 
    'Get-SMBShares'
)
