#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Launch PowerShell MCP Workspace
    
.DESCRIPTION
    Quick launcher script to open the PowerShell MCP workspace with all
    optimizations and configurations ready for development.
    
.PARAMETER Action
    Action to perform: setup, start, profile, or vscode
    
.EXAMPLE
    .\Launch-Workspace.ps1 -Action setup
    Sets up the complete MCP environment
    
.EXAMPLE  
    .\Launch-Workspace.ps1 -Action start
    Starts PowerShell with the MCP profile loaded
    
.EXAMPLE
    .\Launch-Workspace.ps1 -Action vscode
    Opens the workspace in VS Code
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('setup', 'start', 'profile', 'vscode')]
    [string]$Action = 'start'
)

$WorkspaceRoot = $PSScriptRoot
$MCPProfile = Join-Path $WorkspaceRoot 'Microsoft.PowerShell_profile_MCP.ps1'
$VSCodeWorkspace = Join-Path $WorkspaceRoot '.vscode\Powershell.code-workspace'

Write-Host "🚀 PowerShell MCP Workspace Launcher" -ForegroundColor Cyan
Write-Host "Workspace: $WorkspaceRoot" -ForegroundColor Gray

switch ($Action) {
    'setup' {
        Write-Host "`n📦 Setting up MCP environment..." -ForegroundColor Yellow
        
        # Run setup script
        $setupScript = Join-Path $WorkspaceRoot 'Scripts\Setup-MCPEnvironment.ps1'
        if (Test-Path $setupScript) {
            & $setupScript -WorkspaceRoot $WorkspaceRoot
        }
        else {
            Write-Error "Setup script not found: $setupScript"
            return
        }
        
        # Install recommended modules
        Write-Host "`n📚 Installing recommended PowerShell modules..." -ForegroundColor Yellow
        $modules = @('PSScriptAnalyzer', 'Pester', 'Az.Tools.Predictor', 'Terminal-Icons', 'z')
        
        foreach ($module in $modules) {
            try {
                if (-not (Get-Module $module -ListAvailable)) {
                    Write-Host "Installing $module..." -ForegroundColor Gray
                    Install-Module $module -Scope CurrentUser -Force -ErrorAction Stop
                    Write-Host "✅ $module installed" -ForegroundColor Green
                }
                else {
                    Write-Host "✅ $module already installed" -ForegroundColor Green
                }
            }
            catch {
                Write-Host "⚠️  Failed to install $module`: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
        
        Write-Host "`n🎯 Setup complete! Run with -Action start to begin." -ForegroundColor Green
    }
    
    'start' {
        Write-Host "`n🎯 Starting PowerShell with MCP profile..." -ForegroundColor Yellow
        
        if (Test-Path $MCPProfile) {
            # Start new PowerShell session with MCP profile
            $cmd = "pwsh -ExecutionPolicy Bypass -NoExit -Command `". '$MCPProfile'; Set-Location '$WorkspaceRoot'`""
            Invoke-Expression $cmd
        }
        else {
            Write-Error "MCP profile not found: $MCPProfile"
            Write-Host "Run with -Action setup first" -ForegroundColor Yellow
        }
    }
    
    'profile' {
        Write-Host "`n📝 Setting up profile integration..." -ForegroundColor Yellow
        
        if (Test-Path $MCPProfile) {
            Write-Host "Current PowerShell profile: $PROFILE" -ForegroundColor Gray
            
            $choice = Read-Host "`nChoose option:`n1. Replace system profile with MCP profile`n2. Add MCP profile to existing profile`n3. Just show paths`nEnter choice (1-3)"
            
            switch ($choice) {
                '1' {
                    if (Test-Path $PROFILE) {
                        Copy-Item $PROFILE "$PROFILE.backup"
                        Write-Host "✅ Backed up existing profile to $PROFILE.backup" -ForegroundColor Green
                    }
                    Copy-Item $MCPProfile $PROFILE
                    Write-Host "✅ MCP profile set as system default" -ForegroundColor Green
                }
                '2' {
                    if (-not (Test-Path $PROFILE)) {
                        New-Item -Path $PROFILE -ItemType File -Force | Out-Null
                    }
                    $sourceCommand = "`n# Source MCP Profile`nif (Test-Path '$MCPProfile') { . '$MCPProfile' }`n"
                    Add-Content -Path $PROFILE -Value $sourceCommand
                    Write-Host "✅ Added MCP profile sourcing to system profile" -ForegroundColor Green
                }
                '3' {
                    Write-Host "`nPaths:" -ForegroundColor Cyan
                    Write-Host "System Profile: $PROFILE" -ForegroundColor White
                    Write-Host "MCP Profile: $MCPProfile" -ForegroundColor White
                    Write-Host "Workspace: $WorkspaceRoot" -ForegroundColor White
                }
            }
        }
        else {
            Write-Error "MCP profile not found. Run -Action setup first."
        }
    }
    
    'vscode' {
        Write-Host "`n💻 Opening VS Code workspace..." -ForegroundColor Yellow
        
        if (Get-Command code -ErrorAction SilentlyContinue) {
            if (Test-Path $VSCodeWorkspace) {
                & code $VSCodeWorkspace
                Write-Host "✅ VS Code workspace opened" -ForegroundColor Green
            }
            else {
                Write-Error "VS Code workspace file not found: $VSCodeWorkspace"
            }
        }
        else {
            Write-Error "VS Code not found in PATH. Install VS Code first."
        }
    }
}

Write-Host "`n💡 Available actions: setup, start, profile, vscode" -ForegroundColor Gray
Write-Host "💡 For help: Get-Help .\Launch-Workspace.ps1 -Examples" -ForegroundColor Gray
