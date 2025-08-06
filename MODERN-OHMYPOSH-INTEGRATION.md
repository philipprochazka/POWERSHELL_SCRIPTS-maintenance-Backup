# Modern Oh My Posh v26+ Integration Guide

## 🚀 Overview

With Oh My Posh evolving from v7.85.2 to v26.18.0, significant changes have been introduced including new runtime routines and an improved executable approach. This guide covers the enhanced integration for your PowerShell profiles.

## 📋 What's Changed in v26+

### Key Improvements
- **New Runtime Architecture**: Enhanced performance with modern executable approach
- **Improved Initialization**: Better startup times and resource management  
- **Enhanced Theme System**: More robust theme loading and customization
- **Better Error Handling**: Graceful fallbacks and improved diagnostics

### Breaking Changes
- Some legacy initialization methods may be deprecated
- New command-line flags and options
- Updated theme format compatibility

## 🛠️ Installation & Setup

### Quick Installation
```powershell
# Run the installation script
.\Install-ModernOhMyPosh.ps1 -InstallThemes -UpdateProfiles
```

### Alternative Installation Methods
```powershell
# Using Winget (recommended)
winget install JanDeDobbeleer.OhMyPosh

# Using Scoop
.\Install-ModernOhMyPosh.ps1 -UseScoop -InstallThemes

# Force reinstall/upgrade
.\Install-ModernOhMyPosh.ps1 -Force -InstallThemes -UpdateProfiles
```

### VS Code Tasks
Use the convenient VS Code tasks for installation and testing:
- **🚀 Install Modern Oh My Posh v26+** - Standard installation
- **⚡ Install Modern Oh My Posh (Scoop)** - Scoop-based installation  
- **🔄 Force Reinstall Modern Oh My Posh** - Force upgrade/reinstall

## 🎨 Theme Integration

### Enhanced Theme Support
The modern integration includes support for:
- **Dracula Enhanced** - Your custom enhanced Dracula theme
- **Dracula Performance** - Optimized for fast loading
- **Dracula Minimal** - Lightweight variant
- **Remote Themes** - Direct loading from your fork at `https://github.com/philipprochazka/oh-my-posh`

### Theme Loading Function
```powershell
# Load themes using the modern function
Initialize-ModernOhMyPosh -Mode "Dracula"
Initialize-ModernOhMyPosh -Mode "Performance" 
Initialize-ModernOhMyPosh -Mode "Minimal"
```

### Custom Theme Paths
```powershell
# Use custom theme file
Initialize-ModernOhMyPosh -ThemePath "~/my-custom-theme.omp.json"

# Force v26+ initialization 
Initialize-ModernOhMyPosh -Mode "Dracula" -ForceV26
```

## 📂 File Structure

### New Files Added
```
PowerShellModules/UnifiedPowerShellProfile/Scripts/
├── Initialize-ModernOhMyPosh.ps1      # Modern initialization functions
├── Initialize-ProfileTheme.ps1        # Updated theme loader (enhanced)

Root/
├── Install-ModernOhMyPosh.ps1          # Installation & upgrade script
├── Test-ModernOhMyPosh.ps1            # Comprehensive testing suite
├── Microsoft.PowerShell_profile_Dracula.ps1           # Updated main profile
├── Microsoft.PowerShell_profile_Dracula_Performance.ps1 # Updated performance profile
└── .vscode/tasks.json                  # New VS Code tasks added
```

### Updated Profile Integration
Your PowerShell profiles have been enhanced with modern Oh My Posh support:

1. **Automatic Version Detection** - Detects v26+ vs legacy versions
2. **Graceful Fallbacks** - Falls back to legacy methods if modern fails
3. **Performance Optimized** - Faster loading with lazy initialization
4. **Enhanced Error Handling** - Better diagnostics and recovery

## 🧪 Testing & Validation

### Quick Testing
```powershell
# Run quick tests
.\Test-ModernOhMyPosh.ps1 -TestMode Quick
```

### Comprehensive Testing
```powershell  
# Full test suite with report generation
.\Test-ModernOhMyPosh.ps1 -TestMode Comprehensive -GenerateReport
```

### VS Code Testing Tasks
- **🧪 Test Modern Oh My Posh (Quick)** - Fast validation
- **📊 Test Modern Oh My Posh (Comprehensive)** - Full test suite
- **🎨 Test Modern Oh My Posh Themes** - Theme loading tests
- **📋 Check Oh My Posh Version** - Version information

## 🔧 Functions Reference

### Core Functions

#### `Initialize-ModernOhMyPosh`
Enhanced Oh My Posh initialization with v26+ support.

**Parameters:**
- `Mode` - Theme mode (Dracula, Performance, Minimal, Clean, MCP, Custom)
- `ThemePath` - Custom theme file path
- `ForceV26` - Force modern initialization

**Examples:**
```powershell
Initialize-ModernOhMyPosh -Mode "Dracula"
Initialize-ModernOhMyPosh -ThemePath "~/themes/custom.omp.json" -ForceV26
```

#### `Install-ModernOhMyPosh`
Installs or upgrades Oh My Posh to v26+ with custom themes.

**Parameters:**
- `Force` - Force reinstall
- `UseScoop` - Use Scoop instead of winget
- `InstallThemes` - Install custom themes
- `SkipValidation` - Skip post-install validation

#### `Get-OhMyPoshThemePath`
Resolves theme paths with enhanced discovery including your fork.

**Parameters:**
- `Mode` - Theme mode to resolve

### Utility Functions

#### `Initialize-ModernOhMyPoshV26`
Direct v26+ initialization method.

#### `Initialize-LegacyOhMyPosh` 
Legacy fallback initialization.

#### `Install-CustomThemes`
Downloads and installs themes from your Oh My Posh fork.

## 🎯 Profile Integration Details

### Main Dracula Profile
The main profile (`Microsoft.PowerShell_profile_Dracula.ps1`) now includes:

1. **Modern Initialization Check** - Attempts modern v26+ loading first
2. **Legacy Fallback** - Falls back to legacy methods if needed
3. **Enhanced Error Messages** - Better user guidance on failures

### Performance Profile  
The performance profile includes:
- **Lazy Loading** - Themes loaded only when needed
- **Debug Support** - Enhanced debugging for troubleshooting
- **Minimal Fallbacks** - Simple prompts if Oh My Posh fails

## 🚨 Troubleshooting

### Common Issues

#### "Oh My Posh not found"
```powershell
# Check installation
Get-Command oh-my-posh -ErrorAction SilentlyContinue

# Install if missing
.\Install-ModernOhMyPosh.ps1
```

#### "Theme loading failed"
```powershell
# Test theme paths
Get-OhMyPoshThemePath -Mode "Dracula"

# Test with verbose output
Initialize-ModernOhMyPosh -Mode "Dracula" -Verbose
```

#### "Version detection failed"
```powershell
# Check version manually
oh-my-posh version

# Force modern initialization
Initialize-ModernOhMyPosh -Mode "Dracula" -ForceV26
```

### Diagnostic Commands
```powershell
# Full diagnostic test
.\Test-ModernOhMyPosh.ps1 -TestMode Comprehensive -GenerateReport

# Check version and paths
📋 Check Oh My Posh Version  # (VS Code task)

# Test theme loading
🎨 Test Modern Oh My Posh Themes  # (VS Code task)
```

## 🔄 Migration from Legacy

### Automatic Migration
The enhanced profiles automatically handle migration:
1. Detect current Oh My Posh version
2. Use modern methods for v26+
3. Fall back to legacy methods for older versions
4. Provide upgrade guidance

### Manual Migration Steps
If you need to manually migrate:

1. **Backup Current Setup**
   ```powershell
   Copy-Item $PROFILE "$PROFILE.backup"
   ```

2. **Install Modern Version**
   ```powershell
   .\Install-ModernOhMyPosh.ps1 -Force
   ```

3. **Update Profiles**
   ```powershell
   # Profiles are automatically updated during installation
   ```

4. **Test Integration**
   ```powershell
   .\Test-ModernOhMyPosh.ps1 -TestMode Standard
   ```

## 🌟 Custom Theme Development

### Your Oh My Posh Fork
The integration supports themes from your fork at `https://github.com/philipprochazka/oh-my-posh`:

- **dracula-enhanced.omp.json** - Your enhanced Dracula theme
- **dracula-performance.omp.json** - Performance-optimized variant
- **dracula-minimal.omp.json** - Minimal lightweight theme

### Theme Priority Order
1. Local theme files in `Theme/` directory
2. Themes from your fork (philipprochazka/oh-my-posh)
3. Official themes from JanDeDobbeleer/oh-my-posh
4. Built-in fallback themes

## 📊 Performance Considerations

### v26+ Performance Benefits
- **Faster Startup** - Improved initialization routines
- **Better Resource Usage** - More efficient memory management
- **Reduced Overhead** - Optimized command execution

### Benchmarking
Use the included performance tests:
```powershell
# Quick performance check
.\Test-ModernOhMyPosh.ps1 -TestMode Standard

# Detailed performance analysis
.\Test-ModernOhMyPosh.ps1 -TestMode Comprehensive -GenerateReport
```

## 🔗 Related Documentation

- [Oh My Posh Official Documentation](https://ohmyposh.dev/docs/)
- [Windows Terminal Integration](https://ohmyposh.dev/docs/installation/windows)
- [Theme Customization Guide](https://ohmyposh.dev/docs/configuration/overview)
- [Your Oh My Posh Fork](https://github.com/philipprochazka/oh-my-posh)

## 📝 Changelog

### v26+ Integration Features
- ✅ Automatic version detection and modern initialization
- ✅ Enhanced theme loading with your custom fork support
- ✅ Comprehensive testing and validation suite
- ✅ VS Code tasks for easy installation and testing
- ✅ Backward compatibility with legacy versions
- ✅ Performance optimization and lazy loading
- ✅ Enhanced error handling and diagnostics
- ✅ Custom theme installation from your fork

### Improved Profile Features
- ✅ Modern Oh My Posh v26+ support in all profile variants
- ✅ Enhanced Dracula theme integration
- ✅ Performance profile optimizations
- ✅ Graceful fallbacks for all scenarios
- ✅ Better user guidance and error messages

---

**🧛‍♂️ Enjoy your enhanced Dracula PowerShell experience with modern Oh My Posh v26+!**
