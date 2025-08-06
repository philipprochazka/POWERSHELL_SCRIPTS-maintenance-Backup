#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Setup Unified PowerShell Profile System
    
.DESCRIPTION
    Complete setup script for the Unified PowerShell Profile system that integrates
    your three core PowerShell repositories with VS Code debug/run functions.
    
.PARAMETER Mode
    Default profile mode to configure (Dracula, MCP, LazyAdmin, Minimal, Custom)
    
.PARAMETER SetupVSCode
    Configure VS Code workspace integration
    
.PARAMETER InstallDependencies
    Install required PowerShell modules
    
.PARAMETER ConfigureSystemProfile
    Update system PowerShell profile to use unified system
    
.EXAMPLE
    .\Install-UnifiedProfile.ps1 -Mode Dracula -SetupVSCode -InstallDependencies
    
.EXAMPLE
    .\Install-UnifiedProfile.ps1 -ConfigureSystemProfile
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('Dracula', 'MCP', 'LazyAdmin', 'Minimal', 'Custom')]
    [string]$Mode = 'Dracula',
    
    [Parameter()]
    [switch]$SetupVSCode,
    
    [Parameter()]
    [switch]$InstallDependencies,
    
    [Parameter()]
    [switch]$ConfigureSystemProfile,
    
    [Parameter()]
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Configuration
$script:WorkspaceRoot = $PSScriptRoot
$script:ModulePath = Join-Path $PSScriptRoot "PowerShellModules\UnifiedPowerShellProfile"
$script:RequiredModules = @(
    'PSReadLine',
    'Terminal-Icons', 
    'z',
    'PSFzf',
    'CompletionPredictor',
    'PSScriptAnalyzer'
)

function Write-SetupLog {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Level = 'Info'
    )
    
    $colors = @{
        Info    = 'Cyan'
        Success = 'Green'
        Warning = 'Yellow'
        Error   = 'Red'
    }
    
    $prefix = switch ($Level) {
        'Info' { '[INFO]' }
        'Success' { '[SUCCESS]' }
        'Warning' { '[WARNING]' }
        'Error' { '[ERROR]' }
    }
    
    Write-Host "$prefix " -NoNewline -ForegroundColor $colors[$Level]
    Write-Host $Message -ForegroundColor White
}

function Test-Prerequisites {
    Write-SetupLog "🔍 Checking prerequisites..." -Level Info
    
    $results = @{
        PowerShellVersion = $true
        Repositories      = @{}
        Modules           = @{}
        VSCode            = $false
        OhMyPosh          = $false
    }
    
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        $results.PowerShellVersion = $false
        Write-SetupLog "PowerShell 5.1+ required, found $($PSVersionTable.PSVersion)" -Level Error
    }
    
    # Check repositories
    $repositories = @{
        'PowerShell'        = 'c:\backup\Powershell'
        'PowerShellModules' = 'c:\backup\Powershell\PowerShellModules'
        'LazyAdmin'         = 'c:\backup\LazyAdmin'
    }
    
    foreach ($repo in $repositories.GetEnumerator()) {
        $results.Repositories[$repo.Key] = Test-Path $repo.Value
        if ($results.Repositories[$repo.Key]) {
            Write-SetupLog "✅ Repository found: $($repo.Key)" -Level Success
        }
        else {
            Write-SetupLog "❌ Repository missing: $($repo.Key) at $($repo.Value)" -Level Warning
        }
    }
    
    # Check VS Code
    if (Get-Command code -ErrorAction SilentlyContinue) {
        $results.VSCode = $true
        Write-SetupLog "✅ VS Code found" -Level Success
    }
    else {
        Write-SetupLog "⚠️ VS Code not found in PATH" -Level Warning
    }
    
    # Check Oh My Posh
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        $results.OhMyPosh = $true
        Write-SetupLog "✅ Oh My Posh found" -Level Success
    }
    else {
        Write-SetupLog "⚠️ Oh My Posh not found" -Level Warning
    }
    
    return $results
}

function Install-RequiredModules {
    Write-SetupLog "📦 Installing required PowerShell modules..." -Level Info
    
    foreach ($moduleName in $script:RequiredModules) {
        try {
            if (-not (Get-Module $moduleName -ListAvailable)) {
                Write-SetupLog "Installing $moduleName..." -Level Info
                Install-Module $moduleName -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
                Write-SetupLog "✅ $moduleName installed successfully" -Level Success
            }
            else {
                Write-SetupLog "✅ $moduleName already installed" -Level Success
            }
        }
        catch {
            Write-SetupLog "❌ Failed to install $moduleName`: $($_.Exception.Message)" -Level Error
        }
    }
}

function Install-UnifiedModule {
    Write-SetupLog "🔧 Setting up Unified PowerShell Profile module..." -Level Info
    
    # Ensure module is in a discoverable location
    $userModulesPath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Modules"
    $targetModulePath = Join-Path $userModulesPath "UnifiedPowerShellProfile"
    
    # Create user modules directory if it doesn't exist
    if (-not (Test-Path $userModulesPath)) {
        New-Item -Path $userModulesPath -ItemType Directory -Force | Out-Null
    }
    
    # Copy module to user modules location
    if (Test-Path $script:ModulePath) {
        if (Test-Path $targetModulePath) {
            if ($Force) {
                Remove-Item $targetModulePath -Recurse -Force
            }
            else {
                Write-SetupLog "Module already exists at $targetModulePath. Use -Force to overwrite." -Level Warning
                return
            }
        }
        
        Copy-Item $script:ModulePath $targetModulePath -Recurse -Force
        Write-SetupLog "✅ Module installed to: $targetModulePath" -Level Success
        
        # Test module import
        try {
            Import-Module UnifiedPowerShellProfile -Force
            Write-SetupLog "✅ Module imports successfully" -Level Success
        }
        catch {
            Write-SetupLog "❌ Module import failed: $($_.Exception.Message)" -Level Error
        }
    }
    else {
        Write-SetupLog "❌ Source module not found at: $script:ModulePath" -Level Error
    }
}

function Install-VSCodeWorkspace {
    Write-SetupLog "💻 Setting up VS Code workspace..." -Level Info
    
    try {
        # Import the module first
        Import-Module UnifiedPowerShellProfile -Force
        
        # Create VS Code workspace
        New-VSCodeWorkspace -WorkspaceRoot $script:WorkspaceRoot -ProfileMode $Mode
        
        Write-SetupLog "✅ VS Code workspace configured" -Level Success
        
    }
    catch {
        Write-SetupLog "❌ Failed to setup VS Code workspace: $($_.Exception.Message)" -Level Error
    }
}

function Update-SystemProfile {
    Write-SetupLog "📝 Configuring system PowerShell profile..." -Level Info
    
    $profilePath = $PROFILE.CurrentUserAllHosts
    if (-not $profilePath) {
        $profilePath = $PROFILE.CurrentUserCurrentHost
    }
    
    if (-not $profilePath) {
        Write-SetupLog "❌ Could not determine profile path" -Level Error
        return
    }
    
    # Create profile directory if it doesn't exist
    $profileDir = Split-Path $profilePath -Parent
    if (-not (Test-Path $profileDir)) {
        New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
    }
    
    # Backup existing profile
    if (Test-Path $profilePath) {
        $backupPath = "$profilePath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        Copy-Item $profilePath $backupPath
        Write-SetupLog "📄 Backed up existing profile to: $backupPath" -Level Info
    }
    
    # Create new profile that loads unified system
    $profileContent = @"
# Unified PowerShell Profile System
# Generated on: $(Get-Date)

# Load Unified PowerShell Profile Module
if (Get-Module UnifiedPowerShellProfile -ListAvailable) {
    Import-Module UnifiedPowerShellProfile -Force
    Initialize-UnifiedProfile -Mode $Mode -WorkspaceRoot `$PWD.Path
} else {
    Write-Host "❌ UnifiedPowerShellProfile module not found!" -ForegroundColor Red
    Write-Host "💡 Run Install-UnifiedProfile.ps1 to install" -ForegroundColor Yellow
}

# Custom user additions below this line
# ===================================

"@
    
    Set-Content -Path $profilePath -Value $profileContent -Encoding UTF8
    Write-SetupLog "✅ System profile updated: $profilePath" -Level Success
}

function Show-CompletionMessage {
    Write-Host ""
    Write-Host "🎉 UNIFIED POWERSHELL PROFILE SETUP COMPLETE! 🎉" -ForegroundColor Green
    Write-Host "=================================================" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "✨ What's been configured:" -ForegroundColor Cyan
    Write-Host "  🚀 Unified PowerShell Profile module installed" -ForegroundColor White
    Write-Host "  🎨 Default mode set to: $Mode" -ForegroundColor White
    
    if ($SetupVSCode) {
        Write-Host "  💻 VS Code workspace configured with debug/run tasks" -ForegroundColor White
    }
    
    if ($InstallDependencies) {
        Write-Host "  📦 Required modules installed" -ForegroundColor White
    }
    
    if ($ConfigureSystemProfile) {
        Write-Host "  📝 System PowerShell profile updated" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "🚀 Quick Start Commands:" -ForegroundColor Cyan
    Write-Host "  profile-status       - Show current configuration" -ForegroundColor White
    Write-Host "  profile-switch       - Switch between profile modes" -ForegroundColor White  
    Write-Host "  profile-test         - Test configuration" -ForegroundColor White
    Write-Host "  Initialize-UnifiedProfile -Mode [Mode] - Initialize specific mode" -ForegroundColor White
    
    Write-Host ""
    Write-Host "💻 VS Code Integration:" -ForegroundColor Cyan
    Write-Host "  • Use Ctrl+Shift+P → 'Tasks: Run Task' to access profile tasks" -ForegroundColor White
    Write-Host "  • Debug configurations available for each profile mode" -ForegroundColor White
    Write-Host "  • Multiple terminal profiles configured" -ForegroundColor White
    
    Write-Host ""
    Write-Host "📁 Your repositories are now integrated:" -ForegroundColor Cyan
    Write-Host "  • c:\backup\Powershell (Main toolkit)" -ForegroundColor White
    Write-Host "  • c:\backup\Powershell\PowerShellModules (Module collection)" -ForegroundColor White 
    Write-Host "  • c:\backup\LazyAdmin (Admin utilities)" -ForegroundColor White
    
    Write-Host ""
    Write-Host "🎯 Next Steps:" -ForegroundColor Yellow
    Write-Host "  1. Restart PowerShell or run: . `$PROFILE" -ForegroundColor White
    Write-Host "  2. Open VS Code and explore the new tasks and debug configurations" -ForegroundColor White
    Write-Host "  3. Use 'profile-switch' to try different modes" -ForegroundColor White
    Write-Host ""
}

# Main Execution
try {
    Write-Host ""
    Write-Host "🚀 UNIFIED POWERSHELL PROFILE SETUP" -ForegroundColor Magenta
    Write-Host "===================================" -ForegroundColor Magenta
    Write-Host ""
    
    # Check prerequisites
    $prereqResults = Test-Prerequisites
    
    # Install dependencies if requested
    if ($InstallDependencies) {
        Install-RequiredModules
    }
    
    # Setup the unified module
    Install-UnifiedModule
    
    # Setup VS Code if requested
    if ($SetupVSCode) {
        Install-VSCodeWorkspace
    }
    
    # Configure system profile if requested
    if ($ConfigureSystemProfile) {
        Update-SystemProfile
    }
    
    # Show completion message
    Show-CompletionMessage
    
}
catch {
    Write-SetupLog "❌ Setup failed: $($_.Exception.Message)" -Level Error
    Write-SetupLog "📋 Stack trace: $($_.ScriptStackTrace)" -Level Error
    exit 1
}
