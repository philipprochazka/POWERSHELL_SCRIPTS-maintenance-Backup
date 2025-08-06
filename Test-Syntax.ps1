# Syntax check for Dracula profile
$parseErrors = $null
[System.Management.Automation.Language.Parser]::ParseFile('Microsoft.PowerShell_profile_Dracula.ps1', [ref]$null, [ref]$parseErrors)

if ($parseErrors) {
    Write-Host "❌ Syntax errors found:" -ForegroundColor Red
    $parseErrors | ForEach-Object { 
        Write-Host "Line $($_.Extent.StartLineNumber): $($_.Message)" -ForegroundColor Red 
    }
} else {
    Write-Host "✅ Syntax is valid!" -ForegroundColor Green
}
