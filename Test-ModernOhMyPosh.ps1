<#
.SYNOPSIS
    Test script for Modern Oh My Posh v26+ integration with PowerShell profiles

.DESCRIPTION
    Comprehensive testing script that validates Oh My Posh v26+ installation,
    theme loading, and integration with the enhanced PowerShell profiles.

.PARAMETER TestMode
    The type of test to run (Quick, Standard, Comprehensive)

.PARAMETER GenerateReport
    Generate an HTML test report

.EXAMPLE
    .\Test-ModernOhMyPosh.ps1 -TestMode Quick

.EXAMPLE
    .\Test-ModernOhMyPosh.ps1 -TestMode Comprehensive -GenerateReport
#>

[CmdletBinding()]
param(
    [ValidateSet('Quick', 'Standard', 'Comprehensive')]
    [string]$TestMode = 'Standard',
    
    [switch]$GenerateReport
)

# Import the modern initialization script
$modernInitPath = Join-Path $PSScriptRoot "PowerShellModules\UnifiedPowerShellProfile\Scripts\Initialize-ModernOhMyPosh.ps1"
if (Test-Path $modernInitPath) {
    . $modernInitPath
} else {
    Write-Warning "Modern Oh My Posh initialization script not found: $modernInitPath"
}

function Write-TestResult {
    param(
        [string]$TestName,
        [bool]$Passed,
        [string]$Details = "",
        [object]$Data = $null
    )
    
    $status = if ($Passed) {
        "✅ PASS" 
    } else {
        "❌ FAIL" 
    }
    $color = if ($Passed) {
        "Green" 
    } else {
        "Red" 
    }
    
    Write-Host "$status - $TestName" -ForegroundColor $color
    if ($Details) {
        Write-Host "    $Details" -ForegroundColor Gray
    }
    
    # Store for report generation
    if (-not $global:TestResults) {
        $global:TestResults = @()
    }
    
    $global:TestResults += @{
        TestName  = $TestName
        Passed    = $Passed
        Details   = $Details
        Data      = $Data
        Timestamp = Get-Date
    }
}

function Test-OhMyPoshInstallation {
    Write-Host "`n🔍 Testing Oh My Posh Installation..." -ForegroundColor Cyan
    
    # Test 1: Command availability
    $ohMyPoshCmd = Get-Command oh-my-posh -ErrorAction SilentlyContinue
    Write-TestResult "Oh My Posh Command Available" ($null -ne $ohMyPoshCmd) $(if ($ohMyPoshCmd) {
            $ohMyPoshCmd.Source 
        })
    
    if (-not $ohMyPoshCmd) {
        return $false
    }
    
    # Test 2: Version detection
    try {
        $versionOutput = & oh-my-posh version 2>$null
        $versionMatched = $versionOutput -match "(\d+)\.(\d+)\.(\d+)"
        $version = if ($versionMatched) {
            "$($matches[1]).$($matches[2]).$($matches[3])" 
        } else {
            "Unknown" 
        }
        $isModern = $versionMatched -and ([int]$matches[1] -ge 26)
        
        Write-TestResult "Version Detection" $versionMatched "Version: $version"
        Write-TestResult "Modern Version (v26+)" $isModern "Is Modern: $isModern"
        
    } catch {
        Write-TestResult "Version Detection" $false "Error: $($_.Exception.Message)"
        return $false
    }
    
    # Test 3: Basic initialization
    try {
        $testTheme = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/pure.omp.json"
        $initScript = & oh-my-posh init pwsh --config $testTheme 2>$null
        $initWorking = $initScript -and $initScript.Length -gt 10
        
        Write-TestResult "Basic Initialization" $initWorking $(if ($initWorking) {
                "Script length: $($initScript.Length) chars" 
            })
        
    } catch {
        Write-TestResult "Basic Initialization" $false "Error: $($_.Exception.Message)"
    }
    
    return $true
}

function Test-ModernInitializationFunction {
    Write-Host "`n🚀 Testing Modern Initialization Functions..." -ForegroundColor Cyan
    
    # Test 1: Function availability
    $functionsAvailable = @(
        'Initialize-ModernOhMyPosh',
        'Get-OhMyPoshThemePath',
        'Install-ModernOhMyPosh'
    )
    
    foreach ($funcName in $functionsAvailable) {
        $funcExists = Get-Command $funcName -ErrorAction SilentlyContinue
        Write-TestResult "Function: $funcName" ($null -ne $funcExists)
    }
    
    # Test 2: Theme path resolution
    try {
        $draculaPath = Get-OhMyPoshThemePath -Mode "Dracula"
        Write-TestResult "Theme Path Resolution (Dracula)" ($null -ne $draculaPath) "Path: $draculaPath"
        
        $performancePath = Get-OhMyPoshThemePath -Mode "Performance"
        Write-TestResult "Theme Path Resolution (Performance)" ($null -ne $performancePath) "Path: $performancePath"
        
    } catch {
        Write-TestResult "Theme Path Resolution" $false "Error: $($_.Exception.Message)"
    }
    
    # Test 3: Modern initialization (non-destructive)
    try {
        # Save current prompt
        $originalPrompt = Get-Content Function:\prompt -ErrorAction SilentlyContinue
        
        $initResult = Initialize-ModernOhMyPosh -Mode "Dracula" -Verbose
        Write-TestResult "Modern Initialization (Dracula)" $initResult
        
        # Restore original prompt if needed
        if ($originalPrompt) {
            Set-Content Function:\prompt $originalPrompt
        }
        
    } catch {
        Write-TestResult "Modern Initialization" $false "Error: $($_.Exception.Message)"
    }
}

function Test-ProfileIntegration {
    Write-Host "`n📋 Testing Profile Integration..." -ForegroundColor Cyan
    
    $profiles = @(
        @{ Name = "Dracula Main"; Path = "Microsoft.PowerShell_profile_Dracula.ps1" },
        @{ Name = "Dracula Performance"; Path = "Microsoft.PowerShell_profile_Dracula_Performance.ps1" },
        @{ Name = "Unified Profile Theme Script"; Path = "PowerShellModules\UnifiedPowerShellProfile\Scripts\Initialize-ProfileTheme.ps1" }
    )
    
    foreach ($profile in $profiles) {
        $profilePath = Join-Path $PSScriptRoot $profile.Path
        
        if (Test-Path $profilePath) {
            $content = Get-Content $profilePath -Raw
            
            # Check for modern integration
            $hasModernInit = $content -like "*Initialize-ModernOhMyPosh*"
            $hasLegacyFallback = $content -like "*oh-my-posh init*"
            
            Write-TestResult "$($profile.Name) - Modern Integration" $hasModernInit
            Write-TestResult "$($profile.Name) - Legacy Fallback" $hasLegacyFallback
            
            # Syntax validation
            try {
                $null = [System.Management.Automation.Language.Parser]::ParseFile($profilePath, [ref]$null, [ref]$null)
                Write-TestResult "$($profile.Name) - Syntax Valid" $true
            } catch {
                Write-TestResult "$($profile.Name) - Syntax Valid" $false "Error: $($_.Exception.Message)"
            }
        } else {
            Write-TestResult "$($profile.Name) - File Exists" $false "Path: $profilePath"
        }
    }
}

function Test-ThemeAvailability {
    Write-Host "`n🎨 Testing Theme Availability..." -ForegroundColor Cyan
    
    $themesToTest = @(
        @{ Name = "Dracula Enhanced"; Path = "Theme\dracula-enhanced.omp.json" },
        @{ Name = "Dracula Original"; Path = "Theme\dracula.omp.json" },
        @{ Name = "Performance Theme"; Path = "Theme\dracula-performance.omp.json" }
    )
    
    foreach ($theme in $themesToTest) {
        $themePath = Join-Path $PSScriptRoot $theme.Path
        $exists = Test-Path $themePath
        
        if ($exists) {
            try {
                # Test JSON validity
                $themeContent = Get-Content $themePath -Raw | ConvertFrom-Json
                $isValidTheme = $themeContent -and $themeContent.PSObject.Properties['version']
                
                Write-TestResult "$($theme.Name) - Available" $exists "Path: $themePath"
                Write-TestResult "$($theme.Name) - Valid JSON" $isValidTheme
                
            } catch {
                Write-TestResult "$($theme.Name) - Valid JSON" $false "Parse error: $($_.Exception.Message)"
            }
        } else {
            Write-TestResult "$($theme.Name) - Available" $false "Path: $themePath"
        }
    }
    
    # Test remote theme accessibility (in comprehensive mode)
    if ($TestMode -eq 'Comprehensive') {
        $remoteThemes = @(
            "https://raw.githubusercontent.com/philipprochazka/oh-my-posh/main/themes/dracula.omp.json",
            "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/dracula.omp.json"
        )
        
        foreach ($remoteTheme in $remoteThemes) {
            try {
                $response = Invoke-WebRequest -Uri $remoteTheme -Method Head -TimeoutSec 10 -ErrorAction Stop
                $accessible = $response.StatusCode -eq 200
                Write-TestResult "Remote Theme Accessible" $accessible "URL: $remoteTheme"
            } catch {
                Write-TestResult "Remote Theme Accessible" $false "URL: $remoteTheme - Error: $($_.Exception.Message)"
            }
        }
    }
}

function Test-PerformanceMetrics {
    Write-Host "`n⚡ Testing Performance Metrics..." -ForegroundColor Cyan
    
    if ($TestMode -in @('Standard', 'Comprehensive')) {
        # Test initialization speed
        $iterations = if ($TestMode -eq 'Comprehensive') {
            5 
        } else {
            3 
        }
        $initTimes = @()
        
        for ($i = 1; $i -le $iterations; $i++) {
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            try {
                $draculaPath = Get-OhMyPoshThemePath -Mode "Dracula"
                if ($draculaPath) {
                    # Simulate initialization (don't actually change prompt)
                    $initScript = & oh-my-posh init pwsh --config $draculaPath 2>$null
                }
                $stopwatch.Stop()
                $initTimes += $stopwatch.ElapsedMilliseconds
            } catch {
                $stopwatch.Stop()
                Write-TestResult "Performance Test $i" $false "Error: $($_.Exception.Message)"
            }
        }
        
        if ($initTimes.Count -gt 0) {
            $avgTime = [math]::Round(($initTimes | Measure-Object -Average).Average, 2)
            $maxTime = ($initTimes | Measure-Object -Maximum).Maximum
            $minTime = ($initTimes | Measure-Object -Minimum).Minimum
            
            $performanceGood = $avgTime -lt 1000  # Less than 1 second average
            
            Write-TestResult "Average Initialization Time" $performanceGood "Avg: ${avgTime}ms (Min: ${minTime}ms, Max: ${maxTime}ms)"
        }
    }
}

function Generate-TestReport {
    if (-not $GenerateReport -or -not $global:TestResults) {
        return
    }
    
    Write-Host "`n📊 Generating Test Report..." -ForegroundColor Cyan
    
    $reportPath = Join-Path $PSScriptRoot "TestReport_ModernOhMyPosh_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
    
    $passed = ($global:TestResults | Where-Object { $_.Passed }).Count
    $total = $global:TestResults.Count
    $passRate = [math]::Round(($passed / $total) * 100, 1)
    
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Modern Oh My Posh Test Report</title>
    <style>
        body { font-family: 'Segoe UI', Arial, sans-serif; margin: 20px; background: #1e1e2e; color: #f8f8f2; }
        .header { background: #6272a4; color: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .summary { background: #44475a; padding: 15px; border-radius: 8px; margin-bottom: 20px; }
        .test-pass { color: #50fa7b; }
        .test-fail { color: #ff5555; }
        .test-item { padding: 10px; margin: 5px 0; background: #282a36; border-radius: 4px; border-left: 4px solid #6272a4; }
        .test-item.pass { border-left-color: #50fa7b; }
        .test-item.fail { border-left-color: #ff5555; }
        .details { font-size: 0.9em; color: #8be9fd; margin-top: 5px; }
        .timestamp { color: #6272a4; font-size: 0.8em; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 Modern Oh My Posh v26+ Test Report</h1>
        <p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
        <p>Test Mode: $TestMode</p>
    </div>
    
    <div class="summary">
        <h2>📊 Summary</h2>
        <p><strong>Pass Rate:</strong> $passRate% ($passed/$total tests passed)</p>
        <p><strong>System:</strong> $env:COMPUTERNAME</p>
        <p><strong>PowerShell:</strong> $($PSVersionTable.PSVersion)</p>
    </div>
    
    <div class="test-results">
        <h2>🧪 Test Results</h2>
"@

    foreach ($test in $global:TestResults) {
        $cssClass = if ($test.Passed) {
            'pass' 
        } else {
            'fail' 
        }
        $icon = if ($test.Passed) {
            '✅' 
        } else {
            '❌' 
        }
        
        $html += @"
        <div class="test-item $cssClass">
            <strong>$icon $($test.TestName)</strong>
            $(if ($test.Details) { "<div class='details'>$($test.Details)</div>" })
            <div class="timestamp">$($test.Timestamp.ToString('HH:mm:ss'))</div>
        </div>
"@
    }
    
    $html += @"
    </div>
</body>
</html>
"@
    
    $html | Out-File -FilePath $reportPath -Encoding UTF8
    Write-Host "📄 Test report generated: $reportPath" -ForegroundColor Green
    
    # Optionally open the report
    if ((Get-Command Start-Process -ErrorAction SilentlyContinue) -and $env:OS -like "*Windows*") {
        Start-Process $reportPath
    }
}

# Main test execution
try {
    Write-Host ""
    Write-Host "🧪 Modern Oh My Posh v26+ Integration Test Suite" -ForegroundColor Magenta
    Write-Host "================================================" -ForegroundColor Magenta
    Write-Host "Test Mode: $TestMode" -ForegroundColor Yellow
    Write-Host ""
    
    $global:TestResults = @()
    
    # Core tests
    Test-OhMyPoshInstallation
    Test-ModernInitializationFunction
    Test-ProfileIntegration
    Test-ThemeAvailability
    
    # Performance tests (Standard and Comprehensive modes)
    if ($TestMode -in @('Standard', 'Comprehensive')) {
        Test-PerformanceMetrics
    }
    
    # Generate report
    Generate-TestReport
    
    # Summary
    $passed = ($global:TestResults | Where-Object { $_.Passed }).Count
    $total = $global:TestResults.Count
    $passRate = [math]::Round(($passed / $total) * 100, 1)
    
    Write-Host ""
    Write-Host "📊 Test Summary:" -ForegroundColor Cyan
    Write-Host "   Total Tests: $total" -ForegroundColor Gray
    Write-Host "   Passed: $passed" -ForegroundColor Green
    Write-Host "   Failed: $($total - $passed)" -ForegroundColor Red
    Write-Host "   Pass Rate: $passRate%" -ForegroundColor $(if ($passRate -ge 80) {
            'Green' 
        } else {
            'Yellow' 
        })
    Write-Host ""
    
    if ($passRate -ge 80) {
        Write-Host "✅ Modern Oh My Posh integration is working well!" -ForegroundColor Green
    } elseif ($passRate -ge 60) {
        Write-Host "⚠️  Modern Oh My Posh integration has some issues" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Modern Oh My Posh integration needs attention" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Test execution failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
