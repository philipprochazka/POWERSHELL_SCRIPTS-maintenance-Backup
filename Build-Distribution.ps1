# =============================================
# Build-Distribution.ps1
# Create distribution package for UnifiedPowerShellProfile
# Following PowerShell Development Standards
# =============================================

[CmdletBinding()]
param(
    [string]$SourcePath = "PowerShellModules\UnifiedPowerShellProfile",
    [string]$DistributionPath = "Distribution",
    [string]$Version = "2.0.0",
    [switch]$IncludeDocumentation,
    [switch]$IncludeTests,
    [switch]$CreateZip,
    [switch]$ValidatePackage,
    [switch]$UpdateManifest,
    [switch]$All,
    [switch]$WhatIf
)

if ($All) {
    $IncludeDocumentation = $true
    $IncludeTests = $true
    $CreateZip = $true
    $ValidatePackage = $true
    $UpdateManifest = $true
}

function Initialize-DistributionStructure {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$DistributionPath
    )
    
    Write-Host "📁 Initializing distribution structure..." -ForegroundColor Cyan
    
    $folders = @(
        $DistributionPath,
        (Join-Path $DistributionPath "UnifiedPowerShellProfile"),
        (Join-Path $DistributionPath "UnifiedPowerShellProfile\Public"),
        (Join-Path $DistributionPath "UnifiedPowerShellProfile\Private"),
        (Join-Path $DistributionPath "UnifiedPowerShellProfile\docs"),
        (Join-Path $DistributionPath "UnifiedPowerShellProfile\Tests"),
        (Join-Path $DistributionPath "UnifiedPowerShellProfile\Examples")
    )
    
    foreach ($folder in $folders) {
        if (-not (Test-Path $folder)) {
            if ($PSCmdlet.ShouldProcess($folder, "Create directory")) {
                New-Item -Path $folder -ItemType Directory -Force | Out-Null
                Write-Host "   ✅ Created: $folder" -ForegroundColor Green
            }
        }
    }
}

function Build-ModuleFiles {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$SourcePath,
        [string]$TargetPath
    )
    
    Write-Host "📦 Building module files..." -ForegroundColor Cyan
    
    # Copy core module files
    $coreFiles = @(
        "UnifiedPowerShellProfile.psd1",
        "UnifiedPowerShellProfile.psm1",
        "Install-UnifiedProfile.ps1",
        "Setup-UnifiedProfile.ps1"
    )
    
    foreach ($file in $coreFiles) {
        $sourcePath = Join-Path $SourcePath $file
        $targetPath = Join-Path $TargetPath $file
        
        if (Test-Path $sourcePath) {
            if ($PSCmdlet.ShouldProcess($targetPath, "Copy module file")) {
                Copy-Item -Path $sourcePath -Destination $targetPath -Force
                Write-Host "   ✅ Copied: $file" -ForegroundColor Green
            }
        } else {
            Write-Warning "   ⚠️  Missing source file: $file"
        }
    }
    
    # Copy Public and Private folders
    $directories = @("Public", "Private")
    foreach ($dir in $directories) {
        $sourceDir = Join-Path $SourcePath $dir
        $targetDir = Join-Path $TargetPath $dir
        
        if (Test-Path $sourceDir) {
            if ($PSCmdlet.ShouldProcess($targetDir, "Copy directory")) {
                Copy-Item -Path $sourceDir -Destination $targetDir -Recurse -Force
                $fileCount = (Get-ChildItem -Path $sourceDir -Recurse -File).Count
                Write-Host "   ✅ Copied: $dir ($fileCount files)" -ForegroundColor Green
            }
        }
    }
}

function Update-ModuleManifest {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$ManifestPath,
        [string]$Version
    )
    
    Write-Host "📝 Updating module manifest..." -ForegroundColor Cyan
    
    if (-not (Test-Path $ManifestPath)) {
        Write-Error "Module manifest not found: $ManifestPath"
        return $false
    }
    
    try {
        # Read the current manifest
        $manifest = Import-PowerShellDataFile -Path $ManifestPath
        
        # Get function exports dynamically
        $publicFunctions = @()
        $publicDir = Join-Path (Split-Path $ManifestPath -Parent) "Public"
        if (Test-Path $publicDir) {
            $publicFunctions = Get-ChildItem -Path $publicDir -Filter "*.ps1" | 
                              ForEach-Object { $_.BaseName }
        }
        
        # Update manifest content
        $manifestContent = Get-Content -Path $ManifestPath -Raw
        
        # Update version
        $manifestContent = $manifestContent -replace "ModuleVersion\s*=\s*'[^']*'", "ModuleVersion = '$Version'"
        
        # Update function exports
        if ($publicFunctions.Count -gt 0) {
            $functionList = "'" + ($publicFunctions -join "', '") + "'"
            $manifestContent = $manifestContent -replace "FunctionsToExport\s*=\s*@\([^)]*\)", "FunctionsToExport = @($functionList)"
        }
        
        # Update other metadata
        $manifestContent = $manifestContent -replace "Author\s*=\s*'[^']*'", "Author = 'UnifiedPowerShellProfile Team'"
        $manifestContent = $manifestContent -replace "Description\s*=\s*'[^']*'", "Description = 'Comprehensive PowerShell development environment with multiple profile modes and integrated tooling'"
        
        if ($PSCmdlet.ShouldProcess($ManifestPath, "Update module manifest")) {
            $manifestContent | Set-Content -Path $ManifestPath -Encoding UTF8
            Write-Host "   ✅ Updated manifest version to $Version" -ForegroundColor Green
            Write-Host "   ✅ Updated function exports ($($publicFunctions.Count) functions)" -ForegroundColor Green
        }
        
        return $true
    } catch {
        Write-Error "Failed to update manifest: $($_.Exception.Message)"
        return $false
    }
}

function Build-DistributionDocumentation {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$SourcePath,
        [string]$TargetPath
    )
    
    Write-Host "📚 Building distribution documentation..." -ForegroundColor Cyan
    
    if ($PSCmdlet.ShouldProcess($TargetPath, "Generate documentation")) {
        # Generate fresh documentation
        $docScript = Join-Path $PSScriptRoot "Build-ModuleDocumentation.ps1"
        if (Test-Path $docScript) {
            & $docScript -ModulePath $SourcePath -OutputPath (Join-Path $TargetPath "docs") -All
        }
        
        # Copy additional documentation files
        $docFiles = @("README.md", "LICENSE", "CHANGELOG.md", "CONTRIBUTING.md")
        foreach ($file in $docFiles) {
            $sourceFile = Join-Path $PSScriptRoot $file
            $targetFile = Join-Path $TargetPath $file
            
            if (Test-Path $sourceFile) {
                Copy-Item -Path $sourceFile -Destination $targetFile -Force
                Write-Host "   ✅ Copied: $file" -ForegroundColor Green
            }
        }
    }
}

function Build-DistributionTests {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$SourcePath,
        [string]$TargetPath
    )
    
    Write-Host "🧪 Building test suite..." -ForegroundColor Cyan
    
    $sourceTestsPath = Join-Path $PSScriptRoot "Tests"
    $targetTestsPath = Join-Path $TargetPath "Tests"
    
    if (Test-Path $sourceTestsPath) {
        if ($PSCmdlet.ShouldProcess($targetTestsPath, "Copy test suite")) {
            Copy-Item -Path $sourceTestsPath -Destination $targetTestsPath -Recurse -Force
            $testCount = (Get-ChildItem -Path $sourceTestsPath -Filter "*.Tests.ps1" -Recurse).Count
            Write-Host "   ✅ Copied test suite ($testCount test files)" -ForegroundColor Green
        }
    } else {
        Write-Warning "   ⚠️  Source tests directory not found: $sourceTestsPath"
    }
}

function Test-DistributionPackage {
    [CmdletBinding()]
    param(
        [string]$PackagePath
    )
    
    Write-Host "🔍 Validating distribution package..." -ForegroundColor Cyan
    
    $isValid = $true
    
    # Test 1: Module manifest validation
    $manifestPath = Join-Path $PackagePath "UnifiedPowerShellProfile.psd1"
    try {
        $manifest = Test-ModuleManifest -Path $manifestPath -ErrorAction Stop
        Write-Host "   ✅ Module manifest is valid" -ForegroundColor Green
        Write-Host "      Version: $($manifest.Version)" -ForegroundColor Gray
        Write-Host "      Functions: $($manifest.ExportedFunctions.Count)" -ForegroundColor Gray
    } catch {
        Write-Host "   ❌ Module manifest validation failed: $($_.Exception.Message)" -ForegroundColor Red
        $isValid = $false
    }
    
    # Test 2: Module import test
    try {
        Import-Module $manifestPath -Force -ErrorAction Stop
        $module = Get-Module UnifiedPowerShellProfile
        Write-Host "   ✅ Module imports successfully" -ForegroundColor Green
        Write-Host "      Exported functions: $($module.ExportedFunctions.Count)" -ForegroundColor Gray
        Remove-Module UnifiedPowerShellProfile -Force
    } catch {
        Write-Host "   ❌ Module import failed: $($_.Exception.Message)" -ForegroundColor Red
        $isValid = $false
    }
    
    # Test 3: Required files check
    $requiredFiles = @(
        "UnifiedPowerShellProfile.psd1",
        "UnifiedPowerShellProfile.psm1",
        "README.md"
    )
    
    foreach ($file in $requiredFiles) {
        $filePath = Join-Path $PackagePath $file
        if (Test-Path $filePath) {
            Write-Host "   ✅ Required file present: $file" -ForegroundColor Green
        } else {
            Write-Host "   ❌ Missing required file: $file" -ForegroundColor Red
            $isValid = $false
        }
    }
    
    # Test 4: PowerShell syntax validation
    $psFiles = Get-ChildItem -Path $PackagePath -Filter "*.ps1" -Recurse
    $syntaxErrors = 0
    
    foreach ($file in $psFiles) {
        $parseErrors = $null
        [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$null, [ref]$parseErrors)
        if ($parseErrors) {
            Write-Host "   ❌ Syntax errors in $($file.Name): $($parseErrors.Count)" -ForegroundColor Red
            $syntaxErrors += $parseErrors.Count
            $isValid = $false
        }
    }
    
    if ($syntaxErrors -eq 0) {
        Write-Host "   ✅ All PowerShell files have valid syntax" -ForegroundColor Green
    }
    
    return $isValid
}

function New-DistributionZip {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$SourcePath,
        [string]$OutputPath,
        [string]$Version
    )
    
    Write-Host "📦 Creating distribution ZIP package..." -ForegroundColor Cyan
    
    $zipName = "UnifiedPowerShellProfile-v$Version.zip"
    $zipPath = Join-Path $OutputPath $zipName
    
    if ($PSCmdlet.ShouldProcess($zipPath, "Create ZIP package")) {
        try {
            # Remove existing zip if it exists
            if (Test-Path $zipPath) {
                Remove-Item $zipPath -Force
            }
            
            # Create the ZIP package
            Add-Type -AssemblyName "System.IO.Compression.FileSystem"
            [System.IO.Compression.ZipFile]::CreateFromDirectory($SourcePath, $zipPath)
            
            $zipSize = [math]::Round((Get-Item $zipPath).Length / 1KB, 2)
            Write-Host "   ✅ Created ZIP package: $zipName ($zipSize KB)" -ForegroundColor Green
            
            return $zipPath
        } catch {
            Write-Error "Failed to create ZIP package: $($_.Exception.Message)"
            return $null
        }
    }
}

# Main execution
if ($MyInvocation.InvocationName -ne '.') {
    Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║            📦 DISTRIBUTION BUILDER 📦                       ║
║         Creating UnifiedPowerShellProfile Package           ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

    Write-Host ""
    Write-Host "📁 Source: $SourcePath" -ForegroundColor Gray
    Write-Host "📂 Target: $DistributionPath" -ForegroundColor Gray
    Write-Host "🏷️  Version: $Version" -ForegroundColor Gray
    Write-Host ""

    try {
        $moduleDistPath = Join-Path $DistributionPath "UnifiedPowerShellProfile"
        
        # Step 1: Initialize distribution structure
        Initialize-DistributionStructure -DistributionPath $DistributionPath
        Write-Host ""
        
        # Step 2: Build module files
        Build-ModuleFiles -SourcePath $SourcePath -TargetPath $moduleDistPath
        Write-Host ""
        
        # Step 3: Update module manifest
        if ($UpdateManifest) {
            $manifestPath = Join-Path $moduleDistPath "UnifiedPowerShellProfile.psd1"
            Update-ModuleManifest -ManifestPath $manifestPath -Version $Version
            Write-Host ""
        }
        
        # Step 4: Include documentation
        if ($IncludeDocumentation) {
            Build-DistributionDocumentation -SourcePath $SourcePath -TargetPath $moduleDistPath
            Write-Host ""
        }
        
        # Step 5: Include tests
        if ($IncludeTests) {
            Build-DistributionTests -SourcePath $SourcePath -TargetPath $moduleDistPath
            Write-Host ""
        }
        
        # Step 6: Validate package
        if ($ValidatePackage) {
            $isValid = Test-DistributionPackage -PackagePath $moduleDistPath
            Write-Host ""
            
            if (-not $isValid) {
                Write-Warning "Package validation failed. Please review the errors above."
            }
        }
        
        # Step 7: Create ZIP package
        if ($CreateZip) {
            $zipPath = New-DistributionZip -SourcePath $moduleDistPath -OutputPath $DistributionPath -Version $Version
            Write-Host ""
        }
        
        Write-Host "🎉 Distribution build completed!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📋 Distribution Summary:" -ForegroundColor Cyan
        Write-Host "   Package Location: $moduleDistPath" -ForegroundColor White
        Write-Host "   Version: $Version" -ForegroundColor White
        if ($CreateZip -and $zipPath) {
            Write-Host "   ZIP Package: $zipPath" -ForegroundColor White
        }
        Write-Host ""
        Write-Host "📦 Installation Instructions:" -ForegroundColor Cyan
        Write-Host "   1. Copy the UnifiedPowerShellProfile folder to your PowerShell modules directory" -ForegroundColor White
        Write-Host "   2. Run: Import-Module UnifiedPowerShellProfile" -ForegroundColor White
        Write-Host "   3. Run: .\Start-UnifiedProfile.ps1 -Quick" -ForegroundColor White

    } catch {
        Write-Error "Distribution build failed: $($_.Exception.Message)"
        throw
    }
}
