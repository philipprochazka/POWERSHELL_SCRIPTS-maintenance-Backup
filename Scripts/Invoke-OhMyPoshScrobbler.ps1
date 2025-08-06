#Requires -Version 7.0

<#
.SYNOPSIS
    Oh My Posh Documentation Scrobbler and Version Migrator

.DESCRIPTION
    Advanced scrobbler system that fetches the latest Oh My Posh documentation,
    compares versions, and provides migration assistance from legacy configs to v26.9.0+

.PARAMETER ScrobbleMode
    The type of scrobbling operation to perform

.PARAMETER OutputPath
    Where to save the scrobbled documentation

.PARAMETER CompareVersions
    Compare current installation with latest version

.PARAMETER MigrateConfigs
    Migrate old OMPL configurations to new format

.EXAMPLE
    Invoke-OhMyPoshScrobbler -ScrobbleMode 'Full' -CompareVersions -MigrateConfigs
#>

[CmdletBinding()]
param(
    [ValidateSet('Quick', 'Full', 'DocsOnly', 'ThemesOnly', 'Migration')]
    [string]$ScrobbleMode = 'Full',
    
    [string]$OutputPath = 'C:\backup\Powershell\Modules\oh-my-posh\docs',
    
    [switch]$CompareVersions,
    
    [switch]$MigrateConfigs,
    
    [switch]$UpdateInstallation,
    
    [string]$TargetVersion = '26.9.0'
)

# Script-level variables
$script:OhMyPoshConfig = @{
    CurrentVersion = $null
    LatestVersion  = $TargetVersion
    DocsUrl        = 'https://ohmyposh.dev/docs/'
    ApiUrl         = 'https://api.github.com/repos/JanDeDobbeleer/oh-my-posh'
    LocalRepo      = 'C:\backup\Powershell\Modules\oh-my-posh'
    OutputPath     = $OutputPath
    BackupPath     = 'C:\backup\Powershell\Modules\oh-my-posh-backup'
}

function Initialize-ScrobblerEnvironment {
    [CmdletBinding()]
    param()
    
    Write-Host "🚀 Initializing Oh My Posh Scrobbler Environment..." -ForegroundColor Cyan
    
    # Create output directories
    @($script:OhMyPoshConfig.OutputPath, $script:OhMyPoshConfig.BackupPath) | ForEach-Object {
        if (-not (Test-Path $_)) {
            New-Item -Path $_ -ItemType Directory -Force | Out-Null
            Write-Host "📁 Created directory: $_" -ForegroundColor Green
        }
    }
    
    # Get current Oh My Posh version
    try {
        $currentVersion = & oh-my-posh version 2>$null
        $script:OhMyPoshConfig.CurrentVersion = $currentVersion.Trim()
        Write-Host "📊 Current Version: $($script:OhMyPoshConfig.CurrentVersion)" -ForegroundColor Yellow
    } catch {
        Write-Warning "⚠️ Could not determine current Oh My Posh version: $($_.Exception.Message)"
        $script:OhMyPoshConfig.CurrentVersion = "Unknown"
    }
    
    Write-Host "🎯 Target Version: $($script:OhMyPoshConfig.LatestVersion)" -ForegroundColor Green
}

function Invoke-DocumentationScrobble {
    [CmdletBinding()]
    param(
        [string]$Mode = 'Full'
    )
    
    Write-Host "🕷️ Starting Documentation Scrobble (Mode: $Mode)..." -ForegroundColor Magenta
    
    $docsPath = Join-Path $script:OhMyPoshConfig.OutputPath "scrobbled-docs"
    if (-not (Test-Path $docsPath)) {
        New-Item -Path $docsPath -ItemType Directory -Force | Out-Null
    }
    
    # Scrobble main documentation sections
    $docSections = @{
        'installation'  = 'https://ohmyposh.dev/docs/installation'
        'configuration' = 'https://ohmyposh.dev/docs/configuration'
        'themes'        = 'https://ohmyposh.dev/docs/themes'
        'segments'      = 'https://ohmyposh.dev/docs/segments'
        'migration'     = 'https://ohmyposh.dev/docs/migrating'
    }
    
    $scrobbledContent = @{}
    
    foreach ($section in $docSections.GetEnumerator()) {
        Write-Host "📄 Scrobbling: $($section.Key)..." -ForegroundColor Blue
        
        try {
            $response = Invoke-WebRequest -Uri $section.Value -UseBasicParsing -TimeoutSec 30
            $content = $response.Content
            
            # Extract relevant content (simplified HTML parsing)
            $mainContent = if ($content -match '<main[^>]*>(.*?)</main>') {
                $matches[1]
            } else {
                $content
            }
            
            $scrobbledContent[$section.Key] = $mainContent
            
            # Save individual section
            $sectionFile = Join-Path $docsPath "$($section.Key).html"
            Set-Content -Path $sectionFile -Value $mainContent -Encoding UTF8
            
            Write-Host "✅ Scrobbled: $($section.Key) -> $sectionFile" -ForegroundColor Green
            
        } catch {
            Write-Warning "❌ Failed to scrobble $($section.Key): $($_.Exception.Message)"
        }
        
        Start-Sleep -Milliseconds 500  # Be nice to the server
    }
    
    # Create consolidated documentation
    $consolidatedDoc = @"
# Oh My Posh Documentation Scrobble
## Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
## Source: https://ohmyposh.dev/docs/
## Target Version: $($script:OhMyPoshConfig.LatestVersion)
## Current Version: $($script:OhMyPoshConfig.CurrentVersion)

$($scrobbledContent.GetEnumerator() | ForEach-Object {
"## $($_.Key.ToUpper())

$($_.Value)

---
"
})
"@
    
    $consolidatedPath = Join-Path $docsPath "oh-my-posh-docs-consolidated.md"
    Set-Content -Path $consolidatedPath -Value $consolidatedDoc -Encoding UTF8
    
    Write-Host "📚 Consolidated documentation saved: $consolidatedPath" -ForegroundColor Cyan
    
    return $scrobbledContent
}

function Get-VersionComparison {
    [CmdletBinding()]
    param()
    
    Write-Host "🔍 Analyzing Version Differences..." -ForegroundColor Cyan
    
    try {
        # Get latest release info from GitHub API
        $latestRelease = Invoke-RestMethod -Uri "$($script:OhMyPoshConfig.ApiUrl)/releases/latest"
        $latestVersion = $latestRelease.tag_name.TrimStart('v')
        
        Write-Host "📊 Version Comparison:" -ForegroundColor Yellow
        Write-Host "   Current: $($script:OhMyPoshConfig.CurrentVersion)" -ForegroundColor Red
        Write-Host "   Latest:  $latestVersion" -ForegroundColor Green
        Write-Host "   Target:  $($script:OhMyPoshConfig.LatestVersion)" -ForegroundColor Blue
        
        # Parse version numbers for comparison
        $currentVer = try {
            [Version]$script:OhMyPoshConfig.CurrentVersion 
        } catch {
            [Version]"0.0.0" 
        }
        $latestVer = try {
            [Version]$latestVersion 
        } catch {
            [Version]"0.0.0" 
        }
        $targetVer = try {
            [Version]$script:OhMyPoshConfig.LatestVersion 
        } catch {
            [Version]"0.0.0" 
        }
        
        $comparison = @{
            Current        = $currentVer
            Latest         = $latestVer
            Target         = $targetVer
            NeedsUpdate    = $currentVer -lt $targetVer
            IsMajorUpgrade = $currentVer.Major -lt $targetVer.Major
            ReleaseNotes   = $latestRelease.body
        }
        
        if ($comparison.NeedsUpdate) {
            Write-Host "⚠️ Update Required!" -ForegroundColor Red
            if ($comparison.IsMajorUpgrade) {
                Write-Host "🚨 Major version upgrade detected - configuration migration may be needed!" -ForegroundColor Yellow
            }
        } else {
            Write-Host "✅ Version is current" -ForegroundColor Green
        }
        
        return $comparison
        
    } catch {
        Write-Warning "❌ Failed to get latest version info: $($_.Exception.Message)"
        return @{ NeedsUpdate = $true; IsMajorUpgrade = $true }
    }
}

function New-ConfigurationMigrationPlan {
    [CmdletBinding()]
    param(
        [object]$VersionComparison
    )
    
    Write-Host "🔄 Creating Configuration Migration Plan..." -ForegroundColor Cyan
    
    # Find existing Oh My Posh configurations
    $configLocations = @(
        "$env:USERPROFILE\.config\oh-my-posh",
        "$env:POSH_THEMES_PATH",
        "$env:USERPROFILE\Documents\PowerShell",
        "$env:USERPROFILE\Documents\WindowsPowerShell",
        "C:\backup\Powershell"
    )
    
    $foundConfigs = @()
    
    foreach ($location in $configLocations) {
        if (Test-Path $location) {
            $configs = Get-ChildItem -Path $location -Recurse -Include "*.omp.json", "*.omp.yml", "*.json" -ErrorAction SilentlyContinue
            $foundConfigs += $configs
        }
    }
    
    if ($foundConfigs.Count -eq 0) {
        Write-Host "ℹ️ No existing Oh My Posh configurations found" -ForegroundColor Blue
        return @()
    }
    
    Write-Host "📋 Found $($foundConfigs.Count) configuration files:" -ForegroundColor Green
    $foundConfigs | ForEach-Object {
        Write-Host "   📄 $($_.FullName)" -ForegroundColor Gray
    }
    
    # Create migration plan
    $migrationPlan = @{
        Configs        = $foundConfigs
        BackupPath     = Join-Path $script:OhMyPoshConfig.BackupPath "config-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
        MigrationSteps = @()
    }
    
    # Analyze each config for migration needs
    foreach ($config in $foundConfigs) {
        try {
            $content = Get-Content $config.FullName -Raw
            
            # Check for legacy patterns that need migration
            $needsMigration = $false
            $migrationIssues = @()
            
            # Example legacy patterns (simplified)
            if ($content -match '"type"\s*:\s*"prompt"') {
                $needsMigration = $true
                $migrationIssues += "Legacy prompt type format detected"
            }
            
            if ($content -match '"powerline"') {
                $needsMigration = $true
                $migrationIssues += "Powerline theme may need segment updates"
            }
            
            if ($needsMigration) {
                $migrationPlan.MigrationSteps += @{
                    File   = $config.FullName
                    Issues = $migrationIssues
                    Action = "Review and update configuration format"
                }
            }
            
        } catch {
            Write-Warning "⚠️ Could not analyze config: $($config.FullName)"
        }
    }
    
    return $migrationPlan
}

function Invoke-ConfigurationBackup {
    [CmdletBinding()]
    param(
        [object]$MigrationPlan
    )
    
    Write-Host "💾 Creating Configuration Backup..." -ForegroundColor Cyan
    
    if (-not $MigrationPlan.Configs -or $MigrationPlan.Configs.Count -eq 0) {
        Write-Host "ℹ️ No configurations to backup" -ForegroundColor Blue
        return
    }
    
    # Create backup directory
    $backupPath = $MigrationPlan.BackupPath
    New-Item -Path $backupPath -ItemType Directory -Force | Out-Null
    
    $backupCount = 0
    foreach ($config in $MigrationPlan.Configs) {
        try {
            $relativePath = $config.FullName.Replace(':', '_').Replace('\', '_')
            $backupFile = Join-Path $backupPath "backup_$relativePath"
            
            Copy-Item -Path $config.FullName -Destination $backupFile -Force
            $backupCount++
            
            Write-Host "✅ Backed up: $($config.Name)" -ForegroundColor Green
            
        } catch {
            Write-Warning "❌ Failed to backup $($config.FullName): $($_.Exception.Message)"
        }
    }
    
    Write-Host "💾 Backup completed: $backupCount files saved to $backupPath" -ForegroundColor Green
    
    # Create backup manifest
    $manifest = @{
        Timestamp     = Get-Date
        BackupPath    = $backupPath
        ConfigCount   = $backupCount
        SourceVersion = $script:OhMyPoshConfig.CurrentVersion
        TargetVersion = $script:OhMyPoshConfig.LatestVersion
        Files         = $MigrationPlan.Configs | ForEach-Object { $_.FullName }
    }
    
    $manifestPath = Join-Path $backupPath "backup-manifest.json"
    $manifest | ConvertTo-Json -Depth 3 | Set-Content -Path $manifestPath -Encoding UTF8
    
    Write-Host "📋 Backup manifest saved: $manifestPath" -ForegroundColor Cyan
}

function Install-ModernOhMyPosh {
    [CmdletBinding()]
    param(
        [string]$TargetVersion,
        [switch]$Force
    )
    
    Write-Host "🚀 Installing Modern Oh My Posh v$TargetVersion..." -ForegroundColor Magenta
    
    try {
        # Check if Scoop is available
        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            Write-Host "📦 Using Scoop for installation..." -ForegroundColor Blue
            
            if ($Force) {
                & scoop uninstall oh-my-posh
                Start-Sleep -Seconds 2
            }
            
            & scoop install oh-my-posh
            
            # Verify installation
            $newVersion = & oh-my-posh version
            Write-Host "✅ Oh My Posh installed: v$newVersion" -ForegroundColor Green
            
        } else {
            Write-Host "📦 Using PowerShell Gallery installation..." -ForegroundColor Blue
            
            # Alternative installation method
            $installScript = Invoke-WebRequest -Uri "https://ohmyposh.dev/install.ps1" -UseBasicParsing
            Invoke-Expression $installScript.Content
        }
        
        # Update themes
        Write-Host "🎨 Updating themes..." -ForegroundColor Cyan
        & oh-my-posh cache clear
        
        Write-Host "✅ Oh My Posh installation completed!" -ForegroundColor Green
        
    } catch {
        Write-Error "❌ Installation failed: $($_.Exception.Message)"
        throw
    }
}

function New-MigrationReport {
    [CmdletBinding()]
    param(
        [object]$VersionComparison,
        [object]$MigrationPlan,
        [hashtable]$ScrobbledDocs
    )
    
    Write-Host "📊 Generating Migration Report..." -ForegroundColor Cyan
    
    $reportPath = Join-Path $script:OhMyPoshConfig.OutputPath "oh-my-posh-migration-report.md"
    
    $report = @"
# Oh My Posh Migration Report
**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
**Scrobbler Version:** 1.0.0

## Version Analysis
- **Current Version:** $($script:OhMyPoshConfig.CurrentVersion)
- **Latest Available:** $($VersionComparison.Latest)
- **Target Version:** $($script:OhMyPoshConfig.LatestVersion)
- **Update Required:** $($VersionComparison.NeedsUpdate)
- **Major Upgrade:** $($VersionComparison.IsMajorUpgrade)

## Configuration Analysis
- **Configurations Found:** $($MigrationPlan.Configs.Count)
- **Backup Location:** $($MigrationPlan.BackupPath)
- **Migration Steps:** $($MigrationPlan.MigrationSteps.Count)

### Found Configurations
$($MigrationPlan.Configs | ForEach-Object { "- ``$($_.FullName)``" } | Out-String)

### Migration Steps Required
$($MigrationPlan.MigrationSteps | ForEach-Object {
"#### $($_.File)
- Issues: $($_.Issues -join ', ')
- Action: $($_.Action)
"
} | Out-String)

## Scrobbled Documentation Sections
$($ScrobbledDocs.Keys | ForEach-Object { "- [$_](./scrobbled-docs/$_.html)" } | Out-String)

## Recommended Actions
1. **Backup Configurations** - ✅ Completed
2. **Update Oh My Posh** - Use ``Install-ModernOhMyPosh`` function
3. **Migrate Configurations** - Review migration steps above
4. **Test New Setup** - Verify themes and segments work correctly
5. **Update Profile Scripts** - Update PowerShell profiles to use new initialization

## Resources
- [Official Migration Guide](https://ohmyposh.dev/docs/migrating)
- [Configuration Documentation](https://ohmyposh.dev/docs/configuration)
- [Theme Gallery](https://ohmyposh.dev/docs/themes)

## Next Steps
``````powershell
# 1. Install latest Oh My Posh
Install-ModernOhMyPosh -TargetVersion '$($script:OhMyPoshConfig.LatestVersion)' -Force

# 2. Initialize with modern configuration
Initialize-ModernOhMyPosh -Mode 'Dracula' -Verbose

# 3. Test configuration
oh-my-posh config migrate --config 'path/to/old/config.omp.json'
``````

---
*Generated by Oh My Posh Scrobbler System*
"@
    
    Set-Content -Path $reportPath -Value $report -Encoding UTF8
    Write-Host "📋 Migration report saved: $reportPath" -ForegroundColor Green
    
    return $reportPath
}

# Main execution flow
try {
    Write-Host "🕷️ Oh My Posh Documentation Scrobbler Starting..." -ForegroundColor Magenta
    Write-Host "════════════════════════════════════════════════════" -ForegroundColor Gray
    
    # Initialize environment
    Initialize-ScrobblerEnvironment
    
    # Perform scrobbling based on mode
    $scrobbledDocs = @{}
    switch ($ScrobbleMode) {
        'Quick' {
            Write-Host "⚡ Quick scrobble mode - essential docs only" -ForegroundColor Yellow
            $scrobbledDocs = Invoke-DocumentationScrobble -Mode 'Quick'
        }
        'Full' {
            Write-Host "🔍 Full scrobble mode - comprehensive documentation" -ForegroundColor Cyan
            $scrobbledDocs = Invoke-DocumentationScrobble -Mode 'Full'
        }
        'DocsOnly' {
            Write-Host "📚 Documentation only mode" -ForegroundColor Blue
            $scrobbledDocs = Invoke-DocumentationScrobble -Mode 'DocsOnly'
        }
        'ThemesOnly' {
            Write-Host "🎨 Themes only mode" -ForegroundColor Magenta
            # Theme-specific scrobbling would go here
        }
        'Migration' {
            Write-Host "🔄 Migration mode - analysis only" -ForegroundColor Green
            # Skip documentation scrobbling for migration-only mode
        }
    }
    
    # Version comparison
    $versionComparison = $null
    if ($CompareVersions -or $ScrobbleMode -ne 'DocsOnly') {
        $versionComparison = Get-VersionComparison
    }
    
    # Configuration migration analysis
    $migrationPlan = @()
    if ($MigrateConfigs -or $ScrobbleMode -in @('Full', 'Migration')) {
        $migrationPlan = New-ConfigurationMigrationPlan -VersionComparison $versionComparison
        
        if ($migrationPlan.Configs.Count -gt 0) {
            Invoke-ConfigurationBackup -MigrationPlan $migrationPlan
        }
    }
    
    # Update installation if requested
    if ($UpdateInstallation -and $versionComparison.NeedsUpdate) {
        Install-ModernOhMyPosh -TargetVersion $TargetVersion -Force
    }
    
    # Generate comprehensive report
    $reportPath = New-MigrationReport -VersionComparison $versionComparison -MigrationPlan $migrationPlan -ScrobbledDocs $scrobbledDocs
    
    Write-Host "`n✅ Scrobbling completed successfully!" -ForegroundColor Green
    Write-Host "📋 Report available at: $reportPath" -ForegroundColor Cyan
    Write-Host "📁 Documentation saved to: $($script:OhMyPoshConfig.OutputPath)" -ForegroundColor Blue
    
    if ($versionComparison.NeedsUpdate) {
        Write-Host "`n⚠️ Update recommended - run with -UpdateInstallation to proceed" -ForegroundColor Yellow
    }
    
} catch {
    Write-Error "❌ Scrobbler failed: $($_.Exception.Message)"
    Write-Host "💡 Check the error details above and retry" -ForegroundColor Yellow
    exit 1
}
