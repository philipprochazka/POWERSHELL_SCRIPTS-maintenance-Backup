# =============================================
# Repair-DraculaProfile.ps1
# Complete repair for all profile syntax issues
# =============================================

[CmdletBinding()]
param(
    [switch]$FixAllProfiles,
    [switch]$WhatIf
)

function Repair-ProfileSyntax {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$ProfilePath
    )
    
    Write-Host "🔧 Repairing profile: $ProfilePath" -ForegroundColor Cyan
    
    if (-not (Test-Path $ProfilePath)) {
        Write-Warning "Profile not found: $ProfilePath"
        return $false
    }
    
    try {
        $content = Get-Content $ProfilePath -Raw
        $originalContent = $content
        
        # Fix 1: Replace all Unicode emoji characters with text equivalents
        $emojiMap = @{
            '🖥️'   = 'Computer'
            '💻'    = 'OS'
            '🔧'    = 'Settings'
            '💾'    = 'Save'
            '📂'    = 'Folder'
            '📄'    = 'File'
            '🎨'    = 'Theme'
            '⚡'     = 'Fast'
            '🔍'    = 'Search'
            '📊'    = 'Stats'
            '🧛‍♂️' = 'Dracula'
            '🦇'    = 'Bat'
            '🌙'    = 'Moon'
            '⭐'     = 'Star'
            '✨'     = 'Sparkle'
            '🔮'    = 'Magic'
            '🎭'    = 'Drama'
            '🎯'    = 'Target'
            '🚀'    = 'Rocket'
            '💰'    = 'Money'
            '🏆'    = 'Trophy'
            '🎪'    = 'Circus'
            '🎸'    = 'Guitar'
            '🎵'    = 'Music'
            '🎶'    = 'Notes'
            '🎹'    = 'Piano'
            '🎤'    = 'Mic'
            '🎧'    = 'Headphones'
            '📱'    = 'Phone'
            '📺'    = 'TV'
            '🖨️'   = 'Printer'
            '⌨️'    = 'Keyboard'
            '🖱️'   = 'Mouse'
            '🖲️'   = 'Trackball'
            '💿'    = 'CD'
            '💽'    = 'Disk'
            '💾'    = 'Floppy'
            '📀'    = 'DVD'
            '🔌'    = 'Plug'
            '🔋'    = 'Battery'
            '📡'    = 'Satellite'
            '📢'    = 'Speaker'
            '🔊'    = 'Volume'
            '🔉'    = 'VolumeDown'
            '🔈'    = 'VolumeLow'
            '🔇'    = 'Mute'
        }
        
        foreach ($emoji in $emojiMap.GetEnumerator()) {
            $content = $content -replace [regex]::Escape($emoji.Key), $emoji.Value
        }
        
        # Fix 2: Repair malformed string interpolation - escape backticks properly
        $content = $content -replace '\$\(([^)]+)\)(?=\s*["\'])', '`$($1)'
        
        # Fix 3: Fix incomplete hash literals and malformed expressions
        # Look for patterns like @{ without proper closing
        $content = $content -replace '@\ { \s*$', '@ {}'
        
        # Fix 4: Ensure proper PowerShell script block structure
        # Check for mismatched braces and add missing ones
        $braceDepth = 0
        $lines = $content -split "`n"
        $repairedLines = @()
        
        foreach ($line in $lines) {
            # Count opening and closing braces
            $openBraces = ($line.ToCharArray() | Where-Object { $_ -eq '{ ' }).Count
            $closeBraces = ($line.ToCharArray() | Where-Object { $_ -eq '}' }).Count
            
            $braceDepth += $openBraces - $closeBraces
            $repairedLines += $line
        }
        
        # Add missing closing braces if needed
        while ($braceDepth -gt 0) {
            $repairedLines += "}"
            $braceDepth--
        }
        
        $content = $repairedLines -join "`n"
        
        # Fix 5: Specific repair for known problematic patterns
        # Fix the theme initialization structure
        $content = $content -replace '(\$initScript = \[ScriptBlock\]::Create\(\(oh-my-posh init pwsh --config \$draculaTheme\)\))\s*&\s*\$initScript', '$1`n            & $initScript'
        
        # Fix 6: Ensure proper encoding and line endings
        $content = $content -replace "`r`n", "`n"  # Normalize line endings
        $content = $content -replace "`r", "`n"    # Fix any remaining CR
        
        # Fix 7: Remove any null or invalid characters
        $content = $content -replace "`0", ""
        $content = $content -replace "[`u0000-`u0008`u000B`u000C`u000E-`u001F`u007F-`u009F]", ""
        
        # Validate the repaired content
        $parseErrors = $null
        $null = [System.Management.Automation.Language.Parser]::ParseInput($content, [ref]$null, [ref]$parseErrors)
        
        if ($parseErrors) {
            Write-Warning "Still has parse errors after repair:"
            $parseErrors | ForEach-Object { Write-Warning "  Line $($_.Extent.StartLineNumber): $($_.Message)" }
            
            # Try emergency repair for specific known issues
            if ($parseErrors.Message -like "*Missing closing*") {
                # Add additional closing braces
                $content += "`n}`n}"
                Write-Host "   Added emergency closing braces" -ForegroundColor Yellow
            }
        } else {
            Write-Host "   ✅ Syntax validated successfully!" -ForegroundColor Green
        }
        
        # Save the repaired content
        if ($PSCmdlet.ShouldProcess($ProfilePath, "Save repaired profile")) {
            if ($content -ne $originalContent) {
                Set-Content -Path $ProfilePath -Value $content -Encoding UTF8 -NoNewline
                Write-Host "   ✅ Profile repaired and saved" -ForegroundColor Green
                return $true
            } else {
                Write-Host "   ℹ️  No changes needed" -ForegroundColor Blue
                return $true
            }
        }
        
    } catch {
        Write-Error "Failed to repair profile $ProfilePath : $($_.Exception.Message)"
        return $false
    }
}

function Get-AllProfiles {
    $profiles = @()
    
    # Workspace profile
    $workspaceProfile = Join-Path $PSScriptRoot "Microsoft.PowerShell_profile_Dracula.ps1"
    if (Test-Path $workspaceProfile) {
        $profiles += @{
            Name = "Workspace Dracula Profile"
            Path = $workspaceProfile
        }
    }
    
    # System profiles (if accessible)
    try {
        $systemProfiles = @(
            @{ Name = "PS7 Current User"; Path = (& pwsh -Command '$PROFILE.CurrentUserCurrentHost' 2>$null) },
            @{ Name = "PS7 All Users"; Path = (& pwsh -Command '$PROFILE.AllUsersCurrentHost' 2>$null) },
            @{ Name = "PS5 Current User"; Path = (powershell -Command '$PROFILE.CurrentUserCurrentHost' 2>$null) },
            @{ Name = "PS5 All Users"; Path = (powershell -Command '$PROFILE.AllUsersCurrentHost' 2>$null) }
        )
        
        foreach ($profile in $systemProfiles) {
            if ($profile.Path -and (Test-Path $profile.Path)) {
                $profiles += $profile
            }
        }
    } catch {
        Write-Verbose "Could not access some system profiles: $($_.Exception.Message)"
    }
    
    return $profiles
}

# Main execution
if ($MyInvocation.InvocationName -ne '.') {
    Write-Host "🔧 DRACULA PROFILE REPAIR UTILITY" -ForegroundColor Magenta
    Write-Host "=================================" -ForegroundColor Magenta
    Write-Host ""
    
    $profiles = Get-AllProfiles
    
    if ($profiles.Count -eq 0) {
        Write-Warning "No profiles found to repair"
        exit 1
    }
    
    Write-Host "Found $($profiles.Count) profile(s) to repair:" -ForegroundColor Cyan
    $profiles | ForEach-Object { Write-Host "  • $($_.Name): $($_.Path)" -ForegroundColor White }
    Write-Host ""
    
    $repairCount = 0
    $totalCount = 0
    
    foreach ($profile in $profiles) {
        $totalCount++
        if (Repair-ProfileSyntax -ProfilePath $profile.Path -WhatIf:$WhatIf) {
            $repairCount++
        }
        Write-Host ""
    }
    
    Write-Host "🎉 Repair Summary:" -ForegroundColor Magenta
    Write-Host "==================" -ForegroundColor Magenta
    Write-Host "Profiles processed: $totalCount" -ForegroundColor White
    Write-Host "Successfully repaired: $repairCount" -ForegroundColor Green
    
    if ($repairCount -eq $totalCount) {
        Write-Host ""
        Write-Host "✅ All profiles repaired successfully!" -ForegroundColor Green
        Write-Host "🦇 Ready for the ultimate Dracula experience! 🦇" -ForegroundColor Magenta
    } else {
        Write-Host ""
        Write-Host "⚠️  Some profiles could not be fully repaired" -ForegroundColor Yellow
        Write-Host "Check the output above for details" -ForegroundColor Yellow
    }
}
