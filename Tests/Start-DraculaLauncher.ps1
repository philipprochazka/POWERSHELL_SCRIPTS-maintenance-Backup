# ===================================================================
# 🧛‍♂️ DRACULA PROFILE LAUNCHER 🧛‍♂️
# Interactive launcher for testing different profile scenarios
# ===================================================================

param(
    [ValidateSet('Normal', 'Clean', 'Debug', 'Performance', 'Minimal')]
    [string]$Mode = 'Normal',
    [switch]$NoExit,
    [switch]$Verbose
)

function Start-DraculaSession {
    param(
        [string]$LaunchMode,
        [bool]$StayOpen = $false
    )
    
    $profilePath = Join-Path $PSScriptRoot "..\Microsoft.PowerShell_profile_Dracula.ps1"
    
    switch ($LaunchMode) {
        'Normal' {
            Write-Host "🧛‍♂️ Launching Normal Dracula Session..." -ForegroundColor Magenta
            $args = @('-NoLogo', '-ExecutionPolicy', 'Bypass')
            if ($StayOpen) { $args += '-NoExit' }
            $args += '-Command', ". '$profilePath'"
        }
        
        'Clean' {
            Write-Host "🧹 Launching Clean Session (No Modules)..." -ForegroundColor Cyan
            $args = @('-NoLogo', '-NoProfile', '-ExecutionPolicy', 'Bypass')
            if ($StayOpen) { $args += '-NoExit' }
            $args += '-Command', ". '$profilePath'"
        }
        
        'Debug' {
            Write-Host "🐛 Launching Debug Session..." -ForegroundColor Yellow
            $args = @('-NoLogo', '-ExecutionPolicy', 'Bypass')
            if ($StayOpen) { $args += '-NoExit' }
            $args += '-Command', "`$VerbosePreference = 'Continue'; . '$profilePath'"
        }
        
        'Performance' {
            Write-Host "⚡ Launching Performance Test Session..." -ForegroundColor Green
            $args = @('-NoLogo', '-ExecutionPolicy', 'Bypass')
            if ($StayOpen) { $args += '-NoExit' }
            $args += '-Command', @"
`$profileStartTime = Get-Date
. '$profilePath'
`$profileEndTime = Get-Date
`$loadTime = (`$profileEndTime - `$profileStartTime).TotalMilliseconds
Write-Host "⚡ Profile loaded in `$([math]::Round(`$loadTime, 2))ms" -ForegroundColor Green
"@
        }
        
        'Minimal' {
            Write-Host "🎯 Launching Minimal Session..." -ForegroundColor Blue
            $args = @('-NoLogo', '-ExecutionPolicy', 'Bypass')
            if ($StayOpen) { $args += '-NoExit' }
            $args += '-Command', @"
# Load only essential parts
`$Host.UI.RawUI.WindowTitle = "🧛‍♂️ Dracula PowerShell (Minimal) 🧛‍♂️"
Write-Host "🧛‍♂️ Minimal Dracula Session Active" -ForegroundColor Magenta
Set-Alias -Name colors -Value { Write-Host "Dracula Colors Available!" -ForegroundColor Magenta }
"@
        }
    }
    
    if ($Verbose) {
        Write-Host "Executing: pwsh $($args -join ' ')" -ForegroundColor Gray
    }
    
    Start-Process -FilePath 'pwsh' -ArgumentList $args -Wait:$false
}

function Show-LauncherMenu {
    Clear-Host
    Write-Host ""
    Write-Host "🧛‍♂️ DRACULA PROFILE LAUNCHER 🧛‍♂️" -ForegroundColor Magenta
    Write-Host "====================================" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "Choose a launch mode:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. 🧛‍♂️ Normal     - Full Dracula experience" -ForegroundColor White
    Write-Host "2. 🧹 Clean      - No existing modules" -ForegroundColor White
    Write-Host "3. 🐛 Debug      - Verbose output enabled" -ForegroundColor White
    Write-Host "4. ⚡ Performance - Time the profile loading" -ForegroundColor White
    Write-Host "5. 🎯 Minimal    - Essential features only" -ForegroundColor White
    Write-Host "6. 🧪 Test       - Run profile tests" -ForegroundColor White
    Write-Host "7. 📊 Benchmark  - Performance comparison" -ForegroundColor White
    Write-Host "8. 🚪 Exit       - Close launcher" -ForegroundColor White
    Write-Host ""
    
    $choice = Read-Host "Enter your choice (1-8)"
    
    switch ($choice) {
        '1' { Start-DraculaSession -LaunchMode 'Normal' -StayOpen $NoExit }
        '2' { Start-DraculaSession -LaunchMode 'Clean' -StayOpen $NoExit }
        '3' { Start-DraculaSession -LaunchMode 'Debug' -StayOpen $NoExit }
        '4' { Start-DraculaSession -LaunchMode 'Performance' -StayOpen $NoExit }
        '5' { Start-DraculaSession -LaunchMode 'Minimal' -StayOpen $NoExit }
        '6' { Invoke-ProfileTests }
        '7' { Invoke-Benchmark }
        '8' { Write-Host "🌙 Farewell, creature of the night!" -ForegroundColor Magenta; exit }
        default { 
            Write-Host "❌ Invalid choice. Please try again." -ForegroundColor Red
            Start-Sleep 2
            Show-LauncherMenu
        }
    }
}

function Invoke-ProfileTests {
    Write-Host ""
    Write-Host "🧪 Running Dracula Profile Tests..." -ForegroundColor Cyan
    
    $testScript = Join-Path $PSScriptRoot "Test-DraculaProfile.ps1"
    if (Test-Path $testScript) {
        & $testScript -GenerateReport
    }
    else {
        Write-Host "❌ Test script not found at: $testScript" -ForegroundColor Red
    }
    
    Write-Host ""
    Read-Host "Press Enter to return to menu"
    Show-LauncherMenu
}

function Invoke-Benchmark {
    Write-Host ""
    Write-Host "📊 Running Performance Benchmark..." -ForegroundColor Cyan
    
    $iterations = 5
    $results = @()
    
    for ($i = 1; $i -le $iterations; $i++) {
        Write-Progress -Activity "Benchmarking" -Status "Iteration $i of $iterations" -PercentComplete (($i / $iterations) * 100)
        
        $testScript = @"
`$start = Get-Date
. '$PSScriptRoot\..\Microsoft.PowerShell_profile_Dracula.ps1'
`$end = Get-Date
(`$end - `$start).TotalMilliseconds
"@
        
        try {
            $loadTime = pwsh -Command $testScript 2>$null
            if ($loadTime -match '^\d+(\.\d+)?$') {
                $results += [double]$loadTime
            }
        }
        catch {
            Write-Host "⚠️ Error in iteration $i" -ForegroundColor Yellow
        }
    }
    
    Write-Progress -Completed
    
    if ($results.Count -gt 0) {
        $stats = $results | Measure-Object -Average -Minimum -Maximum
        
        Write-Host ""
        Write-Host "📊 Benchmark Results:" -ForegroundColor Green
        Write-Host "  Average: $([math]::Round($stats.Average, 2))ms" -ForegroundColor Yellow
        Write-Host "  Minimum: $([math]::Round($stats.Minimum, 2))ms" -ForegroundColor Green
        Write-Host "  Maximum: $([math]::Round($stats.Maximum, 2))ms" -ForegroundColor Red
        Write-Host "  Samples: $($results.Count)" -ForegroundColor Cyan
        
        if ($stats.Average -lt 1000) {
            Write-Host "🚀 Excellent performance!" -ForegroundColor Green
        }
        elseif ($stats.Average -lt 2000) {
            Write-Host "✅ Good performance" -ForegroundColor Yellow
        }
        else {
            Write-Host "⚠️ Consider optimizing the profile" -ForegroundColor Red
        }
    }
    else {
        Write-Host "❌ No valid results obtained" -ForegroundColor Red
    }
    
    Write-Host ""
    Read-Host "Press Enter to return to menu"
    Show-LauncherMenu
}

# Main execution
if ($Mode -ne 'Normal' -or $PSBoundParameters.Count -gt 0) {
    # Direct launch mode
    Start-DraculaSession -LaunchMode $Mode -StayOpen $NoExit
}
else {
    # Interactive menu
    Show-LauncherMenu
}
