<#
.SYNOPSIS
    Ultra-Performance Profile Startup Comparison Tool
.DESCRIPTION
    Comprehensive testing tool for comparing startup times between different
    ultra-performance profile versions (Original, V3, V4) with lorem ipsum
    blob generation for stress testing.
.VERSION
    1.0.0
.AUTHOR
    Philip Procházka
.COPYRIGHT
    (c) 2025 PhilipProcházka. All rights reserved.
#>

param(
    [ValidateSet('Quick', 'Standard', 'Comprehensive', 'LoremIpsum')]
    [string]$TestMode = 'Standard',
    
    [int]$Iterations = 10,
    
    [switch]$GenerateReport,
    
    [switch]$IncludeLoremIpsum,
    
    [int]$LoremIpsumSize = 1000,
    
    [switch]$BenchmarkWithLoad,
    
    [string]$OutputPath = "UltraPerformance-Comparison-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
)

# ===================================================================
# 🧛‍♂️ ULTRA-PERFORMANCE PROFILE COMPARISON TOOL 🧛‍♂️
# ===================================================================

Write-Host "🔬 Ultra-Performance Profile Startup Comparison" -ForegroundColor Cyan
Write-Host "Test Mode: $TestMode | Iterations: $Iterations" -ForegroundColor Yellow
Write-Host ""

#region 📝 Lorem Ipsum Generator
function New-LoremIpsumBlob {
    param(
        [int]$WordCount = 1000,
        [switch]$AsVariable,
        [string]$VariableName = 'LoremIpsumData'
    )
    
    $loremWords = @(
        'lorem', 'ipsum', 'dolor', 'sit', 'amet', 'consectetur', 'adipiscing', 'elit',
        'sed', 'do', 'eiusmod', 'tempor', 'incididunt', 'ut', 'labore', 'et', 'dolore',
        'magna', 'aliqua', 'enim', 'ad', 'minim', 'veniam', 'quis', 'nostrud',
        'exercitation', 'ullamco', 'laboris', 'nisi', 'aliquip', 'ex', 'ea', 'commodo',
        'consequat', 'duis', 'aute', 'irure', 'in', 'reprehenderit', 'voluptate',
        'velit', 'esse', 'cillum', 'fugiat', 'nulla', 'pariatur', 'excepteur', 'sint',
        'occaecat', 'cupidatat', 'non', 'proident', 'sunt', 'culpa', 'qui', 'officia',
        'deserunt', 'mollit', 'anim', 'id', 'est', 'laborum', 'at', 'vero', 'eos',
        'accusamus', 'accusantium', 'doloremque', 'laudantium', 'totam', 'rem',
        'aperiam', 'eaque', 'ipsa', 'quae', 'ab', 'illo', 'inventore', 'veritatis',
        'et', 'quasi', 'architecto', 'beatae', 'vitae', 'dicta', 'sunt', 'explicabo',
        'nemo', 'ipsam', 'voluptatem', 'quia', 'voluptas', 'aspernatur', 'aut',
        'odit', 'fugit', 'sed', 'quia', 'consequuntur', 'magni', 'dolores', 'ratione'
    )
    
    $sb = [System.Text.StringBuilder]::new($WordCount * 8)
    
    for ($i = 0; $i -lt $WordCount; $i++) {
        $word = $loremWords[(Get-Random -Maximum $loremWords.Count)]
        if ($i -eq 0) {
            $word = (Get-Culture).TextInfo.ToTitleCase($word)
        }
        
        $sb.Append($word) | Out-Null
        
        if (($i + 1) % 15 -eq 0) {
            $sb.AppendLine('.') | Out-Null
        } elseif (($i + 1) % 8 -eq 0) {
            $sb.Append(', ') | Out-Null
        } else {
            $sb.Append(' ') | Out-Null
        }
    }
    
    $result = $sb.ToString().Trim()
    
    if ($AsVariable) {
        Set-Variable -Name $VariableName -Value $result -Scope Global
        Write-Host "📝 Lorem ipsum blob created as `$$VariableName ($WordCount words)" -ForegroundColor Green
        return $VariableName
    } else {
        return $result
    }
}
#endregion

#region 🎯 Profile Definitions
$ProfileVersions = @{
    'Original' = @{
        Path   = "$PSScriptRoot\Microsoft.PowerShell_profile_Dracula_UltraPerformance.ps1"
        Name   = "Ultra-Performance Original"
        Target = "500ms"
        Color  = "Yellow"
    }
    'V3'       = @{
        Path   = "$PSScriptRoot\Microsoft.PowerShell_profile_Dracula_UltraPerformance_V3.ps1"
        Name   = "Ultra-Performance V3"
        Target = "200ms"
        Color  = "Cyan"
    }
    'V4'       = @{
        Path   = "$PSScriptRoot\Microsoft.PowerShell_profile_Dracula_UltraPerformance_V4.ps1"
        Name   = "Ultra-Performance V4"
        Target = "200ms"
        Color  = "Magenta"
    }
}

# Verify profiles exist
$ProfileVersions.Keys | ForEach-Object {
    if (-not (Test-Path $ProfileVersions[$_].Path)) {
        Write-Host "❌ Profile not found: $($ProfileVersions[$_].Path)" -ForegroundColor Red
        $ProfileVersions.Remove($_)
    } else {
        Write-Host "✅ Found: $($ProfileVersions[$_].Name)" -ForegroundColor Green
    }
}
#endregion

#region 🔬 Performance Testing Functions
function Test-ProfileStartup {
    param(
        [string]$ProfilePath,
        [int]$TestIterations = 5,
        [string]$ProfileName = "Unknown"
    )
    
    Write-Host "  🧪 Testing $ProfileName..." -ForegroundColor Gray
    
    $times = @()
    $errors = @()
    
    for ($i = 1; $i -le $TestIterations; $i++) {
        try {
            $start = [System.Diagnostics.Stopwatch]::StartNew()
            
            $result = pwsh -NoProfile -Command @"
try {
    . '$ProfilePath'
    exit 0
} catch {
    Write-Error `$_.Exception.Message
    exit 1
}
"@
            
            $start.Stop()
            $elapsed = $start.Elapsed.TotalMilliseconds
            
            if ($LASTEXITCODE -eq 0) {
                $times += $elapsed
                $elapsedFormatted = "{0:F2}" -f $elapsed
                Write-Host "    Run $i`: ${elapsedFormatted}ms" -ForegroundColor Gray
            } else {
                $errors += "Run $i failed"
                Write-Host "    Run $i`: FAILED" -ForegroundColor Red
            }
        } catch {
            $errors += "Run $i`: $($_.Exception.Message)"
            Write-Host "    Run $i`: ERROR - $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    if ($times.Count -gt 0) {
        $stats = @{
            Average           = ($times | Measure-Object -Average).Average
            Minimum           = ($times | Measure-Object -Minimum).Minimum
            Maximum           = ($times | Measure-Object -Maximum).Maximum
            StandardDeviation = if ($times.Count -gt 1) {
                $avg = ($times | Measure-Object -Average).Average
                [Math]::Sqrt(($times | ForEach-Object { [Math]::Pow($_ - $avg, 2) } | Measure-Object -Sum).Sum / ($times.Count - 1))
            } else {
                0 
            }
            SuccessRate       = ($times.Count / $TestIterations) * 100
            Times             = $times
            Errors            = $errors
        }
        
        return $stats
    } else {
        return @{
            Average           = [double]::PositiveInfinity
            Minimum           = [double]::PositiveInfinity
            Maximum           = [double]::PositiveInfinity
            StandardDeviation = 0
            SuccessRate       = 0
            Times             = @()
            Errors            = $errors
        }
    }
}

function Test-ProfileWithLoremIpsum {
    param(
        [string]$ProfilePath,
        [int]$LoremIpsumWords = 1000,
        [string]$ProfileName = "Unknown"
    )
    
    Write-Host "  📝 Testing $ProfileName with Lorem Ipsum ($LoremIpsumWords words)..." -ForegroundColor Gray
    
    $loremIpsum = New-LoremIpsumBlob -WordCount $LoremIpsumWords
    
    $testScript = @"
try {
    # Load the lorem ipsum data into memory
    `$global:TestLoremIpsum = @'
$loremIpsum
'@
    
    # Load the profile
    . '$ProfilePath'
    
    # Test some operations with the data
    `$wordCount = (`$global:TestLoremIpsum -split '\s+').Count
    `$charCount = `$global:TestLoremIpsum.Length
    
    Write-Host "Lorem Ipsum loaded: `$wordCount words, `$charCount characters"
    exit 0
} catch {
    Write-Error `$_.Exception.Message
    exit 1
}
"@
    
    $start = [System.Diagnostics.Stopwatch]::StartNew()
    $result = pwsh -NoProfile -Command $testScript
    $elapsed = $start.Elapsed.TotalMilliseconds
    
    return @{
        LoadTime = $elapsed
        Success  = ($LASTEXITCODE -eq 0)
        Output   = $result
    }
}
#endregion

#region 📊 Comparison Logic
$results = @{}

switch ($TestMode) {
    'Quick' {
        Write-Host "🏃‍♂️ Quick Test Mode (5 iterations per profile)" -ForegroundColor Yellow
        $testIterations = 5
    }
    'Standard' {
        Write-Host "📊 Standard Test Mode ($Iterations iterations per profile)" -ForegroundColor Yellow
        $testIterations = $Iterations
    }
    'Comprehensive' {
        Write-Host "🏆 Comprehensive Test Mode (20 iterations per profile)" -ForegroundColor Yellow
        $testIterations = 20
    }
    'LoremIpsum' {
        Write-Host "📝 Lorem Ipsum Test Mode" -ForegroundColor Yellow
        $testIterations = 5
    }
}

Write-Host ""

foreach ($version in $ProfileVersions.Keys) {
    Write-Host "🧛‍♂️ Testing $($ProfileVersions[$version].Name)..." -ForegroundColor $ProfileVersions[$version].Color
    
    if ($TestMode -eq 'LoremIpsum' -or $IncludeLoremIpsum) {
        $loremResult = Test-ProfileWithLoremIpsum -ProfilePath $ProfileVersions[$version].Path -LoremIpsumWords $LoremIpsumSize -ProfileName $ProfileVersions[$version].Name
        $profileResult = Test-ProfileStartup -ProfilePath $ProfileVersions[$version].Path -TestIterations $testIterations -ProfileName $ProfileVersions[$version].Name
        
        $results[$version] = @{
            Profile     = $ProfileVersions[$version]
            Performance = $profileResult
            LoremIpsum  = $loremResult
        }
    } else {
        $profileResult = Test-ProfileStartup -ProfilePath $ProfileVersions[$version].Path -TestIterations $testIterations -ProfileName $ProfileVersions[$version].Name
        
        $results[$version] = @{
            Profile     = $ProfileVersions[$version]
            Performance = $profileResult
        }
    }
    
    Write-Host ""
}
#endregion

#region 📈 Results Display
Write-Host "🏆 ULTRA-PERFORMANCE COMPARISON RESULTS" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Green
Write-Host ""

$sortedResults = $results.GetEnumerator() | Sort-Object { $_.Value.Performance.Average }

foreach ($result in $sortedResults) {
    $version = $result.Key
    $data = $result.Value
    $perf = $data.Performance
    $profile = $data.Profile
    
    Write-Host "🧛‍♂️ $($profile.Name)" -ForegroundColor $profile.Color
    Write-Host "  📊 Average: $("{0:F2}" -f $perf.Average)ms" -ForegroundColor White
    Write-Host "  ⚡ Fastest: $("{0:F2}" -f $perf.Minimum)ms" -ForegroundColor Green
    Write-Host "  🐌 Slowest: $("{0:F2}" -f $perf.Maximum)ms" -ForegroundColor Red
    Write-Host "  📏 Std Dev: $("{0:F2}" -f $perf.StandardDeviation)ms" -ForegroundColor Gray
    Write-Host "  ✅ Success: $("{0:F1}" -f $perf.SuccessRate)%" -ForegroundColor $(if ($perf.SuccessRate -eq 100) {
            'Green'
        } else {
            'Yellow'
        })
    
    # Target achievement check
    $targetValue = [double]($profile.Target -replace 'ms', '')
    if ($perf.Average -le $targetValue) {
        Write-Host "  🎯 TARGET ACHIEVED!" -ForegroundColor Green
    } else {
        $over = $perf.Average - $targetValue
        $overFormatted = "{0:F2}" -f $over
        Write-Host "  ⚠️ ${overFormatted}ms over target" -ForegroundColor Yellow
    }
    
    if ($data.LoremIpsum) {
        Write-Host "  📝 Lorem Ipsum: ${($data.LoremIpsum.LoadTime):F2}ms" -ForegroundColor $(if ($data.LoremIpsum.Success) {
                'Cyan'
            } else {
                'Red'
            })
    }
    
    if ($perf.Errors.Count -gt 0) {
        Write-Host "  ❌ Errors:" -ForegroundColor Red
        $perf.Errors | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
    }
    
    Write-Host ""
}

# Performance ranking
Write-Host "🏅 PERFORMANCE RANKING" -ForegroundColor Yellow
Write-Host "=" * 30 -ForegroundColor Yellow
$ranking = 1
foreach ($result in $sortedResults) {
    $medal = switch ($ranking) {
        1 {
            "🥇" 
        }
        2 {
            "🥈" 
        }
        3 {
            "🥉" 
        }
        default {
            "🏃‍♂️" 
        }
    }
    $profileName = $result.Value.Profile.Name
    $avgTime = $result.Value.Performance.Average
    $avgTimeFormatted = "{0:F2}" -f $avgTime
    $profileColor = $result.Value.Profile.Color
    Write-Host "$medal $ranking. $profileName - ${avgTimeFormatted}ms" -ForegroundColor $profileColor
    $ranking++
}
Write-Host ""
#endregion

#region 💾 Report Generation
if ($GenerateReport) {
    Write-Host "📄 Generating HTML Report..." -ForegroundColor Cyan
    
    $htmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>Ultra-Performance Profile Comparison Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background: #1e1e1e; color: #fff; }
        .header { background: linear-gradient(45deg, #ff79c6, #8be9fd); padding: 20px; border-radius: 10px; text-align: center; color: #000; }
        .profile { background: #2d2d2d; margin: 20px 0; padding: 20px; border-radius: 10px; border-left: 5px solid #50fa7b; }
        .metric { display: inline-block; margin: 10px; padding: 10px; background: #3d3d3d; border-radius: 5px; min-width: 120px; text-align: center; }
        .target-achieved { color: #50fa7b; font-weight: bold; }
        .target-missed { color: #ffb86c; }
        .error { color: #ff5555; }
        .ranking { background: #44475a; padding: 15px; border-radius: 10px; margin: 20px 0; }
        .chart { margin: 20px 0; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #6272a4; }
        th { background: #44475a; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🧛‍♂️ Ultra-Performance Profile Comparison</h1>
        <p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
        <p>Test Mode: $TestMode | Iterations: $testIterations</p>
    </div>
"@

    foreach ($result in $sortedResults) {
        $version = $result.Key
        $data = $result.Value
        $perf = $data.Performance
        $profile = $data.Profile
        
        $targetValue = [double]($profile.Target -replace 'ms', '')
        $targetStatus = if ($perf.Average -le $targetValue) {
            "<span class='target-achieved'>🎯 TARGET ACHIEVED!</span>"
        } else {
            $over = $perf.Average - $targetValue
            "<span class='target-missed'>⚠️ ${over:F2}ms over target</span>"
        }
        
        $htmlReport += @"
    <div class="profile">
        <h2>$($profile.Name)</h2>
        <div class="metric">
            <h3>Average</h3>
            <p>${($perf.Average):F2}ms</p>
        </div>
        <div class="metric">
            <h3>Fastest</h3>
            <p>${($perf.Minimum):F2}ms</p>
        </div>
        <div class="metric">
            <h3>Slowest</h3>
            <p>${($perf.Maximum):F2}ms</p>
        </div>
        <div class="metric">
            <h3>Std Dev</h3>
            <p>${($perf.StandardDeviation):F2}ms</p>
        </div>
        <div class="metric">
            <h3>Success Rate</h3>
            <p>${($perf.SuccessRate):F1}%</p>
        </div>
        <p>$targetStatus</p>
"@

        if ($data.LoremIpsum) {
            $htmlReport += @"
        <div class="metric">
            <h3>Lorem Ipsum Test</h3>
            <p>${($data.LoremIpsum.LoadTime):F2}ms</p>
        </div>
"@
        }

        if ($perf.Errors.Count -gt 0) {
            $htmlReport += "<div class='error'><h3>Errors:</h3><ul>"
            $perf.Errors | ForEach-Object { $htmlReport += "<li>$_</li>" }
            $htmlReport += "</ul></div>"
        }
        
        $htmlReport += "</div>"
    }

    # Add ranking table
    $htmlReport += @"
    <div class="ranking">
        <h2>🏅 Performance Ranking</h2>
        <table>
            <tr><th>Rank</th><th>Profile</th><th>Average Time</th><th>Target</th><th>Status</th></tr>
"@

    $ranking = 1
    foreach ($result in $sortedResults) {
        $medal = switch ($ranking) {
            1 {
                "🥇" 
            }
            2 {
                "🥈" 
            }
            3 {
                "🥉" 
            }
            default {
                "🏃‍♂️" 
            }
        }
        
        $targetValue = [double]($result.Value.Profile.Target -replace 'ms', '')
        $status = if ($result.Value.Performance.Average -le $targetValue) {
            "✅" 
        } else {
            "⚠️" 
        }
        
        $htmlReport += @"
            <tr>
                <td>$medal $ranking</td>
                <td>$($result.Value.Profile.Name)</td>
                <td>${($result.Value.Performance.Average):F2}ms</td>
                <td>$($result.Value.Profile.Target)</td>
                <td>$status</td>
            </tr>
"@
        $ranking++
    }

    $htmlReport += @"
        </table>
    </div>
    
    <div class="profile">
        <h2>📝 Test Configuration</h2>
        <p><strong>Test Mode:</strong> $TestMode</p>
        <p><strong>Iterations per Profile:</strong> $testIterations</p>
        <p><strong>Include Lorem Ipsum:</strong> $($IncludeLoremIpsum -or $TestMode -eq 'LoremIpsum')</p>
        <p><strong>Lorem Ipsum Size:</strong> $LoremIpsumSize words</p>
        <p><strong>PowerShell Version:</strong> $($PSVersionTable.PSVersion)</p>
        <p><strong>OS:</strong> $($PSVersionTable.OS)</p>
        <p><strong>Machine:</strong> $env:COMPUTERNAME</p>
    </div>
</body>
</html>
"@

    $htmlReport | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "✅ Report saved to: $OutputPath" -ForegroundColor Green
    
    if ($env:OS -like "*Windows*") {
        Start-Process $OutputPath
    }
}
#endregion

#region 📝 Lorem Ipsum Generation Demo
if ($TestMode -eq 'LoremIpsum' -or $IncludeLoremIpsum) {
    Write-Host "📝 LOREM IPSUM BLOB GENERATION DEMO" -ForegroundColor Magenta
    Write-Host "=" * 50 -ForegroundColor Magenta
    Write-Host ""
    
    # Generate various sizes
    $sizes = @(100, 500, 1000, 2000)
    foreach ($size in $sizes) {
        Write-Host "📝 Generating $size word lorem ipsum blob..." -ForegroundColor Cyan
        $start = [System.Diagnostics.Stopwatch]::StartNew()
        $blob = New-LoremIpsumBlob -WordCount $size
        $elapsed = $start.Elapsed.TotalMilliseconds
        
        $charCount = $blob.Length
        $lines = ($blob -split "`n").Count
        
        Write-Host "  ✅ Generated in ${elapsed:F2}ms" -ForegroundColor Green
        Write-Host "  📊 Stats: $size words, $charCount characters, $lines lines" -ForegroundColor Gray
        Write-Host "  📝 Preview: $($blob.Substring(0, [Math]::Min(100, $blob.Length)))..." -ForegroundColor Yellow
        Write-Host ""
    }
    
    # Create a global variable for testing
    Write-Host "🔧 Creating global lorem ipsum variable for testing..." -ForegroundColor Cyan
    $variableName = New-LoremIpsumBlob -WordCount $LoremIpsumSize -AsVariable -VariableName "GlobalLoremIpsum"
    Write-Host "✅ Use `$$variableName in your tests" -ForegroundColor Green
    Write-Host ""
}
#endregion

Write-Host "🧛‍♂️ Ultra-Performance Comparison Complete!" -ForegroundColor Green
Write-Host "Total profiles tested: $($results.Count)" -ForegroundColor Yellow

if ($GenerateReport) {
    Write-Host "📄 HTML Report: $OutputPath" -ForegroundColor Cyan
}

Write-Host ""
