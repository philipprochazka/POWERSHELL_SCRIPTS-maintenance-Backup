# Comprehensive System Validation Tests
# Enterprise-grade validation for the complete PowerShell workspace

BeforeAll {
    # System validation configuration
    $WorkspaceRoot = "$PSScriptRoot\..\.."
    $RequiredStructure = @{
        Directories = @(
            '.vscode',
            'docs',
            'docs\functions',
            'docs\guides',
            'Tests',
            'Tests\Unit',
            'Tests\Integration', 
            'Tests\Performance',
            'Tests\Reports',
            'PowerShellModules'
        )
        Files       = @(
            '.vscode\tasks.json',
            '.vscode\launch.json',
            '.vscode\settings.json',
            'docs\index.md',
            'docs\guides\testing-standards.md',
            'docs\guides\naming-conventions.md',
            'PSScriptAnalyzerSettings.psd1'
        )
    }
    
    # Quality standards
    $QualityStandards = @{
        MinimumTestCoverage        = 80
        MaximumProfileLoadTime     = 2.0
        MaximumTestExecutionTime   = 60.0
        MaximumAnalysisTime        = 30.0
        RequiredDocumentationFiles = 5
    }
}

Describe "Enterprise Workspace Validation" -Tag @('System', 'Validation', 'Enterprise') {
    
    Context "Directory Structure Compliance" {
        It "Should have all required directories" {
            foreach ($Directory in $RequiredStructure.Directories) {
                $FullPath = Join-Path $WorkspaceRoot $Directory
                Test-Path $FullPath | Should -Be $true -Because "Directory $Directory is required for enterprise workspace"
            }
        }
        
        It "Should have all required configuration files" {
            foreach ($File in $RequiredStructure.Files) {
                $FullPath = Join-Path $WorkspaceRoot $File
                Test-Path $FullPath | Should -Be $true -Because "File $File is required for enterprise workspace"
            }
        }
        
        It "Should have proper test directory structure" {
            $TestDirectories = @('Unit', 'Integration', 'Performance', 'Reports')
            foreach ($TestDir in $TestDirectories) {
                $TestPath = Join-Path $WorkspaceRoot "Tests\$TestDir"
                Test-Path $TestPath | Should -Be $true -Because "Test directory $TestDir is required"
            }
        }
    }
    
    Context "PowerShell Standards Compliance" {
        It "Should not have any Setup-* function violations" {
            $ViolationCount = 0
            $ViolatingFiles = @()
            
            Get-ChildItem -Path $WorkspaceRoot -Filter "*.ps1" -Recurse | ForEach-Object {
                $Content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
                if ($Content -and $Content -match 'function\s+Setup-\w+') {
                    $ViolationCount++
                    $ViolatingFiles += $_.FullName
                }
            }
            
            $ViolationCount | Should -Be 0 -Because "Setup-* functions are prohibited. Violations found in: $($ViolatingFiles -join ', ')"
        }
        
        It "Should not have any Create-* function violations" {
            $ViolationCount = 0
            $ViolatingFiles = @()
            
            Get-ChildItem -Path $WorkspaceRoot -Filter "*.ps1" -Recurse | ForEach-Object {
                $Content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
                if ($Content -and $Content -match 'function\s+Create-\w+') {
                    $ViolationCount++
                    $ViolatingFiles += $_.FullName
                }
            }
            
            $ViolationCount | Should -Be 0 -Because "Create-* functions are prohibited. Violations found in: $($ViolatingFiles -join ', ')"
        }
        
        It "Should use only PowerShell approved verbs" {
            $ApprovedVerbs = (Get-Verb).Verb
            $CustomFunctions = @()
            
            Get-ChildItem -Path $WorkspaceRoot -Filter "*.ps1" -Recurse | ForEach-Object {
                $Content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
                if ($Content) {
                    $Matches = [regex]::Matches($Content, 'function\s+([A-Za-z]+)-\w+')
                    foreach ($Match in $Matches) {
                        $Verb = $Match.Groups[1].Value
                        if ($Verb -notin $ApprovedVerbs) {
                            $CustomFunctions += "$($_.Name): $($Match.Groups[0].Value)"
                        }
                    }
                }
            }
            
            $CustomFunctions.Count | Should -Be 0 -Because "All functions must use PowerShell approved verbs. Non-approved verbs found: $($CustomFunctions -join ', ')"
        }
        
        It "Should have valid PowerShell syntax in all files" {
            $SyntaxErrors = @()
            
            Get-ChildItem -Path $WorkspaceRoot -Filter "*.ps1" -Recurse | ForEach-Object {
                try {
                    $null = [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$null, [ref]$null)
                } catch {
                    $SyntaxErrors += "$($_.Name): $($_.Exception.Message)"
                }
            }
            
            $SyntaxErrors.Count | Should -Be 0 -Because "All PowerShell files must have valid syntax. Errors found: $($SyntaxErrors -join '; ')"
        }
    }
    
    Context "Documentation Standards Compliance" {
        It "Should have comprehensive documentation index" {
            $IndexPath = Join-Path $WorkspaceRoot "docs\index.md"
            $IndexContent = Get-Content $IndexPath -Raw
            
            $RequiredSections = @('Quick Navigation', 'Function Documentation', 'Development Guides', 'Project Structure')
            foreach ($Section in $RequiredSections) {
                $IndexContent | Should -Match $Section -Because "Documentation index must contain $Section section"
            }
        }
        
        It "Should have testing standards documentation" {
            $TestingStandardsPath = Join-Path $WorkspaceRoot "docs\guides\testing-standards.md"
            $TestingContent = Get-Content $TestingStandardsPath -Raw
            
            $RequiredConcepts = @('Pester', 'PSScriptAnalyzer', 'Code Coverage', 'Performance Tests')
            foreach ($Concept in $RequiredConcepts) {
                $TestingContent | Should -Match $Concept -Because "Testing standards must cover $Concept"
            }
        }
        
        It "Should have naming conventions documentation" {
            $NamingConventionsPath = Join-Path $WorkspaceRoot "docs\guides\naming-conventions.md"
            $NamingContent = Get-Content $NamingConventionsPath -Raw
            
            $RequiredGuidelines = @('Install-', 'Build-', 'New-', 'Initialize-', 'Setup-.*prohibited', 'Create-.*prohibited')
            foreach ($Guideline in $RequiredGuidelines) {
                $NamingContent | Should -Match $Guideline -Because "Naming conventions must include $Guideline guidelines"
            }
        }
        
        It "Should have minimum required documentation files" {
            $DocumentationFiles = Get-ChildItem -Path (Join-Path $WorkspaceRoot "docs") -Filter "*.md" -Recurse
            $DocumentationFiles.Count | Should -BeGreaterOrEqual $QualityStandards.RequiredDocumentationFiles -Because "Minimum documentation coverage required"
        }
    }
    
    Context "VS Code Integration Compliance" {
        It "Should have comprehensive VS Code tasks" {
            $TasksPath = Join-Path $WorkspaceRoot ".vscode\tasks.json"
            $TasksContent = Get-Content $TasksPath -Raw | ConvertFrom-Json
            
            $RequiredTaskTypes = @('test', 'build')
            $AvailableGroups = $TasksContent.tasks | Where-Object { $_.group } | ForEach-Object { 
                if ($_.group -is [string]) {
                    $_.group 
                } else {
                    $_.group.kind 
                } 
            } | Sort-Object -Unique
            
            foreach ($TaskType in $RequiredTaskTypes) {
                $AvailableGroups | Should -Contain $TaskType -Because "VS Code tasks must include $TaskType group"
            }
        }
        
        It "Should have testing launch configurations" {
            $LaunchPath = Join-Path $WorkspaceRoot ".vscode\launch.json"
            $LaunchContent = Get-Content $LaunchPath -Raw | ConvertFrom-Json
            
            $TestingConfigs = $LaunchContent.configurations | Where-Object { $_.name -match 'Test|test' }
            $TestingConfigs.Count | Should -BeGreaterThan 0 -Because "Launch configurations must include testing setups"
        }
        
        It "Should have PSScriptAnalyzer integration" {
            $TasksPath = Join-Path $WorkspaceRoot ".vscode\tasks.json"
            $TasksContent = Get-Content $TasksPath -Raw
            
            $TasksContent | Should -Match 'PSScriptAnalyzer|Invoke-ScriptAnalyzer' -Because "VS Code tasks must include PSScriptAnalyzer integration"
        }
        
        It "Should have proper problem matchers configured" {
            $TasksPath = Join-Path $WorkspaceRoot ".vscode\tasks.json"
            $TasksContent = Get-Content $TasksPath -Raw | ConvertFrom-Json
            
            $ProblemsMatchers = $TasksContent.tasks | Where-Object { $_.problemMatcher } | Measure-Object
            $ProblemsMatchers.Count | Should -BeGreaterThan 0 -Because "Tasks should have problem matchers for error detection"
        }
    }
    
    Context "Testing Infrastructure Compliance" {
        It "Should have unit test files" {
            $UnitTestPath = Join-Path $WorkspaceRoot "Tests\Unit"
            $UnitTestFiles = Get-ChildItem -Path $UnitTestPath -Filter "*.Tests.ps1" -ErrorAction SilentlyContinue
            $UnitTestFiles.Count | Should -BeGreaterThan 0 -Because "Unit tests are required for enterprise workspace"
        }
        
        It "Should have integration test files" {
            $IntegrationTestPath = Join-Path $WorkspaceRoot "Tests\Integration"
            $IntegrationTestFiles = Get-ChildItem -Path $IntegrationTestPath -Filter "*.Tests.ps1" -ErrorAction SilentlyContinue
            $IntegrationTestFiles.Count | Should -BeGreaterThan 0 -Because "Integration tests are required for enterprise workspace"
        }
        
        It "Should have performance test files" {
            $PerformanceTestPath = Join-Path $WorkspaceRoot "Tests\Performance"
            $PerformanceTestFiles = Get-ChildItem -Path $PerformanceTestPath -Filter "*.Tests.ps1" -ErrorAction SilentlyContinue
            $PerformanceTestFiles.Count | Should -BeGreaterThan 0 -Because "Performance tests are required for enterprise workspace"
        }
        
        It "Should have test reports directory" {
            $ReportsPath = Join-Path $WorkspaceRoot "Tests\Reports"
            Test-Path $ReportsPath | Should -Be $true -Because "Test reports directory is required for tracking"
        }
    }
    
    Context "Code Quality Standards" {
        It "Should have PSScriptAnalyzer configuration" {
            $AnalyzerConfigPath = Join-Path $WorkspaceRoot "PSScriptAnalyzerSettings.psd1"
            Test-Path $AnalyzerConfigPath | Should -Be $true -Because "PSScriptAnalyzer configuration is required"
            
            # Validate configuration is parseable
            { Import-PowerShellDataFile $AnalyzerConfigPath } | Should -Not -Throw -Because "PSScriptAnalyzer config must be valid"
        }
        
        It "Should pass PSScriptAnalyzer analysis (if available)" {
            if (Get-Command Invoke-ScriptAnalyzer -ErrorAction SilentlyContinue) {
                $AnalysisResults = Invoke-ScriptAnalyzer -Path $WorkspaceRoot -Recurse -Settings (Join-Path $WorkspaceRoot "PSScriptAnalyzerSettings.psd1")
                $ErrorCount = ($AnalysisResults | Where-Object { $_.Severity -eq 'Error' }).Count
                $ErrorCount | Should -Be 0 -Because "Code should pass PSScriptAnalyzer without errors"
            } else {
                Set-ItResult -Skipped -Because "PSScriptAnalyzer not available"
            }
        }
        
        It "Should have proper error handling in functions" {
            $FunctionsWithoutErrorHandling = @()
            
            Get-ChildItem -Path $WorkspaceRoot -Filter "*.ps1" -Recurse | ForEach-Object {
                $Content = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue
                if ($Content -and $Content -match 'function\s+\w+-\w+') {
                    if ($Content -notmatch 'try\s*{|catch\s*{|\$ErrorActionPreference|\[CmdletBinding\(\)]') {
                        $FunctionsWithoutErrorHandling += $_.Name
                    }
                }
            }
            
            $FunctionsWithoutErrorHandling.Count | Should -BeLessThan 5 -Because "Most functions should have proper error handling"
        }
    }
    
    Context "Module Integration Standards" {
        It "Should have proper module structure (if modules exist)" {
            $ModulesPath = Join-Path $WorkspaceRoot "PowerShellModules"
            if (Test-Path $ModulesPath) {
                $ModuleFolders = Get-ChildItem -Path $ModulesPath -Directory
                foreach ($ModuleFolder in $ModuleFolders) {
                    $ManifestPath = Join-Path $ModuleFolder.FullName "$($ModuleFolder.Name).psd1"
                    if (Test-Path $ManifestPath) {
                        { Test-ModuleManifest $ManifestPath } | Should -Not -Throw -Because "Module manifest $($ModuleFolder.Name) should be valid"
                    }
                }
            }
        }
        
        It "Should have proper module exports (if modules exist)" {
            $ModulesPath = Join-Path $WorkspaceRoot "PowerShellModules"
            if (Test-Path $ModulesPath) {
                $ModuleFolders = Get-ChildItem -Path $ModulesPath -Directory
                foreach ($ModuleFolder in $ModuleFolders) {
                    $ManifestPath = Join-Path $ModuleFolder.FullName "$($ModuleFolder.Name).psd1"
                    if (Test-Path $ManifestPath) {
                        $Manifest = Import-PowerShellDataFile $ManifestPath
                        $Manifest.FunctionsToExport | Should -Not -BeNullOrEmpty -Because "Module $($ModuleFolder.Name) should export functions"
                    }
                }
            }
        }
    }
}

Describe "Performance Validation" -Tag @('Performance', 'System') {
    
    Context "System Performance Standards" {
        It "Should complete all unit tests within time limit" {
            $UnitTestPath = Join-Path $WorkspaceRoot "Tests\Unit"
            if ((Get-ChildItem -Path $UnitTestPath -Filter "*.Tests.ps1" -ErrorAction SilentlyContinue).Count -gt 0) {
                $StartTime = Get-Date
                $null = Invoke-Pester -Path $UnitTestPath -PassThru -Show None
                $ExecutionTime = ((Get-Date) - $StartTime).TotalSeconds
                $ExecutionTime | Should -BeLessThan $QualityStandards.MaximumTestExecutionTime -Because "Unit tests should execute quickly"
            } else {
                Set-ItResult -Skipped -Because "No unit tests found"
            }
        }
        
        It "Should complete PSScriptAnalyzer analysis within time limit (if available)" {
            if (Get-Command Invoke-ScriptAnalyzer -ErrorAction SilentlyContinue) {
                $StartTime = Get-Date
                $null = Invoke-ScriptAnalyzer -Path $WorkspaceRoot -Recurse
                $AnalysisTime = ((Get-Date) - $StartTime).TotalSeconds
                $AnalysisTime | Should -BeLessThan $QualityStandards.MaximumAnalysisTime -Because "Code analysis should be efficient"
            } else {
                Set-ItResult -Skipped -Because "PSScriptAnalyzer not available"
            }
        }
    }
}

AfterAll {
    # Generate comprehensive validation report
    $ValidationReport = @{
        Timestamp         = Get-Date
        WorkspacePath     = $WorkspaceRoot
        QualityStandards  = $QualityStandards
        PowerShellVersion = $PSVersionTable.PSVersion.ToString()
        ValidationStatus  = "Complete"
    }
    
    $ReportPath = Join-Path $WorkspaceRoot "Tests\Reports\workspace-validation-report.json"
    New-Item -Path (Split-Path $ReportPath -Parent) -ItemType Directory -Force -ErrorAction SilentlyContinue
    $ValidationReport | ConvertTo-Json -Depth 3 | Out-File -FilePath $ReportPath -Force
    
    Write-Host "📊 Workspace validation report saved to: $ReportPath" -ForegroundColor Green
}
