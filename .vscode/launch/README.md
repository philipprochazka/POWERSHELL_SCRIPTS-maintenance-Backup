# 🎯 VS Code Launch Configurations - Modular System

This directory contains a modular launch configuration system to improve VS Code debugging performance and organization.

## 🚨 Problem Solved

The original `launch.json` file was **354 lines** and contained outdated configurations:
- Redundant debug configurations
- Missing ultra-performance V3/V4 profiles
- No smart navigation integration
- Outdated PowerShell development patterns
- Poor organization for different testing scenarios

## 🏗️ Modern Architecture

### 📁 Updated Structure
```
.vscode/
├── launch.json                    # Modern, organized configurations
└── launch/                        # Future modular configurations
    ├── ultra-performance/         # 🔬 Ultra-performance debugging
    ├── unified-profile/           # 🚀 Unified profile debugging  
    ├── testing/                   # 🧪 Testing and validation
    └── documentation/             # 📚 Documentation builds
```

## 🎯 Configuration Categories

### ⚡ Core PowerShell Debugging
- **🚀 PowerShell: Launch Current File** - Debug any PowerShell script
- **🔗 PowerShell: Attach to Host Process** - Attach to running process
- **💬 PowerShell: Interactive Session** - Interactive debugging

### 🔬 Ultra-Performance Profiles (NEW!)
- **🔬 Ultra-Performance V4 (JIT + Smart Navigation)** - Latest V4 with JIT optimization
- **⚡ Ultra-Performance V3 (Memory Optimized)** - V3 with memory pooling
- **🏆 Interactive V4 Session (Smart Navigation)** - Interactive V4 debugging
- **🎯 Interactive V3 Session (Memory Pool)** - Interactive V3 debugging

### 🚀 Unified Profile System
- **🔧 Unified Profile System (Enhanced)** - Enhanced installation
- **🎮 Profile Mode Switcher** - Interactive profile switching

### 🧪 Performance Testing & Comparison
- **🏆 Ultra-Performance Comparison (Comprehensive)** - Full testing suite
- **📊 Performance Comparison (Quick)** - Quick performance tests
- **🔍 Performance Comparison (Standard)** - Standard benchmarking
- **📝 Lorem Ipsum Stress Test** - Stress testing with large data

### 🧛‍♂️ Dracula Profile Variants
- **🧛‍♂️ Dracula Profile (Enhanced Features)** - Full-featured Dracula
- **⚡ Dracula Profile (Performance Mode)** - Performance-optimized
- **🤫 Dracula Profile (Silent Mode)** - Silent operation
- **🎯 Dracula Profile (Minimal Mode)** - Minimal overhead

### 🎨 Smart Navigation & Feature Demos
- **🌍 Demo Enhanced Features (Smart Navigation)** - Full feature demo
- **🐪 CamelCase Navigation Demo** - CamelCase navigation features
- **🌍 Diacritics Support Demo** - International character support

### 🔐 Google Hardware Key Management
- **🔑 Google Hardware Key Setup** - Initial setup and configuration
- **🧪 Google Hardware Key Tests** - Testing and validation
- **🔐 Manage Google Hardware Key** - Key management operations

### 📚 Documentation & Build System
- **📚 Build Module Documentation (Enhanced)** - Full documentation build
- **📝 Build Documentation (Quick)** - Quick documentation updates
- **🔍 Build Documentation with Git Search** - Git-integrated builds

### 🧪 Testing & Validation
- **🧪 Unified Profile Tests** - Module testing
- **🧪 Run All Module Tests** - Comprehensive test suite
- **🔍 PSScriptAnalyzer Check** - Code quality analysis

## 🚀 Smart Navigation Features

### 🐪 CamelCase Navigation
The ultra-performance profiles include enhanced PSReadLine configuration with smart navigation:

- **Alt+Left/Right**: Smart CamelCase + diacritics navigation
- **Ctrl+Left/Right**: Standard word boundaries
- Perfect support for international variable names

### 🌍 International Support
Enhanced support for:
- Czech, Spanish, French, German, Polish, Hungarian characters
- Smart boundary detection for:
  - CamelCase and PascalCase
  - Underscores and hyphens
  - Dots and colons
  - International diacritics

### ⌨️ Navigation Examples
```powershell
# These work perfectly with Alt+Left/Right:
Get-ChildItem
New-PSSession
[System.IO.Path]::GetFileName
myVariable_withUnderscores
příkaz-sNázvem-čeština
función-conAcentos-español
```

## 🔧 Key Improvements

### ✅ Performance Optimizations
- **Updated V4 Profile**: JIT compilation optimization for sub-200ms startup
- **Smart Navigation**: Enhanced PSReadLine configuration
- **Memory Management**: Advanced memory pooling in V3/V4
- **Async Loading**: Background job management for modules

### ✅ Modern PowerShell Standards
- **Approved Verbs**: All functions use PowerShell approved verbs
- **Error Handling**: Robust error handling and fallbacks
- **Debugging Support**: Enhanced debugging with performance counters
- **Console Management**: Proper temporary console settings

### ✅ Enhanced Organization
- **Logical Grouping**: Related configurations grouped together
- **Clear Naming**: Emoji-prefixed descriptive names
- **Consistent Patterns**: Standardized parameter usage
- **Documentation**: Clear descriptions and usage patterns

## 📊 Usage

### Method 1: VS Code Debug Panel
1. Press `F5` or `Ctrl+Shift+D`
2. Select from organized configurations:
   - 🔬 Ultra-performance debugging
   - 🧪 Testing and validation
   - 🎨 Feature demonstrations
   - etc.

### Method 2: Quick Access (F5)
Press `F5` and select your preferred configuration from the dropdown.

## 🎯 Key Features

### 🔬 Ultra-Performance V4 Highlights
- **JIT Compilation**: Pre-compiled critical paths
- **Advanced Memory Pool**: Concurrent collections
- **Smart Navigation**: Enhanced PSReadLine with CamelCase support
- **Performance Counters**: Detailed startup metrics
- **Async Loading**: Background module loading

### 🚀 Development Workflow
1. **Start with V4**: Use "🏆 Interactive V4 Session (Smart Navigation)"
2. **Test Performance**: Run "🏆 Ultra-Performance Comparison (Comprehensive)"
3. **Debug Issues**: Use specific profile debug configurations
4. **Validate**: Run appropriate test configurations

## 💡 Best Practices

### Debugging Ultra-Performance Profiles
```powershell
# Enable performance debugging
$env:DRACULA_PERFORMANCE_DEBUG='true'
$env:DRACULA_SHOW_STARTUP='true'

# Use interactive sessions for development
# Non-interactive for pure performance testing
```

### Smart Navigation Setup
The V4 profile automatically configures:
- PSReadLine with enhanced navigation
- International character support
- CamelCase boundary detection
- Performance-optimized key bindings

## 🏆 Results

This modern launch system delivers:
- **Organized debugging**: Clear categories and purposes
- **Latest features**: Ultra-performance V3/V4 support
- **Smart navigation**: Enhanced PSReadLine integration
- **Better performance**: Optimized startup and debugging
- **Modern standards**: PowerShell development best practices

The PowerShell debugging environment is now more efficient, organized, and feature-rich while maintaining compatibility with existing workflows.
