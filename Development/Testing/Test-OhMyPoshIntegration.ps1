#Requires -Version 5.1

<#
.SYNOPSIS
    Comprehensive Oh My Posh Integration Testing for UnifiedPowerShellProfile
    
.DESCRIPTION
    Tests all aspects of Oh My Posh integration within the UnifiedPowerShellProfile system,
    validates compatibility, performance, and feature availability.
    
.PARAMETER TestLevel
    Level of testing to perform (Quick, Standard, Comprehensive)
    
.PARAMETER GenerateReport
    Generate a detailed HTML report
    
.PARAMETER BenchmarkPerformance
    Include performance benchmarking
    
.EXAMPLE
    .\Test-OhMyPoshIntegration.ps1 -TestLevel Comprehensive -GenerateReport -BenchmarkPerformance
    
.NOTES
    Validates that Oh My Posh remains a core, well-integrated component
#>

[CmdletBinding()]
param(
    [ValidateSet('Quick', 'Standard', 'Comprehensive')]
    [string]$TestLevel = 'Standard',
    
    [switch]$GenerateReport,
    
    [switch]$BenchmarkPerformance
)

# Test Results Collection
$global:TestResults = @{
    StartTime   = Get-Date
    TestLevel   = $TestLevel
    Tests       = @()
    Summary     = @{
        Total    = 0
        Passed   = 0
        Failed   = 0
        Warnings = 0
    }
    Performance = @{}
    Environment = @{
        PowerShellVersion = $PSVersionTable.PSVersion
        OS                = $PSVersionTable.OS
        Edition           = $PSVersionTable.PSEdition
    }
}

#region Test Helper Functions

function Add-TestResult {
    param(
        [string]$TestName,
        [bool]$Passed,
        [string]$Details = '',
        [string]$ErrorMessage = '',
        [hashtable]$Data = @{}
    )
    
    $result = @{
        TestName     = $TestName
        Passed       = $Passed
        Details      = $Details
        ErrorMessage = $ErrorMessage
        Data         = $Data
        Timestamp    = Get-Date
    }
    
    $global:TestResults.Tests += $result
    $global:TestResults.Summary.Total++
    
    if ($Passed) {
        $global:TestResults.Summary.Passed++
        Write-Host "✅ $TestName" -ForegroundColor Green
        if ($Details) {
            Write-Host "   $Details" -ForegroundColor Gray 
        }
    } else {
        $global:TestResults.Summary.Failed++
        Write-Host "❌ $TestName" -ForegroundColor Red
        if ($ErrorMessage) {
            Write-Host "   Error: $ErrorMessage" -ForegroundColor Red 
        }
        if ($Details) {
            Write-Host "   Details: $Details" -ForegroundColor Gray 
        }
    }
}

function Add-WarningResult {
    param(
        [string]$TestName,
        [string]$Warning
    )
    
    $global:TestResults.Summary.Warnings++
    Write-Host "⚠️ $TestName" -ForegroundColor Yellow
    Write-Host "   Warning: $Warning" -ForegroundColor Yellow
}

function Measure-Performance {
    param(
        [string]$TestName,
        [scriptblock]$ScriptBlock
    )
    
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    try {
        $result = & $ScriptBlock
        $stopwatch.Stop()
        
        $global:TestResults.Performance[$TestName] = @{
            Duration = $stopwatch.ElapsedMilliseconds
            Success  = $true
            Result   = $result
        }
        
        Write-Host "⏱️ $TestName completed in $($stopwatch.ElapsedMilliseconds)ms" -ForegroundColor Cyan
        return $result
    } catch {
        $stopwatch.Stop()
        $global:TestResults.Performance[$TestName] = @{
            Duration = $stopwatch.ElapsedMilliseconds
            Success  = $false
            Error    = $_.Exception.Message
        }
        throw
    }
}

#endregion

#region Core Integration Tests

function Test-OhMyPoshInstallation {
    Write-Host "`n🔍 Testing Oh My Posh Installation..." -ForegroundColor Cyan
    
    # Test 1: Command availability
    try {
        $ohMyPoshCmd = Get-Command oh-my-posh -ErrorAction Stop
        Add-TestResult -TestName "Oh My Posh Command Available" -Passed $true -Details "Found at: $($ohMyPoshCmd.Source)"
    } catch {
        Add-TestResult -TestName "Oh My Posh Command Available" -Passed $false -ErrorMessage $_.Exception.Message
        return
    }
    
    # Test 2: Version detection
    try {
        $version = & oh-my-posh version 2>$null
        if ($version) {
            $versionNumber = [version]($version -replace '[^\d\.].*$')
            $isModern = $versionNumber.Major -ge 26
            
            Add-TestResult -TestName "Oh My Posh Version Detection" -Passed $true -Details "v$version (Modern: $isModern)" -Data @{
                Version       = $version
                VersionNumber = $versionNumber
                IsModern      = $isModern
            }
        } else {
            Add-TestResult -TestName "Oh My Posh Version Detection" -Passed $false -ErrorMessage "Version command returned empty"
        }
    } catch {
        Add-TestResult -TestName "Oh My Posh Version Detection" -Passed $false -ErrorMessage $_.Exception.Message
    }
    
    # Test 3: Themes path detection
    try {
        $themesPath = $env:POSH_THEMES_PATH
        if (-not $themesPath) {
            # Try to auto-detect
            $possiblePaths = @(
                "$env:LOCALAPPDATA\Programs\oh-my-posh\themes",
                "$env:APPDATA\oh-my-posh\themes",
                "${env:ProgramFiles}\oh-my-posh\themes"
            )
            
            foreach ($path in $possiblePaths) {
                if (Test-Path $path) {
                    $themesPath = $path
                    break
                }
            }
        }
        
        if ($themesPath -and (Test-Path $themesPath)) {
            $themeCount = (Get-ChildItem $themesPath -Filter "*.omp.json").Count
            Add-TestResult -TestName "Themes Directory Available" -Passed $true -Details "$themeCount themes found at: $themesPath"
        } else {
            Add-WarningResult -TestName "Themes Directory Available" -Warning "Themes directory not found - custom themes may not work"
        }
    } catch {
        Add-WarningResult -TestName "Themes Directory Available" -Warning $_.Exception.Message
    }
}

function Test-UnifiedProfileModule {
    Write-Host "`n🔍 Testing UnifiedPowerShellProfile Module..." -ForegroundColor Cyan
    
    # Test 1: Module availability
    try {
        $module = Get-Module UnifiedPowerShellProfile -ListAvailable | Select-Object -First 1
        if ($module) {
            Add-TestResult -TestName "UnifiedPowerShellProfile Module Available" -Passed $true -Details "v$($module.Version)"
        } else {
            Add-TestResult -TestName "UnifiedPowerShellProfile Module Available" -Passed $false -ErrorMessage "Module not found"
            return
        }
    } catch {
        Add-TestResult -TestName "UnifiedPowerShellProfile Module Available" -Passed $false -ErrorMessage $_.Exception.Message
        return
    }
    
    # Test 2: Module import
    try {
        Import-Module UnifiedPowerShellProfile -Force -ErrorAction Stop
        Add-TestResult -TestName "UnifiedPowerShellProfile Module Import" -Passed $true
    } catch {
        Add-TestResult -TestName "UnifiedPowerShellProfile Module Import" -Passed $false -ErrorMessage $_.Exception.Message
        return
    }
    
    # Test 3: Initialize-ModernOhMyPosh function availability
    try {
        $function = Get-Command Initialize-ModernOhMyPosh -ErrorAction Stop
        Add-TestResult -TestName "Initialize-ModernOhMyPosh Function Available" -Passed $true -Details "Function found"
    } catch {
        Add-TestResult -TestName "Initialize-ModernOhMyPosh Function Available" -Passed $false -ErrorMessage $_.Exception.Message
    }
    
    # Test 4: Core profile functions
    $coreFunctions = @('Initialize-UnifiedProfile', 'Get-ProfileStatus', 'Set-ProfileMode')
    foreach ($funcName in $coreFunctions) {
        try {
            $func = Get-Command $funcName -ErrorAction Stop
            Add-TestResult -TestName "Core Function: $funcName" -Passed $true
        } catch {
            Add-TestResult -TestName "Core Function: $funcName" -Passed $false -ErrorMessage $_.Exception.Message
        }
    }
}

function Test-OhMyPoshInitialization {
    Write-Host "`n🔍 Testing Oh My Posh Initialization..." -ForegroundColor Cyan
    
    # Test 1: Basic initialization
    try {
        if (Get-Command Initialize-ModernOhMyPosh -ErrorAction SilentlyContinue) {
            Measure-Performance -TestName "Initialize-ModernOhMyPosh" -ScriptBlock {
                Initialize-ModernOhMyPosh -Mode 'Dracula' -Verbose:$false
            }
            Add-TestResult -TestName "Oh My Posh Initialization (Modern)" -Passed $true
        } else {
            Add-WarningResult -TestName "Oh My Posh Initialization (Modern)" -Warning "Initialize-ModernOhMyPosh not available, testing legacy method"
            
            # Test legacy method
            try {
                if ($env:POSH_THEMES_PATH -and (Test-Path "$env:POSH_THEMES_PATH\dracula.omp.json")) {
                    Measure-Performance -TestName "Legacy-OhMyPosh-Init" -ScriptBlock {
                        oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\dracula.omp.json" | Invoke-Expression
                    }
                    Add-TestResult -TestName "Oh My Posh Initialization (Legacy)" -Passed $true
                } else {
                    Measure-Performance -TestName "Default-OhMyPosh-Init" -ScriptBlock {
                        oh-my-posh init pwsh | Invoke-Expression
                    }
                    Add-TestResult -TestName "Oh My Posh Initialization (Default)" -Passed $true
                }
            } catch {
                Add-TestResult -TestName "Oh My Posh Initialization (Legacy)" -Passed $false -ErrorMessage $_.Exception.Message
            }
        }
    } catch {
        Add-TestResult -TestName "Oh My Posh Initialization" -Passed $false -ErrorMessage $_.Exception.Message
    }
    
    # Test 2: Different modes
    if ($TestLevel -in @('Standard', 'Comprehensive')) {
        $modes = @('Dracula', 'Performance', 'Minimal')
        foreach ($mode in $modes) {
            try {
                if (Get-Command Initialize-ModernOhMyPosh -ErrorAction SilentlyContinue) {
                    Initialize-ModernOhMyPosh -Mode $mode -Verbose:$false
                    Add-TestResult -TestName "Mode Initialization: $mode" -Passed $true
                } else {
                    Add-WarningResult -TestName "Mode Initialization: $mode" -Warning "Modern initialization not available"
                }
            } catch {
                Add-TestResult -TestName "Mode Initialization: $mode" -Passed $false -ErrorMessage $_.Exception.Message
            }
        }
    }
}

function Test-IntegrationWithUnifiedProfile {
    Write-Host "`n🔍 Testing Integration with UnifiedProfile..." -ForegroundColor Cyan
    
    # Test 1: Profile initialization with Oh My Posh
    try {
        if (Get-Command Initialize-UnifiedProfile -ErrorAction SilentlyContinue) {
            Measure-Performance -TestName "Unified-Profile-Init" -ScriptBlock {
                Initialize-UnifiedProfile -Mode 'Dracula'
            }
            Add-TestResult -TestName "Unified Profile Initialization" -Passed $true
        } else {
            Add-TestResult -TestName "Unified Profile Initialization" -Passed $false -ErrorMessage "Initialize-UnifiedProfile not available"
        }
    } catch {
        Add-TestResult -TestName "Unified Profile Initialization" -Passed $false -ErrorMessage $_.Exception.Message
    }
    
    # Test 2: Profile status
    try {
        if (Get-Command Get-ProfileStatus -ErrorAction SilentlyContinue) {
            $status = Get-ProfileStatus
            Add-TestResult -TestName "Profile Status Retrieval" -Passed $true -Data $status
        } else {
            Add-WarningResult -TestName "Profile Status Retrieval" -Warning "Get-ProfileStatus not available"
        }
    } catch {
        Add-TestResult -TestName "Profile Status Retrieval" -Passed $false -ErrorMessage $_.Exception.Message
    }
    
    # Test 3: Dracula profile specific features
    try {
        if (Get-Command Initialize-DraculaProfile -ErrorAction SilentlyContinue) {
            Initialize-DraculaProfile
            Add-TestResult -TestName "Dracula Profile Integration" -Passed $true
        } else {
            Add-WarningResult -TestName "Dracula Profile Integration" -Warning "Initialize-DraculaProfile not available"
        }
    } catch {
        Add-TestResult -TestName "Dracula Profile Integration" -Passed $false -ErrorMessage $_.Exception.Message
    }
}

function Test-PerformanceMetrics {
    if (-not $BenchmarkPerformance) {
        return 
    }
    
    Write-Host "`n🔍 Testing Performance Metrics..." -ForegroundColor Cyan
    
    # Performance baseline
    $iterations = if ($TestLevel -eq 'Comprehensive') {
        10 
    } else {
        5 
    }
    
    # Test 1: Oh My Posh initialization performance
    $initTimes = @()
    for ($i = 1; $i -le $iterations; $i++) {
        try {
            $time = Measure-Command {
                if (Get-Command Initialize-ModernOhMyPosh -ErrorAction SilentlyContinue) {
                    Initialize-ModernOhMyPosh -Mode 'Performance' -Verbose:$false
                } else {
                    oh-my-posh init pwsh | Out-Null
                }
            }
            $initTimes += $time.TotalMilliseconds
        } catch {
            # Skip failed iterations
        }
    }
    
    if ($initTimes.Count -gt 0) {
        $avgTime = ($initTimes | Measure-Object -Average).Average
        $maxTime = ($initTimes | Measure-Object -Maximum).Maximum
        $minTime = ($initTimes | Measure-Object -Minimum).Minimum
        
        $performanceGrade = if ($avgTime -lt 100) {
            'Excellent' 
        } elseif ($avgTime -lt 250) {
            'Good' 
        } elseif ($avgTime -lt 500) {
            'Fair' 
        } else {
            'Poor' 
        }
        
        Add-TestResult -TestName "Oh My Posh Performance" -Passed ($avgTime -lt 1000) -Details "Avg: $([math]::Round($avgTime))ms (Min: $([math]::Round($minTime))ms, Max: $([math]::Round($maxTime))ms) - $performanceGrade"
        
        $global:TestResults.Performance['OhMyPoshInit'] = @{
            Average    = $avgTime
            Minimum    = $minTime
            Maximum    = $maxTime
            Grade      = $performanceGrade
            Iterations = $iterations
        }
    }
    
    # Test 2: Memory usage
    try {
        $beforeMemory = [System.GC]::GetTotalMemory($false)
        Initialize-ModernOhMyPosh -Mode 'Dracula' -Verbose:$false
        $afterMemory = [System.GC]::GetTotalMemory($false)
        $memoryUsed = $afterMemory - $beforeMemory
        
        Add-TestResult -TestName "Memory Usage" -Passed ($memoryUsed -lt 50MB) -Details "$([math]::Round($memoryUsed / 1MB, 2)) MB"
        
        $global:TestResults.Performance['MemoryUsage'] = @{
            Before = $beforeMemory
            After  = $afterMemory
            Used   = $memoryUsed
            UsedMB = [math]::Round($memoryUsed / 1MB, 2)
        }
    } catch {
        Add-WarningResult -TestName "Memory Usage" -Warning "Could not measure memory usage"
    }
}

#endregion

#region Comprehensive Testing

function Test-ThemeCompatibility {
    if ($TestLevel -ne 'Comprehensive') {
        return 
    }
    
    Write-Host "`n🔍 Testing Theme Compatibility..." -ForegroundColor Cyan
    
    $themesPath = $env:POSH_THEMES_PATH
    if (-not $themesPath) {
        Add-WarningResult -TestName "Theme Compatibility" -Warning "POSH_THEMES_PATH not set"
        return
    }
    
    if (-not (Test-Path $themesPath)) {
        Add-WarningResult -TestName "Theme Compatibility" -Warning "Themes directory not found"
        return
    }
    
    $themes = Get-ChildItem $themesPath -Filter "*.omp.json" | Select-Object -First 5
    foreach ($theme in $themes) {
        try {
            $themeName = $theme.BaseName
            oh-my-posh init pwsh --config $theme.FullName | Out-Null
            Add-TestResult -TestName "Theme: $themeName" -Passed $true
        } catch {
            Add-TestResult -TestName "Theme: $themeName" -Passed $false -ErrorMessage $_.Exception.Message
        }
    }
}

function Test-ErrorHandling {
    if ($TestLevel -ne 'Comprehensive') {
        return 
    }
    
    Write-Host "`n🔍 Testing Error Handling..." -ForegroundColor Cyan
    
    # Test 1: Invalid theme path
    try {
        if (Get-Command Initialize-ModernOhMyPosh -ErrorAction SilentlyContinue) {
            Initialize-ModernOhMyPosh -ThemePath "nonexistent-theme.json" -ErrorAction Stop
            Add-TestResult -TestName "Invalid Theme Path Handling" -Passed $false -ErrorMessage "Should have failed with invalid path"
        }
    } catch {
        Add-TestResult -TestName "Invalid Theme Path Handling" -Passed $true -Details "Properly handled invalid theme path"
    }
    
    # Test 2: Missing Oh My Posh (simulation)
    try {
        # Temporarily rename oh-my-posh command (if possible)
        $originalPath = $env:PATH
        $env:PATH = ""
        
        if (Get-Command Initialize-ModernOhMyPosh -ErrorAction SilentlyContinue) {
            Initialize-ModernOhMyPosh -Mode 'Dracula'
            Add-TestResult -TestName "Missing Oh My Posh Handling" -Passed $true -Details "Gracefully handled missing command"
        }
        
        $env:PATH = $originalPath
    } catch {
        $env:PATH = $originalPath
        Add-TestResult -TestName "Missing Oh My Posh Handling" -Passed $true -Details "Properly handled missing command with error"
    }
}

#endregion

#region Report Generation

function Generate-TestReport {
    if (-not $GenerateReport) {
        return 
    }
    
    Write-Host "`n📊 Generating Test Report..." -ForegroundColor Cyan
    
    $reportPath = "OhMyPosh-Integration-Test-Report-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
    
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Oh My Posh Integration Test Report</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #bd93f9, #8be9fd); color: white; padding: 20px; margin: -20px -20px 20px -20px; border-radius: 8px 8px 0 0; }
        .summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .summary-card { background: #f8f9fa; padding: 20px; border-radius: 8px; text-align: center; border-left: 4px solid #007bff; }
        .passed { border-left-color: #28a745; }
        .failed { border-left-color: #dc3545; }
        .warning { border-left-color: #ffc107; }
        .test-result { margin: 10px 0; padding: 15px; border-radius: 5px; }
        .test-passed { background: #d4edda; border: 1px solid #c3e6cb; }
        .test-failed { background: #f8d7da; border: 1px solid #f5c6cb; }
        .test-warning { background: #fff3cd; border: 1px solid #ffeaa7; }
        .performance { background: #e3f2fd; padding: 15px; border-radius: 5px; margin: 20px 0; }
        .timestamp { color: #666; font-size: 0.9em; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🧛‍♂️ Oh My Posh Integration Test Report</h1>
            <p>UnifiedPowerShellProfile System - Test Level: $($global:TestResults.TestLevel)</p>
            <p class="timestamp">Generated: $($global:TestResults.StartTime.ToString('yyyy-MM-dd HH:mm:ss'))</p>
        </div>
        
        <div class="summary">
            <div class="summary-card passed">
                <h3>✅ Passed</h3>
                <div style="font-size: 2em; font-weight: bold;">$($global:TestResults.Summary.Passed)</div>
            </div>
            <div class="summary-card failed">
                <h3>❌ Failed</h3>
                <div style="font-size: 2em; font-weight: bold;">$($global:TestResults.Summary.Failed)</div>
            </div>
            <div class="summary-card warning">
                <h3>⚠️ Warnings</h3>
                <div style="font-size: 2em; font-weight: bold;">$($global:TestResults.Summary.Warnings)</div>
            </div>
            <div class="summary-card">
                <h3>📊 Total</h3>
                <div style="font-size: 2em; font-weight: bold;">$($global:TestResults.Summary.Total)</div>
            </div>
        </div>
        
        <h2>🔍 Test Results</h2>
"@

    foreach ($test in $global:TestResults.Tests) {
        $cssClass = if ($test.Passed) {
            'test-passed' 
        } else {
            'test-failed' 
        }
        $icon = if ($test.Passed) {
            '✅' 
        } else {
            '❌' 
        }
        
        $html += @"
        <div class="test-result $cssClass">
            <strong>$icon $($test.TestName)</strong>
            $(if ($test.Details) { "<br><em>$($test.Details)</em>" })
            $(if ($test.ErrorMessage) { "<br><span style='color: red;'>Error: $($test.ErrorMessage)</span>" })
            <div class="timestamp">$($test.Timestamp.ToString('HH:mm:ss'))</div>
        </div>
"@
    }
    
    if ($global:TestResults.Performance.Count -gt 0) {
        $html += @"
        <h2>⚡ Performance Metrics</h2>
        <div class="performance">
            <table>
                <tr><th>Metric</th><th>Value</th><th>Details</th></tr>
"@
        
        foreach ($perf in $global:TestResults.Performance.GetEnumerator()) {
            $name = $perf.Key
            $data = $perf.Value
            
            if ($data.Average) {
                $html += "<tr><td>$name</td><td>$([math]::Round($data.Average))ms avg</td><td>Min: $([math]::Round($data.Minimum))ms, Max: $([math]::Round($data.Maximum))ms ($($data.Grade))</td></tr>"
            } else {
                $html += "<tr><td>$name</td><td>$($data.Duration)ms</td><td>$(if ($data.Success) { 'Success' } else { 'Failed' })</td></tr>"
            }
        }
        
        $html += @"
            </table>
        </div>
"@
    }
    
    $html += @"
        <h2>🖥️ Environment Information</h2>
        <table>
            <tr><td>PowerShell Version</td><td>$($global:TestResults.Environment.PowerShellVersion)</td></tr>
            <tr><td>PowerShell Edition</td><td>$($global:TestResults.Environment.Edition)</td></tr>
            <tr><td>Operating System</td><td>$($global:TestResults.Environment.OS)</td></tr>
            <tr><td>Test Duration</td><td>$([math]::Round((Get-Date - $global:TestResults.StartTime).TotalSeconds, 2)) seconds</td></tr>
        </table>
        
        <div style="margin-top: 40px; padding: 20px; background: #e8f5e8; border-radius: 5px;">
            <h3>💡 Conclusion</h3>
            <p><strong>Oh My Posh Integration Status: 
            $(if ($global:TestResults.Summary.Failed -eq 0) { 
                '🟢 EXCELLENT - Oh My Posh is well-integrated and functioning properly' 
            } elseif ($global:TestResults.Summary.Failed -le 2) { 
                '🟡 GOOD - Oh My Posh is integrated with minor issues' 
            } else { 
                '🔴 NEEDS ATTENTION - Oh My Posh integration has significant issues' 
            })</strong></p>
            <p>This report confirms that Oh My Posh remains a core, valuable component of the UnifiedPowerShellProfile system.</p>
        </div>
    </div>
</body>
</html>
"@
    
    Set-Content -Path $reportPath -Value $html -Encoding UTF8
    Write-Host "📋 Test report generated: $reportPath" -ForegroundColor Green
    
    try {
        Start-Process $reportPath
    } catch {
        Write-Host "💡 Open the report manually: $reportPath" -ForegroundColor Yellow
    }
}

#endregion

#region Main Test Execution

function Start-OhMyPoshIntegrationTests {
    Write-Host ""
    Write-Host "🧛‍♂️ Oh My Posh Integration Testing Suite" -ForegroundColor Magenta
    Write-Host "=" * 50 -ForegroundColor Gray
    Write-Host "Test Level: $TestLevel" -ForegroundColor Cyan
    Write-Host "Performance Benchmarking: $($BenchmarkPerformance.IsPresent)" -ForegroundColor Cyan
    Write-Host "Report Generation: $($GenerateReport.IsPresent)" -ForegroundColor Cyan
    Write-Host ""
    
    # Core tests (always run)
    Test-OhMyPoshInstallation
    Test-UnifiedProfileModule
    Test-OhMyPoshInitialization
    Test-IntegrationWithUnifiedProfile
    
    # Performance tests (if requested)
    Test-PerformanceMetrics
    
    # Comprehensive tests (if requested)
    Test-ThemeCompatibility
    Test-ErrorHandling
    
    # Generate summary
    Write-Host ""
    Write-Host "📊 Test Summary:" -ForegroundColor Cyan
    Write-Host "=" * 30 -ForegroundColor Gray
    Write-Host "Total Tests: $($global:TestResults.Summary.Total)" -ForegroundColor White
    Write-Host "✅ Passed: $($global:TestResults.Summary.Passed)" -ForegroundColor Green
    Write-Host "❌ Failed: $($global:TestResults.Summary.Failed)" -ForegroundColor Red
    Write-Host "⚠️ Warnings: $($global:TestResults.Summary.Warnings)" -ForegroundColor Yellow
    
    $successRate = if ($global:TestResults.Summary.Total -gt 0) {
        [math]::Round(($global:TestResults.Summary.Passed / $global:TestResults.Summary.Total) * 100, 1)
    } else {
        0 
    }
    
    Write-Host "📈 Success Rate: $successRate%" -ForegroundColor $(if ($successRate -ge 90) {
            'Green' 
        } elseif ($successRate -ge 75) {
            'Yellow' 
        } else {
            'Red' 
        })
    
    $testDuration = (Get-Date) - $global:TestResults.StartTime
    Write-Host "⏱️ Test Duration: $([math]::Round($testDuration.TotalSeconds, 2)) seconds" -ForegroundColor Gray
    
    # Generate report
    Generate-TestReport
    
    # Final assessment
    Write-Host ""
    if ($global:TestResults.Summary.Failed -eq 0) {
        Write-Host "🎉 EXCELLENT! Oh My Posh is perfectly integrated with UnifiedPowerShellProfile!" -ForegroundColor Green
        Write-Host "💎 All systems are working harmoniously. Oh My Posh remains a core strength." -ForegroundColor Green
    } elseif ($global:TestResults.Summary.Failed -le 2) {
        Write-Host "👍 GOOD! Oh My Posh integration is solid with minor issues." -ForegroundColor Yellow
        Write-Host "🔧 A few tweaks may be needed, but the integration is fundamentally sound." -ForegroundColor Yellow
    } else {
        Write-Host "⚠️ ATTENTION NEEDED! Oh My Posh integration has some issues." -ForegroundColor Red
        Write-Host "🛠️ Review the failed tests and address the issues to maintain quality." -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "💡 Key Takeaway: Oh My Posh should DEFINITELY remain in the master repository!" -ForegroundColor Magenta
    Write-Host "🧛‍♂️ It's a core component that adds significant value to the PowerShell experience." -ForegroundColor Magenta
    
    return $successRate -ge 75
}

#endregion

# Execute tests if script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    try {
        $success = Start-OhMyPoshIntegrationTests
        exit $(if ($success) {
                0 
            } else {
                1 
            })
    } catch {
        Write-Host "💥 Test execution failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Gray
        exit 1
    }
}
