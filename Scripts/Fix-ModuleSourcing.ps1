#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Quick fix for repository-local module sourcing issue
    
.DESCRIPTION
    Immediately fixes the module path issue by updating PSModulePath to include
    the repository-local PowerShellModules directory and providing helper functions
    for importing repository modules.
#>

param(
    [Parameter()]
    [switch]$Permanent
)

# Get repository root
$repoRoot = "C:\backup\Powershell"
$localModulesPath = Join-Path $repoRoot "PowerShellModules"

Write-Host "🔧 Fixing repository-local module sourcing..." -ForegroundColor Cyan
Write-Host "📂 Repository: $repoRoot" -ForegroundColor Gray
Write-Host "📦 Local Modules: $localModulesPath" -ForegroundColor Gray

# Add repository modules to PSModulePath
$currentModulePath = $env:PSModulePath -split [IO.Path]::PathSeparator
if ($localModulesPath -notin $currentModulePath) {
    $env:PSModulePath = "$localModulesPath$([IO.Path]::PathSeparator)$env:PSModulePath"
    Write-Host "✅ Added repository modules to PSModulePath" -ForegroundColor Green
} else {
    Write-Host "ℹ️ Repository modules already in PSModulePath" -ForegroundColor Yellow
}

# Display current module paths
Write-Host "`n📋 Current PSModulePath:" -ForegroundColor Cyan
$env:PSModulePath -split [IO.Path]::PathSeparator | ForEach-Object {
    $indicator = if ($_ -eq $localModulesPath) { "🎯" } else { "📂" }
    Write-Host "   $indicator $_" -ForegroundColor Gray
}

# Function to import repository-local modules
function Import-RepositoryModule {
    param(
        [Parameter(Mandatory)]
        [string]$ModuleName,
        
        [Parameter()]
        [switch]$Force
    )
    
    $localModulePath = Join-Path $localModulesPath $ModuleName
    if (Test-Path $localModulePath) {
        Import-Module $localModulePath -Force:$Force -Global
        Write-Host "✅ Imported repository module: $ModuleName" -ForegroundColor Green
    } else {
        # Fall back to standard module loading
        try {
            Import-Module $ModuleName -Force:$Force -Global
            Write-Host "📦 Imported standard module: $ModuleName" -ForegroundColor Yellow
        } catch {
            Write-Host "❌ Failed to import module: $ModuleName - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

# Function to list available repository modules
function Get-RepositoryModules {
    if (Test-Path $localModulesPath) {
        $modules = Get-ChildItem -Path $localModulesPath -Directory | 
            Where-Object { Test-Path (Join-Path $_.FullName "*.psd1") -or Test-Path (Join-Path $_.FullName "*.psm1") }
        
        Write-Host "`n📦 Available Repository Modules:" -ForegroundColor Cyan
        $modules | ForEach-Object {
            Write-Host "   📋 $($_.Name)" -ForegroundColor Green
        }
        return $modules
    }
}

# Test repository modules
Write-Host "`n🔍 Testing repository modules..." -ForegroundColor Cyan
$availableModules = Get-RepositoryModules

# Try to import key modules
$keyModules = @('UnifiedMCPProfile', 'UnifiedPowerShellProfile')
foreach ($module in $keyModules) {
    if (Test-Path (Join-Path $localModulesPath $module)) {
        try {
            Import-RepositoryModule $module -Force
        } catch {
            Write-Host "⚠️ Could not import $module`: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠️ Module not found in repository: $module" -ForegroundColor Yellow
    }
}

# Make functions available globally
$global:Import-RepositoryModule = ${function:Import-RepositoryModule}
$global:Get-RepositoryModules = ${function:Get-RepositoryModules}

Write-Host "`n🎉 Repository-local module fix applied!" -ForegroundColor Green
Write-Host "💡 Use 'Import-RepositoryModule ModuleName' to import modules" -ForegroundColor Yellow
Write-Host "💡 Use 'Get-RepositoryModules' to list available modules" -ForegroundColor Yellow

if ($Permanent) {
    # Add to PowerShell profile
    $profileContent = @"

# Repository-Local Module Configuration
`$repoRoot = "$repoRoot"
`$localModulesPath = "$localModulesPath"

# Add repository modules to PSModulePath
if (`$localModulesPath -notin (`$env:PSModulePath -split [IO.Path]::PathSeparator)) {
    `$env:PSModulePath = "`$localModulesPath$([IO.Path]::PathSeparator)`$env:PSModulePath"
}

# Repository module functions
function Import-RepositoryModule {
    param([Parameter(Mandatory)][string]`$ModuleName, [switch]`$Force)
    `$localModulePath = Join-Path `$localModulesPath `$ModuleName
    if (Test-Path `$localModulePath) {
        Import-Module `$localModulePath -Force:`$Force -Global
        Write-Host "✅ Imported repository module: `$ModuleName" -ForegroundColor Green
    } else {
        Import-Module `$ModuleName -Force:`$Force -Global
        Write-Host "📦 Imported standard module: `$ModuleName" -ForegroundColor Yellow
    }
}

function Get-RepositoryModules {
    if (Test-Path `$localModulesPath) {
        Get-ChildItem -Path `$localModulesPath -Directory | 
            Where-Object { Test-Path (Join-Path `$_.FullName "*.psd1") -or Test-Path (Join-Path `$_.FullName "*.psm1") }
    }
}
"@

    $profilePath = Join-Path $repoRoot "Microsoft.PowerShell_profile.ps1"
    $profileContent | Add-Content -Path $profilePath
    Write-Host "✅ Added repository module configuration to profile: $profilePath" -ForegroundColor Green
}
