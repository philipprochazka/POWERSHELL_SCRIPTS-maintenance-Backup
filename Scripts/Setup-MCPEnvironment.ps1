<#
.SYNOPSIS
    Setup MCP (Model Context Protocol) Environment for PowerShell Workspace

.DESCRIPTION
    This script configures the PowerShell workspace for optimal integration with
    Model Context Protocol servers and GitHub Copilot, creating the necessary
    directory structure, configuration files, and helper scripts.

.EXAMPLE
    .\Setup-MCPEnvironment.ps1
    Sets up the complete MCP environment

.NOTES
    File Name      : Setup-MCPEnvironment.ps1
    Author         : GitHub Copilot Enhanced
    Prerequisite   : PowerShell 7.0
    Created        : 2025-07-26
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$WorkspaceRoot = $PWD.Path,
    
    [Parameter()]
    [switch]$Force
)

Write-Host "🚀 Setting up MCP Environment for PowerShell Workspace..." -ForegroundColor Cyan

#region Directory Structure Creation
$directories = @(
    '.mcp',
    '.mcp\tools',
    '.mcp\servers',
    '.mcp\config',
    'Scripts\MCP',
    'Modules\MCP',
    'Examples\MCP'
)

foreach ($dir in $directories) {
    $fullPath = Join-Path $WorkspaceRoot $dir
    if (-not (Test-Path $fullPath) -or $Force) {
        New-Item -Path $fullPath -ItemType Directory -Force | Out-Null
        Write-Host "✅ Created directory: $dir" -ForegroundColor Green
    }
    else {
        Write-Host "📁 Directory exists: $dir" -ForegroundColor Gray
    }
}
#endregion

#region MCP Configuration Files
# Main MCP configuration
$mcpConfig = @{
    version   = "1.0.0"
    workspace = @{
        name        = "PowerShell-MCP-Workspace"
        root        = $WorkspaceRoot
        description = "PowerShell development workspace with MCP integration"
    }
    servers   = @{
        filesystem  = @{
            command      = "powershell"
            args         = @("-ExecutionPolicy", "Bypass", "-File", "Scripts/MCP/filesystem-server.ps1")
            capabilities = @("file_operations", "directory_listing")
        }
        git         = @{
            command      = "powershell" 
            args         = @("-ExecutionPolicy", "Bypass", "-File", "Scripts/MCP/git-server.ps1")
            capabilities = @("git_operations", "version_control")
        }
        development = @{
            command      = "powershell"
            args         = @("-ExecutionPolicy", "Bypass", "-File", "Scripts/MCP/development-server.ps1")
            capabilities = @("code_analysis", "script_execution", "module_management")
        }
    }
    tools     = @{
        script_analyzer   = @{
            path        = "Scripts/MCP/Invoke-ScriptAnalysis.ps1"
            description = "PowerShell script analysis tool"
        }
        module_manager    = @{
            path        = "Scripts/MCP/Manage-Modules.ps1" 
            description = "PowerShell module management tool"
        }
        project_generator = @{
            path        = "Scripts/MCP/New-ProjectStructure.ps1"
            description = "Generate new PowerShell project structure"
        }
    }
} | ConvertTo-Json -Depth 4

$configPath = Join-Path $WorkspaceRoot '.mcp\mcp-config.json'
$mcpConfig | Out-File -FilePath $configPath -Encoding UTF8
Write-Host "✅ Created MCP configuration: .mcp\mcp-config.json" -ForegroundColor Green

# VS Code settings for MCP integration
$vscodeSettings = @{
    'powershell.enableProfileLoading'     = $true
    'powershell.powerShellDefaultVersion' = 'PowerShell'
    'github.copilot.enable'               = @{
        '*'          = $true
        'powershell' = $true
        'markdown'   = $true
        'json'       = $true
    }
    'mcp.enabled'                         = $true
    'mcp.configPath'                      = '.mcp/mcp-config.json'
    'mcp.autoStart'                       = $true
} | ConvertTo-Json -Depth 3

$vscodeDir = Join-Path $WorkspaceRoot '.vscode'
if (-not (Test-Path $vscodeDir)) {
    New-Item -Path $vscodeDir -ItemType Directory -Force | Out-Null
}

$settingsPath = Join-Path $vscodeDir 'mcp-settings.json'
$vscodeSettings | Out-File -FilePath $settingsPath -Encoding UTF8
Write-Host "✅ Created VS Code MCP settings: .vscode\mcp-settings.json" -ForegroundColor Green
#endregion

#region MCP Server Scripts
# Filesystem MCP Server
$filesystemServer = @'
# MCP Filesystem Server for PowerShell
param([string]$Command, [string]$Path, [string]$Content)

switch ($Command) {
    "list" {
        Get-ChildItem -Path $Path | ConvertTo-Json -Depth 2
    }
    "read" {
        Get-Content -Path $Path -Raw | ConvertTo-Json
    }
    "write" {
        $Content | Out-File -FilePath $Path -Encoding UTF8
        @{ status = "success"; message = "File written successfully" } | ConvertTo-Json
    }
    "delete" {
        Remove-Item -Path $Path -Force
        @{ status = "success"; message = "File deleted successfully" } | ConvertTo-Json
    }
    default {
        @{ status = "error"; message = "Unknown command: $Command" } | ConvertTo-Json
    }
}
'@

$filesystemServerPath = Join-Path $WorkspaceRoot 'Scripts\MCP\filesystem-server.ps1'
$filesystemServer | Out-File -FilePath $filesystemServerPath -Encoding UTF8
Write-Host "✅ Created filesystem MCP server: Scripts\MCP\filesystem-server.ps1" -ForegroundColor Green

# Git MCP Server
$gitServer = @'
# MCP Git Server for PowerShell
param([string]$Command, [string[]]$Args)

function Invoke-GitCommand {
    param([string]$GitCommand, [string[]]$Arguments)
    
    try {
        $result = & git $GitCommand @Arguments 2>&1
        @{
            status = "success"
            output = $result
        } | ConvertTo-Json -Depth 2
    }
    catch {
        @{
            status = "error" 
            message = $_.Exception.Message
        } | ConvertTo-Json
    }
}

switch ($Command) {
    "status" { Invoke-GitCommand "status" @("--porcelain") }
    "add" { Invoke-GitCommand "add" $Args }
    "commit" { Invoke-GitCommand "commit" $Args }
    "push" { Invoke-GitCommand "push" $Args }
    "pull" { Invoke-GitCommand "pull" $Args }
    "branch" { Invoke-GitCommand "branch" $Args }
    "log" { Invoke-GitCommand "log" @("--oneline", "-10") }
    default {
        @{ status = "error"; message = "Unknown git command: $Command" } | ConvertTo-Json
    }
}
'@

$gitServerPath = Join-Path $WorkspaceRoot 'Scripts\MCP\git-server.ps1'
$gitServer | Out-File -FilePath $gitServerPath -Encoding UTF8
Write-Host "✅ Created git MCP server: Scripts\MCP\git-server.ps1" -ForegroundColor Green

# Development MCP Server
$devServer = @'
# MCP Development Server for PowerShell
param([string]$Command, [string]$ScriptPath, [hashtable]$Parameters)

switch ($Command) {
    "analyze" {
        if (Get-Module PSScriptAnalyzer -ListAvailable) {
            $results = Invoke-ScriptAnalyzer -Path $ScriptPath -Settings PSGallery
            $results | ConvertTo-Json -Depth 3
        } else {
            @{ status = "error"; message = "PSScriptAnalyzer not available" } | ConvertTo-Json
        }
    }
    "execute" {
        try {
            $result = & $ScriptPath @Parameters
            @{ status = "success"; output = $result } | ConvertTo-Json -Depth 2
        }
        catch {
            @{ status = "error"; message = $_.Exception.Message } | ConvertTo-Json
        }
    }
    "test" {
        if (Get-Module Pester -ListAvailable) {
            $testResults = Invoke-Pester -Path $ScriptPath -PassThru
            $testResults | ConvertTo-Json -Depth 3
        } else {
            @{ status = "error"; message = "Pester not available" } | ConvertTo-Json
        }
    }
    default {
        @{ status = "error"; message = "Unknown development command: $Command" } | ConvertTo-Json
    }
}
'@

$devServerPath = Join-Path $WorkspaceRoot 'Scripts\MCP\development-server.ps1'
$devServer | Out-File -FilePath $devServerPath -Encoding UTF8
Write-Host "✅ Created development MCP server: Scripts\MCP\development-server.ps1" -ForegroundColor Green
#endregion

#region Helper Tools
# Script Analysis Tool
$scriptAnalyzer = @'
<#
.SYNOPSIS
    MCP Tool for PowerShell Script Analysis
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$FilePath,
    
    [Parameter()]
    [string[]]$Severity = @("Error", "Warning", "Information")
)

if (-not (Test-Path $FilePath)) {
    Write-Error "File not found: $FilePath"
    return
}

if (Get-Module PSScriptAnalyzer -ListAvailable) {
    Write-Host "🔍 Analyzing: $FilePath" -ForegroundColor Cyan
    
    $results = Invoke-ScriptAnalyzer -Path $FilePath -Severity $Severity
    
    if ($results) {
        $results | Group-Object Severity | ForEach-Object {
            $color = switch ($_.Name) {
                'Error' { 'Red' }
                'Warning' { 'Yellow' 
                'Information' { 'Cyan' }
                default { 'White' }
            }
            
            Write-Host "`n$($_.Name) Issues ($($_.Count)):" -ForegroundColor $color
            $_.Group | ForEach-Object {
                Write-Host "  Line $($_.Line): $($_.Message)" -ForegroundColor $color
                Write-Host "    Rule: $($_.RuleName)" -ForegroundColor Gray
            }
        }
        
        # Return structured data for MCP
        return @{
            file = $FilePath
            total_issues = $results.Count
            issues = $results | ForEach-Object {
                @{
                    line = $_.Line
                    column = $_.Column  
                    severity = $_.Severity
                    message = $_.Message
                    rule = $_.RuleName
                }
            }
        }
    } else {
        Write-Host "✅ No issues found!" -ForegroundColor Green
        return @{
            file = $FilePath
            total_issues = 0
            issues = @()
        }
    }
} else {
    Write-Error "PSScriptAnalyzer not available. Install with: Install-Module PSScriptAnalyzer"
}
'@

$analyzerPath = Join-Path $WorkspaceRoot 'Scripts\MCP\Invoke-ScriptAnalysis.ps1'
$scriptAnalyzer | Out-File -FilePath $analyzerPath -Encoding UTF8
Write-Host "✅ Created script analyzer tool: Scripts\MCP\Invoke-ScriptAnalysis.ps1" -ForegroundColor Green
#endregion

#region Documentation
$readmePath = Join-Path $WorkspaceRoot '.mcp\README.md'
$readmeContent = @'
# MCP PowerShell Workspace

This workspace is configured with Model Context Protocol (MCP) integration for enhanced AI-assisted PowerShell development.

## Features

- **Filesystem Server**: File operations through MCP
- **Git Server**: Version control operations
- **Development Server**: Code analysis and execution
- **Script Analysis**: PSScriptAnalyzer integration
- **GitHub Copilot**: Enhanced AI assistance

## MCP Servers

### Filesystem Server
Handles file and directory operations:
- List directory contents
- Read/write files
- Delete files

### Git Server  
Provides git operation capabilities:
- Status, add, commit, push, pull
- Branch management
- Commit history

### Development Server
Development workflow tools:
- Script analysis with PSScriptAnalyzer
- Script execution
- Pester test running

## Usage

The MCP environment is automatically initialized when loading the PowerShell profile. Use the provided functions:

```powershell
# Initialize MCP environment
Initialize-MCPEnvironment

# Show MCP status
Show-MCPStatus

# Create new PowerShell script with template
New-PowerShellScript -Name "MyScript" -Description "My new script"

# Analyze script syntax
Test-PowerShellSyntax -FilePath ".\MyScript.ps1"
```

## Configuration

MCP configuration is stored in `.mcp/mcp-config.json`. Modify this file to add new servers or tools.

## Requirements

- PowerShell 7.0+
- PSScriptAnalyzer (recommended)
- Pester (for testing)
- Git (for version control)
'@

$readmeContent | Out-File -FilePath $readmePath -Encoding UTF8
Write-Host "✅ Created MCP documentation: .mcp\README.md" -ForegroundColor Green
#endregion

Write-Host "`n🎯 MCP Environment Setup Complete!" -ForegroundColor Green
Write-Host "📍 Workspace Root: $WorkspaceRoot" -ForegroundColor Gray
Write-Host "📍 MCP Configuration: .mcp\mcp-config.json" -ForegroundColor Gray
Write-Host "📍 Documentation: .mcp\README.md" -ForegroundColor Gray

Write-Host "`n💡 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Reload your PowerShell profile: . `$PROFILE" -ForegroundColor Gray
Write-Host "   2. Run 'Show-MCPStatus' to verify setup" -ForegroundColor Gray
Write-Host "   3. Install recommended modules: Install-Module PSScriptAnalyzer, Pester" -ForegroundColor Gray
Write-Host "   4. Open VS Code and enable GitHub Copilot" -ForegroundColor Gray
