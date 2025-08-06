$ErrorActionPreference = 'Stop'
try {
    Write-Host "Testing MCP Profile syntax..." -ForegroundColor Cyan
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile(
        'c:\backup\Powershell\Microsoft.PowerShell_profile_MCP.ps1', 
        [ref]$null, 
        [ref]$errors
    )
    
    if ($errors -and $errors.Count -gt 0) {
        Write-Host "❌ Syntax Errors Found:" -ForegroundColor Red
        foreach ($error in $errors) {
            Write-Host "  Line $($error.Extent.StartLineNumber): $($error.Message)" -ForegroundColor Yellow
        }
        exit 1
    } else {
        Write-Host "✅ Syntax is valid!" -ForegroundColor Green
        Write-Host "🔄 Now testing profile loading..." -ForegroundColor Cyan
        
        # Test loading the profile
        . 'c:\backup\Powershell\Microsoft.PowerShell_profile_MCP.ps1'
        Write-Host "✅ Profile loaded successfully!" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Error testing profile:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    exit 1
}
