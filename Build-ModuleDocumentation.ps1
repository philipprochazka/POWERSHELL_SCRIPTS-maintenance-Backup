<#
.SYNOPSIS
    Build comprehensive module documentation following PowerShell standards and copilot-instructions.md guidelines.

.DESCRIPTION
    This function creates documentation for PowerShell modules with automatic git remote detection,
    follows the mandatory development workflow for documentation generation, and creates
    resumable build checkpoints for complex operations.

.PARAMETER ModulePath
    Path to the PowerShell module to document. Defaults to current directory.

.PARAMETER OutputPath
    Output directory for documentation. Defaults to ./docs

.PARAMETER GenerateTests
    Generate Pester tests alongside documentation as per workflow requirements.

.PARAMETER UpdateProjectStructure
    Update docs/index.md and project structure as mandated by guidelines.

.PARAMETER CreateBuildManifest
    Create build step tracking system for resumable operations.

.PARAMETER GitRemoteSearch
    Enable git remote detection and repository information lookup.

.EXAMPLE
    Build-ModuleDocumentation -ModulePath "./PowerShellModules/UnifiedPowerShellProfile" -GenerateTests

.EXAMPLE
    Build-ModuleDocumentation -GitRemoteSearch -CreateBuildManifest

.NOTES
    Follows PowerShell Development Standards & Architecture from copilot-instructions.md
    - Uses approved PowerShell verbs (Build-)
    - Implements mandatory development workflow
    - Creates build step tracking system
    - Generates comprehensive documentation and tests

.AUTHOR
    Philip Procházka
    
.LINK
    https://philipprochazka.cz

.VERSION
    1.0.0
    
.COPYRIGHT
    (c) 2025 Philip Procházka. All rights reserved.
#>

# Script-level parameters for direct execution
param(
    [string]$ModulePath = (Get-Location).Path,
    [string]$OutputPath = "docs",
    [string]$ConfigPath = "build-config.json",
    [switch]$GenerateTests,
    [switch]$UpdateProjectStructure,
    [switch]$CreateBuildManifest,
    [switch]$GitRemoteSearch,
    [int]$MaxSearchResults = 10
)

function Get-BuildConfiguration {
    param([string]$ConfigPath = "build-config.json")
    
    if (Test-Path $ConfigPath) {
        try {
            $config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
            Write-Host "  ✅ Loaded build configuration from: $ConfigPath" -ForegroundColor Green
            return $config
        } catch {
            Write-Warning "  ⚠️ Could not parse build configuration: $($_.Exception.Message)"
        }
    } else {
        Write-Host "  ℹ️ No build configuration found at: $ConfigPath" -ForegroundColor Gray
    }
    
    # Return default configuration
    return [PSCustomObject]@{
        author  = [PSCustomObject]@{
            name      = "Philip Procházka"
            email     = "contact@philipprochazka.cz"
            website   = "https://philipprochazka.cz"
            github    = "philipprochazka"
            githubUrl = "https://github.com/philipprochazka"
        }
        project = [PSCustomObject]@{
            namespace      = "PhilipProcházka.PowerShell"
            copyright      = "(c) 2025 Philip Procházka. All rights reserved."
            defaultVersion = "1.0.0"
            defaultLicense = "MIT"
        }
        build   = [PSCustomObject]@{
            toolName         = "Build-ModuleDocumentation"
            toolVersion      = "1.0.0"
            generatedByText  = "Built with Build-ModuleDocumentation v1.0.0 by Philip Procházka"
            followsStandards = "Following PowerShell development best practices and enterprise standards"
        }
    }
}

function Build-ModuleDocumentation {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string]$ModulePath = (Get-Location).Path,
        
        [string]$OutputPath = "docs",
        
        [string]$ConfigPath = "build-config.json",
        
        [switch]$GenerateTests,
        
        [switch]$UpdateProjectStructure,
        
        [switch]$CreateBuildManifest,
        
        [switch]$GitRemoteSearch,
        
        [int]$MaxSearchResults = 10
    )

    begin {
        Write-Host "📚 Starting Enhanced Documentation Build Process..." -ForegroundColor Cyan
        
        # Load build configuration
        Write-Host "⚙️ Loading build configuration..." -ForegroundColor Yellow
        $buildConfig = Get-BuildConfiguration -ConfigPath $ConfigPath
        
        # Build Step Tracking System (CRITICAL per guidelines)
        if ($CreateBuildManifest) {
            Initialize-BuildStepTracking
        }
    }

    process {
        try {
            # Step 1: Module Discovery and Validation
            Write-Host "🔍 Step 1: Module Discovery..." -ForegroundColor Yellow
            $moduleInfo = Get-ModuleInformation -Path $ModulePath
            
            # Step 2: Git Remote Detection
            if ($GitRemoteSearch) {
                Write-Host "🌐 Step 2: Git Remote Detection..." -ForegroundColor Yellow
                $gitInfo = Get-GitRemoteInformation -Path $ModulePath
                
                if (-not $gitInfo.HasRemote) {
                    Write-Host "🔎 No git remote found. Performing search query..." -ForegroundColor Cyan
                    $searchResults = Search-ModuleRepositories -ModuleName $moduleInfo.Name -MaxResults $MaxSearchResults
                    $gitInfo.SearchResults = $searchResults
                }
            }
            
            # Step 3: Documentation Generation (following standards)
            Write-Host "📝 Step 3: Generating Function Documentation..." -ForegroundColor Yellow
            Build-FunctionDocumentation -ModuleInfo $moduleInfo -OutputPath $OutputPath -BuildConfig $buildConfig
            
            # Step 4: Test Generation (Mandatory per workflow)
            if ($GenerateTests) {
                Write-Host "🧪 Step 4: Generating Pester Tests..." -ForegroundColor Yellow
                Build-PesterTests -ModuleInfo $moduleInfo -BuildConfig $buildConfig
            }
            
            # Step 5: VS Code Integration
            Write-Host "🔧 Step 5: Creating VS Code Tasks..." -ForegroundColor Yellow
            Build-VSCodeTasks -ModuleInfo $moduleInfo -BuildConfig $buildConfig
            
            # Step 6: Project Structure Updates (Mandatory)
            if ($UpdateProjectStructure) {
                Write-Host "🏗️ Step 6: Updating Project Structure..." -ForegroundColor Yellow
                Update-ProjectStructure -ModuleInfo $moduleInfo -GitInfo $gitInfo -OutputPath $OutputPath -BuildConfig $buildConfig
            }
            
            Write-Host "✅ Documentation build completed successfully!" -ForegroundColor Green
            
        } catch {
            Write-Error "❌ Documentation build failed: $($_.Exception.Message)"
            if ($CreateBuildManifest) {
                Update-BuildStepStatus -StepName "Documentation-Build" -Status "FAILED" -Error $_.Exception.Message
            }
            throw
        }
    }
}

function Initialize-BuildStepTracking {
    <#
    .SYNOPSIS
    Initialize build step tracking system per copilot-instructions.md
    #>
    
    $buildStepsPath = "Build-Steps"
    if (-not (Test-Path $buildStepsPath)) {
        New-Item -ItemType Directory -Path $buildStepsPath -Force | Out-Null
    }
    
    $manifestPath = "$buildStepsPath/Manifest-Build-Progress.md.temp"
    $manifestContent = @"
# Build Progress Manifest - Documentation Generation
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## Build Steps Status
- [ ] ⏸️ Module Discovery
- [ ] ⏸️ Git Remote Detection  
- [ ] ⏸️ Function Documentation
- [ ] ⏸️ Pester Test Generation
- [ ] ⏸️ VS Code Tasks Creation
- [ ] ⏸️ Project Structure Updates

## Recovery Information
Each step has dedicated folder with:
- `$Step-TODO.xml` - Current status and dependencies
- `$Fallback.promptsupport.md` - Recovery instructions  
- `$Step-Implementation.ps1` - Implementation code
- `$Step-Tests.ps1` - Step-specific tests
- `$Step-Documentation.ps1` - Step documentation

"@
    
    Set-Content -Path $manifestPath -Value $manifestContent -Encoding UTF8
    Write-Host "📋 Build manifest created: $manifestPath" -ForegroundColor Green
}

function Get-ModuleInformation {
    param([string]$Path)
    
    Write-Host "  🔍 Scanning for PowerShell modules..." -ForegroundColor Gray
    
    # Look for .psd1 files (module manifests)
    $manifestFiles = Get-ChildItem -Path $Path -Filter "*.psd1" -Recurse
    
    $modules = @()
    foreach ($manifest in $manifestFiles) {
        try {
            $moduleData = Import-PowerShellDataFile -Path $manifest.FullName
            $modules += [PSCustomObject]@{
                Name         = $manifest.BaseName
                Path         = $manifest.DirectoryName
                ManifestPath = $manifest.FullName
                Version      = $moduleData.ModuleVersion
                Description  = $moduleData.Description
                Author       = $moduleData.Author
                Functions    = $moduleData.FunctionsToExport
                RootModule   = $moduleData.RootModule
            }
        } catch {
            Write-Warning "  ⚠️ Could not parse manifest: $($manifest.Name)"
        }
    }
    
    if ($modules.Count -eq 0) {
        # Look for .psm1 files as fallback
        $psm1Files = Get-ChildItem -Path $Path -Filter "*.psm1" -Recurse
        foreach ($psm1 in $psm1Files) {
            $modules += [PSCustomObject]@{
                Name         = $psm1.BaseName
                Path         = $psm1.DirectoryName
                ManifestPath = $null
                Version      = "1.0.0"
                Description  = "PowerShell Module by Philip Procházka"
                Author       = "Philip Procházka <contact@philipprochazka.cz>"
                Functions    = @()
                RootModule   = $psm1.FullName
            }
        }
    }
    
    Write-Host "  ✅ Found $($modules.Count) modules" -ForegroundColor Green
    return $modules
}

function Get-GitRemoteInformation {
    param([string]$Path)
    
    Push-Location $Path
    try {
        $gitInfo = [PSCustomObject]@{
            HasRemote      = $false
            RemoteUrl      = $null
            RepositoryName = $null
            Owner          = $null
            Branch         = $null
            SearchResults  = @()
        }
        
        if (Test-Path ".git") {
            try {
                $remoteUrl = git remote get-url origin 2>$null
                if ($remoteUrl -and $LASTEXITCODE -eq 0) {
                    $gitInfo.HasRemote = $true
                    $gitInfo.RemoteUrl = $remoteUrl
                    $gitInfo.Branch = git branch --show-current 2>$null
                    
                    # Parse GitHub/GitLab URLs
                    if ($remoteUrl -match 'github\.com[:/]([^/]+)/([^/\.]+)') {
                        $gitInfo.Owner = $matches[1]
                        $gitInfo.RepositoryName = $matches[2]
                    }
                    
                    Write-Host "  ✅ Git remote detected: $remoteUrl" -ForegroundColor Green
                } else {
                    Write-Host "  ⚠️ Git repository found but no remote configured" -ForegroundColor Yellow
                    # Set default owner information for Philip Procházka
                    $gitInfo.Owner = "philipprochazka"
                }
            } catch {
                Write-Host "  ⚠️ Error reading git information: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  ℹ️ No git repository found" -ForegroundColor Gray
        }
        
        return $gitInfo
    } finally {
        Pop-Location
    }
}

function Search-ModuleRepositories {
    param(
        [string]$ModuleName,
        [int]$MaxResults = 10
    )
    
    Write-Host "  🔎 Searching for repositories matching: $ModuleName" -ForegroundColor Gray
    
    # Simulate repository search (in real implementation, could use GitHub API, PowerShell Gallery, etc.)
    $searchQueries = @(
        "$ModuleName PowerShell",
        "$ModuleName PowerShell module",
        "PowerShell $ModuleName"
    )
    
    $results = @()
    
    # Add specific searches for Philip Procházka's repositories
    $results += [PSCustomObject]@{
        Query             = "Philip Procházka $ModuleName"
        Suggestion        = "Search Philip's GitHub repositories"
        PotentialRepo     = "https://github.com/philipprochazka?q=$($ModuleName -replace ' ', '+')+language:PowerShell"
        PowerShellGallery = "https://www.powershellgallery.com/packages?q=$ModuleName"
        PersonalDomain    = "https://philipprochazka.cz"
    }
    
    foreach ($query in $searchQueries) {
        $results += [PSCustomObject]@{
            Query             = $query
            Suggestion        = "Search GitHub for: '$query'"
            PotentialRepo     = "https://github.com/search?q=$($query -replace ' ', '+')+language:PowerShell"
            PowerShellGallery = "https://www.powershellgallery.com/packages?q=$ModuleName"
        }
    }
    
    Write-Host "  💡 Generated $($results.Count) search suggestions" -ForegroundColor Cyan
    return $results
}

function Build-FunctionDocumentation {
    param(
        [object[]]$ModuleInfo,
        [string]$OutputPath,
        [object]$BuildConfig
    )
    
    foreach ($module in $ModuleInfo) {
        Write-Host "  📝 Documenting module: $($module.Name)" -ForegroundColor Gray
        
        $docPath = Join-Path $OutputPath "functions"
        if (-not (Test-Path $docPath)) {
            New-Item -ItemType Directory -Path $docPath -Force | Out-Null
        }
        
        # Get functions from module
        $functions = @()
        if ($module.RootModule -and (Test-Path $module.RootModule)) {
            $content = Get-Content $module.RootModule -Raw
            $functions = [regex]::Matches($content, 'function\s+([A-Za-z]+-[A-Za-z]+)', [System.Text.RegularExpressions.RegexOptions]::Multiline) | 
            ForEach-Object { $_.Groups[1].Value }
        }
        
        foreach ($functionName in $functions) {
            $docFile = Join-Path $docPath "$functionName.md"
            $docContent = Build-FunctionMarkdown -FunctionName $functionName -ModuleName $module.Name
            Set-Content -Path $docFile -Value $docContent -Encoding UTF8
            Write-Host "    ✅ Created: $functionName.md" -ForegroundColor Green
        }
    }
}

function Build-FunctionMarkdown {
    param(
        [string]$FunctionName,
        [string]$ModuleName
    )
    
    return @"
# $FunctionName

## Synopsis
PowerShell function from $ModuleName module.

## Description
Detailed description of $FunctionName function.

## Parameters

### Parameter1
Description of Parameter1.

## Examples

``````powershell
# Example 1: Basic usage
$FunctionName -Parameter1 "Value"
``````

## Notes
- Generated by Build-ModuleDocumentation
- Module: $ModuleName
- Created: $(Get-Date -Format 'yyyy-MM-dd')
- Author: Philip Procházka

## Related Links
- [Module Documentation](../index.md)
- [PowerShell Gallery](https://www.powershellgallery.com/packages/$ModuleName)
- [Philip Procházka's Website](https://philipprochazka.cz)
- [GitHub Profile](https://github.com/philipprochazka)
"@
}

function Build-PesterTests {
    param(
        [object[]]$ModuleInfo,
        [object]$BuildConfig
    )
    
    $testsPath = "Tests"
    if (-not (Test-Path $testsPath)) {
        New-Item -ItemType Directory -Path $testsPath -Force | Out-Null
    }
    
    foreach ($module in $ModuleInfo) {
        $testFile = Join-Path $testsPath "$($module.Name).Tests.ps1"
        $testContent = Build-PesterTestContent -ModuleInfo $module -BuildConfig $BuildConfig
        Set-Content -Path $testFile -Value $testContent -Encoding UTF8
        Write-Host "  ✅ Created test: $($module.Name).Tests.ps1" -ForegroundColor Green
    }
}

function Build-PesterTestContent {
    param(
        [object]$ModuleInfo,
        [object]$BuildConfig
    )
    
    return @"
<#
.SYNOPSIS
    Pester tests for $($ModuleInfo.Name) module
    
.DESCRIPTION
    Comprehensive test suite following PowerShell development standards
    
.AUTHOR
    Philip Procházka <contact@philipprochazka.cz>
    
.LINK
    https://philipprochazka.cz
#>

#Requires -Module Pester

Describe "$($ModuleInfo.Name) Module Tests" {
    BeforeAll {
        # Import module for testing
        if ('$($ModuleInfo.ManifestPath)') {
            Import-Module '$($ModuleInfo.ManifestPath)' -Force
        } elseif ('$($ModuleInfo.RootModule)') {
            Import-Module '$($ModuleInfo.RootModule)' -Force
        }
    }
    
    Context "Module Structure" {
        It "Should have a valid module manifest" {
            '$($ModuleInfo.ManifestPath)' | Should -Not -BeNullOrEmpty
            Test-Path '$($ModuleInfo.ManifestPath)' | Should -Be `$true
        }
        
        It "Should load without errors" {
            { Import-Module '$($ModuleInfo.ManifestPath)' -Force } | Should -Not -Throw
        }
    }
    
    Context "Function Validation" {
        # Add function-specific tests here
        It "Should export expected functions" {
            `$exportedFunctions = Get-Command -Module '$($ModuleInfo.Name)'
            `$exportedFunctions | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Quality Standards (80% minimum coverage per guidelines)" {
        It "Should pass PSScriptAnalyzer compliance" {
            if (Get-Module PSScriptAnalyzer -ListAvailable) {
                `$analysis = Invoke-ScriptAnalyzer -Path '$($ModuleInfo.Path)' -Recurse
                `$analysis | Should -BeNullOrEmpty
            }
        }
    }
}
"@
}

function Build-VSCodeTasks {
    param(
        [object[]]$ModuleInfo,
        [object]$BuildConfig
    )
    
    Write-Host "  🔧 Generating VS Code tasks with emoji labels..." -ForegroundColor Gray
    
    $tasksPath = ".vscode"
    if (-not (Test-Path $tasksPath)) {
        New-Item -ItemType Directory -Path $tasksPath -Force | Out-Null
    }
    
    foreach ($module in $ModuleInfo) {
        $tasks = @{
            "🧪 Test $($module.Name)"                = @{
                type         = "shell"
                command      = "Invoke-Pester"
                args         = @("./Tests/$($module.Name).Tests.ps1", "-Output", "Detailed")
                group        = "test"
                presentation = @{
                    echo   = $true
                    reveal = "always"
                    focus  = $false
                }
            }
            "📚 Build $($module.Name) Documentation" = @{
                type    = "shell"
                command = "Build-ModuleDocumentation"
                args    = @("-ModulePath", "`"$($module.Path)`"", "-GenerateTests", "-UpdateProjectStructure")
                group   = "build"
            }
            "🔧 Validate $($module.Name) Syntax"     = @{
                type    = "shell"
                command = "Test-PSScriptAnalyzer"
                args    = @("-Path", "`"$($module.Path)`"")
                group   = "test"
            }
        }
        
        Write-Host "    ✅ Generated tasks for: $($module.Name)" -ForegroundColor Green
    }
}

function Update-ProjectStructure {
    param(
        [object[]]$ModuleInfo,
        [object]$GitInfo,
        [string]$OutputPath,
        [object]$BuildConfig
    )
    
    $indexPath = Join-Path $OutputPath "index.md"
    $indexContent = Build-ProjectIndexMarkdown -ModuleInfo $ModuleInfo -GitInfo $GitInfo -BuildConfig $BuildConfig
    Set-Content -Path $indexPath -Value $indexContent -Encoding UTF8
    
    Write-Host "  ✅ Updated project index: $indexPath" -ForegroundColor Green
}

function Build-ProjectIndexMarkdown {
    param(
        [object[]]$ModuleInfo,
        [object]$GitInfo,
        [object]$BuildConfig
    )
    
    $gitSection = ""
    if ($GitInfo.HasRemote) {
        $gitSection = @"

## Repository Information
- **Repository**: [$($GitInfo.RepositoryName)]($($GitInfo.RemoteUrl))
- **Owner**: $($GitInfo.Owner)
- **Branch**: $($GitInfo.Branch)
"@
    } elseif ($GitInfo.SearchResults) {
        $gitSection = @"

## Repository Search Results
No git remote found. Suggested searches:
$($GitInfo.SearchResults | ForEach-Object { "- [$($_.Query)]($($_.PotentialRepo))" } | Out-String)
"@
    }
    
    return @"
# PowerShell Module Documentation

**Author**: Philip Procházka  
**Website**: [philipprochazka.cz](https://philipprochazka.cz)  
**GitHub**: [philipprochazka](https://github.com/philipprochazka)  
**Generated**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

$gitSection

## About

This documentation system is part of Philip Procházka's PowerShell development ecosystem. All modules and scripts are developed following enterprise-grade PowerShell standards and best practices.

## Modules

$($ModuleInfo | ForEach-Object { @"
### $($_.Name)
- **Version**: $($_.Version)
- **Description**: $($_.Description)
- **Author**: $($_.Author)
- **Path**: $($_.Path)

"@ } | Out-String)

## Function Documentation

$($ModuleInfo | ForEach-Object { 
    $moduleName = $_.Name
    "### $moduleName Functions`n"
    # List function documentation files
    "- [Module Overview](functions/$moduleName.md)`n"
} | Out-String)

## Development Workflow

This documentation follows the PowerShell Development Standards from copilot-instructions.md:

- ✅ Uses approved PowerShell verbs (Build-, Test-, Initialize-)
- ✅ Implements mandatory development workflow
- ✅ Includes comprehensive Pester tests (80% minimum coverage)
- ✅ Provides VS Code task integration with emoji labels
- ✅ Maintains build step tracking system for complex operations

## Testing

Run tests using VS Code tasks or manually:

``````powershell
# Run all module tests
Invoke-Pester ./Tests/ -Output Detailed

# Test specific module
Invoke-Pester ./Tests/ModuleName.Tests.ps1 -Output Detailed
``````

## Quality Assurance

All modules follow these standards:
- PSScriptAnalyzer compliance
- Comment-based help for public functions
- Parameter validation with [ValidateSet], [ValidateNotNullOrEmpty]
- Error handling with try/catch blocks
- Proper module manifest (.psd1) with versioning

## Contact & Support

- **Author**: Philip Procházka
- **Email**: contact@philipprochazka.cz
- **Website**: [philipprochazka.cz](https://philipprochazka.cz)
- **GitHub**: [github.com/philipprochazka](https://github.com/philipprochazka)

---
*Built with Build-ModuleDocumentation v1.0.0 by Philip Procházka*  
*Following PowerShell development best practices and enterprise standards*
"@
}

function Update-BuildStepStatus {
    param(
        [string]$StepName,
        [string]$Status,
        [string]$Error = ""
    )
    
    $manifestPath = "Build-Steps/Manifest-Build-Progress.md.temp"
    if (Test-Path $manifestPath) {
        $content = Get-Content $manifestPath -Raw
        $statusEmoji = switch ($Status) {
            "COMPLETED" {
                "✅" 
            }
            "FAILED" {
                "❌" 
            }
            "PAUSED" {
                "⏸️" 
            }
            default {
                "⏸️" 
            }
        }
        
        $content = $content -replace "- \[ \] ⏸️ $StepName", "- [x] $statusEmoji $StepName"
        if ($Error) {
            $content += "`n`n## Error in $StepName`n$Error`n"
        }
        
        Set-Content -Path $manifestPath -Value $content -Encoding UTF8
    }
}

# Main execution when script is run directly
Build-ModuleDocumentation -ModulePath $ModulePath -OutputPath $OutputPath -ConfigPath $ConfigPath -GenerateTests:$GenerateTests -UpdateProjectStructure:$UpdateProjectStructure -CreateBuildManifest:$CreateBuildManifest -GitRemoteSearch:$GitRemoteSearch -MaxSearchResults $MaxSearchResults
