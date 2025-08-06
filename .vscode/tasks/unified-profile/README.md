# 🚀 Unified Profile Tasks

This module contains tasks related to the UnifiedPowerShellProfile system installation and management.

## 📋 Available Tasks

### 🚀 Install UnifiedProfile System
**Default build task** - Installs the UnifiedProfile system for the current user.
- Adds module path to PSModulePath
- Imports UnifiedPowerShellProfile module
- Runs Install-UnifiedProfileSystem with registry changes

### ⚡ Install System-Wide Ultra-Performance Profile  
**Requires Administrator privileges** - Installs system-wide ultra-performance profile.
- Checks for admin privileges
- Installs for all users
- Switches to Performance mode automatically
- Updates registry settings

### 🎯 Enable Ultra-Performance Default Mode
Sets ultra-performance as the default profile mode.
- Runs Set-DraculaUltraPerformanceDefault.ps1
- Forces ultra-performance as default
- Updates profile preferences

### 🔍 Verify System-Wide Profile Propagation
Comprehensive verification of system-wide profile installation.
- Analyzes PSModulePath
- Checks user and system profile locations
- Verifies UnifiedProfile imports
- Tests module functionality
- Provides detailed status report

### 🎯 Switch Profile Mode
Interactive profile mode switching utility.
- Imports UnifiedPowerShellProfile module
- Runs Switch-ProfileMode function
- Allows runtime profile switching

### 🧹 Setup Unified Profile System
Quick setup utility for unified profile system.
- Runs Start-UnifiedProfile.ps1 script
- Quick setup mode enabled
- Streamlined installation process

## 🎯 Usage

1. **First Time Setup**: Run "🚀 Install UnifiedProfile System"
2. **System-Wide Install**: Run "⚡ Install System-Wide Ultra-Performance Profile" (as Administrator)
3. **Verification**: Run "🔍 Verify System-Wide Profile Propagation"
4. **Mode Switching**: Use "🎯 Switch Profile Mode" for runtime changes

## 📁 Related Files

- `${workspaceFolder}/UnifiedPowerShellProfile/` - Main module directory
- `${workspaceFolder}/Start-UnifiedProfile.ps1` - Quick setup script
- `${workspaceFolder}/Set-DraculaUltraPerformanceDefault.ps1` - Default mode script
- `${workspaceFolder}/Switch-DraculaMode.ps1` - Mode switching script

## 🔧 Requirements

- PowerShell 7+ recommended
- Administrator privileges for system-wide installation
- UnifiedPowerShellProfile module in workspace
