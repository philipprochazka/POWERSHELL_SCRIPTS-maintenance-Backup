# Debug Profile Syntax Script
param(
    [string]$ProfilePath = "c:\backup\Powershell\Microsoft.PowerShell_profile_Dracula_Performance.ps1"
)

Write-Host "🔍 Checking syntax for: $ProfilePath" -ForegroundColor Cyan
Write-Host ""

# Parse the file
$errors = @()
$ast = [System.Management.Automation.Language.Parser]::ParseFile($ProfilePath, [ref]$null, [ref]$errors)

if ($errors.Count -gt 0) {
    Write-Host "❌ Syntax Errors Found:" -ForegroundColor Red
    foreach ($error in $errors) {
        Write-Host "  Line $($error.Extent.StartLineNumber):$($error.Extent.StartColumnNumber) - $($error.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "✅ No syntax errors found!" -ForegroundColor Green
    
    # Try to load the profile
    Write-Host ""
    Write-Host "🔄 Testing profile load..." -ForegroundColor Yellow
    try {
        . $ProfilePath
        Write-Host "✅ Profile loaded successfully!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Profile load failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}
