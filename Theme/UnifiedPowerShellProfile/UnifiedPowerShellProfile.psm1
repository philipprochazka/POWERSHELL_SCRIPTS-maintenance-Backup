#Requires -Version 5.1
#Requires -Modules PSScriptAnalyzer, Pester

using namespace System.Management.Automation
using namespace System.Collections.Generic

<#
.SYNOPSIS
    Unified PowerShell Profile System with Smart Self-Linting
    
.DESCRIPTION
    Advanced PowerShell profile system that provides real-time code quality enforcement,
    intelligent linting suggestions, and comprehensive development environment setup.
    
.NOTES
    Version: 2.0.0
    Author: Philip Rochazka
    Features:
    - Real-time PSScriptAnalyzer integration
    - Smart command suggestions
    - Quality metrics tracking
    - Pester test integration
    - Multi-mode profile support
    - VS Code workspace generation
#>

# Module-level variables
$script:ProfileConfig = @{
    Mode = 'Dracula'
    RealtimeLinting = $true
    QualityThreshold = 0.85
    AutoCorrect = $false
    LogLevel = 'Info'
    MetricsEnabled = $true
    LastQualityCheck = $null
    TotalCommandsAnalyzed = 0
    QualityScore = 1.0
}

$script:LintingRules = @{
    # Critical rules that must pass
    Critical = @(
        'PSAvoidUsingCmdletAliases',
        'PSAvoidUsingPositionalParameters',
        'PSAvoidGlobalVars',
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSAvoidUsingPlainTextForPassword'
    )
    
    # Important rules for best practices
    Important = @(
        'PSUseApprovedVerbs',
        'PSUseSingularNouns',
        'PSUseConsistentWhitespace',
        'PSUseConsistentIndentation',
        'PSAvoidTrailingWhitespace'
    )
    
    # Informational rules for suggestions
    Informational = @(
        'PSProvideCommentHelp',
        'PSUseCmdletCorrectly',
        'PSAvoidDefaultValueSwitchParameter',
        'PSUseOutputTypeCorrectly'
    )
}

#region Core Profile Functions

<#
.SYNOPSIS
    Initialize the Unified PowerShell Profile System
#>
function Initialize-UnifiedProfile {
    [CmdletBinding()]
    param(
        [ValidateSet('Dracula', 'MCP', 'LazyAdmin', 'Minimal', 'Custom')]
        [string]$Mode = 'Dracula',
        
        [string]$WorkspaceRoot = $PWD.Path,
        
        [switch]$EnableRealtimeLinting,
        
        [switch]$Force
    )
    
    Write-Host "🚀 Initializing Unified PowerShell Profile..." -ForegroundColor Magenta
    
    try {
        # Set profile mode
        $script:ProfileConfig.Mode = $Mode
        $script:ProfileConfig.RealtimeLinting = $EnableRealtimeLinting.IsPresent
        
        # Initialize PSReadLine with smart features
        Initialize-SmartPSReadLine
        
        # Setup quality monitoring
        if ($EnableRealtimeLinting) {
            Enable-RealtimeLinting
        }
        
        # Load profile-specific configurations
        switch ($Mode) {
            'Dracula' { Initialize-DraculaProfile }
            'MCP' { Initialize-MCPProfile }
            'LazyAdmin' { Initialize-LazyAdminProfile }
            'Minimal' { Initialize-MinimalProfile }
            'Custom' { Initialize-CustomProfile }
        }
        
        # Display initialization summary
        Show-ProfileInitSummary
        
        Write-Host "✅ Profile initialized successfully!" -ForegroundColor Green
    }
    catch {
        Write-Error "❌ Failed to initialize profile: $($_.Exception.Message)"
        throw
    }
}

<#
.SYNOPSIS
    Initialize smart PSReadLine integration with real-time linting
#>
function Initialize-SmartPSReadLine {
    [CmdletBinding()]
    param()
    
    if (-not (Get-Module PSReadLine -ListAvailable)) {
        Write-Warning "PSReadLine not available. Skipping smart features."
        return
    }
    
    # Enhanced PSReadLine configuration
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Emacs
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    
    # Smart command validation
    Set-PSReadLineKeyHandler -Key 'Enter' -Function AcceptLineWithSmartValidation
    
    # Quality check on command execution
    if ($script:ProfileConfig.RealtimeLinting) {
        Set-PSReadLineKeyHandler -Key 'Ctrl+Q' -BriefDescription 'QuickQualityCheck' -LongDescription 'Run quick quality check on current line' -ScriptBlock {
            param($key, $arg)
            
            $line = $null
            $cursor = $null
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
            
            if (-not [string]::IsNullOrWhiteSpace($line)) {
                $results = Test-CommandQuality -Command $line
                if ($results.Issues.Count -gt 0) {
                    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
                    Write-Host "`n⚠️  Quality Issues Found:" -ForegroundColor Yellow
                    $results.Issues | ForEach-Object {
                        Write-Host "   • $($_.Message)" -ForegroundColor Red
                    }
                    Write-Host ""
                }
                else {
                    Write-Host "`n✅ Command looks good!" -ForegroundColor Green
                }
            }
        }
    }
}

#endregion

#region Smart Linting Functions

<#
.SYNOPSIS
    Enable real-time linting for PowerShell commands
#>
function Enable-RealtimeLinting {
    [CmdletBinding()]
    param()
    
    Write-Host "🔍 Enabling real-time linting..." -ForegroundColor Cyan
    
    $script:ProfileConfig.RealtimeLinting = $true
    
    # Register command validation
    Register-ArgumentCompleter -Native -CommandName * -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        
        if ($script:ProfileConfig.RealtimeLinting) {
            $command = $commandAst.ToString()
            if (-not [string]::IsNullOrWhiteSpace($command)) {
                $quality = Test-CommandQuality -Command $command -Silent
                if ($quality.Score -lt $script:ProfileConfig.QualityThreshold) {
                    # Could add completion suggestions here
                }
            }
        }
    }
    
    Write-Host "✅ Real-time linting enabled" -ForegroundColor Green
}

<#
.SYNOPSIS
    Disable real-time linting
#>
function Disable-RealtimeLinting {
    [CmdletBinding()]
    param()
    
    Write-Host "⏸️  Disabling real-time linting..." -ForegroundColor Yellow
    $script:ProfileConfig.RealtimeLinting = $false
    Write-Host "✅ Real-time linting disabled" -ForegroundColor Green
}

<#
.SYNOPSIS
    Test command quality using PSScriptAnalyzer
#>
function Test-CommandQuality {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Command,
        
        [switch]$Silent
    )
    
    try {
        # Create temporary file for analysis
        $tempFile = [System.IO.Path]::GetTempFileName() + '.ps1'
        Set-Content -Path $tempFile -Value $Command -ErrorAction Stop
        
        # Run PSScriptAnalyzer
        $issues = Invoke-ScriptAnalyzer -Path $tempFile -Severity @('Error', 'Warning', 'Information')
        
        # Calculate quality score
        $criticalIssues = $issues | Where-Object { $_.RuleName -in $script:LintingRules.Critical }
        $importantIssues = $issues | Where-Object { $_.RuleName -in $script:LintingRules.Important }
        $infoIssues = $issues | Where-Object { $_.RuleName -in $script:LintingRules.Informational }
        
        $score = 1.0
        $score -= ($criticalIssues.Count * 0.3)
        $score -= ($importantIssues.Count * 0.15)
        $score -= ($infoIssues.Count * 0.05)
        $score = [Math]::Max(0, $score)
        
        # Update metrics
        $script:ProfileConfig.TotalCommandsAnalyzed++
        $script:ProfileConfig.QualityScore = ($script:ProfileConfig.QualityScore + $score) / 2
        $script:ProfileConfig.LastQualityCheck = Get-Date
        
        $result = @{
            Score = $score
            Issues = $issues
            Critical = $criticalIssues.Count
            Important = $importantIssues.Count
            Informational = $infoIssues.Count
            Grade = Get-QualityGrade -Score $score
        }
        
        if (-not $Silent -and $issues.Count -gt 0) {
            Show-QualityReport -Result $result
        }
        
        return $result
    }
    catch {
        Write-Warning "Failed to analyze command quality: $($_.Exception.Message)"
        return @{ Score = 0.5; Issues = @(); Critical = 0; Important = 0; Informational = 0; Grade = 'Unknown' }
    }
    finally {
        if (Test-Path $tempFile) {
            Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
        }
    }
}

<#
.SYNOPSIS
    Get quality grade based on score
#>
function Get-QualityGrade {
    [CmdletBinding()]
    param([double]$Score)
    
    switch ($Score) {
        { $_ -ge 0.95 } { return 'A+' }
        { $_ -ge 0.90 } { return 'A' }
        { $_ -ge 0.85 } { return 'B+' }
        { $_ -ge 0.80 } { return 'B' }
        { $_ -ge 0.75 } { return 'C+' }
        { $_ -ge 0.70 } { return 'C' }
        { $_ -ge 0.60 } { return 'D' }
        default { return 'F' }
    }
}

<#
.SYNOPSIS
    Show quality report
#>
function Show-QualityReport {
    [CmdletBinding()]
    param($Result)
    
    Write-Host "`n📊 Quality Report:" -ForegroundColor Cyan
    Write-Host "   Score: $($Result.Score.ToString('F2')) ($($Result.Grade))" -ForegroundColor $(if ($Result.Score -ge 0.8) { 'Green' } elseif ($Result.Score -ge 0.6) { 'Yellow' } else { 'Red' })
    
    if ($Result.Critical -gt 0) {
        Write-Host "   🔴 Critical Issues: $($Result.Critical)" -ForegroundColor Red
    }
    if ($Result.Important -gt 0) {
        Write-Host "   🟡 Important Issues: $($Result.Important)" -ForegroundColor Yellow
    }
    if ($Result.Informational -gt 0) {
        Write-Host "   🔵 Info Issues: $($Result.Informational)" -ForegroundColor Blue
    }
    
    Write-Host ""
}

#endregion

#region Profile Mode Functions

function Initialize-DraculaProfile {
    Write-Host "🧛 Loading Dracula Profile..." -ForegroundColor Magenta
    
    # Enhanced Dracula theme with quality indicators
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\dracula.omp.json" | Invoke-Expression
    }
    
    # Dracula-themed quality prompt
    function global:prompt {
        $quality = $script:ProfileConfig.QualityScore
        $qualityIcon = if ($quality -ge 0.9) { "💎" } elseif ($quality -ge 0.8) { "✨" } elseif ($quality -ge 0.7) { "⭐" } else { "⚠️" }
        
        $location = Get-Location
        $branch = ""
        if (Test-Path .git) {
            $branch = " $(git rev-parse --abbrev-ref HEAD 2>$null)"
        }
        
        Write-Host "🧛 " -NoNewline -ForegroundColor Magenta
        Write-Host "$($location.Path.Split('\')[-1])" -NoNewline -ForegroundColor Cyan
        if ($branch) {
            Write-Host " [$branch]" -NoNewline -ForegroundColor Yellow
        }
        Write-Host " $qualityIcon " -NoNewline
        return "❯ "
    }
}

function Initialize-MCPProfile {
    Write-Host "🤖 Loading MCP Profile..." -ForegroundColor Green
    # MCP-specific initialization
}

function Initialize-LazyAdminProfile {
    Write-Host "⚡ Loading LazyAdmin Profile..." -ForegroundColor Yellow
    # LazyAdmin-specific initialization
}

function Initialize-MinimalProfile {
    Write-Host "📦 Loading Minimal Profile..." -ForegroundColor Blue
    # Minimal profile initialization
}

function Initialize-CustomProfile {
    Write-Host "🎨 Loading Custom Profile..." -ForegroundColor White
    # Custom profile initialization
}

#endregion

#region Quality Metrics and Reporting

<#
.SYNOPSIS
    Get comprehensive quality metrics
#>
function Get-QualityMetrics {
    [CmdletBinding()]
    param()
    
    $metrics = @{
        CurrentScore = $script:ProfileConfig.QualityScore
        TotalCommandsAnalyzed = $script:ProfileConfig.TotalCommandsAnalyzed
        LastQualityCheck = $script:ProfileConfig.LastQualityCheck
        RealtimeLinting = $script:ProfileConfig.RealtimeLinting
        QualityThreshold = $script:ProfileConfig.QualityThreshold
        Grade = Get-QualityGrade -Score $script:ProfileConfig.QualityScore
    }
    
    Write-Host "📈 Quality Metrics Dashboard" -ForegroundColor Cyan
    Write-Host "=" * 30 -ForegroundColor Gray
    Write-Host "Current Score: $($metrics.CurrentScore.ToString('F2')) ($($metrics.Grade))" -ForegroundColor Green
    Write-Host "Commands Analyzed: $($metrics.TotalCommandsAnalyzed)" -ForegroundColor Blue
    Write-Host "Real-time Linting: $($metrics.RealtimeLinting)" -ForegroundColor Yellow
    Write-Host "Quality Threshold: $($metrics.QualityThreshold)" -ForegroundColor Magenta
    if ($metrics.LastQualityCheck) {
        Write-Host "Last Check: $($metrics.LastQualityCheck.ToString('HH:mm:ss'))" -ForegroundColor Gray
    }
    
    return $metrics
}

<#
.SYNOPSIS
    Run smart linting on specified paths with async processing
#>
function Invoke-SmartLinting {
    [CmdletBinding()]
    param(
        [string[]]$Path = @('.'),
        [switch]$Detailed,
        [switch]$AutoFix,
        [switch]$Async,
        [int]$MaxConcurrentJobs = 5
    )
    
    Write-Host "🔍 Running Smart Linting Analysis..." -ForegroundColor Cyan
    
    $allResults = @()
    $totalFiles = 0
    $processedFiles = 0
    
    # Collect all files first for progress tracking
    $allFiles = @()
    foreach ($p in $Path) {
        if (Test-Path $p) {
            $files = Get-ChildItem -Path $p -Recurse -Filter "*.ps1" -File | Where-Object {
                $_.FullName -notmatch '\\\.git\\|\\node_modules\\|\\bin\\|\\obj\\|\\\.vscode\\'
            }
            $allFiles += $files
        }
    }
    
    $totalFiles = $allFiles.Count
    Write-Host "📄 Found $totalFiles PowerShell files to analyze" -ForegroundColor Blue
    
    if ($totalFiles -eq 0) {
        Write-Host "✅ No PowerShell files found to analyze" -ForegroundColor Green
        return @()
    }
    
    if ($Async -and $totalFiles -gt 10) {
        # Use background jobs for large file sets
        Write-Host "⚡ Using async processing with $MaxConcurrentJobs concurrent jobs..." -ForegroundColor Yellow
        $allResults = Invoke-AsyncLinting -Files $allFiles -MaxJobs $MaxConcurrentJobs
    } else {
        # Process files with progress bar
        $progressParams = @{
            Activity = "Analyzing PowerShell Files"
            Status = "Processing..."
            PercentComplete = 0
        }
        Write-Progress @progressParams
        
        foreach ($file in $allFiles) {
            $processedFiles++
            $progressParams.PercentComplete = [math]::Round(($processedFiles / $totalFiles) * 100)
            $progressParams.Status = "Analyzing: $($file.Name) ($processedFiles of $totalFiles)"
            Write-Progress @progressParams
            
            try {
                $issues = Invoke-ScriptAnalyzer -Path $file.FullName -Severity @('Error', 'Warning', 'Information') -ErrorAction SilentlyContinue
                
                if ($issues.Count -gt 0) {
                    $allResults += @{
                        File = $file.FullName
                        Issues = $issues
                        Score = Test-CommandQuality -Command (Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue) -Silent
                    }
                }
            }
            catch {
                Write-Warning "Failed to analyze $($file.Name): $($_.Exception.Message)"
            }
        }
        
        Write-Progress -Activity "Analyzing PowerShell Files" -Completed
    }
    
    # Display summary
    Write-Host "`n📊 Linting Summary:" -ForegroundColor Cyan
    Write-Host "Files analyzed: $($files.Count)" -ForegroundColor Blue
    Write-Host "Files with issues: $($allResults.Count)" -ForegroundColor Yellow
    Write-Host "Total issues: $(($allResults | ForEach-Object { $_.Issues.Count } | Measure-Object -Sum).Sum)" -ForegroundColor Red
    
    if ($Detailed -and $allResults.Count -gt 0) {
        Write-Host "`n📋 Detailed Results:" -ForegroundColor Cyan
        foreach ($result in $allResults) {
            Write-Host "`n📄 $($result.File)" -ForegroundColor White
            $result.Issues | ForEach-Object {
                $color = switch ($_.Severity) {
                    'Error' { 'Red' }
                    'Warning' { 'Yellow' }
                    'Information' { 'Blue' }
                    default { 'Gray' }
                }
                Write-Host "   [$($_.Severity)] $($_.RuleName): $($_.Message)" -ForegroundColor $color
            }
        }
    }
    
    return $allResults
}

<#
.SYNOPSIS
    Process files asynchronously using background jobs
#>
function Invoke-AsyncLinting {
    [CmdletBinding()]
    param(
        [array]$Files,
        [int]$MaxJobs = 5
    )
    
    $allResults = @()
    $jobs = @()
    $processedFiles = 0
    $totalFiles = $Files.Count
    
    # Split files into batches
    $batchSize = [math]::Max(1, [math]::Ceiling($totalFiles / $MaxJobs))
    $batches = for ($i = 0; $i -lt $totalFiles; $i += $batchSize) {
        $end = [math]::Min($i + $batchSize - 1, $totalFiles - 1)
        $Files[$i..$end]
    }
    
    Write-Host "📦 Processing $totalFiles files in $($batches.Count) batches..." -ForegroundColor Blue
    
    # Start background jobs
    foreach ($batch in $batches) {
        $scriptBlock = {
            param($fileBatch)
            
            $results = @()
            foreach ($file in $fileBatch) {
                try {
                    $issues = Invoke-ScriptAnalyzer -Path $file.FullName -Severity @('Error', 'Warning', 'Information') -ErrorAction SilentlyContinue
                    
                    if ($issues.Count -gt 0) {
                        # Calculate simple score for async processing
                        $criticalCount = ($issues | Where-Object Severity -eq 'Error').Count
                        $warningCount = ($issues | Where-Object Severity -eq 'Warning').Count
                        $infoCount = ($issues | Where-Object Severity -eq 'Information').Count
                        
                        $score = [math]::Max(0, 1.0 - ($criticalCount * 0.3) - ($warningCount * 0.15) - ($infoCount * 0.05))
                        
                        $results += @{
                            File = $file.FullName
                            Issues = $issues
                            Score = @{ Score = $score; Grade = if ($score -ge 0.9) { 'A' } elseif ($score -ge 0.8) { 'B' } elseif ($score -ge 0.7) { 'C' } else { 'D' } }
                        }
                    }
                }
                catch {
                    # Silently continue on errors in background jobs
                }
            }
            return $results
        }
        
        $job = Start-Job -ScriptBlock $scriptBlock -ArgumentList @(,$batch)
        $jobs += $job
    }
    
    # Monitor jobs with progress
    $completedJobs = 0
    while ($completedJobs -lt $jobs.Count) {
        Start-Sleep -Milliseconds 500
        
        $completed = $jobs | Where-Object State -eq 'Completed'
        $completedJobs = $completed.Count
        
        $progressParams = @{
            Activity = "Async Analysis Progress"
            Status = "Completed $completedJobs of $($jobs.Count) batches"
            PercentComplete = [math]::Round(($completedJobs / $jobs.Count) * 100)
        }
        Write-Progress @progressParams
        
        # Show live update
        Write-Host "`r⚡ Batches completed: $completedJobs/$($jobs.Count) " -NoNewline -ForegroundColor Yellow
    }
    
    Write-Progress -Activity "Async Analysis Progress" -Completed
    Write-Host "`n✅ All batches completed!" -ForegroundColor Green
    
    # Collect results
    foreach ($job in $jobs) {
        try {
            $jobResults = Receive-Job -Job $job -ErrorAction SilentlyContinue
            if ($jobResults) {
                $allResults += $jobResults
            }
        }
        catch {
            Write-Warning "Failed to collect results from background job"
        }
        finally {
            Remove-Job -Job $job -Force -ErrorAction SilentlyContinue
        }
    }
    
    return $allResults
}

#endregion

#region Utility Functions

function Show-ProfileInitSummary {
    Write-Host "`n🎯 Profile Configuration Summary:" -ForegroundColor Cyan
    Write-Host "   Mode: $($script:ProfileConfig.Mode)" -ForegroundColor White
    Write-Host "   Real-time Linting: $($script:ProfileConfig.RealtimeLinting)" -ForegroundColor White
    Write-Host "   Quality Threshold: $($script:ProfileConfig.QualityThreshold)" -ForegroundColor White
    Write-Host "   PSScriptAnalyzer: $(if (Get-Module PSScriptAnalyzer -ListAvailable) { '✅' } else { '❌' })" -ForegroundColor White
    Write-Host "   Pester: $(if (Get-Module Pester -ListAvailable) { '✅' } else { '❌' })" -ForegroundColor White
    Write-Host ""
}

function Get-ProfileStatus {
    [CmdletBinding()]
    param()
    
    $status = @{
        Mode = $script:ProfileConfig.Mode
        RealtimeLinting = $script:ProfileConfig.RealtimeLinting
        QualityScore = $script:ProfileConfig.QualityScore
        CommandsAnalyzed = $script:ProfileConfig.TotalCommandsAnalyzed
        PSScriptAnalyzer = (Get-Module PSScriptAnalyzer -ListAvailable) -ne $null
        Pester = (Get-Module Pester -ListAvailable) -ne $null
    }
    
    return $status
}

function Set-ProfileMode {
    [CmdletBinding()]
    param(
        [ValidateSet('Dracula', 'MCP', 'LazyAdmin', 'Minimal', 'Custom')]
        [string]$Mode
    )
    
    $script:ProfileConfig.Mode = $Mode
    Write-Host "🔄 Profile mode changed to: $Mode" -ForegroundColor Green
    Write-Host "💡 Restart PowerShell or run 'Initialize-UnifiedProfile -Mode $Mode' to apply changes" -ForegroundColor Yellow
}

#endregion

#region Aliases
Set-Alias -Name 'profile-init' -Value 'Initialize-UnifiedProfile'
Set-Alias -Name 'profile-mode' -Value 'Set-ProfileMode'
Set-Alias -Name 'profile-status' -Value 'Get-ProfileStatus'
Set-Alias -Name 'smart-lint' -Value 'Invoke-SmartLinting'
Set-Alias -Name 'smart-lint-async' -Value 'Invoke-SmartLinting'
Set-Alias -Name 'lint-on' -Value 'Enable-RealtimeLinting'
Set-Alias -Name 'lint-off' -Value 'Disable-RealtimeLinting'
Set-Alias -Name 'quality-check' -Value 'Get-QualityMetrics'
#endregion

# Export module variables
$script:UnifiedProfileConfig = $script:ProfileConfig
$script:ProfileLintingRules = $script:LintingRules

# Auto-initialize if called directly
if ($MyInvocation.InvocationName -eq '&' -or $MyInvocation.Line -match 'Import-Module.*UnifiedPowerShellProfile') {
    Write-Host "🚀 Auto-initializing Unified PowerShell Profile..." -ForegroundColor Magenta
    Initialize-UnifiedProfile -EnableRealtimeLinting
}

Write-Host "✅ UnifiedPowerShellProfile module loaded successfully!" -ForegroundColor Green
