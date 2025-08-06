# 🚀 VS Code Launch Configuration System

Welcome to the comprehensive VS Code launch configuration system for the Unified PowerShell Profile ecosystem.

## 📁 Directory Structure

> **🚀 MIGRATION COMPLETE**: Launch configurations have been moved to `.vscode/launch.json` for proper VS Code integration! The ultra-performance folder now contains documentation and legacy references.

```
.vscode/
├── launch.json                   # 🚀 MAIN LAUNCH CONFIGURATIONS (Moved here!)
└── launch/                       # Launch system documentation
    ├── README-Launch-System.md   # This file - launch system overview
    ├── README.md                 # Quick start guide
    ├── ultra-performance/        # Legacy ultra-performance docs
    │   ├── README-Enhanced-Configurations.md  # Enhanced features documentation
    │   └── README.md             # Ultra-performance specific guide
    ├── configurations/           # Individual configuration docs
    │   ├── dracula-modes.md     # Dracula profile variants
    │   ├── mcp-modes.md        # Model Context Protocol configurations
    │   ├── lazyadmin-modes.md  # LazyAdmin configurations
    │   ├── minimal-modes.md    # Minimal profile configurations
    │   └── custom-modes.md     # Custom profile configurations
    ├── features/                # Feature-specific documentation
    │   ├── camelcase-navigation.md  # CamelCase navigation guide
    │   ├── diacritics-support.md   # International character support
    │   ├── performance-monitoring.md # Performance tracking features
    │   └── smart-linting.md        # Real-time PSScriptAnalyzer integration
    ├── testing/                # Testing and validation docs
    │   ├── profile-tests.md    # Profile configuration testing
    │   ├── module-validation.md # Module dependency validation
    │   ├── environment-analysis.md # Environment diagnostic testing
    │   └── health-checks.md    # System health verification
    ├── troubleshooting/        # Problem resolution guides
    │   ├── common-issues.md    # Frequently encountered problems
    │   ├── recovery-procedures.md # System recovery instructions
    │   └── diagnostic-tools.md # Diagnostic and debugging tools
    └── examples/               # Example configurations and usage
        ├── basic-setup.md      # Getting started examples
        ├── advanced-usage.md   # Power user configurations
        └── integration-examples.md # Integration with other tools
```

## 🎯 Key Components

### 🧛‍♂️ Profile Modes
- **Dracula** - Enhanced theme with productivity features
- **MCP** - Model Context Protocol integration
- **LazyAdmin** - System administration utilities
- **Minimal** - Lightweight setup with core features
- **Custom** - User-defined configurations

### 🎨 Smart Navigation Features
- **🐪 CamelCase Navigation** - Intelligent PowerShell command navigation
- **🌍 Diacritics Support** - International character handling
- **🔍 Real-time Linting** - PSScriptAnalyzer integration
- **📊 Performance Monitoring** - Startup time tracking

### 🧪 Testing & Validation
- **Profile Configuration Tests** - Comprehensive validation
- **Module Version Validation** - Dependency checking
- **Environment Analysis** - PowerShell environment diagnostics
- **Health Checks** - Quick module status verification

## 📚 Documentation Categories

### 📖 Getting Started
1. [Quick Start Guide](README.md)
2. [Basic Setup Examples](examples/basic-setup.md)
3. [Common Profile Modes](configurations/)

### 🔧 Configuration Guides
1. [Enhanced Configurations](ultra-performance/README-Enhanced-Configurations.md)
2. [Profile Mode Details](configurations/)
3. [Feature Configuration](features/)

### 🧪 Testing & Validation
1. [Testing Overview](testing/)
2. [Validation Procedures](testing/module-validation.md)
3. [Health Check Procedures](testing/health-checks.md)

### 🆘 Troubleshooting
1. [Common Issues](troubleshooting/common-issues.md)
2. [Recovery Procedures](troubleshooting/recovery-procedures.md)
3. [Diagnostic Tools](troubleshooting/diagnostic-tools.md)

## 🛠️ Usage Patterns

### Quick Launch
```json
F5 → Select Configuration → Run
```

### Task Integration
```json
Ctrl+Shift+P → Tasks: Run Task → Select Category
```

### Debug Mode
```json
F5 → Debug Configuration → Set Breakpoints → Run
```

## 🔗 Integration Points

- **VS Code Tasks** - Seamless task integration
- **PowerShell Modules** - Direct module interaction
- **Git Integration** - Version control awareness
- **Performance Monitoring** - Built-in benchmarking

---

**Generated:** August 6, 2025  
**System:** Unified PowerShell Profile Launch System v2.0  
**Compatibility:** VS Code 1.90+, PowerShell 7.x, Windows 10/11
