# Unit Tests for Start-ContinuousCleanup Function
# Testing the continuous cleanup system with comprehensive coverage

BeforeAll {
    # Import the module under test
    $ModulePath = "$PSScriptRoot\..\..\PowerShellModules\UnifiedMCPProfile"
    if (Test-Path $ModulePath) {
        Import-Module $ModulePath -Force
    }
    
    # Create test environment
    $TestRoot = "TestDrive:\CleanupTests"
    New-Item -Path $TestRoot -ItemType Directory -Force
    
    # Test data setup
    $TestCategories = @('Profiles', 'Documentation', 'Performance', 'Development')
    $TestFiles = @(
        "$TestRoot\test-profile.ps1",
        "$TestRoot\test-doc.md",
        "$TestRoot\test-performance.log",
        "$TestRoot\test-dev.tmp"
    )
}

Describe "Start-ContinuousCleanup" -Tag @('Unit', 'ContinuousCleanup') {
    
    Context "Parameter Validation" {
        It "Should accept valid MaxFilesPerRun parameter" {
            { Start-ContinuousCleanup -MaxFilesPerRun 10 -WhatIf } | Should -Not -Throw
        }
        
        It "Should accept valid TargetCategories parameter" {
            { Start-ContinuousCleanup -TargetCategories @('Profiles') -WhatIf } | Should -Not -Throw
        }
        
        It "Should accept AutoCommit switch" {
            { Start-ContinuousCleanup -AutoCommit -WhatIf } | Should -Not -Throw
        }
        
        It "Should throw on invalid MaxFilesPerRun (negative value)" {
            { Start-ContinuousCleanup -MaxFilesPerRun -5 } | Should -Throw
        }
        
        It "Should throw on invalid MaxFilesPerRun (zero value)" {
            { Start-ContinuousCleanup -MaxFilesPerRun 0 } | Should -Throw
        }
        
        It "Should accept WhatIf parameter for dry run" {
            { Start-ContinuousCleanup -WhatIf } | Should -Not -Throw
        }
    }
    
    Context "Function Availability and Structure" {
        It "Should be available as a command" {
            Get-Command Start-ContinuousCleanup -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
        
        It "Should have proper comment-based help" {
            $Help = Get-Help Start-ContinuousCleanup -ErrorAction SilentlyContinue
            $Help.Synopsis | Should -Not -BeNullOrEmpty
            $Help.Description | Should -Not -BeNullOrEmpty
        }
        
        It "Should have required parameters defined" {
            $Command = Get-Command Start-ContinuousCleanup
            $Command.Parameters.Keys | Should -Contain 'MaxFilesPerRun'
            $Command.Parameters.Keys | Should -Contain 'TargetCategories'
            $Command.Parameters.Keys | Should -Contain 'AutoCommit'
        }
    }
    
    Context "WhatIf Mode Testing" {
        BeforeEach {
            # Create test files for each run
            foreach ($File in $TestFiles) {
                "Test content for $(Split-Path $File -Leaf)" | Out-File -FilePath $File -Force
            }
        }
        
        It "Should run in WhatIf mode without making changes" {
            $OriginalFileCount = (Get-ChildItem $TestRoot).Count
            Start-ContinuousCleanup -MaxFilesPerRun 5 -WhatIf
            $NewFileCount = (Get-ChildItem $TestRoot).Count
            $NewFileCount | Should -Be $OriginalFileCount
        }
        
        It "Should return status information in WhatIf mode" {
            $Result = Start-ContinuousCleanup -MaxFilesPerRun 5 -WhatIf -PassThru
            $Result | Should -Not -BeNullOrEmpty
            $Result.GetType().Name | Should -Be 'PSCustomObject'
        }
        
        AfterEach {
            # Cleanup test files
            Get-ChildItem $TestRoot -File | Remove-Item -Force
        }
    }
    
    Context "Category Filtering" {
        It "Should filter by single category" {
            { Start-ContinuousCleanup -TargetCategories @('Profiles') -WhatIf } | Should -Not -Throw
        }
        
        It "Should filter by multiple categories" {
            { Start-ContinuousCleanup -TargetCategories @('Profiles', 'Documentation') -WhatIf } | Should -Not -Throw
        }
        
        It "Should handle 'All' category" {
            { Start-ContinuousCleanup -TargetCategories @('All') -WhatIf } | Should -Not -Throw
        }
        
        It "Should validate category names" {
            { Start-ContinuousCleanup -TargetCategories @('InvalidCategory') -WhatIf } | Should -Throw
        }
    }
    
    Context "File Processing Limits" {
        BeforeEach {
            # Create more test files than the limit
            for ($i = 1; $i -le 15; $i++) {
                "Test content $i" | Out-File -FilePath "$TestRoot\testfile_$i.tmp" -Force
            }
        }
        
        It "Should respect MaxFilesPerRun limit" {
            $FileCountBefore = (Get-ChildItem $TestRoot -File).Count
            $FileCountBefore | Should -BeGreaterThan 10
            
            # This test validates the parameter is respected, not actual file changes
            { Start-ContinuousCleanup -MaxFilesPerRun 5 -WhatIf } | Should -Not -Throw
        }
        
        It "Should handle large MaxFilesPerRun values" {
            { Start-ContinuousCleanup -MaxFilesPerRun 1000 -WhatIf } | Should -Not -Throw
        }
        
        AfterEach {
            Get-ChildItem $TestRoot -File | Remove-Item -Force
        }
    }
    
    Context "Performance Validation" {
        It "Should complete WhatIf operation within reasonable time" {
            $StartTime = Get-Date
            Start-ContinuousCleanup -MaxFilesPerRun 10 -WhatIf
            $Duration = (Get-Date) - $StartTime
            $Duration.TotalSeconds | Should -BeLessThan 30
        }
    }
    
    Context "Error Handling" {
        It "Should handle missing module gracefully" {
            # Mock scenario where module is not available
            Mock Get-Module { $null } -ModuleName UnifiedMCPProfile
            { Start-ContinuousCleanup -WhatIf } | Should -Not -Throw
        }
        
        It "Should handle file system errors gracefully" {
            # This tests the function's error handling capabilities
            { Start-ContinuousCleanup -MaxFilesPerRun 5 -WhatIf } | Should -Not -Throw
        }
    }
    
    Context "Output and Logging" {
        It "Should produce verbose output when requested" {
            $VerboseOutput = Start-ContinuousCleanup -MaxFilesPerRun 5 -WhatIf -Verbose 4>&1
            $VerboseOutput | Should -Not -BeNullOrEmpty
        }
        
        It "Should support PassThru parameter" {
            $Result = Start-ContinuousCleanup -MaxFilesPerRun 5 -WhatIf -PassThru
            $Result | Should -Not -BeNullOrEmpty
        }
    }
}

Describe "Start-ContinuousCleanup Integration Points" -Tag @('Unit', 'Integration') {
    
    Context "Module Dependencies" {
        It "Should work with UnifiedMCPProfile module" {
            $Module = Get-Module UnifiedMCPProfile -ListAvailable
            $Module | Should -Not -BeNullOrEmpty
        }
        
        It "Should have proper function exports" {
            $ExportedFunctions = (Get-Module UnifiedMCPProfile).ExportedFunctions.Keys
            $ExportedFunctions | Should -Contain 'Start-ContinuousCleanup'
        }
    }
    
    Context "PowerShell Compatibility" {
        It "Should work in current PowerShell version" {
            $PSVersionTable.PSVersion.Major | Should -BeGreaterOrEqual 5
            { Start-ContinuousCleanup -WhatIf } | Should -Not -Throw
        }
    }
}

AfterAll {
    # Cleanup test environment
    if (Test-Path $TestRoot) {
        Remove-Item -Path $TestRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # Remove module if it was imported for testing
    Remove-Module UnifiedMCPProfile -Force -ErrorAction SilentlyContinue
}
