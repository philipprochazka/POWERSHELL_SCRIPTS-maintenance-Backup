# 🚀 Unified PowerShell Profile System

A comprehensive, portable PowerShell configuration system that integrates your three core PowerShell repositories with VS Code debug/run functions. This system provides seamless profile management across multiple repositories and development environments.

## 🎯 Overview

This unified system brings together your three PowerShell repositories:
- **PowerShell** (`c:\backup\Powershell`) - Main toolkit with Dracula theme
- **PowerShellModules** (`c:\backup\Powershell\PowerShellModules`) - Module collection  
- **LazyAdmin** (`c:\backup\LazyAdmin`) - Administrative utilities

## ✨ Features

### 🎨 Multiple Profile Modes
- **🧛‍♂️ Dracula** - Enhanced theme with productivity features (Default)
- **🚀 MCP** - Model Context Protocol with AI integration
- **⚡ LazyAdmin** - System administration utilities
- **🎯 Minimal** - Lightweight setup
- **🛠️ Custom** - User-defined configuration

### 💻 VS Code Integration
- **Debug/Run Configurations** - Profile-aware debugging
- **Task Integration** - Built-in tasks for profile management
- **Multiple Terminal Profiles** - One-click profile switching
- **IntelliSense Support** - Enhanced PowerShell development

### 📦 Module Management
- **Automatic Path Configuration** - All repositories in PSModulePath
- **Nested Module Support** - Provider/Category organization
- **Portable Configuration** - Works across different systems

## 🚀 Quick Start

### Option 1: Interactive Setup (Recommended)
```powershell
.\Start-UnifiedProfile.ps1
```

### Option 2: Quick Setup with Defaults
```powershell
.\Start-UnifiedProfile.ps1 -Quick
```

### Option 3: Full Setup with All Features
```powershell
.\Start-UnifiedProfile.ps1 -Full
```

## 🔧 Manual Installation

If you prefer manual setup:

```powershell
# 1. Setup the unified profile system
.\Setup-UnifiedProfile.ps1 -Mode Dracula -SetupVSCode -InstallDependencies -ConfigureSystemProfile

# 2. Configure module paths (optional)
.\Configure-ModulePath.ps1 -AddToPath -Persistent

# 3. Import and initialize
Import-Module UnifiedPowerShellProfile
Initialize-UnifiedProfile -Mode Dracula -VSCodeIntegration
```

## 💻 VS Code Usage

### Task Integration
Open VS Code and use **Ctrl+Shift+P** → **Tasks: Run Task**:
- **🚀 Initialize Unified Profile** - Setup profile with mode selection
- **🎯 Switch Profile Mode** - Interactive mode switching
- **🧹 Setup Unified Profile System** - One-click system setup
- **🔧 Test Profile Configuration** - Validate setup

### Debug Configurations
Press **F5** to access profile-aware debug configurations:
- **PowerShell: Launch Current File (Unified)** - Debug with current profile
- **PowerShell: Interactive Session (Dracula/MCP/LazyAdmin)** - Mode-specific sessions
- **PowerShell: Debug Current File (Enhanced)** - Enhanced debugging

### Terminal Profiles
Use **Ctrl+`** and select from available profiles:
- **PowerShell (Unified)** - Default with Dracula mode
- **PowerShell (MCP)** - AI-assisted development
- **PowerShell (LazyAdmin)** - Administrative tasks
- **PowerShell (Clean)** - No profile for testing

## 🎮 Available Commands

### Core Commands
```powershell
# Profile management
Initialize-UnifiedProfile -Mode Dracula    # Initialize specific mode
Switch-ProfileMode                          # Interactive mode switching
Show-AvailableProfiles                     # Show status and available modes
Test-ProfileConfiguration                   # Validate setup

# Workspace management
Set-WorkspaceProfile -WorkspaceType PowerShell -ProfileMode Dracula
New-VSCodeWorkspace -WorkspaceRoot . -ProfileMode MCP
Update-ModulePath -Force
```

### Aliases
```powershell
profile-init        # Initialize-UnifiedProfile
profile-switch      # Switch-ProfileMode  
profile-status      # Show-AvailableProfiles
profile-test        # Test-ProfileConfiguration
workspace-setup     # Set-WorkspaceProfile
```

## 📁 Repository Structure

```
PowerShell/
├── Modules/
│   └── UnifiedPowerShellProfile/          # Main unified system
├── Theme/                                 # Dracula themes
├── Microsoft.PowerShell_profile_Dracula.ps1
├── Microsoft.PowerShell_profile_MCP.ps1
├── Setup-UnifiedProfile.ps1              # Setup script
├── Start-UnifiedProfile.ps1              # Quick start
└── .vscode/                              # VS Code integration
    ├── tasks.json                        # Profile tasks
    ├── launch.json                       # Debug configs
    └── settings.json                     # Workspace settings

PowerShellModules/
├── Microsoft/                            # Microsoft modules
├── Custom/                              # Your custom modules
└── [Provider]/[Module]/                 # Categorized modules

LazyAdmin/
├── ActiveDirectory/                      # AD utilities
├── Exchange/                            # Exchange management
├── Azure/                               # Azure tools
└── PowerShell Profile.ps1              # LazyAdmin profile
```

## 🔧 Configuration

### Profile Mode Configuration
Edit `Modules/UnifiedPowerShellProfile/Config/DefaultProfiles.json` to customize:
- Default modules per mode
- Theme configurations  
- Feature enablement
- Workspace types

### VS Code Settings
The system automatically configures VS Code with:
- PowerShell formatting rules
- GitHub Copilot integration
- Dracula theme
- Terminal profiles
- Debug configurations

### Module Path Management
The system automatically adds these paths to PSModulePath:
- `C:\backup\Powershell\Modules`
- `C:\backup\Powershell\PowerShellModules`
- `C:\backup\LazyAdmin`
- `$env:USERPROFILE\Documents\PowerShell\Modules`

## 🧪 Testing

Test your configuration:
```powershell
# Run comprehensive tests
Test-ProfileConfiguration

# Test specific profile mode
Initialize-UnifiedProfile -Mode MCP
profile-test

# Validate VS Code integration
# Open VS Code and run: Tasks → 🔧 Test Profile Configuration
```

## 🐛 Troubleshooting

### Common Issues

**Module not found:**
```powershell
# Reinstall the module
.\Setup-UnifiedProfile.ps1 -Force
```

**VS Code tasks not working:**
```powershell
# Regenerate VS Code configuration
New-VSCodeWorkspace -WorkspaceRoot . -ProfileMode Dracula
```

**Profile not loading:**
```powershell
# Check profile status
Show-AvailableProfiles

# Reinitialize
Initialize-UnifiedProfile -Mode Dracula -Force
```

**Module path issues:**
```powershell
# Update module paths
Update-ModulePath -Force

# Or use the legacy script
.\Configure-ModulePath.ps1 -AddToPath -Persistent
```

## 🌟 Benefits

### For Development
- **Consistent Environment** - Same profile across all repositories
- **Quick Switching** - Change modes instantly based on task
- **VS Code Integration** - Seamless debugging and task execution
- **Module Discovery** - All modules automatically available

### For Administration  
- **LazyAdmin Integration** - Full admin toolkit available
- **Profile Isolation** - Switch to admin mode when needed
- **Repository Organization** - Keep modules categorized

### For AI Development
- **MCP Support** - Model Context Protocol integration
- **GitHub Copilot** - Enhanced AI assistance
- **Smart Completion** - AI-powered suggestions

## 🔮 Future Enhancements

- **Profile Templates** - Save and share profile configurations
- **Module Marketplace** - Easy module discovery and installation
- **Cloud Sync** - Sync profiles across machines
- **Advanced Theming** - Custom theme builder
- **Performance Monitoring** - Profile load time optimization

## 📄 License

MIT License - Feel free to use and modify for your needs.

---

**🎉 Enjoy your unified PowerShell experience!** 

For questions or issues, check the troubleshooting section or examine the module source code in `Modules/UnifiedPowerShellProfile/`.
