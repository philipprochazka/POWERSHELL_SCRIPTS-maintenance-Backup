# ========================================
# Fix-ProfileCompatibility.ps1
# Fixes PowerShell profile compatibility issues
# ========================================

[CmdletBinding()]
param(
    [string]$ProfilePath = "Microsoft.PowerShell_profile_Dracula.ps1",
    [switch]$FixWindowsPowerShell,
    [switch]$WhatIf
)

function Update-ProfileCompatibility {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$ProfilePath,
        [switch]$FixWindowsPowerShell
    )
    
    Write-Host "🔧 Fixing PowerShell profile compatibility issues..." -ForegroundColor Cyan
    
    try {
        if (-not (Test-Path $ProfilePath)) {
            Write-Error "Profile file not found: $ProfilePath"
            return
        }
        
        $content = Get-Content $ProfilePath -Raw
        $changes = @()
        
        # Fix 1: Add PowerShell version detection
        $versionCheck = @'
# PowerShell Version Compatibility Check
$PSVersion = $PSVersionTable.PSVersion.Major
$IsWindowsPowerShell = $PSVersionTable.PSEdition -eq 'Desktop'
$IsPowerShell7Plus = $PSVersion -ge 7

'@
        
        if ($content -notlike "*PSVersion*") {
            $content = $versionCheck + "`n" + $content
            $changes += "Added PowerShell version detection"
        }
        
        # Fix 2: Wrap version-specific modules in compatibility checks
        $azToolsPredictorFix = @'
    # Az.Tools.Predictor (requires PowerShell 7.2+)
    if ($PSVersion -ge 7 -and $PSVersionTable.PSVersion.Minor -ge 2) {
        try {
            Import-Module Az.Tools.Predictor -ErrorAction SilentlyContinue
            Write-Host "📦 Loaded Az.Tools.Predictor" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  Az.Tools.Predictor not available" -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠️  Az.Tools.Predictor requires PowerShell 7.2+" -ForegroundColor Yellow
    }
'@
        
        # Replace direct Az.Tools.Predictor import
        $content = $content -replace "(?s)'Az\.Tools\.Predictor'.*?catch \{.*?\}", $azToolsPredictorFix
        $changes += "Fixed Az.Tools.Predictor compatibility"
        
        # Fix 3: Terminal-Icons compatibility
        $terminalIconsFix = @'
    # Terminal-Icons (different versions for different PowerShell editions)
    if ($IsPowerShell7Plus) {
        try {
            Import-Module Terminal-Icons -ErrorAction SilentlyContinue
            Write-Host "📦 Loaded Terminal-Icons" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  Terminal-Icons not available" -ForegroundColor Yellow
        }
    } else {
        # For Windows PowerShell 5.1, use compatible version or skip
        try {
            $terminalIconsVersion = (Get-Module Terminal-Icons -ListAvailable | Sort-Object Version -Descending)[0]
            if ($terminalIconsVersion -and $terminalIconsVersion.Version -lt [Version]"0.11.0") {
                Import-Module Terminal-Icons -ErrorAction SilentlyContinue
                Write-Host "📦 Loaded Terminal-Icons (compatible version)" -ForegroundColor Green
            } else {
                Write-Host "⚠️  Terminal-Icons requires PowerShell 7+ for latest features" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "⚠️  Terminal-Icons not available" -ForegroundColor Yellow
        }
    }
'@
        
        $content = $content -replace "(?s)'Terminal-Icons'.*?catch \{.*?\}", $terminalIconsFix
        $changes += "Fixed Terminal-Icons compatibility"
        
        # Fix 4: PSReadLine compatibility
        $psReadLineFix = @'
# PSReadLine Configuration (version-aware)
if (Get-Module PSReadLine -ListAvailable) {
    try {
        Import-Module PSReadLine -Force
        
        # Version-specific configurations
        $psReadLineVersion = (Get-Module PSReadLine).Version
        
        if ($psReadLineVersion -ge [Version]"2.2.0") {
            # Modern PSReadLine features
            try {
                Set-PSReadLineOption -PredictionSource HistoryAndPlugin -ErrorAction SilentlyContinue
            } catch {
                Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
            }
            
            try {
                Set-PSReadLineOption -PredictionViewStyle InlineView -ErrorAction SilentlyContinue
            } catch {
                # Fallback for older parameter names
                try {
                    Set-PSReadLineOption -PredictionViewStyle ListView -ErrorAction SilentlyContinue
                } catch {
                    # Skip if not supported
                }
            }
        } else {
            # Legacy PSReadLine configuration
            Set-PSReadLineOption -HistorySearchCursorMovesToEnd
            Set-PSReadLineOption -ShowToolTips
        }
        
        # Common configurations that work across versions
        Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
        
        # Safe key bindings (use standard function names)
        if ($IsPowerShell7Plus) {
            try {
                Set-PSReadLineKeyHandler -Key Alt+LeftArrow -Function BackwardWord -ErrorAction SilentlyContinue
                Set-PSReadLineKeyHandler -Key Alt+RightArrow -Function ForwardWord -ErrorAction SilentlyContinue
            } catch {
                # Fallback if functions don't exist
            }
        } else {
            # Windows PowerShell 5.1 compatible bindings
            Set-PSReadLineKeyHandler -Key Alt+LeftArrow -Function BackwardWord -ErrorAction SilentlyContinue
            Set-PSReadLineKeyHandler -Key Alt+RightArrow -Function ForwardWord -ErrorAction SilentlyContinue
        }
        
        Write-Host "📦 Loaded PSReadLine" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  PSReadLine configuration failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}
'@
        
        # Replace PSReadLine configuration section
        $content = $content -replace "(?s)# PSReadLine.*?(?=Write-Host.*?Loaded PSReadLine|#region|$)", $psReadLineFix
        $changes += "Fixed PSReadLine compatibility"
        
        # Fix 5: Safe alias handling
        $aliasFix = @'
# Safe alias configuration
$aliases = @{
    'll' = 'Get-ChildItem -Force'
    'la' = 'Get-ChildItem -Force -Hidden'
    'grep' = 'Select-String'
    'which' = 'Get-Command'
    'touch' = 'New-Item -ItemType File'
}

foreach ($alias in $aliases.GetEnumerator()) {
    try {
        if (-not (Get-Alias $alias.Key -ErrorAction SilentlyContinue)) {
            Set-Alias $alias.Key $alias.Value -Scope Global
        }
    } catch {
        Write-Verbose "Could not set alias $($alias.Key): $($_.Exception.Message)"
    }
}

# Handle 'ls' alias carefully (it may be protected)
try {
    if (Get-Alias ls -ErrorAction SilentlyContinue) {
        if ((Get-Alias ls).Options -notlike "*AllScope*") {
            Set-Alias ls Get-ChildItem -Force -Scope Global
        }
    } else {
        Set-Alias ls Get-ChildItem -Scope Global
    }
} catch {
    Write-Verbose "Could not modify 'ls' alias: $($_.Exception.Message)"
}
'@
        
        # Replace alias section
        $content = $content -replace "(?s)# Aliases.*?(?=#region|$)", $aliasFix
        $changes += "Fixed alias handling"
        
        # Fix 6: Ensure proper error handling in all sections
        $content = $content -replace "\} catch \{[^}]*\}", "} catch { Write-Host `"⚠️  Module load error: `$(`$_.Exception.Message)`" -ForegroundColor Yellow }"
        $changes += "Improved error handling"
        
        # Write the fixed content back
        if ($PSCmdlet.ShouldProcess($ProfilePath, "Apply compatibility fixes")) {
            Set-Content -Path $ProfilePath -Value $content -Encoding UTF8
            Write-Host "✅ Applied compatibility fixes:" -ForegroundColor Green
            foreach ($change in $changes) {
                Write-Host "  • $change" -ForegroundColor White
            }
        }
        
        # Validate the fixed profile
        Write-Host "🔍 Validating fixed profile..." -ForegroundColor Yellow
        $parseErrors = $null
        $null = [System.Management.Automation.Language.Parser]::ParseFile($ProfilePath, [ref]$null, [ref]$parseErrors)
        
        if ($parseErrors) {
            Write-Warning "Parse errors found after fixing:"
            $parseErrors | ForEach-Object { Write-Warning "  Line $($_.Extent.StartLineNumber): $($_.Message)" }
        }
        else {
            Write-Host "✅ Profile syntax is now valid!" -ForegroundColor Green
        }
        
    }
    catch {
        Write-Error "Failed to fix profile compatibility: $($_.Exception.Message)"
        throw
    }
}

function Install-MissingModule {
    [CmdletBinding()]
    param(
        [string]$ModuleName,
        [string]$MinimumVersion = $null,
        [string]$Repository = "PSGallery"
    )
    
    try {
        $module = Get-Module $ModuleName -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
        
        if (-not $module) {
            Write-Host "📦 Installing missing module: $ModuleName" -ForegroundColor Yellow
            if ($MinimumVersion) {
                Install-Module $ModuleName -MinimumVersion $MinimumVersion -Repository $Repository -Scope CurrentUser -Force
            }
            else {
                Install-Module $ModuleName -Repository $Repository -Scope CurrentUser -Force
            }
            Write-Host "✅ Installed $ModuleName" -ForegroundColor Green
        }
        else {
            Write-Host "✅ Module $ModuleName already available (v$($module.Version))" -ForegroundColor Green
        }
    }
    catch {
        Write-Warning "Failed to install $ModuleName : $($_.Exception.Message)"
    }
}

# Main execution
if ($MyInvocation.InvocationName -ne '.') {
    # Install missing modules first
    Write-Host "🔍 Checking for missing modules..." -ForegroundColor Cyan
    
    $requiredModules = @(
        @{ Name = "CompletionPredictor"; MinVersion = "0.3.1" },
        @{ Name = "PSReadLine"; MinVersion = "2.2.0" }
    )
    
    foreach ($module in $requiredModules) {
        Install-MissingModule -ModuleName $module.Name -MinimumVersion $module.MinVersion
    }
    
    # Apply compatibility fixes
    Update-ProfileCompatibility -ProfilePath $ProfilePath -FixWindowsPowerShell:$FixWindowsPowerShell -WhatIf:$WhatIf
}
