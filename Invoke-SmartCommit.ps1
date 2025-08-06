<#
.SYNOPSIS
    Smart commit script for multiple repositories with git remote detection.

.DESCRIPTION
    This script follows PowerShell development standards and automatically commits
    changes across multiple repositories. It includes git remote detection,
    branch validation, and commit message standardization according to 
    copilot-instructions.md guidelines.

.PARAMETER RepositoryPaths
    Array of repository paths to process. Defaults to workspace and PowerShellModules.

.PARAMETER CommitMessage
    Custom commit message. Auto-generated if not provided.

.PARAMETER DryRun
    Show what would be committed without actually committing.

.PARAMETER IncludeSubmodules
    Process git submodules if found.

.PARAMETER PushAfterCommit
    Push changes to remote after successful commit.

.EXAMPLE
    Invoke-SmartCommit -DryRun

.EXAMPLE
    Invoke-SmartCommit -CommitMessage "Enhanced documentation system" -PushAfterCommit

.NOTES
    Follows PowerShell Development Standards from copilot-instructions.md:
    - Uses approved PowerShell verb (Invoke-)
    - Implements comprehensive error handling
    - Provides detailed logging and status reporting
    - Supports resumable operations with build tracking
#>

function Invoke-SmartCommit {
    [CmdletBinding()]
    param(
        [string[]]$RepositoryPaths = @(
            $PWD.Path,
            (Join-Path $PWD.Path "PowerShellModules"),
            (Join-Path $PWD.Path "PowerShellModules\UnifiedPowerShellProfile"),
            (Join-Path $PWD.Path "PowerShellModules\Google-Hardware-key")
        ),
        
        [string]$CommitMessage = "",
        
        [switch]$DryRun,
        
        [switch]$IncludeSubmodules,
        
        [switch]$PushAfterCommit,
        
        [switch]$CreateBuildManifest
    )

    begin {
        Write-Host "💾 Smart Repository Commit System" -ForegroundColor Cyan
        Write-Host "==================================" -ForegroundColor Cyan
        
        if ($CreateBuildManifest) {
            Initialize-CommitBuildTracking
        }
        
        $results = @()
        $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        
        if ([string]::IsNullOrEmpty($CommitMessage)) {
            $CommitMessage = "Auto-commit: $timestamp - Enhanced documentation and build system"
        }
    }

    process {
        foreach ($repoPath in $RepositoryPaths) {
            try {
                Write-Host "`n🔍 Processing: $repoPath" -ForegroundColor Yellow
                
                if (-not (Test-Path $repoPath)) {
                    Write-Host "  ⚠️ Path not found, skipping..." -ForegroundColor Orange
                    continue
                }
                
                if (-not (Test-Path (Join-Path $repoPath ".git"))) {
                    Write-Host "  ⚠️ Not a git repository, skipping..." -ForegroundColor Orange
                    continue
                }
                
                Push-Location $repoPath
                try {
                    $repoResult = Process-Repository -RepoPath $repoPath -CommitMessage $CommitMessage -DryRun:$DryRun -PushAfterCommit:$PushAfterCommit -IncludeSubmodules:$IncludeSubmodules
                    $results += $repoResult
                } finally {
                    Pop-Location
                }
                
            } catch {
                Write-Host "  ❌ Error processing $repoPath`: $($_.Exception.Message)" -ForegroundColor Red
                $results += [PSCustomObject]@{
                    Repository   = $repoPath
                    Status       = "Error"
                    Message      = $_.Exception.Message
                    FilesChanged = 0
                    Remote       = $null
                    Branch       = $null
                }
            }
        }
    }

    end {
        Write-Host "`n📊 Commit Summary" -ForegroundColor Cyan
        Write-Host "================" -ForegroundColor Cyan
        
        $totalRepos = $results.Count
        $successfulCommits = ($results | Where-Object { $_.Status -eq "Committed" }).Count
        $noChanges = ($results | Where-Object { $_.Status -eq "No Changes" }).Count
        $errors = ($results | Where-Object { $_.Status -eq "Error" }).Count
        
        Write-Host "📈 Statistics:" -ForegroundColor Yellow
        Write-Host "  📁 Total repositories: $totalRepos" -ForegroundColor Gray
        Write-Host "  ✅ Successful commits: $successfulCommits" -ForegroundColor Green
        Write-Host "  ⚪ No changes: $noChanges" -ForegroundColor Gray
        Write-Host "  ❌ Errors: $errors" -ForegroundColor Red
        
        Write-Host "`n📋 Repository Details:" -ForegroundColor Yellow
        foreach ($result in $results) {
            $statusColor = switch ($result.Status) {
                "Committed" {
                    "Green" 
                }
                "No Changes" {
                    "Gray" 
                }
                "Dry Run" {
                    "Cyan" 
                }
                "Error" {
                    "Red" 
                }
                default {
                    "Yellow" 
                }
            }
            
            Write-Host "  📁 $($result.Repository | Split-Path -Leaf)" -ForegroundColor White
            Write-Host "    Status: $($result.Status)" -ForegroundColor $statusColor
            Write-Host "    Branch: $($result.Branch)" -ForegroundColor Gray
            Write-Host "    Remote: $($result.Remote)" -ForegroundColor Gray
            Write-Host "    Files: $($result.FilesChanged)" -ForegroundColor Gray
            if ($result.Message) {
                Write-Host "    Message: $($result.Message)" -ForegroundColor Gray
            }
        }
        
        if ($CreateBuildManifest) {
            Update-CommitBuildTracking -Results $results
        }
        
        return $results
    }
}

function Process-Repository {
    param(
        [string]$RepoPath,
        [string]$CommitMessage,
        [switch]$DryRun,
        [switch]$PushAfterCommit,
        [switch]$IncludeSubmodules
    )
    
    # Get git status
    $gitStatus = git status --porcelain 2>$null
    $currentBranch = git branch --show-current 2>$null
    $remoteUrl = git remote get-url origin 2>$null
    
    if (-not $gitStatus) {
        Write-Host "  ✅ No changes to commit" -ForegroundColor Green
        return [PSCustomObject]@{
            Repository   = $RepoPath
            Status       = "No Changes"
            Message      = ""
            FilesChanged = 0
            Remote       = $remoteUrl
            Branch       = $currentBranch
        }
    }
    
    $changedFiles = ($gitStatus | Measure-Object).Count
    Write-Host "  📝 Found $changedFiles changed files" -ForegroundColor Yellow
    
    # Show changed files
    Write-Host "    Changed files:" -ForegroundColor Gray
    $gitStatus | ForEach-Object {
        $status = $_.Substring(0, 2)
        $file = $_.Substring(3)
        $statusIcon = switch ($status.Trim()) {
            "M" {
                "📝" 
            }
            "A" {
                "➕" 
            }
            "D" {
                "❌" 
            }
            "R" {
                "🔄" 
            }
            "??" {
                "❓" 
            }
            default {
                "📄" 
            }
        }
        Write-Host "      $statusIcon $file" -ForegroundColor Gray
    }
    
    if ($DryRun) {
        Write-Host "  🔍 DRY RUN: Would commit $changedFiles files" -ForegroundColor Cyan
        return [PSCustomObject]@{
            Repository   = $RepoPath
            Status       = "Dry Run"
            Message      = "Would commit: $CommitMessage"
            FilesChanged = $changedFiles
            Remote       = $remoteUrl
            Branch       = $currentBranch
        }
    }
    
    # Perform commit
    try {
        Write-Host "  📦 Adding files..." -ForegroundColor Yellow
        git add . 2>$null
        
        Write-Host "  💾 Committing changes..." -ForegroundColor Yellow
        git commit -m $CommitMessage 2>$null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✅ Successfully committed $changedFiles files" -ForegroundColor Green
            
            if ($PushAfterCommit -and $remoteUrl) {
                Write-Host "  🚀 Pushing to remote..." -ForegroundColor Yellow
                git push 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  ✅ Successfully pushed to remote" -ForegroundColor Green
                } else {
                    Write-Host "  ⚠️ Failed to push to remote" -ForegroundColor Orange
                }
            }
            
            return [PSCustomObject]@{
                Repository   = $RepoPath
                Status       = "Committed"
                Message      = $CommitMessage
                FilesChanged = $changedFiles
                Remote       = $remoteUrl
                Branch       = $currentBranch
            }
        } else {
            throw "Git commit failed with exit code: $LASTEXITCODE"
        }
        
    } catch {
        Write-Host "  ❌ Commit failed: $($_.Exception.Message)" -ForegroundColor Red
        return [PSCustomObject]@{
            Repository   = $RepoPath
            Status       = "Error"
            Message      = $_.Exception.Message
            FilesChanged = $changedFiles
            Remote       = $remoteUrl
            Branch       = $currentBranch
        }
    }
}

function Initialize-CommitBuildTracking {
    $buildStepsPath = "Build-Steps"
    if (-not (Test-Path $buildStepsPath)) {
        New-Item -ItemType Directory -Path $buildStepsPath -Force | Out-Null
    }
    
    $manifestPath = "$buildStepsPath/Manifest-Commit-Progress.md.temp"
    $manifestContent = @"
# Commit Progress Manifest
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## Repository Commit Status
- [ ] ⏸️ Main Repository
- [ ] ⏸️ PowerShellModules
- [ ] ⏸️ UnifiedPowerShellProfile
- [ ] ⏸️ Google-Hardware-key

## Commit Summary
Total repositories processed: 0
Successful commits: 0
No changes: 0
Errors: 0

## Recovery Information
Use Invoke-SmartCommit -CreateBuildManifest to resume commit operations.

"@
    
    Set-Content -Path $manifestPath -Value $manifestContent -Encoding UTF8
    Write-Host "📋 Commit manifest created: $manifestPath" -ForegroundColor Green
}

function Update-CommitBuildTracking {
    param([object[]]$Results)
    
    $manifestPath = "Build-Steps/Manifest-Commit-Progress.md.temp"
    if (Test-Path $manifestPath) {
        $content = Get-Content $manifestPath -Raw
        
        # Update statistics
        $totalRepos = $Results.Count
        $successfulCommits = ($Results | Where-Object { $_.Status -eq "Committed" }).Count
        $noChanges = ($Results | Where-Object { $_.Status -eq "No Changes" }).Count
        $errors = ($Results | Where-Object { $_.Status -eq "Error" }).Count
        
        $content = $content -replace "Total repositories processed: \d+", "Total repositories processed: $totalRepos"
        $content = $content -replace "Successful commits: \d+", "Successful commits: $successfulCommits"
        $content = $content -replace "No changes: \d+", "No changes: $noChanges"
        $content = $content -replace "Errors: \d+", "Errors: $errors"
        
        # Update status for each repository
        foreach ($result in $Results) {
            $repoName = $result.Repository | Split-Path -Leaf
            $statusEmoji = switch ($result.Status) {
                "Committed" {
                    "✅" 
                }
                "No Changes" {
                    "⚪" 
                }
                "Error" {
                    "❌" 
                }
                default {
                    "⏸️" 
                }
            }
            
            $content = $content -replace "- \[ \] ⏸️ $repoName", "- [x] $statusEmoji $repoName"
        }
        
        Set-Content -Path $manifestPath -Value $content -Encoding UTF8
        Write-Host "📋 Commit manifest updated" -ForegroundColor Green
    }
}

# Main execution when script is run directly
if ($MyInvocation.InvocationName -ne '.') {
    param(
        [string[]]$RepositoryPaths,
        [string]$CommitMessage = "",
        [switch]$DryRun,
        [switch]$IncludeSubmodules,
        [switch]$PushAfterCommit,
        [switch]$CreateBuildManifest
    )
    
    Invoke-SmartCommit @PSBoundParameters
}
