# ========================================
# Install-UnifiedProfileSystem.ps1
# Comprehensive installation with registry modifications
# ========================================

[CmdletBinding()]
param(
    [switch]$IncludeRegistryChanges,
    [string]$InstallScope = "CurrentUser", # CurrentUser, AllUsers, or Both
    [switch]$Force,
    [switch]$WhatIf
)

function Install-UnifiedProfileSystem {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$IncludeRegistryChanges,
        [string]$InstallScope = "CurrentUser",
        [switch]$Force
    )
    
    Write-Host "🚀 Installing UnifiedPowerShellProfile System..." -ForegroundColor Cyan
    
    # Get current script location
    $ScriptPath = if ($MyInvocation.MyCommand.Path) {
        Split-Path -Parent $MyInvocation.MyCommand.Path
    }
    else {
        $PWD.Path
    }
    $ModulePath = Join-Path $ScriptPath "UnifiedPowerShellProfile"
    
    try {
        # 1. Update PSModulePath
        Update-PSModulePath -ModulePath $ScriptPath -Scope $InstallScope
        
        # 2. Install the module
        Install-ModuleFiles -SourcePath $ScriptPath -Scope $InstallScope
        
        # 3. Configure PowerShell profiles
        Install-ProfileConfiguration -Scope $InstallScope
        
        # 4. Registry modifications (if requested)
        if ($IncludeRegistryChanges) {
            Set-PowerShellRegistrySettings -Scope $InstallScope
        }
        
        # 5. Verify installation
        Test-InstallationIntegrity
        
        Write-Host "✅ UnifiedPowerShellProfile System installed successfully!" -ForegroundColor Green
        Write-Host "🔄 Please restart your PowerShell sessions or run:" -ForegroundColor Yellow
        Write-Host "   Import-Module UnifiedPowerShellProfile -Force" -ForegroundColor White
        
    }
    catch {
        Write-Error "❌ Installation failed: $($_.Exception.Message)"
        throw
    }
}

function Update-PSModulePath {
    [CmdletBinding()]
    param(
        [string]$ModulePath,
        [string]$Scope
    )
    
    Write-Host "📂 Updating PSModulePath..." -ForegroundColor Yellow
    
    $Scopes = @()
    switch ($Scope) {
        "CurrentUser" { $Scopes = @("User") }
        "AllUsers" { $Scopes = @("Machine") }
        "Both" { $Scopes = @("User", "Machine") }
    }
    
    foreach ($EnvScope in $Scopes) {
        $CurrentPath = [Environment]::GetEnvironmentVariable('PSModulePath', $EnvScope)
        
        if ($CurrentPath -notlike "*$ModulePath*") {
            if ($PSCmdlet.ShouldProcess("PSModulePath ($EnvScope)", "Add $ModulePath")) {
                $NewPath = "$ModulePath;$CurrentPath"
                [Environment]::SetEnvironmentVariable('PSModulePath', $NewPath, $EnvScope)
                Write-Host "  ✅ Added to PSModulePath ($EnvScope): $ModulePath" -ForegroundColor Green
            }
        }
        else {
            Write-Host "  ℹ️ Already in PSModulePath ($EnvScope): $ModulePath" -ForegroundColor Gray
        }
    }
    
    # Update current session
    $env:PSModulePath = "$ModulePath;$env:PSModulePath"
}

function Install-ModuleFiles {
    [CmdletBinding()]
    param(
        [string]$SourcePath,
        [string]$Scope
    )
    
    Write-Host "📦 Installing module files..." -ForegroundColor Yellow
    
    # Determine target directories
    $Targets = @()
    switch ($Scope) {
        "CurrentUser" { 
            $UserModulesPath = Join-Path $env:USERPROFILE "Documents\PowerShell\Modules"
            $Targets = @($UserModulesPath)
        }
        "AllUsers" { 
            $SystemModulesPath = Join-Path $env:ProgramFiles "PowerShell\Modules"
            $Targets = @($SystemModulesPath)
        }
        "Both" { 
            $UserModulesPath = Join-Path $env:USERPROFILE "Documents\PowerShell\Modules"
            $SystemModulesPath = Join-Path $env:ProgramFiles "PowerShell\Modules"
            $Targets = @($UserModulesPath, $SystemModulesPath)
        }
    }
    
    foreach ($TargetBase in $Targets) {
        $TargetPath = Join-Path $TargetBase "UnifiedPowerShellProfile"
        
        if ($PSCmdlet.ShouldProcess($TargetPath, "Copy module files")) {
            # Create target directory
            New-Item -Path $TargetPath -ItemType Directory -Force | Out-Null
            
            # Copy module files
            $SourceFiles = @(
                "UnifiedPowerShellProfile.psm1",
                "UnifiedPowerShellProfile.psd1",
                "README.md"
            )
            
            foreach ($File in $SourceFiles) {
                $SourceFile = Join-Path $SourcePath $File
                if (Test-Path $SourceFile) {
                    Copy-Item $SourceFile -Destination $TargetPath -Force
                    Write-Host "  ✅ Copied: $File → $TargetPath" -ForegroundColor Green
                }
            }
            
            # Copy additional directories if they exist
            $AdditionalDirs = @("docs", "Tests", "assets")
            foreach ($Dir in $AdditionalDirs) {
                $SourceDir = Join-Path $SourcePath $Dir
                if (Test-Path $SourceDir) {
                    $TargetDir = Join-Path $TargetPath $Dir
                    Copy-Item $SourceDir -Destination $TargetDir -Recurse -Force
                    Write-Host "  ✅ Copied directory: $Dir → $TargetPath" -ForegroundColor Green
                }
            }
        }
    }
}

function Install-ProfileConfiguration {
    [CmdletBinding()]
    param(
        [string]$Scope
    )
    
    Write-Host "🔧 Configuring PowerShell profiles..." -ForegroundColor Yellow
    
    $ProfileScript = @'
# UnifiedPowerShellProfile Auto-Import
if (-not (Get-Module UnifiedPowerShellProfile -ListAvailable)) {
    Write-Warning "UnifiedPowerShellProfile module not found in PSModulePath"
} else {
    try {
        Import-Module UnifiedPowerShellProfile -Force -ErrorAction SilentlyContinue
        if (Get-Command Initialize-UnifiedProfile -ErrorAction SilentlyContinue) {
            Initialize-UnifiedProfile -Mode Auto -Silent
        }
    } catch {
        Write-Warning "Failed to initialize UnifiedPowerShellProfile: $($_.Exception.Message)"
    }
}
'@
    
    $Profiles = @()
    switch ($Scope) {
        "CurrentUser" { 
            $Profiles = @($PROFILE.CurrentUserCurrentHost, $PROFILE.CurrentUserAllHosts)
        }
        "AllUsers" { 
            $Profiles = @($PROFILE.AllUsersCurrentHost, $PROFILE.AllUsersAllHosts)
        }
        "Both" { 
            $Profiles = @(
                $PROFILE.CurrentUserCurrentHost, 
                $PROFILE.CurrentUserAllHosts,
                $PROFILE.AllUsersCurrentHost, 
                $PROFILE.AllUsersAllHosts
            )
        }
    }
    
    foreach ($ProfilePath in $Profiles) {
        if ($PSCmdlet.ShouldProcess($ProfilePath, "Update PowerShell profile")) {
            try {
                # Create profile directory if it doesn't exist
                $ProfileDir = Split-Path $ProfilePath -Parent
                if (-not (Test-Path $ProfileDir)) {
                    New-Item -Path $ProfileDir -ItemType Directory -Force | Out-Null
                }
                
                # Check if our script is already in the profile
                $ProfileContent = ""
                if (Test-Path $ProfilePath) {
                    $ProfileContent = Get-Content $ProfilePath -Raw
                }
                
                if ($ProfileContent -notlike "*UnifiedPowerShellProfile*") {
                    # Append our initialization script
                    Add-Content -Path $ProfilePath -Value "`n# === UnifiedPowerShellProfile Auto-Import ===`n$ProfileScript`n# === End UnifiedPowerShellProfile ===`n"
                    Write-Host "  ✅ Updated profile: $ProfilePath" -ForegroundColor Green
                }
                else {
                    Write-Host "  ℹ️ Profile already configured: $ProfilePath" -ForegroundColor Gray
                }
                
            }
            catch {
                Write-Warning "Failed to update profile $ProfilePath : $($_.Exception.Message)"
            }
        }
    }
}

function Set-PowerShellRegistrySettings {
    [CmdletBinding()]
    param(
        [string]$Scope
    )
    
    Write-Host "🔐 Configuring registry settings..." -ForegroundColor Yellow
    
    $RegistrySettings = @{
        "HKCU:\Software\Microsoft\PowerShell\1\PowerShellEngine" = @{
            "ExecutionPolicy" = "RemoteSigned"
        }
        "HKCU:\Software\Microsoft\PowerShell\1\PSReadline"       = @{
            "HistorySearchCursorMovesToEnd" = 1
            "MaximumHistoryCount"           = 4096
            "ShowToolTips"                  = 1
        }
    }
    
    if ($Scope -eq "AllUsers" -or $Scope -eq "Both") {
        $RegistrySettings["HKLM:\SOFTWARE\Microsoft\PowerShell\1\PowerShellEngine"] = @{
            "ExecutionPolicy" = "RemoteSigned"
        }
    }
    
    foreach ($RegPath in $RegistrySettings.Keys) {
        if ($PSCmdlet.ShouldProcess($RegPath, "Configure registry settings")) {
            try {
                # Create registry key if it doesn't exist
                if (-not (Test-Path $RegPath)) {
                    New-Item -Path $RegPath -Force | Out-Null
                }
                
                # Set values
                foreach ($Property in $RegistrySettings[$RegPath].Keys) {
                    $Value = $RegistrySettings[$RegPath][$Property]
                    Set-ItemProperty -Path $RegPath -Name $Property -Value $Value -Force
                    Write-Host "  ✅ Set $RegPath\$Property = $Value" -ForegroundColor Green
                }
                
            }
            catch {
                Write-Warning "Failed to configure registry at $RegPath : $($_.Exception.Message)"
            }
        }
    }
}

function Test-InstallationIntegrity {
    [CmdletBinding()]
    param()
    
    Write-Host "🔍 Verifying installation..." -ForegroundColor Yellow
    
    $ValidationResults = @()
    
    # Test 1: Module availability
    $Module = Get-Module UnifiedPowerShellProfile -ListAvailable -ErrorAction SilentlyContinue
    if ($Module) {
        $ValidationResults += "✅ Module found in PSModulePath"
        Write-Host "  ✅ Module version: $($Module.Version)" -ForegroundColor Green
    }
    else {
        $ValidationResults += "❌ Module not found in PSModulePath"
        Write-Host "  ❌ Module not accessible" -ForegroundColor Red
    }
    
    # Test 2: Import capability
    try {
        Import-Module UnifiedPowerShellProfile -Force -ErrorAction Stop
        $ValidationResults += "✅ Module imports successfully"
        Write-Host "  ✅ Module imports without errors" -ForegroundColor Green
        
        # Test 3: Core functions available
        $CoreFunctions = @("Initialize-UnifiedProfile", "Invoke-SmartLinting", "Get-QualityScore")
        foreach ($Function in $CoreFunctions) {
            if (Get-Command $Function -ErrorAction SilentlyContinue) {
                $ValidationResults += "✅ Function available: $Function"
            }
            else {
                $ValidationResults += "❌ Function missing: $Function"
                Write-Host "  ❌ Missing function: $Function" -ForegroundColor Red
            }
        }
        
    }
    catch {
        $ValidationResults += "❌ Module import failed: $($_.Exception.Message)"
        Write-Host "  ❌ Import failed: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    # Test 4: PSScriptAnalyzer dependency
    if (Get-Module PSScriptAnalyzer -ListAvailable) {
        $ValidationResults += "✅ PSScriptAnalyzer dependency available"
    }
    else {
        $ValidationResults += "⚠️ PSScriptAnalyzer not found (optional dependency)"
        Write-Host "  ⚠️ Consider installing PSScriptAnalyzer for full functionality" -ForegroundColor Yellow
    }
    
    return $ValidationResults
}

# Main execution
if ($MyInvocation.InvocationName -ne '.') {
    Install-UnifiedProfileSystem -IncludeRegistryChanges:$IncludeRegistryChanges -InstallScope $InstallScope -WhatIf:$WhatIf
}
