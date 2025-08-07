#!/usr/bin/env pwsh
# Quick V4Alpha Parsing Test
# Simple test to check V4Alpha parsing functionality

param(
    [switch] $Verbose
)

$ErrorActionPreference = "Continue"

Write-Host "🔍 Quick V4Alpha Parsing Test" -ForegroundColor Cyan
Write-Host ""

# Test 1: Check file structure
Write-Host "📁 Checking V4Alpha file structure..." -ForegroundColor Yellow

$baseDir = $PSScriptRoot
$v4alphaDir = Join-Path $baseDir "PowerShellModules\UnifiedMCPProfile\V4alpha"

if (-not (Test-Path $v4alphaDir)) {
    Write-Host "❌ V4Alpha directory not found: $v4alphaDir" -ForegroundColor Red
    exit 1
}

$requiredPaths = @{
    "Parser"   = Join-Path $v4alphaDir "Runtime\XMLRuntimeParser.ps1"
    "Bridge"   = Join-Path $v4alphaDir "V4AlphaIntegrationBridge.ps1"
    "Schema"   = Join-Path $v4alphaDir "Schemas\ProfileManifest.xsd"
    "Manifest" = Join-Path $v4alphaDir "Manifests\Dracula-v4-Alpha.xml"
}

foreach ($name in $requiredPaths.Keys) {
    $path = $requiredPaths[$name]
    if (Test-Path $path) {
        Write-Host "✅ $name found" -ForegroundColor Green
    } else {
        Write-Host "❌ $name missing: $path" -ForegroundColor Red
    }
}

Write-Host ""

# Test 2: Try to load XMLRuntimeParser
Write-Host "🔧 Testing XMLRuntimeParser loading..." -ForegroundColor Yellow

try {
    $parserPath = Join-Path $v4alphaDir "Runtime\XMLRuntimeParser.ps1"
    if (Test-Path $parserPath) {
        . $parserPath
        Write-Host "✅ XMLRuntimeParser loaded successfully" -ForegroundColor Green
        
        # Test parser instantiation
        $schemasDir = Join-Path $v4alphaDir "Schemas"
        $parser = [XMLRuntimeParser]::new($schemasDir)
        Write-Host "✅ XMLRuntimeParser instantiated" -ForegroundColor Green
        
        if ($Verbose) {
            Write-Host "   Parser metrics:" -ForegroundColor Gray
            $metrics = $parser.GetMetrics()
            $metrics | Format-Table -AutoSize
        }
        
    } else {
        Write-Host "❌ XMLRuntimeParser.ps1 not found" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ XMLRuntimeParser loading failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($Verbose) {
        Write-Host "   Full error: $($_.Exception)" -ForegroundColor Gray
    }
}

Write-Host ""

# Test 3: Try to parse a manifest
Write-Host "📄 Testing manifest parsing..." -ForegroundColor Yellow

try {
    if ($parser) {
        $manifestPath = Join-Path $v4alphaDir "Manifests\Dracula-v4-Alpha.xml"
        if (Test-Path $manifestPath) {
            Write-Host "   Parsing: $manifestPath" -ForegroundColor Gray
            
            $parseStart = Get-Date
            $parsed = $parser.ParseManifest($manifestPath)
            $parseTime = (Get-Date) - $parseStart
            
            Write-Host "✅ Manifest parsed successfully ($($parseTime.TotalMilliseconds)ms)" -ForegroundColor Green
            
            if ($Verbose) {
                Write-Host "   Parsed structure:" -ForegroundColor Gray
                Write-Host "     Has Metadata: $($null -ne $parsed.Metadata)" -ForegroundColor White
                Write-Host "     Has Configuration: $($null -ne $parsed.Configuration)" -ForegroundColor White
                Write-Host "     Has Modules: $($null -ne $parsed.Modules)" -ForegroundColor White
                
                if ($parsed.Metadata) {
                    Write-Host "     Profile Name: $($parsed.Metadata.Name)" -ForegroundColor White
                    Write-Host "     Profile Version: $($parsed.Metadata.Version)" -ForegroundColor White
                }
            }
            
        } else {
            Write-Host "❌ Test manifest not found: $manifestPath" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Parser not available for testing" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Manifest parsing failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($Verbose) {
        Write-Host "   Full error: $($_.Exception)" -ForegroundColor Gray
    }
}

Write-Host ""

# Test 4: Try V4Alpha Integration Bridge
Write-Host "🌉 Testing V4Alpha Integration Bridge..." -ForegroundColor Yellow

try {
    $bridgePath = Join-Path $v4alphaDir "V4AlphaIntegrationBridge.ps1"
    if (Test-Path $bridgePath) {
        . $bridgePath
        Write-Host "✅ Integration Bridge loaded" -ForegroundColor Green
        
        $manifestsDir = Join-Path $v4alphaDir "Manifests"
        $schemasDir = Join-Path $v4alphaDir "Schemas"
        
        # Test bridge instantiation  
        $bridge = [V4AlphaIntegrationBridge]::new($manifestsDir, $schemasDir)
        Write-Host "✅ Integration Bridge instantiated" -ForegroundColor Green
        
        if ($Verbose -and $bridge.BridgeMetrics) {
            Write-Host "   Bridge metrics:" -ForegroundColor Gray
            $bridge.BridgeMetrics | Format-Table -AutoSize
        }
        
    } else {
        Write-Host "❌ Integration Bridge not found" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Integration Bridge failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($Verbose) {
        Write-Host "   Full error: $($_.Exception)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "🎯 Summary:" -ForegroundColor Cyan

if ($parser -and $parsed -and $bridge) {
    Write-Host "✅ V4Alpha system appears to be working correctly!" -ForegroundColor Green
    Write-Host "   • XML parsing engine operational" -ForegroundColor White
    Write-Host "   • Manifest parsing successful" -ForegroundColor White
    Write-Host "   • Integration bridge functional" -ForegroundColor White
    Write-Host ""
    Write-Host "💡 To use V4Alpha effectively:" -ForegroundColor Yellow
    Write-Host "   • Run with -Verbose for detailed information" -ForegroundColor White
    Write-Host "   • Check individual XML manifests for validation" -ForegroundColor White
    Write-Host "   • Use the integration bridge for compatibility" -ForegroundColor White
} else {
    Write-Host "❌ V4Alpha system has issues that need to be resolved" -ForegroundColor Red
    Write-Host "   Check the error messages above for specific problems" -ForegroundColor White
}

Write-Host ""
