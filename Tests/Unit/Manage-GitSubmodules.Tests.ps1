<#
.SYNOPSIS
    Pester tests for Manage-GitSubmodules.ps1

.DESCRIPTION
    Comprehensive test suite for the Git submodule management script.
    Tests all major functions and edge cases for proper PowerShell naming conventions.

.NOTES
    Author: PowerShell Development Team
    Version: 1.0.0
    Requires: Pester 5.0+
#>

BeforeAll {
    # Import the script under test (in the parent directory of Tests)
    $scriptPath = Join-Path (Split-Path (Split-Path $PSScriptRoot)) "Manage-GitSubmodules.ps1"
    if (-not (Test-Path $scriptPath)) {
        throw "Cannot find Manage-GitSubmodules.ps1 script at $scriptPath"
    }
    
    # Don't actually execute the script, just dot-source the functions
    $scriptContent = Get-Content $scriptPath -Raw
    $functionPattern = 'function\s+([A-Za-z-]+)\s*\{'
    $functions = [regex]::Matches($scriptContent, $functionPattern) | ForEach-Object { $_.Groups[1].Value }
    
    # Mock external dependencies
    Mock git { return @() } -ModuleName TestModule
    Mock Set-Location { } -ModuleName TestModule
    Mock Get-Location { return "C:\backup\Powershell" } -ModuleName TestModule
}

Describe "Manage-GitSubmodules Script Validation" {
    Context "PowerShell Naming Convention Compliance" {
        It "Should use approved PowerShell verbs in function names" {
            $scriptContent = Get-Content (Join-Path (Split-Path (Split-Path $PSScriptRoot)) "Manage-GitSubmodules.ps1") -Raw
            $functionMatches = [regex]::Matches($scriptContent, 'function\s+([A-Za-z-]+)')
            
            $prohibitedPrefixes = @('Setup-', 'Create-')
            $approvedVerbs = Get-Verb | Select-Object -ExpandProperty Verb
            
            foreach ($match in $functionMatches) {
                $functionName = $match.Groups[1].Value
                
                # Check for prohibited prefixes
                foreach ($prefix in $prohibitedPrefixes) {
                    $functionName | Should -Not -Match "^$prefix" -Because "Function $functionName uses prohibited prefix $prefix"
                }
                
                # Check if verb is approved
                $verb = ($functionName -split '-')[0]
                if ($verb -and $verb -ne 'Invoke') {
                    # Invoke- is commonly used and acceptable
                    $approvedVerbs | Should -Contain $verb -Because "Function $functionName uses unapproved verb '$verb'"
                }
                
                # Check PascalCase format
                $functionName | Should -Match '^[A-Z][a-zA-Z]*-[A-Z][a-zA-Z]*$' -Because "Function $functionName should use PascalCase format"
            }
        }
        
        It "Should not contain Setup- or Create- function prefixes" {
            $scriptContent = Get-Content (Join-Path (Split-Path (Split-Path $PSScriptRoot)) "Manage-GitSubmodules.ps1") -Raw
            $scriptContent | Should -Not -Match 'function\s+Setup-' -Because "Setup- prefix is prohibited"
            $scriptContent | Should -Not -Match 'function\s+Create-' -Because "Create- prefix is prohibited"
        }
        
        It "Should use proper PowerShell parameter naming" {
            $scriptContent = Get-Content (Join-Path (Split-Path (Split-Path $PSScriptRoot)) "Manage-GitSubmodules.ps1") -Raw
            $parameterMatches = [regex]::Matches($scriptContent, '\[Parameter[^\]]*\]\s*\[[\w\[\]]+\]\s*\$(\w+)')
            
            foreach ($match in $parameterMatches) {
                $paramName = $match.Groups[1].Value
                $paramName | Should -Match '^[A-Z][a-zA-Z]*$' -Because "Parameter $paramName should use PascalCase"
            }
        }
    }
    
    Context "Script Structure Validation" {
        It "Should have proper comment-based help" {
            $scriptContent = Get-Content (Join-Path (Split-Path (Split-Path $PSScriptRoot)) "Manage-GitSubmodules.ps1") -Raw
            $scriptContent | Should -Match '\.SYNOPSIS' -Because "Script should have SYNOPSIS section"
            $scriptContent | Should -Match '\.DESCRIPTION' -Because "Script should have DESCRIPTION section"
            $scriptContent | Should -Match '\.PARAMETER' -Because "Script should have PARAMETER documentation"
            $scriptContent | Should -Match '\.EXAMPLE' -Because "Script should have usage examples"
        }
        
        It "Should use proper error handling" {
            $scriptContent = Get-Content (Join-Path (Split-Path (Split-Path $PSScriptRoot)) "Manage-GitSubmodules.ps1") -Raw
            $scriptContent | Should -Match '\$ErrorActionPreference' -Because "Script should set error handling preference"
            $scriptContent | Should -Match 'try\s*\{' -Because "Script should use try-catch blocks"
            $scriptContent | Should -Match 'catch\s*\{' -Because "Script should handle exceptions"
        }
        
        It "Should validate input parameters" {
            $scriptContent = Get-Content (Join-Path (Split-Path (Split-Path $PSScriptRoot)) "Manage-GitSubmodules.ps1") -Raw
            $scriptContent | Should -Match '\[ValidateSet\(' -Because "Script should validate enum parameters"
            $scriptContent | Should -Match '\[CmdletBinding\(\)\]' -Because "Script should use advanced function syntax"
        }
    }
    
    Context "Git Repository Structure Tests" {
        BeforeEach {
            Mock Test-Path { return $true } -ParameterFilter { $Path -like "*\.git*" }
            Mock Test-Path { return $false } -ParameterFilter { $Path -notlike "*\.git*" }
        }
        
        It "Should define proper repository structure" {
            $scriptContent = Get-Content (Join-Path (Split-Path (Split-Path $PSScriptRoot)) "Manage-GitSubmodules.ps1") -Raw
            $scriptContent | Should -Match 'RepoStructure' -Because "Script should define repository structure"
            $scriptContent | Should -Match 'PowerShellModules' -Because "Script should reference PowerShellModules"
            $scriptContent | Should -Match 'gemini-cli' -Because "Script should reference gemini-cli submodule"
            $scriptContent | Should -Match 'opencode' -Because "Script should reference opencode submodule"
            $scriptContent | Should -Match 'PSReadLine' -Because "Script should reference PSReadLine submodule"
        }
        
        It "Should have proper Git remote URLs" {
            $scriptContent = Get-Content (Join-Path (Split-Path (Split-Path $PSScriptRoot)) "Manage-GitSubmodules.ps1") -Raw
            $scriptContent | Should -Match 'github\.com' -Because "Script should reference GitHub remotes"
            $scriptContent | Should -Match 'philipprochazka' -Because "Script should reference user repositories"
        }
    }
    
    Context "Function Implementation Tests" {
        It "Should implement all required functions" {
            $scriptContent = Get-Content (Join-Path (Split-Path (Split-Path $PSScriptRoot)) "Manage-GitSubmodules.ps1") -Raw
            
            # Check for proper function naming following PowerShell conventions
            $scriptContent | Should -Match 'function Initialize-GitSubmodules' -Because "Should have Initialize-GitSubmodules function"
            $scriptContent | Should -Match 'function Update-GitSubmodules' -Because "Should have Update-GitSubmodules function"
            $scriptContent | Should -Match 'function Get-SubmoduleStatus' -Because "Should have Get-SubmoduleStatus function"
            $scriptContent | Should -Match 'function Reset-GitSubmodules' -Because "Should have Reset-GitSubmodules function"
            $scriptContent | Should -Match 'function Sync-UpstreamRepositories' -Because "Should have Sync-UpstreamRepositories function"
        }
        
        It "Should use proper Write-* functions for output" {
            $scriptContent = Get-Content (Join-Path (Split-Path (Split-Path $PSScriptRoot)) "Manage-GitSubmodules.ps1") -Raw
            $scriptContent | Should -Match 'Write-Host' -Because "Script should use Write-Host for user output"
            $scriptContent | Should -Match 'Write-StepInfo' -Because "Script should have custom output functions"
            $scriptContent | Should -Match 'Write-Success' -Because "Script should indicate success states"
            $scriptContent | Should -Match 'Write-Warning' -Because "Script should show warnings"
            $scriptContent | Should -Match 'Write-Error' -Because "Script should handle errors appropriately"
        }
    }
    
    Context "Security and Best Practices" {
        It "Should use secure Git operations" {
            $scriptContent = Get-Content (Join-Path (Split-Path (Split-Path $PSScriptRoot)) "Manage-GitSubmodules.ps1") -Raw
            $scriptContent | Should -Match 'git@github\.com' -Because "Script should use SSH for private repositories"
            $scriptContent | Should -Match 'LASTEXITCODE' -Because "Script should check Git command exit codes"
        }
        
        It "Should implement proper confirmation for destructive operations" {
            $scriptContent = Get-Content (Join-Path (Split-Path (Split-Path $PSScriptRoot)) "Manage-GitSubmodules.ps1") -Raw
            $scriptContent | Should -Match 'Read-Host.*Continue' -Because "Script should confirm destructive operations"
            $scriptContent | Should -Match '\$Force' -Because "Script should have Force parameter for automation"
        }
    }
}

Describe "Integration Tests" {
    Context "Git Submodule File Validation" {
        It "Should create valid .gitmodules file for main repository" {
            $gitmodulesPath = Join-Path (Split-Path (Split-Path $PSScriptRoot)) ".gitmodules"
            if (Test-Path $gitmodulesPath) {
                $content = Get-Content $gitmodulesPath -Raw
                $content | Should -Match '\[submodule "PowerShellModules"\]' -Because ".gitmodules should define PowerShellModules submodule"
                $content | Should -Match 'path = PowerShellModules' -Because ".gitmodules should specify correct path"
                $content | Should -Match 'url = https://github\.com/philipprochazka/PowerShellModules\.git' -Because ".gitmodules should have correct URL"
            }
        }
        
        It "Should create valid .gitmodules file for PowerShellModules" {
            $gitmodulesPath = Join-Path (Split-Path (Split-Path $PSScriptRoot)) "PowerShellModules\.gitmodules"
            if (Test-Path $gitmodulesPath) {
                $content = Get-Content $gitmodulesPath -Raw
                $content | Should -Match '\[submodule "gemini-cli"\]' -Because ".gitmodules should define gemini-cli submodule"
                $content | Should -Match '\[submodule "opencode"\]' -Because ".gitmodules should define opencode submodule"
                $content | Should -Match '\[submodule "PSReadLine"\]' -Because ".gitmodules should define PSReadLine submodule"
            }
        }
    }
    
    Context "Documentation Validation" {
        It "Should have comprehensive Git submodule documentation" {
            $docPath = Join-Path (Split-Path (Split-Path $PSScriptRoot)) "docs\Git-Submodule-Structure.md"
            if (Test-Path $docPath) {
                $content = Get-Content $docPath -Raw
                $content | Should -Match '# Git Submodule Structure Documentation' -Because "Documentation should have proper title"
                $content | Should -Match 'git submodule update --init --recursive' -Because "Documentation should include essential commands"
                $content | Should -Match 'Best Practices' -Because "Documentation should include best practices"
            }
        }
    }
}

Describe "Performance and Efficiency Tests" {
    Context "Script Performance" {
        It "Should not have excessive complexity" {
            $scriptContent = Get-Content (Join-Path $PSScriptRoot "Manage-GitSubmodules.ps1") -Raw
            $lines = ($scriptContent -split "`n").Count
            $lines | Should -BeLessThan 1000 -Because "Script should be maintainable size"
        }
        
        It "Should use efficient PowerShell patterns" {
            $scriptContent = Get-Content (Join-Path $PSScriptRoot "Manage-GitSubmodules.ps1") -Raw
            $scriptContent | Should -Match '\$script:' -Because "Script should use script scope for module variables"
            $scriptContent | Should -Match 'Join-Path' -Because "Script should use Join-Path for cross-platform compatibility"
        }
    }
}

AfterAll {
    # Cleanup any temporary test files or mock states
    Write-Host "Test suite completed for Manage-GitSubmodules.ps1" -ForegroundColor Green
}
