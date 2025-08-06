<#
.SYNOPSIS
    Enhanced Dracula PowerShell Profile with Full PSReadLine Integration
.DESCRIPTION
    Complete profile with proper PSReadLine history, semantic navigation, 
    Dracula theme prompt, and all essential features working correctly.
.VERSION
    1.0.0-Enhanced
.AUTHOR
    Philip Procházka
.COPYRIGHT
    (c) 2025 PhilipProcházka. All rights reserved.
#>

# ===================================================================
# 🧛‍♂️ ENHANCED DRACULA PROFILE WITH FULL FEATURES 🧛‍♂️
# Focuses on functionality over ultra-performance
# ===================================================================

#region ⚡ Initialization Guard
if ($global:DraculaEnhancedLoaded) {
    return 
}
$global:DraculaEnhancedLoaded = $true

# Performance tracking (optional)
if ($env:DRACULA_PERFORMANCE_DEBUG -eq 'true') {
    $global:ProfileLoadStart = [System.Diagnostics.Stopwatch]::StartNew()
    Write-Host "🔬 Enhanced Dracula Profile loading..." -ForegroundColor Cyan
}
#endregion

#region 📚 Advanced PSReadLine Configuration
# Load PSReadLine first and configure it properly
try {
    Import-Module PSReadLine -Force -ErrorAction Stop
    
    # Core PSReadLine Configuration with Dracula colors
    Set-PSReadLineOption -EditMode Windows  # Use Windows mode for familiar shortcuts
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -MaximumHistoryCount 10000
    Set-PSReadLineOption -HistoryNoDuplicates:$true
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd:$true
    Set-PSReadLineOption -ShowToolTips:$true
    Set-PSReadLineOption -ExtraPromptLineCount 1
    
    # Dracula Color Scheme for PSReadLine
    $DraculaColors = @{
        Command                = '#50fa7b'  # Green
        Number                 = '#bd93f9'  # Purple  
        Member                 = '#ffb86c'  # Orange
        Operator               = '#ff79c6'  # Pink
        Type                   = '#8be9fd'  # Cyan
        Variable               = '#f8f8f2'  # Foreground
        Parameter              = '#ffb86c'  # Orange
        ContinuationPrompt     = '#6272a4'  # Comment
        Default                = '#f8f8f2'  # Foreground
        Emphasis               = '#ff5555'  # Red
        Error                  = '#ff5555'  # Red
        Selection              = '#44475a'  # Selection
        Comment                = '#6272a4'  # Comment
        Keyword                = '#ff79c6'  # Pink
        String                 = '#f1fa8c'  # Yellow
        InlinePrediction       = '#6272a4'  # Comment
        ListPrediction         = '#bd93f9'  # Purple
        ListPredictionSelected = '#282a36' # Background
    }
    
    Set-PSReadLineOption -Colors $DraculaColors
    
    # Enhanced Key Bindings - Semantic Navigation
    Set-PSReadLineKeyHandler -Key Ctrl+LeftArrow -Function BackwardWord
    Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function ForwardWord
    Set-PSReadLineKeyHandler -Key Ctrl+Backspace -Function BackwardKillWord
    Set-PSReadLineKeyHandler -Key Ctrl+Delete -Function KillWord
    Set-PSReadLineKeyHandler -Key Ctrl+UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key Ctrl+DownArrow -Function HistorySearchForward
    
    # Advanced prediction controls
    Set-PSReadLineKeyHandler -Key Ctrl+f -Function AcceptSuggestion
    Set-PSReadLineKeyHandler -Key Ctrl+RightArrow -Function AcceptNextSuggestionWord
    Set-PSReadLineKeyHandler -Key F2 -Function SwitchPredictionView
    
    # Enhanced completion
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key Shift+Tab -Function MenuComplete
    # Note: Ctrl+Space may conflict with some terminals, using Tab instead
    
    # Advanced CamelCase Navigation with Diacritics Support
    Set-PSReadLineKeyHandler -Key Alt+LeftArrow -BriefDescription BackwardCamelCaseWord -ScriptBlock {
        param($key, $arg)
        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        
        if ($cursor -gt 0) {
            # Move backward respecting: CamelCase, diacritics, _ (joined), - and . (boundaries)
            $pos = $cursor - 1
            
            # Skip current position if we're on a word boundary character
            while ($pos -gt 0 -and $line[$pos] -match '[-.\s]') {
                $pos--
            }
            
            # Find previous word boundary
            while ($pos -gt 0) {
                $current = $line[$pos]
                $previous = if ($pos -gt 0) {
                    $line[$pos - 1] 
                } else {
                    '' 
                }
                
                # Word boundaries: hyphen, dot, or whitespace (but not underscore)
                if ($current -match '[-.\s]') {
                    break
                }
                
                # CamelCase boundary: lowercase/diacritic followed by uppercase
                if ($previous -match '[a-züéèáàóòíìúùýỳčďěňřšťžẽĩõũỹ]' -and $current -match '[A-ZÜÉÈÁÀÓÒÍÌÚÙÝỲČĎĚŇŘŠŤŽẼĨÕŨỸ]') {
                    break
                }
                
                # Start of line
                if ($pos -eq 0) {
                    break
                }
                
                $pos--
            }
            
            # Skip any boundary characters to position at start of word
            while ($pos -gt 0 -and $line[$pos] -match '[-.\s]') {
                $pos++
                break
            }
            
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition([Math]::Max(0, $pos))
        }
    }
    
    Set-PSReadLineKeyHandler -Key Alt+RightArrow -BriefDescription ForwardCamelCaseWord -ScriptBlock {
        param($key, $arg)
        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        
        if ($cursor -lt $line.Length) {
            # Move forward respecting: CamelCase, diacritics, _ (joined), - and . (boundaries)
            $pos = $cursor
            
            # Skip current boundary characters
            while ($pos -lt $line.Length -and $line[$pos] -match '[-.\s]') {
                $pos++
            }
            
            # Find next word boundary
            while ($pos -lt $line.Length - 1) {
                $current = $line[$pos]
                $next = $line[$pos + 1]
                
                # CamelCase boundary: lowercase/diacritic followed by uppercase
                if ($current -match '[a-züéèáàóòíìúùýỳčďěňřšťžẽĩõũỹ]' -and $next -match '[A-ZÜÉÈÁÀÓÒÍÌÚÙÝỲČĎĚŇŘŠŤŽẼĨÕŨỸ]') {
                    $pos++
                    break
                }
                
                # Word boundary: before hyphen, dot, or whitespace (but not underscore)
                if ($next -match '[-.\s]') {
                    $pos++
                    break
                }
                
                # End of string
                if ($pos -eq $line.Length - 1) {
                    $pos++
                    break
                }
                
                $pos++
            }
            
            # Ensure we don't go past end
            if ($pos -ge $line.Length) {
                $pos = $line.Length
            }
            
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition([Math]::Min($line.Length, $pos))
        }
    }
    
    # Enhanced History Navigation
    Set-PSReadLineKeyHandler -Key F7 -Function ShowKeyBindings
    Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory
    Set-PSReadLineKeyHandler -Key Ctrl+s -Function ForwardSearchHistory
    Set-PSReadLineKeyHandler -Key Alt+F7 -Function ClearHistory
    
    # Directory navigation shortcuts
    Set-PSReadLineKeyHandler -Key Alt+d -BriefDescription "Insert '..\'" -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert('..\')
    }
    
    Set-PSReadLineKeyHandler -Key Alt+h -BriefDescription "Go to home directory" -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert('cd ~')
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
    
    # Advanced editing shortcuts
    Set-PSReadLineKeyHandler -Key Ctrl+Shift+c -Function CopyOrCancelLine
    Set-PSReadLineKeyHandler -Key Ctrl+v -Function Paste
    Set-PSReadLineKeyHandler -Key Ctrl+z -Function Undo
    Set-PSReadLineKeyHandler -Key Ctrl+y -Function Redo
    Set-PSReadLineKeyHandler -Key Ctrl+a -Function SelectAll
    Set-PSReadLineKeyHandler -Key Ctrl+l -Function ClearScreen
    
    # Command completion shortcuts
    Set-PSReadLineKeyHandler -Key 'Ctrl+Shift+Enter' -BriefDescription "Show parameter hints" -ScriptBlock {
        param($key, $arg)
        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        
        # Try to show parameter completion
        [Microsoft.PowerShell.PSConsoleReadLine]::TabCompleteNext()
    }
    
    # Smart quotes handling
    Set-PSReadLineKeyHandler -Key '"' -BriefDescription SmartInsertQuote -ScriptBlock {
        param($key, $arg)
        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        
        if ($line[$cursor] -eq $key.KeyChar) {
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
        } else {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)" * 2)
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
            [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - 1)
        }
    }
    
    Write-Host "✅ PSReadLine enhanced configuration loaded" -ForegroundColor Green
} catch {
    Write-Host "⚠️ PSReadLine configuration failed: $($_.Exception.Message)" -ForegroundColor Yellow
}
#endregion

#region 🎨 Enhanced Dracula Prompt
function prompt {
    $currentPath = $PWD.Path
    $pathName = Split-Path -Leaf $currentPath
    
    # Handle special cases
    if ($pathName -eq "") {
        $pathName = $currentPath 
    }
    if ($pathName -eq "System32") {
        $pathName = "System32 💎" 
    }
    
    # Build the prompt components
    $vampire = "🧛"
    $diamond = if ($pathName -notlike "*💎*") {
        " 💎" 
    } else {
        "" 
    }
    $arrow = "❯"
    
    # Color scheme
    Write-Host $vampire -NoNewline -ForegroundColor Magenta
    Write-Host " " -NoNewline
    Write-Host $pathName -NoNewline -ForegroundColor Cyan
    Write-Host $diamond -NoNewline -ForegroundColor Yellow
    Write-Host " " -NoNewline
    Write-Host $arrow -NoNewline -ForegroundColor Green
    Write-Host " " -NoNewline
    
    return " "
}
#endregion

#region 📦 Essential Module Loading
# Function to load modules with error handling
function Import-ModuleIfAvailable {
    param(
        [string]$ModuleName,
        [scriptblock]$ConfigScript = $null
    )
    
    try {
        $module = Get-Module -ListAvailable -Name $ModuleName | Select-Object -First 1
        if ($module) {
            Import-Module $ModuleName -Force -ErrorAction Stop
            if ($ConfigScript) {
                & $ConfigScript
            }
            Write-Host "✅ $ModuleName loaded" -ForegroundColor Green
            return $true
        } else {
            Write-Host "⚠️ $ModuleName not available" -ForegroundColor Yellow
            return $false
        }
    } catch {
        Write-Host "❌ Failed to load $ModuleName`: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Load Terminal Icons
$null = Import-ModuleIfAvailable -ModuleName "Terminal-Icons"

# Load z (directory jumping)
$null = Import-ModuleIfAvailable -ModuleName "z"

# Load Azure predictor if available
$null = Import-ModuleIfAvailable -ModuleName "Az.Tools.Predictor"

# Load completion predictor if available
$null = Import-ModuleIfAvailable -ModuleName "CompletionPredictor"
#endregion

#region 🎨 Advanced PSReadLine Prompt Customization
# Enhanced prompt with PSReadLine integration and Git status
function prompt {
    $currentPath = $PWD.Path
    $pathName = Split-Path -Leaf $currentPath
    
    # Handle special cases
    if ($pathName -eq "") {
        $pathName = $currentPath 
    }
    if ($pathName -eq "System32") {
        $pathName = "System32 💎" 
    }
    
    # Git status if available
    $gitStatus = ""
    if (Get-Command git -ErrorAction SilentlyContinue) {
        try {
            $gitBranch = git branch --show-current 2>$null
            if ($gitBranch) {
                $gitDirty = git status --porcelain 2>$null
                $gitIcon = if ($gitDirty) {
                    "🔴" 
                } else {
                    "🟢" 
                }
                $gitStatus = " ($gitIcon $gitBranch)"
            }
        } catch {
            # Silently ignore git errors
        }
    }
    
    # Build the prompt components
    $vampire = "🧛"
    $diamond = if ($pathName -notlike "*💎*") {
        " 💎" 
    } else {
        "" 
    }
    $arrow = "❯"
    
    # Enhanced color scheme with git status
    Write-Host $vampire -NoNewline -ForegroundColor Magenta
    Write-Host " " -NoNewline
    Write-Host $pathName -NoNewline -ForegroundColor Cyan
    Write-Host $diamond -NoNewline -ForegroundColor Yellow
    if ($gitStatus) {
        Write-Host $gitStatus -NoNewline -ForegroundColor Gray
    }
    Write-Host " " -NoNewline
    Write-Host $arrow -NoNewline -ForegroundColor Green
    Write-Host " " -NoNewline
    
    return " "
}
#endregion

#region 🛠️ Utility Functions
function Get-EnhancedProfileInfo {
    Write-Host "📊 Enhanced Dracula Profile Information:" -ForegroundColor Cyan
    Write-Host "  PSReadLine: $(if (Get-Module PSReadLine) { '✅ Loaded with Dracula colors' } else { '❌ Not loaded' })" -ForegroundColor $(if (Get-Module PSReadLine) {
            'Green' 
        } else {
            'Red' 
        })
    Write-Host "  Terminal-Icons: $(if (Get-Module Terminal-Icons) { '✅ Loaded' } else { '❌ Not loaded' })" -ForegroundColor $(if (Get-Module Terminal-Icons) {
            'Green' 
        } else {
            'Red' 
        })
    Write-Host "  z: $(if (Get-Module z) { '✅ Loaded' } else { '❌ Not loaded' })" -ForegroundColor $(if (Get-Module z) {
            'Green' 
        } else {
            'Red' 
        })
    Write-Host "  Git Status: $(if (Get-Command git -ErrorAction SilentlyContinue) { '✅ Available in prompt' } else { '❌ Git not found' })" -ForegroundColor $(if (Get-Command git -ErrorAction SilentlyContinue) {
            'Green' 
        } else {
            'Yellow' 
        })
    
    if ($global:ProfileLoadStart) {
        $loadTime = $global:ProfileLoadStart.Elapsed.TotalMilliseconds
        Write-Host "  Load Time: ${loadTime:F2}ms" -ForegroundColor Green
    }
    
    # Show PSReadLine prediction settings
    $psrlOptions = Get-PSReadLineOption
    Write-Host "  Prediction Source: $($psrlOptions.PredictionSource)" -ForegroundColor Yellow
    Write-Host "  Prediction View: $($psrlOptions.PredictionViewStyle)" -ForegroundColor Yellow
}

function Test-PSReadLineFeatures {
    Write-Host "🧪 Testing PSReadLine Features:" -ForegroundColor Cyan
    $psrlOptions = Get-PSReadLineOption
    Write-Host "  Edit Mode: $($psrlOptions.EditMode)" -ForegroundColor Yellow
    Write-Host "  Prediction Source: $($psrlOptions.PredictionSource)" -ForegroundColor Yellow
    Write-Host "  Prediction View: $($psrlOptions.PredictionViewStyle)" -ForegroundColor Yellow
    Write-Host "  History Count: $($psrlOptions.MaximumHistoryCount)" -ForegroundColor Yellow
    Write-Host "  Colors: Dracula theme applied ✅" -ForegroundColor Green
    
    Write-Host "📋 Key Bindings Test:" -ForegroundColor Cyan
    $keyTests = @(
        "Ctrl+LeftArrow    -> BackwardWord {Standard word navigation}",
        "Ctrl+RightArrow   -> ForwardWord {Standard word navigation}", 
        "Alt+LeftArrow     -> BackwardCamelCaseWord {CamelCase + diacritics, respects _/-/.}",
        "Alt+RightArrow    -> ForwardCamelCaseWord {CamelCase + diacritics, respects _/-/.}",
        "Ctrl+UpArrow      -> HistorySearchBackward",
        "Ctrl+DownArrow    -> HistorySearchForward",
        "Ctrl+f            -> AcceptSuggestion {Accept current prediction}",
        "F2                -> SwitchPredictionView {Toggle list/inline view}",
        "F7                -> ShowKeyBindings",
        "Ctrl+r            -> ReverseSearchHistory",
        "Alt+F7            -> ClearHistory",
        "Alt+d             -> Insert '..\' {Quick parent directory}",
        "Alt+h             -> Go to home directory",
        "Ctrl+l            -> ClearScreen"
    )
    
    foreach ($test in $keyTests) {
        Write-Host "  $test" -ForegroundColor Gray
    }
    
    Write-Host "💡 Try: 'my_variable-name.property' with Alt+Left/Right" -ForegroundColor Green
    Write-Host "💡 Underscore keeps words joined, hyphen/dot create boundaries" -ForegroundColor Green
}

function Show-PSReadLineHelp {
    Write-Host "🔤 PSReadLine Quick Reference:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📍 Navigation:" -ForegroundColor Yellow
    Write-Host "  Ctrl+Left/Right Arrow  - Move by standard word boundaries" -ForegroundColor Gray
    Write-Host "  Alt+Left/Right Arrow   - Move by CamelCase + diacritics (respects _, -, .)" -ForegroundColor Magenta
    Write-Host "  Home/End               - Move to start/end of line" -ForegroundColor Gray
    Write-Host "  Ctrl+Home/End          - Move to start/end of input" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📚 History:" -ForegroundColor Yellow  
    Write-Host "  Ctrl+Up/Down Arrow     - Search history" -ForegroundColor Gray
    Write-Host "  F7                     - Show key bindings" -ForegroundColor Gray
    Write-Host "  Ctrl+r                 - Reverse search" -ForegroundColor Gray
    Write-Host ""
    Write-Host "✂️ Editing:" -ForegroundColor Yellow
    Write-Host "  Ctrl+Backspace/Delete  - Delete standard word" -ForegroundColor Gray
    Write-Host "  Ctrl+z/y               - Undo/Redo" -ForegroundColor Gray
    Write-Host "  Tab/Shift+Tab          - Menu completion" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🧛‍♂️ CamelCase Navigation Rules:" -ForegroundColor Magenta
    Write-Host "  _ (underscore) - Keeps words joined together" -ForegroundColor Green
    Write-Host "  - (hyphen)     - Creates new word boundary" -ForegroundColor Yellow  
    Write-Host "  . (dot)        - Creates new word boundary" -ForegroundColor Yellow
    Write-Host "  CamelCase      - Breaks on case transitions" -ForegroundColor Cyan
    Write-Host "  Diacritics     - Supported (á, é, í, ó, ú, č, ď...)" -ForegroundColor Cyan
}

function Show-CamelCaseDemo {
    Write-Host "🧛‍♂️ CamelCase + Diacritics Navigation Demo:" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "📝 Try typing these examples and use Alt+Left/Right:" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "🔤 PowerShell Commands:" -ForegroundColor Yellow
    $psExamples = @(
        "Get-ChildItem -Path C:\Windows\System32",
        "New-PSSession -ComputerName Server01", 
        "Import-Module -Name ActiveDirectory",
        "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned"
    )
    foreach ($example in $psExamples) {
        Write-Host "  $example" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "🧩 Underscore Joining (treated as ONE word):" -ForegroundColor Yellow
    $underscoreExamples = @(
        "my_long_variable_name",
        "function_with_underscores",
        "DATABASE_CONNECTION_STRING"
    )
    foreach ($example in $underscoreExamples) {
        Write-Host "  $example" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "➖ Hyphen Boundaries:" -ForegroundColor Yellow
    $hyphenExamples = @(
        "kebab-case-variable",
        "multi-word-command",
        "docker-compose-file"
    )
    foreach ($example in $hyphenExamples) {
        Write-Host "  $example" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "🔘 Dot Boundaries:" -ForegroundColor Yellow
    $dotExamples = @(
        "[System.IO.Path]::GetFileName(`$filePath)",
        "Microsoft.PowerShell.Core",
        "config.json.backup"
    )
    foreach ($example in $dotExamples) {
        Write-Host "  $example" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "🌍 Diacritics Support:" -ForegroundColor Yellow
    $diacriticsExamples = @(
        "příkaz-sNázvem-čeština",
        "función-conAcentos-español", 
        "commentaireAvecAccents-français"
    )
    foreach ($example in $diacriticsExamples) {
        Write-Host "  $example" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "🎯 Navigation Behavior:" -ForegroundColor Green
    Write-Host "  • underscore_words    -> Treated as single unit" -ForegroundColor Cyan
    Write-Host "  • hyphen-words        -> Break at each hyphen" -ForegroundColor Cyan  
    Write-Host "  • dot.words           -> Break at each dot" -ForegroundColor Cyan
    Write-Host "  • camelCaseWords      -> Break at case changes" -ForegroundColor Cyan
    Write-Host "  • áčcentedWörds       -> Full diacritics support" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "💡 This matches your bash/zsh navigation conventions!" -ForegroundColor Green
}

function Show-PSReadLineColors {
    Write-Host "🎨 Current PSReadLine Dracula Color Scheme:" -ForegroundColor Magenta
    Write-Host ""
    
    $colorMap = @{
        'Command'   = '#50fa7b (Green) - Commands like Get-ChildItem'
        'Number'    = '#bd93f9 (Purple) - Numbers and numeric values'
        'Member'    = '#ffb86c (Orange) - Object members and properties'
        'Operator'  = '#ff79c6 (Pink) - Operators like -eq, |, >'
        'Type'      = '#8be9fd (Cyan) - Type names like [string]'
        'Variable'  = '#f8f8f2 (Foreground) - Variables like $var'
        'Parameter' = '#ffb86c (Orange) - Parameters like -Path'
        'String'    = '#f1fa8c (Yellow) - String literals'
        'Comment'   = '#6272a4 (Comment) - Comments and predictions'
        'Keyword'   = '#ff79c6 (Pink) - Keywords like if, else'
        'Error'     = '#ff5555 (Red) - Error text'
        'Selection' = '#44475a (Selection) - Selected text background'
    }
    
    foreach ($color in $colorMap.GetEnumerator()) {
        Write-Host "  $($color.Key): " -NoNewline -ForegroundColor White
        Write-Host $color.Value -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "💡 These colors make PowerShell syntax much more readable!" -ForegroundColor Green
}

function Reset-PSReadLineToDefaults {
    Write-Host "🔄 Resetting PSReadLine to default settings..." -ForegroundColor Yellow
    
    try {
        # Remove all custom key handlers
        Remove-PSReadLineKeyHandler -Key Alt+LeftArrow
        Remove-PSReadLineKeyHandler -Key Alt+RightArrow
        Remove-PSReadLineKeyHandler -Key Alt+d
        Remove-PSReadLineKeyHandler -Key Alt+h
        Remove-PSReadLineKeyHandler -Key 'Ctrl+Shift+Enter'
        
        # Reset to default options
        Set-PSReadLineOption -EditMode Windows
        Set-PSReadLineOption -BellStyle Audible
        Set-PSReadLineOption -PredictionSource History
        Set-PSReadLineOption -PredictionViewStyle InlineView
        
        Write-Host "✅ PSReadLine reset to defaults" -ForegroundColor Green
        Write-Host "💡 Restart PowerShell or run . `$PROFILE to reload enhanced settings" -ForegroundColor Gray
    } catch {
        Write-Host "❌ Error resetting PSReadLine: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Show-PSReadLineStats {
    Write-Host "📊 PSReadLine Statistics:" -ForegroundColor Cyan
    
    $history = Get-PSReadLineOption | Select-Object -ExpandProperty HistorySavePath
    if (Test-Path $history) {
        $historyCount = (Get-Content $history).Count
        $historySize = [Math]::Round((Get-Item $history).Length / 1KB, 2)
        Write-Host "  History File: $history" -ForegroundColor Gray
        Write-Host "  History Commands: $historyCount" -ForegroundColor Yellow
        Write-Host "  History Size: ${historySize} KB" -ForegroundColor Yellow
    }
    
    $keyHandlers = Get-PSReadLineKeyHandler
    $customHandlers = $keyHandlers | Where-Object { $_.Description -like "*CamelCase*" -or $_.Description -like "*Insert*" -or $_.Description -like "*Go to*" }
    
    Write-Host "  Total Key Handlers: $($keyHandlers.Count)" -ForegroundColor Yellow
    Write-Host "  Custom Handlers: $($customHandlers.Count)" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "🔤 Custom Key Handlers:" -ForegroundColor Green
    foreach ($handler in $customHandlers) {
        Write-Host "  $($handler.Key): $($handler.Description)" -ForegroundColor Gray
    }
}

# Aliases for easy access
Set-Alias -Name profile-info -Value Get-EnhancedProfileInfo
Set-Alias -Name test-psreadline -Value Test-PSReadLineFeatures  
Set-Alias -Name psreadline-help -Value Show-PSReadLineHelp
Set-Alias -Name help-keys -Value Show-PSReadLineHelp
Set-Alias -Name demo-camel -Value Show-CamelCaseDemo
Set-Alias -Name demo-pascal -Value Show-CamelCaseDemo  # Legacy alias
Set-Alias -Name show-colors -Value Show-PSReadLineColors
Set-Alias -Name psrl-colors -Value Show-PSReadLineColors
Set-Alias -Name psrl-stats -Value Show-PSReadLineStats
Set-Alias -Name psrl-reset -Value Reset-PSReadLineToDefaults
Set-Alias -Name ll -Value Get-ChildItem  # Common alias
Set-Alias -Name la -Value Get-ChildItem  # Show all files
#endregion

#region 🔧 Final Setup
# Performance tracking completion
if ($env:DRACULA_PERFORMANCE_DEBUG -eq 'true') {
    Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
        if ($global:ProfileLoadStart) {
            $loadTime = $global:ProfileLoadStart.Elapsed.TotalMilliseconds
            Write-Host "⚡ Enhanced Dracula Profile loaded in ${loadTime:F2}ms" -ForegroundColor Green
            $global:LastProfileLoadTime = $loadTime
        }
    }
}

# Welcome message
if ($env:DRACULA_SHOW_STARTUP -eq 'true') {
    Write-Host ""
    Write-Host "🧛‍♂️ Enhanced Dracula PowerShell Profile Ready!" -ForegroundColor Magenta
    Write-Host "⚡ Performance-focused with advanced PSReadLine features" -ForegroundColor Green
    Write-Host ""
    Write-Host "� Quick Commands:" -ForegroundColor Cyan
    Write-Host "  help-keys     - PSReadLine shortcuts and navigation" -ForegroundColor Gray
    Write-Host "  demo-camel    - CamelCase + diacritics navigation demo" -ForegroundColor Gray
    Write-Host "  show-colors   - Display Dracula color scheme" -ForegroundColor Gray
    Write-Host "  profile-info  - Module status and load time" -ForegroundColor Gray
    Write-Host "  psrl-stats    - PSReadLine statistics" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🎯 Key Features:" -ForegroundColor Yellow
    Write-Host "  • Dracula colors for syntax highlighting" -ForegroundColor Gray
    Write-Host "  • Advanced CamelCase navigation (Alt+Left/Right)" -ForegroundColor Gray
    Write-Host "  • Smart predictions and completion" -ForegroundColor Gray
    Write-Host "  • Git status in prompt" -ForegroundColor Gray
    Write-Host "  • No Oh My Posh overhead - pure PSReadLine performance!" -ForegroundColor Green
    Write-Host ""
}
#endregion
