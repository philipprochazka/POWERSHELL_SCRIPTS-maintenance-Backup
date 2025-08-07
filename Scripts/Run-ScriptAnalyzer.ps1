#requires -Version 5.1
<#
.SYNOPSIS
    🔍 PSScriptAnalyzer Runner for PowerShell Projects

.DESCRIPTION
    Runs PSScriptAnalyzer against PowerShell files in the workspace.
    Follows coding standards from copilot-instructions.md.

.PARAMETER Path
    Root path to analyze. Defaults to current directory.

.PARAMETER Settings
    PSScriptAnalyzer settings preset. Valid options: PSGallery, CodeFormatting, ScriptSecurity

.PARAMETER Recurse
    Analyze files recursively in subdirectories

.PARAMETER Fix
    Automatically fix issues that can be corrected

.EXAMPLE
    .\Run-ScriptAnalyzer.ps1
    Analyzes current directory with PSGallery settings

.EXAMPLE
    .\Run-ScriptAnalyzer.ps1 -Path "C:\Projects" -Settings CodeFormatting -Fix
    Analyzes specific path with code formatting rules and auto-fixes issues

.NOTES
    Author: GitHub Copilot
    Version: 1.0.0
    Follows PowerShell approved verbs and naming conventions
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]$Path = $PWD,
    
    [Parameter()]
    [ValidateSet('PSGallery', 'CodeFormatting', 'ScriptSecurity')]
    [string]$Settings = 'PSGallery',
    
    [Parameter()]
    [switch]$Recurse,
    
    [Parameter()]
    [switch]$Fix
)

begin {
    Write-Host "🔍 POWERSHELL SCRIPT ANALYZER 🔍" -ForegroundColor Cyan
    Write-Host "=" * 50 -ForegroundColor Gray
    
    # Install PSScriptAnalyzer if not available
    if (-not (Get-Module PSScriptAnalyzer -ListAvailable)) {
        Write-Host "📦 Installing PSScriptAnalyzer module..." -ForegroundColor Yellow
        try {
            Install-Module PSScriptAnalyzer -Force -Scope CurrentUser
            Write-Host "✅ PSScriptAnalyzer installed successfully" -ForegroundColor Green
        }
        catch {
            Write-Error "❌ Failed to install PSScriptAnalyzer: $($_.Exception.Message)"
            exit 1
        }
    }
}

process {
    try {
        # Discover PowerShell files
        $filter = if ($Recurse) { "*.ps1", "*.psm1", "*.psd1" } else { "*.ps1" }
        $files = Get-ChildItem -Path $Path -Include $filter -Recurse:$Recurse.IsPresent
        
        if ($files.Count -eq 0) {
            Write-Warning "⚠️ No PowerShell files found in path: $Path"
            return
        }
        
        Write-Host "🔍 Found $($files.Count) PowerShell file(s) to analyze" -ForegroundColor Green
        
        # Configure analyzer parameters
        $analyzerParams = @{
            Path = $Path
            Settings = $Settings
            Recurse = $Recurse.IsPresent
        }
        
        if ($Fix) {
            $analyzerParams.Fix = $true
            Write-Host "🔧 Auto-fix mode enabled" -ForegroundColor Yellow
        }
        
        Write-Host "⚙️ Using settings: $Settings" -ForegroundColor Gray
        Write-Host "`n🚀 Running analysis..." -ForegroundColor Cyan
        
        # Run analysis
        $results = Invoke-ScriptAnalyzer @analyzerParams
        
        # Process results
        if ($results) {
            Write-Host "`n📊 ANALYSIS RESULTS:" -ForegroundColor Cyan
            
            # Group by severity
            $grouped = $results | Group-Object Severity
            foreach ($group in $grouped) {
                $color = switch ($group.Name) {
                    'Error' { 'Red' }
                    'Warning' { 'Yellow' }
                    'Information' { 'Cyan' }
                    default { 'Gray' }
                }
                Write-Host "   $($group.Name): $($group.Count)" -ForegroundColor $color
            }
            
            Write-Host "`n📋 DETAILED ISSUES:" -ForegroundColor Cyan
            foreach ($result in $results) {
                $color = switch ($result.Severity) {
                    'Error' { 'Red' }
                    'Warning' { 'Yellow' }
                    'Information' { 'Cyan' }
                    default { 'Gray' }
                }
                
                $file = $result.ScriptName | Split-Path -Leaf
                Write-Host "   [$($result.Severity)] $file : Line $($result.Line) - $($result.Message)" -ForegroundColor $color
                Write-Host "      Rule: $($result.RuleName)" -ForegroundColor Gray
            }
            
            if ($results | Where-Object Severity -eq 'Error') {
                Write-Host "`n❌ Critical issues found!" -ForegroundColor Red
                exit 1
            } else {
                Write-Host "`n✅ Analysis completed successfully" -ForegroundColor Green
            }
        } else {
            Write-Host "✅ No issues found!" -ForegroundColor Green
        }
    }
    catch {
        Write-Error "❌ Script analysis failed: $($_.Exception.Message)"
        exit 1
    }
}

end {
    Write-Host "🎯 Script analysis completed" -ForegroundColor Cyan
}
