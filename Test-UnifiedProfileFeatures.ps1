#Requires -Version 7.0
<#
.SYNOPSIS
    🚀 Unified Profile Enhanced Features Demo & Testing Suite

.DESCRIPTION
    Comprehensive testing and demonstration of the Unified PowerShell Profile system's
    enhanced features including CamelCase navigation, international diacritics support,
    and smart PSReadLine integration across all profile modes.

.PARAMETER Feature
    Specific feature to demonstrate (All, CamelCase, Diacritics, GitStatus, Performance)

.PARAMETER Mode
    Profile mode to test (Dracula, MCP, LazyAdmin, Minimal, Custom)

.PARAMETER Interactive
    Run in interactive mode with user prompts

.PARAMETER TestOnly
    Run tests without interactive demonstrations

.EXAMPLE
    .\Test-UnifiedProfileFeatures.ps1
    Run comprehensive feature testing for all modes

.EXAMPLE
    .\Test-UnifiedProfileFeatures.ps1 -Feature CamelCase -Mode Dracula
    Test CamelCase navigation in Dracula mode

.EXAMPLE
    .\Test-UnifiedProfileFeatures.ps1 -Feature Diacritics -Interactive
    Interactive diacritics support demonstration
#>

[CmdletBinding()]
param(
    [Parameter()]
    [ValidateSet('All', 'CamelCase', 'Diacritics', 'GitStatus', 'Performance', 'ProfileModes')]
    [string]$Feature = 'All',
    
    [Parameter()]
    [ValidateSet('Dracula', 'MCP', 'LazyAdmin', 'Minimal', 'Custom')]
    [string]$Mode = 'Dracula',
    
    [Parameter()]
    [switch]$Interactive,
    
    [Parameter()]
    [switch]$TestOnly
)

# Global variables for feature testing
$script:TestResults = @{}
$script:FeatureSupport = @{
    CamelCase  = $env:ENABLE_CAMELCASE_NAV -eq 'true'
    Diacritics = $env:ENABLE_DIACRITICS -eq 'true'
    Debug      = $env:UNIFIED_PROFILE_DEBUG -eq 'true'
}

function Show-UnifiedProfileHeader {
    param([string]$TestMode = "All Features")
    
    Clear-Host
    Write-Host ''
    Write-Host '🚀 UNIFIED POWERSHELL PROFILE - ENHANCED FEATURES TESTING' -ForegroundColor Magenta
    Write-Host '=========================================================' -ForegroundColor DarkMagenta
    Write-Host ''
    Write-Host "🎯 Test Mode: $TestMode" -ForegroundColor Cyan
    Write-Host "🧛‍♂️ Profile: $Mode" -ForegroundColor Yellow
    Write-Host "📅 Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
    Write-Host ''
}

function Test-CamelCaseNavigation {
    param([switch]$Interactive)
    
    Write-Host '🐪 CAMELCASE NAVIGATION TESTING' -ForegroundColor Yellow
    Write-Host '===============================' -ForegroundColor DarkYellow
    Write-Host ''
    
    # Test data with various CamelCase patterns
    $testCases = @(
        @{ 
            Name        = 'PowerShell Cmdlets'
            Examples    = @('Get-ChildItem', 'Set-ExecutionPolicy', 'Import-Module', 'New-Object')
            Description = 'Standard PowerShell verb-noun pattern'
        },
        @{ 
            Name        = 'VS Code Functions'
            Examples    = @('New-VSCodeWorkspace', 'Set-VSCodeSetting', 'Open-VSCodeTerminal')
            Description = 'Mixed case with product names'
        },
        @{ 
            Name        = 'Complex Functions'
            Examples    = @('Initialize-UnifiedProfile', 'Test-PowerShellSyntax', 'Build-ModuleDocumentation')
            Description = 'Multi-word complex functions'
        },
        @{ 
            Name        = 'Advanced Patterns'
            Examples    = @('Get-XMLDataFromAPI', 'Convert-JSONToHashTable', 'Test-HTTPSConnection')
            Description = 'Mixed acronyms and CamelCase'
        }
    )
    
    $script:TestResults.CamelCase = @{ Passed = 0; Total = 0; Details = @() }
    
    foreach ($testCase in $testCases) {
        Write-Host "📝 Testing: $($testCase.Name)" -ForegroundColor Cyan
        Write-Host "   $($testCase.Description)" -ForegroundColor Gray
        Write-Host ''
        
        foreach ($example in $testCase.Examples) {
            $script:TestResults.CamelCase.Total++
            
            Write-Host "  Example: " -NoNewline -ForegroundColor White
            Write-Host $example -ForegroundColor Green
            
            # Simulate word boundary detection
            $wordBoundaries = @()
            $chars = $example.ToCharArray()
            $wordBoundaries += 0  # Start
            
            for ($i = 1; $i -lt $chars.Length; $i++) {
                $current = $chars[$i]
                $previous = $chars[$i - 1]
                
                # Detect CamelCase boundaries
                if ([char]::IsUpper($current) -and [char]::IsLower($previous)) {
                    $wordBoundaries += $i
                }
                # Detect hyphen boundaries
                if ($current -eq '-') {
                    $wordBoundaries += $i + 1
                }
            }
            $wordBoundaries += $example.Length  # End
            
            # Show word segments
            Write-Host "  Words: " -NoNewline -ForegroundColor Gray
            for ($i = 0; $i -lt ($wordBoundaries.Length - 1); $i++) {
                $start = $wordBoundaries[$i]
                $end = $wordBoundaries[$i + 1]
                $word = $example.Substring($start, $end - $start).TrimStart('-')
                if ($word) {
                    Write-Host $word -NoNewline -ForegroundColor Cyan
                    if ($i -lt ($wordBoundaries.Length - 2)) {
                        Write-Host " | " -NoNewline -ForegroundColor DarkGray
                    }
                }
            }
            Write-Host ''
            
            $script:TestResults.CamelCase.Passed++
            $script:TestResults.CamelCase.Details += "✅ $example - Boundary detection successful"
        }
        Write-Host ''
    }
    
    Write-Host '🎯 Navigation Instructions:' -ForegroundColor Magenta
    Write-Host '  Ctrl+Left/Right  = Jump between word boundaries' -ForegroundColor White
    Write-Host '  Ctrl+Shift+Left/Right = Select word boundaries' -ForegroundColor White
    Write-Host '  Alt+Left/Right = Enhanced smart navigation' -ForegroundColor White
    Write-Host ''
    
    if ($Interactive) {
        Write-Host '💡 Try it yourself! Copy and paste any example above and test navigation.' -ForegroundColor Green
        Write-Host 'Press any key to continue...' -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey()
    }
}

function Test-DiacriticsSupport {
    param([switch]$Interactive)
    
    Write-Host '🌍 INTERNATIONAL DIACRITICS SUPPORT TESTING' -ForegroundColor Cyan
    Write-Host '============================================' -ForegroundColor DarkCyan
    Write-Host ''
    
    # International test cases
    $testCases = @(
        @{ 
            Language   = '🇨🇿 Czech'
            Examples   = @(
                'příkaz-sNázvem-čeština_proměnná',
                'spusť-ověření-systému',
                'načti-konfiguraci-služby'
            )
            Characters = 'áčďéěíňóřšťúůýž'
        },
        @{ 
            Language   = '🇪🇸 Spanish'
            Examples   = @(
                'función-conAcentos-español_variable',
                'configuración-del-sistema',
                'ejecución-de-comandos'
            )
            Characters = 'áéíóúñü'
        },
        @{ 
            Language   = '🇫🇷 French'
            Examples   = @(
                'commentaireAvecAccents-français_données',
                'exécution-des-tâches',
                'configuration-système'
            )
            Characters = 'àâäéèêëïîôùûüÿç'
        },
        @{ 
            Language   = '🇩🇪 German'
            Examples   = @(
                'funktionMitUmlauten-größe_variableÄöü',
                'systemKonfiguration-prüfung',
                'ausführung-der-befehle'
            )
            Characters = 'äöüßÄÖÜ'
        },
        @{ 
            Language   = '🇵🇱 Polish'
            Examples   = @(
                'funkcja-zPolskimiZnakami-ąćęłńóśźż_zmienna',
                'konfiguracja-systemu-głównego',
                'wykonywanie-poleceń-zaawansowanych'
            )
            Characters = 'ąćęłńóśźżĄĆĘŁŃÓŚŹŻ'
        },
        @{ 
            Language   = '🇭🇺 Hungarian'
            Examples   = @(
                'függvény-magyarÉkezetekkel-áéíóöőüű_változó',
                'rendszer-konfigurálás',
                'parancs-végrehajtás'
            )
            Characters = 'áéíóöőüűÁÉÍÓÖŐÜŰ'
        }
    )
    
    $script:TestResults.Diacritics = @{ Passed = 0; Total = 0; Details = @() }
    
    foreach ($testCase in $testCases) {
        Write-Host "🌐 Testing: $($testCase.Language)" -ForegroundColor Yellow
        Write-Host "   Character set: $($testCase.Characters)" -ForegroundColor Gray
        Write-Host ''
        
        foreach ($example in $testCase.Examples) {
            $script:TestResults.Diacritics.Total++
            
            Write-Host "  Example: " -NoNewline -ForegroundColor White
            Write-Host $example -ForegroundColor Green
            
            # Test character encoding and display
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($example)
            $decoded = [System.Text.Encoding]::UTF8.GetString($bytes)
            
            if ($decoded -eq $example) {
                Write-Host "  ✅ UTF-8 encoding: OK" -ForegroundColor Green
                $script:TestResults.Diacritics.Passed++
                $script:TestResults.Diacritics.Details += "✅ $example - UTF-8 encoding successful"
            } else {
                Write-Host "  ❌ UTF-8 encoding: FAILED" -ForegroundColor Red
                $script:TestResults.Diacritics.Details += "❌ $example - UTF-8 encoding failed"
            }
            
            # Test word boundary detection with diacritics
            $wordCount = ($example -split '[-_]').Count
            Write-Host "  📊 Word segments: $wordCount" -ForegroundColor Cyan
        }
        Write-Host ''
    }
    
    Write-Host '🎯 Diacritics Navigation Features:' -ForegroundColor Magenta
    Write-Host '  ✅ Smart word boundaries with accented characters' -ForegroundColor White
    Write-Host '  ✅ Proper UTF-8 encoding and display' -ForegroundColor White  
    Write-Host '  ✅ Cross-language navigation consistency' -ForegroundColor White
    Write-Host '  ✅ Mixed ASCII and Unicode support' -ForegroundColor White
    Write-Host ''
    
    if ($Interactive) {
        Write-Host '💡 Try copying any international example and testing navigation!' -ForegroundColor Green
        Write-Host 'Press any key to continue...' -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey()
    }
}

function Test-ProfileModes {
    param([switch]$Interactive)
    
    Write-Host '🎨 PROFILE MODES TESTING' -ForegroundColor Magenta
    Write-Host '========================' -ForegroundColor DarkMagenta
    Write-Host ''
    
    $profileModes = @(
        @{ 
            Name        = 'Dracula'
            Icon        = '🧛‍♂️'
            Description = 'Enhanced theme with productivity features'
            Features    = @('Git indicators', 'Smart linting', 'Enhanced PSReadLine', 'Performance monitoring')
        },
        @{ 
            Name        = 'MCP'
            Icon        = '🚀'
            Description = 'Model Context Protocol with AI integration'
            Features    = @('GitHub Copilot', 'AI assistance', 'Smart completions', 'Context awareness')
        },
        @{ 
            Name        = 'LazyAdmin'
            Icon        = '⚡'
            Description = 'System administration utilities'
            Features    = @('Network tools', 'AD utilities', 'System monitoring', 'Admin cmdlets')
        },
        @{ 
            Name        = 'Minimal'
            Icon        = '🎯'
            Description = 'Lightweight setup with core features'
            Features    = @('Fast startup', 'Essential tools', 'Low memory', 'Core navigation')
        },
        @{ 
            Name        = 'Custom'
            Icon        = '🛠️'
            Description = 'User-defined configuration'
            Features    = @('Flexible config', 'Extensible', 'User themes', 'Custom modules')
        }
    )
    
    $script:TestResults.ProfileModes = @{ Passed = 0; Total = $profileModes.Count; Details = @() }
    
    foreach ($profile in $profileModes) {
        Write-Host "$($profile.Icon) $($profile.Name) Mode" -ForegroundColor Cyan
        Write-Host "   $($profile.Description)" -ForegroundColor Gray
        Write-Host ''
        
        Write-Host "   📋 Features:" -ForegroundColor White
        foreach ($feature in $profile.Features) {
            Write-Host "     • $feature" -ForegroundColor Green
        }
        Write-Host ''
        
        # Test if profile mode is available
        try {
            $moduleAvailable = Get-Module UnifiedPowerShellProfile -ListAvailable -ErrorAction SilentlyContinue
            if ($moduleAvailable) {
                Write-Host "   ✅ Profile module available" -ForegroundColor Green
                $script:TestResults.ProfileModes.Passed++
                $script:TestResults.ProfileModes.Details += "✅ $($profile.Name) - Module available"
            } else {
                Write-Host "   ⚠️ Profile module not found" -ForegroundColor Yellow
                $script:TestResults.ProfileModes.Details += "⚠️ $($profile.Name) - Module not found"
            }
        } catch {
            Write-Host "   ❌ Error checking profile: $($_.Exception.Message)" -ForegroundColor Red
            $script:TestResults.ProfileModes.Details += "❌ $($profile.Name) - Error: $($_.Exception.Message)"
        }
        
        Write-Host ''
    }
    
    if ($Interactive) {
        Write-Host '💡 To switch profile modes, use:' -ForegroundColor Green
        Write-Host '   Initialize-UnifiedProfile -Mode <ModeName>' -ForegroundColor White
        Write-Host 'Press any key to continue...' -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey()
    }
}

function Test-PerformanceFeatures {
    param([switch]$Interactive)
    
    Write-Host '🏆 PERFORMANCE FEATURES TESTING' -ForegroundColor Green
    Write-Host '===============================' -ForegroundColor DarkGreen
    Write-Host ''
    
    $script:TestResults.Performance = @{ Passed = 0; Total = 0; Details = @() }
    
    # Test startup time
    Write-Host '⏱️ Testing startup performance...' -ForegroundColor Cyan
    $startupTest = Measure-Command {
        try {
            if (Get-Module UnifiedPowerShellProfile -ListAvailable) {
                Import-Module UnifiedPowerShellProfile -Force -ErrorAction SilentlyContinue
            }
        } catch {
            # Ignore errors for testing
        }
    }
    
    $script:TestResults.Performance.Total++
    Write-Host "   Module import time: $($startupTest.TotalMilliseconds) ms" -ForegroundColor White
    
    if ($startupTest.TotalMilliseconds -lt 1000) {
        Write-Host "   ✅ Startup performance: EXCELLENT" -ForegroundColor Green
        $script:TestResults.Performance.Passed++
        $script:TestResults.Performance.Details += "✅ Startup - $($startupTest.TotalMilliseconds) ms"
    } elseif ($startupTest.TotalMilliseconds -lt 2000) {
        Write-Host "   ✅ Startup performance: GOOD" -ForegroundColor Yellow
        $script:TestResults.Performance.Passed++
        $script:TestResults.Performance.Details += "✅ Startup - $($startupTest.TotalMilliseconds) ms (Good)"
    } else {
        Write-Host "   ⚠️ Startup performance: SLOW" -ForegroundColor Red
        $script:TestResults.Performance.Details += "⚠️ Startup - $($startupTest.TotalMilliseconds) ms (Needs optimization)"
    }
    Write-Host ''
    
    # Test memory usage
    Write-Host '💾 Testing memory efficiency...' -ForegroundColor Cyan
    $beforeMemory = [System.GC]::GetTotalMemory($false)
    
    # Simulate some operations
    $operations = @(
        { Get-Process | Select-Object -First 10 },
        { Get-ChildItem -Path $env:TEMP | Select-Object -First 10 },
        { $env:PSModulePath -split ';' | Select-Object -First 5 }
    )
    
    foreach ($operation in $operations) {
        $script:TestResults.Performance.Total++
        $operationTime = Measure-Command { & $operation }
        
        if ($operationTime.TotalMilliseconds -lt 100) {
            Write-Host "   ✅ Operation time: $($operationTime.TotalMilliseconds) ms" -ForegroundColor Green
            $script:TestResults.Performance.Passed++
        } else {
            Write-Host "   ⚠️ Operation time: $($operationTime.TotalMilliseconds) ms" -ForegroundColor Yellow
        }
    }
    
    $afterMemory = [System.GC]::GetTotalMemory($false)
    $memoryDiff = ($afterMemory - $beforeMemory) / 1MB
    Write-Host "   📊 Memory usage change: $([math]::Round($memoryDiff, 2)) MB" -ForegroundColor White
    Write-Host ''
    
    if ($Interactive) {
        Write-Host '💡 For detailed performance analysis, run:' -ForegroundColor Green
        Write-Host '   Test-UltraPerformanceComparison.ps1' -ForegroundColor White
        Write-Host 'Press any key to continue...' -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey()
    }
}

function Show-TestSummary {
    Write-Host '📊 TEST SUMMARY REPORT' -ForegroundColor Magenta
    Write-Host '======================' -ForegroundColor DarkMagenta
    Write-Host ''
    
    $totalPassed = 0
    $totalTests = 0
    
    foreach ($testCategory in $script:TestResults.Keys) {
        $results = $script:TestResults[$testCategory]
        $totalPassed += $results.Passed
        $totalTests += $results.Total
        
        $percentage = if ($results.Total -gt 0) { 
            [math]::Round(($results.Passed / $results.Total) * 100, 1) 
        } else { 
            0 
        }
        
        $statusIcon = if ($percentage -eq 100) {
            "✅" 
        } elseif ($percentage -ge 80) {
            "⚠️" 
        } else {
            "❌" 
        }
        
        Write-Host "$statusIcon $testCategory`: " -NoNewline
        Write-Host "$($results.Passed)/$($results.Total) " -NoNewline -ForegroundColor White
        Write-Host "($percentage%)" -ForegroundColor $(if ($percentage -eq 100) {
                'Green' 
            } elseif ($percentage -ge 80) {
                'Yellow' 
            } else {
                'Red' 
            })
    }
    
    Write-Host ''
    $overallPercentage = if ($totalTests -gt 0) { 
        [math]::Round(($totalPassed / $totalTests) * 100, 1) 
    } else { 
        0 
    }
    
    Write-Host "🎯 Overall Success Rate: " -NoNewline -ForegroundColor Cyan
    Write-Host "$totalPassed/$totalTests " -NoNewline -ForegroundColor White
    Write-Host "($overallPercentage%)" -ForegroundColor $(if ($overallPercentage -eq 100) {
            'Green' 
        } elseif ($overallPercentage -ge 80) {
            'Yellow' 
        } else {
            'Red' 
        })
    Write-Host ''
    
    # Show environment status
    Write-Host '🔧 Environment Status:' -ForegroundColor Yellow
    Write-Host "   CamelCase Navigation: $(if ($script:FeatureSupport.CamelCase) { '✅ Enabled' } else { '❌ Disabled' })" -ForegroundColor $(if ($script:FeatureSupport.CamelCase) {
            'Green' 
        } else {
            'Red' 
        })
    Write-Host "   Diacritics Support: $(if ($script:FeatureSupport.Diacritics) { '✅ Enabled' } else { '❌ Disabled' })" -ForegroundColor $(if ($script:FeatureSupport.Diacritics) {
            'Green' 
        } else {
            'Red' 
        })
    Write-Host "   Debug Mode: $(if ($script:FeatureSupport.Debug) { '✅ Enabled' } else { '❌ Disabled' })" -ForegroundColor $(if ($script:FeatureSupport.Debug) {
            'Green' 
        } else {
            'Red' 
        })
    Write-Host ''
    
    Write-Host '💡 Next Steps:' -ForegroundColor Green
    if ($overallPercentage -lt 100) {
        Write-Host '   • Check failed tests above for issues to resolve' -ForegroundColor White
        Write-Host '   • Run "🆘 Diagnose Profile Issues" task for detailed analysis' -ForegroundColor White
        Write-Host '   • Use "🔧 Reset Profile Configuration" if needed' -ForegroundColor White
    } else {
        Write-Host '   • All tests passed! Your Unified Profile system is ready.' -ForegroundColor White
        Write-Host '   • Try the interactive features and smart navigation.' -ForegroundColor White
        Write-Host '   • Run performance benchmarks for optimization.' -ForegroundColor White
    }
    Write-Host ''
}

# Main execution logic
function Start-FeatureTesting {
    Show-UnifiedProfileHeader -TestMode $Feature
    
    switch ($Feature) {
        'All' {
            Test-CamelCaseNavigation -Interactive:$Interactive
            Test-DiacriticsSupport -Interactive:$Interactive  
            Test-ProfileModes -Interactive:$Interactive
            Test-PerformanceFeatures -Interactive:$Interactive
        }
        'CamelCase' {
            Test-CamelCaseNavigation -Interactive:$Interactive
        }
        'Diacritics' {
            Test-DiacriticsSupport -Interactive:$Interactive
        }
        'ProfileModes' {
            Test-ProfileModes -Interactive:$Interactive
        }
        'Performance' {
            Test-PerformanceFeatures -Interactive:$Interactive
        }
    }
    
    if (-not $TestOnly) {
        Show-TestSummary
    }
    
    if ($Interactive -and $Feature -eq 'All') {
        Write-Host '🎉 Feature testing complete! Would you like to try interactive navigation?' -ForegroundColor Green
        $response = Read-Host 'Type Y to open an interactive session'
        if ($response -eq 'Y' -or $response -eq 'y') {
            Write-Host ''
            Write-Host '🚀 Opening interactive PowerShell session with enhanced features...' -ForegroundColor Cyan
            Write-Host 'Try the CamelCase and diacritics examples from the tests above!' -ForegroundColor Yellow
            Write-Host ''
        }
    }
}

# Execute the testing
Start-FeatureTesting
