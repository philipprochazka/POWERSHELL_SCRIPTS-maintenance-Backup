# 🧪 Profile Configuration Testing

Comprehensive testing system for validating PowerShell profile configurations, module dependencies, and feature functionality.

## 🎯 Testing Overview

The profile testing system provides multiple layers of validation to ensure your Unified PowerShell Profile system is working correctly:

### 🔍 Test Categories
- **Quick Health Checks** - Fast validation of core functionality
- **Comprehensive Configuration Tests** - Full system validation
- **Module Dependency Validation** - Verify all required modules
- **Environment Analysis** - PowerShell environment diagnostics
- **Feature-Specific Tests** - Navigation, theming, performance
- **Integration Tests** - VS Code, Git, and external tool integration

## 🚀 Available Test Configurations

### 🎯 Quick Health Check
**Launch Configuration:** `🎯 Module Health Check (Quick)`

Fast validation of essential components:
```powershell
# Tests performed:
- PowerShell version compatibility
- Core module availability
- Profile loading status
- Basic navigation functionality
- Theme loading verification
- Essential key bindings

# Expected runtime: 5-10 seconds
# Output: Pass/Fail summary with issue count
```

### 🧪 Comprehensive Configuration Test
**Launch Configuration:** `🧪 Test Profile Configuration (Comprehensive)`

Full system validation:
```powershell
# Comprehensive test areas:
- All module dependencies
- Complete feature validation
- Performance benchmarking
- Navigation system testing
- Theme and color verification
- Git integration validation
- VS Code integration testing
- Error handling verification

# Expected runtime: 30-60 seconds
# Output: Detailed report with recommendations
```

### 📦 Module Dependency Validation
**Launch Configuration:** `📦 Test Module Dependencies`

Validates all required PowerShell modules:
```powershell
# Module validation includes:
- PSReadLine version compatibility
- Oh-My-Posh installation status
- Pester testing framework
- PSScriptAnalyzer availability
- Git module functionality
- Custom profile modules

# Version requirements:
PSReadLine:      >= 2.2.0
Oh-My-Posh:      >= 20.0.0
Pester:          >= 5.0.0
PSScriptAnalyzer: >= 1.21.0
```

### 🔍 Environment Analysis
**Launch Configuration:** `🔍 PowerShell Environment Analysis`

Deep analysis of PowerShell environment:
```powershell
# Environment checks:
- PowerShell edition and version
- Execution policy settings
- Module path configuration
- Profile location validation
- Console font and encoding
- Terminal capabilities
- Performance counters
- Security settings

# Output: Comprehensive environment report
```

## 🎨 Feature-Specific Testing

### 🐪 CamelCase Navigation Testing
**Launch Configuration:** `🐪 Test CamelCase Navigation`

Interactive testing of smart navigation:
```powershell
# Navigation test scenarios:
Test-SimpleCommands = @(
    "Get-ChildItem",
    "Set-Location", 
    "New-Item",
    "Remove-Item"
)

Test-ComplexFunctions = @(
    "Initialize-UnifiedProfile",
    "Install-EnhancedOhMyPoshIntegration",
    "Test-ModuleDependencyValidation"
)

Test-Variables = @(
    '$MyComplexVariableName',
    '$configuration_with_underscores',
    '$mixedCase_andNumbers123'
)

# Interactive test process:
1. Display test command
2. User navigates with Ctrl+Arrow keys
3. Validate cursor positions
4. Report accuracy percentage
```

### 🌍 Diacritics Support Testing
**Launch Configuration:** `🌍 Test Diacritics Support`

International character navigation validation:
```powershell
# International test cases:
Czech_Tests = @(
    "funkce-sČeskýmiZnaky-příklad",
    "proměnná_sÚložištěm_názveů"
)

German_Tests = @(
    "funktion-mitUmlauten-größe",
    "Variable_mitÄöü_undEszett"
)

Spanish_Tests = @(
    "función-conAcentosEspañol",
    "variable_conCaracteresEspeciales_ñáéíóú"
)

# Validation includes:
- Character display verification
- Navigation boundary accuracy
- Keyboard input handling
- Copy/paste functionality
```

### 🧛‍♂️ Theme Validation Testing
**Launch Configuration:** `🎨 Test Profile Themes`

Comprehensive theme testing:
```powershell
# Theme validation areas:
- Color scheme loading
- Prompt configuration
- Git status indicators
- Error message formatting
- Syntax highlighting
- Terminal transparency
- Font compatibility

# Test modes:
- Dracula theme variants
- MCP theme validation
- LazyAdmin theme testing
- Minimal theme verification
- Custom theme validation
```

## ⚡ Performance Testing

### 🏆 Performance Benchmark Suite
**Launch Configuration:** `🏆 Performance Benchmark (Comprehensive)`

Full performance analysis:
```powershell
# Performance metrics:
Profile_Startup_Time = @{
    Dracula_Enhanced = "Target: <2 seconds"
    Dracula_Performance = "Target: <1 second" 
    Minimal_Mode = "Target: <0.5 seconds"
}

Navigation_Performance = @{
    CamelCase_Response = "Target: <10ms"
    Diacritics_Processing = "Target: <20ms"
    Complex_Commands = "Target: <50ms"
}

Memory_Usage = @{
    Base_Profile = "Target: <50MB"
    Full_Features = "Target: <100MB"
    Maximum_Acceptable = "<200MB"
}

# Output: Performance report with recommendations
```

### ⚡ Quick Performance Test
**Launch Configuration:** `⚡ Performance Test (Quick)`

Fast performance validation:
```powershell
# Quick test areas:
- Profile startup time
- Basic command response
- Memory usage check
- Module loading speed

# Expected runtime: 10-15 seconds
# Output: Pass/Fail with basic metrics
```

## 🔧 Integration Testing

### 🎯 VS Code Integration Test
**Launch Configuration:** `🎯 Test VS Code Integration`

VS Code specific functionality:
```powershell
# Integration test areas:
- Launch configuration loading
- Task execution capability
- Terminal integration
- Debug configuration
- Extension compatibility
- Workspace settings
- Color theme synchronization

# Tests VS Code features:
- Integrated terminal functionality
- PowerShell extension integration
- Git extension compatibility
- Debug adapter functionality
```

### 🔄 Git Integration Test
**Launch Configuration:** `🔄 Test Git Integration`

Git functionality validation:
```powershell
# Git integration tests:
- Repository status detection
- Branch information display
- Commit status indicators
- Remote repository connection
- Git command integration
- Performance impact measurement

# Validation scenarios:
- Clean repository
- Modified files
- Staged changes
- Untracked files
- Merge conflicts
- Detached HEAD state
```

## 📊 Test Reporting

### Standard Test Output
```powershell
# Test result format:
=== PowerShell Profile Test Report ===
Test Suite: Comprehensive Configuration Test
Executed: 2025-08-06 14:30:25
Duration: 45.2 seconds

RESULTS SUMMARY:
✅ Passed: 23/25 tests (92%)
❌ Failed: 2/25 tests (8%)
⚠️  Warnings: 3

FAILED TESTS:
❌ Git Integration: Remote repository unreachable
❌ Performance: Startup time exceeded target (2.3s > 2.0s)

WARNINGS:
⚠️  PSReadLine version 2.1.0 (recommend >= 2.2.0)
⚠️  Oh-My-Posh theme cache outdated
⚠️  Custom theme file missing

RECOMMENDATIONS:
1. Update PSReadLine module
2. Clear Oh-My-Posh cache
3. Optimize profile startup sequence
4. Check network connectivity for Git remote
```

### Detailed Diagnostic Output
```powershell
# Detailed test results:
Module Dependency Analysis:
├── PSReadLine: ✅ v2.2.6 (Compatible)
├── Oh-My-Posh: ✅ v20.1.0 (Current)
├── Pester: ⚠️  v4.10.1 (Recommend upgrade to v5.x)
├── PSScriptAnalyzer: ✅ v1.21.0 (Current)
└── Git: ✅ v2.41.0 (Compatible)

Feature Validation:
├── CamelCase Navigation: ✅ 98% accuracy
├── Diacritics Support: ✅ All languages tested
├── Theme Loading: ✅ Dracula Enhanced loaded
├── Performance: ⚠️  Startup time: 2.3s (target: <2.0s)
└── VS Code Integration: ✅ All features functional

Environment Analysis:
├── PowerShell Version: ✅ 7.4.1 (Current)
├── Execution Policy: ✅ RemoteSigned
├── Module Path: ✅ Configured correctly
├── Console Encoding: ✅ UTF-8
└── Terminal Capabilities: ✅ Full color support
```

## 🧪 Automated Test Scheduling

### Continuous Testing
```powershell
# Automated test schedule:
Daily_Health_Check = {
    Time = "09:00"
    Tests = @("Quick Health Check", "Performance Test")
    EmailReport = $true
}

Weekly_Comprehensive = {
    Day = "Sunday"
    Time = "06:00"
    Tests = @("Comprehensive Configuration", "Full Performance Benchmark")
    DetailedReport = $true
}

Module_Update_Check = {
    Frequency = "Weekly"
    AutoUpdate = $false
    NotifyUpdates = $true
}
```

### Test Automation Tasks
**VS Code Tasks:**
- `🤖 Schedule Automated Tests`
- `📊 Generate Weekly Test Report`
- `🔄 Run Continuous Health Monitoring`

## 🆘 Troubleshooting Tests

### Common Test Failures

#### Module Not Found
```powershell
# Diagnostic steps:
1. Check module installation:
   Get-Module -ListAvailable -Name ModuleName

2. Verify module path:
   $env:PSModulePath -split ';'

3. Manual module import:
   Import-Module ModuleName -Force

4. Check module dependencies:
   Test-ModuleManifest ModuleName.psd1
```

#### Navigation Tests Failing
```powershell
# Troubleshooting navigation:
1. Verify PSReadLine version:
   Get-Module PSReadLine

2. Check key bindings:
   Get-PSReadLineKeyHandler | Where-Object Key -match "Arrow"

3. Test environment variables:
   Get-ChildItem Env: | Where-Object Name -match "CAMELCASE|DIACRITICS"

4. Reset PSReadLine configuration:
   Remove-Module PSReadLine -Force
   Import-Module PSReadLine -Force
```

#### Performance Test Failures
```powershell
# Performance troubleshooting:
1. Profile startup with timing:
   Measure-Command { & $PROFILE }

2. Identify slow modules:
   $env:MEASURE_STARTUP_TIME = "true"

3. Check system resources:
   Get-Process PowerShell | Select-Object CPU, WorkingSet

4. Clear module cache:
   Remove-Module * -Force
```

## 💡 Best Practices

### 1. Regular Testing Schedule
- Run quick health checks daily
- Perform comprehensive tests weekly
- Test after any profile modifications
- Validate after module updates

### 2. Test Environment Isolation
```powershell
# Create test profile:
$TestProfile = "$env:TEMP\TestProfile.ps1"
Copy-Item $PROFILE $TestProfile

# Test in isolation:
pwsh -NoProfile -File $TestProfile
```

### 3. Performance Baseline
```powershell
# Establish performance baselines:
$BaselineMetrics = @{
    StartupTime = "1.5s"
    MemoryUsage = "75MB"
    NavigationResponse = "5ms"
}

# Compare against baseline in tests
```

### 4. Continuous Integration
Integrate testing into your development workflow:
- Pre-commit hooks for profile validation
- Automated testing on profile changes
- Performance regression detection
- Module compatibility verification

---

**Testing System:** Unified PowerShell Profile Test Suite  
**Generated:** August 6, 2025  
**Coverage:** Configuration, Modules, Features, Performance, Integration  
**Compatibility:** PowerShell 7.x, Pester 5.x, VS Code 1.90+
