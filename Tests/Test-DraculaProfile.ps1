# =================================================================== 
# 🧛‍♂️ DRACULA POWERSHELL PROFILE TESTING SCRIPT 🧛‍♂️
# Comprehensive testing suite for the Dracula PowerShell profile
# ===================================================================

param(
    [switch]$Verbose,
    [switch]$SkipModuleTests,
    [switch]$SkipThemeTests,
    [switch]$GenerateReport
)

# Initialize test results
$testResults = @{
    Passed  = 0
    Failed  = 0
    Skipped = 0
    Tests   = @()
}

function Write-TestResult {
    param(
        [string]$TestName,
        [bool]$Passed,
        [string]$Message = "",
        [string]$Details = ""
    )
    
    $result = @{
        Name      = $TestName
        Passed    = $Passed
        Message   = $Message
        Details   = $Details
        Timestamp = Get-Date
    }
    
    $testResults.Tests += $result
    
    if ($Passed) {
        $testResults.Passed++
        Write-Host "✅ $TestName" -ForegroundColor Green
        if ($Message) { Write-Host "   $Message" -ForegroundColor Gray }
    }
    else {
        $testResults.Failed++
        Write-Host "❌ $TestName" -ForegroundColor Red
        if ($Message) { Write-Host "   $Message" -ForegroundColor Yellow }
        if ($Details) { Write-Host "   Details: $Details" -ForegroundColor Gray }
    }
}

function Test-ProfileStructure {
    Write-Host "`n🔍 Testing Profile Structure..." -ForegroundColor Cyan
    
    # Test main profile file
    $profilePath = Join-Path $PSScriptRoot "..\Microsoft.PowerShell_profile_Dracula.ps1"
    $exists = Test-Path $profilePath
    Write-TestResult "Main Profile File Exists" $exists "Path: $profilePath"
    
    # Test theme files
    $themePath = Join-Path $PSScriptRoot "..\Theme"
    $themeExists = Test-Path $themePath
    Write-TestResult "Theme Directory Exists" $themeExists "Path: $themePath"
    
    if ($themeExists) {
        $draculaTheme = Join-Path $themePath "dracula.omp.json"
        $enhancedTheme = Join-Path $themePath "dracula-enhanced.omp.json"
        $powerPack = Join-Path $themePath "DraculaPowerPack.psm1"
        $psReadLine = Join-Path $themePath "PSReadLine-Dracula-Enhanced.ps1"
        
        Write-TestResult "Dracula Theme File" (Test-Path $draculaTheme)
        Write-TestResult "Enhanced Theme File" (Test-Path $enhancedTheme)
        Write-TestResult "PowerPack Module" (Test-Path $powerPack)
        Write-TestResult "PSReadLine Config" (Test-Path $psReadLine)
    }
}

function Test-ProfileSyntax {
    Write-Host "`n📝 Testing Profile Syntax..." -ForegroundColor Cyan
    
    $profilePath = Join-Path $PSScriptRoot "..\Microsoft.PowerShell_profile_Dracula.ps1"
    
    try {
        $null = [System.Management.Automation.Language.Parser]::ParseFile(
            $profilePath, 
            [ref]$null, 
            [ref]$null
        )
        Write-TestResult "Profile Syntax Valid" $true "No parse errors found"
    }
    catch {
        Write-TestResult "Profile Syntax Valid" $false "Parse error: $($_.Exception.Message)"
    }
}

function Test-RequiredModules {
    if ($SkipModuleTests) {
        Write-Host "`n⏭️  Skipping Module Tests..." -ForegroundColor Yellow
        return
    }
    
    Write-Host "`n📦 Testing Required Modules..." -ForegroundColor Cyan
    
    $requiredModules = @(
        'PSReadLine',
        'Terminal-Icons',
        'z',
        'Az.Tools.Predictor',
        'CompletionPredictor'
    )
    
    foreach ($module in $requiredModules) {
        $available = Get-Module -ListAvailable -Name $module
        if ($available) {
            Write-TestResult "Module Available: $module" $true "Version: $($available[0].Version)"
        }
        else {
            Write-TestResult "Module Available: $module" $false "Module not found"
        }
    }
}

function Test-ThemeFiles {
    if ($SkipThemeTests) {
        Write-Host "`n⏭️  Skipping Theme Tests..." -ForegroundColor Yellow
        return
    }
    
    Write-Host "`n🎨 Testing Theme Files..." -ForegroundColor Cyan
    
    $themePath = Join-Path $PSScriptRoot "..\Theme"
    
    # Test JSON theme files
    $jsonFiles = @("dracula.omp.json", "dracula-enhanced.omp.json")
    foreach ($file in $jsonFiles) {
        $filePath = Join-Path $themePath $file
        if (Test-Path $filePath) {
            try {
                $content = Get-Content $filePath -Raw | ConvertFrom-Json
                Write-TestResult "Theme JSON Valid: $file" $true "JSON structure is valid"
            }
            catch {
                Write-TestResult "Theme JSON Valid: $file" $false "Invalid JSON: $($_.Exception.Message)"
            }
        }
    }
    
    # Test PowerPack module
    $powerPackPath = Join-Path $themePath "DraculaPowerPack.psm1"
    if (Test-Path $powerPackPath) {
        try {
            $null = [System.Management.Automation.Language.Parser]::ParseFile(
                $powerPackPath, 
                [ref]$null, 
                [ref]$null
            )
            Write-TestResult "PowerPack Module Syntax" $true "No syntax errors"
        }
        catch {
            Write-TestResult "PowerPack Module Syntax" $false "Syntax error: $($_.Exception.Message)"
        }
    }
}

function Test-ProfileFunctions {
    Write-Host "`n🛠️  Testing Profile Functions..." -ForegroundColor Cyan
    
    # Source the profile in a temporary scope
    try {
        $profilePath = Join-Path $PSScriptRoot "..\Microsoft.PowerShell_profile_Dracula.ps1"
        
        # Create a new PowerShell process to test loading
        $testScript = @"
try {
    . '$profilePath'
    Write-Output "PROFILE_LOADED_SUCCESS"
} catch {
    Write-Output "PROFILE_LOAD_ERROR: `$(`$_.Exception.Message)"
}
"@
        
        $result = powershell -Command $testScript 2>&1
        
        if ($result -like "*PROFILE_LOADED_SUCCESS*") {
            Write-TestResult "Profile Loads Successfully" $true "Profile loaded without errors"
        }
        else {
            Write-TestResult "Profile Loads Successfully" $false "Load error: $result"
        }
    }
    catch {
        Write-TestResult "Profile Loads Successfully" $false "Exception: $($_.Exception.Message)"
    }
}

function Test-Aliases {
    Write-Host "`n🔗 Testing Aliases..." -ForegroundColor Cyan
    
    $expectedAliases = @(
        'colors', 'quote', 'demo', 'sysinfo', 'cleanup', 'newscript',
        'ls', 'l', 'll', 'la', 'tree', 'which', 'edit',
        'g', 'd', 'k', 'tf', 'gs', 'help-dracula'
    )
    
    # Test aliases in a clean PowerShell session
    $testScript = @"
. '$PSScriptRoot\..\Microsoft.PowerShell_profile_Dracula.ps1'
`$aliases = Get-Alias | Select-Object -ExpandProperty Name
foreach (`$alias in @('$($expectedAliases -join "','")')) {
    if (`$aliases -contains `$alias) {
        Write-Output "ALIAS_EXISTS:`$alias"
    } else {
        Write-Output "ALIAS_MISSING:`$alias"
    }
}
"@
    
    try {
        $results = powershell -Command $testScript 2>&1
        
        foreach ($alias in $expectedAliases) {
            $found = $results -like "*ALIAS_EXISTS:$alias*"
            Write-TestResult "Alias: $alias" $found
        }
    }
    catch {
        Write-TestResult "Alias Testing" $false "Failed to test aliases: $($_.Exception.Message)"
    }
}

function Test-Performance {
    Write-Host "`n⚡ Testing Performance..." -ForegroundColor Cyan
    
    $iterations = 3
    $loadTimes = @()
    
    for ($i = 1; $i -le $iterations; $i++) {
        $testScript = @"
`$start = Get-Date
. '$PSScriptRoot\..\Microsoft.PowerShell_profile_Dracula.ps1'
`$end = Get-Date
(`$end - `$start).TotalMilliseconds
"@
        
        try {
            $loadTime = powershell -Command $testScript 2>$null
            if ($loadTime -match '^\d+(\.\d+)?$') {
                $loadTimes += [double]$loadTime
            }
        }
        catch {
            # Ignore errors for performance testing
        }
    }
    
    if ($loadTimes.Count -gt 0) {
        $avgTime = ($loadTimes | Measure-Object -Average).Average
        $maxTime = ($loadTimes | Measure-Object -Maximum).Maximum
        
        Write-TestResult "Profile Load Performance" ($avgTime -lt 2000) "Avg: $([math]::Round($avgTime, 2))ms, Max: $([math]::Round($maxTime, 2))ms"
    }
    else {
        Write-TestResult "Profile Load Performance" $false "Could not measure load times"
    }
}

function Generate-TestReport {
    if (-not $GenerateReport) { return }
    
    Write-Host "`n📊 Generating Test Report..." -ForegroundColor Cyan
    
    $reportPath = Join-Path $PSScriptRoot "TestReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
    
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>🧛‍♂️ Dracula PowerShell Profile Test Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #282a36; color: #f8f8f2; margin: 20px; }
        .header { background: #44475a; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
        .summary { display: flex; gap: 20px; margin-bottom: 20px; }
        .metric { background: #44475a; padding: 15px; border-radius: 8px; text-align: center; flex: 1; }
        .passed { color: #50fa7b; }
        .failed { color: #ff5555; }
        .skipped { color: #ffb86c; }
        .test-results { background: #44475a; padding: 20px; border-radius: 8px; }
        .test-item { padding: 10px; border-bottom: 1px solid #6272a4; }
        .test-item:last-child { border-bottom: none; }
        .test-name { font-weight: bold; }
        .test-details { font-size: 0.9em; color: #6272a4; margin-top: 5px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🧛‍♂️ Dracula PowerShell Profile Test Report</h1>
        <p>Generated on: $(Get-Date)</p>
    </div>
    
    <div class="summary">
        <div class="metric">
            <h3 class="passed">$($testResults.Passed)</h3>
            <p>Passed</p>
        </div>
        <div class="metric">
            <h3 class="failed">$($testResults.Failed)</h3>
            <p>Failed</p>
        </div>
        <div class="metric">
            <h3 class="skipped">$($testResults.Skipped)</h3>
            <p>Skipped</p>
        </div>
    </div>
    
    <div class="test-results">
        <h2>Test Results</h2>
"@
    
    foreach ($test in $testResults.Tests) {
        $statusClass = if ($test.Passed) { "passed" } else { "failed" }
        $statusIcon = if ($test.Passed) { "✅" } else { "❌" }
        
        $html += @"
        <div class="test-item">
            <div class="test-name $statusClass">$statusIcon $($test.Name)</div>
            <div class="test-details">
                $(if ($test.Message) { "<p><strong>Message:</strong> $($test.Message)</p>" })
                $(if ($test.Details) { "<p><strong>Details:</strong> $($test.Details)</p>" })
                <p><strong>Timestamp:</strong> $($test.Timestamp)</p>
            </div>
        </div>
"@
    }
    
    $html += @"
    </div>
</body>
</html>
"@
    
    $html | Out-File -FilePath $reportPath -Encoding UTF8
    Write-Host "📄 Test report saved to: $reportPath" -ForegroundColor Green
}

# Main execution
Write-Host "🧛‍♂️ DRACULA POWERSHELL PROFILE TESTING 🧛‍♂️" -ForegroundColor Magenta
Write-Host "=============================================" -ForegroundColor Magenta

Test-ProfileStructure
Test-ProfileSyntax
Test-RequiredModules
Test-ThemeFiles
Test-ProfileFunctions
Test-Aliases
Test-Performance

Write-Host "`n📊 Test Summary:" -ForegroundColor Cyan
Write-Host "✅ Passed: $($testResults.Passed)" -ForegroundColor Green
Write-Host "❌ Failed: $($testResults.Failed)" -ForegroundColor Red
Write-Host "⏭️  Skipped: $($testResults.Skipped)" -ForegroundColor Yellow

Generate-TestReport

if ($testResults.Failed -eq 0) {
    Write-Host "`n🎉 All tests passed! The Dracula profile is ready for the night! 🧛‍♂️" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "`n⚠️  Some tests failed. Check the results above for details." -ForegroundColor Yellow
    exit 1
}
