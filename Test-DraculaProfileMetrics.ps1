<#
.SYNOPSIS
    Comprehensive Performance and Debug Metrics for Dracula PowerShell Profile
.DESCRIPTION
    Measures profile loading performance, memory usage, module initialization times,
    and provides detailed debugging information for optimization.
.VERSION
    1.0.0
.AUTHOR
    Philip Procházka
.COPYRIGHT
    (c) 2025 PhilipProcházka. All rights reserved.
#>

[CmdletBinding()]
param(
    [ValidateSet('Performance', 'Normal', 'Minimal', 'Silent')]
    [string]$ProfileMode = 'Performance',
    
    [int]$Iterations = 5,
    
    [switch]$GenerateReport,
    
    [switch]$Detailed,
    
    [switch]$MemoryProfile,
    
    [switch]$ModuleProfile,
    
    [string]$OutputPath = (Join-Path $PSScriptRoot "Logs")
)

#region 🔧 Performance Measurement Classes
class ProfileMetrics {
    [datetime]$StartTime
    [datetime]$EndTime
    [double]$TotalLoadTime
    [double]$ThemeLoadTime
    [double]$ModuleLoadTime
    [double]$PSReadLineTime
    [double]$AliasTime
    [double]$FunctionTime
    [long]$MemoryBefore
    [long]$MemoryAfter
    [long]$MemoryDelta
    [hashtable]$ModuleTimes
    [string[]]$LoadedModules
    [string[]]$FailedModules
    [string]$ProfilePath
    [string]$Mode
    
    ProfileMetrics() {
        $this.ModuleTimes = @{}
        $this.LoadedModules = @()
        $this.FailedModules = @()
    }
    
    [void]StartMeasurement() {
        $this.StartTime = Get-Date
        $this.MemoryBefore = [System.GC]::GetTotalMemory($false)
    }
    
    [void]EndMeasurement() {
        $this.EndTime = Get-Date
        $this.MemoryAfter = [System.GC]::GetTotalMemory($false)
        $this.TotalLoadTime = ($this.EndTime - $this.StartTime).TotalMilliseconds
        $this.MemoryDelta = $this.MemoryAfter - $this.MemoryBefore
    }
}

class ModuleMetrics {
    [string]$Name
    [datetime]$StartTime
    [datetime]$EndTime
    [double]$LoadTime
    [bool]$Success
    [string]$ErrorMessage
    [long]$MemoryBefore
    [long]$MemoryAfter
    [long]$MemoryUsed
    
    [void]StartMeasurement() {
        $this.StartTime = Get-Date
        $this.MemoryBefore = [System.GC]::GetTotalMemory($false)
    }
    
    [void]EndMeasurement([bool]$Success, [string]$ErrorMessage = '') {
        $this.EndTime = Get-Date
        $this.MemoryAfter = [System.GC]::GetTotalMemory($false)
        $this.LoadTime = ($this.EndTime - $this.StartTime).TotalMilliseconds
        $this.MemoryUsed = $this.MemoryAfter - $this.MemoryBefore
        $this.Success = $Success
        $this.ErrorMessage = $ErrorMessage
    }
}
#endregion

#region 🎯 Profile Performance Testing
function Measure-ProfileLoadTime {
    [CmdletBinding()]
    param(
        [string]$ProfilePath,
        [string]$Mode,
        [switch]$Detailed
    )
    
    $metrics = [ProfileMetrics]::new()
    $metrics.ProfilePath = $ProfilePath
    $metrics.Mode = $Mode
    
    Write-Host "🔬 Measuring profile load time for: " -NoNewline -ForegroundColor Cyan
    Write-Host "$Mode mode" -ForegroundColor Yellow
    
    # Start measurement
    $metrics.StartMeasurement()
    
    # Create isolated PowerShell process for clean measurement
    $scriptBlock = {
        param($ProfilePath)
        
        $measureStart = Get-Date
        
        # Measure theme loading
        $themeStart = Get-Date
        try {
            $draculaTheme = Join-Path (Split-Path $ProfilePath) "Theme\dracula-enhanced.omp.json"
            if (Test-Path $draculaTheme -and (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
                oh-my-posh init pwsh --config $draculaTheme | Invoke-Expression
            }
        } catch { 
        }
        $themeTime = ((Get-Date) - $themeStart).TotalMilliseconds
        
        # Measure module loading
        $moduleStart = Get-Date
        $loadedModules = @()
        $failedModules = @()
        
        $modules = @('PSReadLine', 'Terminal-Icons', 'z', 'Az.Tools.Predictor', 'CompletionPredictor')
        foreach ($module in $modules) {
            try {
                Import-Module $module -ErrorAction Stop
                $loadedModules += $module
            } catch {
                $failedModules += $module
            }
        }
        $moduleTime = ((Get-Date) - $moduleStart).TotalMilliseconds
        
        # Measure PSReadLine configuration
        $psReadLineStart = Get-Date
        if (Get-Module PSReadLine) {
            Set-PSReadLineOption -EditMode Windows -BellStyle None
            Set-PSReadLineOption -PredictionSource History
        }
        $psReadLineTime = ((Get-Date) - $psReadLineStart).TotalMilliseconds
        
        $totalTime = ((Get-Date) - $measureStart).TotalMilliseconds
        
        return @{
            TotalTime      = $totalTime
            ThemeTime      = $themeTime
            ModuleTime     = $moduleTime
            PSReadLineTime = $psReadLineTime
            LoadedModules  = $loadedModules
            FailedModules  = $failedModules
        }
    }
    
    # Execute in separate process
    $result = powershell.exe -NoProfile -WindowStyle Hidden -Command $scriptBlock -ArgumentList $ProfilePath
    
    $metrics.EndMeasurement()
    
    if ($result) {
        $metrics.ThemeLoadTime = $result.ThemeTime
        $metrics.ModuleLoadTime = $result.ModuleTime
        $metrics.PSReadLineTime = $result.PSReadLineTime
        $metrics.LoadedModules = $result.LoadedModules
        $metrics.FailedModules = $result.FailedModules
    }
    
    return $metrics
}

function Test-ModuleLoadingPerformance {
    [CmdletBinding()]
    param([string[]]$Modules)
    
    $moduleMetrics = @()
    
    Write-Host "🧩 Testing individual module loading performance..." -ForegroundColor Cyan
    
    foreach ($moduleName in $Modules) {
        $metric = [ModuleMetrics]::new()
        $metric.Name = $moduleName
        
        Write-Host "  📦 Testing $moduleName..." -NoNewline -ForegroundColor Yellow
        
        $metric.StartMeasurement()
        
        try {
            # Test in isolated runspace
            $rs = [runspacefactory]::CreateRunspace()
            $rs.Open()
            $ps = [powershell]::Create()
            $ps.Runspace = $rs
            
            $null = $ps.AddScript("Import-Module $moduleName -ErrorAction Stop")
            $result = $ps.Invoke()
            
            if ($ps.HadErrors) {
                throw $ps.Streams.Error[0].Exception.Message
            }
            
            $metric.EndMeasurement($true)
            Write-Host " ✅ $([math]::Round($metric.LoadTime, 1))ms" -ForegroundColor Green
            
        } catch {
            $metric.EndMeasurement($false, $_.Exception.Message)
            Write-Host " ❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
        } finally {
            if ($ps) {
                $ps.Dispose() 
            }
            if ($rs) {
                $rs.Dispose() 
            }
        }
        
        $moduleMetrics += $metric
    }
    
    return $moduleMetrics
}

function Get-SystemPerformanceBaseline {
    [CmdletBinding()]
    param()
    
    Write-Host "📊 Gathering system performance baseline..." -ForegroundColor Cyan
    
    $baseline = @{
        PowerShellVersion = $PSVersionTable.PSVersion.ToString()
        OSVersion         = [System.Environment]::OSVersion.ToString()
        ProcessorCount    = [System.Environment]::ProcessorCount
        TotalMemory       = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)
        AvailableMemory   = [math]::Round((Get-Counter '\Memory\Available MBytes').CounterSamples[0].CookedValue / 1024, 2)
        PowerShellMemory  = [math]::Round([System.GC]::GetTotalMemory($false) / 1MB, 2)
        ModulesLoaded     = (Get-Module).Count
        PSVersion         = $PSVersionTable.PSVersion
        ExecutionPolicy   = Get-ExecutionPolicy
        ProfilePath       = $PROFILE
    }
    
    return $baseline
}
#endregion

#region 📊 Report Generation
function New-PerformanceReport {
    [CmdletBinding()]
    param(
        [ProfileMetrics[]]$Metrics,
        [ModuleMetrics[]]$ModuleMetrics,
        [hashtable]$Baseline,
        [string]$OutputPath
    )
    
    if (-not (Test-Path $OutputPath)) {
        New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $reportPath = Join-Path $OutputPath "DraculaProfile_Performance_$timestamp.html"
    
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Dracula Profile Performance Report</title>
    <style>
        body { font-family: 'Consolas', monospace; background: #282a36; color: #f8f8f2; margin: 20px; }
        .header { color: #bd93f9; font-size: 24px; margin-bottom: 20px; }
        .section { margin: 20px 0; padding: 15px; background: #44475a; border-radius: 8px; }
        .metric { margin: 10px 0; }
        .good { color: #50fa7b; }
        .warning { color: #ffb86c; }
        .error { color: #ff5555; }
        .info { color: #8be9fd; }
        table { width: 100%; border-collapse: collapse; margin: 15px 0; }
        th, td { padding: 8px; text-align: left; border-bottom: 1px solid #6272a4; }
        th { background: #6272a4; color: #f8f8f2; }
        .chart { margin: 20px 0; }
    </style>
</head>
<body>
    <div class="header">🧛‍♂️ Dracula Profile Performance Report</div>
    <div class="info">Generated: $(Get-Date)</div>
    
    <div class="section">
        <h2>📊 System Baseline</h2>
        <div class="metric">PowerShell Version: <span class="info">$($Baseline.PowerShellVersion)</span></div>
        <div class="metric">OS Version: <span class="info">$($Baseline.OSVersion)</span></div>
        <div class="metric">Processor Count: <span class="info">$($Baseline.ProcessorCount)</span></div>
        <div class="metric">Total Memory: <span class="info">$($Baseline.TotalMemory) GB</span></div>
        <div class="metric">Available Memory: <span class="info">$($Baseline.AvailableMemory) GB</span></div>
        <div class="metric">PowerShell Memory: <span class="info">$($Baseline.PowerShellMemory) MB</span></div>
    </div>
    
    <div class="section">
        <h2>⚡ Profile Loading Performance</h2>
        <table>
            <tr><th>Metric</th><th>Average</th><th>Min</th><th>Max</th><th>Status</th></tr>
"@

    # Calculate statistics
    $avgTotal = [math]::Round(($Metrics | Measure-Object TotalLoadTime -Average).Average, 1)
    $minTotal = [math]::Round(($Metrics | Measure-Object TotalLoadTime -Minimum).Minimum, 1)
    $maxTotal = [math]::Round(($Metrics | Measure-Object TotalLoadTime -Maximum).Maximum, 1)
    
    $avgTheme = [math]::Round(($Metrics | Measure-Object ThemeLoadTime -Average).Average, 1)
    $avgModule = [math]::Round(($Metrics | Measure-Object ModuleLoadTime -Average).Average, 1)
    $avgPSRL = [math]::Round(($Metrics | Measure-Object PSReadLineTime -Average).Average, 1)
    
    $totalStatus = if ($avgTotal -lt 500) {
        "good" 
    } elseif ($avgTotal -lt 1000) {
        "warning" 
    } else {
        "error" 
    }
    $themeStatus = if ($avgTheme -lt 100) {
        "good" 
    } elseif ($avgTheme -lt 200) {
        "warning" 
    } else {
        "error" 
    }
    $moduleStatus = if ($avgModule -lt 300) {
        "good" 
    } elseif ($avgModule -lt 600) {
        "warning" 
    } else {
        "error" 
    }
    
    $html += @"
            <tr><td>Total Load Time</td><td>${avgTotal}ms</td><td>${minTotal}ms</td><td>${maxTotal}ms</td><td class="$totalStatus">$(if($avgTotal -lt 500){"✅ Excellent"}elseif($avgTotal -lt 1000){"⚠️ Good"}else{"❌ Needs Optimization"})</td></tr>
            <tr><td>Theme Load Time</td><td>${avgTheme}ms</td><td>-</td><td>-</td><td class="$themeStatus">$(if($avgTheme -lt 100){"✅ Fast"}elseif($avgTheme -lt 200){"⚠️ Moderate"}else{"❌ Slow"})</td></tr>
            <tr><td>Module Load Time</td><td>${avgModule}ms</td><td>-</td><td>-</td><td class="$moduleStatus">$(if($avgModule -lt 300){"✅ Fast"}elseif($avgModule -lt 600){"⚠️ Moderate"}else{"❌ Slow"})</td></tr>
            <tr><td>PSReadLine Time</td><td>${avgPSRL}ms</td><td>-</td><td>-</td><td class="good">✅ Fast</td></tr>
        </table>
    </div>
"@

    # Module performance section
    if ($ModuleMetrics) {
        $html += @"
    <div class="section">
        <h2>🧩 Module Loading Performance</h2>
        <table>
            <tr><th>Module</th><th>Load Time</th><th>Memory Used</th><th>Status</th></tr>
"@
        foreach ($module in $ModuleMetrics) {
            $status = if ($module.Success) {
                "✅ Loaded" 
            } else {
                "❌ Failed" 
            }
            $statusClass = if ($module.Success) {
                "good" 
            } else {
                "error" 
            }
            $memoryMB = [math]::Round($module.MemoryUsed / 1MB, 2)
            
            $html += "<tr><td>$($module.Name)</td><td>$([math]::Round($module.LoadTime, 1))ms</td><td>${memoryMB} MB</td><td class='$statusClass'>$status</td></tr>"
        }
        $html += "</table></div>"
    }
    
    # Recommendations section
    $html += @"
    <div class="section">
        <h2>💡 Optimization Recommendations</h2>
"@
    
    $recommendations = @()
    
    if ($avgTotal -gt 1000) {
        $recommendations += "❌ <strong>Critical:</strong> Total load time exceeds 1 second. Consider lazy loading more modules."
    }
    if ($avgTheme -gt 200) {
        $recommendations += "⚠️ <strong>Theme:</strong> Oh My Posh theme loading is slow. Consider a simpler theme or caching."
    }
    if ($avgModule -gt 600) {
        $recommendations += "⚠️ <strong>Modules:</strong> Module loading is slow. Implement lazy loading for non-essential modules."
    }
    
    $failedModules = $ModuleMetrics | Where-Object { -not $_.Success }
    if ($failedModules) {
        $failedNames = ($failedModules | ForEach-Object { $_.Name }) -join ", "
        $recommendations += "❌ <strong>Failed Modules:</strong> $failedNames - Consider removing or fixing these modules."
    }
    
    if ($recommendations.Count -eq 0) {
        $recommendations += "✅ <strong>Excellent:</strong> Profile performance is optimal!"
    }
    
    foreach ($rec in $recommendations) {
        $html += "<div class='metric'>$rec</div>"
    }
    
    $html += @"
    </div>
    
    <div class="section">
        <h2>📈 Performance Trends</h2>
        <div class="metric">Test Iterations: $($Metrics.Count)</div>
        <div class="metric">Average Memory Usage: $([math]::Round(($Metrics | Measure-Object MemoryDelta -Average).Average / 1MB, 2)) MB</div>
        <div class="metric">Profile Mode: $($Metrics[0].Mode)</div>
    </div>
</body>
</html>
"@
    
    $html | Out-File -FilePath $reportPath -Encoding UTF8
    
    Write-Host "📊 Performance report generated: " -NoNewline -ForegroundColor Green
    Write-Host $reportPath -ForegroundColor Yellow
    
    return $reportPath
}

function Show-QuickMetrics {
    [CmdletBinding()]
    param([ProfileMetrics[]]$Metrics)
    
    Write-Host ""
    Write-Host "🧛‍♂️ DRACULA PROFILE PERFORMANCE METRICS" -ForegroundColor Magenta
    Write-Host "=======================================" -ForegroundColor Gray
    Write-Host ""
    
    $avg = ($Metrics | Measure-Object TotalLoadTime -Average).Average
    $min = ($Metrics | Measure-Object TotalLoadTime -Minimum).Minimum
    $max = ($Metrics | Measure-Object TotalLoadTime -Maximum).Maximum
    
    $color = if ($avg -lt 500) {
        'Green' 
    } elseif ($avg -lt 1000) {
        'Yellow' 
    } else {
        'Red' 
    }
    
    Write-Host "📊 Load Time Statistics ($($Metrics.Count) iterations):" -ForegroundColor Cyan
    Write-Host "   Average: " -NoNewline -ForegroundColor Gray
    Write-Host "$([math]::Round($avg, 1))ms" -ForegroundColor $color
    Write-Host "   Range: " -NoNewline -ForegroundColor Gray
    Write-Host "$([math]::Round($min, 1))ms - $([math]::Round($max, 1))ms" -ForegroundColor White
    
    Write-Host ""
    Write-Host "🎯 Performance Rating: " -NoNewline -ForegroundColor Cyan
    if ($avg -lt 500) {
        Write-Host "⚡ EXCELLENT" -ForegroundColor Green
    } elseif ($avg -lt 1000) {
        Write-Host "✅ GOOD" -ForegroundColor Yellow
    } else {
        Write-Host "⚠️ NEEDS OPTIMIZATION" -ForegroundColor Red
    }
    
    Write-Host ""
}
#endregion

#region 🚀 Main Execution
function Start-DraculaProfileAnalysis {
    [CmdletBinding()]
    param(
        [string]$ProfileMode,
        [int]$Iterations,
        [switch]$GenerateReport,
        [switch]$Detailed,
        [switch]$MemoryProfile,
        [switch]$ModuleProfile,
        [string]$OutputPath
    )
    
    Write-Host "🧛‍♂️ Starting Dracula Profile Performance Analysis..." -ForegroundColor Magenta
    Write-Host "Mode: $ProfileMode | Iterations: $Iterations" -ForegroundColor Gray
    Write-Host ""
    
    # Get system baseline
    $baseline = Get-SystemPerformanceBaseline
    
    # Determine profile path
    $profilePath = switch ($ProfileMode) {
        'Performance' {
            Join-Path $PSScriptRoot "Microsoft.PowerShell_profile_Dracula_Performance.ps1" 
        }
        'Normal' {
            Join-Path $PSScriptRoot "Microsoft.PowerShell_profile_Dracula.ps1" 
        }
        'Minimal' {
            Join-Path $PSScriptRoot "Microsoft.PowerShell_profile_Dracula_Minimal.ps1" 
        }
        'Silent' {
            Join-Path $PSScriptRoot "Microsoft.PowerShell_profile_Dracula_Silent.ps1" 
        }
    }
    
    if (-not (Test-Path $profilePath)) {
        Write-Error "Profile not found: $profilePath"
        return
    }
    
    # Run performance tests
    $metrics = @()
    
    for ($i = 1; $i -le $Iterations; $i++) {
        Write-Host "🔄 Running test $i of $Iterations..." -ForegroundColor Yellow
        $metric = Measure-ProfileLoadTime -ProfilePath $profilePath -Mode $ProfileMode -Detailed:$Detailed
        $metrics += $metric
        
        # Brief pause between tests
        Start-Sleep -Milliseconds 100
    }
    
    # Test module loading performance if requested
    $moduleMetrics = @()
    if ($ModuleProfile) {
        $modules = @('PSReadLine', 'Terminal-Icons', 'z', 'Az.Tools.Predictor', 'CompletionPredictor')
        $moduleMetrics = Test-ModuleLoadingPerformance -Modules $modules
    }
    
    # Show quick results
    Show-QuickMetrics -Metrics $metrics
    
    # Generate detailed report if requested
    if ($GenerateReport) {
        $reportPath = New-PerformanceReport -Metrics $metrics -ModuleMetrics $moduleMetrics -Baseline $baseline -OutputPath $OutputPath
        
        # Open report in browser
        if (Test-Path $reportPath) {
            Start-Process $reportPath
        }
    }
    
    # Return metrics for further analysis
    return @{
        Metrics       = $metrics
        ModuleMetrics = $moduleMetrics
        Baseline      = $baseline
        ProfilePath   = $profilePath
    }
}

# Execute if script is run directly
if ($MyInvocation.InvocationName -eq $MyInvocation.MyCommand.Name) {
    $result = Start-DraculaProfileAnalysis -ProfileMode $ProfileMode -Iterations $Iterations -GenerateReport:$GenerateReport -Detailed:$Detailed -MemoryProfile:$MemoryProfile -ModuleProfile:$ModuleProfile -OutputPath $OutputPath
    
    if ($result) {
        Write-Host ""
        Write-Host "✅ Analysis complete! " -NoNewline -ForegroundColor Green
        Write-Host "Results stored in `$result variable" -ForegroundColor Gray
    }
}
#endregion
