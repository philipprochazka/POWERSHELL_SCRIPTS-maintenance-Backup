# Repository-specific PowerShell Profile
# POWERSHELL_SCRIPTS-maintenance-Backup

# Set repository root
$RepoRoot = Split-Path -Parent $PSScriptRoot

# Repository-specific aliases and functions
Set-Alias -Name repo-root -Value "Set-Location $RepoRoot"
Set-Alias -Name edit-profile -Value "code $PSScriptRoot\profile.ps1"

# Function to load repository modules
function Import-RepoModules {
    $ModulesPath = Join-Path $RepoRoot "Modules"
    if (Test-Path $ModulesPath) {
        Get-ChildItem $ModulesPath -Directory | ForEach-Object {
            Import-Module $_.FullName -Force
        }
    }
}

# Function to run repository scripts
function Invoke-RepoScript {
    param([string]$ScriptName)
    $ScriptPath = Join-Path $PSScriptRoot "scripts\$ScriptName.ps1"
    if (Test-Path $ScriptPath) {
        & $ScriptPath
    }
    else {
        Write-Warning "Script '$ScriptName' not found in .powershell/scripts/"
    }
}

# Load repository-specific modules
Import-RepoModules

# Repository-specific prompt customization
function prompt {
    $location = Get-Location
    $repoName = Split-Path -Leaf $RepoRoot
    Write-Host "[$repoName] " -ForegroundColor Yellow -NoNewline
    Write-Host "$($location.Path.Replace($RepoRoot, '.'))" -ForegroundColor Green -NoNewline
    Write-Host " PS> " -ForegroundColor White -NoNewline
    return " "
}

Write-Host "Repository PowerShell environment loaded for: " -ForegroundColor Cyan -NoNewline
Write-Host "POWERSHELL_SCRIPTS-maintenance-Backup" -ForegroundColor Yellow
