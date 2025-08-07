<#
.SYNOPSIS
    Manages Git submodules across the PowerShell repository structure

.DESCRIPTION
    This script provides functions to initialize, update, and manage the multi-level 
    Git submodule structure used in this PowerShell project. It handles both the 
    PowerShellModules submodule and its nested submodules.

.PARAMETER Action
    The action to perform: Initialize, Update, Status, or Reset

.PARAMETER TargetModule
    Specific module to target (optional). If not specified, operates on all modules.

.PARAMETER Recursive
    Whether to operate recursively on all nested submodules

.EXAMPLE
    .\Manage-GitSubmodules.ps1 -Action Initialize
    Initializes all submodules recursively

.EXAMPLE
    .\Manage-GitSubmodules.ps1 -Action Update -TargetModule "gemini-cli"
    Updates only the gemini-cli submodule

.EXAMPLE
    .\Manage-GitSubmodules.ps1 -Action Status
    Shows status of all submodules

.NOTES
    Author: PowerShell Development Team
    Version: 1.0.0
    Requires: Git 2.14+ for proper submodule support
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Initialize", "Update", "Status", "Reset", "Sync")]
    [string]$Action,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("PowerShellModules", "gemini-cli", "opencode", "PSReadLine")]
    [string]$TargetModule,
    
    [Parameter(Mandatory = $false)]
    [switch]$Recursive = $true,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force
)

# Set error handling
$ErrorActionPreference = "Stop"

# Define repository structure
$script:RepoStructure = @{
    Main              = @{
        Path   = $PSScriptRoot
        Remote = "https://github.com/philipprochazka/POWERSHELL_SCRIPTS-maintenance-Backup.git"
        Branch = "master"
    }
    PowerShellModules = @{
        Path       = Join-Path $PSScriptRoot "PowerShellModules"
        Remote     = "https://github.com/philipprochazka/PowerShellModules.git"
        Branch     = "main"
        Submodules = @{
            "gemini-cli" = @{
                Remote   = "git@github.com:philipprochazka/gemini-cli.git"
                Branch   = "main"
                Upstream = "git@github.com:google-gemini/gemini-cli.git"
            }
            "opencode"   = @{
                Remote   = "git@github.com:philipprochazka/opencode.git"
                Branch   = "dev"
                Upstream = "git@github.com:sst/opencode.git"
            }
            "PSReadLine" = @{
                Remote   = "git@github.com:philipprochazka/PSReadLine.git"
                Branch   = "master"
                Upstream = "git@github.com:PowerShell/PSReadLine.git"
            }
        }
    }
}

function Write-StepInfo {
    param([string]$Message)
    Write-Host "🔄 $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️ $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Test-GitRepository {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) {
        return $false
    }
    
    $gitDir = Join-Path $Path ".git"
    return (Test-Path $gitDir)
}

function Invoke-GitCommand {
    param(
        [string]$WorkingDirectory,
        [string[]]$Arguments,
        [switch]$SuppressOutput
    )
    
    $originalLocation = Get-Location
    try {
        Set-Location $WorkingDirectory
        $gitArgs = @("git") + $Arguments
        
        if ($SuppressOutput) {
            $result = & $gitArgs 2>&1
            if ($LASTEXITCODE -ne 0) {
                throw "Git command failed: $($gitArgs -join ' ')`nOutput: $result"
            }
        } else {
            & $gitArgs
            if ($LASTEXITCODE -ne 0) {
                throw "Git command failed: $($gitArgs -join ' ')"
            }
        }
    } finally {
        Set-Location $originalLocation
    }
}

function Initialize-GitSubmodules {
    param([string]$TargetModule)
    
    Write-StepInfo "Initializing Git submodules..."
    
    if ($TargetModule -eq "PowerShellModules" -or -not $TargetModule) {
        # Initialize PowerShellModules submodule
        Write-StepInfo "Initializing PowerShellModules submodule"
        Invoke-GitCommand -WorkingDirectory $script:RepoStructure.Main.Path -Arguments @("submodule", "update", "--init", "PowerShellModules")
        Write-Success "PowerShellModules submodule initialized"
    }
    
    if (-not $TargetModule -or $TargetModule -in @("gemini-cli", "opencode", "PSReadLine")) {
        # Initialize nested submodules in PowerShellModules
        $modulesPath = $script:RepoStructure.PowerShellModules.Path
        if (Test-GitRepository $modulesPath) {
            Write-StepInfo "Initializing nested submodules in PowerShellModules"
            
            if ($TargetModule) {
                Invoke-GitCommand -WorkingDirectory $modulesPath -Arguments @("submodule", "update", "--init", $TargetModule)
                Write-Success "Submodule $TargetModule initialized"
            } else {
                Invoke-GitCommand -WorkingDirectory $modulesPath -Arguments @("submodule", "update", "--init", "--recursive")
                Write-Success "All nested submodules initialized"
            }
        } else {
            Write-Warning "PowerShellModules directory not found or not a Git repository"
        }
    }
}

function Update-GitSubmodules {
    param([string]$TargetModule)
    
    Write-StepInfo "Updating Git submodules..."
    
    if ($TargetModule -eq "PowerShellModules" -or -not $TargetModule) {
        Write-StepInfo "Updating PowerShellModules submodule"
        Invoke-GitCommand -WorkingDirectory $script:RepoStructure.Main.Path -Arguments @("submodule", "update", "--remote", "PowerShellModules")
        Write-Success "PowerShellModules submodule updated"
    }
    
    if (-not $TargetModule -or $TargetModule -in @("gemini-cli", "opencode", "PSReadLine")) {
        $modulesPath = $script:RepoStructure.PowerShellModules.Path
        if (Test-GitRepository $modulesPath) {
            Write-StepInfo "Updating nested submodules"
            
            if ($TargetModule) {
                Invoke-GitCommand -WorkingDirectory $modulesPath -Arguments @("submodule", "update", "--remote", $TargetModule)
                Write-Success "Submodule $TargetModule updated"
            } else {
                Invoke-GitCommand -WorkingDirectory $modulesPath -Arguments @("submodule", "update", "--remote", "--recursive")
                Write-Success "All nested submodules updated"
            }
        }
    }
}

function Get-SubmoduleStatus {
    param([string]$TargetModule)
    
    Write-StepInfo "Getting submodule status..."
    
    # Main repository status
    Write-Host "`n📁 Main Repository Status:" -ForegroundColor Blue
    Invoke-GitCommand -WorkingDirectory $script:RepoStructure.Main.Path -Arguments @("status", "--short")
    
    # PowerShellModules submodule status
    if ($TargetModule -eq "PowerShellModules" -or -not $TargetModule) {
        Write-Host "`n📦 PowerShellModules Submodule Status:" -ForegroundColor Blue
        Invoke-GitCommand -WorkingDirectory $script:RepoStructure.Main.Path -Arguments @("submodule", "status", "PowerShellModules")
        
        if (Test-GitRepository $script:RepoStructure.PowerShellModules.Path) {
            Invoke-GitCommand -WorkingDirectory $script:RepoStructure.PowerShellModules.Path -Arguments @("status", "--short")
        }
    }
    
    # Nested submodules status
    if (-not $TargetModule -or $TargetModule -in @("gemini-cli", "opencode", "PSReadLine")) {
        $modulesPath = $script:RepoStructure.PowerShellModules.Path
        if (Test-GitRepository $modulesPath) {
            Write-Host "`n🔧 Nested Submodules Status:" -ForegroundColor Blue
            
            if ($TargetModule) {
                Invoke-GitCommand -WorkingDirectory $modulesPath -Arguments @("submodule", "status", $TargetModule)
            } else {
                Invoke-GitCommand -WorkingDirectory $modulesPath -Arguments @("submodule", "status")
            }
        }
    }
}

function Reset-GitSubmodules {
    param([string]$TargetModule)
    
    if (-not $Force) {
        $confirm = Read-Host "⚠️ This will reset all submodules to their committed state. Continue? (y/N)"
        if ($confirm -ne "y" -and $confirm -ne "Y") {
            Write-Warning "Reset cancelled by user"
            return
        }
    }
    
    Write-StepInfo "Resetting Git submodules..."
    
    if ($TargetModule -eq "PowerShellModules" -or -not $TargetModule) {
        Write-StepInfo "Resetting PowerShellModules submodule"
        Invoke-GitCommand -WorkingDirectory $script:RepoStructure.Main.Path -Arguments @("submodule", "deinit", "--force", "PowerShellModules")
        Invoke-GitCommand -WorkingDirectory $script:RepoStructure.Main.Path -Arguments @("submodule", "update", "--init", "PowerShellModules")
        Write-Success "PowerShellModules submodule reset"
    }
    
    if (-not $TargetModule -or $TargetModule -in @("gemini-cli", "opencode", "PSReadLine")) {
        $modulesPath = $script:RepoStructure.PowerShellModules.Path
        if (Test-GitRepository $modulesPath) {
            Write-StepInfo "Resetting nested submodules"
            
            if ($TargetModule) {
                Invoke-GitCommand -WorkingDirectory $modulesPath -Arguments @("submodule", "deinit", "--force", $TargetModule)
                Invoke-GitCommand -WorkingDirectory $modulesPath -Arguments @("submodule", "update", "--init", $TargetModule)
                Write-Success "Submodule $TargetModule reset"
            } else {
                Invoke-GitCommand -WorkingDirectory $modulesPath -Arguments @("submodule", "deinit", "--all", "--force")
                Invoke-GitCommand -WorkingDirectory $modulesPath -Arguments @("submodule", "update", "--init", "--recursive")
                Write-Success "All nested submodules reset"
            }
        }
    }
}

function Sync-UpstreamRepositories {
    param([string]$TargetModule)
    
    Write-StepInfo "Syncing with upstream repositories..."
    
    $modulesToSync = @()
    if ($TargetModule) {
        if ($TargetModule -in @("gemini-cli", "opencode", "PSReadLine")) {
            $modulesToSync = @($TargetModule)
        }
    } else {
        $modulesToSync = @("gemini-cli", "opencode", "PSReadLine")
    }
    
    foreach ($module in $modulesToSync) {
        $moduleConfig = $script:RepoStructure.PowerShellModules.Submodules[$module]
        $modulePath = Join-Path $script:RepoStructure.PowerShellModules.Path $module
        
        if (Test-GitRepository $modulePath) {
            Write-StepInfo "Syncing $module with upstream"
            
            try {
                # Fetch from upstream
                Invoke-GitCommand -WorkingDirectory $modulePath -Arguments @("fetch", "upstream") -SuppressOutput
                
                # Check if we're on the correct branch
                $currentBranch = & git -C $modulePath branch --show-current
                if ($currentBranch -ne $moduleConfig.Branch) {
                    Invoke-GitCommand -WorkingDirectory $modulePath -Arguments @("checkout", $moduleConfig.Branch)
                }
                
                # Merge upstream changes
                Invoke-GitCommand -WorkingDirectory $modulePath -Arguments @("merge", "upstream/$($moduleConfig.Branch)")
                
                # Push to origin
                Invoke-GitCommand -WorkingDirectory $modulePath -Arguments @("push", "origin", $moduleConfig.Branch)
                
                Write-Success "$module synced with upstream successfully"
            } catch {
                Write-Error "Failed to sync $module with upstream: $_"
            }
        } else {
            Write-Warning "$module directory not found or not a Git repository"
        }
    }
}

# Main execution
try {
    Write-Host "🚀 Git Submodule Manager" -ForegroundColor Magenta
    Write-Host "Repository: POWERSHELL_SCRIPTS-maintenance-Backup" -ForegroundColor Gray
    Write-Host ""
    
    switch ($Action) {
        "Initialize" {
            Initialize-GitSubmodules -TargetModule $TargetModule
        }
        "Update" {
            Update-GitSubmodules -TargetModule $TargetModule
        }
        "Status" {
            Get-SubmoduleStatus -TargetModule $TargetModule
        }
        "Reset" {
            Reset-GitSubmodules -TargetModule $TargetModule
        }
        "Sync" {
            Sync-UpstreamRepositories -TargetModule $TargetModule
        }
    }
    
    Write-Host ""
    Write-Success "Operation completed successfully!"
} catch {
    Write-Error "Operation failed: $_"
    exit 1
}
