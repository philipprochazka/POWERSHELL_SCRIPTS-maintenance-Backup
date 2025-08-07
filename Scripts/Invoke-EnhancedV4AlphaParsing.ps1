#!/usr/bin/env pwsh
# Enhanced V4Alpha Parsing with Advanced Error Recovery
# Leverages the V4Alpha XML Schema Architecture for robust parsing

param(
    [Parameter(Mandatory)]
    [string] $ManifestPath,
    
    [Parameter()]
    [switch] $EnableAdvancedRecovery,
    
    [Parameter()]
    [switch] $ValidateSchema,
    
    [Parameter()]
    [switch] $ShowMetrics
)

# Import V4Alpha components
$v4alphaDir = Join-Path $PSScriptRoot "PowerShellModules\UnifiedMCPProfile\V4alpha"
. (Join-Path $v4alphaDir "Runtime\XMLRuntimeParser.ps1")
. (Join-Path $v4alphaDir "V4AlphaIntegrationBridge.ps1")

function Invoke-EnhancedV4AlphaParsing {
    param(
        [string] $ManifestPath,
        [bool] $AdvancedRecovery = $false,
        [bool] $SchemaValidation = $true,
        [bool] $ShowMetrics = $false
    )
    
    Write-Host "🚀 Enhanced V4Alpha Parsing" -ForegroundColor Cyan
    Write-Host "   Manifest: $ManifestPath" -ForegroundColor White
    Write-Host "   Advanced Recovery: $AdvancedRecovery" -ForegroundColor White
    Write-Host "   Schema Validation: $SchemaValidation" -ForegroundColor White
    Write-Host ""
    
    try {
        # Initialize V4Alpha parser
        $schemasDir = Join-Path $v4alphaDir "Schemas"
        $parser = [XMLRuntimeParser]::new($schemasDir)
        $parser.ValidationEnabled = $SchemaValidation
        
        Write-Host "✅ V4Alpha Parser initialized" -ForegroundColor Green
        
        # Enhanced parsing with recovery
        $parseResult = $null
        $retryCount = 0
        $maxRetries = if ($AdvancedRecovery) {
            3 
        } else {
            1 
        }
        
        do {
            try {
                Write-Host "🔄 Parse attempt $($retryCount + 1)..." -ForegroundColor Yellow
                
                $parseStart = Get-Date
                $parseResult = $parser.ParseManifest($ManifestPath, $true)
                $parseTime = (Get-Date) - $parseStart
                
                Write-Host "✅ Parsing successful! ($($parseTime.TotalMilliseconds)ms)" -ForegroundColor Green
                break
                
            } catch {
                $retryCount++
                Write-Host "❌ Parse attempt $retryCount failed: $($_.Exception.Message)" -ForegroundColor Red
                
                if ($AdvancedRecovery -and $retryCount -lt $maxRetries) {
                    Write-Host "🔧 Attempting recovery..." -ForegroundColor Yellow
                    
                    # Recovery strategy 1: Disable schema validation
                    if ($retryCount -eq 1 -and $SchemaValidation) {
                        Write-Host "   • Disabling schema validation" -ForegroundColor Gray
                        $parser.ValidationEnabled = $false
                        continue
                    }
                    
                    # Recovery strategy 2: Clear cache and retry
                    if ($retryCount -eq 2) {
                        Write-Host "   • Clearing parser cache" -ForegroundColor Gray
                        $parser.ClearCache()
                        continue
                    }
                }
                
                if ($retryCount -ge $maxRetries) {
                    throw "All parsing attempts failed. Last error: $($_.Exception.Message)"
                }
            }
        } while ($retryCount -lt $maxRetries)
        
        # Validate parsing results
        if ($parseResult) {
            Write-Host ""
            Write-Host "📊 Parsing Results:" -ForegroundColor Cyan
            
            $validation = @{
                HasMetadata      = $null -ne $parseResult.Metadata
                HasConfiguration = $null -ne $parseResult.Configuration  
                HasModules       = $null -ne $parseResult.Modules
                ProfileName      = if ($parseResult.Metadata) {
                    $parseResult.Metadata.Name 
                } else {
                    "Unknown" 
                }
                ProfileVersion   = if ($parseResult.Metadata) {
                    $parseResult.Metadata.Version 
                } else {
                    "Unknown" 
                }
                ModuleCount      = if ($parseResult.Modules -and $parseResult.Modules.Required) { 
                    if ($parseResult.Modules.Required.Module -is [array]) {
                        $parseResult.Modules.Required.Module.Count
                    } else {
                        1
                    }
                } else {
                    0 
                }
            }
            
            foreach ($key in $validation.Keys) {
                $value = $validation[$key]
                $color = if ($value -eq $true -or ($value -is [string] -and $value -ne "Unknown") -or ($value -is [int] -and $value -gt 0)) {
                    "Green"
                } else {
                    "Yellow"
                }
                Write-Host "   $key`: $value" -ForegroundColor $color
            }
            
            # Show performance metrics
            if ($ShowMetrics) {
                Write-Host ""
                Write-Host "⚡ Performance Metrics:" -ForegroundColor Cyan
                $metrics = $parser.GetMetrics()
                
                Write-Host "   Parse Time: $($metrics.ParseTime)ms" -ForegroundColor White
                Write-Host "   Validation Time: $($metrics.ValidationTime)ms" -ForegroundColor White
                Write-Host "   Cache Hits: $($metrics.CacheHits)" -ForegroundColor White
                Write-Host "   Cache Misses: $($metrics.CacheMisses)" -ForegroundColor White
                Write-Host "   Total Parses: $($metrics.TotalParses)" -ForegroundColor White
                Write-Host "   Memory Usage: $('{0:F2}' -f $metrics.MemoryUsage)MB" -ForegroundColor White
                Write-Host "   Error Count: $($metrics.ErrorCount)" -ForegroundColor White
            }
            
            return $parseResult
        }
        
    } catch {
        Write-Host ""
        Write-Host "💥 Fatal parsing error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host ""
        Write-Host "💡 Recovery suggestions:" -ForegroundColor Yellow
        Write-Host "   • Try with -EnableAdvancedRecovery" -ForegroundColor White
        Write-Host "   • Validate XML syntax manually" -ForegroundColor White
        Write-Host "   • Check schema compatibility" -ForegroundColor White
        Write-Host "   • Review manifest structure" -ForegroundColor White
        
        throw
    }
}

# Main execution
try {
    $result = Invoke-EnhancedV4AlphaParsing -ManifestPath $ManifestPath -AdvancedRecovery $EnableAdvancedRecovery.IsPresent -SchemaValidation $ValidateSchema.IsPresent -ShowMetrics $ShowMetrics.IsPresent
    
    Write-Host ""
    Write-Host "🎉 V4Alpha parsing completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 Next steps:" -ForegroundColor Yellow
    Write-Host "   • Use the parsed result for profile loading" -ForegroundColor White
    Write-Host "   • Leverage the V4Alpha Integration Bridge" -ForegroundColor White
    Write-Host "   • Enable lazy loading for better performance" -ForegroundColor White
    
    return $result
    
} catch {
    Write-Host ""
    Write-Host "❌ Enhanced V4Alpha parsing failed." -ForegroundColor Red
    Write-Host "   Consider using legacy parsing as fallback." -ForegroundColor Yellow
    exit 1
}
