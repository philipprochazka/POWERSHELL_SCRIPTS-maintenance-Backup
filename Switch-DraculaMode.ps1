#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Switch between different Dracula profile configurations
.DESCRIPTION
    Allows switching between Normal, Performance, and Silent modes for the Dracula PowerShell profile.
    Helps optimize startup time and reduce verbosity based on your needs.
.PARAMETER Mode
    The profile mode to switch to: Normal, Performance, Silent, or Minimal
.PARAMETER ShowStartup
    Whether to show startup messages (Performance mode only)
.PARAMETER NoBackup
    Skip creating backup of current profile
.EXAMPLE
    .\Switch-DraculaMode.ps1 -Mode Performance
.EXAMPLE
    .\Switch-DraculaMode.ps1 -Mode Silent -ShowStartup:$false
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Normal', 'Performance', 'Silent', 'Minimal')]
    [string]$Mode,
    
    [Parameter()]
    [bool]$ShowStartup = $false,
    
    [Parameter()]
    [switch]$NoBackup
)

Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║            🧛‍♂️ DRACULA PROFILE MODE SWITCHER 🧛‍♂️           ║
║              Optimize your PowerShell experience            ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Magenta

$profilePath = $PROFILE.CurrentUserCurrentHost
$backupPath = "$profilePath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"

# Profile file mappings
$profileFiles = @{
    'Normal'      = 'Microsoft.PowerShell_profile_Dracula.ps1'
    'Performance' = 'Microsoft.PowerShell_profile_Dracula_Performance.ps1'
    'Silent'      = 'Microsoft.PowerShell_profile_Dracula_Silent.ps1'
    'Minimal'     = 'Microsoft.PowerShell_profile_Dracula_Minimal.ps1'
}

Write-Host "`n🔄 Switching to $Mode mode..." -ForegroundColor Yellow

try {
    # Create backup if requested
    if (-not $NoBackup -and (Test-Path $profilePath)) {
        Copy-Item $profilePath $backupPath -Force
        Write-Host "✅ Backup created: $backupPath" -ForegroundColor Green
    }
    
    # Set environment variable for startup messages
    if ($Mode -eq 'Performance') {
        [Environment]::SetEnvironmentVariable('DRACULA_SHOW_STARTUP', $ShowStartup.ToString().ToLower(), 'User')
        Write-Host "🔧 Startup messages: $($ShowStartup.ToString().ToLower())" -ForegroundColor Cyan
    }
    
    # Find source profile
    $sourceProfile = Join-Path $PSScriptRoot $profileFiles[$Mode]
    if (-not (Test-Path $sourceProfile)) {
        throw "Source profile not found: $sourceProfile"
    }
    
    # Copy new profile
    $profileDir = Split-Path $profilePath -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    
    Copy-Item $sourceProfile $profilePath -Force
    Write-Host "✅ Profile switched to $Mode mode" -ForegroundColor Green
    
    # Show mode benefits
    Write-Host "`n🎯 $Mode Mode Benefits:" -ForegroundColor Cyan
    switch ($Mode) {
        'Normal' {
            Write-Host "  • Full featured Dracula experience" -ForegroundColor Yellow
            Write-Host "  • All modules loaded at startup" -ForegroundColor Yellow
            Write-Host "  • Complete visual feedback" -ForegroundColor Yellow
            Write-Host "  • Best for: Development and exploration" -ForegroundColor Green
        }
        'Performance' {
            Write-Host "  • Fast startup (~50% faster)" -ForegroundColor Yellow
            Write-Host "  • Lazy module loading" -ForegroundColor Yellow
            Write-Host "  • Minimal verbosity" -ForegroundColor Yellow
            Write-Host "  • Best for: Daily productive work" -ForegroundColor Green
        }
        'Silent' {
            Write-Host "  • Ultra-quiet startup" -ForegroundColor Yellow
            Write-Host "  • No startup messages" -ForegroundColor Yellow
            Write-Host "  • Essential features only" -ForegroundColor Yellow
            Write-Host "  • Best for: Background automation" -ForegroundColor Green
        }
        'Minimal' {
            Write-Host "  • Bare minimum setup" -ForegroundColor Yellow
            Write-Host "  • Fastest possible startup" -ForegroundColor Yellow
            Write-Host "  • Basic Dracula colors only" -ForegroundColor Yellow
            Write-Host "  • Best for: Remote sessions" -ForegroundColor Green
        }
    }
    
    Write-Host "`n🚀 Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Restart PowerShell to apply changes" -ForegroundColor Yellow
    Write-Host "  2. Test the new configuration" -ForegroundColor Yellow
    if ($Mode -eq 'Performance') {
        Write-Host "  3. Use 'load-ext' to load additional modules when needed" -ForegroundColor Yellow
        Write-Host "  4. Use 'help-dracula' to see available commands" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ Error switching profile mode: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n🧛‍♂️ Profile mode successfully changed to $Mode! 🧛‍♂️" -ForegroundColor Magenta
