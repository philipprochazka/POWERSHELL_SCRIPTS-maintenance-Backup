#!/usr/bin/env pwsh
# Setup version branches for UnifiedPowerShellProfile

Write-Host "🚀 Setting up version branches for UnifiedPowerShellProfile..." -ForegroundColor Cyan

# Ensure we're in the right directory
Set-Location "c:\backup\Powershell"

# First, commit any pending changes
try {
    git add . 2>$null
    git commit -m "feat: v4-Alpha XML Schema Architecture + Lazy Loading System" 2>$null
    Write-Host "✅ Changes committed" -ForegroundColor Green
} catch {
    Write-Host "ℹ️ No changes to commit or already committed" -ForegroundColor Blue
}

# Check current status
Write-Host "`n📋 Current repository status:" -ForegroundColor Cyan
$currentBranch = git branch --show-current 2>$null
Write-Host "   Current branch: $currentBranch" -ForegroundColor White

$allBranches = git branch -a 2>$null
Write-Host "   Existing branches:" -ForegroundColor White
$allBranches | ForEach-Object { Write-Host "      $_" -ForegroundColor Gray }

# Create v3-stable branch if it doesn't exist
if ($allBranches -notcontains "*v3-stable" -and $allBranches -notcontains "  v3-stable") {
    Write-Host "`n🔧 Creating v3-stable branch..." -ForegroundColor Yellow
    git branch v3-stable 2>$null
    Write-Host "✅ v3-stable branch created" -ForegroundColor Green
} else {
    Write-Host "`n✅ v3-stable branch already exists" -ForegroundColor Green
}

# Create v4-alpha branch if it doesn't exist
if ($allBranches -notcontains "*v4-alpha" -and $allBranches -notcontains "  v4-alpha") {
    Write-Host "`n🔧 Creating v4-alpha branch..." -ForegroundColor Yellow
    git branch v4-alpha 2>$null
    Write-Host "✅ v4-alpha branch created" -ForegroundColor Green
} else {
    Write-Host "`n✅ v4-alpha branch already exists" -ForegroundColor Green
}

# Switch to v4-alpha for continued development
Write-Host "`n🔄 Switching to v4-alpha branch..." -ForegroundColor Yellow
git checkout v4-alpha 2>$null
Write-Host "✅ Switched to v4-alpha branch" -ForegroundColor Green

# Show final branch structure
Write-Host "`n✅ Branch setup complete! Current branches:" -ForegroundColor Green
$finalBranches = git branch -a 2>$null
$finalBranches | ForEach-Object { 
    if ($_ -match '\*') {
        Write-Host "   $_" -ForegroundColor Cyan
    } else {
        Write-Host "   $_" -ForegroundColor White
    }
}

Write-Host "`n📋 Branch Purpose:" -ForegroundColor Cyan
Write-Host "   • master      - Main production branch" -ForegroundColor White
Write-Host "   • v3-stable   - Stable v3 releases and maintenance" -ForegroundColor White
Write-Host "   • v4-alpha    - v4 development with XML schema architecture" -ForegroundColor White
Write-Host "   • main        - GitHub default branch" -ForegroundColor White
Write-Host "   • dev         - Development branch" -ForegroundColor White
Write-Host "   • feature     - Feature development branch" -ForegroundColor White

Write-Host "`n🎯 You are now on v4-alpha branch for continued XML schema development!" -ForegroundColor Magenta

# Check if we need to push branches
$remotes = git remote 2>$null
if ($remotes) {
    Write-Host "`n💡 Don't forget to push the new branches:" -ForegroundColor Yellow
    Write-Host "   git push -u origin v3-stable" -ForegroundColor Gray
    Write-Host "   git push -u origin v4-alpha" -ForegroundColor Gray
}
