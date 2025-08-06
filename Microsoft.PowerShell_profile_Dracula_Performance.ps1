<#
.SYNOPSIS
    Dracula PowerShell Profile - Performance Optimized Version
.DESCRIPTION
    A performance-optimized version of the Dracula profile with minimal startup verbosity,
    lazy loading, and reduced reload frequency.
.VERSION
    2.0.0-Performance
.AUTHOR
    Philip Procházka
.COPYRIGHT
    (c) 2025 PhilipProcházka. All rights reserved.
#>

# ===================================================================
# 🧛‍♂️ DRACULA PERFORMANCE PROFILE 🧛‍♂️
# Ultra-fast startup with lazy loading
# ===================================================================

#region 🔧 Performance Configuration
# Global flag to prevent multiple reloads
if ($global:DraculaProfileLoaded) {
    return
}
$global:DraculaProfileLoaded = $true

# Load debug helper if available
$debugHelper = Join-Path $PSScriptRoot "DraculaDebugHelper.ps1"
if (Test-Path $debugHelper) {
    . $debugHelper
    
    # Enable debug mode if environment variable is set or if explicitly requested
    if ($env:DRACULA_DEBUG -eq 'true' -or $env:DRACULA_PERFORMANCE_DEBUG -eq 'true') {
        Enable-DraculaDebugMode
        Add-DraculaDebugStage -StageName 'ProfileStart' -Action 'Start'
    }
}

# Silence verbose output during profile load
$originalVerbose = $VerbosePreference
$VerbosePreference = 'SilentlyContinue'

# Performance tracking (optional)
$global:ProfileLoadStart = Get-Date
#endregion

#region 🎨 Essential Theme Setup (Minimal)
# Only load Oh My Posh if not already loaded
if (-not $env:POSH_THEME) {
    if ($global:DraculaDebugEnabled) {
        Invoke-DraculaDebugStep -StepName 'ThemeSetup' -ScriptBlock {
            $draculaTheme = Join-Path $PSScriptRoot "Theme\dracula-enhanced.omp.json"
            if (Test-Path $draculaTheme) {
                try {
                    oh-my-posh init pwsh --config $draculaTheme | Invoke-Expression
                } catch {
                    # Fallback to simple prompt if Oh My Posh fails
                    function prompt {
                        "🧛‍♂️ PS $($executionContext.SessionState.Path.CurrentLocation)> " 
                    }
                }
            } else {
                # Minimal Dracula prompt
                function prompt { 
                    Write-Host "🧛‍♂️ " -NoNewline -ForegroundColor Magenta
                    Write-Host "PS " -NoNewline -ForegroundColor Cyan
                    Write-Host $executionContext.SessionState.Path.CurrentLocation -NoNewline -ForegroundColor Yellow
                    Write-Host "> " -NoNewline -ForegroundColor Green
                    return " "
                }
            }
        }
    } else {
        $draculaTheme = Join-Path $PSScriptRoot "Theme\dracula-enhanced.omp.json"
        if (Test-Path $draculaTheme) {
            try {
                oh-my-posh init pwsh --config $draculaTheme | Invoke-Expression
            } catch {
                # Fallback to simple prompt if Oh My Posh fails
                function prompt {
                    "🧛‍♂️ PS $($executionContext.SessionState.Path.CurrentLocation)> " 
                }
            }
        } else {
            # Minimal Dracula prompt
            function prompt { 
                Write-Host "🧛‍♂️ " -NoNewline -ForegroundColor Magenta
                Write-Host "PS " -NoNewline -ForegroundColor Cyan
                Write-Host $executionContext.SessionState.Path.CurrentLocation -NoNewline -ForegroundColor Yellow
                Write-Host "> " -NoNewline -ForegroundColor Green
                return " "
            }
        }
    }
}
#endregion

#region 📦 Aggressive Lazy Module Loading
# Define ALL modules for lazy loading (including PSReadLine)
$global:DraculaLazyModules = @{
    'PSReadLine'          = { 
        Import-Module PSReadLine -ErrorAction SilentlyContinue
        if (Get-Module PSReadLine) {
            # Essential PSReadLine configuration
            Set-PSReadLineOption -EditMode Windows -BellStyle None
            Set-PSReadLineOption -PredictionSource History
            Set-PSReadLineOption -MaximumHistoryCount 4000
            
            # Essential Dracula colors (reduced set)
            Set-PSReadLineOption -Colors @{
                'Command'   = '#50fa7b'
                'Parameter' = '#ffb86c'
                'String'    = '#f1fa8c'
                'Variable'  = '#f8f8f2'
                'Comment'   = '#6272a4'
                'Keyword'   = '#ff79c6'
                'Error'     = '#ff5555'
            }
            
            # Essential key bindings only
            Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
            Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
            Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
        }
    }
    'Terminal-Icons'      = { Import-Module Terminal-Icons -ErrorAction SilentlyContinue }
    'z'                   = { Import-Module z -ErrorAction SilentlyContinue }
    'Az.Tools.Predictor'  = { Import-Module Az.Tools.Predictor -ErrorAction SilentlyContinue }
    'CompletionPredictor' = { Import-Module CompletionPredictor -ErrorAction SilentlyContinue }
    'Posh-Git'            = { Import-Module Posh-Git -ErrorAction SilentlyContinue }
}

# Auto-load triggers for common commands
$global:DraculaAutoLoadTriggers = @{
    'ls'            = 'Terminal-Icons'
    'dir'           = 'Terminal-Icons'
    'Get-ChildItem' = 'Terminal-Icons'
    'z'             = 'z'
    'Set-Location'  = 'z'
    'cd'            = 'z'
    'git'           = 'Posh-Git'
    'Get-AzContext' = 'Az.Tools.Predictor'
}

# Function to load modules on demand
function Initialize-DraculaModule {
    param([string]$ModuleName)
    
    if ($global:DraculaLazyModules.ContainsKey($ModuleName) -and 
        -not (Get-Module $ModuleName)) {
        
        if ($global:DraculaDebugEnabled) {
            Add-DraculaDebugModule -ModuleName $ModuleName -Action 'Start'
        }
        
        try {
            & $global:DraculaLazyModules[$ModuleName]
            $global:DraculaLazyModules.Remove($ModuleName)
            
            if ($global:DraculaDebugEnabled) {
                Add-DraculaDebugModule -ModuleName $ModuleName -Action 'End'
            }
        } catch {
            if ($global:DraculaDebugEnabled) {
                Add-DraculaDebugModule -ModuleName $ModuleName -Action 'End' -ErrorMessage $_.Exception.Message
            }
        }
    }
}

# Auto-load function that triggers on command execution
function Initialize-DraculaAutoLoad {
    param([string]$Command)
    
    if ($global:DraculaAutoLoadTriggers.ContainsKey($Command)) {
        $moduleName = $global:DraculaAutoLoadTriggers[$Command]
        Initialize-DraculaModule $moduleName
    }
}

# NO immediate module loading - everything is now lazy loaded!
# This provides the fastest possible startup time
#endregion

#region 🚀 Essential Aliases (Performance Focused)
# Core productivity aliases - these load instantly
Set-Alias -Name ll -Value Get-ChildItem -Force
Set-Alias -Name la -Value Get-ChildItem -Force
Set-Alias -Name l -Value Get-ChildItem -Force
Set-Alias -Name cls -Value Clear-Host -Force
Set-Alias -Name which -Value Get-Command -Force

# Enhanced aliases that trigger auto-loading
function ls {
    Initialize-DraculaAutoLoad 'ls'; Get-ChildItem @args 
}
function dir {
    Initialize-DraculaAutoLoad 'dir'; Get-ChildItem @args 
}
function z {
    Initialize-DraculaAutoLoad 'z'; if (Get-Module z) {
        z @args 
    } else {
        Set-Location @args 
    } 
}

# Git aliases (if git is available)
if (Get-Command git -ErrorAction SilentlyContinue) {
    Set-Alias -Name g -Value git -Force
    function gs {
        Initialize-DraculaAutoLoad 'git'; git status @args 
    }
    function ga {
        Initialize-DraculaAutoLoad 'git'; git add @args 
    }
    function gc {
        Initialize-DraculaAutoLoad 'git'; git commit @args 
    }
    function gp {
        Initialize-DraculaAutoLoad 'git'; git push @args 
    }
}
#endregion

#region 🔧 Essential Functions (Ultra-Lazy Loaded)
# Fast directory listing with auto-loading
function Get-DraculaListing {
    param([string]$Path = ".")
    
    # Auto-load Terminal-Icons on first use
    Initialize-DraculaModule 'Terminal-Icons'
    
    Get-ChildItem $Path | ForEach-Object {
        $color = if ($_.PSIsContainer) {
            'Cyan' 
        } else {
            'White' 
        }
        $icon = if ($_.PSIsContainer) {
            '📁' 
        } else {
            '📄' 
        }
        Write-Host "$icon " -NoNewline -ForegroundColor Yellow
        Write-Host $_.Name -ForegroundColor $color
    }
}

# Quick system info (no dependencies)
function Get-DraculaSystem {
    [CmdletBinding()]
    param()
    
    Write-Host "🧛‍♂️ " -NoNewline -ForegroundColor Magenta
    Write-Host "System: " -NoNewline -ForegroundColor Cyan
    Write-Host "$env:COMPUTERNAME" -NoNewline -ForegroundColor Yellow
    Write-Host " | " -NoNewline -ForegroundColor Gray
    Write-Host "User: " -NoNewline -ForegroundColor Cyan  
    Write-Host "$env:USERNAME" -NoNewline -ForegroundColor Yellow
    Write-Host " | " -NoNewline -ForegroundColor Gray
    Write-Host "PS: " -NoNewline -ForegroundColor Cyan
    Write-Host "$($PSVersionTable.PSVersion)" -ForegroundColor Yellow
}

# Load PSReadLine on demand
function Initialize-DraculaPSReadLine {
    Initialize-DraculaModule 'PSReadLine'
    Write-Host "✅ PSReadLine loaded with Dracula configuration" -ForegroundColor Green
}

# Load all extensions function (now truly lazy)
function Initialize-DraculaExtensions {
    [CmdletBinding()]
    param()
    
    Write-Host "🔄 Loading all Dracula extensions..." -ForegroundColor Yellow
    
    # Load all remaining lazy modules
    $moduleCount = 0
    foreach ($module in $global:DraculaLazyModules.Keys.Clone()) {
        Initialize-DraculaModule $module
        Write-Host "✓ " -NoNewline -ForegroundColor Green
        Write-Host $module -ForegroundColor Gray
        $moduleCount++
    }
    
    Write-Host "🧛‍♂️ Loaded $moduleCount extensions!" -ForegroundColor Magenta
}

# Enhanced help with lazy loading info
function Get-DraculaHelp {
    Write-Host ""
    Write-Host "🧛‍♂️ DRACULA ULTRA-PERFORMANCE PROFILE" -ForegroundColor Magenta
    Write-Host "====================================" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Essential Commands:" -ForegroundColor Cyan
    Write-Host "  ll, la, l       - Directory listing" -ForegroundColor Yellow
    Write-Host "  ls, dir         - Enhanced listing (auto-loads Terminal-Icons)" -ForegroundColor Yellow
    Write-Host "  sys             - System info" -ForegroundColor Yellow
    Write-Host "  load-ext        - Load all extensions" -ForegroundColor Yellow
    Write-Host "  load-psrl       - Load PSReadLine on demand" -ForegroundColor Yellow
    Write-Host "  help-dracula    - This help" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Auto-Loading Commands:" -ForegroundColor Cyan
    Write-Host "  z <path>        - Auto-loads z module" -ForegroundColor Yellow
    Write-Host "  gs, ga, gc, gp  - Auto-loads Posh-Git" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Lazy Modules Available:" -ForegroundColor Cyan
    foreach ($module in $global:DraculaLazyModules.Keys) {
        Write-Host "  📦 $module" -ForegroundColor Gray
    }
    Write-Host ""
    
    # Show debug commands if debug mode is available
    if (Get-Command dbg-summary -ErrorAction SilentlyContinue) {
        Write-Host "Debug & Performance:" -ForegroundColor Cyan
        Write-Host "  dbg-on          - Enable debug mode" -ForegroundColor Yellow
        Write-Host "  dbg-off         - Disable debug mode" -ForegroundColor Yellow
        Write-Host "  dbg-summary     - Show performance metrics" -ForegroundColor Yellow
        Write-Host "  dbg-reset       - Reset debug metrics" -ForegroundColor Yellow
        Write-Host "  dbg-export      - Export metrics to file" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Environment Variables:" -ForegroundColor Cyan
        Write-Host "  DRACULA_DEBUG=true           - Auto-enable debug mode" -ForegroundColor Yellow
        Write-Host "  DRACULA_PERFORMANCE_DEBUG=true - Enable performance debug" -ForegroundColor Yellow
        Write-Host "  DRACULA_SHOW_STARTUP=true   - Show startup message" -ForegroundColor Yellow
        Write-Host ""
    }
    
    Write-Host "💡 This profile uses aggressive lazy loading for maximum speed!" -ForegroundColor Green
    Write-Host "   Modules load automatically when you use related commands." -ForegroundColor Gray
    Write-Host ""
}
#endregion

#region 🎯 Performance Aliases
Set-Alias -Name sys -Value Get-DraculaSystem -Force
Set-Alias -Name load-ext -Value Initialize-DraculaExtensions -Force
Set-Alias -Name load-psrl -Value Initialize-DraculaPSReadLine -Force
Set-Alias -Name help-dracula -Value Get-DraculaHelp -Force
Set-Alias -Name lld -Value Get-DraculaListing -Force
#endregion

#region 🏁 Startup Completion
# Restore verbose preference
$VerbosePreference = $originalVerbose

# Finalize debug tracking
if ($global:DraculaDebugEnabled) {
    Add-DraculaDebugStage -StageName 'ProfileStart' -Action 'End'
    Set-DraculaPerformanceFlag -FlagName 'LazyModulesAvailable' -Value $global:DraculaLazyModules.Count
    Set-DraculaPerformanceFlag -FlagName 'UltraLazyLoading' -Value $true
    Set-DraculaPerformanceFlag -FlagName 'AutoLoadTriggers' -Value $global:DraculaAutoLoadTriggers.Count
    Set-DraculaPerformanceFlag -FlagName 'PSReadLineLoaded' -Value ($null -ne (Get-Module PSReadLine))
    Set-DraculaPerformanceFlag -FlagName 'ThemeLoaded' -Value ($null -ne $env:POSH_THEME)
}

# Optional startup message (minimal)
if ($env:DRACULA_SHOW_STARTUP -eq 'true') {
    $loadTime = ((Get-Date) - $global:ProfileLoadStart).TotalMilliseconds
    Write-Host "🧛‍♂️ " -NoNewline -ForegroundColor Magenta
    Write-Host "Dracula Ultra-Performance Profile loaded " -NoNewline -ForegroundColor Gray
    Write-Host "($([math]::Round($loadTime, 0))ms)" -ForegroundColor Green
    Write-Host "⚡ " -NoNewline -ForegroundColor Yellow
    Write-Host "All modules lazy-loaded for maximum speed!" -ForegroundColor Gray
    Write-Host "Type " -NoNewline -ForegroundColor Gray
    Write-Host "help-dracula" -NoNewline -ForegroundColor Cyan
    Write-Host " for commands" -ForegroundColor Gray
    
    # Show debug summary if enabled
    if ($global:DraculaDebugEnabled) {
        Write-Host "Debug mode: " -NoNewline -ForegroundColor Gray
        Write-Host "dbg-summary" -NoNewline -ForegroundColor Yellow
        Write-Host " for metrics" -ForegroundColor Gray
    }
}

# Clean up startup variables
Remove-Variable ProfileLoadStart -Scope Global -ErrorAction SilentlyContinue
#endregion

# ===================================================================
# 🧛‍♂️ Performance Profile Loaded - Type 'help-dracula' for help 🧛‍♂️
# ===================================================================
