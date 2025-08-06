#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Quick Start - Unified PowerShell Profile System
    
.DESCRIPTION
    One-command startup script for the Unified PowerShell Profile system.
    Sets up everything needed for your integrated PowerShell development environment.
    
.PARAMETER Quick
    Perform a quick setup with default settings
    
.PARAMETER Full
    Perform a full setup with all options
    
.PARAMETER Interactive
    Interactive setup with menu choices
    
.EXAMPLE
    .\Start-UnifiedProfile.ps1 -Quick
    
.EXAMPLE
    .\Start-UnifiedProfile.ps1 -Full
    
.EXAMPLE
    .\Start-UnifiedProfile.ps1 -Interactive
#>

[CmdletBinding(DefaultParameterSetName = 'Interactive')]
param(
    [Parameter(ParameterSetName = 'Quick')]
    [switch]$Quick,
    
    [Parameter(ParameterSetName = 'Full')]
    [switch]$Full,
    
    [Parameter(ParameterSetName = 'Interactive')]
    [switch]$Interactive
)

Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║                🚀 UNIFIED POWERSHELL PROFILE 🚀             ║
║              Portable Multi-Repository System               ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Magenta

if ($Quick) {
    Write-Host "`n⚡ Quick Setup Mode" -ForegroundColor Yellow
    Write-Host "Setting up with default configuration (Dracula mode)..." -ForegroundColor Gray
    
    & "$PSScriptRoot\Install-UnifiedProfile.ps1" -Mode Dracula -SetupVSCode -InstallDependencies -ConfigureSystemProfile
}
elseif ($Full) {
    Write-Host "`n🔧 Full Setup Mode" -ForegroundColor Yellow
    Write-Host "Complete installation with all features..." -ForegroundColor Gray
    
    & "$PSScriptRoot\Install-UnifiedProfile.ps1" -Mode Dracula -SetupVSCode -InstallDependencies -ConfigureSystemProfile -Force
}
else {
    # Interactive mode
    Write-Host "`n🎯 Interactive Setup" -ForegroundColor Cyan
    Write-Host "Choose your configuration options:`n" -ForegroundColor Gray
    
    # Profile mode selection
    Write-Host "Available Profile Modes:" -ForegroundColor White
    Write-Host "  1. 🧛‍♂️ Dracula - Enhanced theme with productivity features (Recommended)" -ForegroundColor White
    Write-Host "  2. 🚀 MCP - Model Context Protocol with AI integration" -ForegroundColor White
    Write-Host "  3. ⚡ LazyAdmin - System administration utilities" -ForegroundColor White
    Write-Host "  4. 🎯 Minimal - Lightweight setup" -ForegroundColor White
    Write-Host "  5. 🛠️ Custom - User-defined configuration" -ForegroundColor White
    
    $modeChoice = Read-Host "`nSelect profile mode (1-5) [1]"
    if ([string]::IsNullOrEmpty($modeChoice)) { $modeChoice = "1" }
    
    $selectedMode = switch ($modeChoice) {
        "1" { "Dracula" }
        "2" { "MCP" }
        "3" { "LazyAdmin" }
        "4" { "Minimal" }
        "5" { "Custom" }
        default { "Dracula" }
    }
    
    # Setup options
    Write-Host "`nSetup Options:" -ForegroundColor White
    $setupVSCode = (Read-Host "Configure VS Code integration? (Y/n)") -ne 'n'
    $installDeps = (Read-Host "Install required PowerShell modules? (Y/n)") -ne 'n'
    $configProfile = (Read-Host "Update system PowerShell profile? (Y/n)") -ne 'n'
    
    Write-Host "`n🚀 Starting setup with your selections..." -ForegroundColor Green
    Write-Host "Mode: $selectedMode" -ForegroundColor Gray
    Write-Host "VS Code: $setupVSCode" -ForegroundColor Gray
    Write-Host "Install Dependencies: $installDeps" -ForegroundColor Gray
    Write-Host "Configure Profile: $configProfile" -ForegroundColor Gray
    Write-Host ""
    
    # Build parameters
    $setupParams = @{
        Mode = $selectedMode
    }
    
    if ($setupVSCode) { $setupParams.SetupVSCode = $true }
    if ($installDeps) { $setupParams.InstallDependencies = $true }
    if ($configProfile) { $setupParams.ConfigureSystemProfile = $true }
    
    # Run setup
    & "$PSScriptRoot\Install-UnifiedProfile.ps1" @setupParams
}

Write-Host "`n💡 Quick Commands for VS Code:" -ForegroundColor Cyan
Write-Host "  • Ctrl+Shift+P → 'Tasks: Run Task' → Select profile task" -ForegroundColor White
Write-Host "  • F5 → Debug with current profile mode" -ForegroundColor White
Write-Host "  • Ctrl+` → Open terminal with integrated profile" -ForegroundColor White

Write-Host "`n🎯 Repository Integration Status:" -ForegroundColor Cyan
$repos = @(
    @{ Name = "PowerShell"; Path = "c:\backup\Powershell"; Description = "Main toolkit" },
    @{ Name = "PowerShellModules"; Path = "c:\backup\Powershell\PowerShellModules"; Description = "Module collection" },
    @{ Name = "LazyAdmin"; Path = "c:\backup\LazyAdmin"; Description = "Admin utilities" }
)

foreach ($repo in $repos) {
    $status = if (Test-Path $repo.Path) { "✅" } else { "❌" }
    Write-Host "  $status $($repo.Name) - $($repo.Description)" -ForegroundColor White
}

Write-Host "`n🌟 System Ready! Welcome to your unified PowerShell environment! 🌟" -ForegroundColor Green
