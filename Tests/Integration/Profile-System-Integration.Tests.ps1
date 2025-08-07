# Integration Tests for PowerShell Profile System
# Testing complete profile loading workflows and module interactions

BeforeAll {
    # Test workspace configuration
    $TestWorkspace = "$PSScriptRoot\..\.."
    
    # Define profile paths for testing
    $ProfilePaths = @{
        Dracula          = "$TestWorkspace\Microsoft.PowerShell_profile_Dracula.ps1"
        MCP              = "$TestWorkspace\Microsoft.PowerShell_profile_MCP.ps1"
        UltraPerformance = "$TestWorkspace\Microsoft.PowerShell_profile_Dracula_UltraPerformance.ps1"
    }
    
    # Import required modules
    $ModulePaths = @(
        "$TestWorkspace\PowerShellModules\UnifiedMCPProfile",
        "$TestWorkspace\PowerShellModules\UnifiedPowerShellProfile"
    )
    
    foreach ($ModulePath in $ModulePaths) {
        if (Test-Path $ModulePath) {
            Import-Module $ModulePath -Force -ErrorAction SilentlyContinue
        }
    }
}

Describe "Profile System Integration" -Tag @('Integration', 'Profiles') {
    
    Context "Profile File Availability" {
        It "Should have Dracula profile available" {
            Test-Path $ProfilePaths.Dracula | Should -Be $true
        }
        
        It "Should have MCP profile available" {
            Test-Path $ProfilePaths.MCP | Should -Be $true
        }
        
        It "Should have Ultra Performance profile available" {
            Test-Path $ProfilePaths.UltraPerformance | Should -Be $true
        }
        
        It "Should have valid PowerShell syntax in all profiles" {
            foreach ($ProfileName in $ProfilePaths.Keys) {
                $ProfilePath = $ProfilePaths[$ProfileName]
                if (Test-Path $ProfilePath) {
                    $Content = Get-Content $ProfilePath -Raw
                    { [System.Management.Automation.PSParser]::Tokenize($Content, [ref]$null) } | Should -Not -Throw -Because "Profile $ProfileName should have valid syntax"
                }
            }
        }
    }
    
    Context "Profile Loading Performance" {
        It "Should load Dracula profile within performance threshold (< 2 seconds)" {
            if (Test-Path $ProfilePaths.Dracula) {
                $StartTime = Get-Date
                . $ProfilePaths.Dracula
                $LoadTime = (Get-Date) - $StartTime
                $LoadTime.TotalSeconds | Should -BeLessThan 2
            } else {
                Set-ItResult -Skipped -Because "Dracula profile not found"
            }
        }
        
        It "Should load MCP profile within performance threshold (< 3 seconds)" {
            if (Test-Path $ProfilePaths.MCP) {
                $StartTime = Get-Date
                . $ProfilePaths.MCP
                $LoadTime = (Get-Date) - $StartTime
                $LoadTime.TotalSeconds | Should -BeLessThan 3
            } else {
                Set-ItResult -Skipped -Because "MCP profile not found"
            }
        }
        
        It "Should load Ultra Performance profile within performance threshold (< 1.5 seconds)" {
            if (Test-Path $ProfilePaths.UltraPerformance) {
                $StartTime = Get-Date
                . $ProfilePaths.UltraPerformance
                $LoadTime = (Get-Date) - $StartTime
                $LoadTime.TotalSeconds | Should -BeLessThan 1.5
            } else {
                Set-ItResult -Skipped -Because "Ultra Performance profile not found"
            }
        }
    }
    
    Context "Module Integration" {
        It "Should have UnifiedMCPProfile module functions available after profile load" {
            if (Test-Path $ProfilePaths.MCP) {
                . $ProfilePaths.MCP
                $MCPFunctions = @('Start-ContinuousCleanup', 'Initialize-UnifiedProfile')
                foreach ($Function in $MCPFunctions) {
                    Get-Command $Function -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty -Because "Function $Function should be available"
                }
            } else {
                Set-ItResult -Skipped -Because "MCP profile not found"
            }
        }
        
        It "Should have proper error handling for missing modules" {
            # Test that profiles gracefully handle missing dependencies
            foreach ($ProfilePath in $ProfilePaths.Values) {
                if (Test-Path $ProfilePath) {
                    { . $ProfilePath } | Should -Not -Throw -Because "Profile should handle missing dependencies gracefully"
                }
            }
        }
    }
    
    Context "Environment Configuration" {
        It "Should set up proper PowerShell execution policy" {
            $CurrentPolicy = Get-ExecutionPolicy -Scope CurrentUser
            $CurrentPolicy | Should -BeIn @('RemoteSigned', 'Unrestricted', 'Bypass')
        }
        
        It "Should have PSReadLine configured after profile load" {
            if (Get-Module PSReadLine -ListAvailable) {
                if (Test-Path $ProfilePaths.Dracula) {
                    . $ProfilePaths.Dracula
                    Get-PSReadLineOption | Should -Not -BeNullOrEmpty
                }
            } else {
                Set-ItResult -Skipped -Because "PSReadLine module not available"
            }
        }
    }
    
    Context "Continuous Cleanup Integration" {
        It "Should integrate Start-ContinuousCleanup with profile system" {
            if (Get-Command Start-ContinuousCleanup -ErrorAction SilentlyContinue) {
                { Start-ContinuousCleanup -MaxFilesPerRun 5 -WhatIf } | Should -Not -Throw
            } else {
                Set-ItResult -Skipped -Because "Start-ContinuousCleanup function not available"
            }
        }
        
        It "Should have proper cleanup categories defined" {
            if (Get-Command Start-ContinuousCleanup -ErrorAction SilentlyContinue) {
                $ValidCategories = @('Profiles', 'Documentation', 'Performance', 'Development', 'All')
                foreach ($Category in $ValidCategories) {
                    { Start-ContinuousCleanup -TargetCategories @($Category) -WhatIf } | Should -Not -Throw
                }
            } else {
                Set-ItResult -Skipped -Because "Start-ContinuousCleanup function not available"
            }
        }
    }
}

Describe "VS Code Integration" -Tag @('Integration', 'VSCode') {
    
    Context "Tasks Configuration" {
        It "Should have VS Code tasks.json file" {
            $TasksPath = "$TestWorkspace\.vscode\tasks.json"
            Test-Path $TasksPath | Should -Be $true
        }
        
        It "Should have launch configurations" {
            $LaunchPath = "$TestWorkspace\.vscode\launch.json"
            Test-Path $LaunchPath | Should -Be $true
        }
        
        It "Should have proper PowerShell tasks defined" {
            $TasksPath = "$TestWorkspace\.vscode\tasks.json"
            if (Test-Path $TasksPath) {
                $TasksContent = Get-Content $TasksPath -Raw | ConvertFrom-Json
                $TasksContent.tasks | Should -Not -BeNullOrEmpty
                $TasksContent.tasks.label | Should -Contain "🧪 Run All Unit Tests"
            }
        }
    }
    
    Context "Workspace Configuration" {
        It "Should have PSScriptAnalyzer settings" {
            $AnalyzerSettings = "$TestWorkspace\PSScriptAnalyzerSettings.psd1"
            Test-Path $AnalyzerSettings | Should -Be $true
        }
        
        It "Should have proper workspace settings" {
            $SettingsPath = "$TestWorkspace\.vscode\settings.json"
            if (Test-Path $SettingsPath) {
                { Get-Content $SettingsPath -Raw | ConvertFrom-Json } | Should -Not -Throw
            }
        }
    }
}

Describe "Documentation Integration" -Tag @('Integration', 'Documentation') {
    
    Context "Documentation Structure" {
        It "Should have documentation index" {
            $DocsIndex = "$TestWorkspace\docs\index.md"
            Test-Path $DocsIndex | Should -Be $true
        }
        
        It "Should have function documentation directory" {
            $FunctionDocsPath = "$TestWorkspace\docs\functions"
            Test-Path $FunctionDocsPath | Should -Be $true
        }
        
        It "Should have guides directory" {
            $GuidesPath = "$TestWorkspace\docs\guides"
            Test-Path $GuidesPath | Should -Be $true
        }
        
        It "Should have testing standards documentation" {
            $TestingStandards = "$TestWorkspace\docs\guides\testing-standards.md"
            Test-Path $TestingStandards | Should -Be $true
        }
    }
    
    Context "Function Documentation Coverage" {
        It "Should have documentation for Start-ContinuousCleanup" {
            $FunctionDoc = "$TestWorkspace\docs\functions\Start-ContinuousCleanup.md"
            Test-Path $FunctionDoc | Should -Be $true
        }
    }
}

Describe "Git Integration" -Tag @('Integration', 'Git') {
    
    Context "Repository Structure" {
        It "Should be a git repository" {
            $GitPath = "$TestWorkspace\.git"
            Test-Path $GitPath | Should -Be $true
        }
        
        It "Should have .gitignore file" {
            $GitIgnorePath = "$TestWorkspace\.gitignore"
            Test-Path $GitIgnorePath | Should -Be $true
        }
    }
    
    Context "GitHub Configuration" {
        It "Should have GitHub directory structure" {
            $GitHubPath = "$TestWorkspace\.github"
            Test-Path $GitHubPath | Should -Be $true
        }
        
        It "Should have Copilot instructions" {
            $CopilotInstructions = "$TestWorkspace\.github\copilot-instructions.md"
            Test-Path $CopilotInstructions | Should -Be $true
        }
    }
}

AfterAll {
    # Cleanup: Remove any modules imported for testing
    $TestModules = @('UnifiedMCPProfile', 'UnifiedPowerShellProfile')
    foreach ($Module in $TestModules) {
        Remove-Module $Module -Force -ErrorAction SilentlyContinue
    }
}
