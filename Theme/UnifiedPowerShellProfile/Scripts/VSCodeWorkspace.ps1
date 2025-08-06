<#
.SYNOPSIS
    Generate VS Code workspace with PowerShell quality tools integration
#>
function New-VSCodeWorkspace {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$WorkspaceRoot,
        
        [ValidateSet('Dracula', 'MCP', 'LazyAdmin', 'Minimal', 'Custom')]
        [string]$ProfileMode = 'Dracula'
    )
    
    Write-Host "💻 Creating VS Code workspace configuration..." -ForegroundColor Cyan
    
    # Create .vscode directory
    $vscodeDir = Join-Path $WorkspaceRoot '.vscode'
    if (-not (Test-Path $vscodeDir)) {
        New-Item -Path $vscodeDir -ItemType Directory -Force | Out-Null
    }
    
    # Create settings.json
    $settings = @{
        "powershell.codeFormatting.preset" = "OTBS"
        "powershell.codeFormatting.openBraceOnSameLine" = $true
        "powershell.codeFormatting.newLineAfterOpenBrace" = $true
        "powershell.codeFormatting.newLineAfterCloseBrace" = $true
        "powershell.codeFormatting.whitespaceBeforeOpenBrace" = $true
        "powershell.codeFormatting.whitespaceBeforeOpenParen" = $true
        "powershell.codeFormatting.whitespaceAroundOperator" = $true
        "powershell.codeFormatting.whitespaceAfterSeparator" = $true
        "powershell.codeFormatting.ignoreOneLineBlock" = $false
        "powershell.scriptAnalysis.enable" = $true
        "powershell.scriptAnalysis.settingsPath" = ".vscode/PSScriptAnalyzerSettings.psd1"
        "files.associations" = @{
            "*.ps1" = "powershell"
            "*.psm1" = "powershell"
            "*.psd1" = "powershell"
        }
        "editor.formatOnSave" = $true
        "editor.codeActionsOnSave" = @{
            "source.fixAll" = $true
        }
    }
    
    $settingsPath = Join-Path $vscodeDir 'settings.json'
    $settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath -Encoding UTF8
    
    # Create PSScriptAnalyzer settings
    $analyzerSettings = @"
@{
    # Use all rules
    IncludeRules = @('*')
    
    # Exclude rules that might be too strict
    ExcludeRules = @(
        'PSAvoidUsingWriteHost',  # Allow Write-Host for user interaction
        'PSUseShouldProcessForStateChangingFunctions'  # Not always needed
    )
    
    # Severity levels
    Rules = @{
        PSAvoidUsingCmdletAliases = @{
            Enable = $true
        }
        PSAvoidUsingPositionalParameters = @{
            Enable = $true
        }
        PSUseConsistentWhitespace = @{
            Enable = $true
            CheckInnerBrace = $true
            CheckOpenBrace = $true
            CheckOpenParen = $true
            CheckOperator = $true
            CheckPipe = $true
            CheckPipeForRedundantWhitespace = $false
            CheckSeparator = $true
            CheckParameter = $false
        }
        PSUseConsistentIndentation = @{
            Enable = $true
            Kind = 'space'
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            IndentationSize = 4
        }
        PSProvideCommentHelp = @{
            Enable = $true
            ExportedOnly = $false
            BlockComment = $true
            VSCodeSnippetCorrection = $true
            Placement = 'before'
        }
        PSUseApprovedVerbs = @{
            Enable = $true
        }
    }
}
"@
    
    $analyzerSettingsPath = Join-Path $vscodeDir 'PSScriptAnalyzerSettings.psd1'
    Set-Content -Path $analyzerSettingsPath -Value $analyzerSettings -Encoding UTF8
    
    # Create tasks.json
    $tasks = @{
        version = '2.0.0'
        tasks = @(
            @{
                label = "🔍 Run PSScriptAnalyzer"
                type = "shell"
                command = "pwsh"
                args = @(
                    "-Command",
                    "Invoke-ScriptAnalyzer -Path '`${workspaceFolder}' -Recurse -Severity Error,Warning,Information"
                )
                group = "test"
                presentation = @{
                    echo = $true
                    reveal = "always"
                    focus = $false
                    panel = "shared"
                    showReuseMessage = $true
                    clear = $false
                }
                problemMatcher = @(
                    @{
                        owner = "PSScriptAnalyzer"
                        fileLocation = @("relative", "`${workspaceFolder}")
                        pattern = @{
                            regexp = "^(.*)\\[(\\d+),(\\d+)\\]:\\s+(\\w+):\\s+(.*)$"
                            file = 1
                            line = 2
                            column = 3
                            severity = 4
                            message = 5
                        }
                    }
                )
            },
            @{
                label = "🧪 Run Pester Tests"
                type = "shell"
                command = "pwsh"
                args = @(
                    "-Command",
                    "Import-Module Pester -Force; Invoke-Pester -Path '`${workspaceFolder}' -Output Detailed"
                )
                group = "test"
                presentation = @{
                    echo = $true
                    reveal = "always"
                    focus = $false
                    panel = "shared"
                    showReuseMessage = $true
                    clear = $false
                }
            },
            @{
                label = "⚡ Initialize Profile ($ProfileMode)"
                type = "shell"
                command = "pwsh"
                args = @(
                    "-Command",
                    "Import-Module UnifiedPowerShellProfile -Force; Initialize-UnifiedProfile -Mode $ProfileMode -EnableRealtimeLinting"
                )
                group = "build"
                presentation = @{
                    echo = $true
                    reveal = "always"
                    focus = $false
                    panel = "shared"
                    showReuseMessage = $true
                    clear = $false
                }
            },
            @{
                label = "📊 Quality Check"
                type = "shell"
                command = "pwsh"
                args = @(
                    "-Command",
                    "Import-Module UnifiedPowerShellProfile -Force; Invoke-SmartLinting -Path '`${workspaceFolder}' -Detailed"
                )
                group = "test"
                presentation = @{
                    echo = $true
                    reveal = "always"
                    focus = $false
                    panel = "shared"
                    showReuseMessage = $true
                    clear = $false
                }
            }
        )
    }
    
    $tasksPath = Join-Path $vscodeDir 'tasks.json'
    $tasks | ConvertTo-Json -Depth 10 | Set-Content -Path $tasksPath -Encoding UTF8
    
    # Create launch.json for debugging
    $launch = @{
        version = '0.2.0'
        configurations = @(
            @{
                name = "🐛 Debug PowerShell Script"
                type = "PowerShell"
                request = "launch"
                script = "`${file}"
                cwd = "`${workspaceFolder}"
            },
            @{
                name = "🧪 Debug Pester Tests"
                type = "PowerShell"
                request = "launch"
                script = "Invoke-Pester"
                args = @("-Path", "`${file}", "-Output", "Detailed")
                cwd = "`${workspaceFolder}"
            }
        )
    }
    
    $launchPath = Join-Path $vscodeDir 'launch.json'
    $launch | ConvertTo-Json -Depth 10 | Set-Content -Path $launchPath -Encoding UTF8
    
    Write-Host "✅ VS Code workspace configured with:" -ForegroundColor Green
    Write-Host "   • PSScriptAnalyzer integration" -ForegroundColor White
    Write-Host "   • Pester test support" -ForegroundColor White
    Write-Host "   • Quality enforcement tasks" -ForegroundColor White
    Write-Host "   • Debug configurations" -ForegroundColor White
    Write-Host "   • Profile mode: $ProfileMode" -ForegroundColor White
}

Export-ModuleMember -Function New-VSCodeWorkspace
