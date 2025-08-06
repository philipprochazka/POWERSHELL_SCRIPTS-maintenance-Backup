# 🔬 Ultra-Performance Launch Configurations - Legacy Documentation

> **🚀 MIGRATION NOTICE**: Launch configurations have been moved to `../.vscode/launch.json` for proper VS Code integration! This directory now contains documentation and legacy references.

Ultra-performance profile debugging configurations with smart navigation support are now available in the main VS Code launch configurations.

## 🎯 Available Configurations (Now in ../.vscode/launch.json)

> **Access via VS Code**: Press `F5` → Select from dropdown → Choose ultra-performance configurations

### 🔬 Ultra-Performance V4 (JIT + Smart Navigation)
**Latest ultra-performance profile with JIT compilation optimization**

- **Target**: Sub-200ms startup
- **Features**: JIT compilation, advanced memory pooling, smart navigation
- **Use Case**: Production-ready ultra-fast startup debugging
- **Console**: Non-interactive for pure performance testing

### ⚡ Ultra-Performance V3 (Memory Optimized)
**Memory-optimized ultra-performance profile**

- **Target**: Sub-200ms startup  
- **Features**: Memory pooling, path caching, optimized prompt
- **Use Case**: Memory-efficient debugging and testing
- **Console**: Non-interactive for performance validation

### 🏆 Interactive V4 Session (Smart Navigation)
**Interactive debugging with V4 ultra-performance**

- **Target**: Interactive development with ultra-performance
- **Features**: Full V4 features + interactive console
- **Use Case**: Development and feature testing
- **Console**: Interactive for hands-on debugging

### 🎯 Interactive V3 Session (Memory Pool)
**Interactive debugging with V3 memory optimization**

- **Target**: Memory-efficient interactive development
- **Features**: V3 memory pooling + interactive console
- **Use Case**: Memory-aware development and testing
- **Console**: Interactive for debugging and validation

## 🧪 Performance Testing

### 🏆 Ultra-Performance Comparison (Comprehensive)
**Full performance testing suite**

- **Iterations**: 10 (configurable)
- **Features**: All profiles, lorem ipsum stress test, HTML report
- **Output**: Detailed comparison report
- **Duration**: ~2-3 minutes

### 📊 Performance Comparison (Quick)
**Fast performance validation**

- **Iterations**: Default (quick)
- **Features**: Basic comparison, HTML report
- **Output**: Quick performance overview
- **Duration**: ~30 seconds

### 🔍 Performance Comparison (Standard)
**Standard benchmarking**

- **Iterations**: 15
- **Features**: Standard testing with detailed report
- **Output**: Standard performance metrics
- **Duration**: ~1-2 minutes

### 📝 Lorem Ipsum Stress Test
**Stress testing with large data**

- **Data Size**: 5000 words
- **Features**: Memory stress testing, blob generation
- **Output**: Stress test performance report
- **Duration**: ~1 minute

## 🎨 Smart Navigation Features

### 🌍 Demo Enhanced Features (Smart Navigation)
**Complete feature demonstration**

- **Features**: All enhanced Dracula features
- **Smart Navigation**: CamelCase + diacritics support
- **International**: Multi-language character support

### 🐪 CamelCase Navigation Demo
**CamelCase navigation demonstration**

- **Navigation**: Alt+Left/Right for smart boundaries
- **Examples**: Get-ChildItem, New-PSSession, [System.IO.Path]::GetFileName
- **Boundaries**: CamelCase, PascalCase, underscores, hyphens

### 🌍 Diacritics Support Demo
**International character support**

- **Languages**: Czech, Spanish, French, German, Polish, Hungarian
- **Examples**: příkaz-sNázvem-čeština, función-conAcentos-español
- **Navigation**: Smart boundary detection for international characters

## ⌨️ Navigation Examples

### Smart Boundaries Work With:
```powershell
# CamelCase and PascalCase
Get-ChildItem           # Alt+Left/Right: Get | Child | Item
New-PSSession          # Alt+Left/Right: New | PS | Session

# Method calls
[System.IO.Path]::GetFileName  # Stops at each boundary

# Variables with underscores
myVariable_withUnderscores     # Stops at underscores

# International examples
příkaz-sNázvem-čeština        # Czech with diacritics
función-conAcentos-español    # Spanish with accents
```

### Key Bindings:
- **Alt+Left/Right**: Smart CamelCase + diacritics navigation
- **Ctrl+Left/Right**: Standard word boundaries
- **Perfect support**: International variable names

## 💡 Usage Tips

### Development Workflow:
1. **Start Development**: Use "🏆 Interactive V4 Session (Smart Navigation)"
2. **Test Performance**: Run "📊 Performance Comparison (Quick)"
3. **Full Testing**: Use "🏆 Ultra-Performance Comparison (Comprehensive)"
4. **Feature Demo**: Try "🌍 Demo Enhanced Features (Smart Navigation)"

### Performance Testing:
1. **Quick Check**: "📊 Performance Comparison (Quick)"
2. **Detailed Analysis**: "🔍 Performance Comparison (Standard)"
3. **Stress Testing**: "📝 Lorem Ipsum Stress Test"
4. **Full Suite**: "🏆 Ultra-Performance Comparison (Comprehensive)"

### Smart Navigation Testing:
1. **Full Demo**: "🌍 Demo Enhanced Features (Smart Navigation)"
2. **CamelCase**: "🐪 CamelCase Navigation Demo"
3. **International**: "🌍 Diacritics Support Demo"

## 🔧 Environment Variables

### Performance Debugging:
```powershell
$env:DRACULA_PERFORMANCE_DEBUG='true'   # Enable performance counters
$env:DRACULA_SHOW_STARTUP='true'        # Show startup timing
```

### Auto-configured in launch configurations
All ultra-performance configurations automatically set these variables for optimal debugging experience.

## 🏆 Performance Targets

### V4 Ultra-Performance:
- **Startup**: Sub-200ms (target)
- **JIT Compilation**: Pre-compiled critical paths
- **Memory**: Advanced concurrent collections
- **Features**: Smart navigation, async loading

### V3 Ultra-Performance:
- **Startup**: Sub-200ms (target)
- **Memory**: Optimized memory pooling
- **Caching**: Path and module caching
- **Features**: Memory-efficient operations

## 📊 Expected Results

### Performance Comparison Output:
- **Average startup times** for each profile
- **Success rates** and reliability metrics
- **Memory usage** and optimization data
- **HTML report** with detailed analysis

### Smart Navigation Benefits:
- **Faster code navigation** with Alt+Left/Right
- **International support** for global development
- **Enhanced productivity** with smart boundaries
- **Better debugging experience** with optimized PSReadLine
