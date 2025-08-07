#Requires -Version 5.1

<#
.SYNOPSIS
    Reorganizes PowerShell modules by vendor/maintainer for better workspace organization.

.DESCRIPTION
    Creates vendor-based directory structure for PowerShell modules following enterprise patterns.
    Prepares for PSGallery source registration and digital signature implementation.

.PARAMETER ModulesPath
    Path to the PowerShellModules directory to reorganize.

.PARAMETER CreateSymlinks
    Create symlinks to preserve existing module paths for compatibility.

.PARAMETER DryRun
    Show what would be moved without actually moving files.

.EXAMPLE
    Reorganize-ModulesByVendor -DryRun

.EXAMPLE
    Reorganize-ModulesByVendor -CreateSymlinks

.NOTES
    Follows PowerShell Development Standards & Architecture
    - Vendor organization for enterprise module management
    - Preparation for PSGallery source registration
    - Digital signature readiness
#>

param(
    [string]$ModulesPath = "c:\backup\Powershell\PowerShellModules",
    [switch]$CreateSymlinks,
    [switch]$DryRun
)

function Get-ModuleVendorMapping {
    <#
    .SYNOPSIS
    Define vendor mapping for known PowerShell modules
    #>
    
    return @{
        # Microsoft Official Modules
        'Microsoft' = @(
            'Microsoft.PowerShell.*',
            'Microsoft.WinGet.*',
            'Microsoft.PowerToys.*',
            'Microsoft.WSMan.*',
            'ActiveDirectory',
            'AppBackgroundTask',
            'AppLocker',
            'AppvClient',
            'Appx',
            'AssignedAccess',
            'AutoSequencer',
            'BestPractices',
            'BitLocker',
            'BitsTransfer',
            'BranchCache',
            'CimCmdlets',
            'ClusterAwareUpdating',
            'ConfigCI',
            'ConfigDefender',
            'ConfigDefenderPerformance',
            'Defender',
            'DeliveryOptimization',
            'DesktopManager',
            'DFSN',
            'DFSR',
            'DhcpServer',
            'DirectAccessClientComponents',
            'Dism',
            'DnsClient',
            'DnsServer',
            'EventTracingManagement',
            'FailoverClusters',
            'GroupPolicy',
            'HgsClient',
            'HgsDiagnostics',
            'HostComputeService',
            'HostNetworkingService',
            'Hyper-V',
            'IISAdministration',
            'International',
            'IpamServer',
            'iSCSI',
            'IscsiTarget',
            'ISE',
            'Kds',
            'LanguagePackManagement',
            'LAPS',
            'MMAgent',
            'MsDtc',
            'MSOnline',
            'Net*',
            'Network*',
            'NFS',
            'PackageManagement',
            'PcsvDevice',
            'PersistentMemory',
            'PKI',
            'PnpDevice',
            'PowerShellGet',
            'PrintManagement',
            'ProcessMitigations',
            'Provisioning',
            'PSDesiredStateConfiguration',
            'PSDiagnostics',
            'PSScheduledJob',
            'PSWindowsUpdate',
            'PSWorkflow',
            'PSWorkflowUtility',
            'RemoteAccess',
            'RemoteDesktop',
            'RunAsUser',
            'ScheduledTasks',
            'SecureBoot',
            'Sequencer',
            'ServerManager',
            'ServerManagerTasks',
            'ShieldedVM*',
            'SmbShare',
            'SmbWitness',
            'StartLayout',
            'Storage*',
            'SystemInsights',
            'ThreadJob',
            'TLS',
            'TroubleshootingPack',
            'TrustedPlatformModule',
            'UEV',
            'UpdateServices',
            'VcRedist',
            'VirtualDesktop',
            'Wdac',
            'WebAdministration',
            'Whea',
            'WindowsDeveloperLicense',
            'WindowsErrorReporting',
            'WindowsSearch',
            'WindowsUpdate'
        )
        
        # Azure/Microsoft Cloud
        'Microsoft.Azure' = @(
            'Az.*',
            'Azure*',
            'AzureAD',
            'AzureRM*',
            'ExchangeOnlineManagement'
        )
        
        # Community/Third-Party Popular
        'Community' = @(
            'Pester',
            'PSReadLine',
            'Terminal-Icons',
            'oh-my-posh',
            'posh-git',
            'Posh-SSH',
            'PSFzf',
            'powershell-yaml',
            'z'
        )
        
        # Specialty Tools
        'Tools' = @(
            'F7History',
            'gemini-cli',
            'Mailozaurr',
            'NerdFont-Cheat-Sheet',
            'opencode',
            'posh-cargo',
            'PowerBGInfo',
            'PSWritePDF',
            'VMware'
        )
        
        # Custom/Personal (Your modules)
        'PhilipRochazka' = @(
            'Google-Hardware-key',
            'Symlink-Management',
            'UnifiedPowerShellProfile',
            'PSmodulesRepository',
            'Dotenv'
        )
        
        # Language Packs
        'LanguagePacks' = @(
            'de-de',
            'en-us',
            'es-es',
            'it-it',
            'pt-br',
            'ru-ru',
            'zh-cn',
            'zh-tw'
        )
        
        # Development/Build
        'Development' = @(
            '.vscode',
            '.vs',
            'Build-Steps',
            'docs'
        )
    }
}

function Get-ModuleVendor {
    param([string]$ModuleName)
    
    $vendorMapping = Get-ModuleVendorMapping
    
    foreach ($vendor in $vendorMapping.Keys) {
        foreach ($pattern in $vendorMapping[$vendor]) {
            if ($ModuleName -like $pattern) {
                return $vendor
            }
        }
    }
    
    # Default for unrecognized modules
    return 'Unknown'
}

function Initialize-VendorDirectories {
    param([string]$BasePath)
    
    $vendors = @(
        'Microsoft',
        'Microsoft.Azure', 
        'Community',
        'Tools',
        'PhilipRochazka',
        'LanguagePacks',
        'Development',
        'Unknown'
    )
    
    foreach ($vendor in $vendors) {
        $vendorPath = Join-Path $BasePath $vendor
        if (-not (Test-Path $vendorPath)) {
            if (-not $DryRun) {
                New-Item -ItemType Directory -Path $vendorPath -Force | Out-Null
            }
            Write-Host "📁 Created vendor directory: $vendor" -ForegroundColor Green
        }
    }
}

function Reorganize-ModulesByVendor {
    [CmdletBinding()]
    param(
        [string]$ModulesPath,
        [switch]$CreateSymlinks,
        [switch]$DryRun
    )
    
    Write-Host "🚀 Starting Module Vendor Reorganization..." -ForegroundColor Cyan
    Write-Host "📂 Source: $ModulesPath" -ForegroundColor Gray
    
    if ($DryRun) {
        Write-Host "🧪 DRY RUN MODE - No files will be moved" -ForegroundColor Yellow
    }
    
    # Get all modules
    $modules = Get-ChildItem -Path $ModulesPath -Directory
    Write-Host "📦 Found $($modules.Count) modules to organize" -ForegroundColor Gray
    
    # Initialize vendor directories
    Initialize-VendorDirectories -BasePath $ModulesPath
    
    # Group modules by vendor
    $vendorGroups = @{}
    foreach ($module in $modules) {
        $vendor = Get-ModuleVendor -ModuleName $module.Name
        
        if (-not $vendorGroups.ContainsKey($vendor)) {
            $vendorGroups[$vendor] = @()
        }
        $vendorGroups[$vendor] += $module
    }
    
    # Display organization plan
    Write-Host "`n📋 Reorganization Plan:" -ForegroundColor Cyan
    foreach ($vendor in $vendorGroups.Keys | Sort-Object) {
        $count = $vendorGroups[$vendor].Count
        Write-Host "  🏷️  $vendor ($count modules)" -ForegroundColor Yellow
        
        foreach ($module in $vendorGroups[$vendor] | Sort-Object Name) {
            Write-Host "     📦 $($module.Name)" -ForegroundColor Gray
        }
    }
    
    if ($DryRun) {
        Write-Host "`n✅ Dry run completed. Use -DryRun:`$false to perform actual reorganization." -ForegroundColor Green
        return
    }
    
    # Perform reorganization
    Write-Host "`n🔄 Starting reorganization..." -ForegroundColor Cyan
    
    foreach ($vendor in $vendorGroups.Keys) {
        $vendorPath = Join-Path $ModulesPath $vendor
        
        foreach ($module in $vendorGroups[$vendor]) {
            $sourcePath = $module.FullName
            $targetPath = Join-Path $vendorPath $module.Name
            
            try {
                # Check if target already exists
                if (Test-Path $targetPath) {
                    Write-Warning "⚠️ Target already exists: $targetPath"
                    continue
                }
                
                # Move module to vendor directory
                Move-Item -Path $sourcePath -Destination $targetPath -Force
                Write-Host "  ✅ Moved: $($module.Name) → $vendor/" -ForegroundColor Green
                
                # Create symlink for compatibility if requested
                if ($CreateSymlinks) {
                    New-Item -ItemType SymbolicLink -Path $sourcePath -Target $targetPath -Force | Out-Null
                    Write-Host "  🔗 Created symlink: $($module.Name)" -ForegroundColor Blue
                }
                
            } catch {
                Write-Error "❌ Failed to move $($module.Name): $($_.Exception.Message)"
            }
        }
    }
    
    Write-Host "`n🎯 Creating vendor documentation..." -ForegroundColor Cyan
    Build-VendorDocumentation -ModulesPath $ModulesPath -VendorGroups $vendorGroups
    
    Write-Host "`n✅ Module reorganization completed!" -ForegroundColor Green
    Write-Host "📊 Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Review vendor organization" -ForegroundColor Gray
    Write-Host "  2. Update module paths in scripts" -ForegroundColor Gray
    Write-Host "  3. Prepare for PSGallery source registration" -ForegroundColor Gray
    Write-Host "  4. Implement digital signature process" -ForegroundColor Gray
}

function Build-VendorDocumentation {
    param(
        [string]$ModulesPath,
        [hashtable]$VendorGroups
    )
    
    $readmePath = Join-Path $ModulesPath "README-VendorOrganization.md"
    
    $content = @"
# PowerShell Modules - Vendor Organization

This directory has been reorganized by vendor/maintainer for better enterprise module management.

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## Vendor Structure

"@

    foreach ($vendor in $VendorGroups.Keys | Sort-Object) {
        $modules = $VendorGroups[$vendor]
        $content += @"

### $vendor ($($modules.Count) modules)

"@
        
        foreach ($module in $modules | Sort-Object Name) {
            $content += "- **$($module.Name)** - Located in `$vendor/$($module.Name)`/`n"
        }
    }
    
    $content += @"

## Usage

### Module Import Examples

``````powershell
# Import Microsoft module
Import-Module ".\Microsoft\ActiveDirectory"

# Import Community module  
Import-Module ".\Community\Pester"

# Import Personal module
Import-Module ".\PhilipRochazka\UnifiedPowerShellProfile"

# Import Azure module
Import-Module ".\Microsoft.Azure\Az.Accounts"
``````

### PSModulePath Configuration

To make vendor modules discoverable:

``````powershell
# Add vendor paths to PSModulePath
`$vendorPaths = @(
    "C:\backup\Powershell\PowerShellModules\Microsoft"
    "C:\backup\Powershell\PowerShellModules\Community"
    "C:\backup\Powershell\PowerShellModules\PhilipRochazka"
)

foreach (`$path in `$vendorPaths) {
    if (`$env:PSModulePath -notlike "*`$path*") {
        `$env:PSModulePath = "`$path;`$env:PSModulePath"
    }
}
``````

## PSGallery Repository Preparation

This organization prepares for:
- Private PSGallery source registration
- Digital signature implementation
- Enterprise module deployment
- Automated CI/CD for module publishing

## Next Steps

1. **Digital Signatures**: Implement code signing for custom modules
2. **PSGallery Source**: Register as private repository
3. **CI/CD Pipeline**: Automate module testing and publishing
4. **Version Management**: Implement semantic versioning
5. **Documentation**: Generate comprehensive module docs

---
*Generated by Reorganize-ModulesByVendor following PowerShell enterprise best practices*
"@
    
    Set-Content -Path $readmePath -Value $content -Encoding UTF8
    Write-Host "  📚 Created vendor documentation: README-VendorOrganization.md" -ForegroundColor Green
}

# Main execution
Reorganize-ModulesByVendor -ModulesPath $ModulesPath -CreateSymlinks:$CreateSymlinks -DryRun:$DryRun
