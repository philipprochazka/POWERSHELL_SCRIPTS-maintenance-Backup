# =============================================
# Setup-UnifiedProfile.ps1
# Configure Unified PowerShell Profile System
# =============================================

[CmdletBinding()]
param(
    [ValidateSet('Dracula', 'Minimal', 'Development', 'Production')]
    [string]$Mode = 'Dracula',
    
    [switch]$SetupVSCode,
    [switch]$InstallDependencies,
    [switch]$ConfigureSystemProfile,
    [switch]$CreateDocumentation,
    [switch]$GenerateTests,
    [switch]$WhatIf
)

#region Import Module Functions
$ModulePath = Split-Path $MyInvocation.MyCommand.Path -Parent
Import-Module (Join-Path $ModulePath "UnifiedPowerShellProfile.psd1") -Force
#endregion

function Initialize-ProfileStructure {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$ProjectRoot = $PWD.Path
    )
    
    Write-Host "🏗️  Initializing project structure..." -ForegroundColor Cyan
    
    # Define folder structure following PowerShell standards
    $folders = @(
        'docs',
        'docs\functions',
        'docs\guides', 
        'docs\examples',
        'Tests',
        'Tests\Unit',
        'Tests\Integration', 
        'Tests\Performance',
        'Tests\Reports',
        'Build-Steps',
        '.vscode',
        '.github',
        '.github\workflows',
        '.github\chatmodes'
    )
    
    foreach ($folder in $folders) {
        $folderPath = Join-Path $ProjectRoot $folder
        if (-not (Test-Path $folderPath)) {
            if ($PSCmdlet.ShouldProcess($folderPath, "Create directory")) {
                New-Item -Path $folderPath -ItemType Directory -Force | Out-Null
                Write-Host "   ✅ Created: $folder" -ForegroundColor Green
            }
        } else {
            Write-Host "   ℹ️  Exists: $folder" -ForegroundColor Blue
        }
    }
}

function Install-RequiredModules {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    Write-Host "📦 Installing required PowerShell modules..." -ForegroundColor Cyan
    
    $requiredModules = @(
        @{ Name = 'PSScriptAnalyzer'; MinVersion = '1.20.0' },
        @{ Name = 'Pester'; MinVersion = '5.0.0' },
        @{ Name = 'PSReadLine'; MinVersion = '2.2.0' },
        @{ Name = 'Terminal-Icons'; MinVersion = '0.10.0' },
        @{ Name = 'z'; MinVersion = '1.1.0' },
        @{ Name = 'CompletionPredictor'; MinVersion = '0.3.0' }
    )
    
    foreach ($module in $requiredModules) {
        try {
            $installed = Get-Module -ListAvailable -Name $module.Name | 
                         Where-Object { $_.Version -ge [Version]$module.MinVersion } |
                         Sort-Object Version -Descending |
                         Select-Object -First 1
            
            if (-not $installed) {
                if ($PSCmdlet.ShouldProcess($module.Name, "Install module")) {
                    Write-Host "   📥 Installing $($module.Name) (min v$($module.MinVersion))..." -ForegroundColor Yellow
                    Install-Module -Name $module.Name -MinimumVersion $module.MinVersion -Scope CurrentUser -Force -AllowClobber
                    Write-Host "   ✅ Installed $($module.Name)" -ForegroundColor Green
                }
            } else {
                Write-Host "   ✅ $($module.Name) v$($installed.Version) already installed" -ForegroundColor Green
            }
        } catch {
            Write-Warning "   ⚠️  Failed to install $($module.Name): $($_.Exception.Message)"
        }
    }
}

function Build-VSCodeConfiguration {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$ProjectRoot = $PWD.Path
    )
    
    Write-Host "🔧 Configuring VS Code workspace..." -ForegroundColor Cyan
    
    $vscodeDir = Join-Path $ProjectRoot ".vscode"
    
    # Create settings.json
    $settingsPath = Join-Path $vscodeDir "settings.json"
    $settings = @{
        "powershell.powerShellDefaultVersion" = "PowerShell 7+"
        "powershell.enableProfileLoading" = $true
        "powershell.scriptAnalysis.enable" = $true
        "powershell.scriptAnalysis.settingsPath" = "PSScriptAnalyzerSettings.psd1"
        "powershell.codeFormatting.preset" = "OTBS"
        "files.encoding" = "utf8bom"
        "files.eol" = "`r`n"
        "editor.insertSpaces" = $true
        "editor.tabSize" = 4
        "github.copilot.enable" = @{
            "powershell" = $true
            "markdown" = $true
            "json" = $true
        }
        "terminal.integrated.defaultProfile.windows" = "PowerShell 7+"
        "terminal.integrated.profiles.windows" = @{
            "PowerShell 7+" = @{
                "path" = "pwsh.exe"
                "args" = @("-NoLogo")
                "icon" = "terminal-powershell"
            }
        }
    }
    
    if ($PSCmdlet.ShouldProcess($settingsPath, "Create VS Code settings")) {
        $settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath -Encoding UTF8
        Write-Host "   ✅ Created VS Code settings.json" -ForegroundColor Green
    }
    
    # Create PSScriptAnalyzer settings
    $analyzerPath = Join-Path $ProjectRoot "PSScriptAnalyzerSettings.psd1"
    $analyzerSettings = @"
@{
    Rules = @{
        PSAvoidUsingCmdletAliases = @{
            Enable = `$true
            allowlist = @('cd', 'ls', 'dir', 'cls', 'cat', 'cp', 'mv', 'rm')
        }
        PSUseApprovedVerbs = @{
            Enable = `$true
        }
        PSUseSingularNouns = @{
            Enable = `$true
        }
        PSReviewUnusedParameter = @{
            Enable = `$true
        }
        PSUseCmdletCorrectly = @{
            Enable = `$true
        }
    }
    ExcludeRules = @()
    IncludeRules = @()
}
"@
    
    if ($PSCmdlet.ShouldProcess($analyzerPath, "Create PSScriptAnalyzer settings")) {
        $analyzerSettings | Set-Content -Path $analyzerPath -Encoding UTF8
        Write-Host "   ✅ Created PSScriptAnalyzer settings" -ForegroundColor Green
    }
}

function Build-Documentation {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$ProjectRoot = $PWD.Path
    )
    
    Write-Host "📚 Building documentation structure..." -ForegroundColor Cyan
    
    # Create main index.md
    $indexPath = Join-Path $ProjectRoot "docs\index.md"
    $indexContent = @"
# UnifiedPowerShellProfile Documentation

## Overview
The UnifiedPowerShellProfile is a comprehensive PowerShell development environment that provides:

- **Multi-mode profiles** (Dracula, Minimal, Development, Production)
- **Integrated tooling** with PSScriptAnalyzer, Pester, and VS Code
- **Performance optimization** with smart loading and caching
- **Cross-platform compatibility** for Windows, Linux, and macOS

## Quick Start

``````powershell
# Install the module
Install-Module UnifiedPowerShellProfile -Scope CurrentUser

# Setup with Dracula theme
.\Start-UnifiedProfile.ps1 -Quick

# Switch between modes
Switch-ProfileMode -Mode Development
``````

## Functions

$(if (Get-Module UnifiedPowerShellProfile -ListAvailable) {
    $functions = Get-Command -Module UnifiedPowerShellProfile -CommandType Function
    $functions | ForEach-Object { "- [$($_.Name)](functions/$($_.Name).md)" }
} else {
    "- Documentation will be generated after module installation"
})

## Guides

- [Installation Guide](guides/Installation.md)
- [Configuration Guide](guides/Configuration.md)
- [Development Workflow](guides/Development.md)
- [Performance Tuning](guides/Performance.md)

## Examples

- [Basic Usage](examples/Basic-Usage.md)
- [Advanced Configuration](examples/Advanced-Configuration.md)
- [Custom Themes](examples/Custom-Themes.md)

---

Generated on: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@
    
    if ($PSCmdlet.ShouldProcess($indexPath, "Create documentation index")) {
        $indexContent | Set-Content -Path $indexPath -Encoding UTF8
        Write-Host "   ✅ Created documentation index" -ForegroundColor Green
    }
}

function Build-PesterTests {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$ProjectRoot = $PWD.Path
    )
    
    Write-Host "🧪 Building Pester test structure..." -ForegroundColor Cyan
    
    # Create main test configuration
    $testConfigPath = Join-Path $ProjectRoot "Tests\PesterConfiguration.psd1"
    $testConfig = @"
@{
    Run = @{
        Path = @('Tests\Unit', 'Tests\Integration')
        PassThru = `$true
    }
    CodeCoverage = @{
        Enabled = `$true
        CoveragePercentTarget = 80
        OutputPath = 'Tests\Reports\CodeCoverage.xml'
        OutputFormat = 'JaCoCo'
    }
    TestResult = @{
        Enabled = `$true
        OutputPath = 'Tests\Reports\TestResults.xml'
        OutputFormat = 'NUnitXml'
    }
    Output = @{
        Verbosity = 'Detailed'
        StackTraceVerbosity = 'Filtered'
        CIFormat = 'Auto'
    }
}
"@
    
    if ($PSCmdlet.ShouldProcess($testConfigPath, "Create Pester configuration")) {
        $testConfig | Set-Content -Path $testConfigPath -Encoding UTF8
        Write-Host "   ✅ Created Pester configuration" -ForegroundColor Green
    }
    
    # Create sample unit test
    $unitTestPath = Join-Path $ProjectRoot "Tests\Unit\UnifiedPowerShellProfile.Tests.ps1"
    $unitTestContent = @"
#Requires -Module Pester
#Requires -Module UnifiedPowerShellProfile

Describe "UnifiedPowerShellProfile Module Tests" {
    BeforeAll {
        Import-Module UnifiedPowerShellProfile -Force
    }
    
    Context "Module Import" {
        It "Should import successfully" {
            Get-Module UnifiedPowerShellProfile | Should -Not -BeNullOrEmpty
        }
        
        It "Should export expected functions" {
            `$functions = Get-Command -Module UnifiedPowerShellProfile -CommandType Function
            `$functions.Count | Should -BeGreaterThan 0
        }
    }
    
    Context "Profile Modes" {
        It "Should validate profile modes" {
            { Switch-ProfileMode -Mode 'Dracula' -WhatIf } | Should -Not -Throw
            { Switch-ProfileMode -Mode 'Minimal' -WhatIf } | Should -Not -Throw
        }
    }
    
    Context "Performance" {
        It "Should load within acceptable time" {
            `$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            Import-Module UnifiedPowerShellProfile -Force
            `$stopwatch.Stop()
            `$stopwatch.ElapsedMilliseconds | Should -BeLessThan 5000
        }
    }
}
"@
    
    if ($PSCmdlet.ShouldProcess($unitTestPath, "Create unit tests")) {
        $unitTestContent | Set-Content -Path $unitTestPath -Encoding UTF8
        Write-Host "   ✅ Created unit test template" -ForegroundColor Green
    }
}

function Set-ProfileMode {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [ValidateSet('Dracula', 'Minimal', 'Development', 'Production')]
        [string]$Mode
    )
    
    Write-Host "🎨 Configuring profile mode: $Mode" -ForegroundColor Cyan
    
    switch ($Mode) {
        'Dracula' {
            Write-Host "   🧛‍♂️ Setting up Dracula theme with full features" -ForegroundColor Magenta
            if ($PSCmdlet.ShouldProcess("Profile", "Configure Dracula mode")) {
                $env:UNIFIED_PROFILE_MODE = 'Dracula'
                $env:UNIFIED_PROFILE_THEME = 'Enhanced'
            }
        }
        'Minimal' {
            Write-Host "   ⚡ Setting up minimal profile for maximum performance" -ForegroundColor Yellow
            if ($PSCmdlet.ShouldProcess("Profile", "Configure Minimal mode")) {
                $env:UNIFIED_PROFILE_MODE = 'Minimal'
                $env:UNIFIED_PROFILE_THEME = 'Basic'
            }
        }
        'Development' {
            Write-Host "   🛠️  Setting up development mode with full tooling" -ForegroundColor Blue
            if ($PSCmdlet.ShouldProcess("Profile", "Configure Development mode")) {
                $env:UNIFIED_PROFILE_MODE = 'Development'
                $env:UNIFIED_PROFILE_THEME = 'Developer'
            }
        }
        'Production' {
            Write-Host "   🏭 Setting up production mode with security focus" -ForegroundColor Green
            if ($PSCmdlet.ShouldProcess("Profile", "Configure Production mode")) {
                $env:UNIFIED_PROFILE_MODE = 'Production'
                $env:UNIFIED_PROFILE_THEME = 'Secure'
            }
        }
    }
    
    Write-Host "   ✅ Profile mode configured" -ForegroundColor Green
}

# Main execution logic
if ($MyInvocation.InvocationName -ne '.') {
    Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║            🔧 UNIFIED POWERSHELL PROFILE SETUP 🔧           ║
║               Following PowerShell Best Practices           ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

    Write-Host ""
    Write-Host "⚡ Setup Mode: $Mode" -ForegroundColor Yellow
    Write-Host "📁 Working Directory: $PWD" -ForegroundColor Gray
    Write-Host ""

    try {
        # Step 1: Initialize project structure
        Initialize-ProfileStructure -WhatIf:$WhatIf
        Write-Host ""

        # Step 2: Install dependencies if requested
        if ($InstallDependencies) {
            Install-RequiredModules -WhatIf:$WhatIf
            Write-Host ""
        }

        # Step 3: Setup VS Code if requested
        if ($SetupVSCode) {
            Build-VSCodeConfiguration -WhatIf:$WhatIf
            Write-Host ""
        }

        # Step 4: Create documentation if requested
        if ($CreateDocumentation) {
            Build-Documentation -WhatIf:$WhatIf
            Write-Host ""
        }

        # Step 5: Generate tests if requested
        if ($GenerateTests) {
            Build-PesterTests -WhatIf:$WhatIf
            Write-Host ""
        }

        # Step 6: Configure profile mode
        Set-ProfileMode -Mode $Mode -WhatIf:$WhatIf
        Write-Host ""

        # Step 7: Configure system profile if requested
        if ($ConfigureSystemProfile) {
            Write-Host "🔧 Configuring system-wide profile..." -ForegroundColor Cyan
            if ($PSCmdlet.ShouldProcess("System Profile", "Configure")) {
                & (Join-Path $PSScriptRoot "Install-UnifiedProfile.ps1") -Scope AllUsers -WhatIf:$WhatIf
            }
            Write-Host ""
        }

        Write-Host "🎉 Setup completed successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📋 Next Steps:" -ForegroundColor Cyan
        Write-Host "   1. Restart PowerShell to load the new profile" -ForegroundColor White
        Write-Host "   2. Run 'Get-UnifiedProfileStatus' to verify setup" -ForegroundColor White
        Write-Host "   3. Use 'Switch-ProfileMode' to change modes" -ForegroundColor White
        Write-Host "   4. Open VS Code in this directory to use configured workspace" -ForegroundColor White

    } catch {
        Write-Error "Setup failed: $($_.Exception.Message)"
        throw
    }
}
