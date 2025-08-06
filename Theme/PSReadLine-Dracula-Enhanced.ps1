# =================================================================== 
# 🧛‍♂️ DRACULA ENHANCED PSREADLINE THEME 🧛‍♂️
# A sophisticated PSReadLine configuration inspired by Dracula colors
# with advanced features for modern PowerShell development
# ===================================================================

using namespace System.Management.Automation
using namespace System.Management.Automation.Language

#region 🎨 Color Definitions (Dracula Palette)
$DraculaColors = @{
    Background  = '#282a36'
    CurrentLine = '#44475a'
    Foreground  = '#f8f8f2'
    Comment     = '#6272a4'
    Cyan        = '#8be9fd'
    Green       = '#50fa7b'
    Orange      = '#ffb86c'
    Pink        = '#ff79c6'
    Purple      = '#bd93f9'
    Red         = '#ff5555'
    Yellow      = '#f1fa8c'
    Selection   = '#44475a'
}
#endregion

#region 🚀 Enhanced PSReadLine Configuration
if (Get-Module PSReadLine) {
    Write-Host "🧛‍♂️ Loading Dracula Enhanced PSReadLine Theme..." -ForegroundColor Magenta

    # 🎯 Core Options
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineOption -ShowToolTips
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -MaximumHistoryCount 10000
    Set-PSReadLineOption -HistoryNoDuplicates
    
    # 🔮 Prediction Configuration
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -MaximumCompletionCount 50
    
    # 🎨 Dracula Color Scheme
    Set-PSReadLineOption -Colors @{
        # Basic text colors
        'Default'                = $DraculaColors.Foreground
        'Comment'                = $DraculaColors.Comment
        'Keyword'                = $DraculaColors.Pink
        'String'                 = $DraculaColors.Yellow
        'Operator'               = $DraculaColors.Pink
        'Variable'               = $DraculaColors.Foreground
        'Command'                = $DraculaColors.Green
        'Parameter'              = $DraculaColors.Orange
        'Type'                   = $DraculaColors.Cyan
        'Number'                 = $DraculaColors.Purple
        'Member'                 = $DraculaColors.Cyan
        
        # Advanced syntax highlighting
        'ContinuationPrompt'     = $DraculaColors.Comment
        'Emphasis'               = $DraculaColors.Red
        'Error'                  = $DraculaColors.Red
        'Selection'              = $DraculaColors.Selection
        'InlinePrediction'       = $DraculaColors.Comment
        'ListPrediction'         = $DraculaColors.Cyan
        'ListPredictionSelected' = $DraculaColors.Purple
        'ListPredictionTooltip'  = $DraculaColors.Orange
    }

    #region ⌨️ Enhanced Key Bindings
    
    # 📜 History Navigation (with visual feedback)
    Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadlineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory
    
    # 📋 Completion Enhancements
    Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadlineKeyHandler -Key Shift+Tab -Function TabCompletePrevious
    Set-PSReadlineKeyHandler -Key Ctrl+Spacebar -Function Complete
    
    # 🧭 Navigation Improvements
    Set-PSReadLineKeyHandler -Key Alt+RightArrow -Function MoveToEndOfLine
    Set-PSReadLineKeyHandler -Key Alt+LeftArrow -Function MoveToStartOfLine
    Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function NextWord
    Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord
    Set-PSReadLineKeyHandler -Key Ctrl+Home -Function BeginningOfLine
    Set-PSReadLineKeyHandler -Key Ctrl+End -Function EndOfLine
    
    # 🎯 Selection Magic
    Set-PSReadLineKeyHandler -Key Shift+LeftArrow -Function SelectBackwardChar
    Set-PSReadLineKeyHandler -Key Shift+RightArrow -Function SelectForwardChar
    Set-PSReadLineKeyHandler -Key Ctrl+Shift+LeftArrow -Function SelectBackwardWord
    Set-PSReadLineKeyHandler -Key Ctrl+Shift+RightArrow -Function SelectNextWord
    Set-PSReadLineKeyHandler -Key Shift+Home -Function SelectBackwardsLine
    Set-PSReadLineKeyHandler -Key Shift+End -Function SelectForwardLine
    Set-PSReadLineKeyHandler -Key Ctrl+a -Function SelectAll
    
    # 📝 Advanced Editing
    Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit
    Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardDeleteWord
    Set-PSReadLineKeyHandler -Key Alt+d -Function DeleteWord
    Set-PSReadLineKeyHandler -Key Ctrl+Backspace -Function BackwardDeleteWord
    Set-PSReadLineKeyHandler -Key Ctrl+Delete -Function DeleteWord
    
    # 🔄 Undo/Redo
    Set-PSReadLineKeyHandler -Key Ctrl+z -Function Undo
    Set-PSReadLineKeyHandler -Key Ctrl+y -Function Redo
    
    #endregion

    #region 🛠️ Custom Functions & Smart Features
    
    # 🕰️ F7 - Enhanced History with Dracula styling
    Set-PSReadLineKeyHandler -Key F7 -BriefDescription '🕰️ History Browser' -LongDescription 'Browse command history with Dracula styling' -ScriptBlock {
        $pattern = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$pattern, [ref]$null)
        if ($pattern) { $pattern = [regex]::Escape($pattern) }

        $history = [System.Collections.ArrayList]@(
            $last = ''
            $lines = ''
            foreach ($line in [System.IO.File]::ReadLines((Get-PSReadLineOption).HistorySavePath)) {
                if ($line.EndsWith('`')) {
                    $line = $line.Substring(0, $line.Length - 1)
                    $lines = if ($lines) { "$lines`n$line" } else { $line }
                    continue
                }
                if ($lines) { $line = "$lines`n$line"; $lines = '' }
                if (($line -cne $last) -and (!$pattern -or ($line -match $pattern))) {
                    $last = $line; $line
                }
            }
        )
        $history.Reverse()

        $command = $history | Out-GridView -Title "🧛‍♂️ Dracula Command History 🧛‍♂️" -PassThru
        if ($command) {
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($command -join "`n"))
        }
    }
    
    # 🔍 Ctrl+Shift+F - Smart Search
    Set-PSReadLineKeyHandler -Key Ctrl+Shift+f -BriefDescription '🔍 Smart Search' -LongDescription 'Search through commands intelligently' -ScriptBlock {
        $input = [Microsoft.PowerShell.PSConsoleReadLine]::ReadLine("🔍 Search: ", "")
        if ($input) {
            $matches = Get-History | Where-Object { $_.CommandLine -like "*$input*" } | Select-Object -Last 20
            if ($matches) {
                $selected = $matches | Out-GridView -Title "🔍 Search Results for '$input'" -PassThru
                if ($selected) {
                    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected.CommandLine)
                }
            }
        }
    }
    
    # 🎨 Alt+c - Color Test
    Set-PSReadLineKeyHandler -Key Alt+c -BriefDescription '🎨 Color Test' -LongDescription 'Test Dracula color scheme' -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert('# 🧛‍♂️ Dracula Color Test: Get-Process | Where-Object {$_.ProcessName -like "*pwsh*"} | Format-Table -AutoSize')
    }
    
    # 📊 F9 - System Info
    Set-PSReadLineKeyHandler -Key F9 -BriefDescription '📊 System Info' -LongDescription 'Insert system information command' -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert('Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, TotalPhysicalMemory | Format-List')
    }
    
    # 🚀 Ctrl+Shift+N - New Script Template
    Set-PSReadLineKeyHandler -Key Ctrl+Shift+n -BriefDescription '🚀 Script Template' -LongDescription 'Insert PowerShell script template' -ScriptBlock {
        $template = @'
#Requires -Version 7.0
<#
.SYNOPSIS
    Brief description of the script

.DESCRIPTION
    Detailed description of what the script does

.PARAMETER ParameterName
    Description of the parameter

.EXAMPLE
    .\ScriptName.ps1 -ParameterName "Value"

.NOTES
    Author: Your Name
    Date: {0:yyyy-MM-dd}
    Version: 1.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ParameterName
)

begin {
    Write-Verbose "Starting $($MyInvocation.MyCommand.Name)"
}

process {
    # Main script logic here
}

end {
    Write-Verbose "Completed $($MyInvocation.MyCommand.Name)"
}
'@ -f (Get-Date)
        
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($template)
    }
    
    # 🔮 Prediction Enhancements
    Set-PSReadLineKeyHandler -Key Ctrl+f -BriefDescription '🔮 Accept Prediction' -LongDescription 'Accept inline prediction' -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptSuggestion()
    }
    
    Set-PSReadLineKeyHandler -Key Ctrl+Shift+f -BriefDescription '🔮 Accept Word' -LongDescription 'Accept next word from prediction' -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptNextSuggestionWord()
    }
    
    #endregion

    #region 🎭 Dynamic Prompt Enhancements
    
    # 🌈 Rainbow Parentheses (matching bracket highlighting)
    Set-PSReadLineOption -ShowToolTips
    
    # 🎵 Command Completion with Sound (optional)
    # Set-PSReadLineOption -BellStyle Visual
    
    #endregion

    Write-Host "✨ Dracula Enhanced PSReadLine Theme Loaded Successfully! ✨" -ForegroundColor Green
    Write-Host "🧛‍♂️ Available shortcuts:" -ForegroundColor Cyan
    Write-Host "   F7             - 🕰️ History Browser" -ForegroundColor Yellow
    Write-Host "   F9             - 📊 System Info" -ForegroundColor Yellow
    Write-Host "   Alt+C          - 🎨 Color Test" -ForegroundColor Yellow
    Write-Host "   Ctrl+Shift+F   - 🔍 Smart Search" -ForegroundColor Yellow
    Write-Host "   Ctrl+Shift+N   - 🚀 Script Template" -ForegroundColor Yellow
    Write-Host "   Ctrl+F         - 🔮 Accept Prediction" -ForegroundColor Yellow
    Write-Host "   Ctrl+Shift+F   - 🔮 Accept Word" -ForegroundColor Yellow
    Write-Host ""
}
else {
    Write-Warning "PSReadLine module not found. Please install it: Install-Module PSReadLine -Force"
}
#endregion

# 🎉 End of Dracula Enhanced PSReadLine Theme
Write-Host "🧛‍♂️ Welcome to your enhanced Dracula PowerShell experience! 🧛‍♂️" -ForegroundColor Magenta
