# 🚀 Basic Setup Examples

Quick start examples for getting up and running with the Unified PowerShell Profile system.

## ⚡ Quick Start (5 Minutes)

### 🎯 Minimal Setup
Perfect for first-time users who want to try the system:

```powershell
# 1. Navigate to the PowerShell directory
Set-Location "C:\backup\Powershell"

# 2. Quick install with Dracula theme
.\Install-UnifiedProfile.ps1 -Mode Dracula -Quick

# 3. Test the installation
Test-Path $PROFILE
& "🎯 Module Health Check (Quick)"
```

**What you get:**
- Dracula theme with enhanced colors
- Basic CamelCase navigation
- Essential PowerShell improvements
- VS Code integration ready

### 🧛‍♂️ Dracula Enhanced (Recommended)
For users who want the full experience:

```powershell
# 1. Full Dracula installation
.\Install-UnifiedProfile.ps1 -Mode Dracula -Enhanced

# 2. Enable smart navigation features
$env:ENABLE_CAMELCASE_NAV = "true"
$env:ENABLE_DIACRITICS = "true"

# 3. Test enhanced features
& "🐪 Test CamelCase Navigation"
& "🌍 Test Diacritics Support"
```

**What you get:**
- Complete Dracula theme package
- Smart CamelCase navigation
- International character support
- Git status integration
- Performance monitoring
- Real-time linting

## 🎨 Interactive Setup (10 Minutes)

### 📋 Step-by-Step Installation
For users who prefer guided setup:

**Launch Configuration:** `🎯 Interactive Profile Setup`

```powershell
# The interactive setup will guide you through:

1. Profile Mode Selection:
   ┌─────────────────────────────────┐
   │ Choose your profile mode:       │
   │                                 │
   │ 🧛‍♂️ [1] Dracula (Recommended)  │
   │ 🚀 [2] MCP (AI-Enhanced)        │
   │ ⚡ [3] LazyAdmin (Sysadmin)     │
   │ 🎯 [4] Minimal (Lightweight)   │
   │ 🛠️ [5] Custom (Advanced)       │
   └─────────────────────────────────┘

2. Feature Selection:
   ┌─────────────────────────────────┐
   │ Enable enhanced features:       │
   │                                 │
   │ ☑️ CamelCase Navigation         │
   │ ☑️ Diacritics Support          │
   │ ☑️ Git Integration             │
   │ ☑️ Performance Monitoring      │
   │ ☑️ Real-time Linting           │
   └─────────────────────────────────┘

3. VS Code Integration:
   ┌─────────────────────────────────┐
   │ Configure VS Code integration:  │
   │                                 │
   │ ☑️ Launch Configurations       │
   │ ☑️ Task Definitions            │
   │ ☑️ Debug Settings              │
   │ ☑️ Color Theme Sync            │
   └─────────────────────────────────┘
```

### 🔧 Custom Installation Options
```powershell
# Advanced installation with specific options
.\Install-UnifiedProfile.ps1 `
    -Mode Dracula `
    -EnableCamelCase `
    -EnableDiacritics `
    -EnableGitStatus `
    -VSCodeIntegration `
    -PerformanceMode Fast
```

## 🧪 Testing Your Setup

### 🎯 Quick Validation
After installation, validate everything works:

```powershell
# 1. Health check
& "🎯 Module Health Check (Quick)"

# 2. Test navigation
& "🐪 Test CamelCase Navigation"

# 3. Test theme
Write-Host "Testing Dracula colors..." -ForegroundColor Magenta
Get-ChildItem | Select-Object -First 5
```

### 🔍 Comprehensive Testing
For thorough validation:

```powershell
# Run comprehensive test suite
& "🧪 Test Profile Configuration (Comprehensive)"

# Test specific features
& "🌍 Test Diacritics Support"
& "🎨 Test Profile Themes"
& "⚡ Performance Test (Quick)"
```

## 🎨 Profile Mode Examples

### 🧛‍♂️ Dracula Mode Setup
```powershell
# Install Dracula with all features
.\Install-UnifiedProfile.ps1 -Mode Dracula -Enhanced

# Environment setup
$env:DRACULA_ENHANCED_MODE = "true"
$env:ENABLE_CAMELCASE_NAV = "true"
$env:ENABLE_DIACRITICS = "true"
$env:ENABLE_GIT_STATUS = "true"

# Test the setup
& "🧛‍♂️ Test Dracula Configuration"

# Expected result:
# ✅ Purple and cyan themed prompt
# ✅ Git branch information
# ✅ Smart navigation working
# ✅ International characters supported
```

### 🚀 MCP Mode Setup
```powershell
# Install MCP (Model Context Protocol) mode
.\Install-UnifiedProfile.ps1 -Mode MCP

# Environment setup for AI development
$env:MCP_ENHANCED_MODE = "true"
$env:ENABLE_AI_INTEGRATION = "true"
$env:GITHUB_COPILOT_INTEGRATION = "true"

# Test AI features
& "🤖 Test MCP Integration"

# Expected result:
# ✅ AI-optimized prompt
# ✅ GitHub Copilot integration
# ✅ Enhanced autocomplete
# ✅ Code generation helpers
```

### ⚡ LazyAdmin Mode Setup
```powershell
# Install LazyAdmin for system administration
.\Install-UnifiedProfile.ps1 -Mode LazyAdmin

# Environment setup for sysadmin tasks
$env:LAZYADMIN_ENHANCED_MODE = "true"
$env:ENABLE_ADMIN_TOOLS = "true"
$env:ENABLE_NETWORK_TOOLS = "true"

# Test admin features
& "🔧 Test LazyAdmin Tools"

# Expected result:
# ✅ Admin-focused prompt
# ✅ Network discovery tools
# ✅ System monitoring functions
# ✅ Enhanced cmdlet collections
```

## 📱 VS Code Integration Setup

### 🛠️ Launch Configuration Setup
After installing your profile:

```powershell
# 1. Open VS Code in your PowerShell workspace
code "C:\backup\Powershell"

# 2. Press F5 to see available launch configurations:
#    🧛‍♂️ Dracula Mode (+ Smart Navigation)
#    🚀 MCP Mode (+ AI Integration)
#    ⚡ LazyAdmin Mode (+ Admin Tools)
#    🎯 Minimal Mode (Lightweight)

# 3. Select a configuration and run it
```

### 📋 Task Integration Setup
```powershell
# Access tasks via Command Palette:
# Ctrl+Shift+P → "Tasks: Run Task"

# Available task categories:
# 🚀 Installation & Setup
# 🎨 Profile Mode Management
# 🧪 Testing & Validation
# 🎨 Smart Navigation Features
# 🏆 Performance Testing
# 🔧 Maintenance & Utilities
```

## 🌐 Environment Variables Guide

### 🔧 Essential Variables
```powershell
# Core feature toggles
$env:ENABLE_CAMELCASE_NAV = "true"      # Smart navigation
$env:ENABLE_DIACRITICS = "true"         # International support
$env:ENABLE_GIT_STATUS = "true"         # Git integration
$env:UNIFIED_PROFILE_DEBUG = "false"    # Debug mode

# Performance tuning
$env:LAZY_LOAD_MODULES = "true"         # Faster startup
$env:MINIMAL_STARTUP_MESSAGES = "true"  # Quiet startup
$env:CACHE_MODULE_DEPENDENCIES = "true" # Cache for speed
```

### 🎨 Theme-Specific Variables
```powershell
# Dracula theme
$env:DRACULA_ENHANCED_MODE = "true"
$env:DRACULA_PERFORMANCE_MODE = "false"
$env:DRACULA_MINIMAL_MODE = "false"

# MCP theme
$env:MCP_ENHANCED_MODE = "true"
$env:ENABLE_AI_INTEGRATION = "true"

# LazyAdmin theme
$env:LAZYADMIN_ENHANCED_MODE = "true"
$env:ENABLE_ADMIN_TOOLS = "true"
```

## 🔄 Migration from Existing Setups

### 📦 From Default PowerShell
```powershell
# Backup existing profile
if (Test-Path $PROFILE) {
    Copy-Item $PROFILE "$PROFILE.backup.$(Get-Date -Format 'yyyyMMdd')"
}

# Install Unified Profile
.\Install-UnifiedProfile.ps1 -Mode Dracula

# Migrate custom functions (manual review recommended)
if (Test-Path "$PROFILE.backup.*") {
    Write-Host "Review your backup profile for custom functions to migrate"
    Get-Content "$PROFILE.backup.*" | Where-Object { $_ -match "^function" }
}
```

### 🎨 From Oh-My-Posh Only
```powershell
# If you already have Oh-My-Posh:
Get-Command oh-my-posh

# Install with Oh-My-Posh integration
.\Install-UnifiedProfile.ps1 -Mode Dracula -UseExistingOhMyPosh

# Your existing themes will be preserved
oh-my-posh get shell
```

### 🔧 From PowerShell ISE
```powershell
# ISE users migrating to modern PowerShell
# Note: ISE is deprecated, use VS Code + PowerShell extension

# Install PowerShell 7
winget install Microsoft.PowerShell

# Install VS Code with PowerShell extension
winget install Microsoft.VisualStudioCode
code --install-extension ms-vscode.PowerShell

# Install Unified Profile
.\Install-UnifiedProfile.ps1 -Mode Dracula -VSCodeIntegration
```

## ✅ Verification Checklist

After setup, verify these features work:

### 🎯 Basic Functionality
```powershell
# ✅ Profile loads without errors
Test-Path $PROFILE
. $PROFILE

# ✅ Theme displays correctly
Write-Host "Theme test" -ForegroundColor Magenta

# ✅ Basic commands work
Get-ChildItem | Select-Object -First 3
```

### 🐪 Navigation Features
```powershell
# ✅ CamelCase navigation
# Type: Get-ChildItem
# Test: Ctrl+Right should jump: Get | Child | Item

# ✅ International characters (if enabled)
# Type: funkce-sČeskýmiZnaky
# Test: Navigation should handle diacritics correctly
```

### 🔗 Integration Features
```powershell
# ✅ Git integration (if in git repository)
git status
# Should see git info in prompt

# ✅ VS Code integration
# F5 should show launch configurations
# Ctrl+Shift+P → Tasks should show custom tasks
```

### ⚡ Performance Check
```powershell
# ✅ Startup time reasonable (<3 seconds)
Measure-Command { pwsh -NoExit -Command "exit" }

# ✅ Memory usage acceptable (<200MB)
Get-Process PowerShell | Select-Object WorkingSet
```

## 🆘 Quick Troubleshooting

### 🚨 Common Issues
```powershell
# Issue: Profile not loading
# Solution: Check execution policy
Get-ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Issue: Theme not working
# Solution: Verify Oh-My-Posh installation
Get-Command oh-my-posh

# Issue: Navigation not working
# Solution: Check PSReadLine version
Get-Module PSReadLine
```

### 🔧 Quick Fixes
```powershell
# Reset to known good state
.\Install-UnifiedProfile.ps1 -Mode Dracula -Force

# Clear module cache
Get-Module | Remove-Module -Force

# Restart PowerShell
exit
```

## 💡 Next Steps

### 🔍 Explore Advanced Features
```powershell
# Try advanced configurations
& "🎨 Demo Enhanced Features (Interactive)"

# Explore different profile modes
& "🧛‍♂️ Switch to MCP Mode"
& "⚡ Switch to LazyAdmin Mode"

# Performance optimization
& "🏆 Performance Benchmark (Comprehensive)"
```

### 📚 Learn More
- Read detailed feature documentation in `/features/`
- Explore troubleshooting guides in `/troubleshooting/`
- Check out advanced configurations in `/configurations/`

---

**Quick Start Guide:** Unified PowerShell Profile System  
**Generated:** August 6, 2025  
**Estimated Setup Time:** 5-15 minutes depending on options  
**Support:** Run diagnostic tasks for help
