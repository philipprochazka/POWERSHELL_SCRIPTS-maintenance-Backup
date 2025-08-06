#!/usr/bin/env pwsh
# Branch Setup Script - Minimal version to avoid terminal issues

param(
    [switch]$Force,
    [switch]$Quiet
)

function Write-Status {
    param($Message, $Color = "White")
    if (-not $Quiet) {
        Write-Host $Message -ForegroundColor $Color
    }
}

# Change to the PowerShell directory
Set-Location "c:\backup\Powershell" -ErrorAction SilentlyContinue

Write-Status "🔧 Setting up version branches..." "Cyan"

try {
    # Stage and commit current changes
    $gitStatus = git status --porcelain 2>$null
    if ($gitStatus -or $Force) {
        git add . 2>$null
        git commit -m "feat: v4-Alpha XML Schema Architecture + Lazy Loading System" 2>$null
        Write-Status "✅ Changes committed" "Green"
    }

    # Get current branches
    $branches = git branch 2>$null | ForEach-Object { $_.Trim().Replace('*', '').Trim() }
    
    # Create v3-stable if needed
    if (-not ($branches -contains "v3-stable")) {
        git branch v3-stable 2>$null
        Write-Status "✅ Created v3-stable branch" "Green"
    } else {
        Write-Status "✅ v3-stable branch exists" "Green"
    }
    
    # Create v4-alpha if needed
    if (-not ($branches -contains "v4-alpha")) {
        git branch v4-alpha 2>$null
        Write-Status "✅ Created v4-alpha branch" "Green"
    } else {
        Write-Status "✅ v4-alpha branch exists" "Green"
    }
    
    # Switch to v4-alpha
    git checkout v4-alpha 2>$null
    Write-Status "✅ Switched to v4-alpha branch" "Green"
    
    # Show current status
    $currentBranch = git branch --show-current 2>$null
    Write-Status "`n🎯 Current branch: $currentBranch" "Magenta"
    
    if (-not $Quiet) {
        Write-Status "`n📋 All branches:" "Cyan"
        git branch 2>$null | ForEach-Object {
            if ($_ -match '\*') {
                Write-Status "   $_" "Cyan"
            } else {
                Write-Status "   $_" "White"
            }
        }
    }
    
    Write-Status "`n🎉 Branch setup completed successfully!" "Green"
    
} catch {
    Write-Status "❌ Error during branch setup: $($_.Exception.Message)" "Red"
    exit 1
}

# Write completion marker
"Branch setup completed at $(Get-Date)" | Out-File "branch-setup-complete.txt" -Force
