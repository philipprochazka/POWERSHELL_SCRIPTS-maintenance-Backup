#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Pester tests for AsyncProfileRouter lazy module loading functionality
    
.DESCRIPTION
    Comprehensive test suite for the enhanced async router with lazy loading capabilities
#>

BeforeAll {
    # Import the AsyncProfileRouter
    $routerPath = Join-Path $PSScriptRoot "PowerShellModules\UnifiedPowerShellProfile\Core\AsyncProfileRouter.ps1"
    if (Test-Path $routerPath) {
        . $routerPath
    } else {
        throw "AsyncProfileRouter not found at $routerPath"
    }
}

Describe "AsyncProfileRouter Lazy Module Loading" {
    
    Context "Infrastructure Initialization" {
        
        It "Should initialize dependency graph correctly" {
            # Force re-initialization for testing
            Initialize-AsyncInfrastructure
            
            $script:ModuleDependencyGraph | Should -Not -BeNullOrEmpty
            $script:ModuleDependencyGraph.Keys.Count | Should -BeGreaterThan 5
            $script:LazyModuleLoaders | Should -Not -BeNullOrEmpty
        }
        
        It "Should have correct module metadata structure" {
            $script:ModeMetadata | Should -Not -BeNullOrEmpty
            $script:ModeMetadata.Keys | Should -Contain 'Dracula'
            $script:ModeMetadata.Keys | Should -Contain 'MCP'
            
            $draculaMode = $script:ModeMetadata['Dracula']
            $draculaMode.RequiredModules | Should -Not -BeNullOrEmpty
            $draculaMode.OptionalModules | Should -Not -BeNull
            $draculaMode.LoadPriority | Should -BeGreaterThan 0
        }
        
        It "Should create lazy loaders for appropriate modules" {
            $lazyModules = $script:ModuleDependencyGraph.Keys | Where-Object { 
                $script:ModuleDependencyGraph[$_].LazyLoad -eq $true 
            }
            
            $lazyModules | Should -Not -BeNullOrEmpty
            $lazyModules.Count | Should -BeGreaterThan 3
            
            foreach ($module in $lazyModules) {
                $script:LazyModuleLoaders.ContainsKey($module) | Should -Be $true
            }
        }
    }
    
    Context "Module Dependency Resolution" {
        
        It "Should resolve cross-references correctly" {
            $testModules = @('Az.Tools.Predictor', 'Terminal-Icons', 'PSReadLine', 'z')
            $resolved = Resolve-ModuleCrossReferences -ModuleList $testModules
            
            $resolved | Should -Not -BeNullOrEmpty
            $resolved.Count | Should -Be $testModules.Count
            
            # PSReadLine should come first (lowest priority number)
            $resolved[0] | Should -Be 'PSReadLine'
        }
        
        It "Should handle unknown modules gracefully" {
            $testModules = @('PSReadLine', 'NonExistentModule123', 'Terminal-Icons')
            $resolved = Resolve-ModuleCrossReferences -ModuleList $testModules
            
            $resolved | Should -Not -BeNullOrEmpty
            $resolved | Should -Contain 'NonExistentModule123'
            $resolved | Should -Contain 'PSReadLine'
            $resolved | Should -Contain 'Terminal-Icons'
        }
    }
    
    Context "Lazy Module Loading" {
        
        It "Should load known modules with lazy loader" {
            $result = Invoke-LazyModuleLoad -ModuleName 'PSReadLine'
            
            $result | Should -Not -BeNullOrEmpty
            $result.Success | Should -Be $true
            $result.Module | Should -Be 'PSReadLine'
            $result.Method | Should -BeIn @('Lazy', 'Standard')
        }
        
        It "Should handle non-existent modules gracefully" {
            $result = Invoke-LazyModuleLoad -ModuleName 'NonExistentModule123'
            
            $result | Should -Not -BeNullOrEmpty
            $result.Success | Should -Be $false
            $result.Module | Should -Be 'NonExistentModule123'
            $result.Error | Should -Not -BeNullOrEmpty
        }
        
        It "Should cache loaded modules" {
            # Clear cache first
            Clear-ModuleCache -Force
            
            # Load a module
            $result1 = Invoke-LazyModuleLoad -ModuleName 'PSReadLine'
            $result2 = Invoke-LazyModuleLoad -ModuleName 'PSReadLine'
            
            $result1.Success | Should -Be $true
            $result2.Success | Should -Be $true
            $result2.Cached | Should -Be $true
        }
    }
    
    Context "Cache Management" {
        
        It "Should provide cache status information" {
            $status = Get-ModuleCacheStatus
            
            $status | Should -Not -BeNullOrEmpty
            $status.CachedModules | Should -Not -BeNull
            $status.LazyLoaders | Should -Not -BeNull
            $status.TotalCached | Should -BeGreaterOrEqual 0
            $status.MemoryFootprint | Should -BeGreaterOrEqual 0
        }
        
        It "Should clear specific modules from cache" {
            # Ensure something is in cache
            Invoke-LazyModuleLoad -ModuleName 'PSReadLine' | Out-Null
            
            $cacheStatus = Get-ModuleCacheStatus
            $initialCount = $cacheStatus.TotalCached
            
            Clear-ModuleCache -ModuleNames @('PSReadLine')
            
            $newStatus = Get-ModuleCacheStatus
            $newStatus.TotalCached | Should -BeLessOrEqual $initialCount
        }
        
        It "Should clear all cache with Force parameter" {
            # Ensure something is in cache
            Invoke-LazyModuleLoad -ModuleName 'PSReadLine' | Out-Null
            
            Clear-ModuleCache -Force
            
            $status = Get-ModuleCacheStatus
            $status.TotalCached | Should -Be 0
        }
    }
    
    Context "Performance and Optimization" {
        
        It "Should provide optimization recommendations" {
            { Optimize-ModuleLoading -Mode 'Dracula' } | Should -Not -Throw
            { Optimize-ModuleLoading } | Should -Not -Throw
        }
        
        It "Should track loading performance" {
            $status = Get-AsyncLoadingStatus
            
            $status | Should -Not -BeNullOrEmpty
            $status.TotalElapsed | Should -BeGreaterThan 0
            $status.LoadingSteps | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Async Profile Loading" {
        
        It "Should load Dracula mode without errors" {
            { $result = Invoke-AsyncProfileRouter -Mode 'Dracula' -ShowProgress:$false } | Should -Not -Throw
        }
        
        It "Should load Minimal mode quickly" {
            $startTime = Get-Date
            $result = Invoke-AsyncProfileRouter -Mode 'Minimal' -ShowProgress:$false
            $elapsed = ((Get-Date) - $startTime).TotalMilliseconds
            
            # Minimal mode should load very quickly
            $elapsed | Should -BeLessThan 2000
        }
        
        It "Should handle invalid mode gracefully" {
            { Invoke-AsyncProfileRouter -Mode 'InvalidMode123' -ShowProgress:$false } | Should -Throw
        }
    }
}

Describe "AsyncProfileRouter Integration Tests" -Tag "Integration" {
    
    Context "Real Module Loading" {
        
        It "Should successfully load common PowerShell modules" {
            $commonModules = @('PSReadLine', 'Microsoft.PowerShell.Management')
            
            foreach ($module in $commonModules) {
                if (Get-Module -ListAvailable -Name $module) {
                    $result = Invoke-LazyModuleLoad -ModuleName $module
                    $result.Success | Should -Be $true
                }
            }
        }
    }
    
    Context "Performance Benchmarks" {
        
        It "Should complete full Dracula mode loading within reasonable time" {
            $startTime = Get-Date
            $result = Invoke-AsyncProfileRouter -Mode 'Dracula' -ShowProgress:$false
            $elapsed = ((Get-Date) - $startTime).TotalMilliseconds
            
            # Should complete within 5 seconds even with all modules
            $elapsed | Should -BeLessThan 5000
        }
    }
}
