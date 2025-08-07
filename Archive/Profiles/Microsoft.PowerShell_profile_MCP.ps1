# PowerShell 7 Profile - MCP & GitHub Copilot Optimized
# Location: Microsoft.PowerShell_profile.ps1
# Description: Enhanced PowerShell profile for development with MCP and AI assistance

# Load the Dracula Profile Module with MCP optimization
if (Get-Module DraculaProfile -ListAvailable) {
    Import-Module DraculaProfile
    Initialize-DraculaProfile
    
    # Ensure MCP environment is properly initialized
    Initialize-MCPEnvironment -Quiet
    
    Write-Host "🚀 PowerShell Profile with MCP & GitHub Copilot Integration loaded!" -ForegroundColor Cyan
    Show-MCPStatus
} else {
    # Fallback to manual setup
    Write-Host "🚀 Loading PowerShell Profile with MCP & GitHub Copilot Integration..." -ForegroundColor Cyan

    # Environment Variables for MCP
    $env:WORKSPACE_ROOT = $PWD.Path
    $env:COPILOT_ENABLED = $true
    $env:MCP_SERVER_PATH = "$env:WORKSPACE_ROOT\.mcp"

    #endregion

    #region Oh My Posh Theme
    try {
        if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
            oh-my-posh init pwsh --config "$env:WORKSPACE_ROOT\Theme\dracula.omp.json" | Invoke-Expression
            Write-Host "✅ Oh My Posh theme loaded" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Oh My Posh not found. Install with: winget install JanDeDobbeleer.OhMyPosh" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "⚠️  Could not load Oh My Posh theme: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    #endregion

    #region Module Imports
    $RequiredModules = @(
        'Az.Tools.Predictor',
        'Terminal-Icons',
        'z',
        'PSReadLine',
        'PSScriptAnalyzer'
    )

    foreach ($Module in $RequiredModules) {
        try {
            Import-Module $Module -ErrorAction Stop
            Write-Host "✅ $Module imported" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  $Module not available. Install with: Install-Module $Module" -ForegroundColor Yellow
        }
    }
    #endregion

    #region PSReadLine Configuration - Enhanced for AI Development
    if (Get-Module PSReadLine) {
        # Visual customization
        Set-PSReadLineOption -Colors @{
            Command            = 'Cyan'
            Number             = 'White'
            Member             = 'White'
            Operator           = 'Magenta'
            Type               = 'Blue'
            Variable           = 'Green'
            Parameter          = 'Green'
            ContinuationPrompt = 'DarkYellow'
            Default            = 'White'
            Emphasis           = 'Red'
            Error              = 'Red'
            Selection          = 'DarkGray'
            Comment            = 'DarkGreen'
            Keyword            = 'Blue'
            String             = 'Yellow'
            InlinePrediction   = 'DarkGray'
        }

        # Prediction settings optimized for development
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
        Set-PSReadLineOption -PredictionViewStyle ListView
        Set-PSReadLineOption -EditMode Windows
        Set-PSReadLineOption -ShowToolTips
        Set-PSReadLineOption -BellStyle None
    
        # Key handlers for enhanced productivity
        Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
        Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
        Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
        Set-PSReadLineKeyHandler -Key Alt+RightArrow -Function MoveToEndOfLine
        Set-PSReadLineKeyHandler -Key Alt+LeftArrow -Function MoveToStartOfLine
    
        # F7 for enhanced history
        Set-PSReadLineKeyHandler -Key F7 -BriefDescription 'Show command history' -LongDescription 'Show command history in grid view' -ScriptBlock {
            $pattern = $null
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$pattern, [ref]$null)
            if ($pattern) {
                $pattern = [regex]::Escape($pattern) 
            }

            $history = [System.Collections.ArrayList]@(
                $last = ''
                $lines = ''
                foreach ($line in [System.IO.File]::ReadLines((Get-PSReadLineOption).HistorySavePath)) {
                    if ($line.EndsWith('`')) {
                        $line = $line.Substring(0, $line.Length - 1)
                        $lines = if ($lines) {
                            "$lines`n$line" 
                        } else {
                            $line 
                        }
                        continue
                    }
                    if ($lines) {
                        $line = "$lines`n$line"
                        $lines = ''
                    }
                    if (($line -cne $last) -and (!$pattern -or ($line -match $pattern))) {
                        $last = $line
                        $line
                    }
                }
            )
            $history.Reverse()
        
            $command = $history | Out-GridView -Title "Command History (F7)" -PassThru
            if ($command) {
                [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($command -join "`n"))
            }
        }
    }
    #endregion

    #region Aliases - Developer Friendly
    Set-Alias -Name l -Value Get-ChildItem
    Set-Alias -Name ll -Value Get-ChildItem
    Set-Alias -Name la -Value Get-ChildItem
    Set-Alias -Name grep -Value Select-String
    Set-Alias -Name which -Value Get-Command
    Set-Alias -Name touch -Value New-Item
    Set-Alias -Name cat -Value Get-Content
    Set-Alias -Name curl -Value Invoke-WebRequest
    Set-Alias -Name wget -Value Invoke-WebRequest

    # Git aliases
    function gs {
        git status $args 
    }
    function ga {
        git add $args 
    }
    function gc {
        git commit $args 
    }
    function gp {
        git push $args 
    }
    function gl {
        git log --oneline $args 
    }
    function gd {
        git diff $args 
    }

    # Development aliases
    function code {
        & 'code.exe' $args 
    }
    function pwsh-admin {
        Start-Process pwsh -Verb RunAs 
    }
    function reload-profile {
        . $PROFILE 
    }
    #endregion

    #region MCP Integration Functions
    function Initialize-MCPEnvironment {
        <#
    .SYNOPSIS
    Initialize Model Context Protocol environment for this workspace
    #>
        [CmdletBinding()]
        param()
    
        try {
            $mcpPath = "$env:WORKSPACE_ROOT\.mcp"
            if (-not (Test-Path $mcpPath)) {
                New-Item -Path $mcpPath -ItemType Directory -Force | Out-Null
                Write-Host "✅ Created MCP directory: $mcpPath" -ForegroundColor Green
            }
        
            # Create MCP server configuration
            $mcpConfig = @{
                server_name    = "powershell-mcp-server"
                version        = "1.0.0"
                workspace_root = $env:WORKSPACE_ROOT
                capabilities   = @(
                    "file_operations",
                    "command_execution", 
                    "environment_management",
                    "git_integration"
                )
            } | ConvertTo-Json -Depth 3
        
            $configPath = "$mcpPath\server-config.json"
            $mcpConfig | Out-File -FilePath $configPath -Encoding UTF8
            Write-Host "✅ MCP server configuration created: $configPath" -ForegroundColor Green
        
            # Set environment variable for MCP tools
            $env:MCP_TOOLS_PATH = "$mcpPath\tools"
            if (-not (Test-Path $env:MCP_TOOLS_PATH)) {
                New-Item -Path $env:MCP_TOOLS_PATH -ItemType Directory -Force | Out-Null
            }
        
            Write-Host "🎯 MCP Environment initialized successfully!" -ForegroundColor Cyan
        } catch {
            Write-Error "Failed to initialize MCP environment: $($_.Exception.Message)"
        }
    }

    function Show-MCPStatus {
        <#
    .SYNOPSIS
    Display current MCP environment status
    #>
        Write-Host "`n🔍 MCP Environment Status:" -ForegroundColor Cyan
        Write-Host "Workspace Root: $env:WORKSPACE_ROOT" -ForegroundColor White
        Write-Host "MCP Path: $env:MCP_SERVER_PATH" -ForegroundColor White
        Write-Host "Copilot Enabled: $env:COPILOT_ENABLED" -ForegroundColor White
    
        if (Test-Path "$env:WORKSPACE_ROOT\.mcp") {
            Write-Host "✅ MCP Directory exists" -ForegroundColor Green
        } else {
            Write-Host "⚠️  MCP Directory not found" -ForegroundColor Yellow
        }
    }

    function New-PowerShellScript {
        <#
    .SYNOPSIS
    Create a new PowerShell script with template and best practices
    #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory)]
            [string]$Name,
        
            [Parameter()]
            [string]$Path = $PWD.Path,
        
            [Parameter()]
            [string]$Description = "PowerShell script created with MCP integration"
        )
    
        $fileName = if ($Name.EndsWith('.ps1')) {
            $Name 
        } else {
            "$Name.ps1" 
        }
        $fullPath = Join-Path $Path $fileName
    
        $template = @"
<#
.SYNOPSIS
    $Description

.DESCRIPTION
    Detailed description of what this script does.

.PARAMETER ParameterName
    Description of the parameter

.EXAMPLE
    .\$fileName
    Example of how to use this script

.NOTES
    File Name      : $fileName
    Author         : GitHub Copilot Enhanced
    Prerequisite   : PowerShell 7.0
    Created        : $(Get-Date -Format 'yyyy-MM-dd')
#>

[CmdletBinding()]
param(
    # Add parameters here
)

# Script implementation
Write-Host "Hello from $fileName!" -ForegroundColor Green

# Your code here
"@

        try {
            $template | Out-File -FilePath $fullPath -Encoding UTF8
            Write-Host "✅ Created PowerShell script: $fullPath" -ForegroundColor Green
        
            # Open in VS Code if available
            if (Get-Command code -ErrorAction SilentlyContinue) {
                code $fullPath
            }
        } catch {
            Write-Error "Failed to create script: $($_.Exception.Message)"
        }
    }
    #endregion

    #region Development Helper Functions
    function Show-GitStatus {
        <#
    .SYNOPSIS
    Enhanced git status with AI-friendly output
    #>
        if (Get-Command git -ErrorAction SilentlyContinue) {
            Write-Host "`n📊 Git Repository Status:" -ForegroundColor Cyan
            git status --short --branch
        
            $changes = git diff --name-only
            if ($changes) {
                Write-Host "`n📝 Modified Files:" -ForegroundColor Yellow
                $changes | ForEach-Object { Write-Host "  • $_" -ForegroundColor White }
            }
        } else {
            Write-Host "Git not available" -ForegroundColor Red
        }
    }

    function Get-ProjectStructure {
        <#
    .SYNOPSIS
    Display project structure in AI-friendly format
    #>
        param([string]$Path = $PWD.Path, [int]$Depth = 2)
    
        Write-Host "`n📁 Project Structure:" -ForegroundColor Cyan
        Get-ChildItem -Path $Path -Recurse -Depth $Depth | 
        Where-Object { $_.Name -notmatch '^\.|node_modules|\.git' } |
        Sort-Object FullName |
        ForEach-Object {
            $indent = "  " * (($_.FullName -split '\\').Count - ($Path -split '\\').Count)
            $icon = if ($_.PSIsContainer) {
                "📁" 
            } else {
                "📄" 
            }
            Write-Host "$indent$icon $($_.Name)" -ForegroundColor White
        }
    }

    function Test-PowerShellSyntax {
        <#
    .SYNOPSIS
    Test PowerShell script syntax with PSScriptAnalyzer
    #>
        [CmdletBinding()]
        param([Parameter(Mandatory)][string]$FilePath)
    
        if (Get-Module PSScriptAnalyzer -ListAvailable) {
            Write-Host "🔍 Analyzing PowerShell syntax..." -ForegroundColor Cyan
            $results = Invoke-ScriptAnalyzer -Path $FilePath -Settings PSGallery
        
            if ($results) {
                $results | Group-Object Severity | ForEach-Object {
                    $color = switch ($_.Name) {
                        'Error' {
                            'Red' 
                        }
                        'Warning' {
                            'Yellow' 
                        }
                        'Information' {
                            'Cyan' 
                        }
                        default {
                            'White' 
                        }
                    }
                    Write-Host "`n$($_.Name) Issues ($($_.Count)):" -ForegroundColor $color
                    $_.Group | ForEach-Object {
                        Write-Host "  Line $($_.Line): $($_.Message)" -ForegroundColor $color
                    }
                }
            } else {
                Write-Host "✅ No issues found!" -ForegroundColor Green
            }
        } else {
            Write-Host "Install PSScriptAnalyzer: Install-Module PSScriptAnalyzer" -ForegroundColor Yellow
        }
    }
    #endregion

    #region Startup Actions
    # Initialize MCP environment on startup
    Initialize-MCPEnvironment

    # Show welcome information
    Write-Host "`n🎯 PowerShell Profile Loaded Successfully!" -ForegroundColor Green
    Write-Host "   • Workspace: $env:WORKSPACE_ROOT" -ForegroundColor Gray
    Write-Host "   • MCP Integration: Enabled" -ForegroundColor Gray
    Write-Host "   • GitHub Copilot: Ready" -ForegroundColor Gray

    # Display available custom functions
    Write-Host "`n🛠️  Available MCP Functions:" -ForegroundColor Cyan
    Write-Host "   • Initialize-MCPEnvironment   - Setup MCP environment" -ForegroundColor Gray
    Write-Host "   • Show-MCPStatus             - Display MCP status" -ForegroundColor Gray
    Write-Host "   • New-PowerShellScript       - Create new PS1 script" -ForegroundColor Gray
    Write-Host "   • Show-GitStatus             - Enhanced git status" -ForegroundColor Gray
    Write-Host "   • Get-ProjectStructure       - Show project tree" -ForegroundColor Gray
    Write-Host "   • Test-PowerShellSyntax      - Analyze script syntax" -ForegroundColor Gray

    Write-Host "`n💡 Type 'Show-MCPStatus' to see current MCP configuration" -ForegroundColor Yellow
    Write-Host "💡 Use F7 for enhanced command history" -ForegroundColor Yellow
    #endregion
}
