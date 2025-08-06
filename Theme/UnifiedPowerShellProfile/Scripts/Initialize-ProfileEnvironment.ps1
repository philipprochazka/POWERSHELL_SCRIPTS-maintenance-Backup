# Initialize-ProfileEnvironment.ps1
# Pre-import script for UnifiedPowerShellProfile module

Write-Verbose "Initializing PowerShell Profile Environment..."

# Set up environment variables for quality enforcement
$env:PSSCRIPTANALYZER_CACHE = Join-Path $env:TEMP "PSScriptAnalyzer"
$env:UNIFIED_PROFILE_QUALITY_MODE = "Strict"

# Create cache directory if it doesn't exist
if (-not (Test-Path $env:PSSCRIPTANALYZER_CACHE)) {
    New-Item -Path $env:PSSCRIPTANALYZER_CACHE -ItemType Directory -Force | Out-Null
}

# Enhanced error handling for quality enforcement
$ErrorActionPreference = "Continue"
$WarningPreference = "Continue"

Write-Verbose "✅ Profile environment initialized"
