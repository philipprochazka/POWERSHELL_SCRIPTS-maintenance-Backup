# Quick Start - Continuous Repository Maintenance
# UnifiedMCPProfile Enhanced System

Write-Host "🚀 Quick Start - Continuous Repository Maintenance" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor DarkCyan

# Import the UnifiedMCPProfile module
try {
    Import-Module .\PowerShellModules\UnifiedMCPProfile -Force
    Write-Host "✅ UnifiedMCPProfile module loaded" -ForegroundColor Green
} catch {
    Write-Error "Failed to load UnifiedMCPProfile module: $($_.Exception.Message)"
    exit 1
}

# Display current repository status
Write-Host "`n📊 Current Repository Status:" -ForegroundColor Yellow
$gitStatus = git status --porcelain 2>$null
$stashList = git stash list 2>$null

Write-Host "   Modified files: $(($gitStatus | Where-Object { $_ -match '^\s*M' }).Count)" -ForegroundColor Gray
Write-Host "   New files: $(($gitStatus | Where-Object { $_ -match '^\?\?' }).Count)" -ForegroundColor Gray
Write-Host "   Stashes: $(($stashList | Measure-Object).Count)" -ForegroundColor Gray

# Get clutter file counts
$summaryFiles = Get-ChildItem -Path "*SUMMARY*", "*COMPLETE*", "*MILESTONE*" -File -ErrorAction SilentlyContinue
$perfReports = Get-ChildItem -Path "UltraPerformance-Comparison-*.html" -File -ErrorAction SilentlyContinue
$profileFiles = Get-ChildItem -Path "Microsoft.PowerShell_profile*.ps1" -File -ErrorAction SilentlyContinue | 
Where-Object { $_.Name -notmatch "profile_Dracula\.ps1$" -and $_.Name -notmatch "profile_MCP\.ps1$" }

Write-Host "   Documentation clutter: $($summaryFiles.Count)" -ForegroundColor Gray
Write-Host "   Performance reports: $($perfReports.Count)" -ForegroundColor Gray
Write-Host "   Legacy profiles: $($profileFiles.Count)" -ForegroundColor Gray

# Present options
Write-Host "`n🎯 Quick Start Options:" -ForegroundColor Magenta
Write-Host ""
Write-Host "1. 🧹 Quick Cleanup (15 files)" -ForegroundColor Green
Write-Host "   Clean up repository in small batches with auto-commit"
Write-Host ""
Write-Host "2. 📝 Process Commits Only" -ForegroundColor Blue  
Write-Host "   Handle existing git changes without file cleanup"
Write-Host ""
Write-Host "3. 📦 Handle Git Stashes" -ForegroundColor Cyan
Write-Host "   Interactive stash management and commit"
Write-Host ""
Write-Host "4. ⏰ Start Continuous Maintenance" -ForegroundColor Yellow
Write-Host "   Background cleanup every 30 minutes (can leave running)"
Write-Host ""
Write-Host "5. 🔍 Preview Mode (WhatIf)" -ForegroundColor Gray
Write-Host "   See what would be cleaned without making changes"
Write-Host ""
Write-Host "6. 🚀 Full Auto Mode" -ForegroundColor Red
Write-Host "   Cleanup + commits + continue until done"
Write-Host ""

$choice = Read-Host "Choose option (1-6) or 'q' to quit"

switch ($choice) {
    "1" {
        Write-Host "`n🧹 Starting Quick Cleanup..." -ForegroundColor Green
        Start-ContinuousCleanup -MaxFilesPerRun 15 -AutoCommit
    }
    "2" {
        Write-Host "`n📝 Processing Commits..." -ForegroundColor Blue
        Invoke-IncrementalCommit -CommitCategory Modified -MaxFilesPerCommit 8
    }
    "3" {
        Write-Host "`n📦 Handling Git Stashes..." -ForegroundColor Cyan
        Invoke-IncrementalCommit -CommitCategory Stash -InteractiveMode
    }
    "4" {
        Write-Host "`n⏰ Starting Continuous Maintenance..." -ForegroundColor Yellow
        Write-Host "   Press Ctrl+C to stop gracefully" -ForegroundColor Gray
        Write-Host "   Log file: Build-Steps\Maintenance-$(Get-Date -Format 'yyyyMMdd-HHmm').log" -ForegroundColor Gray
        Start-ContinuousMaintenanceScheduler -CleanupIntervalMinutes 30 -CommitIntervalMinutes 15
    }
    "5" {
        Write-Host "`n🔍 Preview Mode - Cleanup..." -ForegroundColor Gray
        Start-ContinuousCleanup -MaxFilesPerRun 20 -WhatIf
        Write-Host "`n🔍 Preview Mode - Commits..." -ForegroundColor Gray
        Invoke-IncrementalCommit -CommitCategory All -WhatIf
    }
    "6" {
        Write-Host "`n🚀 Full Auto Mode..." -ForegroundColor Red
        Write-Host "⚠️  This will process ALL files with auto-commit" -ForegroundColor Yellow
        $confirm = Read-Host "Continue? (yes/no)"
        if ($confirm -eq "yes") {
            # Run multiple iterations until complete
            do {
                Write-Host "`n🧹 Cleanup iteration..." -ForegroundColor Green
                Start-ContinuousCleanup -MaxFilesPerRun 25 -AutoCommit
                
                Write-Host "`n📝 Commit processing..." -ForegroundColor Blue
                Invoke-IncrementalCommit -CommitCategory All -MaxFilesPerCommit 10
                
                # Check if more work needed
                $newGitStatus = git status --porcelain 2>$null
                $remainingClutter = Get-ChildItem -Path "*SUMMARY*", "*COMPLETE*", "UltraPerformance-*.html" -File -ErrorAction SilentlyContinue
                
                if ($newGitStatus.Count -eq 0 -and $remainingClutter.Count -eq 0) {
                    Write-Host "`n🎉 Repository fully cleaned!" -ForegroundColor Green
                    break
                }
                
                Write-Host "`n▶️  More work remaining, continuing..." -ForegroundColor Yellow
                Start-Sleep -Seconds 5
                
            } while ($true)
        } else {
            Write-Host "Cancelled" -ForegroundColor Gray
        }
    }
    "q" {
        Write-Host "Goodbye! 👋" -ForegroundColor Yellow
        exit 0
    }
    default {
        Write-Host "Invalid choice. Please run the script again." -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n✅ Quick Start Complete!" -ForegroundColor Green
Write-Host "💡 Use VS Code Tasks (Ctrl+Shift+P → 'Tasks: Run Task') for easy access" -ForegroundColor Cyan
Write-Host "📚 Available tasks: continuous-maintenance.json" -ForegroundColor Gray
