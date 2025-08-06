# =================================================================== 
# 🧛‍♂️ DRACULA THEME INSTALLER 🧛‍♂️
# Sets up the complete Dracula PowerShell experience
# ===================================================================

[CmdletBinding()]
param(
    [switch]$Backup,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "🧛‍♂️ DRACULA POWERSHELL THEME INSTALLER 🧛‍♂️" -ForegroundColor Magenta
Write-Host "=============================================" -ForegroundColor Magenta
Write-Host ""

# Debug information
Write-Host "🔍 Debug Information:" -ForegroundColor Gray
Write-Host "  PowerShell Version: $($PSVersionTable.PSVersion)" -ForegroundColor Gray
Write-Host "  PowerShell Edition: $($PSVersionTable.PSEdition)" -ForegroundColor Gray
Write-Host "  Script Location: $PSScriptRoot" -ForegroundColor Gray
Write-Host ""

# Get profile path with fallback
$profilePath = $PROFILE.CurrentUserAllHosts
if (-not $profilePath) {
    $profilePath = $PROFILE.CurrentUserCurrentHost
}
if (-not $profilePath) {
    $profilePath = Join-Path ([Environment]::GetFolderPath("MyDocuments")) "PowerShell\Microsoft.PowerShell_profile.ps1"
}

Write-Host "📍 Profile location: $profilePath" -ForegroundColor Cyan

# Ensure we have a valid profile path
if (-not $profilePath) {
    Write-Host "❌ Could not determine PowerShell profile path!" -ForegroundColor Red
}

$profileDir = Split-Path $profilePath -Parent
$backupPath = "$profilePath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"

Write-Host "📁 Profile directory: $profileDir" -ForegroundColor Cyan

# Create profile directory if it doesn't exist
if (-not (Test-Path $profileDir)) {
    Write-Host "📁 Creating profile directory..." -ForegroundColor Yellow
    try {
        New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
        Write-Host "✅ Profile directory created successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to create profile directory: $_" -ForegroundColor Red
        return
    }
}

# Backup existing profile
if ((Test-Path $profilePath) -and $Backup) {
    Write-Host "💾 Backing up existing profile to: $backupPath" -ForegroundColor Yellow
    try {
        Copy-Item $profilePath $backupPath
        Write-Host "✅ Backup created successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to backup profile: $_" -ForegroundColor Red
        return
    }
}

# Copy Dracula profile
$draculaProfile = Join-Path $PSScriptRoot "Microsoft.PowerShell_profile_Dracula.ps1"
Write-Host "🔍 Looking for Dracula profile at: $draculaProfile" -ForegroundColor Gray

if (Test-Path $draculaProfile) {
    if ((Test-Path $profilePath) -and -not $Force) {
        $response = Read-Host "Profile already exists. Overwrite? (y/N)"
        if ($response -ne 'y' -and $response -ne 'Y') {
            Write-Host "❌ Installation cancelled" -ForegroundColor Red
            return
        }
    }
    
    Write-Host "📝 Installing Dracula profile..." -ForegroundColor Green
    try {
        Copy-Item $draculaProfile $profilePath -Force
        Write-Host "✅ Dracula profile installed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to install profile: $_" -ForegroundColor Red
        return
    }
}
else {
    Write-Host "❌ Dracula profile not found at: $draculaProfile" -ForegroundColor Red
    Write-Host "📁 Available files in script directory:" -ForegroundColor Yellow
    if (Test-Path $PSScriptRoot) {
        Get-ChildItem $PSScriptRoot -Name | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    }
    return
}

# Create Theme directory in profile location
$themeDir = Join-Path $profileDir "Theme"
Write-Host "🔍 Theme directory will be: $themeDir" -ForegroundColor Gray

if (-not (Test-Path $themeDir)) {
    Write-Host "📁 Creating Theme directory..." -ForegroundColor Yellow
    try {
        New-Item -Path $themeDir -ItemType Directory -Force | Out-Null
        Write-Host "✅ Theme directory created successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Failed to create Theme directory: $_" -ForegroundColor Red
        return
    }
}

# Copy theme files
$themeFiles = @(
    "Theme\dracula-enhanced.omp.json",
    "Theme\PSReadLine-Dracula-Enhanced.ps1",
    "Theme\DraculaPowerPack.psm1"
)

Write-Host "📦 Copying theme files..." -ForegroundColor Cyan
foreach ($file in $themeFiles) {
    $sourcePath = Join-Path $PSScriptRoot $file
    $destPath = Join-Path $profileDir $file
    
    Write-Host "🔍 Looking for: $sourcePath" -ForegroundColor Gray
    
    if (Test-Path $sourcePath) {
        Write-Host "📄 Copying $file..." -ForegroundColor Green
        try {
            # Ensure destination directory exists
            $destDir = Split-Path $destPath -Parent
            if (-not (Test-Path $destDir)) {
                New-Item -Path $destDir -ItemType Directory -Force | Out-Null
            }
            Copy-Item $sourcePath $destPath -Force
            Write-Host "✅ $file copied successfully" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Failed to copy $file : $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "⚠️  $file not found at $sourcePath" -ForegroundColor Yellow
    }
}

# Check for required modules
Write-Host ""
Write-Host "🔍 Checking required modules..." -ForegroundColor Cyan

$requiredModules = @(
    @{ Name = "PSReadLine"; MinVersion = "2.2.0" },
    @{ Name = "Terminal-Icons"; Required = $false },
    @{ Name = "z"; Required = $false },
    @{ Name = "Az.Tools.Predictor"; Required = $false }
)

foreach ($module in $requiredModules) {
    $installed = Get-Module -ListAvailable -Name $module.Name
    if ($installed) {
        $version = ($installed | Sort-Object Version -Descending | Select-Object -First 1).Version
        Write-Host "✅ $($module.Name) $version" -ForegroundColor Green
    }
    else {
        if ($module.Required -ne $false) {
            Write-Host "❌ $($module.Name) - REQUIRED" -ForegroundColor Red
            Write-Host "   Install with: Install-Module $($module.Name) -Force" -ForegroundColor Yellow
        }
        else {
            Write-Host "⚠️  $($module.Name) - OPTIONAL" -ForegroundColor Yellow
            Write-Host "   Install with: Install-Module $($module.Name) -Force" -ForegroundColor Gray
        }
    }
}

# Check for Oh My Posh
Write-Host ""
Write-Host "🔍 Checking Oh My Posh..." -ForegroundColor Cyan
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    $version = oh-my-posh version
    Write-Host "✅ Oh My Posh $version" -ForegroundColor Green
}
else {
    Write-Host "❌ Oh My Posh not found" -ForegroundColor Red
    Write-Host "   Install with: winget install JanDeDobbeleer.OhMyPosh -s winget" -ForegroundColor Yellow
    Write-Host "   Or: Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 INSTALLATION COMPLETE! 🎉" -ForegroundColor Green
Write-Host ""
Write-Host "🧛‍♂️ Next steps:" -ForegroundColor Magenta
Write-Host "1. Restart PowerShell or run: . `$PROFILE" -ForegroundColor Yellow
Write-Host "2. Install missing modules if needed" -ForegroundColor Yellow
Write-Host "3. Install Oh My Posh if not available" -ForegroundColor Yellow
Write-Host "4. Type 'help-dracula' for available commands" -ForegroundColor Yellow
Write-Host ""
Write-Host "🌙 Welcome to the dark side of PowerShell! 🌙" -ForegroundColor Magenta
Write-Host ""
