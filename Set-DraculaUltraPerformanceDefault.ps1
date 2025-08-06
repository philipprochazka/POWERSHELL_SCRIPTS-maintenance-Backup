<#
.SYNOPSIS
    Set Ultra-Performance as Default Profile Mode
.DESCRIPTION
    Configures the system to always use ultra-performance lazy loading as the default
    across all PowerShell sessions and profile types.
.VERSION
    1.0.0
.AUTHOR
    Philip Procházka
#>

param(
    [ValidateSet('UltraPerformance', 'Performance', 'Normal', 'Minimal')]
    [string]$DefaultMode = 'UltraPerformance',
    
    [switch]$SystemWide,
    [switch]$Force,
    [switch]$Test
)

# ===================================================================
# 🧛‍♂️ SET ULTRA-PERFORMANCE AS DEFAULT 🧛‍♂️
# Makes lazy loading the default for all PowerShell sessions
# ===================================================================

function Set-DraculaDefaultMode {
    param(
        [string]$Mode,
        [bool]$SystemWide = $false,
        [bool]$Force = $false
    )
    
    Write-Host "🧛‍♂️ Setting Dracula Default Mode: $Mode" -ForegroundColor Magenta
    
    # Define profile paths based on scope
    $profilePaths = if ($SystemWide) {
        @(
            $PROFILE.AllUsersCurrentHost,
            $PROFILE.AllUsersAllHosts,
            $PROFILE.CurrentUserCurrentHost,
            $PROFILE.CurrentUserAllHosts
        )
    } else {
        @(
            $PROFILE.CurrentUserCurrentHost,
            $PROFILE.CurrentUserAllHosts
        )
    }
    
    # Profile content based on mode
    $profileContent = switch ($Mode) {
        'UltraPerformance' {
            @"
# ===================================================================
# 🧛‍♂️ DRACULA ULTRA-PERFORMANCE AUTO-LOADER 🧛‍♂️
# Automatically loads ultra-performance profile for sub-50ms startup
# ===================================================================

# Set performance environment variables
`$env:DRACULA_MODE = 'UltraPerformance'
`$env:DRACULA_LAZY_LOADING = 'true'

# Determine the correct path to the ultra-performance profile
`$ultraPerfProfile = if (Test-Path "`$PSScriptRoot\Microsoft.PowerShell_profile_Dracula_UltraPerformance.ps1") {
    "`$PSScriptRoot\Microsoft.PowerShell_profile_Dracula_UltraPerformance.ps1"
} elseif (Test-Path "$(Split-Path $PROFILE)\Microsoft.PowerShell_profile_Dracula_UltraPerformance.ps1") {
    "$(Split-Path $PROFILE)\Microsoft.PowerShell_profile_Dracula_UltraPerformance.ps1"
} elseif (Test-Path "C:\backup\PowerShell\Microsoft.PowerShell_profile_Dracula_UltraPerformance.ps1") {
    "C:\backup\PowerShell\Microsoft.PowerShell_profile_Dracula_UltraPerformance.ps1"
} else {
    `$null
}

# Load ultra-performance profile if found
if (`$ultraPerfProfile -and (Test-Path `$ultraPerfProfile)) {
    try {
        . `$ultraPerfProfile
    } catch {
        Write-Warning "Failed to load ultra-performance profile: `$(`$_.Exception.Message)"
        # Fallback to minimal prompt
        function prompt {
            "🧛‍♂️ PS `$(`$executionContext.SessionState.Path.CurrentLocation)> "
        }
    }
} else {
    # Fallback ultra-minimal profile if file not found
    Write-Host "⚡ Ultra-Performance Mode (Fallback)" -ForegroundColor Yellow
    
    # Set global flag
    `$global:DraculaUltraLoaded = `$true
    
    # Minimal prompt
    function prompt {
        Write-Host "🧛‍♂️" -NoNewline -ForegroundColor Magenta
        Write-Host " PS " -NoNewline -ForegroundColor Cyan
        Write-Host (Split-Path -Leaf `$PWD) -NoNewline -ForegroundColor Yellow
        Write-Host " > " -NoNewline -ForegroundColor Green
        return " "
    }
    
    # Essential aliases
    Set-Alias ll Get-ChildItem -Force
    Set-Alias la Get-ChildItem -Force
    Set-Alias l Get-ChildItem -Force
    Set-Alias cls Clear-Host -Force
    Set-Alias which Get-Command -Force
    
    # Manual module loading functions
    function load-psrl { 
        if (-not (Get-Module PSReadLine)) {
            Import-Module PSReadLine -ErrorAction SilentlyContinue
        }
    }
    function load-icons { 
        if (-not (Get-Module Terminal-Icons)) {
            Import-Module Terminal-Icons -ErrorAction SilentlyContinue
        }
    }
    function load-all {
        Write-Host "🚀 Loading essential modules..." -ForegroundColor Cyan
        load-psrl; load-icons
        Write-Host "✅ Modules loaded!" -ForegroundColor Green
    }
}

# Performance debug info
if (`$env:DRACULA_PERFORMANCE_DEBUG -eq 'true') {
    Write-Host "⚡ Ultra-Performance mode active via auto-loader" -ForegroundColor Green
}
"@
        }
        'Performance' {
            @"
# Load existing performance profile
`$perfProfile = "`$PSScriptRoot\Microsoft.PowerShell_profile_Dracula_Performance.ps1"
if (Test-Path `$perfProfile) {
    . `$perfProfile
} else {
    Write-Warning "Performance profile not found at `$perfProfile"
}
"@
        }
        'Normal' {
            @"
# Load standard Dracula profile
`$draculaProfile = "`$PSScriptRoot\Microsoft.PowerShell_profile_Dracula.ps1"
if (Test-Path `$draculaProfile) {
    . `$draculaProfile
} else {
    Write-Warning "Dracula profile not found at `$draculaProfile"
}
"@
        }
        'Minimal' {
            @"
# Load minimal Dracula profile
`$minimalProfile = "`$PSScriptRoot\Microsoft.PowerShell_profile_Dracula_Minimal.ps1"
if (Test-Path `$minimalProfile) {
    . `$minimalProfile
} else {
    Write-Warning "Minimal profile not found at `$minimalProfile"
}
"@
        }
    }
    
    # Apply to each profile path
    foreach ($profilePath in $profilePaths) {
        try {
            # Create directory if it doesn't exist
            $profileDir = Split-Path $profilePath -Parent
            if (-not (Test-Path $profileDir)) {
                New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
            }
            
            # Backup existing profile if it exists and not forcing
            if ((Test-Path $profilePath) -and -not $Force) {
                $backup = "$profilePath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
                Copy-Item $profilePath $backup -Force
                Write-Host "  📋 Backed up existing profile to: $backup" -ForegroundColor Gray
            }
            
            # Write new profile content
            Set-Content -Path $profilePath -Value $profileContent -Encoding UTF8 -Force
            Write-Host "  ✅ Updated: $profilePath" -ForegroundColor Green
            
        } catch {
            Write-Warning "Failed to update $profilePath`: $($_.Exception.Message)"
        }
    }
    
    # Set environment variables for current session
    $env:DRACULA_MODE = $Mode
    $env:DRACULA_LAZY_LOADING = 'true'
    
    Write-Host "🎯 Default mode set to: $Mode" -ForegroundColor Green
    Write-Host "💡 Restart PowerShell sessions to apply changes" -ForegroundColor Cyan
}

function Test-UltraPerformanceSetup {
    Write-Host "🧪 Testing Ultra-Performance Setup..." -ForegroundColor Cyan
    
    # Test profile existence
    $ultraPerfPath = Join-Path $PSScriptRoot "Microsoft.PowerShell_profile_Dracula_UltraPerformance.ps1"
    if (Test-Path $ultraPerfPath) {
        Write-Host "  ✅ Ultra-Performance profile exists" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Ultra-Performance profile missing at: $ultraPerfPath" -ForegroundColor Red
        return $false
    }
    
    # Test profile loading speed
    Write-Host "  🔬 Testing startup speed..." -ForegroundColor Yellow
    $testScript = @"
`$start = Get-Date
. '$ultraPerfPath'
`$elapsed = ((Get-Date) - `$start).TotalMilliseconds
Write-Output `$elapsed
"@
    
    try {
        $elapsed = pwsh -NoProfile -Command $testScript
        Write-Host "  ⚡ Startup time: ${elapsed}ms" -ForegroundColor $(if ($elapsed -lt 50) {
                'Green' 
            } elseif ($elapsed -lt 100) {
                'Yellow' 
            } else {
                'Red' 
            })
        
        if ($elapsed -lt 50) {
            Write-Host "  🏆 ULTRA-PERFORMANCE TARGET ACHIEVED!" -ForegroundColor Green
            return $true
        } elseif ($elapsed -lt 100) {
            Write-Host "  ⚡ Good performance, but can be optimized further" -ForegroundColor Yellow
            return $true
        } else {
            Write-Host "  ⚠️ Performance below target, needs optimization" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "  ❌ Test failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main execution
if ($Test) {
    Test-UltraPerformanceSetup
    return
}

Write-Host "🧛‍♂️ Dracula Ultra-Performance Default Mode Setup" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Gray

# Ensure ultra-performance profile exists
$ultraPerfPath = Join-Path $PSScriptRoot "Microsoft.PowerShell_profile_Dracula_UltraPerformance.ps1"
if (-not (Test-Path $ultraPerfPath)) {
    Write-Warning "Ultra-Performance profile not found at: $ultraPerfPath"
    Write-Host "💡 Make sure to create the ultra-performance profile first!" -ForegroundColor Yellow
    return
}

# Set the default mode
Set-DraculaDefaultMode -Mode $DefaultMode -SystemWide $SystemWide -Force $Force

Write-Host ""
Write-Host "🎯 Configuration Complete!" -ForegroundColor Green
Write-Host "⚡ All new PowerShell sessions will use $DefaultMode mode" -ForegroundColor Cyan
Write-Host "🧛‍♂️ Enjoy your ultra-fast PowerShell startup!" -ForegroundColor Magenta

# Test the setup
Write-Host ""
Test-UltraPerformanceSetup
