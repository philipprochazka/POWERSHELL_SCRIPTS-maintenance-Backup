# =============================================
# Install-PowerShell7SystemWide.ps1
# Install PowerShell 7+ system-wide with profile
# =============================================

[CmdletBinding()]
param(
    [switch]$SkipPowerShell7Install,
    [switch]$ProfileOnly,
    [switch]$WhatIf
)

function Install-PowerShell7 {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    try {
        # Check if PowerShell 7+ is already installed
        $ps7Installed = Get-Command pwsh -ErrorAction SilentlyContinue
        if ($ps7Installed) {
            $version = & pwsh -Command '$PSVersionTable.PSVersion'
            Write-Host "✅ PowerShell 7+ already installed: v$version" -ForegroundColor Green
            return $true
        }
        
        Write-Host "📥 Installing PowerShell 7+ system-wide..." -ForegroundColor Cyan
        
        if ($PSCmdlet.ShouldProcess("System", "Install PowerShell 7+")) {
            # Use winget if available, otherwise use direct download
            if (Get-Command winget -ErrorAction SilentlyContinue) {
                Write-Host "Using winget to install PowerShell..." -ForegroundColor Yellow
                & winget install Microsoft.PowerShell
            } else {
                # Fallback to direct installation
                Write-Host "Using direct download method..." -ForegroundColor Yellow
                $downloadUrl = "https://github.com/PowerShell/PowerShell/releases/latest/download/PowerShell-7-win-x64.msi"
                $tempFile = Join-Path $env:TEMP "PowerShell-7-win-x64.msi"
                
                Invoke-WebRequest -Uri $downloadUrl -OutFile $tempFile
                Start-Process msiexec.exe -ArgumentList "/i `"$tempFile`" /quiet" -Wait
                Remove-Item $tempFile -Force
            }
            
            # Verify installation
            $ps7Installed = Get-Command pwsh -ErrorAction SilentlyContinue
            if ($ps7Installed) {
                Write-Host "✅ PowerShell 7+ installed successfully!" -ForegroundColor Green
                return $true
            } else {
                Write-Error "PowerShell 7+ installation failed"
                return $false
            }
        }
    } catch {
        Write-Error "Failed to install PowerShell 7+: $($_.Exception.Message)"
        return $false
    }
}

function Install-ProfileSystemWide {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    try {
        Write-Host "🎨 Installing Dracula profile system-wide..." -ForegroundColor Cyan
        
        # Define profile paths for both PowerShell editions
        $profiles = @{
            "PowerShell 7+ (Current User)" = (& pwsh -Command '$PROFILE.CurrentUserCurrentHost')
            "PowerShell 7+ (All Users)" = (& pwsh -Command '$PROFILE.AllUsersCurrentHost')
            "Windows PowerShell (Current User)" = (powershell -Command '$PROFILE.CurrentUserCurrentHost')
            "Windows PowerShell (All Users)" = (powershell -Command '$PROFILE.AllUsersCurrentHost')
        }
        
        $sourceProfile = Join-Path $PSScriptRoot "Microsoft.PowerShell_profile_Dracula.ps1"
        if (-not (Test-Path $sourceProfile)) {
            Write-Error "Source profile not found: $sourceProfile"
            return $false
        }
        
        foreach ($profileInfo in $profiles.GetEnumerator()) {
            $profilePath = $profileInfo.Value
            $profileName = $profileInfo.Key
            
            Write-Host "📋 Installing profile for: $profileName" -ForegroundColor Yellow
            Write-Host "   Path: $profilePath" -ForegroundColor Gray
            
            if ($PSCmdlet.ShouldProcess($profilePath, "Install Dracula profile")) {
                try {
                    # Create profile directory if it doesn't exist
                    $profileDir = Split-Path $profilePath -Parent
                    if (-not (Test-Path $profileDir)) {
                        New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
                        Write-Host "   ✅ Created profile directory" -ForegroundColor Green
                    }
                    
                    # Copy the profile
                    Copy-Item $sourceProfile $profilePath -Force
                    Write-Host "   ✅ Profile installed successfully" -ForegroundColor Green
                    
                } catch {
                    if ($_.Exception.Message -like "*access*denied*" -or $_.Exception.Message -like "*permission*") {
                        Write-Warning "   ⚠️  Access denied - requires administrator privileges for: $profileName"
                    } else {
                        Write-Warning "   ❌ Failed to install profile for $profileName : $($_.Exception.Message)"
                    }
                }
            }
        }
        
        return $true
        
    } catch {
        Write-Error "Failed to install profiles: $($_.Exception.Message)"
        return $false
    }
}

function Set-PowerShell7DefaultShell {
    [CmdletBinding(SupportsShouldProcess)]
    param()
    
    try {
        Write-Host "🔧 Configuring PowerShell 7 as default shell..." -ForegroundColor Cyan
        
        # Get PowerShell 7 path
        $ps7Path = (Get-Command pwsh -ErrorAction SilentlyContinue).Source
        if (-not $ps7Path) {
            Write-Warning "PowerShell 7 not found in PATH"
            return $false
        }
        
        if ($PSCmdlet.ShouldProcess("Registry", "Set PowerShell 7 as default shell")) {
            # Windows Terminal configuration
            $wtSettingsPath = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
            if (Test-Path $wtSettingsPath) {
                try {
                    $wtSettings = Get-Content $wtSettingsPath -Raw | ConvertFrom-Json
                    
                    # Find PowerShell 7 profile GUID
                    $ps7Profile = $wtSettings.profiles.list | Where-Object { $_.name -like "*PowerShell 7*" -or $_.commandline -like "*pwsh*" }
                    if ($ps7Profile) {
                        $wtSettings.defaultProfile = $ps7Profile.guid
                        $wtSettings | ConvertTo-Json -Depth 10 | Set-Content $wtSettingsPath -Encoding UTF8
                        Write-Host "   ✅ Windows Terminal default shell set to PowerShell 7" -ForegroundColor Green
                    }
                } catch {
                    Write-Warning "   ⚠️  Could not update Windows Terminal settings: $($_.Exception.Message)"
                }
            }
            
            # VS Code configuration
            $vsCodeSettingsPath = Join-Path $env:APPDATA "Code\User\settings.json"
            if (Test-Path $vsCodeSettingsPath) {
                try {
                    $vsCodeSettings = Get-Content $vsCodeSettingsPath -Raw | ConvertFrom-Json
                    $vsCodeSettings."terminal.integrated.defaultProfile.windows" = "PowerShell 7"
                    $vsCodeSettings."terminal.integrated.profiles.windows" = @{
                        "PowerShell 7" = @{
                            "path" = $ps7Path
                            "args" = @()
                            "icon" = "terminal-powershell"
                        }
                        "Windows PowerShell" = @{
                            "path" = "powershell.exe"
                            "args" = @()
                        }
                    }
                    $vsCodeSettings | ConvertTo-Json -Depth 10 | Set-Content $vsCodeSettingsPath -Encoding UTF8
                    Write-Host "   ✅ VS Code default terminal set to PowerShell 7" -ForegroundColor Green
                } catch {
                    Write-Warning "   ⚠️  Could not update VS Code settings: $($_.Exception.Message)"
                }
            }
        }
        
        return $true
        
    } catch {
        Write-Error "Failed to configure PowerShell 7 as default: $($_.Exception.Message)"
        return $false
    }
}

function Test-Installation {
    [CmdletBinding()]
    param()
    
    Write-Host "🧪 Testing PowerShell 7 installation..." -ForegroundColor Cyan
    
    $results = @{
        PowerShell7Installed = $false
        ProfilesInstalled = 0
        DefaultShellConfigured = $false
    }
    
    # Test PowerShell 7 installation
    $ps7 = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($ps7) {
        $results.PowerShell7Installed = $true
        $version = & pwsh -Command '$PSVersionTable.PSVersion'
        Write-Host "   ✅ PowerShell 7+ installed: v$version" -ForegroundColor Green
    } else {
        Write-Host "   ❌ PowerShell 7+ not found" -ForegroundColor Red
    }
    
    # Test profile installations
    $profiles = @(
        (& pwsh -Command '$PROFILE.CurrentUserCurrentHost' -ErrorAction SilentlyContinue),
        (& pwsh -Command '$PROFILE.AllUsersCurrentHost' -ErrorAction SilentlyContinue),
        (powershell -Command '$PROFILE.CurrentUserCurrentHost' -ErrorAction SilentlyContinue),
        (powershell -Command '$PROFILE.AllUsersCurrentHost' -ErrorAction SilentlyContinue)
    )
    
    foreach ($profile in $profiles) {
        if ($profile -and (Test-Path $profile)) {
            $results.ProfilesInstalled++
            Write-Host "   ✅ Profile installed: $profile" -ForegroundColor Green
        }
    }
    
    if ($results.ProfilesInstalled -eq 0) {
        Write-Host "   ❌ No profiles installed" -ForegroundColor Red
    } else {
        Write-Host "   ✅ $($results.ProfilesInstalled) profile(s) installed" -ForegroundColor Green
    }
    
    # Test profile loading
    try {
        $testResult = & pwsh -NoProfile -Command {
            & $PROFILE.CurrentUserCurrentHost
            "Profile loaded successfully"
        } 2>&1
        
        if ($testResult -like "*Profile loaded successfully*") {
            Write-Host "   ✅ Profile loads without errors" -ForegroundColor Green
        } else {
            Write-Host "   ⚠️  Profile loading issues detected" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ❌ Profile loading failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    return $results
}

# Main execution
if ($MyInvocation.InvocationName -ne '.') {
    Write-Host "🚀 PowerShell 7 System-Wide Installation" -ForegroundColor Magenta
    Write-Host "=======================================" -ForegroundColor Magenta
    Write-Host ""
    
    $success = $true
    
    # Install PowerShell 7 if requested
    if (-not $SkipPowerShell7Install -and -not $ProfileOnly) {
        $success = Install-PowerShell7 -WhatIf:$WhatIf
        if (-not $success) {
            Write-Error "PowerShell 7 installation failed"
            exit 1
        }
        Write-Host ""
    }
    
    # Install profiles
    $success = Install-ProfileSystemWide -WhatIf:$WhatIf
    if (-not $success) {
        Write-Warning "Profile installation had issues"
    }
    Write-Host ""
    
    # Configure as default shell
    if (-not $ProfileOnly) {
        Set-PowerShell7DefaultShell -WhatIf:$WhatIf
        Write-Host ""
    }
    
    # Test the installation
    Write-Host ""
    $testResults = Test-Installation
    
    Write-Host ""
    Write-Host "🎉 Installation Summary:" -ForegroundColor Magenta
    Write-Host "========================" -ForegroundColor Magenta
    Write-Host "PowerShell 7+ Installed: $($testResults.PowerShell7Installed)" -ForegroundColor $(if($testResults.PowerShell7Installed) { "Green" } else { "Red" })
    Write-Host "Profiles Installed: $($testResults.ProfilesInstalled)" -ForegroundColor $(if($testResults.ProfilesInstalled -gt 0) { "Green" } else { "Red" })
    Write-Host ""
    
    if ($testResults.PowerShell7Installed -and $testResults.ProfilesInstalled -gt 0) {
        Write-Host "✅ Installation completed successfully!" -ForegroundColor Green
        Write-Host "🦇 Start a new PowerShell 7 session to enjoy the Dracula experience!" -ForegroundColor Magenta
    } else {
        Write-Host "⚠️  Installation completed with warnings. Check the output above." -ForegroundColor Yellow
    }
}
