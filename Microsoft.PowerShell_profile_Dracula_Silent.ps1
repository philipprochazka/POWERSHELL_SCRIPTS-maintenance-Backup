<#
.SYNOPSIS
    Dracula PowerShell Profile - Silent Mode
.DESCRIPTION
    Ultra-quiet Dracula profile with no startup messages or verbose output.
    Perfect for automation and background tasks.
.VERSION
    2.0.0-Silent
.AUTHOR
    Philip Procházka
#>

# ===================================================================
# 🧛‍♂️ DRACULA SILENT PROFILE 🧛‍♂️
# Zero verbosity, maximum efficiency
# ===================================================================

# Prevent multiple loads
if ($global:DraculaSilentLoaded) {
    return 
}
$global:DraculaSilentLoaded = $true

# Suppress all output during load
$originalInformation = $InformationPreference
$originalVerbose = $VerbosePreference
$originalWarning = $WarningPreference

$InformationPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'
$WarningPreference = 'SilentlyContinue'

try {
    #region Theme (Minimal)
    if (-not $env:POSH_THEME) {
        $draculaTheme = Join-Path $PSScriptRoot "Theme\dracula-enhanced.omp.json"
        if (Test-Path $draculaTheme) {
            try {
                oh-my-posh init pwsh --config $draculaTheme | Invoke-Expression
            } catch {
                function prompt {
                    "PS $($executionContext.SessionState.Path.CurrentLocation)> " 
                }
            }
        } else {
            function prompt {
                "PS $($executionContext.SessionState.Path.CurrentLocation)> " 
            }
        }
    }
    #endregion

    #region Essential Modules (Silent Load)
    @('PSReadLine') | ForEach-Object {
        Import-Module $_ -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
    }
    #endregion

    #region PSReadLine (Essential Only)
    if (Get-Module PSReadLine) {
        Set-PSReadLineOption -EditMode Windows -BellStyle None
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -Colors @{
            'Command' = '#50fa7b'; 'Parameter' = '#ffb86c'; 'String' = '#f1fa8c'
            'Variable' = '#f8f8f2'; 'Comment' = '#6272a4'; 'Keyword' = '#ff79c6'
            'Error' = '#ff5555'
        }
        Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
        Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
        Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    }
    #endregion

    #region Essential Aliases
    Set-Alias -Name ll -Value Get-ChildItem -Force -ErrorAction SilentlyContinue
    Set-Alias -Name la -Value Get-ChildItem -Force -ErrorAction SilentlyContinue
    Set-Alias -Name l -Value Get-ChildItem -Force -ErrorAction SilentlyContinue
    Set-Alias -Name cls -Value Clear-Host -Force -ErrorAction SilentlyContinue
    Set-Alias -Name which -Value Get-Command -Force -ErrorAction SilentlyContinue
    
    if (Get-Command git -ErrorAction SilentlyContinue) {
        Set-Alias -Name g -Value git -Force -ErrorAction SilentlyContinue
    }
    #endregion

} finally {
    # Restore preferences
    $InformationPreference = $originalInformation
    $VerbosePreference = $originalVerbose
    $WarningPreference = $originalWarning
}
