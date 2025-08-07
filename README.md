# 🚀 UnifiedPowerShell Repository

[![PowerShell](https://img.shields.io/badge/PowerShell-7.0+-blue.svg)](https://github.com/PowerShell/PowerShell)
[![GitHub Copilot](https://img.shields.io/badge/GitHub_Copilot-Enabled-green.svg)](https://github.com/features/copilot)
[![MCP](https://img.shields.io/badge/MCP-Integrated-purple.svg)](https://modelcontextprotocol.io)
[![Repository](https://img.shields.io/badge/Repository-Main-orange.svg)](https://github.com/philipprochazka/UnifiedPowerShell)

**Unified PowerShell Modules & Scripts Repository — Central hub for all PowerShell resources with Model Context Protocol (MCP) integration and GitHub Copilot optimization.**

> **📢 IMPORTANT**: This repository has been officially designated as the **main PowerShell repository**. All future PowerShell scripts, modules, and resources should be contributed here. Previous repositories are now deprecated in favor of this unified approach.

## ⚡ Quick Start

1. **Open in VS Code**:
   ```bash
   code .vscode/Powershell.code-workspace
   ```

2. **Setup MCP Environment**:
   ```powershell
   .\Scripts\Setup-MCPEnvironment.ps1
   ```

3. **Load Enhanced Profile**:
   ```powershell
   Copy-Item .\Microsoft.PowerShell_profile_MCP.ps1 .\Microsoft.PowerShell_profile.ps1
   . $PROFILE
   ```

4. **Verify Setup**:
   ```powershell
   Show-MCPStatus
   ```

## 🎯 Features

- **🤖 AI-Powered Development**: GitHub Copilot integration with optimized settings
- **🔌 MCP Integration**: Model Context Protocol servers for enhanced AI assistance
- **📝 Enhanced Profile**: Feature-rich PowerShell profile with developer tools
- **🎨 VS Code Workspace**: Pre-configured workspace with tasks, debugging, and extensions
- **🔍 Code Analysis**: Integrated PSScriptAnalyzer for code quality
- **📚 Template System**: Ready-to-use script templates and project structures
- **🔄 Git Integration**: Enhanced git workflows and automation

## 🛠️ Available Tools

### MCP Functions
```powershell
Initialize-MCPEnvironment    # Setup MCP directories and config
Show-MCPStatus              # Display current MCP status
New-PowerShellScript        # Create new script with template
Test-PowerShellSyntax       # Analyze script with PSScriptAnalyzer
Show-GitStatus             # Enhanced git status display
Get-ProjectStructure       # Show project tree structure
```

### Git Aliases
```powershell
gs    # git status
ga    # git add
gc    # git commit
gp    # git push
gl    # git log --oneline
gd    # git diff
```

### VS Code Tasks
- **PowerShell: Run Script** - Execute current file
- **PowerShell: Run with Profile** - Execute with enhanced profile
- **PowerShell: Format Document** - Format code
- **PowerShell: PSScriptAnalyzer** - Analyze for issues
- **PowerShell: Setup MCP Environment** - Initialize MCP

## 📁 Repository Structure

This unified repository is organized into the following key directories:

```
UnifiedPowerShell/
├── .github/                 # GitHub configuration & instructions
├── .mcp/                    # MCP configuration and servers  
├── .vscode/                 # VS Code workspace configuration
├── docs/                    # Comprehensive documentation
├── Scripts/                 # PowerShell scripts & utilities
├── Modules/                 # PowerShell modules (deprecated structure)
├── PowerShellModules/       # Main PowerShell modules directory
│   ├── UnifiedMCPProfile/   # Core MCP integration module
│   ├── UnifiedPowerShellProfile/  # Unified profile system
│   └── [Other Modules]/     # Additional PowerShell modules
├── Tests/                   # Pester tests for all components
├── Examples/                # Example scripts and usage patterns
└── Build-Steps/            # Build automation and deployment
```

### Key Modules

- **UnifiedMCPProfile**: Core MCP integration and AI assistance
- **UnifiedPowerShellProfile**: Advanced PowerShell profile system
- **PowerShellModules**: Collection of enterprise-grade PowerShell modules

## 🎯 Repository Transition & Future Contributions

### 📢 Repository Status
This repository serves as the **central hub** for all PowerShell development:

- **✅ ACTIVE**: `UnifiedPowerShell` (this repository) - Main PowerShell resource
- **📦 MODULAR**: Individual modules can be extracted to separate repositories when mature
- **🔄 CONSOLIDATED**: All future PowerShell contributions should be made here
- **📚 DOCUMENTED**: Comprehensive documentation and examples for all components

### 🚀 Contributing Guidelines
All PowerShell scripts and modules should follow our [development standards](.github/copilot-instructions.md):

1. **Function Naming**: Use approved PowerShell verbs (`Install-*`, `Build-*`, `New-*`, `Test-*`)
2. **Documentation**: Include comprehensive Pester tests and `.md` documentation
3. **Structure**: Follow the established folder hierarchy
4. **Quality**: Maintain PSScriptAnalyzer compliance and 80%+ test coverage

## 📖 Documentation

- **[Repository Index](./docs/repository-index.md)** - Complete repository navigation guide
- **[Migration Guide](./docs/migration-guide.md)** - Guide for transitioning from old repository
- **[Setup Instructions](.github/INSTRUCTIONS.md)** - Complete setup and usage guide
- **[MCP Documentation](.mcp/README.md)** - MCP-specific documentation
- **[VS Code Configuration](.vscode/README.md)** - Workspace configuration details
- **[Documentation Index](./docs/index.md)** - Central documentation hub

## 🌟 Making This Your Default Environment

### Replace System Profile
```powershell
# Backup existing profile
Copy-Item $PROFILE "$PROFILE.backup"

# Use MCP profile as system default
Copy-Item ".\Microsoft.PowerShell_profile_MCP.ps1" $PROFILE
```

### Source from Existing Profile
Add to your existing `$PROFILE`:
```powershell
# Source the MCP profile
$MCPProfile = "C:\path\to\this\workspace\Microsoft.PowerShell_profile_MCP.ps1"
if (Test-Path $MCPProfile) { . $MCPProfile }
```

## 🚀 Advanced Usage

### Creating New Projects
```powershell
# Create a new PowerShell script with template
New-PowerShellScript -Name "MyAwesomeScript" -Description "Does amazing things"

# Analyze the script
Test-PowerShellSyntax -FilePath ".\MyAwesomeScript.ps1"

# Show project structure
Get-ProjectStructure
```

### Working with MCP
```powershell
# Initialize MCP environment
Initialize-MCPEnvironment

# Check MCP status
Show-MCPStatus

# View available MCP servers and tools in .mcp/mcp-config.json
```

## 📋 Requirements

- **PowerShell 7.0+**
- **Visual Studio Code**
- **Git**
- **GitHub Copilot** (recommended)

### Recommended Modules
```powershell
Install-Module PSScriptAnalyzer, Pester, Az.Tools.Predictor, Terminal-Icons, z -Scope CurrentUser
```

## 🤝 Contributing

This workspace is designed as a community resource. Contributions welcome!

1. Fork the repository
2. Add your enhancements
3. Submit a pull request

Areas for contribution:
- Additional MCP servers and tools
- PowerShell module templates  
- Enhanced development workflows
- Documentation improvements

## 📝 License

Provided as-is for community use. Individual components may have their own licenses.

---

**Happy PowerShell development with AI assistance! 🎯**
