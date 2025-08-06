<#
.SCRIPTINFO
    Version: 1.0.0
.ANNOTATION
    Author :philip Procházka
    Company:PhilipProcházka
    Date   :2025-29-07
    .TITLE
    🧛‍♂️ MODULE ORCHASTRATED DRACULA POWERSHELL PROFILE 🧛‍♂️
.SYNOPSIS
    Dracula Enhanced PowerShell Profile
.DESCRIPTION
    This profile enhances the PowerShell experience with the Dracula theme, optimized for productivity and aesthetics.
    It includes custom aliases, functions, and a beautiful Oh My Posh theme.
.Copyright (c) 2025 PhilipProcházka. All rights reserved.
.LICENSE
    This code is licensed under the MIT License.
    You may obtain a copy of the License at https://opensource.org/license/mit/
.Repository
    https://github.com/PhilipProcházka/Powershell
#>

# ===================================================================
#
# The ultimate PowerShell experience for creatures of the night
# ===================================================================

# Load the Dracula Profile Module
if (Get-Module DraculaProfile -ListAvailable) {
    Import-Module DraculaProfile
    Initialize-DraculaProfile
} else {
    # Fallback to local module if available
    $localModule = Join-Path $PSScriptRoot "Modules\DraculaProfile\DraculaProfile.psm1"
    if (Test-Path $localModule) {
        Import-Module $localModule
        Initialize-DraculaProfile
    } else {
        Write-Host "🧛‍♂️ Dracula Profile Module not found!" -ForegroundColor Red
        Write-Host "Install with: .\Install-DraculaProfile.ps1" -ForegroundColor Yellow
    }    
    # Minimal fallback setup
    Write-Host "Loading minimal Dracula profile..." -ForegroundColor Cyan

    #region 🎨 Theme Initialization

    # Initialize Oh My Posh with enhanced Dracula theme
    $draculaTheme = Join-Path $PSScriptRoot "Theme\dracula-enhanced.omp.json"
    if (Test-Path $draculaTheme) {
        $initScript = [ScriptBlock]::Create((oh-my-posh init pwsh --config $draculaTheme))
        & $initScript
        Write-Host "✨ Enhanced Dracula Oh My Posh theme loaded" -ForegroundColor Green
    } else {
        # Fallback to original theme
        $originalTheme = Join-Path $PSScriptRoot "Theme\dracula.omp.json"
        if (Test-Path $originalTheme) {
            $initScript = [ScriptBlock]::Create((oh-my-posh init pwsh --config $originalTheme))
            & $initScript
            Write-Host "✨ Original Dracula Oh My Posh theme loaded" -ForegroundColor Yellow
        }
    }

    #endregion

    #region 📦 Module Imports

    # Essential modules
    $modules = @(
        'Az.Tools.Predictor',
        'Terminal-Icons',
        'z',
        'CompletionPredictor'
    )

    foreach ($module in $modules) {
        try {
            Import-Module $module -ErrorAction SilentlyContinue
            Write-Host "📦 Loaded $module" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  $module not available" -ForegroundColor Yellow
        }
    }

    # Import Dracula PowerPack
    $powerPackPath = Join-Path $PSScriptRoot "Theme\DraculaPowerPack.psm1"
    if (Test-Path $powerPackPath) {
        Import-Module $powerPackPath -Force
        Write-Host "🦇 Dracula PowerPack loaded" -ForegroundColor Magenta
    }

    #endregion

    #region 🎨 Load Enhanced PSReadLine Configuration

    $psReadLineConfig = Join-Path $PSScriptRoot "Theme\PSReadLine-Dracula-Enhanced.ps1"
    if (Test-Path $psReadLineConfig) {
        . $psReadLineConfig
    } else {
        # Fallback enhanced configuration for PowerShell 7
        if (Get-Module PSReadLine) {
            Set-PSReadLineOption -Colors @{
                'Command'                = '#50fa7b'
                'Parameter'              = '#ffb86c'
                'String'                 = '#f1fa8c'
                'Variable'               = '#f8f8f2'
                'Comment'                = '#6272a4'
                'Keyword'                = '#ff79c6'
                'Operator'               = '#ff79c6'
                'Type'                   = '#8be9fd'
                'Number'                 = '#bd93f9'
                'Member'                 = '#50fa7b'
                'Emphasis'               = '#f8f8f2'
                'Error'                  = '#ff5555'
                'Selection'              = '#44475a'
                'InlinePrediction'       = '#6272a4'
                'ListPrediction'         = '#bd93f9'
                'ListPredictionSelected' = '#282a36'
            }
        
            # Enhanced PowerShell 7 features
            Set-PSReadLineOption -PredictionSource HistoryAndPlugin
            Set-PSReadLineOption -PredictionViewStyle ListView
            Set-PSReadLineOption -EditMode Windows
            Set-PSReadLineOption -BellStyle None
            Set-PSReadLineOption -HistorySearchCursorMovesToEnd
            Set-PSReadLineOption -ShowToolTips
            Set-PSReadLineOption -MaximumHistoryCount 4000
        
            # Enhanced key bindings for PowerShell 7
            Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
            Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
            Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
            Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteChar
            Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardDeleteWord
        
            # Custom Dracula-specific key bindings
            Set-PSReadLineKeyHandler -Key F7 -ScriptBlock {
                Get-History | Out-GridView -Title "Command History" -PassThru | Invoke-Expression
            }
        
            Set-PSReadLineKeyHandler -Key F9 -ScriptBlock {
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert("Get-ComputerInfo | Select-Object -Property @{Name='🖥️ Computer';Expression={$_.CsName}}, @{Name='💻 OS';Expression={$_.WindowsProductName}}, @{Name='🔧 Version';Expression={$_.WindowsVersion}}, @{Name='💾 RAM';Expression={'{0:N2} GB' -f ($_.TotalPhysicalMemory/1GB)}}")
            }
        
            Set-PSReadLineKeyHandler -Key Alt+c -ScriptBlock {
                [Microsoft.PowerShell.PSConsoleReadLine]::Insert("Show-DraculaColors")
            }
        
            Set-PSReadLineKeyHandler -Key Ctrl+Shift+f -ScriptBlock {
                $search = [Microsoft.PowerShell.PSConsoleReadLine]::ReadLine("🔍 Search: ", "")
                if ($search) {
                    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("Get-ChildItem -Recurse | Select-String '$search'")
                }
            }
        
            Set-PSReadLineKeyHandler -Key Ctrl+Shift+n -ScriptBlock {
                $name = [Microsoft.PowerShell.PSConsoleReadLine]::ReadLine("📝 Script name: ", "")
                if ($name) {
                    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("New-DraculaScript -Name '$name'")
                }
            }
        
            Write-Host "🎨 Enhanced Dracula PSReadLine colors applied (PowerShell 7)" -ForegroundColor Cyan
        }
    }

    #endregion

    #region 🚀 Enhanced Aliases

    # Navigation shortcuts
    Set-Alias -Name ls -Value Get-ChildItem
    Set-Alias -Name l -Value Get-ChildItem
    Set-Alias -Name ll -Value Get-ChildItemDetailed
    Set-Alias -Name la -Value Get-ChildItemAll
    Set-Alias -Name tree -Value Show-DirectoryTree
    Set-Alias -Name which -Value Get-Command

    # Development shortcuts
    Set-Alias -Name g -Value git
    Set-Alias -Name d -Value docker
    Set-Alias -Name k -Value kubectl
    Set-Alias -Name tf -Value terraform

    # Dracula shortcuts
    Set-Alias -Name colors -Value Show-DraculaColors
    Set-Alias -Name quote -Value Invoke-DraculaQuote
    Set-Alias -Name demo -Value Start-DraculaDemo
    Set-Alias -Name sysinfo -Value Get-DraculaSystemInfo
    Set-Alias -Name cleanup -Value Invoke-DraculaCleanup
    Set-Alias -Name newscript -Value New-DraculaScript

    #endregion

    #region 🛠️ Enhanced Functions

    function Get-ChildItemDetailed {
        <#
    .SYNOPSIS
        Enhanced ls with detailed formatting
    #>
        param([string]$Path = ".")
        Get-ChildItem $Path | Format-Table -AutoSize Mode, LastWriteTime, Length, Name
    }

    function Get-ChildItemAll {
        <#
    .SYNOPSIS
        Shows all files including hidden ones
    #>
        param([string]$Path = ".")
        Get-ChildItem $Path -Force | Format-Table -AutoSize Mode, LastWriteTime, Length, Name
    }

    function Show-DirectoryTree {
        <#
    .SYNOPSIS
        Shows directory structure as a tree
    #>
        param(
            [string]$Path = ".",
            [int]$Depth = 3
        )
    
        function Show-Tree {
            param($Dir, $Prefix = "", $Level = 0)
        
            if ($Level -gt $Depth) {
                return 
            }
        
            $items = Get-ChildItem $Dir | Sort-Object { $_.PSIsContainer }, Name
            $count = $items.Count
        
            for ($i = 0; $i -lt $count; $i++) {
                $item = $items[$i]
                $isLast = ($i -eq ($count - 1))
            
                $symbol = if ($isLast) {
                    "└── " 
                } else {
                    "├── " 
                }
                $color = if ($item.PSIsContainer) {
                    "Cyan" 
                } else {
                    "White" 
                }
            
                Write-Host "$Prefix$symbol" -NoNewline -ForegroundColor Yellow
                Write-Host $item.Name -ForegroundColor $color
            
                if ($item.PSIsContainer -and $Level -lt $Depth) {
                    $newPrefix = $Prefix + $(if ($isLast) {
                            "    " 
                        } else {
                            "│   " 
                        })
                    Show-Tree $item.FullName $newPrefix ($Level + 1)
                }
            }
        }
    
        Write-Host "📁 Directory tree for: $Path" -ForegroundColor Magenta
        Show-Tree (Resolve-Path $Path)
    }

    function Open-FileInVSCode {
        <#
    .SYNOPSIS
        Opens file or directory in VS Code
    #>
        param([string]$Path = ".")
        if (Get-Command code -ErrorAction SilentlyContinue) {
            code $Path
        } else {
            Write-Host "VS Code not found in PATH" -ForegroundColor Red
        }
    }

    function Get-GitStatus {
        <#
    .SYNOPSIS
        Enhanced git status with colors
    #>
        if (Get-Command git -ErrorAction SilentlyContinue) {
            git status --porcelain | ForEach-Object {
                $status = $_.Substring(0, 2)
                $file = $_.Substring(3)
            
                $color = switch ($status) {
                    { $_ -like "*M*" } {
                        "Yellow" 
                    }
                    { $_ -like "*A*" } {
                        "Green" 
                    }
                    { $_ -like "*D*" } {
                        "Red" 
                    }
                    { $_ -like "*R*" } {
                        "Cyan" 
                    }
                    { $_ -like "*?*" } {
                        "Magenta" 
                    }
                    default {
                        "White" 
                    }
                }
            
                Write-Host "$status $file" -ForegroundColor $color
            }
        }
    }
    Set-Alias -Name gs -Value Get-GitStatus

    function Invoke-DraculaHelp {
        <#
    .SYNOPSIS
        Shows Dracula PowerShell help
    #>
        Write-Host ""
        Write-Host "🧛‍♂️ DRACULA POWERSHELL HELP 🧛‍♂️" -ForegroundColor Magenta
        Write-Host "==================================" -ForegroundColor Magenta
        Write-Host ""
        Write-Host "🎨 Theme Commands:" -ForegroundColor Cyan
        Write-Host "  colors          - Show Dracula color palette" -ForegroundColor Yellow
        Write-Host "  quote           - Random vampire quote" -ForegroundColor Yellow
        Write-Host "  demo            - PowerShell demo with Dracula styling" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "🔧 Utility Commands:" -ForegroundColor Green
        Write-Host "  sysinfo         - System information" -ForegroundColor Yellow
        Write-Host "  cleanup         - Clean temporary files" -ForegroundColor Yellow
        Write-Host "  newscript <name> - Create new script template" -ForegroundColor Yellow
        Write-Host "  tree [path]     - Show directory tree" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "📁 Navigation:" -ForegroundColor Magenta
        Write-Host "  ls, l, ll, la   - List files (various formats)" -ForegroundColor Yellow
        Write-Host "  edit [path]     - Open in VS Code" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "🔗 Git Shortcuts:" -ForegroundColor DarkYellow
        Write-Host "  g               - git command" -ForegroundColor Yellow
        Write-Host "  gs              - Enhanced git status" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "⌨️  PSReadLine Shortcuts:" -ForegroundColor Magenta
        Write-Host "  F7              - History browser" -ForegroundColor Yellow
        Write-Host "  F9              - System info command" -ForegroundColor Yellow
        Write-Host "  Alt+C           - Color test" -ForegroundColor Yellow
        Write-Host "  Ctrl+Shift+F    - Smart search" -ForegroundColor Yellow
        Write-Host "  Ctrl+Shift+N    - Script template" -ForegroundColor Yellow
        Write-Host ""
    }
    Set-Alias -Name help-dracula -Value Invoke-DraculaHelp

    #endregion

    #region 🎭 Startup Actions

    # Set window title
    if ($Host.UI.RawUI) {
        $Host.UI.RawUI.WindowTitle = "🧛‍♂️ Dracula PowerShell 🧛‍♂️"
    }

    # Show welcome message
    Write-Host ""
    Write-Host "🧛‍♂️ Welcome to Dracula PowerShell! 🧛‍♂️" -ForegroundColor Magenta
    Write-Host "Type 'help-dracula' for available commands" -ForegroundColor Cyan

    # Random startup quote
    if (Get-Random -Minimum 1 -Maximum 4 -eq 1) {
        Invoke-DraculaQuote
    }

    #endregion

    #region 🌙 Performance Tracking

    # Track profile loading time
    $profileEndTime = Get-Date
    if ($profileStartTime) {
        $loadTime = ($profileEndTime - $profileStartTime).TotalMilliseconds
        Write-Host "⚡ Profile loaded in $([math]::Round($loadTime, 2))ms" -ForegroundColor Green
    }

    #endregion

    Write-Host ""
    Write-Host "🦇 The night is young, let's code! 🦇" -ForegroundColor Magenta
    Write-Host ""
    Write-Host ""
