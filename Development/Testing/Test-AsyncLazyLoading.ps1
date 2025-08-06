#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Test script for AsyncProfileRouter lazy module loading
    
.DESCRIPTION
    Demonstrates the new lazy module loading capabilities and performance improvements
    
.EXAMPLE
    .\Test-AsyncLazyLoading.ps1 -Mode Dracula -ShowProgress
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('Dracula', 'MCP', 'LazyAdmin', 'Minimal', 'Custom')]
    [string]$Mode = 'Dracula',
    
    [Parameter()]
    [switch]$ShowProgress = $true,
    
    [Parameter()]
    [switch]$TestModuleCache,
    
    [Parameter()]
    [switch]$BenchmarkLoading
)

# Import the AsyncProfileRouter
$routerPath = Join-Path $PSScriptRoot "PowerShellModules\UnifiedPowerShellProfile\Core\AsyncProfileRouter.ps1"
if (Test-Path $routerPath) {
    . $routerPath
} else {
    Write-Error "AsyncProfileRouter not found at $routerPath"
    exit 1
}

Write-Host "🧪 Testing Async Lazy Module Loading System" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Gray

# Test 1: Basic async loading with progress
Write-Host "`n📋 Test 1: Basic Async Loading" -ForegroundColor Yellow
$result1 = Invoke-AsyncProfileRouter -Mode $Mode -ShowProgress:$ShowProgress

# Test 2: Module cache status
if ($TestModuleCache) {
    Write-Host "`n📋 Test 2: Module Cache Status" -ForegroundColor Yellow
    $cacheStatus = Get-ModuleCacheStatus
    Write-Host "   Cached Modules: $($cacheStatus.CachedModules -join ', ')" -ForegroundColor Green
    Write-Host "   Lazy Loaders: $($cacheStatus.LazyLoaders -join ', ')" -ForegroundColor Green
    Write-Host "   Total Cached: $($cacheStatus.TotalCached)" -ForegroundColor Green
    Write-Host "   Est. Memory: $($cacheStatus.MemoryFootprint) bytes" -ForegroundColor Green
}

# Test 3: Manual lazy module loading
Write-Host "`n📋 Test 3: Manual Lazy Module Loading" -ForegroundColor Yellow
$testModules = @('Terminal-Icons', 'z', 'Az.Tools.Predictor')
foreach ($module in $testModules) {
    Write-Host "   Testing $module..." -ForegroundColor Gray
    $moduleResult = Invoke-LazyModuleLoad -ModuleName $module
    if ($moduleResult.Success) {
        $status = if ($moduleResult.Cached) {
            "Cached" 
        } else {
            "Loaded" 
        }
        Write-Host "      ✅ $status ($($moduleResult.Method), $([math]::Round($moduleResult.LoadTime, 0))ms)" -ForegroundColor Green
    } else {
        Write-Host "      ❌ Failed: $($moduleResult.Error)" -ForegroundColor Red
    }
}

# Test 4: Dependency resolution
Write-Host "`n📋 Test 4: Cross-Reference Resolution" -ForegroundColor Yellow
$testModuleList = @('Az.Tools.Predictor', 'Terminal-Icons', 'PSReadLine', 'z')
$resolvedOrder = Resolve-ModuleCrossReferences -ModuleList $testModuleList
Write-Host "   Original order: $($testModuleList -join ' → ')" -ForegroundColor Gray
Write-Host "   Resolved order: $($resolvedOrder -join ' → ')" -ForegroundColor Green

# Test 5: Loading optimization recommendations
Write-Host "`n📋 Test 5: Loading Optimization" -ForegroundColor Yellow
Optimize-ModuleLoading -Mode $Mode

# Test 6: Performance benchmark
if ($BenchmarkLoading) {
    Write-Host "`n📋 Test 6: Performance Benchmark" -ForegroundColor Yellow
    
    # Clear cache for fair test
    Clear-ModuleCache -Force
    
    # Benchmark standard loading
    $standardStart = Get-Date
    $testModule = 'Terminal-Icons'
    if (Get-Module -Name $testModule) {
        Remove-Module $testModule 
    }
    Import-Module $testModule -Force -ErrorAction SilentlyContinue
    $standardTime = ((Get-Date) - $standardStart).TotalMilliseconds
    
    # Clear and test lazy loading
    if (Get-Module -Name $testModule) {
        Remove-Module $testModule 
    }
    $lazyStart = Get-Date
    $lazyResult = Invoke-LazyModuleLoad -ModuleName $testModule
    $lazyTime = $lazyResult.LoadTime
    
    Write-Host "   Standard Import: $([math]::Round($standardTime, 0))ms" -ForegroundColor Yellow
    Write-Host "   Lazy Loading:    $([math]::Round($lazyTime, 0))ms" -ForegroundColor Green
    
    $improvement = (($standardTime - $lazyTime) / $standardTime) * 100
    Write-Host "   Performance:     $([math]::Round($improvement, 1))% improvement" -ForegroundColor Cyan
}

# Final status
Write-Host "`n📊 Final Status Report" -ForegroundColor Cyan
$finalStatus = Get-AsyncLoadingStatus
Write-Host "   Total Elapsed: $([math]::Round($finalStatus.TotalElapsed, 0))ms" -ForegroundColor White
Write-Host "   Loaded Modes: $($finalStatus.LoadedModes -join ', ')" -ForegroundColor White
Write-Host "   Pending Jobs: $($finalStatus.PendingJobs)" -ForegroundColor White

Write-Host "`n✅ Testing Complete!" -ForegroundColor Green
