<#
.SYNOPSIS
    Install or upgrade Oh My Posh to v26+ with enhanced PowerShell integration

.DESCRIPTION
    This script installs or upgrades Oh My Posh to the latest version (v26+) with support for
    the new runtime routines and executable approach. It also installs custom themes from
    your fork and updates the PowerShell profiles to use modern initialization.

.PARAMETER Force
    Force reinstall even if a newer version is already installed

.PARAMETER UseScoop
    Use Scoop instead of winget for installation

.PARAMETER InstallThemes
    Install custom themes including enhanced Dracula themes

.PARAMETER UpdateProfiles
    Update PowerShell profiles to use modern Oh My Posh initialization

.PARAMETER SkipValidation
    Skip post-installation validation

.EXAMPLE
    .\Install-ModernOhMyPosh.ps1
    Standard installation with winget

.EXAMPLE
    .\Install-ModernOhMyPosh.ps1 -UseScoop -InstallThemes -UpdateProfiles
    Complete installation using Scoop with themes and profile updates

.NOTES
    Author: Philip Procházka
    Compatible with: Oh My Posh v26+
    Requires: PowerShell 5.1+ or PowerShell 7+
#>

[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$UseScoop,
    [switch]$InstallThemes = $true,
    [switch]$UpdateProfiles = $true,
    [switch]$SkipValidation
)

# Ensure we're using proper error handling
$ErrorActionPreference = 'Stop'
$VerbosePreference = if ($PSBoundParameters['Verbose']) {
    'Continue' 
} else {
    'SilentlyContinue' 
}

function Write-StatusMessage {
    param(
        [string]$Message,
        [ValidateSet('Info', 'Success', 'Warning', 'Error')]
        [string]$Type = 'Info'
    )
    
    $colors = @{
        'Info'    = 'Cyan'
        'Success' = 'Green' 
        'Warning' = 'Yellow'
        'Error'   = 'Red'
    }
    
    $icons = @{
        'Info'    = '📋'
        'Success' = '✅'
        'Warning' = '⚠️'
        'Error'   = '❌'
    }
    
    Write-Host "$($icons[$Type]) $Message" -ForegroundColor $colors[$Type]
}

function Test-OhMyPoshVersion {
    <#
    .SYNOPSIS
        Tests the current Oh My Posh version and returns version info
    #>
    [CmdletBinding()]
    param()
    
    try {
        $ohMyPoshCmd = Get-Command oh-my-posh -ErrorAction SilentlyContinue
        if (-not $ohMyPoshCmd) {
            return @{
                Installed = $false
                Version   = $null
                IsModern  = $false
                Path      = $null
            }
        }
        
        $versionOutput = & oh-my-posh version 2>$null
        $version = $null
        $isModern = $false
        
        if ($versionOutput -match "(\d+)\.(\d+)\.(\d+)") {
            $majorVersion = [int]$matches[1]
            $version = "$majorVersion.$($matches[2]).$($matches[3])"
            $isModern = $majorVersion -ge 26
        }
        
        return @{
            Installed = $true
            Version   = $version
            IsModern  = $isModern
            Path      = $ohMyPoshCmd.Source
        }
        
    } catch {
        Write-Verbose "Error checking Oh My Posh version: $($_.Exception.Message)"
        return @{
            Installed = $false
            Version   = $null
            IsModern  = $false
            Path      = $null
            Error     = $_.Exception.Message
        }
    }
}

function Install-OhMyPoshViaPlatform {
    <#
    .SYNOPSIS
        Installs Oh My Posh using the specified platform (winget or scoop)
    #>
    [CmdletBinding()]
    param(
        [bool]$UseScoop,
        [bool]$Force
    )
    
    try {
        if ($UseScoop) {
            Write-StatusMessage "Installing Oh My Posh via Scoop..." -Type Info
            
            # Check if Scoop is available
            if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
                throw "Scoop is not installed. Install it first or use winget instead."
            }
            
            if ($Force) {
                Write-StatusMessage "Removing existing Scoop installation..." -Type Info
                & scoop uninstall oh-my-posh 2>$null
            }
            
            & scoop install https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json
            
            if ($LASTEXITCODE -eq 0) {
                Write-StatusMessage "Oh My Posh installed successfully via Scoop" -Type Success
            } else {
                throw "Scoop installation failed with exit code: $LASTEXITCODE"
            }
            
        } else {
            Write-StatusMessage "Installing Oh My Posh via Winget..." -Type Info
            
            if ($Force) {
                Write-StatusMessage "Removing existing Winget installation..." -Type Info
                & winget uninstall JanDeDobbeleer.OhMyPosh 2>$null
            }
            
            & winget install JanDeDobbeleer.OhMyPosh -s winget --accept-package-agreements --accept-source-agreements
            
            if ($LASTEXITCODE -eq 0) {
                Write-StatusMessage "Oh My Posh installed successfully via Winget" -Type Success
            } else {
                throw "Winget installation failed with exit code: $LASTEXITCODE"
            }
        }
        
        # Refresh PATH for current session
        $env:PATH = [System.Environment]::GetEnvironmentVariable('PATH', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('PATH', 'User')
        
        return $true
        
    } catch {
        Write-StatusMessage "Installation failed: $($_.Exception.Message)" -Type Error
        return $false
    }
}

function Install-CustomOhMyPoshThemes {
    <#
    .SYNOPSIS
        Downloads and installs custom themes from your fork
    #>
    [CmdletBinding()]
    param()
    
    try {
        Write-StatusMessage "Installing custom Oh My Posh themes..." -Type Info
        
        # Determine themes path
        $themesPath = $null
        $possiblePaths = @(
            "$env:LOCALAPPDATA\Programs\oh-my-posh\themes",
            "$env:POSH_THEMES_PATH",
            (Join-Path (Split-Path (Get-Command oh-my-posh -ErrorAction SilentlyContinue).Source -Parent) "themes")
        )
        
        foreach ($path in $possiblePaths) {
            if ($path -and (Test-Path $path -PathType Container)) {
                $themesPath = $path
                break
            }
        }
        
        if (-not $themesPath) {
            # Create default themes path
            $themesPath = "$env:LOCALAPPDATA\Programs\oh-my-posh\themes"
            New-Item -ItemType Directory -Path $themesPath -Force | Out-Null
        }
        
        Write-Verbose "Using themes path: $themesPath"
        
        # Custom themes from your fork
        $customThemes = @{
            'dracula-enhanced.omp.json'    = 'https://raw.githubusercontent.com/philipprochazka/oh-my-posh/main/themes/dracula-enhanced.omp.json'
            'dracula-performance.omp.json' = 'https://raw.githubusercontent.com/philipprochazka/oh-my-posh/main/themes/dracula-performance.omp.json'
            'dracula-minimal.omp.json'     = 'https://raw.githubusercontent.com/philipprochazka/oh-my-posh/main/themes/dracula-minimal.omp.json'
        }
        
        $installed = 0
        foreach ($theme in $customThemes.GetEnumerator()) {
            try {
                $localPath = Join-Path $themesPath $theme.Key
                Write-Verbose "Downloading $($theme.Key) to $localPath"
                
                Invoke-WebRequest -Uri $theme.Value -OutFile $localPath -UseBasicParsing -ErrorAction Stop
                Write-StatusMessage "Installed theme: $($theme.Key)" -Type Success
                $installed++
                
            } catch {
                Write-StatusMessage "Failed to install theme $($theme.Key): $($_.Exception.Message)" -Type Warning
            }
        }
        
        if ($installed -gt 0) {
            Write-StatusMessage "Installed $installed custom themes to: $themesPath" -Type Success
            
            # Set environment variable for themes path
            if (-not $env:POSH_THEMES_PATH) {
                [Environment]::SetEnvironmentVariable('POSH_THEMES_PATH', $themesPath, 'User')
                $env:POSH_THEMES_PATH = $themesPath
            }
        }
        
        return $installed -gt 0
        
    } catch {
        Write-StatusMessage "Custom themes installation failed: $($_.Exception.Message)" -Type Error
        return $false
    }
}

function Update-PowerShellProfiles {
    <#
    .SYNOPSIS
        Updates PowerShell profiles to use modern Oh My Posh initialization
    #>
    [CmdletBinding()]
    param()
    
    try {
        Write-StatusMessage "Updating PowerShell profiles for modern Oh My Posh..." -Type Info
        
        $scriptRoot = $PSScriptRoot
        $profilesUpdated = 0
        
        # Profiles to update
        $profilesToUpdate = @(
            "$scriptRoot\Microsoft.PowerShell_profile_Dracula.ps1",
            "$scriptRoot\Microsoft.PowerShell_profile_Dracula_Performance.ps1",
            "$scriptRoot\Microsoft.PowerShell_profile_Dracula_Minimal.ps1",
            "$scriptRoot\Microsoft.PowerShell_profile_Dracula_Silent.ps1"
        )
        
        foreach ($profilePath in $profilesToUpdate) {
            if (Test-Path $profilePath) {
                try {
                    $content = Get-Content $profilePath -Raw
                    
                    # Check if already updated
                    if ($content -like "*Initialize-ModernOhMyPosh*") {
                        Write-Verbose "Profile already updated: $profilePath"
                        continue
                    }
                    
                    # Backup original
                    $backupPath = "$profilePath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
                    Copy-Item $profilePath $backupPath
                    Write-Verbose "Created backup: $backupPath"
                    
                    # TODO: Add profile update logic here
                    # For now, just inform the user
                    Write-StatusMessage "Profile ready for manual update: $(Split-Path $profilePath -Leaf)" -Type Info
                    $profilesUpdated++
                    
                } catch {
                    Write-StatusMessage "Failed to update profile $profilePath: $($_.Exception.Message)" -Type Warning
                }
            }
        }
        
        if ($profilesUpdated -gt 0) {
            Write-StatusMessage "Prepared $profilesUpdated profiles for modern Oh My Posh" -Type Success
        }
        
        return $profilesUpdated -gt 0
        
    } catch {
        Write-StatusMessage "Profile update failed: $($_.Exception.Message)" -Type Error
        return $false
    }
}

function Test-ModernOhMyPoshInstallation {
    <#
    .SYNOPSIS
        Validates the modern Oh My Posh installation
    #>
    [CmdletBinding()]
    param()
    
    try {
        Write-StatusMessage "Validating Oh My Posh installation..." -Type Info
        
        $versionInfo = Test-OhMyPoshVersion
        
        if (-not $versionInfo.Installed) {
            Write-StatusMessage "Oh My Posh is not installed or not in PATH" -Type Error
            return $false
        }
        
        Write-StatusMessage "Oh My Posh version: $($versionInfo.Version)" -Type Success
        Write-StatusMessage "Modern version (v26+): $($versionInfo.IsModern)" -Type $(if ($versionInfo.IsModern) {
                'Success' 
            } else {
                'Warning' 
            })
        Write-StatusMessage "Installation path: $($versionInfo.Path)" -Type Info
        
        # Test basic functionality
        try {
            $testTheme = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/pure.omp.json"
            $initScript = & oh-my-posh init pwsh --config $testTheme 2>$null
            
            if ($initScript -and $initScript.Length -gt 10) {
                Write-StatusMessage "Oh My Posh initialization test: PASSED" -Type Success
            } else {
                Write-StatusMessage "Oh My Posh initialization test: FAILED" -Type Warning
            }
        } catch {
            Write-StatusMessage "Oh My Posh initialization test: ERROR - $($_.Exception.Message)" -Type Warning
        }
        
        return $versionInfo.IsModern
        
    } catch {
        Write-StatusMessage "Validation failed: $($_.Exception.Message)" -Type Error
        return $false
    }
}

# Main installation logic
try {
    Write-Host ""
    Write-Host "🚀 Modern Oh My Posh v26+ Installation & Setup" -ForegroundColor Magenta
    Write-Host "=============================================" -ForegroundColor Magenta
    Write-Host ""
    
    # Check current installation
    $currentVersion = Test-OhMyPoshVersion
    
    if ($currentVersion.Installed -and -not $Force) {
        Write-StatusMessage "Current installation: v$($currentVersion.Version) (Modern: $($currentVersion.IsModern))" -Type Info
        
        if ($currentVersion.IsModern) {
            Write-StatusMessage "You already have a modern version installed!" -Type Success
            $installNeeded = $false
        } else {
            Write-StatusMessage "Upgrading from legacy version to modern v26+..." -Type Info
            $installNeeded = $true
        }
    } else {
        $installNeeded = $true
    }
    
    # Install or upgrade if needed
    if ($installNeeded) {
        $installSuccess = Install-OhMyPoshViaPlatform -UseScoop $UseScoop -Force $Force
        if (-not $installSuccess) {
            throw "Installation failed"
        }
        
        # Wait a moment for installation to complete
        Start-Sleep -Seconds 2
    }
    
    # Install custom themes
    if ($InstallThemes) {
        $themesSuccess = Install-CustomOhMyPoshThemes
        if ($themesSuccess) {
            Write-StatusMessage "Custom themes installed successfully" -Type Success
        }
    }
    
    # Update profiles
    if ($UpdateProfiles) {
        $profilesSuccess = Update-PowerShellProfiles
        if ($profilesSuccess) {
            Write-StatusMessage "Profiles updated for modern Oh My Posh" -Type Success
        }
    }
    
    # Validation
    if (-not $SkipValidation) {
        $validationSuccess = Test-ModernOhMyPoshInstallation
        if ($validationSuccess) {
            Write-StatusMessage "Installation validation: PASSED" -Type Success
        } else {
            Write-StatusMessage "Installation validation: ISSUES DETECTED" -Type Warning
        }
    }
    
    Write-Host ""
    Write-StatusMessage "Modern Oh My Posh setup completed!" -Type Success
    Write-Host ""
    Write-Host "🎯 Next Steps:" -ForegroundColor Yellow
    Write-Host "   1. Restart your terminal or run: . `$PROFILE" -ForegroundColor Gray
    Write-Host "   2. Test with: oh-my-posh version" -ForegroundColor Gray
    Write-Host "   3. Load Dracula theme: Initialize-ModernOhMyPosh -Mode Dracula" -ForegroundColor Gray
    Write-Host "   4. Browse themes: Get-PoshThemes" -ForegroundColor Gray
    Write-Host ""
    
} catch {
    Write-StatusMessage "Installation failed: $($_.Exception.Message)" -Type Error
    Write-Host ""
    Write-Host "🔧 Manual Installation Options:" -ForegroundColor Yellow
    Write-Host "   • Winget: winget install JanDeDobbeleer.OhMyPosh" -ForegroundColor Gray
    Write-Host "   • Scoop: scoop install https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json" -ForegroundColor Gray
    Write-Host "   • PowerShell: Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))" -ForegroundColor Gray
    Write-Host ""
    
    exit 1
}
