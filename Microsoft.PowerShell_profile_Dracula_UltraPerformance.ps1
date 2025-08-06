<#
.SYNOPSIS
    Dracula PowerShell Profile - Ultra-Performance Version
.DESCRIPTION
    True ultra-performance profile with aggressive lazy loading, minimal initialization,
    and sub-50ms startup times. NO modules loaded at startup.
.VERSION
    3.0.0-UltraPerformance
.AUTHOR
    Philip Procházka
.COPYRIGHT
    (c) 2025 PhilipProcházka. All rights reserved.
#>

# ===================================================================
# 🧛‍♂️ DRACULA ULTRA-PERFORMANCE PROFILE 🧛‍♂️
# Target: Sub-50ms startup time with full lazy loading
# ===================================================================

#region ⚡ Ultra-Fast Initialization Guard
# Prevent multiple loads with minimal overhead
if ($global:DraculaUltraLoaded) {
    return 
}
$global:DraculaUltraLoaded = $true

# Minimal performance tracking (optional)
if ($env:DRACULA_PERFORMANCE_DEBUG -eq 'true') {
    $global:ProfileLoadStart = Get-Date
}
#endregion

#region 🎯 Minimal Prompt (No Oh My Posh at startup)
# Ultra-fast prompt that loads instantly
function prompt {
    Write-Host "🧛‍♂️" -NoNewline -ForegroundColor Magenta
    Write-Host " PS " -NoNewline -ForegroundColor Cyan
    Write-Host (Split-Path -Leaf $PWD) -NoNewline -ForegroundColor Yellow
    Write-Host " > " -NoNewline -ForegroundColor Green
    return " "
}
#endregion

#region 📦 True Lazy Loading System
# Module registry - NO modules loaded at startup
$global:DraculaModules = @{
    'PSReadLine'         = {
        if (-not (Get-Module PSReadLine)) {
            Import-Module PSReadLine -Force -ErrorAction SilentlyContinue
            if (Get-Module PSReadLine) {
                # Minimal PSReadLine config for speed
                Set-PSReadLineOption -EditMode Windows -BellStyle None
                Set-PSReadLineOption -PredictionSource History
                Set-PSReadLineOption -MaximumHistoryCount 2000
                
                # Essential Dracula colors only
                Set-PSReadLineOption -Colors @{
                    'Command' = '#50fa7b'; 'Parameter' = '#ffb86c'; 'String' = '#f1fa8c'
                    'Variable' = '#f8f8f2'; 'Comment' = '#6272a4'; 'Error' = '#ff5555'
                }
                
                # Essential key bindings
                Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
                Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
                Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
            }
        }
    }
    'Terminal-Icons'     = {
        if (-not (Get-Module Terminal-Icons)) {
            Import-Module Terminal-Icons -ErrorAction SilentlyContinue
        }
    }
    'z'                  = {
        if (-not (Get-Module z)) {
            Import-Module z -ErrorAction SilentlyContinue
        }
    }
    'OhMyPosh'           = {
        if (-not $env:POSH_THEME) {
            # Load Oh My Posh only when requested
            $modernInit = Join-Path $PSScriptRoot "PowerShellModules\UnifiedPowerShellProfile\Scripts\Initialize-ModernOhMyPosh.ps1"
            if (Test-Path $modernInit) {
                try {
                    . $modernInit
                    Initialize-ModernOhMyPosh -Mode "Performance"
                } catch {
                    # Fallback to theme file
                    $theme = Join-Path $PSScriptRoot "Theme\dracula-enhanced.omp.json"
                    if (Test-Path $theme -and (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
                        oh-my-posh init pwsh --config $theme | Invoke-Expression
                    }
                }
            }
        }
    }
    'Posh-Git'           = {
        if (-not (Get-Module Posh-Git)) {
            Import-Module Posh-Git -ErrorAction SilentlyContinue
        }
    }
    'Az.Tools.Predictor' = {
        if (-not (Get-Module Az.Tools.Predictor)) {
            Import-Module Az.Tools.Predictor -ErrorAction SilentlyContinue
        }
    }
}

# Command triggers for auto-loading
$global:DraculaTriggers = @{
    'ls' = 'Terminal-Icons'; 'dir' = 'Terminal-Icons'; 'Get-ChildItem' = 'Terminal-Icons'
    'z' = 'z'; 'cd' = 'z'; 'Set-Location' = 'z'
    'git' = 'Posh-Git'
    'Get-AzContext' = 'Az.Tools.Predictor'
}

# Ultra-fast module loader
function Load-DraculaModule {
    param([string]$ModuleName)
    
    if ($global:DraculaModules.ContainsKey($ModuleName)) {
        if ($env:DRACULA_PERFORMANCE_DEBUG -eq 'true') {
            $start = Get-Date
            Write-Host "⚡ Loading $ModuleName..." -ForegroundColor Yellow
        }
        
        try {
            & $global:DraculaModules[$ModuleName]
            $global:DraculaModules.Remove($ModuleName)
            
            if ($env:DRACULA_PERFORMANCE_DEBUG -eq 'true') {
                $elapsed = ((Get-Date) - $start).TotalMilliseconds
                Write-Host "✅ $ModuleName loaded in ${elapsed}ms" -ForegroundColor Green
            }
        } catch {
            if ($env:DRACULA_PERFORMANCE_DEBUG -eq 'true') {
                Write-Host "❌ $ModuleName failed: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}

# Auto-trigger function
function Trigger-DraculaAutoLoad {
    param([string]$Command)
    
    if ($global:DraculaTriggers.ContainsKey($Command)) {
        Load-DraculaModule $global:DraculaTriggers[$Command]
    }
}
#endregion

#region ⚡ Ultra-Fast Aliases & Functions
# Core aliases that load instantly (no dependencies)
Set-Alias ll Get-ChildItem -Force
Set-Alias la Get-ChildItem -Force
Set-Alias l Get-ChildItem -Force
Set-Alias cls Clear-Host -Force
Set-Alias which Get-Command -Force

# Smart aliases that trigger lazy loading
function ls {
    Trigger-DraculaAutoLoad 'ls'; Get-ChildItem @args 
}
function dir {
    Trigger-DraculaAutoLoad 'dir'; Get-ChildItem @args 
}
function z { 
    Trigger-DraculaAutoLoad 'z'
    if (Get-Module z) {
        z @args 
    } else {
        Set-Location @args 
    }
}

# Git aliases (only if git exists)
if (Get-Command git -ErrorAction SilentlyContinue) {
    Set-Alias g git -Force
    function gs {
        Trigger-DraculaAutoLoad 'git'; git status @args 
    }
    function ga {
        Trigger-DraculaAutoLoad 'git'; git add @args 
    }
    function gc {
        Trigger-DraculaAutoLoad 'git'; git commit @args 
    }
    function gp {
        Trigger-DraculaAutoLoad 'git'; git push @args 
    }
    function gl {
        Trigger-DraculaAutoLoad 'git'; git pull @args 
    }
}

# Manual loading functions for power users
function load-psrl {
    Load-DraculaModule 'PSReadLine' 
}
function load-icons {
    Load-DraculaModule 'Terminal-Icons' 
}
function load-z {
    Load-DraculaModule 'z' 
}
function load-omp {
    Load-DraculaModule 'OhMyPosh' 
}
function load-git {
    Load-DraculaModule 'Posh-Git' 
}
function load-az {
    Load-DraculaModule 'Az.Tools.Predictor' 
}

# Load all modules at once (for full experience)
function load-all {
    Write-Host "🚀 Loading all Dracula modules..." -ForegroundColor Cyan
    'PSReadLine', 'Terminal-Icons', 'z', 'OhMyPosh', 'Posh-Git' | ForEach-Object {
        Load-DraculaModule $_
    }
    Write-Host "✅ All modules loaded!" -ForegroundColor Green
}
#endregion

#region 🧛‍♂️ Ultra-Performance Utilities
# Debug summary function
function dbg-summary {
    if ($global:ProfileLoadStart) {
        $elapsed = ((Get-Date) - $global:ProfileLoadStart).TotalMilliseconds
        Write-Host "⚡ Profile loaded in: ${elapsed}ms" -ForegroundColor Green
    }
    
    Write-Host "📦 Loaded modules:" -ForegroundColor Cyan
    Get-Module | Select-Object Name, Version | Format-Table -AutoSize
    
    Write-Host "🧛‍♂️ Available lazy loaders:" -ForegroundColor Magenta
    $global:DraculaModules.Keys | ForEach-Object {
        Write-Host "  load-$($_.ToLower().Replace('.','').Replace('tools','').Replace('predictor',''))" -ForegroundColor Gray
    }
}

# Performance testing
function test-performance {
    param([int]$Iterations = 5)
    
    Write-Host "🔬 Testing profile performance..." -ForegroundColor Cyan
    $times = @()
    
    for ($i = 1; $i -le $Iterations; $i++) {
        $start = Get-Date
        pwsh -NoProfile -Command ". '$PSCommandPath'; exit"
        $elapsed = ((Get-Date) - $start).TotalMilliseconds
        $times += $elapsed
        Write-Host "Run $i`: ${elapsed}ms" -ForegroundColor Yellow
    }
    
    $avg = ($times | Measure-Object -Average).Average
    $min = ($times | Measure-Object -Minimum).Minimum
    $max = ($times | Measure-Object -Maximum).Maximum
    
    Write-Host "📊 Results:" -ForegroundColor Green
    Write-Host "  Average: ${avg}ms" -ForegroundColor White
    Write-Host "  Fastest: ${min}ms" -ForegroundColor Green
    Write-Host "  Slowest: ${max}ms" -ForegroundColor Red
    
    if ($avg -lt 50) {
        Write-Host "🏆 ULTRA-PERFORMANCE TARGET ACHIEVED!" -ForegroundColor Green
    } elseif ($avg -lt 100) {
        Write-Host "⚡ High performance" -ForegroundColor Yellow
    } else {
        Write-Host "⚠️ Needs optimization" -ForegroundColor Red
    }
}

# Module status check
function module-status {
    Write-Host "🧛‍♂️ Dracula Ultra-Performance Module Status" -ForegroundColor Magenta
    Write-Host "=================================" -ForegroundColor Gray
    
    foreach ($module in $global:DraculaModules.Keys) {
        $loaded = Get-Module $module -ErrorAction SilentlyContinue
        if ($loaded) {
            Write-Host "✅ $module (v$($loaded.Version))" -ForegroundColor Green
        } else {
            Write-Host "⏳ $module (lazy)" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "💡 Use 'load-all' to load everything at once" -ForegroundColor Cyan
    Write-Host "💡 Use 'dbg-summary' to see performance stats" -ForegroundColor Cyan
}
#endregion

#region 🎯 Essential PowerShell Settings (Minimal)
# Only the most essential settings for speed
$PSDefaultParameterValues = @{
    'Out-Default:OutVariable' = 'LastResult'
}

# Essential error handling
$ErrorActionPreference = 'Continue'
#endregion

# Performance debug output
if ($env:DRACULA_PERFORMANCE_DEBUG -eq 'true') {
    $loadTime = ((Get-Date) - $global:ProfileLoadStart).TotalMilliseconds
    Write-Host "⚡ Ultra-Performance profile loaded in ${loadTime}ms" -ForegroundColor Green
    Write-Host "🧛‍♂️ Type 'dbg-summary' for detailed stats" -ForegroundColor Magenta
    Write-Host "💡 Type 'load-all' to activate full Dracula experience" -ForegroundColor Cyan
}

# Welcome message (only if startup messages enabled)
if ($env:DRACULA_SHOW_STARTUP -eq 'true') {
    Write-Host "🧛‍♂️ Dracula Ultra-Performance Mode Active" -ForegroundColor Magenta
    Write-Host "⚡ All modules lazy-loaded for maximum speed" -ForegroundColor Green
}
