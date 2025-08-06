# Repository Initialization Script
# Load the repository-specific PowerShell environment

param(
    [switch]$Force
)

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ProfilePath = Join-Path $PSScriptRoot "profile.ps1"

Write-Host "Initializing PowerShell environment for repository..." -ForegroundColor Green

# Check if modules manifest exists and install required modules
$ModulesManifest = Join-Path $PSScriptRoot "modules.psd1"
if (Test-Path $ModulesManifest) {
    Write-Host "Checking required modules..." -ForegroundColor Cyan
    $Manifest = Import-PowerShellDataFile $ModulesManifest
    
    foreach ($RequiredModule in $Manifest.RequiredModules) {
        $ModuleName = $RequiredModule.ModuleName
        $RequiredVersion = $RequiredModule.ModuleVersion
        
        $InstalledModule = Get-Module -ListAvailable -Name $ModuleName
        if (-not $InstalledModule -or ($InstalledModule.Version -lt $RequiredVersion)) {
            Write-Host "Installing module: $ModuleName (>= $RequiredVersion)" -ForegroundColor Yellow
            try {
                Install-Module -Name $ModuleName -MinimumVersion $RequiredVersion -Force:$Force -Scope CurrentUser
                Write-Host "  ✅ Installed $ModuleName" -ForegroundColor Green
            }
            catch {
                Write-Warning "Failed to install ${ModuleName}: $($_.Exception.Message)"
            }
        }
        else {
            Write-Host "  ✅ $ModuleName already installed" -ForegroundColor Green
        }
    }
}

# Load the repository profile
if (Test-Path $ProfilePath) {
    Write-Host "Loading repository profile..." -ForegroundColor Cyan
    . $ProfilePath
}

Write-Host "Repository environment initialized! 🚀" -ForegroundColor Green
Write-Host "Available commands:" -ForegroundColor Yellow
Write-Host "  repo-root        - Navigate to repository root" -ForegroundColor White
Write-Host "  edit-profile     - Edit repository profile" -ForegroundColor White
Write-Host "  Invoke-RepoScript - Run repository scripts" -ForegroundColor White
