# 🧛‍♂️ Dracula Enhanced PowerShell Theme

A comprehensive, beautiful, and feature-rich PowerShell theme inspired by the Dracula color palette. This theme transforms your PowerShell experience with enhanced visual appeal, productivity features, and vampire-themed fun!

## 🌟 Features

### 🎨 Visual Enhancements
- **Enhanced Oh My Posh theme** with system information, execution time, and git status
- **Advanced PSReadLine configuration** with Dracula colors and smart keybindings
- **Beautiful color scheme** using the complete Dracula palette
- **Custom prompt segments** showing RAM usage, shell info, and AWS profile

### ⌨️ Enhanced Keybindings
- `F7` - Interactive history browser with grid view
- `F9` - Quick system information command
- `Alt+C` - Color test command
- `Ctrl+Shift+F` - Smart command search
- `Ctrl+Shift+N` - PowerShell script template insertion
- `Ctrl+F` - Accept inline prediction
- Enhanced navigation with Alt+Arrow keys

### 🛠️ Productivity Tools
- **DraculaPowerPack module** with utility functions
- **Enhanced aliases** for common commands
- **Git integration** with colorized status
- **Directory tree viewer**
- **System information dashboard**
- **Automatic cleanup utilities**

### 🎭 Fun Features
- Random vampire-themed startup quotes
- ASCII art displays
- Dracula-themed command help
- Weather integration (placeholder)
- Script templates with vampire flair

## 📦 What's Included

1. **Microsoft.PowerShell_profile_Dracula.ps1** - Main profile file
2. **Theme/dracula-enhanced.omp.json** - Enhanced Oh My Posh theme
3. **Theme/PSReadLine-Dracula-Enhanced.ps1** - Advanced PSReadLine configuration
4. **Theme/DraculaPowerPack.psm1** - Utility functions module
5. **Install-DraculaTheme.ps1** - Automated installer
6. **README.md** - This documentation

## 🚀 Installation

### Automated Installation
```powershell
# Clone or download the theme files to your PowerShell directory
cd C:\backup\Powershell

# Run the installer
.\Install-DraculaTheme.ps1 -Backup
```

### Manual Installation
1. Backup your existing profile:
   ```powershell
   Copy-Item $PROFILE "$PROFILE.backup"
   ```

2. Copy the Dracula profile:
   ```powershell
   Copy-Item "Microsoft.PowerShell_profile_Dracula.ps1" $PROFILE
   ```

3. Copy theme files to your profile directory:
   ```powershell
   $profileDir = Split-Path $PROFILE -Parent
   Copy-Item "Theme" "$profileDir\Theme" -Recurse
   ```

## 📋 Prerequisites

### Required
- **PowerShell 7.0+**
- **PSReadLine 2.2.0+** - `Install-Module PSReadLine -Force`
- **Oh My Posh** - `winget install JanDeDobbeleer.OhMyPosh`

### Optional (Recommended)
- **Terminal-Icons** - `Install-Module Terminal-Icons`
- **z (directory jumper)** - `Install-Module z`
- **Az.Tools.Predictor** - `Install-Module Az.Tools.Predictor`

## 🎯 Quick Start

After installation, restart PowerShell and try these commands:

```powershell
# Show available Dracula commands
help-dracula

# Display color palette
colors

# Get a vampire quote
quote

# Run a demonstration
demo

# Show system information
sysinfo

# Create a new script
newscript MyScript

# Show directory tree
tree

# Enhanced git status
gs
```

## ⌨️ Key Bindings Reference

| Key Combination | Function |
|----------------|----------|
| `F7` | 🕰️ History Browser |
| `F9` | 📊 System Info Command |
| `Alt+C` | 🎨 Color Test |
| `Ctrl+Shift+F` | 🔍 Smart Search |
| `Ctrl+Shift+N` | 🚀 Script Template |
| `Ctrl+F` | 🔮 Accept Prediction |
| `Ctrl+Shift+F` | 🔮 Accept Word |
| `Tab` | Menu Complete |
| `Ctrl+R` | Reverse Search |
| `Alt+→` | Move to End of Line |
| `Alt+←` | Move to Start of Line |

## 🎨 Color Palette

The theme uses the official Dracula color palette:

- **Background**: `#282a36`
- **Current Line**: `#44475a`
- **Foreground**: `#f8f8f2`
- **Comment**: `#6272a4`
- **Cyan**: `#8be9fd`
- **Green**: `#50fa7b`
- **Orange**: `#ffb86c`
- **Pink**: `#ff79c6`
- **Purple**: `#bd93f9`
- **Red**: `#ff5555`
- **Yellow**: `#f1fa8c`

## 🛠️ Customization

### Modifying Colors
Edit `Theme/PSReadLine-Dracula-Enhanced.ps1` and update the `$DraculaColors` hashtable.

### Adding Custom Functions
Add your functions to `Theme/DraculaPowerPack.psm1` or create your own module.

### Customizing Oh My Posh
Edit `Theme/dracula-enhanced.omp.json` to modify prompt segments.

## 📱 Terminal Compatibility

Tested and optimized for:
- **Windows Terminal** ✅
- **PowerShell 7** ✅
- **VS Code Integrated Terminal** ✅
- **Windows PowerShell ISE** ⚠️ (Limited support)

## 🤝 Contributing

Feel free to contribute improvements:
1. Fork the repository
2. Create feature branch
3. Make your changes
4. Test thoroughly
5. Submit pull request

## 📄 License

This theme is released under the MIT License. See LICENSE file for details.

## 🙏 Credits

- **Dracula Theme** - [https://draculatheme.com/](https://draculatheme.com/)
- **Oh My Posh** - [https://ohmyposh.dev/](https://ohmyposh.dev/)
- **PSReadLine** - Microsoft PowerShell Team

## 🧛‍♂️ Support

If you encounter issues:
1. Check prerequisites are installed
2. Verify PowerShell execution policy
3. Review error messages in profile loading
4. Check terminal font supports Unicode characters

---

**🌙 Welcome to the dark side of PowerShell! 🌙**

*"In the darkness, we find the light of code."* ✨
