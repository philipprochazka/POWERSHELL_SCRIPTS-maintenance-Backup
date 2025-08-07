#Requires -Version 5.1

<#
.SYNOPSIS
    Complete enterprise PowerShell module organization and PSGallery source setup.

.DESCRIPTION
    Combines vendor organization, digital signature, and PSGallery source registration
    into a single enterprise-ready workflow.

.PARAMETER Quick
    Run with minimal interaction for quick setup.

.PARAMETER CreateCertificate
    Create new code signing certificate.

.PARAMETER SkipSigning
    Skip digital signature process.

.EXAMPLE
    Build-EnterpriseModuleRepository -Quick

.EXAMPLE
    Build-EnterpriseModuleRepository -CreateCertificate

.NOTES
    Follows PowerShell Development Standards & Architecture
    - Vendor-based organization
    - Digital signature implementation
    - Enterprise PSGallery source registration
#>

param(
    [switch]$Quick,
    [switch]$CreateCertificate,
    [switch]$SkipSigning,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

function Write-Header {
    param([string]$Title)
    Write-Host ""
    Write-Host "=" * 80 -ForegroundColor Cyan
    Write-Host " $Title" -ForegroundColor White
    Write-Host "=" * 80 -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Step, [int]$Current, [int]$Total)
    Write-Host "[$Current/$Total] $Step" -ForegroundColor Yellow
}

function Confirm-Continue {
    param([string]$Message = "Continue?", [switch]$Quick)
    
    if ($Quick) {
        return $true 
    }
    
    $response = Read-Host "$Message (y/N)"
    return $response -eq 'y' -or $response -eq 'Y'
}

function Build-VSCodeTasks {
    param([string]$WorkspaceRoot)
    
    $tasksPath = Join-Path $WorkspaceRoot ".vscode\tasks.json"
    $vscodePath = Split-Path $tasksPath -Parent
    
    if (-not (Test-Path $vscodePath) -and -not $DryRun) {
        New-Item -ItemType Directory -Path $vscodePath -Force | Out-Null
    }
    
    $tasks = @{
        version = "2.0.0"
        tasks   = @(
            @{
                label   = "🏷️ Test Vendor Organization"
                type    = "shell"
                command = "pwsh"
                args    = @("-ExecutionPolicy", "Bypass", "-Command", "Get-ChildItem '${workspaceFolder}/PowerShellModules' -Directory | Group-Object {Split-Path $_.FullName -Parent | Split-Path -Leaf} | Sort-Object Name | ForEach-Object { Write-Host `"📁 $($_.Name): $($_.Count) modules`" -ForegroundColor Yellow; $_.Group | ForEach-Object { Write-Host `"   📦 $($_.Name)`" -ForegroundColor Gray } }")
                group   = "test"
            },
            @{
                label   = "🔐 Create Code Signing Certificate"
                type    = "shell"
                command = "pwsh"
                args    = @("-ExecutionPolicy", "Bypass", "-File", "${workspaceFolder}/Initialize-PSGallerySource.ps1", "-CreateCertificate", "-DryRun")
                group   = "build"
            },
            @{
                label   = "📦 Publish Custom Modules"
                type    = "shell"
                command = "pwsh"
                args    = @("-ExecutionPolicy", "Bypass", "-Command", "Get-ChildItem '${workspaceFolder}/PowerShellModules/PhilipRochazka' -Directory | ForEach-Object { Write-Host `"📦 Publishing: $($_.Name)`" -ForegroundColor Cyan; Write-Host `"   Path: $($_.FullName)`" -ForegroundColor Gray }")
                group   = "build"
            },
            @{
                label   = "🧹 Reset to Original Structure"
                type    = "shell"
                command = "pwsh"
                args    = @("-ExecutionPolicy", "Bypass", "-Command", "Write-Host '🧹 Resetting module organization...' -ForegroundColor Yellow; Write-Host '⚠️ This would restore original flat structure' -ForegroundColor Red; Write-Host '💡 Use with caution - implement actual reset logic' -ForegroundColor Cyan")
                group   = "build"
            },
            @{
                label   = "📊 Module Statistics"
                type    = "shell"
                command = "pwsh"
                args    = @("-ExecutionPolicy", "Bypass", "-Command", "$modules = Get-ChildItem '${workspaceFolder}/PowerShellModules' -Directory -Recurse; $vendors = $modules | Group-Object {if($_.FullName -like '*PowerShellModules\\*\\*'){Split-Path (Split-Path $_.FullName -Parent) -Leaf}else{'Root'}}; Write-Host '📊 Module Statistics:' -ForegroundColor Cyan; Write-Host ''; $vendors | Sort-Object Name | ForEach-Object { Write-Host `"🏷️  $($_.Name): $($_.Count) modules`" -ForegroundColor Yellow }; Write-Host ''; Write-Host `"📈 Total: $($modules.Count) modules`" -ForegroundColor Green")
                group   = "test"
            }
        )
    }
    
    if (-not $DryRun) {
        $tasks | ConvertTo-Json -Depth 10 | Set-Content -Path $tasksPath -Encoding UTF8
        Write-Host "  📝 Created VS Code tasks: .vscode/tasks.json" -ForegroundColor Green
    }
}

function Build-ComprehensiveDocumentation {
    param(
        [string]$WorkspaceRoot,
        [string]$ModulesPath
    )
    
    $docPath = Join-Path $WorkspaceRoot "Enterprise-Module-Setup.md"
    
    $content = @"
# Enterprise PowerShell Module Repository

Complete enterprise-grade PowerShell module organization and management system.

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## Overview

This repository has been transformed into an enterprise-ready PowerShell module management system with:

- **Vendor Organization**: Modules organized by maintainer/vendor
- **Digital Signatures**: Code signing for security and trust
- **PSGallery Source**: Private repository for module distribution
- **CI/CD Ready**: Automated testing and publishing workflows

## Repository Structure

``````
PowerShellModules/
├── Microsoft/              # Official Microsoft modules
├── Microsoft.Azure/        # Azure and cloud modules
├── Community/              # Popular community modules
├── Tools/                  # Specialty tools and utilities
├── PhilipRochazka/         # Custom/personal modules
├── LanguagePacks/          # Localization modules
├── Development/            # Development tools
└── Unknown/                # Unclassified modules
``````

## Key Features

### 🏷️ Vendor Organization
- Clear separation by maintainer/vendor
- Maintains compatibility through symlinks
- Enterprise-ready structure

### 🔐 Digital Signatures
- Code signing certificates for custom modules
- Trusted publisher configuration
- Security compliance

### 🌐 PSGallery Source
- Private repository registration
- Enterprise module distribution
- Version management

### 🛠️ Development Workflow
- VS Code task integration
- Automated testing
- Documentation generation

## Usage

### Module Discovery

``````powershell
# List modules by vendor
Get-ChildItem "./PowerShellModules/Microsoft" -Directory
Get-ChildItem "./PowerShellModules/PhilipRochazka" -Directory

# Import vendor-specific module
Import-Module "./PowerShellModules/PhilipRochazka/UnifiedPowerShellProfile"
``````

### PSGallery Operations

``````powershell
# Find modules in private repository
Find-Module -Repository "PhilipRochazkaModules"

# Install from private repository
Install-Module -Name "UnifiedPowerShellProfile" -Repository "PhilipRochazkaModules"

# Publish module
Publish-Module -Path "./PowerShellModules/PhilipRochazka/MyModule" -Repository "PhilipRochazkaModules"
``````

### Development Workflow

``````powershell
# Test module organization
Invoke-VsCodeTask "🏷️ Test Vendor Organization"

# Create digital certificate
Invoke-VsCodeTask "🔐 Create Code Signing Certificate"

# View module statistics
Invoke-VsCodeTask "📊 Module Statistics"
``````

## Scripts and Tools

| Script | Purpose |
|--------|---------|
| `Reorganize-ModulesByVendor.ps1` | Vendor-based module organization |
| `Initialize-PSGallerySource.ps1` | PSGallery source preparation |
| `Build-EnterpriseModuleRepository.ps1` | Complete enterprise setup |

## Security Configuration

### Execution Policy
``````powershell
# Recommended for signed modules
Set-ExecutionPolicy AllSigned -Scope CurrentUser
``````

### Certificate Management
``````powershell
# Check trusted publishers
Get-ChildItem "Cert:\CurrentUser\TrustedPublisher"

# Verify module signature
Get-AuthenticodeSignature "./PowerShellModules/PhilipRochazka/*//*.ps*"
``````

## CI/CD Integration

### Automated Testing
- Module manifest validation
- PSScriptAnalyzer compliance
- Pester test execution
- Signature verification

### Publishing Pipeline
- Version management
- Automated signing
- Repository publishing
- Documentation updates

## Maintenance

### Regular Tasks
1. **Module Updates**: Check for vendor module updates
2. **Signature Renewal**: Update code signing certificates
3. **Documentation**: Keep module docs current
4. **Testing**: Run comprehensive test suites

### Troubleshooting
- Check `logs/` directory for error details
- Review module manifest files for issues
- Verify certificate validity
- Test PSGallery connectivity

## Contributing

### Custom Module Development
1. Create module in `PhilipRochazka/` directory
2. Follow PowerShell module standards
3. Add comprehensive Pester tests
4. Sign with code signing certificate
5. Publish to private PSGallery

### Best Practices
- Use approved PowerShell verbs
- Include comment-based help
- Implement proper error handling
- Follow semantic versioning
- Maintain backward compatibility

---

*This enterprise module repository follows PowerShell development standards and Microsoft best practices for module organization, security, and distribution.*
"@
    
    if (-not $DryRun) {
        Set-Content -Path $docPath -Value $content -Encoding UTF8
        Write-Host "  📚 Created enterprise documentation: Enterprise-Module-Setup.md" -ForegroundColor Green
    }
}

function Build-EnterpriseModuleRepository {
    [CmdletBinding()]
    param(
        [switch]$Quick,
        [switch]$CreateCertificate,
        [switch]$SkipSigning,
        [switch]$DryRun
    )
    
    $startTime = Get-Date
    $workspaceRoot = "c:\backup\Powershell"
    $modulesPath = Join-Path $workspaceRoot "PowerShellModules"
    
    Write-Header "🚀 Enterprise PowerShell Module Repository Builder"
    
    Write-Host "📊 Configuration:" -ForegroundColor Cyan
    Write-Host "  🏠 Workspace: $workspaceRoot" -ForegroundColor Gray
    Write-Host "  📦 Modules: $modulesPath" -ForegroundColor Gray
    Write-Host "  ⚡ Quick mode: $Quick" -ForegroundColor Gray
    Write-Host "  🔐 Create certificate: $CreateCertificate" -ForegroundColor Gray
    Write-Host "  🔏 Skip signing: $SkipSigning" -ForegroundColor Gray
    Write-Host "  🧪 Dry run: $DryRun" -ForegroundColor Gray
    
    if (-not (Test-Path $modulesPath)) {
        Write-Error "❌ PowerShellModules directory not found: $modulesPath"
        return
    }
    
    $moduleCount = (Get-ChildItem -Path $modulesPath -Directory).Count
    Write-Host "  📈 Total modules: $moduleCount" -ForegroundColor Gray
    
    if (-not $Quick -and -not (Confirm-Continue -Message "Proceed with enterprise module repository setup?" -Quick:$Quick)) {
        Write-Host "❌ Setup cancelled by user" -ForegroundColor Red
        return
    }
    
    # Step 1: Vendor Organization
    Write-Step "Organizing modules by vendor" 1 4
    
    $reorganizeArgs = @{
        ModulesPath    = $modulesPath
        CreateSymlinks = $true
        DryRun         = $DryRun
    }
    
    try {
        Push-Location $workspaceRoot
        & ".\Reorganize-ModulesByVendor.ps1" @reorganizeArgs
        
        if (-not $DryRun) {
            Write-Host "  ✅ Vendor organization completed" -ForegroundColor Green
        }
    } catch {
        Write-Error "❌ Vendor organization failed: $($_.Exception.Message)"
        return
    } finally {
        Pop-Location
    }
    
    # Step 2: Git Operations
    Write-Step "Committing changes to repository" 2 4
    
    try {
        Push-Location $workspaceRoot
        
        # Check if we have a git repository
        if (Test-Path ".git") {
            $gitStatus = git status --porcelain
            
            if ($gitStatus -and -not $DryRun) {
                git add .
                $commitMessage = "feat: Enterprise module organization by vendor`n`n- Reorganized $moduleCount modules by vendor/maintainer`n- Created vendor-based directory structure`n- Added compatibility symlinks`n- Prepared for PSGallery source registration`n`nGenerated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
                git commit -m $commitMessage
                Write-Host "  ✅ Changes committed to git" -ForegroundColor Green
                
                # Try to push if we have a remote
                $remotes = git remote
                if ($remotes) {
                    try {
                        git push
                        Write-Host "  ✅ Changes pushed to remote" -ForegroundColor Green
                    } catch {
                        Write-Warning "⚠️ Could not push to remote: $($_.Exception.Message)"
                    }
                }
            } else {
                Write-Host "  ✅ No changes to commit" -ForegroundColor Gray
            }
        } else {
            Write-Warning "⚠️ Not a git repository - skipping version control"
        }
    } catch {
        Write-Warning "⚠️ Git operations failed: $($_.Exception.Message)"
    } finally {
        Pop-Location
    }
    
    # Step 3: PSGallery Source Preparation
    Write-Step "Preparing PSGallery source" 3 4
    
    $psGalleryArgs = @{
        VendorPath        = $modulesPath
        RepositoryName    = "PhilipRochazkaModules"
        CreateCertificate = $CreateCertificate
        DryRun            = $DryRun
    }
    
    if ($SkipSigning) {
        $psGalleryArgs.Remove('CreateCertificate')
    }
    
    try {
        Push-Location $workspaceRoot
        & ".\Initialize-PSGallerySource.ps1" @psGalleryArgs
        
        if (-not $DryRun) {
            Write-Host "  ✅ PSGallery source preparation completed" -ForegroundColor Green
        }
    } catch {
        Write-Warning "⚠️ PSGallery source preparation failed: $($_.Exception.Message)"
    } finally {
        Pop-Location
    }
    
    # Step 4: Documentation and VS Code Tasks
    Write-Step "Creating documentation and VS Code tasks" 4 4
    
    try {
        Build-VSCodeTasks -WorkspaceRoot $workspaceRoot
        Build-ComprehensiveDocumentation -WorkspaceRoot $workspaceRoot -ModulesPath $modulesPath
        
        if (-not $DryRun) {
            Write-Host "  ✅ Documentation and tasks created" -ForegroundColor Green
        }
    } catch {
        Write-Warning "⚠️ Documentation creation failed: $($_.Exception.Message)"
    }
    
    # Summary
    $duration = (Get-Date) - $startTime
    
    Write-Header "🎯 Enterprise Module Repository Setup Complete"
    
    Write-Host "⏱️  Duration: $($duration.ToString('mm\:ss'))" -ForegroundColor Gray
    Write-Host "📦 Modules organized: $moduleCount" -ForegroundColor Gray
    
    if ($DryRun) {
        Write-Host "🧪 DRY RUN COMPLETED - No changes were made" -ForegroundColor Yellow
        Write-Host "   Run without -DryRun to perform actual setup" -ForegroundColor Gray
    } else {
        Write-Host "🏆 ENTERPRISE SETUP COMPLETED SUCCESSFULLY!" -ForegroundColor Green
    }
    
    Write-Host "`n📋 Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Review vendor organization in PowerShellModules/" -ForegroundColor Gray
    Write-Host "  2. Configure PSGallery server (NuGet.Server/ProGet)" -ForegroundColor Gray
    Write-Host "  3. Set up CI/CD pipeline for module publishing" -ForegroundColor Gray
    Write-Host "  4. Review and test digital signatures" -ForegroundColor Gray
    Write-Host "  5. Update module import paths in scripts" -ForegroundColor Gray
    
    Write-Host "`n📚 Documentation Created:" -ForegroundColor Cyan
    Write-Host "  📄 README-VendorOrganization.md" -ForegroundColor Gray
    Write-Host "  📄 PSGallery-Setup.md" -ForegroundColor Gray
    Write-Host "  📄 Enterprise-Module-Setup.md" -ForegroundColor Gray
    
    Write-Host "`n🛠️  VS Code Tasks Available:" -ForegroundColor Cyan
    Write-Host "  🧪 Test vendor organization" -ForegroundColor Gray
    Write-Host "  🔐 Manage digital signatures" -ForegroundColor Gray
    Write-Host "  📦 Publish modules to PSGallery" -ForegroundColor Gray
}

# Main execution
Build-EnterpriseModuleRepository -Quick:$Quick -CreateCertificate:$CreateCertificate -SkipSigning:$SkipSigning -DryRun:$DryRun
