<#
.SYNOPSIS
    Compare PowerShell Profile Startup Performance
.DESCRIPTION
    Benchmarks different Dracula profile modes to demonstrate the performance
    differences and validate ultra-performance targets.
.VERSION
    1.0.0
.AUTHOR
    Philip Procházka
#>

param(
    [int]$Iterations = 5,
    [switch]$Detailed,
    [switch]$ExportResults
)

# ===================================================================
# 📊 DRACULA PROFILE PERFORMANCE COMPARISON 📊
# Demonstrates the speed difference between profile modes
# ===================================================================

function Measure-ProfileStartup {
    param(
        [string]$ProfilePath,
        [string]$ProfileName,
        [int]$Iterations = 5
    )
    
    if (-not (Test-Path $ProfilePath)) {
        return @{
            Name    = $ProfileName
            Status  = "Missing"
            Times   = @()
            Average = 0
            Minimum = 0
            Maximum = 0
        }
    }
    
    Write-Host "🔬 Testing $ProfileName..." -ForegroundColor Cyan
    $times = @()
    
    for ($i = 1; $i -le $Iterations; $i++) {
        $start = Get-Date
        
        # Test profile loading in isolated PowerShell session
        try {
            $null = pwsh -NoProfile -Command ". '$ProfilePath'; exit" 2>$null
            $elapsed = ((Get-Date) - $start).TotalMilliseconds
            $times += $elapsed
            
            if ($Detailed) {
                Write-Host "  Run $i`: ${elapsed}ms" -ForegroundColor Gray
            }
        } catch {
            Write-Host "  Run $i`: Failed" -ForegroundColor Red
            $times += 9999 # High penalty for failed loads
        }
    }
    
    $avg = if ($times.Count -gt 0) {
        ($times | Measure-Object -Average).Average 
    } else {
        0 
    }
    $min = if ($times.Count -gt 0) {
        ($times | Measure-Object -Minimum).Minimum 
    } else {
        0 
    }
    $max = if ($times.Count -gt 0) {
        ($times | Measure-Object -Maximum).Maximum 
    } else {
        0 
    }
    
    return @{
        Name    = $ProfileName
        Status  = "OK"
        Times   = $times
        Average = $avg
        Minimum = $min
        Maximum = $max
    }
}

function Get-PerformanceRating {
    param([double]$AverageTime)
    
    if ($AverageTime -lt 50) {
        return @{ Rating = "🏆 ULTRA"; Color = "Green"; Description = "Sub-50ms - ULTRA-PERFORMANCE TARGET" }
    } elseif ($AverageTime -lt 100) {
        return @{ Rating = "⚡ FAST"; Color = "Yellow"; Description = "Good performance" }
    } elseif ($AverageTime -lt 300) {
        return @{ Rating = "🐌 SLOW"; Color = "Red"; Description = "Needs optimization" }
    } else {
        return @{ Rating = "🐌 VERY SLOW"; Color = "DarkRed"; Description = "Requires immediate optimization" }
    }
}

Write-Host "🧛‍♂️ Dracula Profile Performance Comparison" -ForegroundColor Magenta
Write-Host "===========================================" -ForegroundColor Gray
Write-Host ""

# Define profiles to test
$profilesToTest = @{
    "Ultra-Performance" = Join-Path $PSScriptRoot "Microsoft.PowerShell_profile_Dracula_UltraPerformance.ps1"
    "Performance"       = Join-Path $PSScriptRoot "Microsoft.PowerShell_profile_Dracula_Performance.ps1"
    "Minimal"           = Join-Path $PSScriptRoot "Microsoft.PowerShell_profile_Dracula_Minimal.ps1"
    "Normal"            = Join-Path $PSScriptRoot "Microsoft.PowerShell_profile_Dracula.ps1"
    "No Profile"        = $null  # Baseline measurement
}

$results = @()

# Test each profile
foreach ($profileEntry in $profilesToTest.GetEnumerator()) {
    $profileName = $profileEntry.Key
    $profilePath = $profileEntry.Value
    
    if ($profileName -eq "No Profile") {
        # Baseline measurement - no profile
        Write-Host "🔬 Testing No Profile (Baseline)..." -ForegroundColor Cyan
        $times = @()
        
        for ($i = 1; $i -le $Iterations; $i++) {
            $start = Get-Date
            $null = pwsh -NoProfile -Command "exit" 2>$null
            $elapsed = ((Get-Date) - $start).TotalMilliseconds
            $times += $elapsed
            
            if ($Detailed) {
                Write-Host "  Run $i`: ${elapsed}ms" -ForegroundColor Gray
            }
        }
        
        $avg = ($times | Measure-Object -Average).Average
        $min = ($times | Measure-Object -Minimum).Minimum
        $max = ($times | Measure-Object -Maximum).Maximum
        
        $result = @{
            Name    = $profileName
            Status  = "OK"
            Times   = $times
            Average = $avg
            Minimum = $min
            Maximum = $max
        }
    } else {
        $result = Measure-ProfileStartup -ProfilePath $profilePath -ProfileName $profileName -Iterations $Iterations
    }
    
    $results += $result
}

Write-Host ""
Write-Host "📊 PERFORMANCE RESULTS" -ForegroundColor Green
Write-Host "======================" -ForegroundColor Gray

# Sort results by average time
$sortedResults = $results | Sort-Object Average

foreach ($result in $sortedResults) {
    if ($result.Status -eq "Missing") {
        Write-Host "❌ $($result.Name): Profile not found" -ForegroundColor Red
        continue
    }
    
    $rating = Get-PerformanceRating -AverageTime $result.Average
    
    Write-Host ""
    Write-Host "$($rating.Rating) $($result.Name)" -ForegroundColor $rating.Color
    Write-Host "  Average: $([math]::Round($result.Average, 1))ms" -ForegroundColor White
    Write-Host "  Fastest: $([math]::Round($result.Minimum, 1))ms" -ForegroundColor Green
    Write-Host "  Slowest: $([math]::Round($result.Maximum, 1))ms" -ForegroundColor Red
    Write-Host "  $($rating.Description)" -ForegroundColor $rating.Color
}

# Performance analysis
Write-Host ""
Write-Host "🎯 PERFORMANCE ANALYSIS" -ForegroundColor Cyan
Write-Host "=======================" -ForegroundColor Gray

$ultraResult = $results | Where-Object { $_.Name -eq "Ultra-Performance" }
$baselineResult = $results | Where-Object { $_.Name -eq "No Profile" }
$normalResult = $results | Where-Object { $_.Name -eq "Normal" }

if ($ultraResult -and $ultraResult.Status -eq "OK") {
    $ultraRating = Get-PerformanceRating -AverageTime $ultraResult.Average
    
    Write-Host ""
    Write-Host "🧛‍♂️ Ultra-Performance Analysis:" -ForegroundColor Magenta
    
    if ($baselineResult -and $baselineResult.Status -eq "OK") {
        $overhead = $ultraResult.Average - $baselineResult.Average
        Write-Host "  Overhead vs No Profile: $([math]::Round($overhead, 1))ms" -ForegroundColor Yellow
    }
    
    if ($normalResult -and $normalResult.Status -eq "OK") {
        $speedup = $normalResult.Average / $ultraResult.Average
        $savings = $normalResult.Average - $ultraResult.Average
        Write-Host "  Speed improvement vs Normal: $([math]::Round($speedup, 1))x faster" -ForegroundColor Green
        Write-Host "  Time savings vs Normal: $([math]::Round($savings, 1))ms" -ForegroundColor Green
    }
    
    if ($ultraResult.Average -lt 50) {
        Write-Host "  🏆 ULTRA-PERFORMANCE TARGET ACHIEVED!" -ForegroundColor Green -BackgroundColor DarkGreen
        Write-Host "  ✅ True lazy loading working perfectly" -ForegroundColor Green
    } elseif ($ultraResult.Average -lt 100) {
        Write-Host "  ⚡ Good performance, but can be optimized further" -ForegroundColor Yellow
        Write-Host "  💡 Consider reducing initialization code" -ForegroundColor Yellow
    } else {
        Write-Host "  ❌ Ultra-Performance target missed" -ForegroundColor Red
        Write-Host "  💡 Review profile for blocking operations" -ForegroundColor Red
    }
}

# Recommendations
Write-Host ""
Write-Host "💡 RECOMMENDATIONS" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Gray

$fastestProfile = $sortedResults | Where-Object { $_.Status -eq "OK" } | Select-Object -First 1
if ($fastestProfile) {
    Write-Host "🏆 Fastest Profile: $($fastestProfile.Name) ($([math]::Round($fastestProfile.Average, 1))ms)" -ForegroundColor Green
    
    if ($fastestProfile.Name -eq "Ultra-Performance") {
        Write-Host ""
        Write-Host "✅ You're already using the optimal profile!" -ForegroundColor Green
        Write-Host "💡 To set as default for all sessions, run:" -ForegroundColor Cyan
        Write-Host "   .\Set-DraculaUltraPerformanceDefault.ps1" -ForegroundColor Gray
    } else {
        Write-Host ""
        Write-Host "💡 To switch to Ultra-Performance mode:" -ForegroundColor Cyan
        Write-Host "   .\Switch-DraculaMode.ps1 -Mode UltraPerformance" -ForegroundColor Gray
    }
}

# Export results if requested
if ($ExportResults) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $exportPath = "DraculaProfilePerformance_$timestamp.json"
    
    $exportData = @{
        Timestamp   = Get-Date
        Iterations  = $Iterations
        Results     = $results
        Environment = @{
            PSVersion = $PSVersionTable.PSVersion.ToString()
            OS        = $PSVersionTable.OS
            Platform  = $PSVersionTable.Platform
        }
    }
    
    $exportData | ConvertTo-Json -Depth 10 | Set-Content -Path $exportPath -Encoding UTF8
    Write-Host ""
    Write-Host "📄 Results exported to: $exportPath" -ForegroundColor Blue
}

Write-Host ""
Write-Host "🧛‍♂️ Performance comparison complete!" -ForegroundColor Magenta
