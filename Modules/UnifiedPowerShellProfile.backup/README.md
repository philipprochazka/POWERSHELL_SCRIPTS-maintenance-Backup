# 🚀 UnifiedPowerShellProfile v2.0

> **Smart Self-Linting PowerShell Profile with Real-time Quality Enforcement**

A comprehensive PowerShell profile system that provides real-time code quality enforcement, intelligent linting suggestions, and professional development environment setup.

## ✨ Features

### 🔍 **Smart Linting System**
- **Real-time PSScriptAnalyzer integration** - Analyze commands as you type
- **Quality scoring** - Get instant feedback on code quality (A+ to F grades)
- **Intelligent suggestions** - Smart completion with quality hints
- **Critical rule enforcement** - Block dangerous patterns automatically

### 🎯 **Quality Metrics**
- **Live quality dashboard** - Track your coding quality over time
- **Comprehensive reporting** - Detailed analysis with actionable insights
- **Threshold enforcement** - Configurable quality gates
- **Grade tracking** - Monitor improvement trends

### 🎨 **Multiple Profile Modes**
- **🧛 Dracula** - Dark theme with vampire aesthetics
- **🤖 MCP** - Model Context Protocol optimized
- **⚡ LazyAdmin** - System administration focused
- **📦 Minimal** - Lightweight and fast
- **🎨 Custom** - Fully customizable

### 🛠️ **Developer Tools**
- **VS Code integration** - Automated workspace setup
- **Pester test support** - Built-in testing framework
- **GitHub workflows** - CI/CD quality gates
- **PSReadLine enhancement** - Smart command validation

## 🚦 Quick Start

### 1. Installation
```powershell
# Import the module
Import-Module UnifiedPowerShellProfile -Force

# Initialize with real-time linting
Initialize-UnifiedProfile -Mode Dracula -EnableRealtimeLinting
```

### 2. Basic Usage
```powershell
# Check current quality metrics
quality-check

# Run smart linting on current directory (sync)
smart-lint -Detailed

# Run smart linting asynchronously (faster for large projects)
smart-lint -Async -MaxConcurrentJobs 8

# Switch profile modes
profile-mode MCP

# Get profile status
profile-status
```

### 3. VS Code Setup
```powershell
# Create VS Code workspace with quality tools
New-VSCodeWorkspace -WorkspaceRoot "C:\MyProject" -ProfileMode Dracula
```

## 🎮 Commands & Aliases

| Command | Alias | Description |
|---------|-------|-------------|
| `Initialize-UnifiedProfile` | `profile-init` | Initialize profile system |
| `Set-ProfileMode` | `profile-mode` | Change profile mode |
| `Get-ProfileStatus` | `profile-status` | Show current configuration |
| `Invoke-SmartLinting` | `smart-lint` | Run comprehensive linting |
| `Enable-RealtimeLinting` | `lint-on` | Enable real-time analysis |
| `Disable-RealtimeLinting` | `lint-off` | Disable real-time analysis |
| `Get-QualityMetrics` | `quality-check` | Show quality dashboard |

## 🔧 Configuration

### Quality Thresholds
```powershell
# Set quality threshold (0.0 - 1.0)
$UnifiedProfileConfig.QualityThreshold = 0.85

# Enable auto-correction suggestions
$UnifiedProfileConfig.AutoCorrect = $true
```

### Linting Rules
- **Critical Rules** - Must pass (blocks execution)
  - `PSAvoidUsingCmdletAliases`
  - `PSAvoidUsingPositionalParameters`
  - `PSAvoidGlobalVars`
  - `PSUseDeclaredVarsMoreThanAssignments`
  - `PSAvoidUsingPlainTextForPassword`

- **Important Rules** - Best practices (warnings)
  - `PSUseApprovedVerbs`
  - `PSUseSingularNouns`
  - `PSUseConsistentWhitespace`
  - `PSUseConsistentIndentation`

- **Informational Rules** - Suggestions
  - `PSProvideCommentHelp`
  - `PSUseCmdletCorrectly`
  - `PSAvoidDefaultValueSwitchParameter`

## 🎯 Quality Scoring

The system uses a sophisticated scoring algorithm:

- **Base Score**: 1.0 (100%)
- **Critical Issues**: -0.3 per issue
- **Important Issues**: -0.15 per issue  
- **Informational Issues**: -0.05 per issue

### Grade Scale
| Grade | Score Range | Description |
|-------|-------------|-------------|
| A+ | 0.95 - 1.0 | Excellent |
| A  | 0.90 - 0.94 | Very Good |
| B+ | 0.85 - 0.89 | Good |
| B  | 0.80 - 0.84 | Above Average |
| C+ | 0.75 - 0.79 | Average |
| C  | 0.70 - 0.74 | Below Average |
| D  | 0.60 - 0.69 | Poor |
| F  | < 0.60 | Failing |

## 🎨 Profile Modes

### 🧛 Dracula Mode
```powershell
Initialize-UnifiedProfile -Mode Dracula
```
- Dark vampire theme
- Quality indicators in prompt
- Enhanced visual feedback

### 🤖 MCP Mode  
```powershell
Initialize-UnifiedProfile -Mode MCP
```
- Model Context Protocol optimized
- AI-friendly command structure
- Enhanced completion

### ⚡ LazyAdmin Mode
```powershell
Initialize-UnifiedProfile -Mode LazyAdmin
```
- System administration focus
- Quick admin shortcuts
- Enhanced security checks

## 🔍 Real-time Linting

Enable intelligent command analysis as you type:

```powershell
# Enable real-time analysis
Enable-RealtimeLinting

# Use Ctrl+Q for quick quality check on current line
# Commands are automatically validated before execution
```

## 🧪 Testing Integration

### Pester Support
```powershell
# Run all tests with coverage
Invoke-Pester -CodeCoverage

# Run specific test file
Invoke-Pester -Path "MyScript.Tests.ps1"
```

### VS Code Tasks
- **🔍 Run PSScriptAnalyzer** - Full repository analysis
- **🧪 Run Pester Tests** - Execute test suite
- **⚡ Initialize Profile** - Setup environment
- **📊 Quality Check** - Comprehensive quality report

## 🚦 GitHub Integration

### Quality Gate Workflow
The module includes a GitHub workflow that enforces quality standards:

- **PSScriptAnalyzer checks** - Zero critical issues required
- **Pester test execution** - All tests must pass
- **Code coverage reporting** - Track test coverage
- **Quality scoring** - Automated grade assignment

### Workflow Features
- ✅ Automatic quality gate enforcement
- 📊 Detailed quality reports
- 🧪 Automated test execution
- 📈 Trend tracking

## 📊 Quality Dashboard

```powershell
quality-check
```

```
📈 Quality Metrics Dashboard
==============================
Current Score: 0.92 (A)
Commands Analyzed: 1,247
Real-time Linting: True
Quality Threshold: 0.85
Last Check: 14:32:15
```

## 🛡️ Security Features

- **Password detection** - Warns about plain text passwords
- **Global variable analysis** - Prevents unsafe global usage
- **Injection protection** - Blocks dangerous expressions
- **Permission validation** - Checks execution context

## 🎯 Advanced Usage

### Custom Quality Rules
```powershell
# Add custom rule to critical list
$ProfileLintingRules.Critical += 'MyCustomRule'

# Set custom quality threshold
$UnifiedProfileConfig.QualityThreshold = 0.90
```

### Metrics Export
```powershell
# Export quality metrics
$metrics = Get-QualityMetrics
$metrics | Export-Csv "quality-report.csv"
```

### Batch Analysis
```powershell
# Analyze entire project
smart-lint -Path "C:\MyProject" -Detailed -AutoFix
```

## 🤝 Integration Examples

### With CI/CD Pipeline
```yaml
- name: Quality Gate
  run: |
    Import-Module UnifiedPowerShellProfile
    $result = Invoke-SmartLinting -Path . -Detailed
    if ($result.CriticalIssues -gt 0) { exit 1 }
```

### With Build Scripts
```powershell
# Pre-build quality check
if ((Get-QualityMetrics).CurrentScore -lt 0.85) {
    throw "Quality threshold not met"
}
```

## 🔧 Troubleshooting

### Common Issues

**Module not loading**
```powershell
# Force reload
Remove-Module UnifiedPowerShellProfile -Force
Import-Module UnifiedPowerShellProfile -Force
```

**PSScriptAnalyzer missing**
```powershell
# Install required modules
Install-Module PSScriptAnalyzer, Pester -Force
```

**Real-time linting not working**
```powershell
# Check PSReadLine version
Get-Module PSReadLine
# Update if needed
Install-Module PSReadLine -Force
```

## 📝 Requirements

- **PowerShell 5.1+** (PowerShell 7+ recommended)
- **PSScriptAnalyzer 1.20.0+**
- **Pester 5.0.0+**
- **PSReadLine** (for enhanced features)

## 🎉 Contributing

We welcome contributions! Please ensure your code meets our quality standards:

1. Run `smart-lint` before committing
2. Maintain quality score above 0.85
3. Include Pester tests for new features
4. Follow PSScriptAnalyzer best practices

## 📄 License

© 2025 Philip Rochazka. All rights reserved.

---

**Happy PowerShelling! 🚀**
