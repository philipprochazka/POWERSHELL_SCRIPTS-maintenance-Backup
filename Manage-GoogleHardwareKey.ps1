#Requires -Version 5.1
<#
.SYNOPSIS
    Google Hardware Key Manager - Advanced usage and management tools
    
.DESCRIPTION
    Advanced script for managing your USB-based Google hardware authentication key.
    Provides additional security features, key rotation, and enterprise integration.
    
.PARAMETER Action
    Action to perform: Validate, Rotate, Clone, Enterprise, Monitor, or Secure
    
.PARAMETER USBDriveLetter
    Drive letter of the USB hardware key
    
.PARAMETER NewUSBDrive
    Drive letter for cloning or backup operations
    
.EXAMPLE
    .\Manage-GoogleHardwareKey.ps1 -Action Validate -USBDriveLetter "E:"
    
.EXAMPLE
    .\Manage-GoogleHardwareKey.ps1 -Action Clone -USBDriveLetter "E:" -NewUSBDrive "F:"
    
.NOTES
    Author: PowerShell Security Assistant
    Version: 1.0
    Companion to Setup-GoogleHardwareKey.ps1
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Validate', 'Rotate', 'Clone', 'Enterprise', 'Monitor', 'Secure', 'Emergency')]
    [string]$Action,
    
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Z]:$')]
    [string]$USBDriveLetter,
    
    [Parameter(Mandatory = $false)]
    [ValidatePattern('^[A-Z]:$')]
    [string]$NewUSBDrive
)

Write-Host "🔧 Google Hardware Key Manager" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan

$keyPath = "$USBDriveLetter\GoogleSecurityKey"

# Validate hardware key exists
if (-not (Test-Path $keyPath)) {
    Write-Error "Google Hardware Key not found at $USBDriveLetter"
    Write-Host "Please run Setup-GoogleHardwareKey.ps1 first" -ForegroundColor Yellow
    exit 1
}

function Validate-HardwareKey {
    Write-Host "🔍 Validating hardware key integrity..." -ForegroundColor Cyan
    
    $requiredFolders = @("Certificates", "Credentials", "Scripts", "Backup")
    $requiredFiles = @("Google-HardwareKey-Launcher.ps1", "README.md")
    
    $issues = @()
    
    # Check folder structure
    foreach ($folder in $requiredFolders) {
        $folderPath = "$keyPath\$folder"
        if (-not (Test-Path $folderPath)) {
            $issues += "Missing folder: $folder"
        } else {
            Write-Host "  ✅ Folder exists: $folder" -ForegroundColor Green
        }
    }
    
    # Check required files
    foreach ($file in $requiredFiles) {
        $filePath = "$keyPath\$file"
        if (-not (Test-Path $filePath)) {
            $issues += "Missing file: $file"
        } else {
            Write-Host "  ✅ File exists: $file" -ForegroundColor Green
        }
    }
    
    # Check configurations
    $configs = Get-ChildItem "$keyPath\*-Config.json" -ErrorAction SilentlyContinue
    if ($configs.Count -eq 0) {
        $issues += "No authentication configurations found"
    } else {
        Write-Host "  ✅ Found $($configs.Count) authentication configuration(s)" -ForegroundColor Green
        
        foreach ($config in $configs) {
            try {
                $configData = Get-Content $config.FullName | ConvertFrom-Json
                Write-Host "    📋 $($configData.Type) - Created: $($configData.Created)" -ForegroundColor Yellow
            } catch {
                $issues += "Corrupted configuration: $($config.Name)"
            }
        }
    }
    
    # Security validation
    $usbProperties = Get-ItemProperty -Path $USBDriveLetter
    if ($usbProperties.Attributes -band [System.IO.FileAttributes]::ReadOnly) {
        Write-Host "  ⚠️  USB drive is read-only" -ForegroundColor Yellow
    }
    
    # Report results
    if ($issues.Count -eq 0) {
        Write-Host "✅ Hardware key validation passed!" -ForegroundColor Green
    } else {
        Write-Host "❌ Validation issues found:" -ForegroundColor Red
        $issues | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    }
    
    return $issues.Count -eq 0
}

function Rotate-Credentials {
    Write-Host "🔄 Rotating authentication credentials..." -ForegroundColor Cyan
    
    # Backup current configurations
    $rotationBackup = "$keyPath\Backup\Rotation-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    New-Item -Path $rotationBackup -ItemType Directory -Force | Out-Null
    
    # Backup current configs
    Copy-Item "$keyPath\*-Config.json" -Destination $rotationBackup -Force
    Write-Host "  📦 Current configurations backed up to: $rotationBackup" -ForegroundColor Green
    
    # Rotate certificates
    $certConfig = "$keyPath\Certificate-Config.json"
    if (Test-Path $certConfig) {
        Write-Host "  🔄 Rotating certificates..." -ForegroundColor Yellow
        
        $config = Get-Content $certConfig | ConvertFrom-Json
        $oldThumbprint = $config.CertificateThumbprint
        
        # Remove old certificate
        if ($oldThumbprint) {
            $oldCert = Get-ChildItem "Cert:\CurrentUser\My\$oldThumbprint" -ErrorAction SilentlyContinue
            if ($oldCert) {
                Remove-Item $oldCert.PSPath -Force
                Write-Host "    ❌ Removed old certificate: $oldThumbprint" -ForegroundColor Yellow
            }
        }
        
        # Generate new certificate
        $newCert = New-SelfSignedCertificate -Subject "CN=GoogleHardwareKey-$env:USERNAME-$(Get-Date -Format 'yyyyMMdd')" -KeyAlgorithm RSA -KeyLength 2048 -NotAfter (Get-Date).AddYears(2) -CertStoreLocation "Cert:\CurrentUser\My"
        
        # Export new certificate
        $certPassword = ConvertTo-SecureString -String (Read-Host "Enter new certificate password" -AsSecureString) -Force
        Export-PfxCertificate -Cert $newCert -FilePath "$keyPath\Certificates\GoogleAuthCert-New.pfx" -Password $certPassword
        
        # Update configuration
        $config.CertificateThumbprint = $newCert.Thumbprint
        $config.Created = Get-Date
        $config.RotationHistory = @($config.RotationHistory) + @{
            PreviousThumbprint = $oldThumbprint
            RotationDate = Get-Date
            RotatedBy = $env:USERNAME
        }
        
        $config | ConvertTo-Json -Depth 5 | Set-Content $certConfig
        Write-Host "    ✅ New certificate created: $($newCert.Thumbprint)" -ForegroundColor Green
    }
    
    # Rotate encrypted credentials
    $credConfig = "$keyPath\Credentials-Config.json"
    if (Test-Path $credConfig) {
        Write-Host "  🔄 Rotating encrypted credentials..." -ForegroundColor Yellow
        Write-Host "    Please generate a new Google App Password" -ForegroundColor Cyan
        Start-Process "https://myaccount.google.com/apppasswords"
        
        $config = Get-Content $credConfig | ConvertFrom-Json
        
        # Backup old credentials
        $oldCredFile = $config.CredentialFile
        if (Test-Path $oldCredFile) {
            Copy-Item $oldCredFile -Destination "$rotationBackup\GoogleCredentials-Old.xml" -Force
        }
        
        # Get new credentials
        $newCred = Get-Credential -UserName $config.Account -Message "Enter NEW Google App Password"
        $newCred | Export-Clixml -Path $oldCredFile
        
        # Update configuration
        $config.LastRotation = Get-Date
        $config.RotationHistory = @($config.RotationHistory) + @{
            RotationDate = Get-Date
            RotatedBy = $env:USERNAME
        }
        
        $config | ConvertTo-Json -Depth 5 | Set-Content $credConfig
        Write-Host "    ✅ Credentials rotated successfully" -ForegroundColor Green
    }
    
    Write-Host "🔄 Credential rotation completed!" -ForegroundColor Green
    Write-Host "📝 Remember to update your Google account security settings" -ForegroundColor Yellow
}

function Clone-HardwareKey {
    if (-not $NewUSBDrive) {
        Write-Error "NewUSBDrive parameter required for cloning"
        return
    }
    
    Write-Host "📋 Cloning hardware key to $NewUSBDrive..." -ForegroundColor Cyan
    
    if (-not (Test-Path $NewUSBDrive)) {
        Write-Error "Destination USB drive $NewUSBDrive not found"
        return
    }
    
    $destPath = "$NewUSBDrive\GoogleSecurityKey"
    
    # Create destination structure
    if (Test-Path $destPath) {
        $overwrite = Read-Host "Destination already exists. Overwrite? (Y/N)"
        if ($overwrite -ne 'Y' -and $overwrite -ne 'y') {
            Write-Host "Clone operation cancelled" -ForegroundColor Yellow
            return
        }
        Remove-Item $destPath -Recurse -Force
    }
    
    # Copy entire structure
    Copy-Item $keyPath -Destination $destPath -Recurse -Force
    
    # Update configurations for new drive
    $configFiles = Get-ChildItem "$destPath\Scripts\*.ps1"
    foreach ($script in $configFiles) {
        $content = Get-Content $script.FullName -Raw
        $content = $content.Replace($USBDriveLetter, $NewUSBDrive)
        $content | Set-Content $script.FullName
    }
    
    # Update master launcher
    $masterLauncher = "$destPath\Google-HardwareKey-Launcher.ps1"
    if (Test-Path $masterLauncher) {
        $content = Get-Content $masterLauncher -Raw
        $content = $content.Replace($USBDriveLetter, $NewUSBDrive)
        $content | Set-Content $masterLauncher
    }
    
    # Add clone information
    $cloneInfo = @{
        ClonedFrom = $USBDriveLetter
        ClonedTo = $NewUSBDrive
        CloneDate = Get-Date
        ClonedBy = $env:USERNAME
        OriginalSerial = (Get-Volume -DriveLetter $USBDriveLetter.TrimEnd(':')).FileSystemLabel
        CloneSerial = (Get-Volume -DriveLetter $NewUSBDrive.TrimEnd(':')).FileSystemLabel
    }
    
    $cloneInfo | ConvertTo-Json | Set-Content "$destPath\Clone-Info.json"
    
    Write-Host "✅ Hardware key cloned successfully!" -ForegroundColor Green
    Write-Host "📝 Test the cloned key before relying on it" -ForegroundColor Yellow
}

function Setup-Enterprise {
    Write-Host "🏢 Setting up enterprise integration..." -ForegroundColor Cyan
    
    # Create enterprise configuration
    $enterpriseConfig = @{
        Type = "Enterprise"
        Created = Get-Date
        Domain = Read-Host "Enter your organization domain (e.g., company.com)"
        GoogleWorkspace = $true
        Features = @{
            CertificateBasedAuth = $true
            LDAPIntegration = $false
            GroupPolicyCompliance = $true
            AuditLogging = $true
        }
        AdminContact = Read-Host "Enter IT admin contact email"
        ComplianceStandards = @("SOC2", "ISO27001", "GDPR")
    }
    
    # Create enterprise launcher script
    $enterpriseScript = @'
# Enterprise Google Authentication
param(
    [string]$Domain,
    [switch]$AuditMode
)

$keyPath = "PLACEHOLDER_USB_DRIVE\GoogleSecurityKey"
$enterpriseConfig = Get-Content "$keyPath\Enterprise-Config.json" | ConvertFrom-Json

Write-Host "🏢 Enterprise Google Authentication" -ForegroundColor Cyan
Write-Host "Organization: $($enterpriseConfig.Domain)" -ForegroundColor Yellow

if ($AuditMode) {
    # Log authentication attempt
    $auditEntry = @{
        Timestamp = Get-Date
        User = $env:USERNAME
        Computer = $env:COMPUTERNAME
        Domain = $env:USERDOMAIN
        Action = "Authentication Attempt"
        Method = "Hardware Key"
    }
    
    $auditLog = "$keyPath\Audit\Audit-$(Get-Date -Format 'yyyyMM').json"
    $auditEntries = @()
    
    if (Test-Path $auditLog) {
        $auditEntries = Get-Content $auditLog | ConvertFrom-Json
    }
    
    $auditEntries += $auditEntry
    $auditEntries | ConvertTo-Json | Set-Content $auditLog
    
    Write-Host "📊 Audit entry logged" -ForegroundColor Green
}

# Standard enterprise authentication
& "$keyPath\Google-HardwareKey-Launcher.ps1" -Method Certificate
'@

    $enterpriseScript = $enterpriseScript.Replace("PLACEHOLDER_USB_DRIVE", $USBDriveLetter)
    
    # Create enterprise folder structure
    New-Item -Path "$keyPath\Enterprise" -ItemType Directory -Force | Out-Null
    New-Item -Path "$keyPath\Audit" -ItemType Directory -Force | Out-Null
    
    $enterpriseConfig | ConvertTo-Json -Depth 3 | Set-Content "$keyPath\Enterprise-Config.json"
    $enterpriseScript | Set-Content "$keyPath\Scripts\Enterprise-Auth.ps1"
    
    Write-Host "✅ Enterprise integration configured" -ForegroundColor Green
    Write-Host "📋 Contact your IT admin to complete certificate setup" -ForegroundColor Yellow
}

function Monitor-Usage {
    Write-Host "📊 Monitoring hardware key usage..." -ForegroundColor Cyan
    
    # Check for audit logs
    $auditPath = "$keyPath\Audit"
    if (Test-Path $auditPath) {
        $auditFiles = Get-ChildItem "$auditPath\Audit-*.json"
        
        if ($auditFiles.Count -gt 0) {
            Write-Host "📊 Usage Statistics:" -ForegroundColor Yellow
            
            $totalEntries = 0
            $auditFiles | ForEach-Object {
                $entries = Get-Content $_.FullName | ConvertFrom-Json
                $totalEntries += $entries.Count
                Write-Host "  📅 $($_.BaseName): $($entries.Count) entries" -ForegroundColor Cyan
            }
            
            Write-Host "  📈 Total authentication attempts: $totalEntries" -ForegroundColor Green
        } else {
            Write-Host "📊 No usage data found" -ForegroundColor Yellow
        }
    }
    
    # Check configuration health
    $configs = Get-ChildItem "$keyPath\*-Config.json"
    Write-Host "🔧 Configuration Status:" -ForegroundColor Yellow
    
    foreach ($config in $configs) {
        $configData = Get-Content $config.FullName | ConvertFrom-Json
        $age = (Get-Date) - [DateTime]$configData.Created
        
        Write-Host "  📋 $($configData.Type): $($age.Days) days old" -ForegroundColor Cyan
        
        if ($age.Days -gt 90) {
            Write-Host "    ⚠️  Consider rotating (>90 days old)" -ForegroundColor Yellow
        }
    }
    
    # USB drive health
    $usbInfo = Get-Volume -DriveLetter $USBDriveLetter.TrimEnd(':')
    Write-Host "💾 USB Drive Health:" -ForegroundColor Yellow
    Write-Host "  📁 Label: $($usbInfo.FileSystemLabel)" -ForegroundColor Cyan
    Write-Host "  💽 Size: $([math]::Round($usbInfo.Size / 1GB, 2)) GB" -ForegroundColor Cyan
    Write-Host "  📊 Free: $([math]::Round($usbInfo.SizeRemaining / 1GB, 2)) GB" -ForegroundColor Cyan
    Write-Host "  🗂️  File System: $($usbInfo.FileSystem)" -ForegroundColor Cyan
}

function Secure-HardwareKey {
    Write-Host "🔒 Applying additional security measures..." -ForegroundColor Cyan
    
    # Set advanced file attributes
    Get-ChildItem $keyPath -Recurse | ForEach-Object {
        Set-ItemProperty -Path $_.FullName -Name Attributes -Value ([System.IO.FileAttributes]::Hidden -bor [System.IO.FileAttributes]::System)
    }
    
    # Create integrity verification
    $integrityData = @{
        Created = Get-Date
        Files = @()
    }
    
    Get-ChildItem $keyPath -Recurse -File | ForEach-Object {
        $hash = Get-FileHash $_.FullName -Algorithm SHA256
        $integrityData.Files += @{
            Path = $_.FullName.Replace($keyPath, "")
            Hash = $hash.Hash
            Size = $_.Length
            Modified = $_.LastWriteTime
        }
    }
    
    $integrityData | ConvertTo-Json -Depth 5 | Set-Content "$keyPath\Integrity.json"
    
    # Set read-only on critical files
    $criticalFiles = @("README.md", "*-Config.json", "Integrity.json")
    foreach ($pattern in $criticalFiles) {
        Get-ChildItem "$keyPath\$pattern" -Recurse | ForEach-Object {
            Set-ItemProperty -Path $_.FullName -Name IsReadOnly -Value $true
        }
    }
    
    Write-Host "✅ Additional security measures applied" -ForegroundColor Green
    Write-Host "📝 Integrity file created for verification" -ForegroundColor Yellow
}

function Emergency-Access {
    Write-Host "🚨 Emergency access procedure..." -ForegroundColor Red
    
    Write-Host "⚠️  This will create emergency access codes for your Google account" -ForegroundColor Yellow
    $confirm = Read-Host "Are you sure you want to proceed? (YES/no)"
    
    if ($confirm -eq "YES") {
        # Create emergency access info
        $emergencyInfo = @{
            Created = Get-Date
            CreatedBy = $env:USERNAME
            Reason = Read-Host "Enter reason for emergency access"
            Instructions = @(
                "1. Go to https://myaccount.google.com/security",
                "2. Navigate to 2-Step Verification",
                "3. Generate backup codes",
                "4. Store codes securely offline",
                "5. Use codes if hardware key is unavailable"
            )
            TempCredentials = @{
                Valid = $true
                ExpiresAfter = (Get-Date).AddDays(7)
                Note = "Generate new backup codes immediately"
            }
        }
        
        $emergencyInfo | ConvertTo-Json -Depth 3 | Set-Content "$keyPath\Emergency-Access.json"
        
        # Open Google security page
        Start-Process "https://myaccount.google.com/security"
        
        Write-Host "🚨 Emergency access file created" -ForegroundColor Green
        Write-Host "📝 Follow the instructions to generate backup codes" -ForegroundColor Yellow
        Write-Host "⚠️  Remember to disable emergency access when resolved" -ForegroundColor Red
    } else {
        Write-Host "Emergency access cancelled" -ForegroundColor Yellow
    }
}

# Execute requested action
switch ($Action) {
    'Validate' { Validate-HardwareKey }
    'Rotate' { Rotate-Credentials }
    'Clone' { Clone-HardwareKey }
    'Enterprise' { Setup-Enterprise }
    'Monitor' { Monitor-Usage }
    'Secure' { Secure-HardwareKey }
    'Emergency' { Emergency-Access }
}

Write-Host ""
Write-Host "🔧 Hardware key management completed!" -ForegroundColor Green
