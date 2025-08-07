<#
.SYNOPSIS
    Real-time Debug and Performance Monitor for Dracula Profile
.DESCRIPTION
    Lightweight debug helper that can be integrated into the profile for
    real-time performance monitoring and optimization insights.
.VERSION
    1.0.0
.AUTHOR
    Philip Procházka
#>

#region 🔬 Debug Metrics Collection
$global:DraculaDebugMetrics = @{
    StartTime        = Get-Date
    LoadingStages    = @{}
    MemorySnapshots  = @{}
    ModuleLoadTimes  = @{}
    Warnings         = @()
    Errors           = @()
    PerformanceFlags = @{}
}

function Add-DraculaDebugStage {
    param(
        [string]$StageName,
        [string]$Action = 'Start'
    )
    
    if (-not $global:DraculaDebugMetrics.LoadingStages.ContainsKey($StageName)) {
        $global:DraculaDebugMetrics.LoadingStages[$StageName] = @{}
    }
    
    $timestamp = Get-Date
    $global:DraculaDebugMetrics.LoadingStages[$StageName][$Action] = $timestamp
    
    if ($Action -eq 'Start') {
        $global:DraculaDebugMetrics.MemorySnapshots["$StageName-Start"] = [System.GC]::GetTotalMemory($false)
    } elseif ($Action -eq 'End') {
        $global:DraculaDebugMetrics.MemorySnapshots["$StageName-End"] = [System.GC]::GetTotalMemory($false)
        
        # Calculate duration
        $startTime = $global:DraculaDebugMetrics.LoadingStages[$StageName]['Start']
        if ($startTime) {
            $duration = ($timestamp - $startTime).TotalMilliseconds
            $global:DraculaDebugMetrics.LoadingStages[$StageName]['Duration'] = $duration
            
            # Flag slow stages
            if ($duration -gt 200) {
                $global:DraculaDebugMetrics.Warnings += "Stage '$StageName' took $([math]::Round($duration, 1))ms (>200ms threshold)"
            }
        }
    }
}

function Add-DraculaDebugModule {
    param(
        [string]$ModuleName,
        [string]$Action = 'Start',
        [string]$ErrorMessage = ''
    )
    
    if (-not $global:DraculaDebugMetrics.ModuleLoadTimes.ContainsKey($ModuleName)) {
        $global:DraculaDebugMetrics.ModuleLoadTimes[$ModuleName] = @{
            StartTime = $null
            EndTime   = $null
            Duration  = $null
            Success   = $false
            Error     = ''
        }
    }
    
    $module = $global:DraculaDebugMetrics.ModuleLoadTimes[$ModuleName]
    
    if ($Action -eq 'Start') {
        $module.StartTime = Get-Date
    } elseif ($Action -eq 'End') {
        $module.EndTime = Get-Date
        if ($module.StartTime) {
            $module.Duration = ($module.EndTime - $module.StartTime).TotalMilliseconds
        }
        $module.Success = [string]::IsNullOrEmpty($ErrorMessage)
        $module.Error = $ErrorMessage
        
        # Flag slow or failed modules
        if ($module.Duration -gt 100) {
            $global:DraculaDebugMetrics.Warnings += "Module '$ModuleName' took $([math]::Round($module.Duration, 1))ms (>100ms threshold)"
        }
        if (-not $module.Success) {
            $global:DraculaDebugMetrics.Errors += "Module '$ModuleName' failed to load: $ErrorMessage"
        }
    }
}

function Set-DraculaPerformanceFlag {
    param(
        [string]$FlagName,
        [object]$Value
    )
    
    $global:DraculaDebugMetrics.PerformanceFlags[$FlagName] = @{
        Value     = $Value
        Timestamp = Get-Date
    }
}

function Get-DraculaDebugSummary {
    [CmdletBinding()]
    param(
        [switch]$Detailed,
        [switch]$OnlyWarnings
    )
    
    $totalTime = ((Get-Date) - $global:DraculaDebugMetrics.StartTime).TotalMilliseconds
    
    Write-Host ""
    Write-Host "🧛‍♂️ DRACULA DEBUG SUMMARY" -ForegroundColor Magenta
    Write-Host "========================" -ForegroundColor Gray
    Write-Host ""
    
    # Overall performance
    $color = if ($totalTime -lt 500) {
        'Green' 
    } elseif ($totalTime -lt 1000) {
        'Yellow' 
    } else {
        'Red' 
    }
    Write-Host "⏱️  Total Load Time: " -NoNewline -ForegroundColor Cyan
    Write-Host "$([math]::Round($totalTime, 1))ms" -ForegroundColor $color
    
    # Memory usage
    $memoryUsed = $global:DraculaDebugMetrics.MemorySnapshots.Values | Measure-Object -Maximum -Minimum
    if ($memoryUsed.Maximum -and $memoryUsed.Minimum) {
        $memoryDelta = ($memoryUsed.Maximum - $memoryUsed.Minimum) / 1MB
        Write-Host "💾 Memory Delta: " -NoNewline -ForegroundColor Cyan
        Write-Host "$([math]::Round($memoryDelta, 2)) MB" -ForegroundColor White
    }
    
    # Errors and warnings
    if ($global:DraculaDebugMetrics.Errors.Count -gt 0) {
        Write-Host ""
        Write-Host "❌ Errors ($($global:DraculaDebugMetrics.Errors.Count)):" -ForegroundColor Red
        foreach ($error in $global:DraculaDebugMetrics.Errors) {
            Write-Host "   $error" -ForegroundColor Red
        }
    }
    
    if ($global:DraculaDebugMetrics.Warnings.Count -gt 0) {
        Write-Host ""
        Write-Host "⚠️  Warnings ($($global:DraculaDebugMetrics.Warnings.Count)):" -ForegroundColor Yellow
        foreach ($warning in $global:DraculaDebugMetrics.Warnings) {
            Write-Host "   $warning" -ForegroundColor Yellow
        }
    }
    
    if (-not $OnlyWarnings -and $Detailed) {
        # Loading stages
        Write-Host ""
        Write-Host "📊 Loading Stages:" -ForegroundColor Cyan
        foreach ($stage in $global:DraculaDebugMetrics.LoadingStages.GetEnumerator()) {
            if ($stage.Value.Duration) {
                $stageColor = if ($stage.Value.Duration -lt 100) {
                    'Green' 
                } elseif ($stage.Value.Duration -lt 200) {
                    'Yellow' 
                } else {
                    'Red' 
                }
                Write-Host "   $($stage.Key): " -NoNewline -ForegroundColor Gray
                Write-Host "$([math]::Round($stage.Value.Duration, 1))ms" -ForegroundColor $stageColor
            }
        }
        
        # Module performance
        Write-Host ""
        Write-Host "🧩 Module Performance:" -ForegroundColor Cyan
        foreach ($module in $global:DraculaDebugMetrics.ModuleLoadTimes.GetEnumerator()) {
            if ($module.Value.Duration) {
                $moduleColor = if ($module.Value.Success) {
                    if ($module.Value.Duration -lt 50) {
                        'Green' 
                    } elseif ($module.Value.Duration -lt 100) {
                        'Yellow' 
                    } else {
                        'Red' 
                    }
                } else {
                    'Red' 
                }
                
                $status = if ($module.Value.Success) {
                    "✅" 
                } else {
                    "❌" 
                }
                Write-Host "   $status $($module.Key): " -NoNewline -ForegroundColor Gray
                Write-Host "$([math]::Round($module.Value.Duration, 1))ms" -ForegroundColor $moduleColor
            }
        }
        
        # Performance flags
        if ($global:DraculaDebugMetrics.PerformanceFlags.Count -gt 0) {
            Write-Host ""
            Write-Host "🎯 Performance Flags:" -ForegroundColor Cyan
            foreach ($flag in $global:DraculaDebugMetrics.PerformanceFlags.GetEnumerator()) {
                Write-Host "   $($flag.Key): " -NoNewline -ForegroundColor Gray
                Write-Host "$($flag.Value.Value)" -ForegroundColor White
            }
        }
    }
    
    # Performance recommendations
    Write-Host ""
    Write-Host "💡 Quick Recommendations:" -ForegroundColor Cyan
    
    $recommendations = @()
    
    if ($totalTime -gt 1000) {
        $recommendations += "Consider enabling lazy loading for all non-essential modules"
    }
    
    $slowModules = $global:DraculaDebugMetrics.ModuleLoadTimes.GetEnumerator() | Where-Object { $_.Value.Duration -gt 100 }
    if ($slowModules) {
        $recommendations += "Slow modules detected: $($slowModules.Key -join ', ') - consider lazy loading"
    }
    
    $failedModules = $global:DraculaDebugMetrics.ModuleLoadTimes.GetEnumerator() | Where-Object { -not $_.Value.Success }
    if ($failedModules) {
        $recommendations += "Failed modules: $($failedModules.Key -join ', ') - consider removing or fixing"
    }
    
    if ($recommendations.Count -eq 0) {
        $recommendations += "Profile performance is good! 🎉"
    }
    
    foreach ($rec in $recommendations) {
        Write-Host "   • $rec" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

function Reset-DraculaDebugMetrics {
    $global:DraculaDebugMetrics = @{
        StartTime        = Get-Date
        LoadingStages    = @{}
        MemorySnapshots  = @{}
        ModuleLoadTimes  = @{}
        Warnings         = @()
        Errors           = @()
        PerformanceFlags = @{}
    }
    
    Write-Host "🔄 Debug metrics reset" -ForegroundColor Green
}

function Export-DraculaDebugMetrics {
    param([string]$Path = (Join-Path $PSScriptRoot "Logs\debug-metrics-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"))
    
    $exportData = @{
        Timestamp        = Get-Date
        TotalLoadTime    = ((Get-Date) - $global:DraculaDebugMetrics.StartTime).TotalMilliseconds
        LoadingStages    = $global:DraculaDebugMetrics.LoadingStages
        ModuleLoadTimes  = $global:DraculaDebugMetrics.ModuleLoadTimes
        Warnings         = $global:DraculaDebugMetrics.Warnings
        Errors           = $global:DraculaDebugMetrics.Errors
        PerformanceFlags = $global:DraculaDebugMetrics.PerformanceFlags
        SystemInfo       = @{
            PowerShellVersion = $PSVersionTable.PSVersion.ToString()
            MemoryUsage       = [System.GC]::GetTotalMemory($false)
            ProcessorCount    = [System.Environment]::ProcessorCount
        }
    }
    
    $dir = Split-Path $Path -Parent
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
    
    $exportData | ConvertTo-Json -Depth 10 | Out-File -FilePath $Path -Encoding UTF8
    
    Write-Host "📊 Debug metrics exported to: " -NoNewline -ForegroundColor Green
    Write-Host $Path -ForegroundColor Yellow
    
    return $Path
}
#endregion

#region 🎯 Profile Integration Functions
function Enable-DraculaDebugMode {
    $global:DraculaDebugEnabled = $true
    Write-Host "🔬 Dracula debug mode enabled" -ForegroundColor Green
}

function Disable-DraculaDebugMode {
    $global:DraculaDebugEnabled = $false
    Write-Host "🔇 Dracula debug mode disabled" -ForegroundColor Gray
}

function Invoke-DraculaDebugStep {
    param(
        [string]$StepName,
        [scriptblock]$ScriptBlock
    )
    
    if ($global:DraculaDebugEnabled) {
        Add-DraculaDebugStage -StageName $StepName -Action 'Start'
    }
    
    try {
        $result = & $ScriptBlock
        
        if ($global:DraculaDebugEnabled) {
            Add-DraculaDebugStage -StageName $StepName -Action 'End'
        }
        
        return $result
    } catch {
        if ($global:DraculaDebugEnabled) {
            $global:DraculaDebugMetrics.Errors += "Step '$StepName' failed: $($_.Exception.Message)"
            Add-DraculaDebugStage -StageName $StepName -Action 'End'
        }
        throw
    }
}

function Invoke-DraculaDebugModule {
    param(
        [string]$ModuleName,
        [scriptblock]$LoadScript
    )
    
    if ($global:DraculaDebugEnabled) {
        Add-DraculaDebugModule -ModuleName $ModuleName -Action 'Start'
    }
    
    try {
        $result = & $LoadScript
        
        if ($global:DraculaDebugEnabled) {
            Add-DraculaDebugModule -ModuleName $ModuleName -Action 'End'
        }
        
        return $result
    } catch {
        if ($global:DraculaDebugEnabled) {
            Add-DraculaDebugModule -ModuleName $ModuleName -Action 'End' -ErrorMessage $_.Exception.Message
        }
        throw
    }
}
#endregion

# Aliases for easy access
Set-Alias -Name dbg-summary -Value Get-DraculaDebugSummary -Force
Set-Alias -Name dbg-reset -Value Reset-DraculaDebugMetrics -Force
Set-Alias -Name dbg-export -Value Export-DraculaDebugMetrics -Force
Set-Alias -Name dbg-on -Value Enable-DraculaDebugMode -Force
Set-Alias -Name dbg-off -Value Disable-DraculaDebugMode -Force

# Auto-enable debug mode if environment variable is set
if ($env:DRACULA_DEBUG -eq 'true') {
    Enable-DraculaDebugMode
}
