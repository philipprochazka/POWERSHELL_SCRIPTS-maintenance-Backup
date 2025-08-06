# 🚀 Enhanced Unified Profile Launch & Task Configurations

This directory contains comprehensive VS Code launch and task configurations for the Unified PowerShell Profile system with advanced features including CamelCase navigation and international diacritics support.

## 📁 Files Overview

- **`launch.json`** - Complete launch configurations for all profile modes with smart navigation
- **`tasks-enhanced.json`** - Comprehensive task definitions for installation, testing, and validation
- **`README.md`** - This documentation file

## 🎯 Key Features

### 🧛‍♂️ All Profile Modes with Smart Navigation
Every profile mode now includes:
- **🐪 CamelCase Navigation** - Smart word boundaries for PowerShell commands
- **🌍 Diacritics Support** - International character navigation (Czech, Spanish, French, German, Polish, Hungarian)
- **Real-time Linting** - PSScriptAnalyzer integration
- **Performance Monitoring** - Startup time tracking and optimization

### 📦 Installation & Setup Launchers
- **Quick Install** - Dracula mode with smart navigation
- **Full Install** - All features enabled
- **Interactive Install** - Menu-driven setup
- **System-Wide Install** - Administrator installation

### 🧪 Testing & Validation
- **Profile Configuration Tests** - Comprehensive validation
- **Module Version Validation** - Dependency checking
- **Environment Analysis** - PowerShell environment diagnostics
- **Health Checks** - Quick module status verification

### 🎨 Smart Navigation Testing
- **CamelCase Navigation Demo** - Interactive training with examples
- **Diacritics Support Demo** - International character testing
- **Enhanced Features Demo** - Complete feature showcase

### 🏆 Performance Benchmarking
- **Comprehensive Performance Tests** - Full benchmarking suite
- **Quick Performance Tests** - Fast validation
- **Lorem Ipsum Stress Tests** - Large text handling

## 🚀 Available Profile Modes

Each profile mode supports the enhanced navigation features:

### 🧛‍♂️ Dracula Mode
- **Enhanced theme** with productivity features
- **Git status indicators**
- **Advanced PSReadLine configuration**
- **Smart navigation enabled by default**

### 🚀 MCP Mode
- **Model Context Protocol** integration
- **AI-powered assistance**
- **GitHub Copilot optimization**
- **Smart navigation for AI workflows**

### ⚡ LazyAdmin Mode
- **System administration** utilities
- **Network discovery tools**
- **Advanced cmdlet collections**
- **Smart navigation for admin commands**

### 🎯 Minimal Mode
- **Lightweight setup** with core features
- **Fast startup time**
- **Essential tools only**
- **Smart navigation for basic commands**

### 🛠️ Custom Mode
- **User-defined configuration**
- **Flexible customization**
- **Extensible framework**
- **Smart navigation for custom workflows**

## 🎨 Smart Navigation Features

### 🐪 CamelCase Navigation
Intelligently handles PowerShell command structure:
```powershell
Get-ChildItem          # Ctrl+Left/Right jumps: Get | Child | Item
New-VSCodeWorkspace    # Ctrl+Left/Right jumps: New | VSCode | Workspace
Initialize-UnifiedProfile  # Smart word boundaries
```

### 🌍 International Diacritics Support
Full support for accented characters:
```powershell
# Czech
příkaz-sNázvem-čeština_proměnná

# Spanish  
función-conAcentos-español_variable

# French
commentaireAvecAccents-français_données

# German
funktionMitUmlauten-größe_variableÄöü

# Polish
funkcja-zPolskimiZnakami-ąćęłńóśźż_zmienna
```

## 🔧 Environment Variables

The enhanced configurations use these environment variables for feature control:

- **`ENABLE_CAMELCASE_NAV=true`** - Enables CamelCase navigation
- **`ENABLE_DIACRITICS=true`** - Enables diacritics support  
- **`UNIFIED_PROFILE_DEBUG=true`** - Enables debug mode
- **`DRACULA_ENHANCED_MODE=true`** - Enables Dracula enhancements
- **`MCP_ENHANCED_MODE=true`** - Enables MCP enhancements
- **`LAZYADMIN_ENHANCED_MODE=true`** - Enables LazyAdmin enhancements

## 🛠️ Usage Instructions

### Using Launch Configurations

1. **Open VS Code** in your PowerShell workspace
2. **Press F5** or **Ctrl+F5** to open the launch menu
3. **Select a configuration** from the enhanced list
4. **Choose input parameters** when prompted (profile mode, test mode, etc.)

### Using Tasks

1. **Open Command Palette** (`Ctrl+Shift+P`)
2. **Type "Tasks: Run Task"**
3. **Select from organized categories:**
   - 🚀 Installation & Setup
   - 🎨 Profile Mode Management  
   - 🧪 Testing & Validation
   - 🎨 Smart Navigation Features
   - 🏆 Performance Testing
   - 🔧 Maintenance & Utilities
   - 🆘 Troubleshooting & Recovery

### Quick Start Examples

#### Install with Smart Navigation
```json
"🚀 Install Unified Profile System (Enhanced)"
```

#### Test CamelCase Navigation
```json
"🐪 Test CamelCase Navigation"
```

#### Test Diacritics Support
```json
"🌍 Test Diacritics Support"
```

#### Switch Profile Mode
```json
"🧛‍♂️ Switch to Dracula Mode (+ Smart Navigation)"
```

## 🧪 Testing Your Setup

### Quick Health Check
Run the "🎯 Module Health Check (Quick)" task to verify all dependencies.

### Comprehensive Testing
Use "🧪 Test Profile Configuration (Comprehensive)" for full validation.

### Feature Demos
Try "🎨 Demo Enhanced Features (Interactive)" to see all capabilities.

## 🆘 Troubleshooting

### Common Issues

**Module not found:**
- Run "🆘 Diagnose Profile Issues" task
- Check module paths with "🔍 PowerShell Environment Analysis"

**Navigation not working:**
- Verify environment variables are set
- Run "🐪 Test CamelCase Navigation" or "🌍 Test Diacritics Support"

**Performance issues:**
- Use "🏆 Performance Benchmark (Quick)" to identify bottlenecks
- Run "🧹 Clean Module Cache" to clear cached modules

### Recovery Options

**Reset Configuration:**
- Use "🔧 Reset Profile Configuration" (requires confirmation)

**Reload System:**
- Use "🔄 Reload Unified Profile System"

## 📊 Inputs and Parameters

The launch configurations support these input parameters:

### Profile Mode Selection
- Dracula
- MCP
- LazyAdmin  
- Minimal
- Custom

### Test Mode Selection
- Quick
- Standard
- Comprehensive
- LoremIpsum

### Feature Demo Selection
- All
- CamelCase
- Diacritics
- GitStatus
- Performance

## 🎯 Best Practices

1. **Start with Quick Install** - Use "⚡ Quick Install (Dracula + Smart Navigation)"
2. **Test Navigation Features** - Run CamelCase and Diacritics tests
3. **Validate Environment** - Use health check tasks regularly
4. **Monitor Performance** - Run periodic benchmarks
5. **Keep Updated** - Use "📚 Update Documentation" and reload tasks

## 🔄 Integration with Existing Workflows

The enhanced configurations are designed to work alongside existing VS Code workflows:

- **Compatible** with existing launch configurations
- **Extends** current task definitions
- **Preserves** backwards compatibility
- **Enhances** developer experience

## 💡 Pro Tips

- Use **emoji prefixes** to quickly identify task categories
- **Environment variables** can be set globally for consistent behavior
- **Interactive demos** are great for training new team members
- **Diagnostic tasks** help quickly identify and resolve issues
- **Performance benchmarks** help optimize your specific use case

---

**Generated:** August 6, 2025  
**Version:** Enhanced Unified Profile v2.0  
**Compatibility:** PowerShell 7.x, VS Code 1.90+, Windows 10/11
