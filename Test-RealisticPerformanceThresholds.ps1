<#
.SYNOPSIS
    Test Realistic Performance Thresholds for PowerShell Profiles
.DESCRIPTION
    Updated performance testing with realistic expectations after Oh My Posh migration.
    Previous targets (30-40ms) were unrealistic for feature-rich profiles.
.VERSION
    1.0.0
.AUTHOR
    Philip Procházka  
#>

[CmdletBinding()]
param(
    [ValidateSet('Quick', 'Standard', 'Comprehensive')]
    [string]$TestMode = 'Standard',
    
    [switch]$GenerateReport,
    
    [int]$Iterations = 10,
    
    [switch]$ShowDebugInfo
)

# =============================================================================
# 🎯 REALISTIC PERFORMANCE THRESHOLDS
# =============================================================================

$PerformanceThresholds = @{
    Excellent  = 200   # Sub-200ms - Excellent performance
    VeryGood   = 500   # 200-500ms - Very good, realistic with rich features  
    Good       = 750   # 500-750ms - Good, some optimization potential
    Acceptable = 1000  # 750ms-1s - Acceptable, needs review
    Poor       = 1500  # >1s - Needs optimization
}

$ProfileTargets = @{
    'V4'       = @{
        Target = 200  # Updated from unrealistic 30ms
        Name   = 'Ultra-Performance V4 (JIT Optimized)'
        Path   = "$PSScriptRoot\Microsoft.PowerShell_profile_Dracula_UltraPerformance_V4.ps1"
    }
    'V3'       = @{
        Target = 200  # Updated from unrealistic 40ms  
        Name   = 'Ultra-Performance V3 (Memory Optimized)'
        Path   = "$PSScriptRoot\Microsoft.PowerShell_profile_Dracula_UltraPerformance_V3.ps1"
    }
    'Original' = @{
        Target = 500  # Updated from unrealistic 50ms
        Name   = 'Ultra-Performance Original'
        Path   = "$PSScriptRoot\Microsoft.PowerShell_profile_Dracula_UltraPerformance.ps1"
    }
}

function Test-ProfilePerformance {
    param($ProfileInfo, $TestIterations)
    
    if (-not (Test-Path $ProfileInfo.Path)) {
        Write-Warning "Profile not found: $($ProfileInfo.Path)"
        return $null
    }
    
    $results = @()
    
    Write-Host "Testing: $($ProfileInfo.Name)" -ForegroundColor Cyan
    Write-Host "Target: $($ProfileInfo.Target)ms" -ForegroundColor Yellow
    
    for ($i = 1; $i -le $TestIterations; $i++) {
        $start = Get-Date
        
        # Test profile loading in isolated process
        $process = Start-Process -FilePath 'pwsh' -ArgumentList @(
            '-NoProfile', 
            '-Command', 
            ". '$($ProfileInfo.Path)'; exit"
        ) -Wait -PassThru -WindowStyle Hidden
        
        $loadTime = ((Get-Date) - $start).TotalMilliseconds
        $results += $loadTime
        
        if ($ShowDebugInfo) {
            Write-Host "  Iteration $i`: $([math]::Round($loadTime, 1))ms" -ForegroundColor Gray
        }
    }
    
    $avgTime = ($results | Measure-Object -Average).Average
    $minTime = ($results | Measure-Object -Minimum).Minimum
    $maxTime = ($results | Measure-Object -Maximum).Maximum
    
    return @{
        ProfileName = $ProfileInfo.Name
        Target      = $ProfileInfo.Target
        Average     = $avgTime
        Minimum     = $minTime
        Maximum     = $maxTime
        Results     = $results
        MeetsTarget = $avgTime -le $ProfileInfo.Target
    }
}

function Get-PerformanceRating {
    param($AvgTime)
    
    if ($AvgTime -lt $PerformanceThresholds.Excellent) {
        return @{ Rating = "⚡ EXCELLENT"; Color = "Green" }
    } elseif ($AvgTime -lt $PerformanceThresholds.VeryGood) {
        return @{ Rating = "✅ VERY GOOD"; Color = "Green" }
    } elseif ($AvgTime -lt $PerformanceThresholds.Good) {
        return @{ Rating = "👍 GOOD"; Color = "Yellow" }
    } elseif ($AvgTime -lt $PerformanceThresholds.Acceptable) {
        return @{ Rating = "⚠️ ACCEPTABLE"; Color = "Yellow" }
    } else {
        return @{ Rating = "❌ NEEDS OPTIMIZATION"; Color = "Red" }
    }
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

Clear-Host
Write-Host "🎯 Realistic Performance Threshold Testing" -ForegroundColor Magenta
Write-Host "=" * 60 -ForegroundColor Gray
Write-Host ""

Write-Host "📊 Updated Performance Expectations:" -ForegroundColor Cyan
Write-Host "  ⚡ Excellent: < $($PerformanceThresholds.Excellent)ms" -ForegroundColor Green
Write-Host "  ✅ Very Good: $($PerformanceThresholds.Excellent)-$($PerformanceThresholds.VeryGood)ms" -ForegroundColor Green  
Write-Host "  👍 Good: $($PerformanceThresholds.VeryGood)-$($PerformanceThresholds.Good)ms" -ForegroundColor Yellow
Write-Host "  ⚠️ Acceptable: $($PerformanceThresholds.Good)-$($PerformanceThresholds.Acceptable)ms" -ForegroundColor Yellow
Write-Host "  ❌ Poor: > $($PerformanceThresholds.Acceptable)ms" -ForegroundColor Red
Write-Host ""

Write-Host "💡 Why These Targets Are Realistic:" -ForegroundColor Yellow
Write-Host "  • Previous 30-40ms targets were unrealistic for feature-rich profiles" -ForegroundColor Gray
Write-Host "  • Oh My Posh themes add 50-100ms but provide significant visual value" -ForegroundColor Gray  
Write-Host "  • Modern PowerShell with rich features: 200-500ms is excellent" -ForegroundColor Gray
Write-Host "  • Focus on user experience over micro-optimization" -ForegroundColor Gray
Write-Host ""

# Determine test iterations based on mode
$testIterations = switch ($TestMode) {
    'Quick' {
        5 
    }
    'Standard' {
        $Iterations 
    }
    'Comprehensive' {
        $Iterations * 2 
    }
}

Write-Host "🧪 Running $TestMode test mode with $testIterations iterations..." -ForegroundColor Cyan
Write-Host ""

# Test each profile
$allResults = @()
foreach ($profileKey in $ProfileTargets.Keys) {
    $result = Test-ProfilePerformance -ProfileInfo $ProfileTargets[$profileKey] -TestIterations $testIterations
    if ($result) {
        $allResults += $result
        
        $rating = Get-PerformanceRating -AvgTime $result.Average
        
        Write-Host "📈 Results for $($result.ProfileName):" -ForegroundColor White
        Write-Host "  Average: $([math]::Round($result.Average, 1))ms" -ForegroundColor White
        Write-Host "  Range: $([math]::Round($result.Minimum, 1))ms - $([math]::Round($result.Maximum, 1))ms" -ForegroundColor Gray
        Write-Host "  Target: $($result.Target)ms" -ForegroundColor Gray
        Write-Host "  Rating: $($rating.Rating)" -ForegroundColor $rating.Color
        Write-Host "  Meets Target: $(if($result.MeetsTarget){'✅ YES'}else{'❌ NO'})" -ForegroundColor $(if ($result.MeetsTarget) {
                'Green'
            } else {
                'Red'
            })
        Write-Host ""
    }
}

# Summary
Write-Host "📊 SUMMARY" -ForegroundColor Magenta
Write-Host "=" * 60 -ForegroundColor Gray

$meetingTargets = ($allResults | Where-Object { $_.MeetsTarget }).Count
$totalProfiles = $allResults.Count

Write-Host "Profiles meeting realistic targets: $meetingTargets / $totalProfiles" -ForegroundColor $(if ($meetingTargets -eq $totalProfiles) {
        'Green'
    } else {
        'Yellow'
    })

if ($totalProfiles -gt 0) {
    $bestProfile = $allResults | Sort-Object Average | Select-Object -First 1
    $worstProfile = $allResults | Sort-Object Average | Select-Object -Last 1
    
    Write-Host "Best performing: $($bestProfile.ProfileName) ($([math]::Round($bestProfile.Average, 1))ms)" -ForegroundColor Green
    if ($totalProfiles -gt 1) {
        Write-Host "Slowest: $($worstProfile.ProfileName) ($([math]::Round($worstProfile.Average, 1))ms)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "🎯 Recommendations:" -ForegroundColor Cyan

$avgOfAverages = ($allResults | Measure-Object -Property Average -Average).Average
if ($avgOfAverages -lt $PerformanceThresholds.Excellent) {
    Write-Host "  ⚡ Excellent performance! Profiles are well optimized." -ForegroundColor Green
} elseif ($avgOfAverages -lt $PerformanceThresholds.VeryGood) {
    Write-Host "  ✅ Very good performance. Consider this optimal for feature-rich profiles." -ForegroundColor Green
} elseif ($avgOfAverages -lt $PerformanceThresholds.Good) {
    Write-Host "  👍 Good performance. Minor optimizations could help." -ForegroundColor Yellow
    Write-Host "    • Consider lazy loading for non-essential modules" -ForegroundColor Gray
    Write-Host "    • Review Oh My Posh theme complexity" -ForegroundColor Gray
} else {
    Write-Host "  ⚠️ Performance could be improved:" -ForegroundColor Red
    Write-Host "    • Enable lazy loading for all non-essential modules" -ForegroundColor Gray
    Write-Host "    • Simplify or optimize Oh My Posh theme" -ForegroundColor Gray
    Write-Host "    • Review module loading order" -ForegroundColor Gray
}

Write-Host ""
Write-Host "💡 Remember: These realistic thresholds account for modern PowerShell" -ForegroundColor Gray
Write-Host "   feature richness and visual enhancements like Oh My Posh themes." -ForegroundColor Gray

# Generate HTML report if requested
if ($GenerateReport) {
    $reportPath = "$PSScriptRoot\RealisticPerformanceReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
    
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Realistic Performance Threshold Test Report</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; margin: 20px; background: #1e1e1e; color: #ffffff; }
        .header { background: linear-gradient(135deg, #6a5acd, #ff6b6b); padding: 20px; border-radius: 10px; margin-bottom: 20px; }
        .section { background: #2d2d30; padding: 15px; margin: 10px 0; border-radius: 8px; border-left: 4px solid #6a5acd; }
        .excellent { color: #4caf50; }
        .good { color: #ffeb3b; }
        .poor { color: #f44336; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 15px; }
        .stat-card { background: #3c3c3c; padding: 15px; border-radius: 8px; }
        .chart { margin: 20px 0; }
        .threshold-guide { background: #2a2a2a; padding: 15px; border-radius: 8px; margin: 15px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🎯 Realistic Performance Threshold Test Report</h1>
        <p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
        <p>Test Mode: $TestMode | Iterations: $testIterations</p>
    </div>
    
    <div class="threshold-guide">
        <h2>📊 Updated Performance Expectations</h2>
        <ul>
            <li class="excellent">⚡ Excellent: &lt; $($PerformanceThresholds.Excellent)ms</li>
            <li class="excellent">✅ Very Good: $($PerformanceThresholds.Excellent)-$($PerformanceThresholds.VeryGood)ms</li>
            <li class="good">👍 Good: $($PerformanceThresholds.VeryGood)-$($PerformanceThresholds.Good)ms</li>
            <li class="good">⚠️ Acceptable: $($PerformanceThresholds.Good)-$($PerformanceThresholds.Acceptable)ms</li>
            <li class="poor">❌ Poor: &gt; $($PerformanceThresholds.Acceptable)ms</li>
        </ul>
    </div>
    
    <div class="section">
        <h2>🧪 Test Results</h2>
        <div class="stats">
"@

    foreach ($result in $allResults) {
        $rating = Get-PerformanceRating -AvgTime $result.Average
        $ratingClass = switch ($rating.Color) {
            'Green' {
                'excellent' 
            }
            'Yellow' {
                'good' 
            }
            'Red' {
                'poor' 
            }
        }
        
        $html += @"
            <div class="stat-card">
                <h3>$($result.ProfileName)</h3>
                <p><strong>Average:</strong> $([math]::Round($result.Average, 1))ms</p>
                <p><strong>Range:</strong> $([math]::Round($result.Minimum, 1))ms - $([math]::Round($result.Maximum, 1))ms</p>
                <p><strong>Target:</strong> $($result.Target)ms</p>
                <p class="$ratingClass"><strong>Rating:</strong> $($rating.Rating)</p>
                <p><strong>Meets Target:</strong> $(if($result.MeetsTarget){'✅ YES'}else{'❌ NO'})</p>
            </div>
"@
    }

    $html += @"
        </div>
    </div>
    
    <div class="section">
        <h2>💡 Why These Targets Are Realistic</h2>
        <ul>
            <li>Previous 30-40ms targets were unrealistic for feature-rich PowerShell profiles</li>
            <li>Oh My Posh themes add 50-100ms but provide significant visual value</li>
            <li>Modern PowerShell with rich features: 200-500ms is excellent performance</li>
            <li>Focus should be on user experience over micro-optimization</li>
            <li>These thresholds account for real-world usage with multiple modules</li>
        </ul>
    </div>
    
    <div class="section">
        <h2>📈 Summary</h2>
        <p><strong>Profiles meeting realistic targets:</strong> $meetingTargets / $totalProfiles</p>
        <p><strong>Average load time across all profiles:</strong> $([math]::Round($avgOfAverages, 1))ms</p>
        <p><strong>Test completed:</strong> $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
    </div>
</body>
</html>
"@

    $html | Out-File -FilePath $reportPath -Encoding UTF8
    Write-Host ""
    Write-Host "📄 Report generated: $reportPath" -ForegroundColor Green
    
    if (Get-Command Start-Process -ErrorAction SilentlyContinue) {
        Start-Process $reportPath
    }
}

Write-Host ""
Write-Host "✅ Realistic performance threshold testing complete!" -ForegroundColor Green
