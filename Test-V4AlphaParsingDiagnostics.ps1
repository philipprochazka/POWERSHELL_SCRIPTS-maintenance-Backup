#!/usr/bin/env pwsh
# Enhanced V4Alpha Parsing Diagnostics
# Focuses on identifying and resolving parsing failures with detailed error reporting

using namespace System.Xml
using namespace System.Xml.Schema
using namespace System.Collections.Generic

param(
    [Parameter()]
    [ValidateSet("All", "Schema", "Parser", "Manifest", "Performance")]
    [string] $TestFocus = "All",
    
    [Parameter()]
    [switch] $VerboseOutput,
    
    [Parameter()]
    [switch] $GenerateReport,
    
    [Parameter()]
    [string] $OutputPath = ".\V4Alpha-Parsing-Diagnostics.html"
)

# Enhanced error handling and logging
$ErrorActionPreference = "Stop"
$Global:DiagnosticsResults = @()

function Write-DiagnosticMessage {
    param(
        [string] $Message,
        [ValidateSet("Info", "Warning", "Error", "Success")]
        [string] $Level = "Info",
        [object] $Data = $null
    )
    
    $timestamp = Get-Date -Format "HH:mm:ss.fff"
    $emoji = switch ($Level) {
        "Info" {
            "ℹ️" 
        }
        "Warning" {
            "⚠️" 
        }
        "Error" {
            "❌" 
        }
        "Success" {
            "✅" 
        }
    }
    
    $color = switch ($Level) {
        "Info" {
            "Cyan" 
        }
        "Warning" {
            "Yellow" 
        }
        "Error" {
            "Red" 
        }
        "Success" {
            "Green" 
        }
    }
    
    Write-Host "[$timestamp] $emoji $Message" -ForegroundColor $color
    
    $Global:DiagnosticsResults += [PSCustomObject]@{
        Timestamp = Get-Date
        Level     = $Level
        Message   = $Message
        Data      = $Data
    }
    
    if ($VerboseOutput -and $Data) {
        Write-Host "   Data: $($Data | ConvertTo-Json -Depth 2 -Compress)" -ForegroundColor Gray
    }
}

function Test-V4AlphaEnvironment {
    Write-DiagnosticMessage "Testing V4Alpha environment setup" -Level "Info"
    
    $v4alphaPath = Join-Path $PSScriptRoot "PowerShellModules\UnifiedMCPProfile\V4alpha"
    if (-not (Test-Path $v4alphaPath)) {
        Write-DiagnosticMessage "V4Alpha directory not found at: $v4alphaPath" -Level "Error"
        return $false
    }
    
    $requiredPaths = @{
        "Schemas"   = Join-Path $v4alphaPath "Schemas"
        "Runtime"   = Join-Path $v4alphaPath "Runtime"
        "Manifests" = Join-Path $v4alphaPath "Manifests"
    }
    
    $pathResults = @{}
    foreach ($pathName in $requiredPaths.Keys) {
        $path = $requiredPaths[$pathName]
        $exists = Test-Path $path
        $pathResults[$pathName] = $exists
        
        if ($exists) {
            Write-DiagnosticMessage "Found $pathName directory" -Level "Success"
        } else {
            Write-DiagnosticMessage "Missing $pathName directory: $path" -Level "Error"
        }
    }
    
    Write-DiagnosticMessage "Environment check complete" -Level "Info" -Data $pathResults
    return ($pathResults.Values | Where-Object { -not $_ }).Count -eq 0
}

function Test-XSDSchemaValidation {
    Write-DiagnosticMessage "Testing XSD schema validation" -Level "Info"
    
    $schemasPath = Join-Path $PSScriptRoot "PowerShellModules\UnifiedMCPProfile\V4alpha\Schemas"
    $schemaFiles = Get-ChildItem -Path $schemasPath -Filter "*.xsd" -ErrorAction SilentlyContinue
    
    if ($schemaFiles.Count -eq 0) {
        Write-DiagnosticMessage "No XSD schema files found in: $schemasPath" -Level "Error"
        return $false
    }
    
    $schemaResults = @{}
    foreach ($schemaFile in $schemaFiles) {
        try {
            Write-DiagnosticMessage "Validating schema: $($schemaFile.Name)" -Level "Info"
            
            # Test basic XML loading
            $xmlDoc = New-Object System.Xml.XmlDocument
            $xmlDoc.Load($schemaFile.FullName)
            
            # Test schema compilation
            $schemaSet = New-Object System.Xml.Schema.XmlSchemaSet
            $schema = $schemaSet.Add($null, $schemaFile.FullName)
            $schemaSet.Compile()
            
            $schemaResults[$schemaFile.Name] = @{
                Valid    = $true
                Elements = $schema.Elements.Count
                Types    = $schema.SchemaTypes.Count
                Error    = $null
            }
            
            Write-DiagnosticMessage "Schema validation successful: $($schemaFile.Name)" -Level "Success"
            
        } catch {
            $schemaResults[$schemaFile.Name] = @{
                Valid    = $false
                Elements = 0
                Types    = 0
                Error    = $_.Exception.Message
            }
            
            Write-DiagnosticMessage "Schema validation failed: $($schemaFile.Name) - $($_.Exception.Message)" -Level "Error"
        }
    }
    
    Write-DiagnosticMessage "Schema validation complete" -Level "Info" -Data $schemaResults
    return ($schemaResults.Values | Where-Object { -not $_.Valid }).Count -eq 0
}

function Test-XMLRuntimeParserImplementation {
    Write-DiagnosticMessage "Testing XMLRuntimeParser implementation" -Level "Info"
    
    $runtimePath = Join-Path $PSScriptRoot "PowerShellModules\UnifiedMCPProfile\V4alpha\Runtime\XMLRuntimeParser.ps1"
    
    if (-not (Test-Path $runtimePath)) {
        Write-DiagnosticMessage "XMLRuntimeParser.ps1 not found at: $runtimePath" -Level "Error"
        return $false
    }
    
    try {
        Write-DiagnosticMessage "Loading XMLRuntimeParser class" -Level "Info"
        
        # Dot-source the parser
        . $runtimePath
        
        # Test class instantiation
        $schemasPath = Join-Path $PSScriptRoot "PowerShellModules\UnifiedMCPProfile\V4alpha\Schemas"
        $parser = New-Object XMLRuntimeParser($schemasPath)
        
        if ($parser) {
            Write-DiagnosticMessage "XMLRuntimeParser instantiated successfully" -Level "Success"
            
            # Test parser metrics
            $metrics = $parser.Metrics
            if ($metrics) {
                Write-DiagnosticMessage "Parser metrics available" -Level "Success" -Data $metrics
            }
            
            return $true
        } else {
            Write-DiagnosticMessage "Failed to instantiate XMLRuntimeParser" -Level "Error"
            return $false
        }
        
    } catch {
        Write-DiagnosticMessage "XMLRuntimeParser loading failed: $($_.Exception.Message)" -Level "Error"
        return $false
    }
}

function Test-ManifestParsing {
    Write-DiagnosticMessage "Testing XML manifest parsing" -Level "Info"
    
    try {
        # Load parser
        $runtimePath = Join-Path $PSScriptRoot "PowerShellModules\UnifiedMCPProfile\V4alpha\Runtime\XMLRuntimeParser.ps1"
        . $runtimePath
        
        $schemasPath = Join-Path $PSScriptRoot "PowerShellModules\UnifiedMCPProfile\V4alpha\Schemas"
        $manifestsPath = Join-Path $PSScriptRoot "PowerShellModules\UnifiedMCPProfile\V4alpha\Manifests"
        
        $parser = New-Object XMLRuntimeParser($schemasPath)
        $manifestFiles = Get-ChildItem -Path $manifestsPath -Filter "*.xml" -ErrorAction SilentlyContinue
        
        if ($manifestFiles.Count -eq 0) {
            Write-DiagnosticMessage "No XML manifest files found in: $manifestsPath" -Level "Error"
            return $false
        }
        
        $parseResults = @{}
        foreach ($manifestFile in $manifestFiles) {
            try {
                Write-DiagnosticMessage "Parsing manifest: $($manifestFile.Name)" -Level "Info"
                
                $parseStart = Get-Date
                $parsed = $parser.ParseManifest($manifestFile.FullName)
                $parseTime = (Get-Date) - $parseStart
                
                $parseResults[$manifestFile.Name] = @{
                    Success          = $true
                    ParseTime        = $parseTime.TotalMilliseconds
                    HasMetadata      = $null -ne $parsed.Metadata
                    HasConfiguration = $null -ne $parsed.Configuration
                    HasModules       = $null -ne $parsed.Modules
                    Error            = $null
                    Data             = $parsed
                }
                
                Write-DiagnosticMessage "Manifest parsed successfully: $($manifestFile.Name) ($('{0:F2}' -f $parseTime.TotalMilliseconds)ms)" -Level "Success"
                
            } catch {
                $parseResults[$manifestFile.Name] = @{
                    Success          = $false
                    ParseTime        = 0
                    HasMetadata      = $false
                    HasConfiguration = $false
                    HasModules       = $false
                    Error            = $_.Exception.Message
                    Data             = $null
                }
                
                Write-DiagnosticMessage "Manifest parsing failed: $($manifestFile.Name) - $($_.Exception.Message)" -Level "Error"
            }
        }
        
        Write-DiagnosticMessage "Manifest parsing complete" -Level "Info" -Data $parseResults
        return ($parseResults.Values | Where-Object { -not $_.Success }).Count -eq 0
        
    } catch {
        Write-DiagnosticMessage "Manifest parsing test failed: $($_.Exception.Message)" -Level "Error"
        return $false
    }
}

function Test-PerformanceBenchmarks {
    Write-DiagnosticMessage "Running performance benchmarks" -Level "Info"
    
    try {
        # Load parser
        $runtimePath = Join-Path $PSScriptRoot "PowerShellModules\UnifiedMCPProfile\V4alpha\Runtime\XMLRuntimeParser.ps1"
        . $runtimePath
        
        $schemasPath = Join-Path $PSScriptRoot "PowerShellModules\UnifiedMCPProfile\V4alpha\Schemas"
        $manifestPath = Join-Path $PSScriptRoot "PowerShellModules\UnifiedMCPProfile\V4alpha\Manifests\Dracula-v4-Alpha.xml"
        
        if (-not (Test-Path $manifestPath)) {
            Write-DiagnosticMessage "Test manifest not found: $manifestPath" -Level "Error"
            return $false
        }
        
        $parser = New-Object XMLRuntimeParser($schemasPath)
        $iterations = 10
        $times = @()
        
        Write-DiagnosticMessage "Running $iterations parse iterations for performance testing" -Level "Info"
        
        for ($i = 1; $i -le $iterations; $i++) {
            $parseStart = Get-Date
            $parsed = $parser.ParseManifest($manifestPath, $false) # Disable caching for pure parse time
            $parseTime = (Get-Date) - $parseStart
            $times += $parseTime.TotalMilliseconds
            
            Write-DiagnosticMessage "Iteration $i`: $('{0:F2}' -f $parseTime.TotalMilliseconds)ms" -Level "Info"
        }
        
        $avgTime = ($times | Measure-Object -Average).Average
        $minTime = ($times | Measure-Object -Minimum).Minimum
        $maxTime = ($times | Measure-Object -Maximum).Maximum
        
        $perfResults = @{
            Iterations  = $iterations
            AverageTime = $avgTime
            MinTime     = $minTime
            MaxTime     = $maxTime
            AllTimes    = $times
        }
        
        Write-DiagnosticMessage "Performance benchmark complete - Avg: $('{0:F2}' -f $avgTime)ms, Min: $('{0:F2}' -f $minTime)ms, Max: $('{0:F2}' -f $maxTime)ms" -Level "Success" -Data $perfResults
        
        return $true
        
    } catch {
        Write-DiagnosticMessage "Performance benchmark failed: $($_.Exception.Message)" -Level "Error"
        return $false
    }
}

function New-DiagnosticsReport {
    if (-not $GenerateReport) {
        return
    }
    
    Write-DiagnosticMessage "Generating diagnostics report" -Level "Info"
    
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>V4Alpha Parsing Diagnostics Report</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2563eb; border-bottom: 3px solid #2563eb; padding-bottom: 10px; }
        h2 { color: #1f2937; margin-top: 30px; }
        .success { color: #10b981; font-weight: bold; }
        .error { color: #ef4444; font-weight: bold; }
        .warning { color: #f59e0b; font-weight: bold; }
        .info { color: #6b7280; }
        .log-entry { margin: 5px 0; padding: 8px; border-left: 4px solid #e5e7eb; background: #f9fafb; }
        .log-entry.success { border-left-color: #10b981; background: #ecfdf5; }
        .log-entry.error { border-left-color: #ef4444; background: #fef2f2; }
        .log-entry.warning { border-left-color: #f59e0b; background: #fffbeb; }
        pre { background: #f3f4f6; padding: 15px; border-radius: 6px; overflow-x: auto; }
        .timestamp { font-size: 0.9em; color: #6b7280; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 V4Alpha Parsing Diagnostics Report</h1>
        <p><strong>Generated:</strong> $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
        <p><strong>Test Focus:</strong> $TestFocus</p>
        
        <h2>📊 Summary</h2>
        <p><strong>Total Entries:</strong> $($Global:DiagnosticsResults.Count)</p>
        <p><strong>Success:</strong> <span class="success">$(($Global:DiagnosticsResults | Where-Object Level -eq 'Success').Count)</span></p>
        <p><strong>Errors:</strong> <span class="error">$(($Global:DiagnosticsResults | Where-Object Level -eq 'Error').Count)</span></p>
        <p><strong>Warnings:</strong> <span class="warning">$(($Global:DiagnosticsResults | Where-Object Level -eq 'Warning').Count)</span></p>
        
        <h2>📝 Detailed Log</h2>
"@
    
    foreach ($entry in $Global:DiagnosticsResults) {
        $cssClass = $entry.Level.ToLower()
        $html += @"
        <div class="log-entry $cssClass">
            <div class="timestamp">$($entry.Timestamp.ToString('HH:mm:ss.fff'))</div>
            <div><strong>[$($entry.Level)]</strong> $($entry.Message)</div>
"@
        if ($entry.Data) {
            $dataJson = $entry.Data | ConvertTo-Json -Depth 3
            $html += "<pre>$dataJson</pre>"
        }
        $html += "</div>`n"
    }
    
    $html += @"
    </div>
</body>
</html>
"@
    
    try {
        $html | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-DiagnosticMessage "Report saved to: $OutputPath" -Level "Success"
    } catch {
        Write-DiagnosticMessage "Failed to save report: $($_.Exception.Message)" -Level "Error"
    }
}

# Main execution
Write-Host "🔍 V4Alpha Parsing Diagnostics Starting..." -ForegroundColor Cyan
Write-Host "   Test Focus: $TestFocus" -ForegroundColor White
Write-Host "   Verbose: $VerboseOutput" -ForegroundColor White
Write-Host "   Generate Report: $GenerateReport" -ForegroundColor White
Write-Host ""

$allTestsPassed = $true

# Run environment check first
if ($TestFocus -eq "All" -or $TestFocus -eq "Schema") {
    $allTestsPassed = (Test-V4AlphaEnvironment) -and $allTestsPassed
}

# Schema validation
if ($TestFocus -eq "All" -or $TestFocus -eq "Schema") {
    $allTestsPassed = (Test-XSDSchemaValidation) -and $allTestsPassed
}

# Parser implementation
if ($TestFocus -eq "All" -or $TestFocus -eq "Parser") {
    $allTestsPassed = (Test-XMLRuntimeParserImplementation) -and $allTestsPassed
}

# Manifest parsing
if ($TestFocus -eq "All" -or $TestFocus -eq "Manifest") {
    $allTestsPassed = (Test-ManifestParsing) -and $allTestsPassed
}

# Performance benchmarks
if ($TestFocus -eq "All" -or $TestFocus -eq "Performance") {
    $allTestsPassed = (Test-PerformanceBenchmarks) -and $allTestsPassed
}

# Generate report if requested
New-DiagnosticsReport

# Final summary
Write-Host ""
if ($allTestsPassed) {
    Write-Host "✅ All diagnostics tests PASSED! V4Alpha parsing system is working correctly." -ForegroundColor Green
} else {
    Write-Host "❌ Some diagnostics tests FAILED. Check the output above for specific issues." -ForegroundColor Red
}

Write-Host ""
Write-Host "💡 Next steps:" -ForegroundColor Yellow
Write-Host "   - If tests failed, review the error messages above" -ForegroundColor White
Write-Host "   - Use -VerboseOutput for more detailed information" -ForegroundColor White
Write-Host "   - Use -GenerateReport to create an HTML report" -ForegroundColor White
Write-Host "   - Focus on specific areas with -TestFocus parameter" -ForegroundColor White

return $allTestsPassed
