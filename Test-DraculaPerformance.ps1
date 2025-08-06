#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Benchmark Dracula profile performance across different modes
.DESCRIPTION
    Tests startup time and resource usage for different Dracula profile configurations.
.PARAMETER Iterations
    Number of test iterations per mode (default: 5)
.PARAMETER Detailed
    Show detailed timing breakdown
.EXAMPLE
    .\Test-DraculaPerformance.ps1
.EXAMPLE
    .\Test-DraculaPerformance.ps1 -Iterations 10 -Detailed
#>

[CmdletBinding()]
param(
    [Parameter()]
    [int]$Iterations = 5,
    
    [Parameter()]
    [switch]$Detailed
)

Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║           🧛‍♂️ DRACULA PROFILE PERFORMANCE TEST 🧛‍♂️         ║
║              Benchmark startup times and usage              ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Magenta

$profileModes = @('Normal', 'Performance', 'Silent', 'Minimal')
$results = @{}

Write-Host "`n🔬 Testing $Iterations iterations per mode..." -ForegroundColor Yellow

foreach ($mode in $profileModes) {
    Write-Host "`n📊 Testing $mode mode..." -ForegroundColor Cyan
    
    $profileFile = switch ($mode) {
        'Normal' {
            'Microsoft.PowerShell_profile_Dracula.ps1' 
        }
        'Performance' {
            'Microsoft.PowerShell_profile_Dracula_Performance.ps1' 
        }
        'Silent' {
            'Microsoft.PowerShell_profile_Dracula_Silent.ps1' 
        }
        'Minimal' {
            'Microsoft.PowerShell_profile_Dracula_Minimal.ps1' 
        }
    }
    
    $profilePath = Join-Path $PSScriptRoot $profileFile
    
    if (-not (Test-Path $profilePath)) {
        Write-Host "⚠️  Profile not found: $profileFile" -ForegroundColor Yellow
        continue
    }
    
    $times = @()
    $memoryUsage = @()
    
    for ($i = 1; $i -le $Iterations; $i++) {
        Write-Host "  Run $i/$Iterations..." -ForegroundColor Gray
        
        # Test script that loads the profile and measures time
        $testScript = @"
`$start = Get-Date
. '$profilePath'
`$end = Get-Date
`$duration = (`$end - `$start).TotalMilliseconds
Write-Output `$duration
"@
        
        try {
            # Run in separate PowerShell process to get clean measurement
            $result = powershell -NoLogo -NoProfile -Command $testScript 2>$null
            if ($result -and $result -match '^\d+\.?\d*$') {
                $times += [double]$result
                
                # Memory usage (approximation)
                $process = Get-Process -Name powershell | Where-Object { $_.StartTime -gt (Get-Date).AddSeconds(-5) } | Sort-Object StartTime -Descending | Select-Object -First 1
                if ($process) {
                    $memoryUsage += [math]::Round($process.WorkingSet64 / 1MB, 2)
                }
            }
        } catch {
            Write-Host "    ❌ Test failed: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        Start-Sleep -Milliseconds 500  # Cool down between tests
    }
    
    if ($times.Count -gt 0) {
        $results[$mode] = @{
            Times     = $times
            AvgTime   = [math]::Round(($times | Measure-Object -Average).Average, 2)
            MinTime   = [math]::Round(($times | Measure-Object -Minimum).Minimum, 2)
            MaxTime   = [math]::Round(($times | Measure-Object -Maximum).Maximum, 2)
            StdDev    = if ($times.Count -gt 1) { 
                [math]::Round([math]::Sqrt(($times | ForEach-Object { [math]::Pow($_ - ($times | Measure-Object -Average).Average, 2) } | Measure-Object -Sum).Sum / ($times.Count - 1)), 2)
            } else {
                0 
            }
            AvgMemory = if ($memoryUsage.Count -gt 0) {
                [math]::Round(($memoryUsage | Measure-Object -Average).Average, 2) 
            } else {
                0 
            }
        }
        
        Write-Host "  ✅ Average: $($results[$mode].AvgTime)ms" -ForegroundColor Green
    } else {
        Write-Host "  ❌ No valid results" -ForegroundColor Red
    }
}

# Display results summary
Write-Host "`n📈 PERFORMANCE RESULTS SUMMARY" -ForegroundColor Magenta
Write-Host "==============================" -ForegroundColor Gray

$table = foreach ($mode in $profileModes) {
    if ($results.ContainsKey($mode)) {
        $r = $results[$mode]
        [PSCustomObject]@{
            Mode            = $mode
            'Avg Time (ms)' = $r.AvgTime
            'Min (ms)'      = $r.MinTime
            'Max (ms)'      = $r.MaxTime
            'Std Dev'       = $r.StdDev
            'Memory (MB)'   = $r.AvgMemory
            'Improvement'   = if ($results.ContainsKey('Normal')) { 
                $improvement = (($results['Normal'].AvgTime - $r.AvgTime) / $results['Normal'].AvgTime) * 100
                if ($improvement -gt 0) {
                    "+$([math]::Round($improvement, 1))%" 
                } else {
                    "$([math]::Round($improvement, 1))%" 
                }
            } else {
                "N/A" 
            }
        }
    }
}

$table | Format-Table -AutoSize

# Recommendations
Write-Host "`n🎯 RECOMMENDATIONS" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Gray

if ($results.ContainsKey('Performance') -and $results.ContainsKey('Normal')) {
    $perfImprovement = (($results['Normal'].AvgTime - $results['Performance'].AvgTime) / $results['Normal'].AvgTime) * 100
    
    if ($perfImprovement -gt 20) {
        Write-Host "🚀 Performance mode offers significant improvement ($([math]::Round($perfImprovement, 1))%)" -ForegroundColor Green
        Write-Host "   Recommended for daily use" -ForegroundColor Yellow
    }
}

if ($results.ContainsKey('Silent')) {
    Write-Host "🤫 Silent mode for automation and scripts" -ForegroundColor Green
}

if ($results.ContainsKey('Minimal')) {
    Write-Host "⚡ Minimal mode for remote sessions and constrained environments" -ForegroundColor Green
}

Write-Host "`n💡 To switch modes, run:" -ForegroundColor Cyan
Write-Host "   .\Switch-DraculaMode.ps1 -Mode Performance" -ForegroundColor Yellow

if ($Detailed -and $results.Count -gt 0) {
    Write-Host "`n📊 DETAILED TIMING DATA" -ForegroundColor Magenta
    Write-Host "=======================" -ForegroundColor Gray
    
    foreach ($mode in $profileModes) {
        if ($results.ContainsKey($mode)) {
            Write-Host "`n$mode Mode Individual Times:" -ForegroundColor Cyan
            $results[$mode].Times | ForEach-Object { Write-Host "  $_ ms" -ForegroundColor Gray }
        }
    }
}
