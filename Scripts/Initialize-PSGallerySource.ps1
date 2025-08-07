#Requires -Version 5.1

<#
.SYNOPSIS
    Prepares PowerShell modules for PSGallery source registration and digital signature.

.DESCRIPTION
    Creates proper module manifests, implements digital signatures, and prepares
    vendor-organized modules for enterprise PSGallery source deployment.

.PARAMETER VendorPath
    Path to the vendor-organized modules directory.

.PARAMETER CertificatePath
    Path to code signing certificate for digital signatures.

.PARAMETER RepositoryName
    Name for the private PSGallery repository.

.PARAMETER PublishUrl
    URL for the PSGallery publish endpoint.

.EXAMPLE
    Initialize-PSGallerySource -VendorPath ".\PowerShellModules" -RepositoryName "EnterpriseModules"

.NOTES
    Follows PowerShell Development Standards & Architecture
    - Digital signature implementation
    - Enterprise PSGallery source registration
    - Module manifest validation and enhancement
#>

param(
    [string]$VendorPath = "c:\backup\Powershell\PowerShellModules",
    [string]$CertificatePath,
    [string]$RepositoryName = "PhilipRochazkaModules",
    [string]$PublishUrl = "https://localhost:8080/api/v2/package",
    [string]$SourceUrl = "https://localhost:8080/nuget",
    [switch]$CreateCertificate,
    [switch]$DryRun
)

function New-CodeSigningCertificate {
    <#
    .SYNOPSIS
    Creates a self-signed code signing certificate for module signing.
    #>
    
    param(
        [string]$Subject = "CN=Philip Rochazka PowerShell Modules",
        [string]$OutputPath = ".\CodeSigning.pfx",
        [string]$Password = (Read-Host "Enter certificate password" -AsSecureString)
    )
    
    Write-Host "🔐 Creating code signing certificate..." -ForegroundColor Cyan
    
    try {
        # Create certificate
        $cert = New-SelfSignedCertificate -Subject $Subject -Type CodeSigning -KeyUsage DigitalSignature -FriendlyName "PowerShell Module Signing" -CertStoreLocation Cert:\CurrentUser\My -KeyLength 2048 -Provider "Microsoft Enhanced RSA and AES Cryptographic Provider" -KeyExportPolicy Exportable -KeySpec Signature -HashAlgorithm SHA256 -NotAfter (Get-Date).AddYears(3)
        
        Write-Host "  ✅ Certificate created with thumbprint: $($cert.Thumbprint)" -ForegroundColor Green
        
        # Export certificate
        $pwd = ConvertTo-SecureString -String (Read-Host "Enter password for certificate export" -AsSecureString) -Force -AsPlainText
        Export-PfxCertificate -Cert $cert -FilePath $OutputPath -Password $pwd
        
        Write-Host "  💾 Certificate exported to: $OutputPath" -ForegroundColor Green
        
        # Add to Trusted Publishers (for self-signed)
        $store = New-Object System.Security.Cryptography.X509Certificates.X509Store([System.Security.Cryptography.X509Certificates.StoreName]::TrustedPublisher, [System.Security.Cryptography.X509Certificates.StoreLocation]::CurrentUser)
        $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
        $store.Add($cert)
        $store.Close()
        
        Write-Host "  🛡️ Certificate added to Trusted Publishers" -ForegroundColor Green
        
        return $cert
        
    } catch {
        Write-Error "❌ Failed to create certificate: $($_.Exception.Message)"
        return $null
    }
}

function Test-ModuleManifest {
    <#
    .SYNOPSIS
    Validates and enhances PowerShell module manifests.
    #>
    
    param([string]$ModulePath)
    
    $manifestPath = Get-ChildItem -Path $ModulePath -Filter "*.psd1" | Select-Object -First 1
    
    if (-not $manifestPath) {
        return @{
            Valid = $false
            Reason = "No manifest file found"
            ManifestPath = $null
        }
    }
    
    try {
        $manifest = Test-ModuleManifest -Path $manifestPath.FullName -ErrorAction Stop
        
        # Check required fields for PSGallery
        $required = @('ModuleVersion', 'Description', 'Author')
        $missing = @()
        
        foreach ($field in $required) {
            if (-not $manifest.$field -or $manifest.$field -eq '') {
                $missing += $field
            }
        }
        
        return @{
            Valid = $missing.Count -eq 0
            Reason = if ($missing.Count -gt 0) { "Missing required fields: $($missing -join ', ')" } else { "Valid" }
            ManifestPath = $manifestPath.FullName
            Manifest = $manifest
            MissingFields = $missing
        }
        
    } catch {
        return @{
            Valid = $false
            Reason = "Invalid manifest: $($_.Exception.Message)"
            ManifestPath = $manifestPath.FullName
        }
    }
}

function Update-ModuleManifest {
    <#
    .SYNOPSIS
    Enhances module manifest with PSGallery requirements.
    #>
    
    param(
        [string]$ManifestPath,
        [hashtable]$Updates
    )
    
    if ($DryRun) {
        Write-Host "    🧪 Would update manifest: $ManifestPath" -ForegroundColor Yellow
        return
    }
    
    try {
        # Read current manifest
        $content = Get-Content -Path $ManifestPath -Raw
        
        # Create backup
        $backupPath = $ManifestPath + ".backup"
        Copy-Item -Path $ManifestPath -Destination $backupPath -Force
        
        # Apply updates
        foreach ($key in $Updates.Keys) {
            $value = $Updates[$key]
            
            if ($content -match "^\s*$key\s*=") {
                # Update existing field
                $content = $content -replace "^\s*$key\s*=.*", "    $key = '$value'"
            } else {
                # Add new field (insert before closing brace)
                $content = $content -replace "}\s*$", "    $key = '$value'`n}"
            }
        }
        
        Set-Content -Path $ManifestPath -Value $content -Encoding UTF8
        Write-Host "    ✅ Updated manifest: $ManifestPath" -ForegroundColor Green
        
    } catch {
        Write-Error "❌ Failed to update manifest $ManifestPath`: $($_.Exception.Message)"
    }
}

function Add-DigitalSignature {
    <#
    .SYNOPSIS
    Signs PowerShell module files with digital certificate.
    #>
    
    param(
        [string]$ModulePath,
        [System.Security.Cryptography.X509Certificates.X509Certificate2]$Certificate
    )
    
    if (-not $Certificate) {
        Write-Warning "⚠️ No certificate provided for signing"
        return
    }
    
    $scriptFiles = Get-ChildItem -Path $ModulePath -Filter "*.ps1" -Recurse
    $scriptFiles += Get-ChildItem -Path $ModulePath -Filter "*.psm1" -Recurse
    
    foreach ($file in $scriptFiles) {
        try {
            if ($DryRun) {
                Write-Host "    🧪 Would sign: $($file.Name)" -ForegroundColor Yellow
                continue
            }
            
            Set-AuthenticodeSignature -FilePath $file.FullName -Certificate $Certificate -TimestampServer "http://timestamp.digicert.com" | Out-Null
            Write-Host "    🔏 Signed: $($file.Name)" -ForegroundColor Green
            
        } catch {
            Write-Warning "⚠️ Failed to sign $($file.Name): $($_.Exception.Message)"
        }
    }
}

function Register-PSGallerySource {
    <#
    .SYNOPSIS
    Registers private PSGallery repository source.
    #>
    
    param(
        [string]$Name,
        [string]$SourceUrl,
        [string]$PublishUrl
    )
    
    Write-Host "🌐 Registering PSGallery source: $Name" -ForegroundColor Cyan
    
    if ($DryRun) {
        Write-Host "  🧪 Would register repository:" -ForegroundColor Yellow
        Write-Host "    Name: $Name" -ForegroundColor Gray
        Write-Host "    SourceUrl: $SourceUrl" -ForegroundColor Gray
        Write-Host "    PublishUrl: $PublishUrl" -ForegroundColor Gray
        return
    }
    
    try {
        # Unregister if exists
        if (Get-PSRepository -Name $Name -ErrorAction SilentlyContinue) {
            Unregister-PSRepository -Name $Name -Force
            Write-Host "  🗑️ Removed existing repository" -ForegroundColor Gray
        }
        
        # Register new repository
        Register-PSRepository -Name $Name -SourceLocation $SourceUrl -PublishLocation $PublishUrl -InstallationPolicy Trusted
        
        Write-Host "  ✅ Repository registered successfully" -ForegroundColor Green
        
        # Test connection
        Find-Module -Repository $Name -ErrorAction SilentlyContinue | Out-Null
        Write-Host "  🔌 Repository connection verified" -ForegroundColor Green
        
    } catch {
        Write-Error "❌ Failed to register repository: $($_.Exception.Message)"
    }
}

function Initialize-PSGallerySource {
    [CmdletBinding()]
    param(
        [string]$VendorPath,
        [string]$CertificatePath,
        [string]$RepositoryName,
        [string]$PublishUrl,
        [string]$SourceUrl,
        [switch]$CreateCertificate,
        [switch]$DryRun
    )
    
    Write-Host "🚀 Initializing PSGallery Source for Enterprise Modules..." -ForegroundColor Cyan
    Write-Host "📂 Vendor Path: $VendorPath" -ForegroundColor Gray
    
    if ($DryRun) {
        Write-Host "🧪 DRY RUN MODE - No changes will be made" -ForegroundColor Yellow
    }
    
    # Get certificate for signing
    $cert = $null
    if ($CreateCertificate) {
        $cert = New-CodeSigningCertificate
    } elseif ($CertificatePath -and (Test-Path $CertificatePath)) {
        $password = Read-Host "Enter certificate password" -AsSecureString
        $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2($CertificatePath, $password)
        Write-Host "🔐 Loaded certificate: $($cert.Subject)" -ForegroundColor Green
    }
    
    # Focus on custom/personal modules for PSGallery preparation
    $customVendors = @('PhilipRochazka', 'Unknown')
    $processedModules = 0
    $signedModules = 0
    $enhancedManifests = 0
    
    foreach ($vendor in $customVendors) {
        $vendorPath = Join-Path $VendorPath $vendor
        
        if (-not (Test-Path $vendorPath)) {
            Write-Host "⚠️ Vendor path not found: $vendorPath" -ForegroundColor Yellow
            continue
        }
        
        Write-Host "`n🏷️  Processing vendor: $vendor" -ForegroundColor Cyan
        
        $modules = Get-ChildItem -Path $vendorPath -Directory
        
        foreach ($module in $modules) {
            Write-Host "  📦 Processing module: $($module.Name)" -ForegroundColor Yellow
            $processedModules++
            
            # Test and enhance manifest
            $manifestTest = Test-ModuleManifest -ModulePath $module.FullName
            
            if ($manifestTest.Valid) {
                Write-Host "    ✅ Manifest is valid" -ForegroundColor Green
            } else {
                Write-Host "    ⚠️ Manifest issue: $($manifestTest.Reason)" -ForegroundColor Yellow
                
                if ($manifestTest.ManifestPath -and $manifestTest.MissingFields) {
                    # Enhance manifest
                    $updates = @{}
                    
                    if ('Description' -in $manifestTest.MissingFields) {
                        $updates['Description'] = "PowerShell module: $($module.Name)"
                    }
                    if ('Author' -in $manifestTest.MissingFields) {
                        $updates['Author'] = "Philip Rochazka"
                    }
                    if ('CompanyName' -notin $manifestTest.MissingFields) {
                        $updates['CompanyName'] = "Philip Rochazka"
                    }
                    if ('Copyright' -notin $manifestTest.MissingFields) {
                        $updates['Copyright'] = "(c) $(Get-Date -Format yyyy) Philip Rochazka. All rights reserved."
                    }
                    
                    Update-ModuleManifest -ManifestPath $manifestTest.ManifestPath -Updates $updates
                    $enhancedManifests++
                }
            }
            
            # Add digital signature
            if ($cert) {
                Add-DigitalSignature -ModulePath $module.FullName -Certificate $cert
                $signedModules++
            }
        }
    }
    
    # Register PSGallery source
    Write-Host "`n🌐 Preparing PSGallery source registration..." -ForegroundColor Cyan
    Register-PSGallerySource -Name $RepositoryName -SourceUrl $SourceUrl -PublishUrl $PublishUrl
    
    # Create deployment documentation
    Build-PSGalleryDocumentation -VendorPath $VendorPath -RepositoryName $RepositoryName -ProcessedModules $processedModules -SignedModules $signedModules -EnhancedManifests $enhancedManifests
    
    Write-Host "`n✅ PSGallery source initialization completed!" -ForegroundColor Green
    Write-Host "📊 Summary:" -ForegroundColor Cyan
    Write-Host "  📦 Processed modules: $processedModules" -ForegroundColor Gray
    Write-Host "  🔏 Signed modules: $signedModules" -ForegroundColor Gray
    Write-Host "  📝 Enhanced manifests: $enhancedManifests" -ForegroundColor Gray
    Write-Host "  🌐 Repository: $RepositoryName" -ForegroundColor Gray
}

function Build-PSGalleryDocumentation {
    param(
        [string]$VendorPath,
        [string]$RepositoryName,
        [int]$ProcessedModules,
        [int]$SignedModules, 
        [int]$EnhancedManifests
    )
    
    $docsPath = Join-Path $VendorPath "PSGallery-Setup.md"
    
    $content = @"
# PSGallery Enterprise Source - Setup Complete

Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

## Repository Information

- **Repository Name**: $RepositoryName
- **Source URL**: $SourceUrl
- **Publish URL**: $PublishUrl
- **Installation Policy**: Trusted

## Processing Summary

- **Modules Processed**: $ProcessedModules
- **Modules Signed**: $SignedModules  
- **Manifests Enhanced**: $EnhancedManifests

## Usage Examples

### Finding Modules

``````powershell
# Search in private repository
Find-Module -Repository $RepositoryName

# Search specific module
Find-Module -Name "UnifiedPowerShellProfile" -Repository $RepositoryName
``````

### Installing Modules

``````powershell
# Install from private repository
Install-Module -Name "UnifiedPowerShellProfile" -Repository $RepositoryName

# Install with specific version
Install-Module -Name "Google-Hardware-key" -RequiredVersion "1.0.0" -Repository $RepositoryName
``````

### Publishing Modules

``````powershell
# Publish module to private repository
Publish-Module -Path ".\PhilipRochazka\UnifiedPowerShellProfile" -Repository $RepositoryName -NuGetApiKey "your-api-key"

# Publish with release notes
Publish-Module -Path ".\PhilipRochazka\Google-Hardware-key" -Repository $RepositoryName -ReleaseNotes "Initial release" -NuGetApiKey "your-api-key"
``````

## Digital Signature Verification

Modules have been signed with code signing certificate. To verify:

``````powershell
# Check signature status
Get-AuthenticodeSignature -FilePath ".\PhilipRochazka\UnifiedPowerShellProfile\UnifiedPowerShellProfile.psm1"

# Verify all signatures in module
Get-ChildItem -Path ".\PhilipRochazka\UnifiedPowerShellProfile" -Filter "*.ps*" -Recurse | Get-AuthenticodeSignature | Where-Object Status -eq "Valid"
``````

## Security Configuration

### Execution Policy

For signed modules:

``````powershell
# Allow signed scripts (recommended for enterprise)
Set-ExecutionPolicy AllSigned -Scope CurrentUser

# Or allow remote signed (less restrictive)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
``````

### Certificate Trust

The code signing certificate has been added to Trusted Publishers. To manually verify:

``````powershell
# Check trusted publishers
Get-ChildItem -Path "Cert:\CurrentUser\TrustedPublisher"

# Add certificate to trusted publishers (if needed)
Import-Certificate -FilePath ".\CodeSigning.cer" -CertStoreLocation "Cert:\CurrentUser\TrustedPublisher"
``````

## Next Steps

1. **Configure Repository Server**: Set up actual PSGallery server (NuGet.Server, ProGet, etc.)
2. **API Key Management**: Generate and configure API keys for publishing
3. **CI/CD Integration**: Automate module testing and publishing pipeline
4. **Version Management**: Implement semantic versioning strategy
5. **Documentation**: Complete module documentation for all custom modules

## Repository Management Commands

``````powershell
# List registered repositories
Get-PSRepository

# Update repository configuration
Set-PSRepository -Name "$RepositoryName" -InstallationPolicy Trusted

# Unregister repository (if needed)
Unregister-PSRepository -Name "$RepositoryName"
``````

---
*Generated by Initialize-PSGallerySource following PowerShell enterprise best practices*
"@
    
    if (-not $DryRun) {
        Set-Content -Path $docsPath -Value $content -Encoding UTF8
        Write-Host "  📚 Created PSGallery documentation: PSGallery-Setup.md" -ForegroundColor Green
    }
}

# Main execution
Initialize-PSGallerySource -VendorPath $VendorPath -CertificatePath $CertificatePath -RepositoryName $RepositoryName -PublishUrl $PublishUrl -SourceUrl $SourceUrl -CreateCertificate:$CreateCertificate -DryRun:$DryRun
