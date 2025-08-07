# Performance Tests for PowerShell Workspace
# Validates performance requirements and benchmarks for the workspace

BeforeAll {
    # Performance test configuration
    $TestWorkspace = "$PSScriptRoot\..\.."
    $PerformanceThresholds = @{
        ProfileLoadTime          = 2.0          # Maximum seconds for profile load
        UltraPerformanceLoadTime = 1.5 # Maximum seconds for ultra performance profile
        TestSuiteRunTime         = 30.0        # Maximum seconds for full test suite
        MemoryUsageMB            = 100            # Maximum MB memory increase
        ModuleImportTime         = 5.0         # Maximum seconds for module import
    }
    
    # Pre-test cleanup
    Get-Process -Name pwsh -ErrorAction SilentlyContinue | Where-Object { $_.Id -ne $PID } | Stop-Process -Force -ErrorAction SilentlyContinue
    
    # Baseline memory measurement
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    $BaselineMemory = [System.GC]::GetTotalMemory($false)
}

Describe "Performance Benchmarks" -Tag @('Performance', 'Benchmarks') {
    
    Context "Profile Loading Performance" {
        It "Should load Dracula profile within threshold (<$($PerformanceThresholds.ProfileLoadTime)s)" {
            $ProfilePath = "$TestWorkspace\Microsoft.PowerShell_profile_Dracula.ps1"
            if (Test-Path $ProfilePath) {
                $Measurements = 1..3 | ForEach-Object {
                    $StartTime = Get-Date
                    $null = Start-Job -ScriptBlock { 
                        param($Path) 
                        . $Path 
                    } -ArgumentList $ProfilePath | Wait-Job | Receive-Job
                    ((Get-Date) - $StartTime).TotalSeconds
                }
                $AverageTime = ($Measurements | Measure-Object -Average).Average
                $AverageTime | Should -BeLessThan $PerformanceThresholds.ProfileLoadTime -Because "Profile should load quickly"
            } else {
                Set-ItResult -Skipped -Because "Dracula profile not found"
            }
        }
        
        It "Should load Ultra Performance profile within threshold (<$($PerformanceThresholds.UltraPerformanceLoadTime)s)" {
            $ProfilePath = "$TestWorkspace\Microsoft.PowerShell_profile_Dracula_UltraPerformance.ps1"
            if (Test-Path $ProfilePath) {
                $Measurements = 1..3 | ForEach-Object {
                    $StartTime = Get-Date
                    $null = Start-Job -ScriptBlock { 
                        param($Path) 
                        . $Path 
                    } -ArgumentList $ProfilePath | Wait-Job | Receive-Job
                    ((Get-Date) - $StartTime).TotalSeconds
                }
                $AverageTime = ($Measurements | Measure-Object -Average).Average
                $AverageTime | Should -BeLessThan $PerformanceThresholds.UltraPerformanceLoadTime -Because "Ultra Performance profile should be fastest"
            } else {
                Set-ItResult -Skipped -Because "Ultra Performance profile not found"
            }
        }
        
        It "Should load MCP profile within threshold (<$($PerformanceThresholds.ProfileLoadTime)s)" {
            $ProfilePath = "$TestWorkspace\Microsoft.PowerShell_profile_MCP.ps1"
            if (Test-Path $ProfilePath) {
                $StartTime = Get-Date
                $null = Start-Job -ScriptBlock { 
                    param($Path) 
                    . $Path 
                } -ArgumentList $ProfilePath | Wait-Job | Receive-Job
                $LoadTime = ((Get-Date) - $StartTime).TotalSeconds
                $LoadTime | Should -BeLessThan $PerformanceThresholds.ProfileLoadTime -Because "MCP profile should load within threshold"
            } else {
                Set-ItResult -Skipped -Because "MCP profile not found"
            }
        }
    }
    
    Context "Module Import Performance" {
        It "Should import UnifiedMCPProfile module within threshold (<$($PerformanceThresholds.ModuleImportTime)s)" {
            $ModulePath = "$TestWorkspace\PowerShellModules\UnifiedMCPProfile"
            if (Test-Path $ModulePath) {
                Remove-Module UnifiedMCPProfile -Force -ErrorAction SilentlyContinue
                $StartTime = Get-Date
                Import-Module $ModulePath -Force
                $ImportTime = ((Get-Date) - $StartTime).TotalSeconds
                $ImportTime | Should -BeLessThan $PerformanceThresholds.ModuleImportTime -Because "Module import should be fast"
            } else {
                Set-ItResult -Skipped -Because "UnifiedMCPProfile module not found"
            }
        }
        
        It "Should have minimal memory overhead after module import" {
            $ModulePath = "$TestWorkspace\PowerShellModules\UnifiedMCPProfile"
            if (Test-Path $ModulePath) {
                [System.GC]::Collect()
                $MemoryBefore = [System.GC]::GetTotalMemory($false)
                
                Import-Module $ModulePath -Force
                
                [System.GC]::Collect()
                $MemoryAfter = [System.GC]::GetTotalMemory($false)
                
                $MemoryIncreaseMB = ($MemoryAfter - $MemoryBefore) / 1MB
                $MemoryIncreaseMB | Should -BeLessThan $PerformanceThresholds.MemoryUsageMB -Because "Module should have minimal memory footprint"
            } else {
                Set-ItResult -Skipped -Because "UnifiedMCPProfile module not found"
            }
        }
    }
    
    Context "Function Performance Benchmarks" {
        It "Should execute Start-ContinuousCleanup WhatIf operation quickly" {
            if (Get-Command Start-ContinuousCleanup -ErrorAction SilentlyContinue) {
                $StartTime = Get-Date
                Start-ContinuousCleanup -MaxFilesPerRun 10 -WhatIf
                $ExecutionTime = ((Get-Date) - $StartTime).TotalSeconds
                $ExecutionTime | Should -BeLessThan 10 -Because "WhatIf operations should be fast"
            } else {
                Set-ItResult -Skipped -Because "Start-ContinuousCleanup function not available"
            }
        }
        
        It "Should handle large file counts efficiently" {
            if (Get-Command Start-ContinuousCleanup -ErrorAction SilentlyContinue) {
                $StartTime = Get-Date
                Start-ContinuousCleanup -MaxFilesPerRun 100 -WhatIf
                $ExecutionTime = ((Get-Date) - $StartTime).TotalSeconds
                $ExecutionTime | Should -BeLessThan 20 -Because "Large file operations should still be reasonably fast"
            } else {
                Set-ItResult -Skipped -Because "Start-ContinuousCleanup function not available"
            }
        }
    }
    
    Context "VS Code Integration Performance" {
        It "Should parse tasks.json quickly" {
            $TasksPath = "$TestWorkspace\.vscode\tasks.json"
            if (Test-Path $TasksPath) {
                $StartTime = Get-Date
                $null = Get-Content $TasksPath -Raw | ConvertFrom-Json
                $ParseTime = ((Get-Date) - $StartTime).TotalSeconds
                $ParseTime | Should -BeLessThan 1 -Because "Tasks configuration should parse quickly"
            } else {
                Set-ItResult -Skipped -Because "tasks.json not found"
            }
        }
        
        It "Should parse launch.json quickly" {
            $LaunchPath = "$TestWorkspace\.vscode\launch.json"
            if (Test-Path $LaunchPath) {
                $StartTime = Get-Date
                $null = Get-Content $LaunchPath -Raw | ConvertFrom-Json
                $ParseTime = ((Get-Date) - $StartTime).TotalSeconds
                $ParseTime | Should -BeLessThan 1 -Because "Launch configuration should parse quickly"
            } else {
                Set-ItResult -Skipped -Because "launch.json not found"
            }
        }
    }
    
    Context "PSScriptAnalyzer Performance" {
        It "Should analyze single file quickly" {
            $TestFile = Get-ChildItem "$TestWorkspace" -Filter "*.ps1" | Select-Object -First 1
            if ($TestFile -and (Get-Command Invoke-ScriptAnalyzer -ErrorAction SilentlyContinue)) {
                $StartTime = Get-Date
                $null = Invoke-ScriptAnalyzer -Path $TestFile.FullName -Settings "$TestWorkspace\PSScriptAnalyzerSettings.psd1"
                $AnalysisTime = ((Get-Date) - $StartTime).TotalSeconds
                $AnalysisTime | Should -BeLessThan 5 -Because "Single file analysis should be fast"
            } else {
                Set-ItResult -Skipped -Because "No PowerShell files found or PSScriptAnalyzer not available"
            }
        }
        
        It "Should analyze workspace within reasonable time" {
            if (Get-Command Invoke-ScriptAnalyzer -ErrorAction SilentlyContinue) {
                $StartTime = Get-Date
                $null = Invoke-ScriptAnalyzer -Path $TestWorkspace -Settings "$TestWorkspace\PSScriptAnalyzerSettings.psd1" -Recurse
                $AnalysisTime = ((Get-Date) - $StartTime).TotalSeconds
                $AnalysisTime | Should -BeLessThan 60 -Because "Full workspace analysis should complete within a minute"
            } else {
                Set-ItResult -Skipped -Because "PSScriptAnalyzer not available"
            }
        }
    }
}

Describe "Memory Usage Benchmarks" -Tag @('Performance', 'Memory') {
    
    Context "Memory Efficiency" {
        It "Should maintain reasonable memory usage after all operations" {
            # Perform various operations
            if (Test-Path "$TestWorkspace\Microsoft.PowerShell_profile_Dracula.ps1") {
                . "$TestWorkspace\Microsoft.PowerShell_profile_Dracula.ps1"
            }
            
            if (Get-Command Start-ContinuousCleanup -ErrorAction SilentlyContinue) {
                Start-ContinuousCleanup -MaxFilesPerRun 5 -WhatIf
            }
            
            # Force garbage collection
            [System.GC]::Collect()
            [System.GC]::WaitForPendingFinalizers()
            [System.GC]::Collect()
            
            $CurrentMemory = [System.GC]::GetTotalMemory($false)
            $MemoryIncreaseMB = ($CurrentMemory - $BaselineMemory) / 1MB
            
            $MemoryIncreaseMB | Should -BeLessThan ($PerformanceThresholds.MemoryUsageMB * 2) -Because "Total memory usage should remain reasonable"
        }
        
        It "Should not have memory leaks in repeated operations" {
            if (Get-Command Start-ContinuousCleanup -ErrorAction SilentlyContinue) {
                [System.GC]::Collect()
                $MemoryBefore = [System.GC]::GetTotalMemory($false)
                
                # Perform repeated operations
                1..5 | ForEach-Object {
                    Start-ContinuousCleanup -MaxFilesPerRun 3 -WhatIf
                }
                
                [System.GC]::Collect()
                $MemoryAfter = [System.GC]::GetTotalMemory($false)
                
                $MemoryIncrease = ($MemoryAfter - $MemoryBefore) / 1MB
                $MemoryIncrease | Should -BeLessThan 50 -Because "Repeated operations should not cause significant memory increase"
            } else {
                Set-ItResult -Skipped -Because "Start-ContinuousCleanup function not available"
            }
        }
    }
}

Describe "Scalability Benchmarks" -Tag @('Performance', 'Scalability') {
    
    Context "File System Operations" {
        It "Should handle large directory structures efficiently" {
            $LargeTestPath = "TestDrive:\LargeStructure"
            New-Item -Path $LargeTestPath -ItemType Directory -Force
            
            # Create a moderately large directory structure
            1..20 | ForEach-Object {
                $SubDir = "$LargeTestPath\Dir$_"
                New-Item -Path $SubDir -ItemType Directory -Force
                1..10 | ForEach-Object {
                    "Test content $_" | Out-File -FilePath "$SubDir\file$_.txt"
                }
            }
            
            $StartTime = Get-Date
            $FileCount = (Get-ChildItem $LargeTestPath -Recurse -File).Count
            $ScanTime = ((Get-Date) - $StartTime).TotalSeconds
            
            $FileCount | Should -BeGreaterThan 150
            $ScanTime | Should -BeLessThan 10 -Because "Directory scanning should be efficient"
            
            # Cleanup
            Remove-Item $LargeTestPath -Recurse -Force
        }
        
        It "Should process multiple categories efficiently" {
            if (Get-Command Start-ContinuousCleanup -ErrorAction SilentlyContinue) {
                $Categories = @('Profiles', 'Documentation', 'Performance', 'Development')
                $StartTime = Get-Date
                
                foreach ($Category in $Categories) {
                    Start-ContinuousCleanup -TargetCategories @($Category) -MaxFilesPerRun 5 -WhatIf
                }
                
                $ProcessTime = ((Get-Date) - $StartTime).TotalSeconds
                $ProcessTime | Should -BeLessThan 20 -Because "Processing multiple categories should be efficient"
            } else {
                Set-ItResult -Skipped -Because "Start-ContinuousCleanup function not available"
            }
        }
    }
}

AfterAll {
    # Performance test cleanup
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    
    # Remove test modules
    Remove-Module UnifiedMCPProfile -Force -ErrorAction SilentlyContinue
    
    # Export performance metrics for tracking
    $PerformanceReport = @{
        TestDate          = Get-Date
        BaselineMemoryMB  = $BaselineMemory / 1MB
        Thresholds        = $PerformanceThresholds
        PowerShellVersion = $PSVersionTable.PSVersion.ToString()
        OSVersion         = [System.Environment]::OSVersion.ToString()
    }
    
    $ReportPath = "$TestWorkspace\Tests\Reports\performance-baseline.json"
    $PerformanceReport | ConvertTo-Json -Depth 3 | Out-File -FilePath $ReportPath -Force
}
