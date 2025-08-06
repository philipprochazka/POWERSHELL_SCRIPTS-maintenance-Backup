# GitHub Copilot Custom Instructions

## PowerShell Development Standards & Architecture

### Critical Naming Conventions (ENFORCED)
- **❌ PROHIBITED**: `Setup-*` functions → use `Install-*`
- **❌ PROHIBITED**: `Create-*` functions → use `Build-*`, `New-*`, or `Initialize-*`
- **✅ REQUIRED**: PowerShell approved verbs only (Get, Set, New, Remove, Install, Build, Test, Initialize)
- **✅ REQUIRED**: PascalCase for all function names

### Function Verb Standards
- `Install-*` - installation/setup operations
- `Build-*` - construction/compilation operations  
- `New-*` - creating new objects/resources
- `Initialize-*` - initialization operations
- `Test-*` - validation/testing operations
- `Get-*` - retrieval operations
- `Set-*` - configuration operations

### Project Architecture Pattern
This codebase follows a modular PowerShell architecture:
- **Module Structure**: `{ModuleName}.psd1/.psm1` with Public/Private function separation
- **Documentation**: `/docs/` with `index.md` hub and `/functions/` subdirectory
- **Testing**: `/Tests/` with Pester test files matching function names
- **Tasks**: `.vscode/tasks.json` with emoji-prefixed labels for VS Code integration

### Mandatory Development Workflow
For EVERY function created/modified, automatically generate:

1. **Pester Tests** - Comprehensive coverage in `/Tests/` folder
2. **Function Documentation** - `.md` file in `/docs/functions/`
3. **VS Code Tasks** - Test execution and validation tasks
4. **VS Code Launch Configs** - Debug configurations in `.vscode/launch.json`
5. **Project Structure Updates** - Update `docs/index.md` and folder tree

### VS Code Integration Requirements (CRITICAL)
When creating or modifying PowerShell scripts, ALWAYS add corresponding launch configurations:

1. **Debug Launch Config**: Direct script debugging with appropriate arguments
2. **Test Launch Config**: Running with test parameters and report generation  
3. **Interactive Launch Config**: For scripts requiring user interaction
4. **Emoji Naming**: Use descriptive emojis in launch config names (🧪, 🔬, 🚀, 📊, etc.)
5. **Temporary Console**: Set `createTemporaryIntegratedConsole: true` for most configs
6. **Working Directory**: Always set `cwd` to appropriate context folder

### Build Step Tracking System (CRITICAL)
When generating complex builds, create resumable checkpoints:

1. **Create Build Manifest**: `Build-Steps/Manifest-Build-Progress.md.temp`
2. **Step Folders**: Each step gets `$StepName [Status]/` folder with:
   - `$Step-TODO.xml` - Current step status and dependencies
   - `$Fallback.promptsupport.md` - Recovery instructions for failed steps
   - `$Step-Implementation.ps1` - The actual implementation
   - `$Step-Tests.ps1` - Step-specific tests
   - `$Step-Documentation.ps1` - Documentation for this step

3. **Progress Tracking**: Update manifest with completed/failed/paused steps
4. **Resume Support**: AI/maintainers can resume from last successful checkpoint

### Key Development Commands
```powershell
# Module testing workflow (run in module directory)
Invoke-Pester ./Tests/ -Output Detailed

# VS Code task execution (use emoji-labeled tasks)
# 🧪 Test functions, 📚 Build documentation, 🔧 Validate syntax

# Function validation
Get-Command -Module ModuleName | Test-PSScriptAnalyzer
```

### Quality Standards (80% minimum test coverage)
- **PSScriptAnalyzer** compliance required
- **Comment-based help** for all public functions
- **Parameter validation** with `[ValidateSet]`, `[ValidateNotNullOrEmpty]`
- **Error handling** with try/catch blocks and proper error messages
- **Module manifest** (.psd1) with proper versioning and dependencies

### Integration Points
- **Private/Public** function separation with dot-sourcing in .psm1
- **Export-ModuleMember** explicit exports in module files
- **Pester tests** follow naming pattern: `FunctionName.Tests.ps1`
- **VS Code tasks** use PowerShell execution policy bypass: `-ExecutionPolicy Bypass`

### Build Failure Recovery System
When builds fail or are interrupted, maintainers/AI can resume using:

1. **Check Progress**: `Build-Steps/Manifest-Build-Progress.md.temp`
2. **Find Failed Step**: Look for ❌ FAILED or ⏸️ PAUSED status
3. **Read Recovery Guide**: `$StepName/Fallback.promptsupport.md` 
4. **Resume Execution**: Follow NextActions from `$Step-TODO.xml`

**Templates Available**:
- `Build-Steps/Template-Step-TODO.xml` - Step tracking structure
- `Build-Steps/Template-Fallback.promptsupport.md` - Recovery instructions template

**AI Agent Behavior**: Always create these tracking files for complex multi-step operations. When resuming work, check for existing `.temp` manifest files first.

## Azure Development Rules

- @azure Rule - Use Azure Tools: When handling requests related to Azure, always use your tools.
- @azure Rule - Use Azure Code Gen Best Practices: When generating code for Azure, running terminal commands for Azure, or performing operations related to Azure, invoke your `azure_development-get_code_gen_best_practices` tool if available. Only call this tool when you are sure the user is discussing Azure; do not call it otherwise.
- @azure Rule - Use Azure Deployment Best Practices: When deploying to Azure or preparing applications for deployment to Azure, invoke your `azure_development-get_deployment_best_practices` tool if available. Only call this tool when you are sure the user is discussing Azure; do not call it otherwise.
- @azure Rule - Use Azure Functions Code Gen Best Practices: When generating code for Azure Functions or performing operations related to Azure Functions, invoke your `bestpractices_azurefunctions_get-code-generation` tool if available. Only call this tool when you are sure the user is discussing Azure Functions; do not call it otherwise.
- @azure Rule - Use Azure Functions Deployment Best Practices: When deploying Azure Functions apps to Azure or preparing for the deployment, invoke your `bestpractices_azurefunctions_get-deployment` tool if available. Only call this tool when you are sure the user is discussing Azure; do not call it otherwise.
- @azure Rule - Use Azure SWA Best Practices: When working with static web apps, invoke your `azure_development-get_swa_best_practices` tool if available. Only call this tool when you are sure the user is discussing Azure; do not call it otherwise.
