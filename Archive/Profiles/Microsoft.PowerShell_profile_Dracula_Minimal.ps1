<#
.SYNOPSIS
    Dracula PowerShell Profile - Minimal Mode
.DESCRIPTION
    Bare minimum Dracula profile for maximum startup speed.
    Only essential colors and aliases.
.VERSION
    2.0.0-Minimal
.AUTHOR
    Philip Procházka
#>

# ===================================================================
# 🧛‍♂️ DRACULA MINIMAL PROFILE 🧛‍♂️
# Fastest possible startup
# ===================================================================

# Single load check
if ($global:DraculaMinimalLoaded) {
    return 
}
$global:DraculaMinimalLoaded = $true

# Minimal prompt
function prompt { 
    Write-Host "🧛‍♂️ " -NoNewline -ForegroundColor Magenta
    Write-Host $executionContext.SessionState.Path.CurrentLocation -NoNewline -ForegroundColor Yellow
    Write-Host "> " -NoNewline -ForegroundColor Green
    return " "
}

# Essential PSReadLine only
if (Get-Module PSReadLine -ListAvailable) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue
    if (Get-Module PSReadLine) {
        Set-PSReadLineOption -EditMode Windows -BellStyle None
        Set-PSReadLineOption -Colors @{
            'Command' = '#50fa7b'
            'String'  = '#f1fa8c' 
            'Error'   = '#ff5555'
        }
    }
}

# Core aliases only
Set-Alias ll Get-ChildItem -Force -ErrorAction SilentlyContinue
Set-Alias cls Clear-Host -Force -ErrorAction SilentlyContinue
