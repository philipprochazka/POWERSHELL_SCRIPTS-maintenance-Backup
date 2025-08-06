#Requires -Version 5.1

<#
.SYNOPSIS
    Enhanced Oh My Posh Integration for UnifiedPowerShellProfile
    
.DESCRIPTION
    This script enhances the existing Oh My Posh integration within the UnifiedPowerShellProfile system,
    ensuring backward compatibility while adding modern v26+ features and graceful fallbacks.
    
.PARAMETER Force
    Force reinstallation even if Oh My Posh is already installed
    
.PARAMETER InstallLatest
    Install the latest version of Oh My Posh
    
.PARAMETER UpdateThemes
    Update and install custom themes
    
.PARAMETER TestIntegration
    Test the integration after installation
    
.EXAMPLE
    .\Install-EnhancedOhMyPoshIntegration.ps1 -InstallLatest -UpdateThemes -TestIntegration
    
.NOTES
    This preserves Oh My Posh as a core component while enhancing its integration
#>

[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$InstallLatest,
    [switch]$UpdateThemes,
    [switch]$TestIntegration
)

#region Helper Functions

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
        'Info'    = '💡'
        'Success' = '✅'
        'Warning' = '⚠️'
        'Error'   = '❌'
    }
    
    Write-Host "$($icons[$Type]) $Message" -ForegroundColor $colors[$Type]
}

function Test-OhMyPoshInstallation {
    $ohMyPoshCmd = Get-Command oh-my-posh -ErrorAction SilentlyContinue
    if ($ohMyPoshCmd) {
        try {
            $version = & oh-my-posh version 2>$null
            $versionNumber = [version]($version -replace '[^\d\.].*$')
            return @{
                Installed     = $true
                Version       = $version
                VersionNumber = $versionNumber
                Path          = $ohMyPoshCmd.Source
                IsModern      = $versionNumber.Major -ge 26
            }
        } catch {
            return @{
                Installed     = $true
                Version       = "Unknown"
                VersionNumber = [version]"0.0.0"
                Path          = $ohMyPoshCmd.Source
                IsModern      = $false
            }
        }
    }
    
    return @{
        Installed     = $false
        Version       = $null
        VersionNumber = $null
        Path          = $null
        IsModern      = $false
    }
}

function Install-OhMyPoshIfNeeded {
    param([switch]$Force)
    
    $installation = Test-OhMyPoshInstallation
    
    if ($installation.Installed -and -not $Force) {
        Write-StatusMessage "Oh My Posh already installed: v$($installation.Version)" -Type Success
        return $installation
    }
    
    Write-StatusMessage "Installing Oh My Posh..." -Type Info
    
    # Try winget first (preferred method)
    try {
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            Write-StatusMessage "Using winget to install Oh My Posh..." -Type Info
            $result = winget install JanDeDobbeleer.OhMyPosh -s winget --accept-package-agreements --accept-source-agreements
            if ($LASTEXITCODE -eq 0) {
                Write-StatusMessage "Oh My Posh installed successfully via winget" -Type Success
                # Refresh PATH
                $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
                return Test-OhMyPoshInstallation
            }
        }
    } catch {
        Write-StatusMessage "Winget installation failed: $($_.Exception.Message)" -Type Warning
    }
    
    # Try Scoop as fallback
    try {
        if (Get-Command scoop -ErrorAction SilentlyContinue) {
            Write-StatusMessage "Using Scoop to install Oh My Posh..." -Type Info
            scoop install https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json
            if ($LASTEXITCODE -eq 0) {
                Write-StatusMessage "Oh My Posh installed successfully via Scoop" -Type Success
                return Test-OhMyPoshInstallation
            }
        }
    } catch {
        Write-StatusMessage "Scoop installation failed: $($_.Exception.Message)" -Type Warning
    }
    
    # Manual installation as last resort
    try {
        Write-StatusMessage "Attempting manual installation..." -Type Info
        $installScript = Invoke-RestMethod https://ohmyposh.dev/install.ps1
        Invoke-Expression $installScript
        Write-StatusMessage "Oh My Posh installed successfully via manual method" -Type Success
        return Test-OhMyPoshInstallation
    } catch {
        Write-StatusMessage "Manual installation failed: $($_.Exception.Message)" -Type Error
        return @{ Installed = $false }
    }
}

function Update-OhMyPoshThemes {
    Write-StatusMessage "Updating Oh My Posh themes..." -Type Info
    
    $themesPath = $env:POSH_THEMES_PATH
    if (-not $themesPath) {
        # Try to detect themes path
        $possiblePaths = @(
            "$env:LOCALAPPDATA\Programs\oh-my-posh\themes",
            "$env:APPDATA\oh-my-posh\themes",
            "${env:ProgramFiles}\oh-my-posh\themes",
            "${env:ProgramFiles(x86)}\oh-my-posh\themes"
        )
        
        foreach ($path in $possiblePaths) {
            if (Test-Path $path) {
                $themesPath = $path
                $env:POSH_THEMES_PATH = $path
                break
            }
        }
    }
    
    if ($themesPath -and (Test-Path $themesPath)) {
        Write-StatusMessage "Themes found at: $themesPath" -Type Success
        
        # Create custom Dracula theme if it doesn't exist
        $draculaTheme = Join-Path $themesPath "dracula.omp.json"
        if (-not (Test-Path $draculaTheme)) {
            Write-StatusMessage "Creating enhanced Dracula theme..." -Type Info
            $draculaThemeContent = @"
{
  "`$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
  "version": 2,
  "final_space": true,
  "console_title_template": "{{.Shell}} in {{.Folder}}",
  "blocks": [
    {
      "type": "prompt",
      "alignment": "left",
      "segments": [
        {
          "type": "session",
          "style": "diamond",
          "foreground": "#ffffff",
          "background": "#bd93f9",
          "leading_diamond": "╭─",
          "template": " {{ .UserName }} "
        },
        {
          "type": "path",
          "style": "powerline",
          "powerline_symbol": "",
          "foreground": "#282a36",
          "background": "#8be9fd",
          "template": " {{ .Path }} ",
          "properties": {
            "style": "folder"
          }
        },
        {
          "type": "git",
          "style": "powerline",
          "powerline_symbol": "",
          "foreground": "#282a36",
          "background": "#50fa7b",
          "template": " {{ .HEAD }}{{if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }} {{ .Working.String }}{{ end }}{{ if and (.Working.Changed) (.Staging.Changed) }} |{{ end }}{{ if .Staging.Changed }} {{ .Staging.String }}{{ end }} ",
          "properties": {
            "branch_max_length": 25,
            "fetch_status": true,
            "fetch_upstream_icon": true
          }
        },
        {
          "type": "node",
          "style": "powerline",
          "powerline_symbol": "",
          "foreground": "#ffffff",
          "background": "#68d391",
          "template": " {{ if .PackageManagerIcon }}{{ .PackageManagerIcon }} {{ end }}{{ .Full }} "
        },
        {
          "type": "python",
          "style": "powerline",
          "powerline_symbol": "",
          "foreground": "#282a36",
          "background": "#ffb86c",
          "template": " {{ if .Error }}{{ .Error }}{{ else }}{{ if .Venv }}{{ .Venv }} {{ end }}{{ .Full }}{{ end }} "
        },
        {
          "type": "time",
          "style": "diamond",
          "foreground": "#282a36",
          "background": "#f1fa8c",
          "trailing_diamond": "",
          "template": " {{ .CurrentDate | date .Format }} "
        }
      ]
    },
    {
      "type": "prompt",
      "alignment": "right",
      "segments": [
        {
          "type": "executiontime",
          "style": "plain",
          "foreground": "#6272a4",
          "template": "{{ .FormattedMs }}",
          "properties": {
            "threshold": 5000
          }
        }
      ]
    },
    {
      "type": "prompt",
      "alignment": "left",
      "newline": true,
      "segments": [
        {
          "type": "text",
          "style": "plain",
          "foreground": "#bd93f9",
          "template": "╰─"
        },
        {
          "type": "exit",
          "style": "plain",
          "foreground": "#f8f8f2",
          "foreground_templates": [
            "{{ if gt .Code 0 }}#ff5555{{ end }}"
          ],
          "template": "❯",
          "properties": {
            "always_enabled": true
          }
        }
      ]
    }
  ]
}
"@
            Set-Content -Path $draculaTheme -Value $draculaThemeContent -Encoding UTF8
            Write-StatusMessage "Enhanced Dracula theme created" -Type Success
        }
        
        return $true
    } else {
        Write-StatusMessage "Could not locate Oh My Posh themes directory" -Type Warning
        return $false
    }
}

function Test-UnifiedProfileIntegration {
    Write-StatusMessage "Testing UnifiedPowerShellProfile integration..." -Type Info
    
    # Test if UnifiedPowerShellProfile module is available
    $unifiedModule = Get-Module UnifiedPowerShellProfile -ListAvailable | Select-Object -First 1
    if (-not $unifiedModule) {
        Write-StatusMessage "UnifiedPowerShellProfile module not found" -Type Warning
        return $false
    }
    
    Write-StatusMessage "UnifiedPowerShellProfile module found: v$($unifiedModule.Version)" -Type Success
    
    # Test if Initialize-ModernOhMyPosh is available
    try {
        Import-Module UnifiedPowerShellProfile -Force -ErrorAction Stop
        
        if (Get-Command Initialize-ModernOhMyPosh -ErrorAction SilentlyContinue) {
            Write-StatusMessage "Initialize-ModernOhMyPosh function available" -Type Success
            
            # Test the function
            try {
                Initialize-ModernOhMyPosh -Mode 'Dracula' -Verbose
                Write-StatusMessage "Oh My Posh initialization test successful" -Type Success
                return $true
            } catch {
                Write-StatusMessage "Oh My Posh initialization test failed: $($_.Exception.Message)" -Type Warning
                return $false
            }
        } else {
            Write-StatusMessage "Initialize-ModernOhMyPosh function not found" -Type Warning
            return $false
        }
    } catch {
        Write-StatusMessage "Failed to import UnifiedPowerShellProfile: $($_.Exception.Message)" -Type Error
        return $false
    }
}

#endregion

#region Main Installation Process

function Install-EnhancedOhMyPoshIntegration {
    Write-Host ""
    Write-Host "🧛‍♂️ Enhanced Oh My Posh Integration for UnifiedPowerShellProfile" -ForegroundColor Magenta
    Write-Host "=" * 60 -ForegroundColor Gray
    Write-Host ""
    
    # Step 1: Check current installation
    Write-StatusMessage "Checking current Oh My Posh installation..." -Type Info
    $currentInstallation = Test-OhMyPoshInstallation
    
    if ($currentInstallation.Installed) {
        Write-StatusMessage "Current installation: v$($currentInstallation.Version) at $($currentInstallation.Path)" -Type Info
        if ($currentInstallation.IsModern) {
            Write-StatusMessage "Modern version (v26+) detected - Full feature support available" -Type Success
        } else {
            Write-StatusMessage "Legacy version detected - Consider upgrading for full features" -Type Warning
        }
    } else {
        Write-StatusMessage "Oh My Posh not found - Installation required" -Type Warning
    }
    
    # Step 2: Install or update Oh My Posh if needed
    if (-not $currentInstallation.Installed -or $InstallLatest -or $Force) {
        $installation = Install-OhMyPoshIfNeeded -Force:$Force
        if (-not $installation.Installed) {
            Write-StatusMessage "Failed to install Oh My Posh - Aborting" -Type Error
            return $false
        }
    }
    
    # Step 3: Update themes
    if ($UpdateThemes) {
        $themesResult = Update-OhMyPoshThemes
        if (-not $themesResult) {
            Write-StatusMessage "Theme update failed, but continuing..." -Type Warning
        }
    }
    
    # Step 4: Test integration
    if ($TestIntegration) {
        $integrationResult = Test-UnifiedProfileIntegration
        if (-not $integrationResult) {
            Write-StatusMessage "Integration test failed - Manual verification recommended" -Type Warning
        }
    }
    
    # Step 5: Final summary
    Write-Host ""
    Write-StatusMessage "Enhanced Oh My Posh integration complete!" -Type Success
    Write-Host ""
    Write-Host "📋 Next Steps:" -ForegroundColor Cyan
    Write-Host "   1. Restart PowerShell to refresh PATH" -ForegroundColor Yellow
    Write-Host "   2. Run: Import-Module UnifiedPowerShellProfile -Force" -ForegroundColor Yellow
    Write-Host "   3. Run: Initialize-UnifiedProfile -Mode Dracula" -ForegroundColor Yellow
    Write-Host "   4. Test with: Initialize-ModernOhMyPosh -Mode Dracula" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "💡 Advanced Usage:" -ForegroundColor Cyan
    Write-Host "   • Check version: oh-my-posh version" -ForegroundColor Gray
    Write-Host "   • List themes: Get-PoshThemes (if available)" -ForegroundColor Gray
    Write-Host "   • Custom theme: Initialize-ModernOhMyPosh -ThemePath 'path/to/theme.omp.json'" -ForegroundColor Gray
    Write-Host ""
    
    return $true
}

#endregion

# Execute the installation
if ($MyInvocation.InvocationName -ne '.') {
    try {
        $success = Install-EnhancedOhMyPoshIntegration
        if ($success) {
            Write-Host "🎉 Installation completed successfully!" -ForegroundColor Green
            exit 0
        } else {
            Write-Host "❌ Installation failed!" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "💥 Installation error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Gray
        exit 1
    }
}
