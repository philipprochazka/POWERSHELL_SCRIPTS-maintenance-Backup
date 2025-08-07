#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Reorganizes the PowerShell repository into the new UnifiedPowerShell structure.

.DESCRIPTION
    This script reorganizes the repository to follow the UnifiedPowerShell naming convention
    and structure with proper module separation:
    - UnifiedMCPProfile: Core MCP integration and AI assistance
    - UnifiedPowerShellProfile: Advanced PowerShell profile system

.PARAMETER WhatIf
    Shows what would be done without making changes.

.PARAMETER AutoCommit
    Automatically commits changes with descriptive messages.

.EXAMPLE
    .\Build-UnifiedPowerShellReorganization.ps1 -WhatIf
    Shows the reorganization plan without making changes.

.EXAMPLE
    .\Build-UnifiedPowerShellReorganization.ps1 -AutoCommit
    Performs the reorganization and commits changes.
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter()]
    [switch]$WhatIf,
    
    [Parameter()]
    [switch]$AutoCommit
)

function Write-StepHeader {
    param([string]$StepName, [string]$Description)
    Write-Host "`n🔧 $StepName" -ForegroundColor Cyan
    Write-Host "   $Description" -ForegroundColor Gray
    Write-Host ("=" * 60) -ForegroundColor DarkGray
}

function Test-DirectoryExists {
    param([string]$Path)
    return Test-Path -Path $Path -PathType Container
}

function New-DirectoryIfNotExists {
    param([string]$Path)
    if (-not (Test-DirectoryExists -Path $Path)) {
        if ($PSCmdlet.ShouldProcess($Path, "Create Directory")) {
            New-Item -Path $Path -ItemType Directory -Force | Out-Null
            Write-Host "✅ Created directory: $Path" -ForegroundColor Green
        }
    } else {
        Write-Host "ℹ️  Directory already exists: $Path" -ForegroundColor Yellow
    }
}

function Move-ModuleToNewStructure {
    param(
        [string]$SourcePath,
        [string]$DestinationPath,
        [string]$ModuleName
    )
    
    if (Test-Path -Path $SourcePath) {
        if ($PSCmdlet.ShouldProcess($SourcePath, "Move to $DestinationPath")) {
            New-DirectoryIfNotExists -Path (Split-Path $DestinationPath -Parent)
            
            if (Test-Path -Path $DestinationPath) {
                Write-Host "⚠️  Destination already exists, merging: $DestinationPath" -ForegroundColor Yellow
                # Copy content instead of moving if destination exists
                Copy-Item -Path "$SourcePath\*" -Destination $DestinationPath -Recurse -Force
                Remove-Item -Path $SourcePath -Recurse -Force
            } else {
                Move-Item -Path $SourcePath -Destination $DestinationPath -Force
            }
            Write-Host "✅ Moved $ModuleName module to new structure" -ForegroundColor Green
        }
    } else {
        Write-Host "⚠️  Source module not found: $SourcePath" -ForegroundColor Yellow
    }
}

# Main reorganization process
try {
    $WorkspaceRoot = $PSScriptRoot
    Write-Host "🚀 Starting UnifiedPowerShell Repository Reorganization" -ForegroundColor Magenta
    Write-Host "📁 Workspace: $WorkspaceRoot" -ForegroundColor Gray
    
    # Step 1: Create the new directory structure
    Write-StepHeader "Step 1" "Creating UnifiedPowerShell directory structure"
    
    $NewStructure = @(
        "Scripts",
        "Examples", 
        "PowerShellModules\UnifiedMCPProfile",
        "PowerShellModules\UnifiedPowerShellProfile",
        "Tests\Unit",
        "Tests\Integration", 
        "Tests\Performance",
        "Tests\Reports",
        "docs\functions",
        "docs\guides",
        "Build-Steps"
    )
    
    foreach ($Directory in $NewStructure) {
        $FullPath = Join-Path $WorkspaceRoot $Directory
        New-DirectoryIfNotExists -Path $FullPath
    }
    
    # Step 2: Move UnifiedPowerShellProfile from Theme/ to PowerShellModules/
    Write-StepHeader "Step 2" "Moving UnifiedPowerShellProfile to proper location"
    
    $SourceProfile = Join-Path $WorkspaceRoot "Theme\UnifiedPowerShellProfile"
    $DestProfile = Join-Path $WorkspaceRoot "PowerShellModules\UnifiedPowerShellProfile"
    
    Move-ModuleToNewStructure -SourcePath $SourceProfile -DestinationPath $DestProfile -ModuleName "UnifiedPowerShellProfile"
    
    # Step 3: Ensure UnifiedMCPProfile is properly structured
    Write-StepHeader "Step 3" "Validating UnifiedMCPProfile structure"
    
    $MCPProfile = Join-Path $WorkspaceRoot "PowerShellModules\UnifiedMCPProfile"
    if (Test-Path $MCPProfile) {
        Write-Host "✅ UnifiedMCPProfile is already in correct location" -ForegroundColor Green
        
        # Ensure it has all required directories
        $MCPRequiredDirs = @("Public", "Private", "Tests", "docs", "Build-Steps")
        foreach ($Dir in $MCPRequiredDirs) {
            $DirPath = Join-Path $MCPProfile $Dir
            New-DirectoryIfNotExists -Path $DirPath
        }
    } else {
        Write-Host "⚠️  UnifiedMCPProfile not found in expected location" -ForegroundColor Yellow
    }
    
    # Step 4: Organize loose scripts into Scripts/ directory
    Write-StepHeader "Step 4" "Organizing loose PowerShell scripts"
    
    $ScriptsToMove = Get-ChildItem -Path $WorkspaceRoot -Filter "*.ps1" | 
    Where-Object { $_.Name -notlike "Build-*" -and $_.Name -notlike "*profile*" }
    
    foreach ($Script in $ScriptsToMove) {
        $DestPath = Join-Path $WorkspaceRoot "Scripts\$($Script.Name)"
        if ($PSCmdlet.ShouldProcess($Script.FullName, "Move to Scripts directory")) {
            Move-Item -Path $Script.FullName -Destination $DestPath -Force
            Write-Host "📝 Moved script: $($Script.Name)" -ForegroundColor Green
        }
    }
    
    # Step 5: Update documentation
    Write-StepHeader "Step 5" "Updating repository documentation"
    
    $ReadmePath = Join-Path $WorkspaceRoot "README.md"
    if (Test-Path $ReadmePath) {
        $ReadmeContent = Get-Content $ReadmePath -Raw
        $NewReadmeContent = $ReadmeContent -replace "PowerShell.*Repository", "UnifiedPowerShell Repository"
        $NewReadmeContent = $NewReadmeContent -replace "powershell-scripts", "UnifiedPowerShell"
        
        if ($PSCmdlet.ShouldProcess($ReadmePath, "Update README.md")) {
            Set-Content -Path $ReadmePath -Value $NewReadmeContent -Encoding UTF8
            Write-Host "📖 Updated README.md with new naming" -ForegroundColor Green
        }
    }
    
    # Step 6: Create module manifest documentation
    Write-StepHeader "Step 6" "Creating module documentation"
    
    $ModulesDoc = @"
# UnifiedPowerShell Module Structure

## Core Modules

### UnifiedMCPProfile
**Purpose**: Core MCP (Model Context Protocol) integration and AI assistance
**Location**: `PowerShellModules/UnifiedMCPProfile/`
**Features**:
- MCP server integration
- AI-powered development assistance  
- Code generation and optimization
- Automated testing integration

### UnifiedPowerShellProfile
**Purpose**: Advanced PowerShell profile system
**Location**: `PowerShellModules/UnifiedPowerShellProfile/`
**Features**:
- Enhanced PowerShell experience
- Theme management (Dracula, etc.)
- Performance optimizations
- Module loading and configuration

## Directory Structure
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

## Usage

### Installing UnifiedMCPProfile
```powershell
Import-Module './PowerShellModules/UnifiedMCPProfile' -Force
```

### Installing UnifiedPowerShellProfile  
```powershell
Import-Module './PowerShellModules/UnifiedPowerShellProfile' -Force
```

## Development Workflow

1. **Function Development**: Create functions following PowerShell approved verbs
2. **Testing**: Write comprehensive Pester tests in `Tests/` directory
3. **Documentation**: Generate function documentation in `docs/functions/`
4. **Quality Assurance**: Use PSScriptAnalyzer for code quality checks

## Naming Conventions

- ✅ **REQUIRED**: PowerShell approved verbs (Get, Set, New, Remove, Install, Build, Test, Initialize)
- ❌ **PROHIBITED**: `Setup-*` functions → use `Install-*`
- ❌ **PROHIBITED**: `Create-*` functions → use `Build-*`, `New-*`, or `Initialize-*`
- ✅ **REQUIRED**: PascalCase for all function names
"@
    
    $ModulesDocPath = Join-Path $WorkspaceRoot "docs\UnifiedPowerShell-Modules.md"
    if ($PSCmdlet.ShouldProcess($ModulesDocPath, "Create module documentation")) {
        Set-Content -Path $ModulesDocPath -Value $ModulesDoc -Encoding UTF8
        Write-Host "📚 Created UnifiedPowerShell modules documentation" -ForegroundColor Green
    }
    
    # Step 7: Commit changes if requested
    if ($AutoCommit -and -not $WhatIf) {
        Write-StepHeader "Step 7" "Committing reorganization changes"
        
        if ($PSCmdlet.ShouldProcess("Repository", "Commit reorganization changes")) {
            & git add .
            & git commit -m "🔧 Repository reorganization to UnifiedPowerShell structure

- Moved UnifiedPowerShellProfile from Theme/ to PowerShellModules/
- Organized loose scripts into Scripts/ directory  
- Created proper module documentation
- Updated README.md with new naming convention
- Established clear separation between MCP and Profile modules

Structure:
- UnifiedMCPProfile: Core MCP integration and AI assistance
- UnifiedPowerShellProfile: Advanced PowerShell profile system"
            
            Write-Host "✅ Changes committed successfully" -ForegroundColor Green
        }
    }
    
    Write-Host "`n🎉 UnifiedPowerShell reorganization completed successfully!" -ForegroundColor Magenta
    Write-Host "📋 Summary:" -ForegroundColor Cyan
    Write-Host "  • Repository structure updated to UnifiedPowerShell standard" -ForegroundColor Green
    Write-Host "  • UnifiedPowerShellProfile moved to PowerShellModules/" -ForegroundColor Green  
    Write-Host "  • Scripts organized into Scripts/ directory" -ForegroundColor Green
    Write-Host "  • Documentation updated with new structure" -ForegroundColor Green
    
    if (-not $AutoCommit) {
        Write-Host "`n💡 Run with -AutoCommit to commit these changes to Git" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "❌ Error during reorganization: $_" -ForegroundColor Red
    Write-Host "🔍 Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Gray
    exit 1
}
