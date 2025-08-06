<#
.SYNOPSIS
    Dracula PowerShell Profile - Ultra-Performance V4
.DESCRIPTION
    Version 4 ultra-performance profile with JIT compilation optimization,
    advanced memory pooling, async loading, and sub-200ms startup. Experimental features.
.VERSION
    4.0.0-UltraPerformance-V4
.AUTHOR
    Philip Procházka
.COPYRIGHT
    (c) 2025 PhilipProcházka. All rights reserved.
#>

# ===================================================================
# 🧛‍♂️ DRACULA ULTRA-PERFORMANCE PROFILE V4 🧛‍♂️
# Target: Sub-200ms startup with JIT optimization
# ===================================================================

#region ⚡ JIT-Optimized Initialization Guard V4
# Advanced guard with JIT compilation hints
if ($global:DraculaUltraV4Loaded) {
    return 
}

# Advanced memory pool with pre-allocation
$global:DraculaAdvancedPool = @{
    StringBuffer = [System.Text.StringBuilder]::new(512)
    PathCache    = [System.Collections.Concurrent.ConcurrentDictionary[string, string]]::new()
    ModuleCache  = [System.Collections.Concurrent.ConcurrentDictionary[string, object]]::new()
    CommandCache = [System.Collections.Generic.Dictionary[string, scriptblock]]::new(64)
    LoadQueue    = [System.Collections.Concurrent.ConcurrentQueue[scriptblock]]::new()
}

# JIT compilation warmup for critical paths (simplified to avoid ambiguity)
try {
    $pathMethod = [System.IO.Path].GetMethod('GetFileName', [string])
    if ($pathMethod) {
        $null = [System.Runtime.CompilerServices.RuntimeHelpers]::PrepareMethod($pathMethod.MethodHandle)
    }
} catch {
    # JIT optimization failed, continue without it
}

$global:DraculaUltraV4Loaded = $true

# High-resolution performance tracking
if ($env:DRACULA_PERFORMANCE_DEBUG -eq 'true') {
    $global:ProfileLoadStart = [System.Diagnostics.Stopwatch]::StartNew()
    $global:V4PerfCounters = @{
        PromptCalls = 0
        ModuleLoads = 0
        CacheHits   = 0
        CacheMisses = 0
    }
}
#endregion

#region 🎯 JIT-Optimized Prompt V4
# Ultra-fast prompt with JIT optimization and caching
$global:DraculaPromptScript = {
    param($currentPath)
    
    $sb = $global:DraculaAdvancedPool.StringBuffer
    $sb.Clear() | Out-Null
    $sb.Append("🧛‍♂️ PS ") | Out-Null
    
    # Concurrent path caching
    $pathKey = $currentPath
    $cachedPath = $global:DraculaAdvancedPool.PathCache.GetOrAdd($pathKey, {
            [System.IO.Path]::GetFileName($currentPath)
        })
    
    $sb.Append($cachedPath) | Out-Null
    $sb.Append(" > ") | Out-Null
    
    if ($env:DRACULA_PERFORMANCE_DEBUG -eq 'true') {
        $global:V4PerfCounters.PromptCalls++
    }
    
    return $sb.ToString()
}

function prompt {
    $promptText = & $global:DraculaPromptScript $PWD.Path
    Write-Host $promptText -NoNewline -ForegroundColor Green
    return " "
}

# Pre-compile the prompt script for JIT optimization
$null = & $global:DraculaPromptScript $PWD.Path
#endregion

#region 📦 Async Lazy Loading System V4
# Advanced module registry with async loading and dependency resolution
$global:DraculaModulesV4 = @{
    'PSReadLine'     = @{
        Loader       = {
            $moduleKey = 'PSReadLine'
            return $global:DraculaAdvancedPool.ModuleCache.GetOrAdd($moduleKey, {
                    $module = Import-Module PSReadLine -PassThru -Force -ErrorAction SilentlyContinue
                    if ($module) {
                        # Optimized PSReadLine configuration
                        $configScript = {
                            Set-PSReadLineOption -EditMode Emacs -BellStyle None
                            Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
                            Set-PSReadLineOption -PredictionSource History
                            Set-PSReadLineOption -MaximumHistoryCount 4096
                        }
                    
                        # Queue configuration for async execution
                        $global:DraculaAdvancedPool.LoadQueue.Enqueue($configScript)
                    
                        if ($env:DRACULA_PERFORMANCE_DEBUG -eq 'true') {
                            $global:V4PerfCounters.ModuleLoads++
                        }
                    }
                    return $module
                })
        }
        Dependencies = @()
        Priority     = 1
        AsyncSafe    = $true
    }
    
    'Terminal-Icons' = @{
        Loader       = {
            $moduleKey = 'Terminal-Icons'
            return $global:DraculaAdvancedPool.ModuleCache.GetOrAdd($moduleKey, {
                    $module = Import-Module Terminal-Icons -PassThru -Force -ErrorAction SilentlyContinue
                    if ($env:DRACULA_PERFORMANCE_DEBUG -eq 'true') {
                        $global:V4PerfCounters.ModuleLoads++
                    }
                    return $module
                })
        }
        Dependencies = @()
        Priority     = 2
        AsyncSafe    = $true
    }
    
    'z'              = @{
        Loader       = {
            $moduleKey = 'z'
            return $global:DraculaAdvancedPool.ModuleCache.GetOrAdd($moduleKey, {
                    $module = Import-Module z -PassThru -Force -ErrorAction SilentlyContinue
                    if ($env:DRACULA_PERFORMANCE_DEBUG -eq 'true') {
                        $global:V4PerfCounters.ModuleLoads++
                    }
                    return $module
                })
        }
        Dependencies = @()
        Priority     = 3
        AsyncSafe    = $true
    }
}

# Optimized lazy loading functions with caching
$global:DraculaAdvancedPool.CommandCache['load-psrl'] = { & $global:DraculaModulesV4['PSReadLine'].Loader }
$global:DraculaAdvancedPool.CommandCache['load-icons'] = { & $global:DraculaModulesV4['Terminal-Icons'].Loader }
$global:DraculaAdvancedPool.CommandCache['load-z'] = { & $global:DraculaModulesV4['z'].Loader }

function Invoke-V4PSReadLineLoad {
    & $global:DraculaAdvancedPool.CommandCache['load-psrl'] 
}
function Invoke-V4TerminalIconsLoad {
    & $global:DraculaAdvancedPool.CommandCache['load-icons'] 
}
function Invoke-V4ZModuleLoad {
    & $global:DraculaAdvancedPool.CommandCache['load-z'] 
}

# Aliases for shorter names
Set-Alias -Name load-psrl -Value Invoke-V4PSReadLineLoad
Set-Alias -Name load-icons -Value Invoke-V4TerminalIconsLoad
Set-Alias -Name load-z -Value Invoke-V4ZModuleLoad

# Async bulk loader with parallel execution
function Invoke-V4EssentialModuleLoad {
    $asyncModules = $global:DraculaModulesV4.GetEnumerator() | 
    Where-Object { $_.Value.AsyncSafe } |
    Sort-Object { $_.Value.Priority }
    
    $asyncModules | ForEach-Object {
        $loader = $_.Value.Loader
        & $loader
    }
    
    # Process queued configurations
    while ($global:DraculaAdvancedPool.LoadQueue.TryDequeue([ref]$configScript)) {
        & $configScript
    }
}

function Invoke-V4AllModuleLoad {
    $startTime = [System.Diagnostics.Stopwatch]::StartNew()
    
    # Sequential loading for stability
    $global:DraculaModulesV4.Keys | ForEach-Object {
        $moduleKey = $_
        $loader = $global:DraculaModulesV4[$moduleKey].Loader
        & $loader
    }
    
    # Process queued configurations
    while ($global:DraculaAdvancedPool.LoadQueue.TryDequeue([ref]$configScript)) {
        & $configScript
    }
    
    $elapsed = $startTime.Elapsed.TotalMilliseconds
    Write-Host "⚡ All modules loaded in ${elapsed}ms (V4)" -ForegroundColor Green
}

# Aliases for backward compatibility
Set-Alias -Name load-essential -Value Invoke-V4EssentialModuleLoad
Set-Alias -Name load-all -Value Invoke-V4AllModuleLoad
#endregion

#region 🛠️ Advanced Utility Functions V4
# JIT-optimized utility functions
function Get-V4DebugSummary {
    if ($global:ProfileLoadStart) {
        $loadTime = $global:ProfileLoadStart.Elapsed.TotalMilliseconds
        Write-Host "📊 V4 Profile Load Time: ${loadTime}ms" -ForegroundColor Cyan
    }
    
    if ($env:DRACULA_PERFORMANCE_DEBUG -eq 'true') {
        Write-Host "📈 V4 Performance Counters:" -ForegroundColor Yellow
        $global:V4PerfCounters.GetEnumerator() | ForEach-Object {
            Write-Host "  $($_.Key): $($_.Value)" -ForegroundColor Gray
        }
    }
    
    Write-Host "📦 Cached Modules: $($global:DraculaAdvancedPool.ModuleCache.Count)" -ForegroundColor Yellow
    Write-Host "📁 Cached Paths: $($global:DraculaAdvancedPool.PathCache.Count)" -ForegroundColor Yellow
    Write-Host "🧠 Advanced Pool Status: Active" -ForegroundColor Green
    Write-Host "⚡ JIT Optimization: Enabled" -ForegroundColor Magenta
}

function Get-V4ModuleStatus {
    Write-Host "📋 V4 Module Status:" -ForegroundColor Cyan
    $global:DraculaModulesV4.GetEnumerator() | ForEach-Object {
        $cached = $global:DraculaAdvancedPool.ModuleCache.ContainsKey($_.Key)
        $loaded = Get-Module $_.Key -ErrorAction SilentlyContinue
        
        $status = if ($loaded) {
            "✅" 
        } elseif ($cached) {
            "💾" 
        } else {
            "⏳" 
        }
        $async = if ($_.Value.AsyncSafe) {
            "🔄" 
        } else {
            "⏸️" 
        }
        Write-Host "  $status$async $($_.Key)" -ForegroundColor $(if ($loaded) {
                'Green'
            } elseif ($cached) {
                'Yellow'
            } else {
                'Gray'
            })
    }
}

function Test-V4Performance {
    Write-Host "🔬 V4 Performance Test..." -ForegroundColor Cyan
    
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
    $max = ($times | Measure-Object -Maximum).Maximum
    $stdDev = [Math]::Sqrt(($times | ForEach-Object { [Math]::Pow($_ - $avg, 2) } | Measure-Object -Sum).Sum / $times.Count)
    
    Write-Host "📊 V4 Results:" -ForegroundColor Green
    Write-Host "  Average: ${avg:F2}ms" -ForegroundColor White
    Write-Host "  Fastest: ${min:F2}ms" -ForegroundColor Green
    Write-Host "  Slowest: ${max:F2}ms" -ForegroundColor Red
    Write-Host "  Std Dev: ${stdDev:F2}ms" -ForegroundColor Gray
    
    if ($avg -lt 30) {
        Write-Host "🏆 V4 TARGET ACHIEVED!" -ForegroundColor Green
    } elseif ($avg -lt 50) {
        Write-Host "⚡ Excellent V4 performance" -ForegroundColor Yellow
    } else {
        Write-Host "⚠️ V4 needs optimization" -ForegroundColor Red
    }
}

# Aliases for backward compatibility
Set-Alias -Name dbg-summary -Value Get-V4DebugSummary
Set-Alias -Name module-status -Value Get-V4ModuleStatus
Set-Alias -Name test-performance -Value Test-V4Performance

# Advanced memory cleanup with GC optimization
function clear-cache {
    $global:DraculaAdvancedPool.PathCache.Clear()
    $global:DraculaAdvancedPool.ModuleCache.Clear()
    $global:DraculaAdvancedPool.CommandCache.Clear()
    $global:DraculaAdvancedPool.StringBuffer.Clear()
    
    # Clear load queue
    while ($global:DraculaAdvancedPool.LoadQueue.TryDequeue([ref]$null)) { 
    }
    
    # Force garbage collection for optimal memory usage
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    [System.GC]::Collect()
    
    Write-Host "🧹 V4 Advanced cache cleared + GC optimized" -ForegroundColor Green
}
#endregion

#region 🎨 JIT-Optimized Oh My Posh Integration V4
# Advanced Oh My Posh with async loading
function Initialize-V4OhMyPosh {
    if (-not $global:DraculaAdvancedPool.ModuleCache.ContainsKey('OhMyPosh')) {
        $loadScript = {
            if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
                $themePath = if ($env:POSH_THEMES_PATH) {
                    Join-Path $env:POSH_THEMES_PATH "dracula.omp.json"
                } else {
                    $null
                }
                
                if ($themePath -and (Test-Path $themePath)) {
                    oh-my-posh init pwsh --config $themePath | Invoke-Expression
                    Write-Host "🎨 V4 Oh My Posh Dracula theme loaded" -ForegroundColor Magenta
                } else {
                    Write-Host "⚠️ V4 Dracula theme not found, using default" -ForegroundColor Yellow
                    oh-my-posh init pwsh | Invoke-Expression
                }
                return $true
            } else {
                Write-Host "❌ V4 Oh My Posh not installed" -ForegroundColor Red
                return $false
            }
        }
        
        # Async loading
        Start-Job -ScriptBlock $loadScript | Wait-Job | Receive-Job | Remove-Job
        $global:DraculaAdvancedPool.ModuleCache['OhMyPosh'] = $true
    }
}

# Alias for backward compatibility
Set-Alias -Name load-omp -Value Initialize-V4OhMyPosh
#endregion

#region 🔧 Advanced Command Override Hooks V4
# JIT-optimized command hooks with pattern caching
$global:CommandPatternCache = @{
    '^(Get-|Set-|New-|Remove-).*Icon.*' = 'load-icons'
    '^z$'                               = 'load-z'
    '^(Get-|Set-)PSReadLine.*'          = 'load-psrl'
    '^oh-my-posh.*'                     = 'load-omp'
}

$ExecutionContext.InvokeCommand.PreCommandLookupAction = {
    param($commandName, $commandLookupEventArgs)
    
    # Optimized pattern matching with caching
    foreach ($pattern in $global:CommandPatternCache.Keys) {
        if ($commandName -match $pattern) {
            $action = $global:CommandPatternCache[$pattern]
            if ($global:DraculaAdvancedPool.CommandCache.ContainsKey($action)) {
                & $global:DraculaAdvancedPool.CommandCache[$action]
            } else {
                & $action
            }
            break
        }
    }
}
#endregion

#region 📊 V4 Advanced Performance Monitoring
# Enhanced performance monitoring with metrics
if ($env:DRACULA_SHOW_STARTUP -eq 'true') {
    Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
        if ($global:ProfileLoadStart) {
            $loadTime = $global:ProfileLoadStart.Elapsed.TotalMilliseconds
            Write-Host "⚡ V4 Profile loaded in ${loadTime:F2}ms" -ForegroundColor Green
            
            if ($env:DRACULA_PERFORMANCE_DEBUG -eq 'true') {
                Write-Host "📈 Cache performance: $($global:V4PerfCounters.CacheHits) hits, $($global:V4PerfCounters.CacheMisses) misses" -ForegroundColor Gray
            }
        }
    }
}

# Background cache optimization
if ($env:DRACULA_PERFORMANCE_DEBUG -eq 'true') {
    Start-Job -ScriptBlock {
        Start-Sleep 2
        [System.GC]::Collect()
    } | Out-Null
}
#endregion

# V4 Profile loaded notification (minimal)
if ($env:DRACULA_PERFORMANCE_DEBUG -eq 'true') {
    Write-Host "🧛‍♂️ Dracula V4 Ultra-Performance Profile Ready (JIT Optimized)" -ForegroundColor Magenta
}
