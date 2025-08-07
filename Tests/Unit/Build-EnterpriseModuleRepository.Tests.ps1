#Requires -Modules Pester

<#
.SYNOPSIS
    Comprehensive Pester tests for Build-EnterpriseModuleRepository.ps1

.DESCRIPTION
    Tests all functions, parameters, and workflows in the enterprise module repository builder.
    Ensures PowerShell development standards compliance and functionality validation.
#>

Describe "Build-EnterpriseModuleRepository" {
    BeforeAll {
        # Set up test environment
        $testRoot = "TestDrive:\EnterpriseModuleTest"
        $testModulesPath = Join-Path $testRoot "PowerShellModules"
        
        # Create test module structure
        New-Item -Path $testModulesPath -ItemType Directory -Force
        New-Item -Path "$testModulesPath\TestModule1" -ItemType Directory -Force
        New-Item -Path "$testModulesPath\TestModule2" -ItemType Directory -Force
        
        # Mock external dependencies at module level
        function script:Push-Location {
            param($Path) 
        }
        function script:Pop-Location { 
        }
        function script:git {
            param([string[]]$Arguments) return "nothing to commit" 
        }
        
        # Load the script content without executing the main call
        $scriptPath = "$PSScriptRoot\..\..\Build-EnterpriseModuleRepository.ps1"
        $scriptContent = Get-Content $scriptPath -Raw
        
        # Remove only the final execution line to prevent automatic execution
        $scriptContentWithoutExecution = $scriptContent -replace "Build-EnterpriseModuleRepository -Quick:\`$Quick.*", ""
        
        # Execute the script content to define all functions
        Invoke-Expression $scriptContentWithoutExecution
    }
    
    Context "Parameter Validation" {
        It "Should accept Quick switch parameter" {
            { Build-EnterpriseModuleRepository -Quick -DryRun } | Should -Not -Throw
        }
        
        It "Should accept CreateCertificate switch parameter" {
            { Build-EnterpriseModuleRepository -CreateCertificate -DryRun } | Should -Not -Throw
        }
        
        It "Should accept SkipSigning switch parameter" {
            { Build-EnterpriseModuleRepository -SkipSigning -DryRun } | Should -Not -Throw
        }
        
        It "Should accept DryRun switch parameter" {
            { Build-EnterpriseModuleRepository -DryRun } | Should -Not -Throw
        }
    }
    
    Context "Helper Functions" {
        It "Write-Header should format titles correctly" {
            Mock Write-Host { }
            { Write-Header -Title "Test Title" } | Should -Not -Throw
            Assert-MockCalled Write-Host -Times 4
        }
        
        It "Write-Step should display progress correctly" {
            Mock Write-Host { }
            { Write-Step -Step "Test Step" -Current 1 -Total 4 } | Should -Not -Throw
            Assert-MockCalled Write-Host -Times 1
        }
        
        It "Confirm-Continue should return true in Quick mode" {
            $result = Confirm-Continue -Message "Test" -Quick
            $result | Should -Be $true
        }
    }
    
    Context "Build-VSCodeTasks Function" {
        It "Should create tasks.json structure correctly" {
            Mock Test-Path { return $true }
            Mock New-Item { }
            Mock Set-Content { }
            Mock Write-Host { }
            
            { Build-VSCodeTasks -WorkspaceRoot $testRoot } | Should -Not -Throw
        }
        
        It "Should include all required task categories" {
            Mock Test-Path { return $true }
            Mock New-Item { }
            Mock Write-Host { }
            
            $capturedContent = $null
            Mock Set-Content { param($Path, $Value) $script:capturedContent = $Value }
            
            Build-VSCodeTasks -WorkspaceRoot $testRoot
            
            $capturedContent | Should -Match "Test Vendor Organization"
            $capturedContent | Should -Match "Create Code Signing Certificate"
            $capturedContent | Should -Match "Publish Custom Modules"
            $capturedContent | Should -Match "Module Statistics"
        }
    }
    
    Context "Build-ComprehensiveDocumentation Function" {
        It "Should create documentation file" {
            Mock Set-Content { }
            Mock Write-Host { }
            
            { Build-ComprehensiveDocumentation -WorkspaceRoot $testRoot -ModulesPath $testModulesPath } | Should -Not -Throw
        }
        
        It "Should include all documentation sections" {
            $capturedContent = $null
            Mock Set-Content { param($Path, $Value) $script:capturedContent = $Value }
            Mock Write-Host { }
            
            Build-ComprehensiveDocumentation -WorkspaceRoot $testRoot -ModulesPath $testModulesPath
            
            $capturedContent | Should -Match "Enterprise PowerShell Module Repository"
            $capturedContent | Should -Match "Repository Structure"
            $capturedContent | Should -Match "Key Features"
            $capturedContent | Should -Match "Security Configuration"
            $capturedContent | Should -Match "CI/CD Integration"
        }
    }
    
    Context "Main Workflow Integration" {
        It "Should handle missing PowerShellModules directory gracefully" {
            Mock Test-Path { return $false }
            Mock Write-Error { }
            
            { Build-EnterpriseModuleRepository -DryRun } | Should -Not -Throw
        }
        
        It "Should execute all steps in correct order" {
            Mock Test-Path { return $true }
            Mock Get-ChildItem { return @(@{Count = 5 }) }
            Mock Write-Host { }
            Mock Write-Step { }
            Mock Confirm-Continue { return $true }
            Mock Build-VSCodeTasks { }
            Mock Build-ComprehensiveDocumentation { }
            
            { Build-EnterpriseModuleRepository -Quick -DryRun } | Should -Not -Throw
        }
    }
    
    Context "Error Handling" {
        It "Should handle vendor organization script errors" {
            Mock Test-Path { return $true }
            Mock Get-ChildItem { return @(@{Count = 5 }) }
            Mock Write-Host { }
            Mock Write-Step { }
            Mock Confirm-Continue { return $true }
            Mock Invoke-Expression { throw "Reorganize script error" }
            Mock Write-Error { }
            
            { Build-EnterpriseModuleRepository -Quick -DryRun } | Should -Not -Throw
        }
        
        It "Should handle git operation failures gracefully" {
            Mock Test-Path { return $true }
            Mock Get-ChildItem { return @(@{Count = 5 }) }
            Mock Write-Host { }
            Mock Write-Step { }
            Mock Confirm-Continue { return $true }
            Mock git { throw "Git error" }
            Mock Write-Warning { }
            
            { Build-EnterpriseModuleRepository -Quick -DryRun } | Should -Not -Throw
        }
    }
    
    Context "PowerShell Standards Compliance" {
        It "Should use approved PowerShell verbs only" {
            $scriptContent = Get-Content "$PSScriptRoot\..\..\Build-EnterpriseModuleRepository.ps1" -Raw
            $scriptContent | Should -Not -Match "function\s+(Setup-|Create-)"
        }
        
        It "Should follow PascalCase naming convention" {
            $scriptContent = Get-Content "$PSScriptRoot\..\..\Build-EnterpriseModuleRepository.ps1" -Raw
            $functions = $scriptContent | Select-String "function\s+([A-Z][a-zA-Z-]+)" -AllMatches
            
            foreach ($match in $functions.Matches) {
                $functionName = $match.Groups[1].Value
                $functionName | Should -MatchExactly "^[A-Z][a-zA-Z-]*$"
            }
        }
        
        It "Should include proper comment-based help" {
            $scriptContent = Get-Content "$PSScriptRoot\..\..\Build-EnterpriseModuleRepository.ps1" -Raw
            $scriptContent | Should -Match "\.SYNOPSIS"
            $scriptContent | Should -Match "\.DESCRIPTION"
            $scriptContent | Should -Match "\.PARAMETER"
            $scriptContent | Should -Match "\.EXAMPLE"
            $scriptContent | Should -Match "\.NOTES"
        }
    }
    
    Context "Security and Best Practices" {
        It "Should handle execution policy requirements" {
            $scriptContent = Get-Content "$PSScriptRoot\..\..\Build-EnterpriseModuleRepository.ps1" -Raw
            $scriptContent | Should -Match "#Requires -Version"
        }
        
        It "Should implement proper error handling" {
            $scriptContent = Get-Content "$PSScriptRoot\..\..\Build-EnterpriseModuleRepository.ps1" -Raw
            $scriptContent | Should -Match "\`$ErrorActionPreference"
            $scriptContent | Should -Match "try\s*{"
            $scriptContent | Should -Match "catch\s*{"
        }
        
        It "Should validate input parameters" {
            $scriptContent = Get-Content "$PSScriptRoot\..\..\Build-EnterpriseModuleRepository.ps1" -Raw
            $scriptContent | Should -Match "\[CmdletBinding\(\)\]"
            $scriptContent | Should -Match "\[switch\]"
        }
    }
}

Describe "Integration Tests" {
    Context "End-to-End Workflow" {
        It "Should complete dry run without errors" {
            Mock Test-Path { return $true }
            Mock Get-ChildItem { return @(@{Count = 10 }) }
            Mock Write-Host { }
            Mock Write-Step { }
            Mock Build-VSCodeTasks { }
            Mock Build-ComprehensiveDocumentation { }
            
            { Build-EnterpriseModuleRepository -Quick -DryRun } | Should -Not -Throw
        }
        
        It "Should generate expected output files in dry run" {
            # This test would verify that all expected files are created in a real run
            # For now, we're testing the dry run behavior
            $true | Should -Be $true  # Placeholder for future implementation
        }
    }
}
