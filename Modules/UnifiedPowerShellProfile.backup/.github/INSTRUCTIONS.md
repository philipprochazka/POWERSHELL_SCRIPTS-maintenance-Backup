# PowerShell MCP Workspace - Setup & Usage Instructions

## 🚀 Overview

This PowerShell workspace is designed as the **ultimate PowerShell development environment** with integrated Model Context Protocol (MCP) support and GitHub Copilot optimization. It provides a comprehensive setup for PowerShell scripting, module development, and AI-assisted coding.

## 🎯 Features

- **MCP Integration**: Full Model Context Protocol support for AI assistance
- **GitHub Copilot Optimized**: Pre-configured for optimal AI code generation
- **Enhanced PowerShell Profile**: Feature-rich profile with developer tools
- **VS Code Workspace**: Properly configured workspace with tasks and debugging
- **Script Analysis**: Integrated PSScriptAnalyzer for code quality
- **Git Integration**: Enhanced git workflows and automation
- **Module Management**: Tools for PowerShell module development

## 📋 Prerequisites

Before using this workspace, ensure you have:

- **PowerShell 7.0+** (Install: `winget install Microsoft.PowerShell`)
- **Visual Studio Code** (Install: `winget install Microsoft.VisualStudioCode`)
- **Git** (Install: `winget install Git.Git`)
- **GitHub Copilot** (VS Code extension)

### Recommended PowerShell Modules

```powershell
# Install essential modules
Install-Module PSScriptAnalyzer -Scope CurrentUser
Install-Module Pester -Scope CurrentUser
Install-Module Az.Tools.Predictor -Scope CurrentUser
Install-Module Terminal-Icons -Scope CurrentUser
Install-Module z -Scope CurrentUser
```

## 🛠️ Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/philipprochazka/POWERSHELL_SCRIPTS-maintenance-Backup.git
cd POWERSHELL_SCRIPTS-maintenance-Backup
```

### 2. Open in VS Code

```bash
code .vscode/Powershell.code-workspace
```

### 3. Setup MCP Environment

Run the setup script to initialize the MCP environment:

```powershell
.\Scripts\Setup-MCPEnvironment.ps1
```

### 4. Load Enhanced Profile

Option A - Use the new MCP-optimized profile:
```powershell
Copy-Item .\Microsoft.PowerShell_profile_MCP.ps1 .\Microsoft.PowerShell_profile.ps1
```

Option B - Keep your existing profile and source the MCP profile:
```powershell
# Add this line to your existing profile
. "$PSScriptRoot\Microsoft.PowerShell_profile_MCP.ps1"
```

### 5. Reload PowerShell Profile

```powershell
. $PROFILE
```

### 6. Verify Setup

```powershell
Show-MCPStatus
Get-ProjectStructure
```

## 🎨 Workspace Configuration

### VS Code Settings

The workspace includes optimized settings for:
- PowerShell development with IntelliSense
- GitHub Copilot integration
- Automatic code formatting
- Error highlighting and problem matching
- Integrated terminal with PowerShell 7

### Available Tasks

Access via `Ctrl+Shift+P > Tasks: Run Task`:

- **PowerShell: Run Script** - Execute current PowerShell file
- **PowerShell: Run with Profile** - Execute with enhanced profile loaded
- **PowerShell: Format Document** - Format PowerShell code
- **PowerShell: PSScriptAnalyzer** - Analyze script for issues
- **PowerShell: Clean Workspace** - Clean temporary files
- **PowerShell: Setup MCP Environment** - Initialize MCP

### Launch Configurations

- **PowerShell Interactive Session** - Debug with enhanced profile

## 🔧 MCP Integration

### Available MCP Functions

Once the enhanced profile is loaded, you have access to:

```powershell
# MCP Environment Management
Initialize-MCPEnvironment    # Setup MCP directories and config
Show-MCPStatus              # Display current MCP status

# Development Tools
New-PowerShellScript        # Create new script with template
Test-PowerShellSyntax       # Analyze script with PSScriptAnalyzer
Show-GitStatus             # Enhanced git status display
Get-ProjectStructure       # Show project tree structure

# Quick Aliases
gs                         # git status
ga                         # git add
gc                         # git commit
gp                         # git push
gl                         # git log --oneline
```

### MCP Servers

The workspace includes three MCP servers:

1. **Filesystem Server** - File operations (read, write, list, delete)
2. **Git Server** - Version control operations
3. **Development Server** - Code analysis and execution

## 🤖 GitHub Copilot Integration

### Optimized Settings

The workspace is pre-configured for optimal Copilot performance:

- Enabled for PowerShell, Markdown, and JSON files
- Inline suggestions activated
- Quick suggestions for comments and strings
- Preview suggestions enabled

### Best Practices for AI Assistance

1. **Use descriptive comments** - Copilot generates better code with clear intent
2. **Write function signatures first** - Let Copilot fill in the implementation
3. **Use the MCP functions** - They provide context for better suggestions
4. **Leverage the enhanced profile** - Built-in functions improve AI understanding

### Example AI-Assisted Workflow

```powershell
# 1. Create a new script with template
New-PowerShellScript -Name "ProcessAnalyzer" -Description "Analyze running processes"

# 2. Open in VS Code (automatically opened)
# 3. Use Copilot to generate function body
# 4. Analyze with PSScriptAnalyzer
Test-PowerShellSyntax -FilePath ".\ProcessAnalyzer.ps1"

# 5. Commit changes
ga "ProcessAnalyzer.ps1"
gc -m "Add process analyzer script"
```

## 📁 Directory Structure

```
├── .github/                 # GitHub configuration
│   └── INSTRUCTIONS.md      # This file
├── .mcp/                    # MCP configuration and servers
│   ├── config/              # MCP configuration files
│   ├── servers/             # MCP server implementations
│   └── tools/               # MCP helper tools
├── .vscode/                 # VS Code workspace configuration
│   ├── Powershell.code-workspace
│   ├── settings.json
│   └── extensions.json
├── Scripts/                 # PowerShell scripts
│   └── MCP/                 # MCP-specific scripts
├── Modules/                 # PowerShell modules
├── Examples/                # Example scripts and usage
└── Microsoft.PowerShell_profile*.ps1  # PowerShell profiles
```

## 🎛️ Customization

### PowerShell Development Standards

#### Function Naming Conventions
- **AVOID**: `Setup-*` functions (use `Install-*` instead)
- **AVOID**: `Create-*` functions (use `Build-*`, `New-*`, or `Initialize-*` instead)
- **PREFER**: PowerShell approved verbs (Get, Set, New, Remove, Install, Build, etc.)
- **USE**: PascalCase for function names following PowerShell conventions

#### Standard Function Prefixes
- `Install-*` for installation/setup operations
- `Build-*` for construction/compilation operations  
- `New-*` for creating new objects/resources
- `Initialize-*` for initialization operations
- `Test-*` for validation/testing operations
- `Get-*` for retrieval operations
- `Set-*` for configuration operations

#### Documentation Requirements
Every PowerShell function must include:
- **Comprehensive .md documentation** in `/docs` folder
- **Pester tests** in `/Tests` folder
- **VS Code tasks** for common operations
- **Function documentation** with proper comment-based help

#### Default Development Workflow
When creating new PowerShell functions, automatically:
1. Generate comprehensive Pester tests
2. Create corresponding .md documentation files
3. Establish proper `/docs` folder structure with index.md
4. Generate VS Code run tasks for testing and building
5. Follow PowerShell best practices for all code generation
6. Create folder tree documentation for project structure

#### Documentation Structure
```
/docs/
├── index.md                 # Main documentation index
├── functions/               # Function-specific documentation
│   ├── Install-Module.md    # One file per function
│   ├── Build-Package.md
│   └── Test-Validation.md
├── guides/                  # How-to guides
├── examples/                # Usage examples
└── folder-tree.md          # Project structure documentation
```

#### Testing Standards
- **Pester 5.x** for all tests
- **Test coverage** minimum 80%
- **Integration tests** for complex workflows
- **Unit tests** for individual functions
- **Performance tests** for critical functions

#### VS Code Task Standards
Every project should include tasks for:
- `Test-AllFunctions` - Run all Pester tests
- `Build-Documentation` - Generate/update documentation
- `Format-Code` - Code formatting and cleanup
- `Validate-Syntax` - PowerShell syntax validation
- `Build-Module` - Module compilation and packaging

## 🎛️ Advanced Customization

### Adding Custom MCP Tools

1. Create a new script in `Scripts/MCP/`
2. Add configuration to `.mcp/mcp-config.json`
3. Reload the MCP environment: `Initialize-MCPEnvironment`

### Extending the Profile

Add custom functions to the profile:

```powershell
# Add to Microsoft.PowerShell_profile_MCP.ps1
function My-CustomFunction {
    # Your custom function here
}
```

### Adding VS Code Tasks

Edit `.vscode/Powershell.code-workspace` to add new tasks:

```json
{
    "label": "My Custom Task",
    "type": "shell",
    "command": "pwsh",
    "args": ["-ExecutionPolicy", "Bypass", "-File", "Scripts/MyScript.ps1"]
}
```

## 🔍 Troubleshooting

### Common Issues

1. **Profile not loading**
   ```powershell
   # Check execution policy
   Get-ExecutionPolicy
   # Set if needed
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **MCP environment not initializing**
   ```powershell
   # Manually run setup
   .\Scripts\Setup-MCPEnvironment.ps1 -Force
   ```

3. **Modules not found**
   ```powershell
   # Install missing modules
   Install-Module PSScriptAnalyzer, Pester, Terminal-Icons -Scope CurrentUser
   ```

4. **VS Code tasks not working**
   - Ensure PowerShell 7 is in PATH
   - Check workspace file syntax
   - Reload VS Code window

### Getting Help

- Use `Show-MCPStatus` to check environment status
- Check `.mcp/README.md` for MCP-specific documentation
- Review PowerShell profile functions with `Get-Command -Module *` 

## 🌟 Making This Your Default PowerShell Environment

### Option 1: Replace System Profile

```powershell
# Backup existing profile
Copy-Item $PROFILE "$PROFILE.backup"

# Copy MCP profile to system location
Copy-Item ".\Microsoft.PowerShell_profile_MCP.ps1" $PROFILE

# Restart PowerShell
```

### Option 2: Source from System Profile

Add to your existing `$PROFILE`:

```powershell
# Source the MCP profile from this workspace
$WorkspaceProfile = "C:\path\to\this\workspace\Microsoft.PowerShell_profile_MCP.ps1"
if (Test-Path $WorkspaceProfile) {
    . $WorkspaceProfile
}
```

### Option 3: Use as Default Workspace

Set this workspace as your default PowerShell development location:

```powershell
# Add to your system profile
Set-Location "C:\path\to\this\workspace"
```

## 🤝 Contributing

This workspace is designed to be a community resource. To contribute:

1. Fork the repository
2. Create a feature branch
3. Add your enhancements (scripts, tools, configurations)
4. Submit a pull request

### Areas for Contribution

- Additional MCP servers
- PowerShell module templates
- Enhanced development tools
- Documentation improvements
- Example scripts and workflows

## 📝 License

This workspace configuration is provided as-is for community use. Individual scripts and modules may have their own licenses.

---

**Happy PowerShell development with AI assistance! 🚀**

For questions or issues, please open a GitHub issue or discussion.
