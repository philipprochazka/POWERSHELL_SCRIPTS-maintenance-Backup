# ===================================================================
# 🧛‍♂️ DRACULA POWERPACK MODULE 🧛‍♂️
# Enhances your PowerShell experience with Dracula-themed utilities
# ===================================================================

#region 🎨 Dracula Color Functions

function Show-DraculaColors {
    <#
    .SYNOPSIS
        Displays the Dracula color palette
    .DESCRIPTION
        Shows all Dracula colors with their hex codes and visual representation
    #>
    $colors = @{
        'Background'  = @{ Hex = '#282a36'; RGB = @(40, 42, 54) }
        'CurrentLine' = @{ Hex = '#44475a'; RGB = @(68, 71, 90) }
        'Foreground'  = @{ Hex = '#f8f8f2'; RGB = @(248, 248, 242) }
        'Comment'     = @{ Hex = '#6272a4'; RGB = @(98, 114, 164) }
        'Cyan'        = @{ Hex = '#8be9fd'; RGB = @(139, 233, 253) }
        'Green'       = @{ Hex = '#50fa7b'; RGB = @(80, 250, 123) }
        'Orange'      = @{ Hex = '#ffb86c'; RGB = @(255, 184, 108) }
        'Pink'        = @{ Hex = '#ff79c6'; RGB = @(255, 121, 198) }
        'Purple'      = @{ Hex = '#bd93f9'; RGB = @(189, 147, 249) }
        'Red'         = @{ Hex = '#ff5555'; RGB = @(255, 85, 85) }
        'Yellow'      = @{ Hex = '#f1fa8c'; RGB = @(241, 250, 140) }
    }

    Write-Host "`n🧛‍♂️ DRACULA COLOR PALETTE 🧛‍♂️" -ForegroundColor Magenta
    Write-Host "=================================" -ForegroundColor Magenta
    
    foreach ($color in $colors.GetEnumerator()) {
        $name = $color.Key.PadRight(12)
        $hex = $color.Value.Hex
        $rgb = "RGB({0},{1},{2})" -f $color.Value.RGB
        
        # Try to display with color if possible
        try {
            Write-Host "$name $hex $rgb ████████" -ForegroundColor $color.Key
        } catch {
            Write-Host "$name $hex $rgb ████████"
        }
    }
    Write-Host ""
}

function Set-DraculaWindowTitle {
    <#
    .SYNOPSIS
        Sets a Dracula-themed window title
    .PARAMETER Title
        Custom title text
    #>
    param(
        [string]$Title = "Dracula PowerShell"
    )
    $Host.UI.RawUI.WindowTitle = "🧛‍♂️ $Title 🧛‍♂️"
}

#endregion

#region 🎭 Fun Utilities

function Invoke-DraculaQuote {
    <#
    .SYNOPSIS
        Displays a random vampire/dark-themed quote
    #>
    $quotes = @(
        "I vant to drink your... coffee ☕",
        "Welcome to the dark side, we have cookies 🍪",
        "Coding by moonlight 🌙",
        "In the darkness, we find the light of code ✨",
        "Embrace the night, embrace the code 🌃",
        "Count your functions, not your sheep 🐑",
        "Debugging is like vampire hunting - you need the right tools 🔨",
        "Code never sleeps, and neither do vampires 💤",
        "In PowerShell we trust, in Dracula we theme 🧛‍♂️",
        "Bite-sized scripts for eternal productivity 🦇"
    )
    
    $quote = $quotes | Get-Random
    Write-Host "`n🧛‍♂️ " -ForegroundColor Magenta -NoNewline
    Write-Host $quote -ForegroundColor Cyan
    Write-Host ""
}

function Start-DraculaDemo {
    <#
    .SYNOPSIS
        Demonstrates various PowerShell features with Dracula styling
    #>
    Write-Host "🧛‍♂️ DRACULA POWERSHELL DEMO 🧛‍♂️" -ForegroundColor Magenta
    Write-Host "=================================" -ForegroundColor Magenta
    
    # Colorful process list
    Write-Host "`n📊 System Processes (Top 10 by CPU):" -ForegroundColor Cyan
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU, WorkingSet | Format-Table -AutoSize
    
    # System info
    Write-Host "💻 System Information:" -ForegroundColor Green
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    Write-Host "OS: $($os.Caption) $($os.Version)" -ForegroundColor Yellow
    Write-Host "RAM: $([math]::Round($os.TotalVisibleMemorySize/1MB, 2)) GB" -ForegroundColor Yellow
    
    # Fun file count
    Write-Host "`n📁 Current Directory Stats:" -ForegroundColor Pink
    $files = Get-ChildItem -File
    $folders = Get-ChildItem -Directory
    Write-Host "Files: $($files.Count)" -ForegroundColor Orange
    Write-Host "Folders: $($folders.Count)" -ForegroundColor Orange
    
    Invoke-DraculaQuote
}

function Get-DraculaWeather {
    <#
    .SYNOPSIS
        Gets weather information with Dracula styling (requires internet)
    .PARAMETER City
        City name for weather lookup
    #>
    param(
        [string]$City = "Transylvania"
    )
    
    try {
        Write-Host "🌙 Checking the night weather in $City..." -ForegroundColor Purple
        # This would require an API key in real usage
        Write-Host "Perfect weather for coding! 🧛‍♂️" -ForegroundColor Green
    } catch {
        Write-Host "The mist obscures the weather... try again later 🌫️" -ForegroundColor Yellow
    }
}

#endregion

#region 🔧 Productivity Tools

function New-DraculaScript {
    <#
    .SYNOPSIS
        Creates a new PowerShell script with Dracula template
    .PARAMETER Name
        Script name
    .PARAMETER Path
        Script path
    #>
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$Path = "."
    )
    
    $scriptPath = Join-Path $Path "$Name.ps1"
    $template = @"
#Requires -Version 7.0
<#
.SYNOPSIS
    🧛‍♂️ $Name - A Dracula-powered PowerShell script

.DESCRIPTION
    Detailed description of what this script does in the darkness

.PARAMETER Parameter1
    Description of the parameter

.EXAMPLE
    .\$Name.ps1 -Parameter1 "Value"

.NOTES
    Author: Vampire Coder 🧛‍♂️
    Date: $(Get-Date -Format 'yyyy-MM-dd')
    Version: 1.0
    Theme: Dracula 🦇
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = `$false)]
    [string]`$Parameter1
)

begin {
    Write-Host "🧛‍♂️ Starting `$(`$MyInvocation.MyCommand.Name)" -ForegroundColor Magenta
    Write-Verbose "Awakening from the digital tomb..."
}

process {
    # 🌙 Main script logic here
    Write-Host "Processing in the darkness..." -ForegroundColor Cyan
}

end {
    Write-Host "✨ `$(`$MyInvocation.MyCommand.Name) completed successfully!" -ForegroundColor Green
    Write-Verbose "Returning to the shadows..."
}
"@
    
    $template | Out-File -FilePath $scriptPath -Encoding UTF8
    Write-Host "🧛‍♂️ Created script: $scriptPath" -ForegroundColor Green
    
    if (Get-Command code -ErrorAction SilentlyContinue) {
        code $scriptPath
    }
}

function Get-DraculaSystemInfo {
    <#
    .SYNOPSIS
        Displays comprehensive system information with Dracula styling
    #>
    Write-Host "🧛‍♂️ SYSTEM INFORMATION 🧛‍♂️" -ForegroundColor Magenta
    Write-Host "=========================" -ForegroundColor Magenta
    
    # OS Info
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    Write-Host "`n💻 Operating System:" -ForegroundColor Cyan
    Write-Host "  Name: $($os.Caption)" -ForegroundColor Yellow
    Write-Host "  Version: $($os.Version)" -ForegroundColor Yellow
    Write-Host "  Architecture: $($os.OSArchitecture)" -ForegroundColor Yellow
    
    # Hardware Info
    $cpu = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1
    Write-Host "`n🔥 Processor:" -ForegroundColor Green
    Write-Host "  Name: $($cpu.Name)" -ForegroundColor Orange
    Write-Host "  Cores: $($cpu.NumberOfCores)" -ForegroundColor Orange
    Write-Host "  Logical Processors: $($cpu.NumberOfLogicalProcessors)" -ForegroundColor Orange
    
    # Memory Info
    $totalRAM = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $freeRAM = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $usedRAM = $totalRAM - $freeRAM
    Write-Host "`n🧠 Memory:" -ForegroundColor Pink
    Write-Host "  Total: $totalRAM GB" -ForegroundColor Purple
    Write-Host "  Used: $usedRAM GB" -ForegroundColor Purple
    Write-Host "  Free: $freeRAM GB" -ForegroundColor Purple
    
    # PowerShell Info
    Write-Host "`n⚡ PowerShell:" -ForegroundColor Cyan
    Write-Host "  Version: $($PSVersionTable.PSVersion)" -ForegroundColor Yellow
    Write-Host "  Edition: $($PSVersionTable.PSEdition)" -ForegroundColor Yellow
    Write-Host "  Host: $($Host.Name)" -ForegroundColor Yellow
}

function Invoke-DraculaCleanup {
    <#
    .SYNOPSIS
        Cleans temporary files with dramatic flair
    #>
    Write-Host "🧛‍♂️ Awakening the cleanup spirits..." -ForegroundColor Magenta
    
    $tempPaths = @(
        $env:TEMP,
        "$env:USERPROFILE\AppData\Local\Temp",
        "$env:WINDIR\Temp"
    )
    
    $totalCleaned = 0
    foreach ($path in $tempPaths) {
        if (Test-Path $path) {
            Write-Host "🌙 Cleansing $path..." -ForegroundColor Cyan
            try {
                $files = Get-ChildItem $path -File -Force -ErrorAction SilentlyContinue
                $size = ($files | Measure-Object -Property Length -Sum).Sum
                $totalCleaned += $size
                Write-Host "  Found $($files.Count) files ($([math]::Round($size/1MB, 2)) MB)" -ForegroundColor Yellow
            } catch {
                Write-Host "  Some files are protected by ancient magic..." -ForegroundColor Red
            }
        }
    }
    
    Write-Host "✨ Cleanup ritual complete! Freed $([math]::Round($totalCleaned/1MB, 2)) MB from the digital realm" -ForegroundColor Green
}

#endregion

#region 🎵 ASCII Art

function Show-DraculaBat {
    <#
    .SYNOPSIS
        Displays ASCII bat art
    #>
    $bat = @"
🧛‍♂️ DRACULA POWERSHELL 🧛‍♂️

       /|       /|  
      ( :v:   :v: )
       |(_) (_)|
       |       |
      /         \
     /    ___    \
    |    (   )    |
     \    ^^^    /
      \  -----  /
       \_______/
        
    Welcome to the Dark Side of PowerShell!
"@
    
    Write-Host $bat -ForegroundColor Magenta
}

#endregion

# Export functions
Export-ModuleMember -Function *

# Welcome message when module is imported
Write-Host "🧛‍♂️ Dracula PowerPack loaded! Type 'Get-Command *Dracula*' to see available commands." -ForegroundColor Magenta
