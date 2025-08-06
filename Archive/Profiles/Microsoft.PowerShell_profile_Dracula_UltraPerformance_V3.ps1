<#
.SYNOPSIS
    Dracula PowerShell Profile - Ultra-Performance V3
.DESCRIPTION
    Version 3 ultra-performance profile with advanced lazy loading optimization,
    memory pooling, and enhanced startup performance. Target: Sub-200ms startup.
.VERSION
    3.5.0-UltraPerformance-V3
.AUTHOR
    Philip Procházka
.COPYRIGHT
    (c) 2025 PhilipProcházka. All rights reserved.
#>

# ===================================================================
# 🧛‍♂️ DRACULA ULTRA-PERFORMANCE PROFILE V3 🧛‍♂️
# Target: Sub-200ms startup with memory optimization
# ===================================================================

#region ⚡ Ultra-Fast Initialization Guard V3
# Enhanced guard with memory optimization
if ($global:DraculaUltraV3Loaded) {
    return 
}

# Memory pool for frequent operations
$global:DraculaMemoryPool = @{
    StringBuffer = [System.Text.StringBuilder]::new(256)
    PathCache    = @{}
    ModuleCache  = @{}
}

$global:DraculaUltraV3Loaded = $true

# Optimized performance tracking
if ($env:DRACULA_PERFORMANCE_DEBUG -eq 'true') {
    $global:ProfileLoadStart = [System.Diagnostics.Stopwatch]::StartNew()
}
#endregion

#region 🎯 Memory-Optimized Prompt V3
# Ultra-fast prompt with string builder optimization
function prompt {
    $sb = $global:DraculaMemoryPool.StringBuffer
    $sb.Clear() | Out-Null
    $sb.Append("🧛‍♂️ PS ") | Out-Null
    
    # Cached path processing
    $currentPath = $PWD.Path
    if (-not $global:DraculaMemoryPool.PathCache.ContainsKey($currentPath)) {
        $global:DraculaMemoryPool.PathCache[$currentPath] = Split-Path -Leaf $currentPath
    }
    
    $sb.Append($global:DraculaMemoryPool.PathCache[$currentPath]) | Out-Null
    $sb.Append(" > ") | Out-Null
    
    Write-Host $sb.ToString() -NoNewline -ForegroundColor Green
    return " "
}
#endregion

#region 📦 Enhanced Lazy Loading System V3
# Advanced module registry with dependency tracking
$global:DraculaModulesV3 = @{
    'PSReadLine'     = @{
        Loader       = {
            if (-not $global:DraculaMemoryPool.ModuleCache['PSReadLine']) {
                $module = Import-Module PSReadLine -PassThru -Force -ErrorAction SilentlyContinue
                $global:DraculaMemoryPool.ModuleCache['PSReadLine'] = $module
                if ($module) {
                    Set-PSReadLineOption -EditMode Emacs -BellStyle None
                    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
                    Set-PSReadLineOption -PredictionSource History
                }
            }
            return $global:DraculaMemoryPool.ModuleCache['PSReadLine']
        }
        Dependencies = @()
        Priority     = 1
    }
    
    'Terminal-Icons' = @{
        Loader       = {
            if (-not $global:DraculaMemoryPool.ModuleCache['Terminal-Icons']) {
                $module = Import-Module Terminal-Icons -PassThru -Force -ErrorAction SilentlyContinue
                $global:DraculaMemoryPool.ModuleCache['Terminal-Icons'] = $module
            }
            return $global:DraculaMemoryPool.ModuleCache['Terminal-Icons']
        }
        Dependencies = @()
        Priority     = 2
    }
    
    'z'              = @{
        Loader       = {
            if (-not $global:DraculaMemoryPool.ModuleCache['z']) {
                $module = Import-Module z -PassThru -Force -ErrorAction SilentlyContinue
                $global:DraculaMemoryPool.ModuleCache['z'] = $module
            }
            return $global:DraculaMemoryPool.ModuleCache['z']
        }
        Dependencies = @()
        Priority     = 3
    }
}

# Optimized lazy loading functions
function Load-PSReadLine {
    & $global:DraculaModulesV3['PSReadLine'].Loader 
}
function Load-TerminalIcons {
    & $global:DraculaModulesV3['Terminal-Icons'].Loader 
}
function Load-ZModule {
    & $global:DraculaModulesV3['z'].Loader 
}

# Aliases for shorter names
Set-Alias -Name load-psrl -Value Load-PSReadLine
Set-Alias -Name load-icons -Value Load-TerminalIcons
Set-Alias -Name load-z -Value Load-ZModule
Set-Alias -Name load-essential -Value Invoke-EssentialModuleLoad
Set-Alias -Name load-all -Value Invoke-AllModuleLoad

# Bulk loader with priority system
function Invoke-EssentialModuleLoad {
    $global:DraculaModulesV3.GetEnumerator() | 
    Sort-Object { $_.Value.Priority } |
    ForEach-Object { 
        $moduleInfo = $_
        $loader = $moduleInfo.Value.Loader
        & $loader
    }
}

function Invoke-AllModuleLoad {
    $startTime = [System.Diagnostics.Stopwatch]::StartNew()
    
    # Sequential loading to avoid Using expression issues
    $global:DraculaModulesV3.Keys | ForEach-Object {
        $moduleKey = $_
        $loader = $global:DraculaModulesV3[$moduleKey].Loader
        & $loader
    }
    
    $elapsed = $startTime.Elapsed.TotalMilliseconds
    Write-Host "⚡ All modules loaded in ${elapsed}ms (V3)" -ForegroundColor Green
}
#endregion

#region 🛠️ Enhanced Utility Functions V3
# Memory-optimized utility functions
function Get-V3DebugSummary {
    if ($global:ProfileLoadStart) {
        $loadTime = if ($global:ProfileLoadStart -is [System.Diagnostics.Stopwatch]) {
            $global:ProfileLoadStart.Elapsed.TotalMilliseconds
        } else {
            ((Get-Date) - $global:ProfileLoadStart).TotalMilliseconds
        }
        Write-Host "📊 V3 Profile Load Time: ${loadTime}ms" -ForegroundColor Cyan
    }
    
    Write-Host "📦 Cached Modules: $($global:DraculaMemoryPool.ModuleCache.Count)" -ForegroundColor Yellow
    Write-Host "📁 Cached Paths: $($global:DraculaMemoryPool.PathCache.Count)" -ForegroundColor Yellow
    Write-Host "🧠 Memory Pool Status: Active" -ForegroundColor Green
}

function Get-V3ModuleStatus {
    Write-Host "📋 V3 Module Status:" -ForegroundColor Cyan
    $global:DraculaModulesV3.GetEnumerator() | ForEach-Object {
        $cached = $global:DraculaMemoryPool.ModuleCache.ContainsKey($_.Key)
        $loaded = Get-Module $_.Key -ErrorAction SilentlyContinue
        
        $status = if ($loaded) {
            "✅" 
        } elseif ($cached) {
            "💾" 
        } else {
            "⏳" 
        }
        Write-Host "  $status $($_.Key)" -ForegroundColor $(if ($loaded) {
                'Green'
            } elseif ($cached) {
                'Yellow'
            } else {
                'Gray'
            })
    }
}

# Aliases for backward compatibility
Set-Alias -Name dbg-summary -Value Get-V3DebugSummary
Set-Alias -Name module-status -Value Get-V3ModuleStatus

function Test-V3Performance {
    Write-Host "🔬 V3 Performance Test..." -ForegroundColor Cyan
    
    $times = @()
    for ($i = 1; $i -le 5; $i++) {
        $start = [System.Diagnostics.Stopwatch]::StartNew()
        pwsh -NoProfile -Command ". '$PSCommandPath'; exit"
        $elapsed = $start.Elapsed.TotalMilliseconds
        $times += $elapsed
        Write-Host "Run $i`: ${elapsed}ms" -ForegroundColor Yellow
    }
    
    $avg = ($times | Measure-Object -Average).Average
    $min = ($times | Measure-Object -Minimum).Minimum
    
    Write-Host "📊 V3 Results:" -ForegroundColor Green
    Write-Host "  Average: ${avg}ms" -ForegroundColor White
    Write-Host "  Fastest: ${min}ms" -ForegroundColor Green
    
    if ($avg -lt 40) {
        Write-Host "🏆 V3 TARGET ACHIEVED!" -ForegroundColor Green
    } elseif ($avg -lt 60) {
        Write-Host "⚡ Good V3 performance" -ForegroundColor Yellow
    } else {
        Write-Host "⚠️ V3 needs optimization" -ForegroundColor Red
    }
}

# Alias for backward compatibility
Set-Alias -Name test-performance -Value Test-V3Performance

function test-performance {
    Write-Host "🔬 V3 Performance Test..." -ForegroundColor Cyan
    
    $times = @()
    for ($i = 1; $i -le 5; $i++) {
        $start = [System.Diagnostics.Stopwatch]::StartNew()
        pwsh -NoProfile -Command ". '$PSCommandPath'; exit"
        $elapsed = $start.Elapsed.TotalMilliseconds
        $times += $elapsed
        Write-Host "Run $i`: ${elapsed}ms" -ForegroundColor Yellow
    }
    
    $avg = ($times | Measure-Object -Average).Average
    $min = ($times | Measure-Object -Minimum).Minimum
    
    Write-Host "📊 V3 Results:" -ForegroundColor Green
    Write-Host "  Average: ${avg}ms" -ForegroundColor White
    Write-Host "  Fastest: ${min}ms" -ForegroundColor Green
    
    if ($avg -lt 40) {
        Write-Host "🏆 V3 TARGET ACHIEVED!" -ForegroundColor Green
    } elseif ($avg -lt 60) {
        Write-Host "⚡ Good V3 performance" -ForegroundColor Yellow
    } else {
        Write-Host "⚠️ V3 needs optimization" -ForegroundColor Red
    }
}

# Memory cleanup function
function Clear-V3Cache {
    $global:DraculaMemoryPool.PathCache.Clear()
    $global:DraculaMemoryPool.ModuleCache.Clear()
    $global:DraculaMemoryPool.StringBuffer.Clear()
    Write-Host "🧹 V3 Memory cache cleared" -ForegroundColor Green
}

# Alias for backward compatibility
Set-Alias -Name clear-cache -Value Clear-V3Cache
#endregion

#region 🎨 Advanced Oh My Posh Integration V3
# Lazy Oh My Posh with memory optimization
function Initialize-V3OhMyPosh {
    if (-not $global:DraculaMemoryPool.ModuleCache['OhMyPosh']) {
        if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
            $themePath = if ($env:POSH_THEMES_PATH) {
                Join-Path $env:POSH_THEMES_PATH "dracula.omp.json"
            } else {
                $null
            }
            
            if ($themePath -and (Test-Path $themePath)) {
                oh-my-posh init pwsh --config $themePath | Invoke-Expression
                $global:DraculaMemoryPool.ModuleCache['OhMyPosh'] = $true
                Write-Host "🎨 V3 Oh My Posh Dracula theme loaded" -ForegroundColor Magenta
            } else {
                Write-Host "⚠️ V3 Dracula theme not found, using default" -ForegroundColor Yellow
                oh-my-posh init pwsh | Invoke-Expression
                $global:DraculaMemoryPool.ModuleCache['OhMyPosh'] = $true
            }
        } else {
            Write-Host "❌ V3 Oh My Posh not installed" -ForegroundColor Red
        }
    }
}

# Alias for backward compatibility
Set-Alias -Name load-omp -Value Initialize-V3OhMyPosh
#endregion

#region 🔧 Command Override Hooks V3
# Optimized command hooks with minimal overhead
$ExecutionContext.InvokeCommand.PreCommandLookupAction = {
    param($commandName, $commandLookupEventArgs)
    
    # Auto-load modules based on command patterns
    switch -Regex ($commandName) {
        '^(Get-|Set-|New-|Remove-).*Icon.*' {
            load-icons 
        }
        '^z$' {
            load-z 
        }
        '^(Get-|Set-)PSReadLine.*' {
            load-psrl 
        }
        '^oh-my-posh.*' {
            load-omp 
        }
    }
}
#endregion

#region 📊 V3 Performance Monitoring
# Enhanced performance monitoring
if ($env:DRACULA_SHOW_STARTUP -eq 'true') {
    Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
        if ($global:ProfileLoadStart) {
            $loadTime = if ($global:ProfileLoadStart -is [System.Diagnostics.Stopwatch]) {
                $global:ProfileLoadStart.Elapsed.TotalMilliseconds
            } else {
                ((Get-Date) - $global:ProfileLoadStart).TotalMilliseconds
            }
            Write-Host "⚡ V3 Profile loaded in ${loadTime}ms" -ForegroundColor Green
        }
    }
}
#endregion

# V3 Profile loaded notification (minimal)
if ($env:DRACULA_PERFORMANCE_DEBUG -eq 'true') {
    Write-Host "🧛‍♂️ Dracula V3 Ultra-Performance Profile Ready" -ForegroundColor Magenta
}
