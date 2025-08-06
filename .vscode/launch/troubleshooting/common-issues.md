# 🆘 Common Issues and Solutions

Comprehensive troubleshooting guide for the Unified PowerShell Profile system with solutions to frequently encountered problems.

## 🚨 Critical Issues

### 🚫 Profile Not Loading
**Symptoms:** PowerShell starts without any profile customizations

**Diagnostic Steps:**
```powershell
# Check if profile exists
Test-Path $PROFILE
Write-Host "Profile path: $PROFILE"

# Test profile syntax
Test-PSScriptAnalyzer $PROFILE -Severity Error

# Try loading manually
try {
    . $PROFILE
    Write-Host "✅ Profile loaded successfully"
} catch {
    Write-Host "❌ Profile loading failed: $($_.Exception.Message)"
}
```

**Solutions:**
```powershell
# Solution 1: Check execution policy
Get-ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Solution 2: Verify profile location
$ProfileDir = Split-Path $PROFILE -Parent
if (!(Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force
}

# Solution 3: Reset to known good profile
Copy-Item "C:\backup\Powershell\Microsoft.PowerShell_profile_Dracula_Enhanced.ps1" $PROFILE -Force
```

### 🔧 Module Dependencies Missing
**Symptoms:** Functions not available, error messages about missing modules

**Diagnostic Commands:**
```powershell
# Check required modules
$RequiredModules = @('PSReadLine', 'Oh-My-Posh', 'Pester', 'PSScriptAnalyzer')
foreach ($Module in $RequiredModules) {
    $Available = Get-Module -ListAvailable -Name $Module
    if ($Available) {
        Write-Host "✅ $Module`: $($Available.Version)" -ForegroundColor Green
    } else {
        Write-Host "❌ $Module`: Not installed" -ForegroundColor Red
    }
}
```

**Solutions:**
```powershell
# Install missing modules
Install-Module PSReadLine -Scope CurrentUser -Force
Install-Module Oh-My-Posh -Scope CurrentUser -Force
Install-Module Pester -Scope CurrentUser -Force
Install-Module PSScriptAnalyzer -Scope CurrentUser -Force

# Update outdated modules
Update-Module PSReadLine
Update-Module Oh-My-Posh
```

### ⚡ Slow Profile Startup
**Symptoms:** PowerShell takes >3 seconds to start

**Performance Diagnosis:**
```powershell
# Enable startup timing
$env:MEASURE_STARTUP_TIME = "true"
$env:UNIFIED_PROFILE_DEBUG = "true"

# Restart PowerShell and measure
Measure-Command { pwsh -NoExit -Command "Write-Host 'Profile loaded'" }
```

**Optimization Solutions:**
```powershell
# Solution 1: Use performance profile variant
Copy-Item "Microsoft.PowerShell_profile_Dracula_Performance.ps1" $PROFILE -Force

# Solution 2: Disable heavy features temporarily
$env:DISABLE_GIT_STATUS = "true"
$env:MINIMAL_OH_MY_POSH = "true"
$env:LAZY_LOAD_MODULES = "true"

# Solution 3: Clear module cache
Get-Module | Remove-Module -Force
```

## 🎨 Navigation Issues

### 🐪 CamelCase Navigation Not Working
**Symptoms:** Ctrl+Arrow keys don't jump between word boundaries

**Diagnostic Steps:**
```powershell
# Check if feature is enabled
Write-Host "CamelCase Navigation: $env:ENABLE_CAMELCASE_NAV"

# Verify PSReadLine version
$PSReadLineVersion = Get-Module PSReadLine | Select-Object -ExpandProperty Version
Write-Host "PSReadLine Version: $PSReadLineVersion"

# Test key bindings
Get-PSReadLineKeyHandler | Where-Object Key -match "LeftArrow|RightArrow"
```

**Solutions:**
```powershell
# Solution 1: Enable the feature
$env:ENABLE_CAMELCASE_NAV = "true"

# Solution 2: Update PSReadLine
Update-Module PSReadLine -Force
Remove-Module PSReadLine -Force
Import-Module PSReadLine -Force

# Solution 3: Manually set key bindings
Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord

# Solution 4: Reset PSReadLine configuration
Remove-Variable PSReadLineOptions -ErrorAction SilentlyContinue
```

### 🌍 Diacritics Not Displaying
**Symptoms:** International characters show as question marks or boxes

**Font and Encoding Check:**
```powershell
# Check console encoding
[Console]::OutputEncoding
[Console]::InputEncoding

# Test character rendering
Write-Host "Test: čěščřžýáíé - ñáéíóú - äöüß - àâçèéêë"

# Check current font
$Host.UI.RawUI.WindowTitle = "Font Test - čěščřžýáíé"
```

**Solutions:**
```powershell
# Solution 1: Set UTF-8 encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Solution 2: Change console font (Windows Terminal)
# Open Windows Terminal settings and change font to:
# - Cascadia Code
# - Fira Code  
# - JetBrains Mono

# Solution 3: Enable diacritics support
$env:ENABLE_DIACRITICS = "true"

# Solution 4: Force Unicode in PowerShell
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding
```

## 🧛‍♂️ Theme and Visual Issues

### 🎨 Dracula Theme Not Loading
**Symptoms:** Default PowerShell colors instead of Dracula theme

**Theme Diagnostic:**
```powershell
# Check Oh-My-Posh installation
Get-Command oh-my-posh -ErrorAction SilentlyContinue

# Test theme file existence
$ThemePath = "$env:USERPROFILE\.oh-my-posh\themes\dracula.omp.json"
Test-Path $ThemePath

# Check current theme
Write-Host "Current theme: $env:POSH_THEME"
```

**Solutions:**
```powershell
# Solution 1: Install Oh-My-Posh
winget install JanDeDobbeleer.OhMyPosh

# Solution 2: Download Dracula theme
$ThemeUrl = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/dracula.omp.json"
$ThemeDir = "$env:USERPROFILE\.oh-my-posh\themes"
New-Item -ItemType Directory -Path $ThemeDir -Force
Invoke-WebRequest -Uri $ThemeUrl -OutFile "$ThemeDir\dracula.omp.json"

# Solution 3: Set theme manually
oh-my-posh init pwsh --config "$env:USERPROFILE\.oh-my-posh\themes\dracula.omp.json" | Invoke-Expression

# Solution 4: Reset Dracula configuration
Remove-Variable DraculaConfig -ErrorAction SilentlyContinue
$env:DRACULA_ENHANCED_MODE = "true"
```

### 🖥️ Terminal Appearance Issues
**Symptoms:** Colors not displaying correctly, formatting problems

**Terminal Diagnostic:**
```powershell
# Check terminal capabilities
$Host.UI.RawUI.ForegroundColor
$Host.UI.RawUI.BackgroundColor

# Test color support
for ($i = 0; $i -lt 16; $i++) {
    Write-Host "Color $i" -ForegroundColor ([System.ConsoleColor]$i)
}

# Check terminal type
Write-Host "Terminal: $env:TERM"
Write-Host "Windows Terminal: $env:WT_SESSION"
```

**Solutions:**
```powershell
# Solution 1: Update Windows Terminal
winget upgrade Microsoft.WindowsTerminal

# Solution 2: Configure terminal color scheme
# In Windows Terminal settings.json:
{
    "name": "Dracula",
    "background": "#282a36",
    "foreground": "#f8f8f2",
    "cursorColor": "#f8f8f2"
}

# Solution 3: Reset terminal settings
# Reset Windows Terminal to defaults and reconfigure

# Solution 4: Use legacy console if needed
# Right-click PowerShell icon → Properties → Use legacy console
```

## 🔗 VS Code Integration Issues

### 🛠️ Launch Configurations Not Working
**Symptoms:** F5 doesn't show custom launch configurations

**VS Code Diagnostic:**
```powershell
# Check launch.json location
$LaunchConfig = ".vscode\launch.json"
Test-Path $LaunchConfig

# Validate JSON syntax
try {
    Get-Content $LaunchConfig | ConvertFrom-Json
    Write-Host "✅ launch.json syntax valid"
} catch {
    Write-Host "❌ launch.json syntax error: $($_.Exception.Message)"
}
```

**Solutions:**
```powershell
# Solution 1: Ensure correct location
# launch.json must be in .vscode folder at workspace root

# Solution 2: Reload VS Code window
# Ctrl+Shift+P → "Developer: Reload Window"

# Solution 3: Reset launch configuration
$LaunchTemplate = @"
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "🧛‍♂️ Dracula Mode (+ Smart Navigation)",
            "type": "PowerShell",
            "request": "launch",
            "script": "Install-UnifiedProfile.ps1",
            "args": ["-Mode", "Dracula"],
            "cwd": "${workspaceFolder}"
        }
    ]
}
"@
$LaunchTemplate | Out-File -FilePath ".vscode\launch.json" -Encoding UTF8
```

### 📋 Tasks Not Appearing
**Symptoms:** Task menu doesn't show custom PowerShell tasks

**Task Diagnostic:**
```powershell
# Check tasks.json
Test-Path ".vscode\tasks.json"

# Validate task configuration
$TasksContent = Get-Content ".vscode\tasks.json" -Raw
try {
    $TasksContent | ConvertFrom-Json
    Write-Host "✅ tasks.json valid"
} catch {
    Write-Host "❌ tasks.json error: $($_.Exception.Message)"
}
```

**Solutions:**
```powershell
# Solution 1: Refresh task list
# Ctrl+Shift+P → "Tasks: Run Task" → Refresh

# Solution 2: Check task syntax
# Ensure proper JSON structure in tasks.json

# Solution 3: Reload VS Code
# Save all files and reload window
```

## 🔄 Git Integration Problems

### 📊 Git Status Not Showing
**Symptoms:** No git information in prompt or status indicators

**Git Diagnostic:**
```powershell
# Check git installation
Get-Command git -ErrorAction SilentlyContinue

# Test git repository
git status 2>&1

# Check git module
Get-Module -Name "*git*" -ListAvailable
```

**Solutions:**
```powershell
# Solution 1: Install Git
winget install Git.Git

# Solution 2: Initialize repository if needed
git init
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Solution 3: Enable git integration
$env:ENABLE_GIT_STATUS = "true"

# Solution 4: Install git PowerShell module
Install-Module posh-git -Scope CurrentUser
```

## 🏃‍♂️ Performance Problems

### 🐌 Slow Command Execution
**Symptoms:** Commands take longer than expected to execute

**Performance Diagnostic:**
```powershell
# Profile command execution
Measure-Command { Get-ChildItem }
Measure-Command { Get-Process }

# Check loaded modules
Get-Module | Measure-Object | Select-Object Count
Get-Module | Sort-Object Name

# Monitor memory usage
Get-Process PowerShell | Select-Object WorkingSet, VirtualMemorySize
```

**Solutions:**
```powershell
# Solution 1: Clear module cache
Get-Module | Remove-Module -Force

# Solution 2: Disable heavy features
$env:DISABLE_GIT_STATUS = "true"
$env:MINIMAL_OH_MY_POSH = "true"

# Solution 3: Use minimal profile
Copy-Item "Microsoft.PowerShell_profile_Dracula_Minimal.ps1" $PROFILE -Force

# Solution 4: Optimize PowerShell settings
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
```

### 💾 High Memory Usage
**Symptoms:** PowerShell using excessive RAM (>500MB)

**Memory Diagnostic:**
```powershell
# Check memory usage
[GC]::GetTotalMemory($false) / 1MB
Get-Process PowerShell | Select-Object WorkingSet, PrivateMemorySize

# Profile memory allocation
[GC]::Collect()
$Before = [GC]::GetTotalMemory($false)
# ... run commands ...
$After = [GC]::GetTotalMemory($false)
Write-Host "Memory used: $(($After - $Before) / 1MB) MB"
```

**Solutions:**
```powershell
# Solution 1: Force garbage collection
[GC]::Collect()
[GC]::WaitForPendingFinalizers()

# Solution 2: Remove unused modules
Get-Module | Where-Object Name -NotIn @('Microsoft.PowerShell.Management', 'Microsoft.PowerShell.Utility') | Remove-Module

# Solution 3: Restart PowerShell session
exit
```

## 🛡️ Security and Permissions

### 🔒 Execution Policy Issues
**Symptoms:** Scripts cannot be executed, "cannot be loaded" errors

**Security Diagnostic:**
```powershell
# Check execution policy
Get-ExecutionPolicy -List

# Test script execution
Test-Path $PROFILE
& $PROFILE -WhatIf
```

**Solutions:**
```powershell
# Solution 1: Set appropriate execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Solution 2: Unblock downloaded files
Get-ChildItem -Path "C:\backup\Powershell" -Recurse | Unblock-File

# Solution 3: Sign scripts (advanced)
# Use code signing certificate for internal scripts
```

### 👤 Permission Denied Errors
**Symptoms:** Cannot modify profile, access denied to module directories

**Permission Diagnostic:**
```powershell
# Check profile directory permissions
$ProfileDir = Split-Path $PROFILE -Parent
Get-Acl $ProfileDir | Format-List

# Test write access
try {
    "Test" | Out-File "$ProfileDir\test.txt"
    Remove-Item "$ProfileDir\test.txt"
    Write-Host "✅ Write access OK"
} catch {
    Write-Host "❌ No write access: $($_.Exception.Message)"
}
```

**Solutions:**
```powershell
# Solution 1: Run as current user (not admin)
# Don't run PowerShell as administrator unless necessary

# Solution 2: Fix profile directory permissions
$ProfileDir = Split-Path $PROFILE -Parent
if (!(Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir -Force
}

# Solution 3: Use user-scope module installation
Install-Module ModuleName -Scope CurrentUser -Force
```

## 🔧 Emergency Recovery

### 🆘 Complete Profile Reset
When nothing else works:

```powershell
# Step 1: Backup current profile
if (Test-Path $PROFILE) {
    Copy-Item $PROFILE "$PROFILE.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
}

# Step 2: Remove problematic profile
Remove-Item $PROFILE -ErrorAction SilentlyContinue

# Step 3: Remove all modules
Get-Module | Remove-Module -Force

# Step 4: Clear PowerShell cache
Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\PowerShell\*" -Recurse -Force -ErrorAction SilentlyContinue

# Step 5: Restart PowerShell
exit

# Step 6: Reinstall from known good source
Copy-Item "C:\backup\Powershell\Microsoft.PowerShell_profile_Dracula_Enhanced.ps1" $PROFILE -Force
```

### 🔄 System Recovery Mode
For critical issues:

```powershell
# Start PowerShell without profile
pwsh -NoProfile

# Test basic functionality
Get-Command
Get-Module -ListAvailable

# Gradually restore features
Import-Module PSReadLine
# Test navigation...

Import-Module Oh-My-Posh  
# Test theming...
```

## 📞 Getting Help

### 🔍 Self-Diagnostic Commands
```powershell
# Run comprehensive diagnostic
& "🆘 Diagnose Profile Issues"

# Quick environment check
& "🔍 PowerShell Environment Analysis"

# Health check
& "🎯 Module Health Check (Quick)"
```

### 📝 Collecting Debug Information
```powershell
# Enable verbose logging
$env:UNIFIED_PROFILE_DEBUG = "true"
$VerbosePreference = "Continue"

# Generate diagnostic report
$DiagReport = @{
    PSVersion = $PSVersionTable
    Profile = $PROFILE
    ExecutionPolicy = Get-ExecutionPolicy -List
    Modules = Get-Module -ListAvailable | Select-Object Name, Version
    Environment = Get-ChildItem Env: | Where-Object Name -match "ENABLE_|DRACULA_|MCP_"
    Errors = $Error | Select-Object -First 5
}

$DiagReport | ConvertTo-Json -Depth 3 | Out-File "PowerShell-Diagnostic-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
```

---

**Support:** Unified PowerShell Profile Troubleshooting  
**Updated:** August 6, 2025  
**Coverage:** Installation, Navigation, Themes, VS Code, Git, Performance  
**Emergency Contact:** Run diagnostic commands above and check logs
