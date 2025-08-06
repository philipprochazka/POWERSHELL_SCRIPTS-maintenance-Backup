# Repository Test Script
Write-Host "Running tests for POWERSHELL_SCRIPTS-maintenance-Backup..." -ForegroundColor Green

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$TestsPassed = 0
$TestsFailed = 0

# Test 1: Validate all PowerShell files can be parsed
Write-Host "Test 1: PowerShell Syntax Validation" -ForegroundColor Cyan
Get-ChildItem $RepoRoot -Filter "*.ps1" -Recurse | ForEach-Object {
    try {
        $syntaxErrors = $null
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $_.FullName -Raw), [ref]$syntaxErrors)
        if ($syntaxErrors) {
            Write-Host "  ❌ $($_.Name): $($syntaxErrors.Count) syntax errors" -ForegroundColor Red
            $TestsFailed++
        }
        else {
            Write-Host "  ✅ $($_.Name): OK" -ForegroundColor Green
            $TestsPassed++
        }
    }
    catch {
        Write-Host "  ❌ $($_.Name): Error reading file" -ForegroundColor Red
        $TestsFailed++
    }
}

# Test 2: Check required modules are available
Write-Host "Test 2: Required Modules Check" -ForegroundColor Cyan
$RequiredModules = @('Az.Tools.Predictor', 'Terminal-Icons', 'z', 'PSReadLine')
foreach ($Module in $RequiredModules) {
    if (Get-Module -ListAvailable -Name $Module) {
        Write-Host "  ✅ ${Module}: Available" -ForegroundColor Green
        $TestsPassed++
    }
    else {
        Write-Host "  ❌ ${Module}: Not available" -ForegroundColor Red
        $TestsFailed++
    }
}

# Summary
Write-Host "`nTest Summary:" -ForegroundColor Yellow
Write-Host "  Passed: $TestsPassed" -ForegroundColor Green
Write-Host "  Failed: $TestsFailed" -ForegroundColor Red

if ($TestsFailed -eq 0) {
    Write-Host "All tests passed! 🎉" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "Some tests failed! 😞" -ForegroundColor Red
    exit 1
}
