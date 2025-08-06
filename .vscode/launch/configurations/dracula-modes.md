# 🧛‍♂️ Dracula Profile Mode Configurations

The Dracula profile mode offers multiple variants optimized for different use cases, all with enhanced smart navigation features.

## 🎯 Available Variants

### 🧛‍♂️ Dracula Enhanced (Default)
**Launch Configuration:** `🧛‍♂️ Dracula Mode (+ Smart Navigation)`

The complete Dracula experience with all productivity features:
- **Smart CamelCase Navigation** - Intelligent word boundaries
- **International Diacritics Support** - Full Unicode character handling
- **Git Status Integration** - Real-time repository status
- **Enhanced PSReadLine** - Advanced command editing
- **Performance Monitoring** - Startup time tracking
- **Real-time Linting** - PSScriptAnalyzer integration

```powershell
# Environment Variables
$env:DRACULA_ENHANCED_MODE = "true"
$env:ENABLE_CAMELCASE_NAV = "true"
$env:ENABLE_DIACRITICS = "true"
$env:ENABLE_GIT_STATUS = "true"
```

### 🧛‍♂️ Dracula Performance
**Launch Configuration:** `🧛‍♂️ Dracula Performance Mode`

Optimized for speed while maintaining core Dracula features:
- **Essential Navigation** - Core CamelCase support
- **Minimal Git Integration** - Basic status only
- **Fast Startup** - Optimized loading sequence
- **Core Features Only** - Essential functionality

```powershell
# Environment Variables
$env:DRACULA_PERFORMANCE_MODE = "true"
$env:ENABLE_CAMELCASE_NAV = "true"
$env:MINIMAL_GIT_STATUS = "true"
```

### 🧛‍♂️ Dracula Minimal
**Launch Configuration:** `🧛‍♂️ Dracula Minimal Mode`

Lightweight Dracula theme with basic features:
- **Theme Only** - Visual styling without heavy features
- **Basic Navigation** - Standard PowerShell navigation
- **No Git Integration** - Fastest startup time
- **Essential PSReadLine** - Basic command editing

```powershell
# Environment Variables
$env:DRACULA_MINIMAL_MODE = "true"
$env:MINIMAL_FEATURES = "true"
```

### 🧛‍♂️ Dracula Silent
**Launch Configuration:** `🧛‍♂️ Dracula Silent Mode`

Silent startup with full features loaded in background:
- **Silent Loading** - No startup messages
- **Background Initialization** - Features load asynchronously
- **Full Feature Set** - All capabilities available after loading
- **Professional Appearance** - Clean startup for presentations

```powershell
# Environment Variables
$env:DRACULA_SILENT_MODE = "true"
$env:SILENT_STARTUP = "true"
$env:BACKGROUND_LOADING = "true"
```

## 🎨 Smart Navigation in Dracula Mode

### 🐪 CamelCase Navigation Examples
Dracula mode provides intelligent navigation for PowerShell commands:

```powershell
# Navigation Examples
Get-ChildItem              # Ctrl+Left/Right: Get | Child | Item
New-DraculaConfiguration   # Ctrl+Left/Right: New | Dracula | Configuration
Install-UnifiedProfile     # Ctrl+Left/Right: Install | Unified | Profile
Set-DraculaThemeOptions   # Ctrl+Left/Right: Set | Dracula | Theme | Options
```

### 🌍 International Characters
Full support for international naming conventions:

```powershell
# Czech
Get-SouborůSNázvem-čeština    # Smart navigation handles diacritics
Set-KonfiguraceÚložiště      # Proper word boundary detection

# German  
New-DateiMitUmlauten-größe   # Handles umlauts correctly
Get-VariableÄöü              # Full Unicode support

# Spanish
Install-FunciónConAcentos    # Accent-aware navigation
Set-ConfiguraciónEspañol     # Proper character boundaries
```

## 🔧 Configuration Options

### Theme Customization
```powershell
# Dracula Theme Settings
$DraculaConfig = @{
    Background = "#282a36"
    Foreground = "#f8f8f2"
    CurrentLine = "#44475a"
    Comment = "#6272a4"
    Cyan = "#8be9fd"
    Green = "#50fa7b"
    Orange = "#ffb86c"
    Pink = "#ff79c6"
    Purple = "#bd93f9"
    Red = "#ff5555"
    Yellow = "#f1fa8c"
}
```

### PSReadLine Enhancement
```powershell
# Enhanced Dracula PSReadLine Configuration
Set-PSReadLineOption -Colors @{
    Command                = 'Magenta'
    Number                 = 'Red'
    Member                 = 'Cyan'
    Operator               = 'DarkGray'
    Type                   = 'Yellow'
    Variable               = 'Green'
    Parameter              = 'DarkCyan'
    ContinuationPrompt     = 'DarkYellow'
    Default                = 'White'
}

# Smart Navigation Settings
Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord
Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
Set-PSReadLineKeyHandler -Key Ctrl+Backspace -Function BackwardKillWord
Set-PSReadLineKeyHandler -Key Ctrl+Delete -Function KillWord
```

## 🧪 Testing Dracula Configurations

### Quick Validation
**Launch Configuration:** `🧪 Test Dracula Configuration`

Tests all Dracula-specific features:
- Theme loading verification
- Navigation feature testing
- Performance validation
- Module dependency checking

### Interactive Demo
**Launch Configuration:** `🎨 Demo Dracula Features`

Interactive demonstration of:
- CamelCase navigation training
- Diacritics support testing
- Git integration showcase
- Performance monitoring display

## 🎯 Best Practices

### 1. Start with Enhanced Mode
Begin with `🧛‍♂️ Dracula Enhanced` to experience all features, then optimize based on your needs.

### 2. Performance Tuning
If startup time is important:
1. Try `🧛‍♂️ Dracula Performance` first
2. Fall back to `🧛‍♂️ Dracula Minimal` if needed
3. Use `🧛‍♂️ Dracula Silent` for presentations

### 3. Feature Customization
Customize features through environment variables:
```powershell
# Custom feature set
$env:DRACULA_ENHANCED_MODE = "true"
$env:ENABLE_CAMELCASE_NAV = "true"
$env:ENABLE_DIACRITICS = "false"  # Disable if not needed
$env:ENABLE_GIT_STATUS = "true"
$env:MINIMAL_STARTUP_MESSAGES = "true"
```

### 4. Testing Your Setup
Always test your configuration:
1. Run `🧪 Test Dracula Configuration`
2. Verify navigation with `🐪 Test CamelCase Navigation`
3. Check international support with `🌍 Test Diacritics Support`

## 🆘 Troubleshooting

### Theme Not Loading
```powershell
# Verify Dracula module installation
Get-Module -ListAvailable | Where-Object Name -like "*Dracula*"

# Reset theme configuration
Remove-Variable DraculaConfig -ErrorAction SilentlyContinue
```

### Navigation Not Working
```powershell
# Check PSReadLine version
Get-Module PSReadLine

# Verify key bindings
Get-PSReadLineKeyHandler | Where-Object Key -like "*Arrow*"
```

### Performance Issues
```powershell
# Enable performance debugging
$env:UNIFIED_PROFILE_DEBUG = "true"
$env:MEASURE_STARTUP_TIME = "true"

# Run performance test
& "🏆 Performance Benchmark (Quick)"
```

---

**Profile:** Dracula Enhanced Modes  
**Generated:** August 6, 2025  
**Compatibility:** PowerShell 7.x, VS Code 1.90+, Windows 10/11
