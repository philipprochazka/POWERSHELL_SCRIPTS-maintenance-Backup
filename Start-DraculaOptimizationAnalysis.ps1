<#
.SYNOPSIS
    Comprehensive Performance Analysis and Optimization Testing for Dracula Profile
.DESCRIPTION
    Runs multiple performance tests, generates detailed reports, and provides
    optimization recommendations for the Dracula PowerShell Profile system.
.VERSION
    1.0.0
.AUTHOR
    Philip Procházka
#>

[CmdletBinding()]
param(
    [ValidateSet('Quick', 'Standard', 'Comprehensive', 'Benchmark')]
    [string]$TestMode = 'Standard',
    
    [switch]$GenerateReport,
    
    [switch]$EnableDebugMode,
    
    [switch]$CompareProfiles,
    
    [string]$OutputDirectory = (Join-Path $PSScriptRoot "Logs\Performance")
)

Write-Host "🧛‍♂️ DRACULA PROFILE PERFORMANCE ANALYSIS" -ForegroundColor Magenta
Write-Host "=========================================" -ForegroundColor Gray
Write-Host ""

# Ensure output directory exists
if (-not (Test-Path $OutputDirectory)) {
    New-Item -Path $OutputDirectory -ItemType Directory -Force | Out-Null
}

#region 🔧 Test Configuration
$testConfig = switch ($TestMode) {
    'Quick' {
        @{
            Iterations            = 3
            Modules               = @('PSReadLine')
            EnableMemoryProfiling = $false
            DetailedAnalysis      = $false
        }
    }
    'Standard' {
        @{
            Iterations            = 5
            Modules               = @('PSReadLine', 'Terminal-Icons', 'z')
            EnableMemoryProfiling = $true
            DetailedAnalysis      = $true
        }
    }
    'Comprehensive' {
        @{
            Iterations            = 10
            Modules               = @('PSReadLine', 'Terminal-Icons', 'z', 'Az.Tools.Predictor', 'CompletionPredictor')
            EnableMemoryProfiling = $true
            DetailedAnalysis      = $true
        }
    }
    'Benchmark' {
        @{
            Iterations            = 20
            Modules               = @('PSReadLine', 'Terminal-Icons', 'z', 'Az.Tools.Predictor', 'CompletionPredictor')
            EnableMemoryProfiling = $true
            DetailedAnalysis      = $true
        }
    }
}

Write-Host "🎯 Test Mode: " -NoNewline -ForegroundColor Cyan
Write-Host $TestMode -ForegroundColor Yellow
Write-Host "📊 Iterations: " -NoNewline -ForegroundColor Cyan
Write-Host $testConfig.Iterations -ForegroundColor Yellow
Write-Host ""
#endregion

#region 🚀 Profile Performance Testing
function Test-ProfileWithDebug {
    param(
        [string]$ProfilePath,
        [string]$ProfileName,
        [int]$Iterations
    )
    
    Write-Host "🔬 Testing $ProfileName..." -ForegroundColor Cyan
    
    $results = @()
    
    for ($i = 1; $i -le $Iterations; $i++) {
        Write-Host "  Iteration $i/$Iterations..." -NoNewline -ForegroundColor Yellow
        
        # Test with debug enabled
        $env:DRACULA_PERFORMANCE_DEBUG = 'true'
        $env:DRACULA_SHOW_STARTUP = 'false'
        
        # Run profile in isolated process
        $scriptBlock = @"
            `$env:DRACULA_PERFORMANCE_DEBUG = 'true'
            `$VerbosePreference = 'SilentlyContinue'
            `$measureStart = Get-Date
            
            try {
                . '$ProfilePath'
                
                # Wait for any background loading
                Start-Sleep -Milliseconds 50
                
                `$loadTime = ((Get-Date) - `$measureStart).TotalMilliseconds
                
                # Collect debug metrics if available
                if (Get-Command Get-DraculaDebugSummary -ErrorAction SilentlyContinue) {
                    `$debugData = `$global:DraculaDebugMetrics
                } else {
                    `$debugData = @{}
                }
                
                # Return results
                @{
                    LoadTime = `$loadTime
                    DebugData = `$debugData
                    ModulesLoaded = (Get-Module).Count
                    MemoryUsage = [System.GC]::GetTotalMemory(`$false)
                    Success = `$true
                    ErrorMessage = ''
                }
            } catch {
                @{
                    LoadTime = ((Get-Date) - `$measureStart).TotalMilliseconds
                    DebugData = @{}
                    ModulesLoaded = 0
                    MemoryUsage = [System.GC]::GetTotalMemory(`$false)
                    Success = `$false
                    ErrorMessage = `$_.Exception.Message
                }
            }
"@
        
        try {
            $result = powershell.exe -NoProfile -WindowStyle Hidden -Command $scriptBlock
            
            if ($result.Success) {
                Write-Host " ✅ $([math]::Round($result.LoadTime, 1))ms" -ForegroundColor Green
            } else {
                Write-Host " ❌ Failed: $($result.ErrorMessage)" -ForegroundColor Red
            }
            
            $results += $result
            
        } catch {
            Write-Host " ❌ Test failed: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Brief pause between tests
        Start-Sleep -Milliseconds 200
    }
    
    # Clean up environment
    Remove-Item Env:DRACULA_PERFORMANCE_DEBUG -ErrorAction SilentlyContinue
    Remove-Item Env:DRACULA_SHOW_STARTUP -ErrorAction SilentlyContinue
    
    return $results
}

# Test current performance profile
Write-Host "🎯 Testing Performance Profile..." -ForegroundColor Magenta

$performanceProfile = Join-Path $PSScriptRoot "Microsoft.PowerShell_profile_Dracula_Performance.ps1"
if (Test-Path $performanceProfile) {
    $performanceResults = Test-ProfileWithDebug -ProfilePath $performanceProfile -ProfileName "Performance" -Iterations $testConfig.Iterations
} else {
    Write-Warning "Performance profile not found: $performanceProfile"
    $performanceResults = @()
}

# Test other profiles if comparison is requested
$comparisonResults = @{}

if ($CompareProfiles) {
    Write-Host ""
    Write-Host "🔄 Comparing with other profiles..." -ForegroundColor Magenta
    
    $profileVariants = @{
        'Normal'  = 'Microsoft.PowerShell_profile_Dracula.ps1'
        'Minimal' = 'Microsoft.PowerShell_profile_Dracula_Minimal.ps1'
        'Silent'  = 'Microsoft.PowerShell_profile_Dracula_Silent.ps1'
    }
    
    foreach ($variant in $profileVariants.GetEnumerator()) {
        $profilePath = Join-Path $PSScriptRoot $variant.Value
        if (Test-Path $profilePath) {
            $comparisonResults[$variant.Key] = Test-ProfileWithDebug -ProfilePath $profilePath -ProfileName $variant.Key -Iterations $testConfig.Iterations
        } else {
            Write-Warning "Profile variant not found: $profilePath"
        }
    }
}
#endregion

#region 📊 Analysis and Reporting
Write-Host ""
Write-Host "📊 PERFORMANCE ANALYSIS RESULTS" -ForegroundColor Magenta
Write-Host "===============================" -ForegroundColor Gray
Write-Host ""

# Analyze performance results
if ($performanceResults.Count -gt 0) {
    $successfulTests = $performanceResults | Where-Object { $_.Success }
    
    if ($successfulTests.Count -gt 0) {
        $avgLoadTime = ($successfulTests | Measure-Object LoadTime -Average).Average
        $minLoadTime = ($successfulTests | Measure-Object LoadTime -Minimum).Minimum
        $maxLoadTime = ($successfulTests | Measure-Object LoadTime -Maximum).Maximum
        $avgMemory = ($successfulTests | Measure-Object MemoryUsage -Average).Average / 1MB
        
        Write-Host "⚡ Performance Profile Results:" -ForegroundColor Cyan
        Write-Host "   Average Load Time: " -NoNewline -ForegroundColor Gray
        
        $color = if ($avgLoadTime -lt 500) {
            'Green' 
        } elseif ($avgLoadTime -lt 1000) {
            'Yellow' 
        } else {
            'Red' 
        }
        Write-Host "$([math]::Round($avgLoadTime, 1))ms" -ForegroundColor $color
        
        Write-Host "   Load Time Range: " -NoNewline -ForegroundColor Gray
        Write-Host "$([math]::Round($minLoadTime, 1))ms - $([math]::Round($maxLoadTime, 1))ms" -ForegroundColor White
        
        Write-Host "   Average Memory: " -NoNewline -ForegroundColor Gray
        Write-Host "$([math]::Round($avgMemory, 2)) MB" -ForegroundColor White
        
        Write-Host "   Success Rate: " -NoNewline -ForegroundColor Gray
        $successRate = ($successfulTests.Count / $performanceResults.Count) * 100
        $successColor = if ($successRate -eq 100) {
            'Green' 
        } elseif ($successRate -gt 80) {
            'Yellow' 
        } else {
            'Red' 
        }
        Write-Host "$([math]::Round($successRate, 1))%" -ForegroundColor $successColor
        
        # Performance rating
        Write-Host ""
        Write-Host "🎯 Performance Rating: " -NoNewline -ForegroundColor Cyan
        if ($avgLoadTime -lt 300) {
            Write-Host "⚡ EXCELLENT (Sub-300ms)" -ForegroundColor Green
        } elseif ($avgLoadTime -lt 500) {
            Write-Host "✅ VERY GOOD (300-500ms)" -ForegroundColor Green
        } elseif ($avgLoadTime -lt 750) {
            Write-Host "👍 GOOD (500-750ms)" -ForegroundColor Yellow
        } elseif ($avgLoadTime -lt 1000) {
            Write-Host "⚠️ ACCEPTABLE (750ms-1s)" -ForegroundColor Yellow
        } else {
            Write-Host "❌ NEEDS OPTIMIZATION (>1s)" -ForegroundColor Red
        }
        
    } else {
        Write-Host "❌ All performance tests failed!" -ForegroundColor Red
    }
} else {
    Write-Host "❌ No performance test results available!" -ForegroundColor Red
}

# Comparison results
if ($CompareProfiles -and $comparisonResults.Count -gt 0) {
    Write-Host ""
    Write-Host "🔄 Profile Comparison:" -ForegroundColor Cyan
    
    $comparisonData = @()
    
    # Add performance profile to comparison
    if ($performanceResults.Count -gt 0) {
        $successfulPerf = $performanceResults | Where-Object { $_.Success }
        if ($successfulPerf.Count -gt 0) {
            $comparisonData += @{
                Name        = 'Performance'
                AvgTime     = ($successfulPerf | Measure-Object LoadTime -Average).Average
                SuccessRate = ($successfulPerf.Count / $performanceResults.Count) * 100
            }
        }
    }
    
    # Add other profiles
    foreach ($variant in $comparisonResults.GetEnumerator()) {
        $successful = $variant.Value | Where-Object { $_.Success }
        if ($successful.Count -gt 0) {
            $comparisonData += @{
                Name        = $variant.Key
                AvgTime     = ($successful | Measure-Object LoadTime -Average).Average
                SuccessRate = ($successful.Count / $variant.Value.Count) * 100
            }
        }
    }
    
    # Sort by performance
    $comparisonData = $comparisonData | Sort-Object AvgTime
    
    Write-Host "   Rank | Profile     | Avg Time    | Success Rate" -ForegroundColor Gray
    Write-Host "   -----|-------------|-------------|-------------" -ForegroundColor Gray
    
    for ($i = 0; $i -lt $comparisonData.Count; $i++) {
        $profile = $comparisonData[$i]
        $rank = $i + 1
        $medal = switch ($rank) {
            1 {
                "🥇" 
            }
            2 {
                "🥈" 
            }
            3 {
                "🥉" 
            }
            default {
                "  " 
            }
        }
        
        $timeColor = if ($profile.AvgTime -lt 500) {
            'Green' 
        } elseif ($profile.AvgTime -lt 1000) {
            'Yellow' 
        } else {
            'Red' 
        }
        
        Write-Host "   $medal $rank   | " -NoNewline -ForegroundColor White
        Write-Host ("{0,-11}" -f $profile.Name) -NoNewline -ForegroundColor White
        Write-Host " | " -NoNewline -ForegroundColor Gray
        Write-Host ("{0,8}ms" -f [math]::Round($profile.AvgTime, 1)) -NoNewline -ForegroundColor $timeColor
        Write-Host " | " -NoNewline -ForegroundColor Gray
        Write-Host ("{0,10}%" -f [math]::Round($profile.SuccessRate, 1)) -ForegroundColor White
    }
}

# Optimization recommendations
Write-Host ""
Write-Host "💡 Optimization Recommendations:" -ForegroundColor Cyan

$recommendations = @()

if ($performanceResults.Count -gt 0) {
    $successfulTests = $performanceResults | Where-Object { $_.Success }
    if ($successfulTests.Count -gt 0) {
        $avgLoadTime = ($successfulTests | Measure-Object LoadTime -Average).Average
        
        if ($avgLoadTime -gt 1000) {
            $recommendations += "❌ CRITICAL: Load time >1s. Enable lazy loading for all non-essential modules."
            $recommendations += "   Consider using DRACULA_PERFORMANCE_DEBUG=true to identify bottlenecks."
        } elseif ($avgLoadTime -gt 750) {
            $recommendations += "⚠️ Load time >750ms. Review module loading order and consider lazy loading."
        } elseif ($avgLoadTime -gt 500) {
            $recommendations += "ℹ️ Load time >500ms. Profile is good but has optimization potential."
        }
        
        # Check for failed tests
        $failedTests = $performanceResults | Where-Object { -not $_.Success }
        if ($failedTests.Count -gt 0) {
            $recommendations += "❌ $($failedTests.Count) tests failed. Check error messages and fix profile issues."
        }
        
        # Memory recommendations
        if ($testConfig.EnableMemoryProfiling) {
            $avgMemory = ($successfulTests | Measure-Object MemoryUsage -Average).Average / 1MB
            if ($avgMemory -gt 50) {
                $recommendations += "💾 High memory usage ($([math]::Round($avgMemory, 1))MB). Review module memory footprint."
            }
        }
    }
}

if ($recommendations.Count -eq 0) {
    $recommendations += "✅ Profile performance is excellent! No optimization needed."
}

foreach ($rec in $recommendations) {
    Write-Host "   $rec" -ForegroundColor Yellow
}

# Show debug mode instructions
Write-Host ""
Write-Host "🔬 Debug Mode Usage:" -ForegroundColor Cyan
Write-Host "   Set DRACULA_PERFORMANCE_DEBUG=true to enable real-time debug metrics" -ForegroundColor Gray
Write-Host "   Use dbg-summary command to view detailed performance breakdown" -ForegroundColor Gray
Write-Host "   Use dbg-export to save metrics for analysis" -ForegroundColor Gray
Write-Host ""
#endregion

#region 📄 Report Generation
if ($GenerateReport) {
    Write-Host "📄 Generating detailed report..." -ForegroundColor Cyan
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $reportPath = Join-Path $OutputDirectory "DraculaProfile_Analysis_$timestamp.html"
    
    # Use the comprehensive metrics tool if available
    $metricsScript = Join-Path $PSScriptRoot "Test-DraculaProfileMetrics.ps1"
    if (Test-Path $metricsScript) {
        Write-Host "📊 Running comprehensive metrics analysis..." -ForegroundColor Yellow
        
        $metricsParams = @{
            ProfileMode    = 'Performance'
            Iterations     = $testConfig.Iterations
            GenerateReport = $true
            ModuleProfile  = $true
            OutputPath     = $OutputDirectory
        }
        
        & $metricsScript @metricsParams
        
    } else {
        Write-Warning "Comprehensive metrics script not found. Basic report only."
        
        # Generate basic HTML report
        $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Dracula Profile Analysis Report</title>
    <style>
        body { font-family: 'Consolas', monospace; background: #282a36; color: #f8f8f2; margin: 20px; }
        .header { color: #bd93f9; font-size: 24px; margin-bottom: 20px; }
        .section { margin: 20px 0; padding: 15px; background: #44475a; border-radius: 8px; }
        .good { color: #50fa7b; }
        .warning { color: #ffb86c; }
        .error { color: #ff5555; }
    </style>
</head>
<body>
    <div class="header">🧛‍♂️ Dracula Profile Analysis Report</div>
    <div>Generated: $(Get-Date)</div>
    <div>Test Mode: $TestMode</div>
    <div>Iterations: $($testConfig.Iterations)</div>
    
    <div class="section">
        <h2>Performance Results</h2>
        <!-- Basic results would go here -->
    </div>
</body>
</html>
"@
        
        $html | Out-File -FilePath $reportPath -Encoding UTF8
    }
    
    Write-Host "✅ Report saved to: " -NoNewline -ForegroundColor Green
    Write-Host $reportPath -ForegroundColor Yellow
}
#endregion

Write-Host ""
Write-Host "🧛‍♂️ Analysis complete! Use the recommendations above to optimize your profile." -ForegroundColor Magenta
Write-Host ""

# Return results for further processing
return @{
    PerformanceResults = $performanceResults
    ComparisonResults  = $comparisonResults
    TestConfig         = $testConfig
    Recommendations    = $recommendations
}
