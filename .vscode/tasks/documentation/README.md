# 📚 Documentation Tasks

This module contains tasks for building, maintaining, and validating project documentation and code quality.

## 📋 Available Tasks

### Documentation Building

#### 📚 Build Module Documentation (Enhanced)
**Comprehensive documentation generation** with all features.
- Generates complete module documentation
- Creates Pester tests automatically
- Updates project structure
- Performs Git remote search
- Creates build progress manifest
- Full VS Code integration

#### 📝 Build Documentation (Quick)
**Fast documentation build** for regular updates.
- Quick documentation generation
- Git remote detection
- Basic module documentation
- Minimal overhead process

#### 🔍 Build Documentation with Git Search
**Git-aware documentation building**.
- Detects Git remote repositories
- Creates build progress tracking
- Verbose output for troubleshooting
- Generates build manifest

#### 🧪 Build Documentation + Tests + Tasks
**Complete build pipeline** with testing and task generation.
- Full documentation generation
- Automatic test creation
- Project structure updates
- Build manifests
- VS Code task integration

### Quality Assurance

#### 📊 Documentation Quality Check
**Quality validation** of documentation and tests.
- Counts documentation files
- Verifies test file existence
- Shows file structure overview
- Identifies missing components

#### 🔧 Validate Profile Syntax
**PowerShell syntax validation** for all profile files.
- Parses all Microsoft.PowerShell_profile*.ps1 files
- Syntax error detection
- Parser validation
- Error reporting

### Build Management

#### 🔄 Resume Documentation Build
**Resume interrupted builds** using build manifests.
- Checks for existing build manifest
- Shows build progress
- Resumes from last checkpoint
- Fallback to fresh build if needed

#### 💾 Commit All Repositories
**Automated Git commits** across all repositories.
- Scans workspace and PowerShellModules
- Detects Git repositories
- Commits pending changes
- Auto-generated commit messages
- Error handling per repository

## 🎯 Usage Workflow

### First-Time Documentation Build
1. **Enhanced Build**: Run "📚 Build Module Documentation (Enhanced)"
2. **Quality Check**: Use "📊 Documentation Quality Check"
3. **Syntax Validation**: Run "🔧 Validate Profile Syntax"
4. **Commit Changes**: Use "💾 Commit All Repositories"

### Regular Documentation Updates
1. **Quick Build**: Use "📝 Build Documentation (Quick)"
2. **Quality Check**: Run "📊 Documentation Quality Check"
3. **Commit Updates**: Use "💾 Commit All Repositories"

### Interrupted Build Recovery
1. **Check Progress**: Run "🔄 Resume Documentation Build"
2. **Continue Building**: Use appropriate build task
3. **Validate Results**: Run "📊 Documentation Quality Check"

### Development Workflow
1. **Build with Tests**: Use "🧪 Build Documentation + Tests + Tasks"
2. **Validate Syntax**: Run "🔧 Validate Profile Syntax"
3. **Quality Check**: Use "📊 Documentation Quality Check"
4. **Commit Work**: Run "💾 Commit All Repositories"

## 🔧 Build Features

### Enhanced Documentation Generation
- **Module Scanning**: Automatic PowerShell module discovery
- **Function Documentation**: Generates .md files for all functions
- **Test Generation**: Creates Pester test files
- **VS Code Integration**: Generates tasks and launch configurations

### Build Progress Tracking
- **Manifest Creation**: `Build-Steps/Manifest-Build-Progress.md.temp`
- **Step Tracking**: Individual step status and dependencies
- **Resume Capability**: Continue from interruption points
- **Fallback Support**: Recovery instructions for failed steps

### Git Integration
- **Remote Detection**: Finds Git repositories automatically
- **Status Monitoring**: Checks for uncommitted changes
- **Automated Commits**: Commits documentation updates
- **Multi-Repository**: Handles workspace and submodules

## 📁 Build Outputs

### Documentation Structure
```
docs/
├── index.md                    # Main documentation hub
├── functions/                  # Function-specific docs
│   ├── Function1.md
│   └── Function2.md
└── modules/                    # Module documentation
    ├── Module1/
    └── Module2/
```

### Test Structure
```
Tests/
├── Function1.Tests.ps1         # Pester tests
├── Function2.Tests.ps1
└── Module.Tests.ps1           # Module-level tests
```

### Build Tracking
```
Build-Steps/
├── Manifest-Build-Progress.md.temp    # Progress tracking
├── Template-Step-TODO.xml             # Step template
├── Template-Fallback.promptsupport.md # Recovery template
└── StepName [Status]/                  # Individual steps
    ├── Step-TODO.xml
    ├── Fallback.promptsupport.md
    ├── Step-Implementation.ps1
    ├── Step-Tests.ps1
    └── Step-Documentation.ps1
```

## 🎯 Quality Standards

### Documentation Requirements
- **Function Documentation**: All public functions documented
- **Module Documentation**: Complete module guides
- **Usage Examples**: Practical examples for all features
- **README Files**: Module-specific documentation

### Test Requirements
- **80% Coverage**: Minimum test coverage target
- **Pester Framework**: Standard PowerShell testing
- **Function Testing**: Individual function validation
- **Integration Testing**: Module-level testing

### Code Quality
- **PSScriptAnalyzer**: PowerShell best practices
- **Syntax Validation**: Parser verification
- **Comment-Based Help**: Proper help documentation
- **Parameter Validation**: Input validation

## 🔧 Requirements

### System Requirements
- **PowerShell 7+**: Latest PowerShell version
- **Git**: For version control features
- **Pester**: For test generation and execution
- **PSScriptAnalyzer**: For code quality (optional)

### File Access Requirements
- **Write Permissions**: For documentation generation
- **Git Access**: For repository operations
- **Module Paths**: Access to PowerShell modules

### Dependencies
- **Build-ModuleDocumentation.ps1**: Main build script
- **UnifiedPowerShellProfile**: For enhanced features
- **VS Code**: For task and launch config generation

## 🔍 Troubleshooting

### Common Build Issues
- **Permission Errors**: Check file/folder permissions
- **Git Errors**: Verify Git repository status
- **Module Loading**: Ensure PowerShell modules accessible
- **Path Issues**: Check workspace folder paths

### Recovery Strategies
1. **Check Build Manifest**: Look for `.temp` files in Build-Steps
2. **Resume from Checkpoint**: Use "🔄 Resume Documentation Build"
3. **Fresh Start**: Remove Build-Steps folder and rebuild
4. **Validate Prerequisites**: Check Git, PowerShell, and modules

### Quality Issues
- **Missing Documentation**: Run enhanced build task
- **Syntax Errors**: Use "🔧 Validate Profile Syntax"
- **Test Failures**: Check generated test files
- **Git Conflicts**: Resolve before committing

## 📊 Performance Optimization

### Build Performance
- **Incremental Builds**: Only update changed components
- **Parallel Processing**: Multiple modules simultaneously
- **Caching**: Reuse previous build artifacts
- **Selective Updates**: Target specific modules/functions

### Quality Checks
- **Fast Syntax Validation**: Parser-based checking
- **Incremental Testing**: Only test changed components
- **Automated Quality Gates**: Fail fast on critical issues
- **Report Generation**: HTML reports for detailed analysis
