<#
.SYNOPSIS
    Test script for Enhanced Dracula Profile
.DESCRIPTION
    Tests the Enhanced Dracula Profile with full PSReadLine integration
#>

Write-Host "🧛‍♂️ Testing Enhanced Dracula Profile with PSReadLine Focus" -ForegroundColor Magenta
Write-Host ""

try {
    # Set environment for testing
    $env:DRACULA_SHOW_STARTUP = 'true'
    $env:DRACULA_PERFORMANCE_DEBUG = 'true'
    
    # Load the profile
    $profilePath = Join-Path $PSScriptRoot "Microsoft.PowerShell_profile_Dracula_Enhanced.ps1"
    Write-Host "📍 Loading profile: $profilePath" -ForegroundColor Cyan
    
    if (Test-Path $profilePath) {
        . $profilePath
        Write-Host ""
        Write-Host "✅ Profile loaded successfully!" -ForegroundColor Green
        Write-Host ""
        
        # Test profile functions
        Write-Host "🔍 Testing profile functions:" -ForegroundColor Cyan
        profile-info
        Write-Host ""
        
        Write-Host "🎨 Testing PSReadLine colors:" -ForegroundColor Cyan
        show-colors
        Write-Host ""
        
        Write-Host "📊 PSReadLine Statistics:" -ForegroundColor Cyan
        psrl-stats
        Write-Host ""
        
        Write-Host "🎯 Test completed successfully!" -ForegroundColor Green
        Write-Host "💡 Try typing commands and using Alt+Left/Right for CamelCase navigation" -ForegroundColor Yellow
    } else {
        Write-Host "❌ Profile file not found: $profilePath" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ Error testing profile: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Gray
}
Write-Host "✅ Enhanced Dracula Profile Test Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Test the navigation features by typing these examples:" -ForegroundColor Yellow
Write-Host "   Get-ChildItem -Path C:\Windows" -ForegroundColor Gray
Write-Host "   New-PSSession -ComputerName Server01" -ForegroundColor Gray
Write-Host "   [System.IO.Path]::GetFileName('test.txt')" -ForegroundColor Gray
Write-Host ""
Write-Host "🎮 Use Alt+Left/Right for PascalCase navigation!" -ForegroundColor Magenta
