# ===================================================================
# 🧛‍♂️ QUICK TEST RUNNER FOR DRACULA PROFILE 🧛‍♂️
# Simple script to quickly test the Dracula PowerShell profile
# ===================================================================

Write-Host ""
Write-Host "🧛‍♂️ DRACULA PROFILE QUICK TEST 🧛‍♂️" -ForegroundColor Magenta
Write-Host "=====================================" -ForegroundColor Magenta
Write-Host ""

# Test 1: Profile file exists
Write-Host "🔍 Checking profile file..." -ForegroundColor Cyan
$profilePath = Join-Path $PSScriptRoot "Microsoft.PowerShell_profile_Dracula.ps1"
if (Test-Path $profilePath) {
    Write-Host "   ✅ Profile file found" -ForegroundColor Green
}
else {
    Write-Host "   ❌ Profile file missing!" -ForegroundColor Red
    exit 1
}

# Test 2: Syntax check
Write-Host "🔍 Checking syntax..." -ForegroundColor Cyan
try {
    $null = [System.Management.Automation.Language.Parser]::ParseFile($profilePath, [ref]$null, [ref]$null)
    Write-Host "   ✅ Syntax is valid" -ForegroundColor Green
}
catch {
    Write-Host "   ❌ Syntax error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 3: Quick load test
Write-Host "🔍 Testing profile load..." -ForegroundColor Cyan
$testScript = @"
try {
    . '$profilePath'
    Write-Output "SUCCESS"
} catch {
    Write-Output "ERROR: `$(`$_.Exception.Message)"
}
"@

$result = pwsh -Command $testScript 2>&1
if ($result -like "*SUCCESS*") {
    Write-Host "   ✅ Profile loads successfully" -ForegroundColor Green
}
else {
    Write-Host "   ❌ Profile load failed: $result" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "🎉 Quick test completed successfully!" -ForegroundColor Green
Write-Host "🧪 For comprehensive testing, run: Test-DraculaProfile.ps1" -ForegroundColor Cyan
Write-Host "🚀 To launch with different modes, run: Start-DraculaLauncher.ps1" -ForegroundColor Cyan
Write-Host ""
