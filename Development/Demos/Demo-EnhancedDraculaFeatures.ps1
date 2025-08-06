#Requires -Version 7.0
<#
.SYNOPSIS
    🧛‍♂️ Enhanced Dracula Profile - Interactive Feature Demo

.DESCRIPTION
    Demonstrates the beloved features of the Enhanced Dracula Profile:
    - 🌍 International diacritics support with smart navigation
    - 🎨 Beautiful git status indicators  
    - ⌨️ Advanced CamelCase/PascalCase navigation

.EXAMPLE
    .\Demo-EnhancedDraculaFeatures.ps1
    Run the interactive demo

.EXAMPLE
    .\Demo-EnhancedDraculaFeatures.ps1 -ShowDiacritics
    Focus on diacritics support demo
#>

param(
    [switch]$ShowDiacritics,
    [switch]$ShowGitStatus,
    [switch]$Interactive = $true
)

function Show-DraculaHeader {
    Write-Host ''
    Write-Host '🧛‍♂️ ENHANCED DRACULA PROFILE - FEATURE SHOWCASE' -ForegroundColor Magenta
    Write-Host '=================================================' -ForegroundColor DarkMagenta
    Write-Host ''
}

function Show-DiacriticsDemo {
    Write-Host '🌍 INTERNATIONAL DIACRITICS SUPPORT ⭐ USER FAVORITE!' -ForegroundColor Cyan
    Write-Host '=====================================================' -ForegroundColor DarkCyan
    Write-Host ''
    
    $examples = @(
        @{ Lang = '🇨🇿 Czech'; Text = 'příkaz-sNázvem-čeština_proměnná.vlastnost'; Color = 'Green' }
        @{ Lang = '🇪🇸 Spanish'; Text = 'función-conAcentos-español_variable.propiedad'; Color = 'Yellow' }
        @{ Lang = '🇫🇷 French'; Text = 'commentaireAvecAccents-français_données.propriété'; Color = 'Blue' }
        @{ Lang = '🇩🇪 German'; Text = 'funktionMitUmlauten-größe_variableÄöü.eigenschaft'; Color = 'Magenta' }
        @{ Lang = '🇵🇱 Polish'; Text = 'funkcja-zPolskimiZnakami-ąćęłńóśźż_zmienna.właściwość'; Color = 'Red' }
        @{ Lang = '🇭🇺 Hungarian'; Text = 'függvény-magyarÉkezetekkel-áéíóöőüű_változó.tulajdonság'; Color = 'White' }
    )
    
    foreach ($example in $examples) {
        Write-Host "  $($example.Lang): " -NoNewline -ForegroundColor Gray
        Write-Host $example.Text -ForegroundColor $example.Color
    }
    
    Write-Host ''
    Write-Host '⌨️  Navigation Magic:' -ForegroundColor White
    Write-Host '   Alt+Left/Right  = Smart CamelCase + diacritics navigation' -ForegroundColor Gray
    Write-Host '   Ctrl+Left/Right = Standard word boundaries' -ForegroundColor Gray
    Write-Host '   Perfect support for international variable names!' -ForegroundColor Gray
}

function Show-GitStatusDemo {
    Write-Host ''
    Write-Host '🎨 GIT STATUS INDICATORS ⭐ USER FAVORITE!' -ForegroundColor Cyan
    Write-Host '===========================================' -ForegroundColor DarkCyan
    Write-Host ''
    
    # Demo the beloved conditional logic
    Write-Host '💎 The beloved conditional logic:' -ForegroundColor White
    Write-Host '   if ($gitDirty) { "🔴" } else { "🟢" }' -ForegroundColor Gray
    Write-Host ''
    
    # Demo scenarios
    $scenarios = @(
        @{ Status = 'Clean'; Dirty = $false; Description = 'All changes committed' }
        @{ Status = 'Dirty'; Dirty = $true; Description = 'Uncommitted changes detected' }
        @{ Status = 'Staged'; Dirty = $false; Description = 'Changes staged for commit' }
    )
    
    foreach ($scenario in $scenarios) {
        $indicator = if ($scenario.Dirty) {
            "🔴" 
        } else {
            "🟢" 
        }
        $color = if ($scenario.Dirty) {
            'Red' 
        } else {
            'Green' 
        }
        
        Write-Host "  $indicator " -NoNewline -ForegroundColor $color
        Write-Host "$($scenario.Status): " -NoNewline -ForegroundColor White
        Write-Host $scenario.Description -ForegroundColor Gray
    }
    
    Write-Host ''
    Write-Host '✨ Enhanced prompt example:' -ForegroundColor White
    Write-Host '   🧛 ProjectName 💎 (🟢 main) ❯ ' -ForegroundColor Magenta
}

function Show-CamelCaseDemo {
    Write-Host ''
    Write-Host '🐪 ADVANCED CAMELCASE NAVIGATION' -ForegroundColor Cyan
    Write-Host '=================================' -ForegroundColor DarkCyan
    Write-Host ''
    
    $examples = @(
        'Get-ChildItem',
        'New-PSSession', 
        '[System.IO.Path]::GetFileName',
        'myVariable_withUnderscores',
        'příkaz-sNázvem-čeština',
        'función-conAcentos-español'
    )
    
    Write-Host '🎯 Try Alt+Left/Right on these examples:' -ForegroundColor White
    foreach ($example in $examples) {
        Write-Host "   $example" -ForegroundColor Yellow
    }
    
    Write-Host ''
    Write-Host '💡 Smart boundaries recognize:' -ForegroundColor White
    Write-Host '   • CamelCase and PascalCase' -ForegroundColor Gray
    Write-Host '   • Underscores and hyphens' -ForegroundColor Gray
    Write-Host '   • Dots and colons' -ForegroundColor Gray
    Write-Host '   • International diacritics' -ForegroundColor Gray
}

function Start-InteractiveDemo {
    Show-DraculaHeader
    
    while ($true) {
        Write-Host ''
        Write-Host '🎮 Choose a demo:' -ForegroundColor White
        Write-Host '  1) 🌍 Diacritics Support (User Favorite!)' -ForegroundColor Cyan
        Write-Host '  2) 🎨 Git Status Indicators (User Favorite!)' -ForegroundColor Cyan  
        Write-Host '  3) 🐪 CamelCase Navigation' -ForegroundColor Cyan
        Write-Host '  4) 🧛‍♂️ Show All Features' -ForegroundColor Magenta
        Write-Host '  Q) Quit' -ForegroundColor Gray
        Write-Host ''
        
        $choice = Read-Host 'Your choice'
        
        switch ($choice.ToUpper()) {
            '1' {
                Show-DiacriticsDemo 
            }
            '2' {
                Show-GitStatusDemo 
            }
            '3' {
                Show-CamelCaseDemo 
            }
            '4' { 
                Show-DiacriticsDemo
                Show-GitStatusDemo
                Show-CamelCaseDemo
            }
            'Q' { 
                Write-Host ''
                Write-Host '🧛‍♂️ Thanks for exploring the Enhanced Dracula Profile!' -ForegroundColor Magenta
                Write-Host '   Enjoy your international PowerShell experience! 🌍⚡' -ForegroundColor Cyan
                return 
            }
            default { 
                Write-Host '❌ Invalid choice. Please try again.' -ForegroundColor Red 
            }
        }
    }
}

# Main execution
if ($ShowDiacritics) {
    Show-DraculaHeader
    Show-DiacriticsDemo
} elseif ($ShowGitStatus) {
    Show-DraculaHeader
    Show-GitStatusDemo
} elseif ($Interactive) {
    Start-InteractiveDemo
} else {
    Show-DraculaHeader
    Show-DiacriticsDemo
    Show-GitStatusDemo
    Show-CamelCaseDemo
}
