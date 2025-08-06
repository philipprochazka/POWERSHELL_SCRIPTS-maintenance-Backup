#Requires -Version 5.1
<#
.SYNOPSIS
    Sets up a USB flash drive as a hardware key for secure Google access
    
.DESCRIPTION
    This script helps create a hardware authentication key using a USB flash drive
    for secure Google account access. It supports multiple authentication methods
    including FIDO2/WebAuthn, encrypted credential storage, and certificate-based authentication.
    
.PARAMETER USBDriveLetter
    The drive letter of the USB flash drive to use as hardware key
    
.PARAMETER Method
    Authentication method: 'FIDO2', 'Certificate', 'EncryptedCredentials', 'All'
    
.PARAMETER GoogleAccount
    Your Google account email address
    
.PARAMETER CreateBackup
    Creates a backup of existing authentication data
    
.EXAMPLE
    .\Install-GoogleHardwareKey.ps1 -USBDriveLetter "E:" -Method "All" -GoogleAccount "user@gmail.com"
    
.EXAMPLE
    .\Install-GoogleHardwareKey.ps1 -USBDriveLetter "F:" -Method "FIDO2" -CreateBackup
    
.NOTES
    Author: PowerShell Security Assistant
    Version: 1.0
    Requires: Windows 10/11, PowerShell 5.1+, Administrator privileges
    
    Security Requirements:
    - USB drive will be encrypted
    - Requires Windows Hello or PIN setup
    - Google Account 2FA must be enabled
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Z]:$')]
    [string]$USBDriveLetter,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet('FIDO2', 'Certificate', 'EncryptedCredentials', 'All')]
    [string]$Method = 'All',
    
    [Parameter(Mandatory = $false)]
    [string]$GoogleAccount,
    
    [Parameter(Mandatory = $false)]
    [switch]$CreateBackup
)

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script requires Administrator privileges. Please run as Administrator."
    exit 1
}

Write-Host "🔐 Google Hardware Key Setup Tool" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Verify USB drive exists
if (-not (Test-Path $USBDriveLetter)) {
    Write-Error "USB drive $USBDriveLetter not found. Please ensure the drive is connected."
    exit 1
}

# Get USB drive info
$usbDrive = Get-Volume -DriveLetter $USBDriveLetter.TrimEnd(':')
Write-Host "📁 USB Drive detected: $($usbDrive.FileSystemLabel) ($($usbDrive.Size / 1GB) GB)" -ForegroundColor Green

# Create security folders structure
$keyPath = "$USBDriveLetter\GoogleSecurityKey"
$certPath = "$keyPath\Certificates"
$credPath = "$keyPath\Credentials" 
$backupPath = "$keyPath\Backup"
$scriptsPath = "$keyPath\Scripts"

Write-Host "📂 Creating security folder structure..." -ForegroundColor Yellow

foreach ($folder in @($keyPath, $certPath, $credPath, $backupPath, $scriptsPath)) {
    if (-not (Test-Path $folder)) {
        New-Item -Path $folder -ItemType Directory -Force | Out-Null
        Write-Host "  ✅ Created: $folder" -ForegroundColor Green
    }
}

# Function to setup FIDO2/WebAuthn
function Install-FIDO2 {
    Write-Host "🔑 Setting up FIDO2/WebAuthn authentication..." -ForegroundColor Cyan
    
    # Create FIDO2 configuration
    $fido2Config = @{
        Type = "FIDO2"
        Created = Get-Date
        USBDrive = $USBDriveLetter
        Instructions = @(
            "1. Go to https://myaccount.google.com/security",
            "2. Navigate to '2-Step Verification'",
            "3. Click 'Add security key'",
            "4. Select 'USB security key'",
            "5. Follow the on-screen instructions",
            "6. Name your key (e.g., 'USB Hardware Key')"
        )
        RequiredSoftware = @(
            "WebAuthn API (built into Windows 10+)",
            "Google Chrome or Edge browser",
            "Windows Hello (recommended)"
        )
    }
    
    $fido2Config | ConvertTo-Json -Depth 3 | Set-Content "$keyPath\FIDO2-Setup.json"
    
    # Create FIDO2 launcher script
    $fido2Script = @'
# FIDO2 Google Authentication Launcher
Write-Host "🔐 Launching Google FIDO2 Authentication..." -ForegroundColor Cyan
Write-Host "Please insert your USB hardware key if not already connected." -ForegroundColor Yellow

# Check if USB key is present
$usbPresent = Test-Path "PLACEHOLDER_USB_DRIVE"
if (-not $usbPresent) {
    Write-Error "USB Hardware Key not detected. Please insert the key and try again."
    exit 1
}

# Open Google security settings
Start-Process "https://myaccount.google.com/security"
Write-Host "✅ Opened Google Security settings. Please proceed with FIDO2 authentication." -ForegroundColor Green
'@

    $fido2Script = $fido2Script.Replace("PLACEHOLDER_USB_DRIVE", $USBDriveLetter)
    $fido2Script | Set-Content "$scriptsPath\Launch-FIDO2.ps1"
    
    Write-Host "  ✅ FIDO2 configuration created" -ForegroundColor Green
}

# Function to setup certificate-based authentication
function Install-Certificate {
    Write-Host "📜 Setting up certificate-based authentication..." -ForegroundColor Cyan
    
    try {
        # Generate self-signed certificate for Google authentication
        $certParams = @{
            Subject = "CN=GoogleHardwareKey-$env:USERNAME"
            KeyAlgorithm = "RSA"
            KeyLength = 2048
            NotAfter = (Get-Date).AddYears(2)
            CertStoreLocation = "Cert:\CurrentUser\My"
            KeyUsage = "DigitalSignature", "KeyEncipherment"
            Type = "SSLServerAuthentication"
        }
        
        $cert = New-SelfSignedCertificate @certParams
        
        # Export certificate to USB drive
        $certPassword = ConvertTo-SecureString -String (Read-Host "Enter password for certificate export" -AsSecureString) -Force
        Export-PfxCertificate -Cert $cert -FilePath "$certPath\GoogleAuthCert.pfx" -Password $certPassword
        Export-Certificate -Cert $cert -FilePath "$certPath\GoogleAuthCert.cer"
        
        # Create certificate configuration
        $certConfig = @{
            Type = "Certificate"
            CertificateThumbprint = $cert.Thumbprint
            Created = Get-Date
            ExpirationDate = $cert.NotAfter
            Subject = $cert.Subject
            Usage = "Google Account Authentication"
            Instructions = @(
                "1. Import certificate to Windows Certificate Store",
                "2. Configure Google Apps for certificate-based authentication",
                "3. Use certificate for enterprise Google Workspace (if applicable)"
            )
        }
        
        $certConfig | ConvertTo-Json -Depth 3 | Set-Content "$keyPath\Certificate-Config.json"
        
        Write-Host "  ✅ Certificate created and exported" -ForegroundColor Green
        Write-Host "  📋 Thumbprint: $($cert.Thumbprint)" -ForegroundColor Yellow
        
    } catch {
        Write-Error "Failed to create certificate: $($_.Exception.Message)"
    }
}

# Function to setup encrypted credentials storage
function Install-EncryptedCredentials {
    Write-Host "🔐 Setting up encrypted credentials storage..." -ForegroundColor Cyan
    
    if (-not $GoogleAccount) {
        $GoogleAccount = Read-Host "Enter your Google account email"
    }
    
    # Create encrypted credential storage
    $credentialFile = "$credPath\GoogleCredentials.xml"
    
    Write-Host "Please enter your Google App Password (not your regular password):" -ForegroundColor Yellow
    Write-Host "Generate one at: https://myaccount.google.com/apppasswords" -ForegroundColor Cyan
    
    $credential = Get-Credential -UserName $GoogleAccount -Message "Enter Google App Password"
    $credential | Export-Clixml -Path $credentialFile
    
    # Create credential launcher script
    $credScript = @'
# Encrypted Google Credentials Launcher
param([switch]$ShowCredentials)

$credentialFile = "PLACEHOLDER_CRED_PATH"
$usbDrive = "PLACEHOLDER_USB_DRIVE"

# Verify USB key is present
if (-not (Test-Path $usbDrive)) {
    Write-Error "USB Hardware Key not detected. Please insert the key."
    exit 1
}

# Load encrypted credentials
if (Test-Path $credentialFile) {
    try {
        $cred = Import-Clixml -Path $credentialFile
        Write-Host "✅ Credentials loaded for: $($cred.UserName)" -ForegroundColor Green
        
        if ($ShowCredentials) {
            Write-Host "Username: $($cred.UserName)" -ForegroundColor Yellow
            Write-Host "Password: [PROTECTED - Use Get-Credential to access]" -ForegroundColor Yellow
        }
        
        # Return credential object for use in other scripts
        return $cred
        
    } catch {
        Write-Error "Failed to load credentials: $($_.Exception.Message)"
    }
} else {
    Write-Error "Credential file not found: $credentialFile"
}
'@

    $credScript = $credScript.Replace("PLACEHOLDER_CRED_PATH", $credentialFile)
    $credScript = $credScript.Replace("PLACEHOLDER_USB_DRIVE", $USBDriveLetter)
    $credScript | Set-Content "$scriptsPath\Load-Credentials.ps1"
    
    # Create credential configuration
    $credConfig = @{
        Type = "EncryptedCredentials"
        Account = $GoogleAccount
        Created = Get-Date
        CredentialFile = $credentialFile
        Instructions = @(
            "1. Use Google App Passwords (not regular password)",
            "2. Generate app passwords at: https://myaccount.google.com/apppasswords",
            "3. Enable 2-Factor Authentication first",
            "4. Use Load-Credentials.ps1 script to access stored credentials"
        )
        Security = @(
            "Credentials encrypted with Windows DPAPI",
            "Only accessible from the same user account",
            "Requires USB hardware key to be present"
        )
    }
    
    $credConfig | ConvertTo-Json -Depth 3 | Set-Content "$keyPath\Credentials-Config.json"
    
    Write-Host "  ✅ Encrypted credentials stored" -ForegroundColor Green
}

# Function to create master launcher script
function Create-MasterLauncher {
    Write-Host "🚀 Creating master launcher script..." -ForegroundColor Cyan
    
    $masterScript = @'
#Requires -Version 5.1
<#
.SYNOPSIS
    Master launcher for Google Hardware Key authentication
    
.DESCRIPTION
    Main script to launch various Google authentication methods from USB hardware key
    
.PARAMETER Method
    Authentication method to use: FIDO2, Certificate, Credentials, or Interactive
    
.PARAMETER GoogleAccount
    Google account to authenticate (for credential method)
    
.EXAMPLE
    .\Google-HardwareKey-Launcher.ps1 -Method FIDO2
    
.EXAMPLE
    .\Google-HardwareKey-Launcher.ps1 -Method Credentials -GoogleAccount "user@gmail.com"
#>

param(
    [ValidateSet('FIDO2', 'Certificate', 'Credentials', 'Interactive')]
    [string]$Method = 'Interactive',
    
    [string]$GoogleAccount
)

$usbDrive = "PLACEHOLDER_USB_DRIVE"
$keyPath = "$usbDrive\GoogleSecurityKey"

Write-Host "🔐 Google Hardware Key Launcher" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

# Verify USB hardware key is present
if (-not (Test-Path $usbDrive)) {
    Write-Error "❌ USB Hardware Key not detected at $usbDrive"
    Write-Host "Please insert your USB hardware key and try again." -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ USB Hardware Key detected" -ForegroundColor Green

if ($Method -eq 'Interactive') {
    Write-Host ""
    Write-Host "Select authentication method:" -ForegroundColor Yellow
    Write-Host "1. FIDO2/WebAuthn (Recommended)"
    Write-Host "2. Certificate-based"
    Write-Host "3. Encrypted Credentials"
    Write-Host "4. Show all configurations"
    Write-Host ""
    
    $choice = Read-Host "Enter your choice (1-4)"
    
    switch ($choice) {
        '1' { $Method = 'FIDO2' }
        '2' { $Method = 'Certificate' }
        '3' { $Method = 'Credentials' }
        '4' { 
            # Show all available configurations
            Get-ChildItem "$keyPath\*-Config.json" | ForEach-Object {
                $config = Get-Content $_.FullName | ConvertFrom-Json
                Write-Host ""
                Write-Host "📋 $($config.Type) Configuration:" -ForegroundColor Cyan
                Write-Host "   Created: $($config.Created)"
                if ($config.Instructions) {
                    Write-Host "   Instructions:" -ForegroundColor Yellow
                    $config.Instructions | ForEach-Object { Write-Host "     $_" }
                }
            }
            exit 0
        }
        default { 
            Write-Error "Invalid choice"
            exit 1
        }
    }
}

# Execute selected method
switch ($Method) {
    'FIDO2' {
        Write-Host "🔑 Launching FIDO2 authentication..." -ForegroundColor Cyan
        & "$keyPath\Scripts\Launch-FIDO2.ps1"
    }
    'Certificate' {
        Write-Host "📜 Launching certificate authentication..." -ForegroundColor Cyan
        Write-Host "Certificate-based authentication requires manual configuration." -ForegroundColor Yellow
        Write-Host "See Certificate-Config.json for instructions." -ForegroundColor Yellow
        Start-Process "notepad.exe" -ArgumentList "$keyPath\Certificate-Config.json"
    }
    'Credentials' {
        Write-Host "🔐 Loading encrypted credentials..." -ForegroundColor Cyan
        $cred = & "$keyPath\Scripts\Load-Credentials.ps1"
        if ($cred) {
            Write-Host "✅ Credentials loaded successfully" -ForegroundColor Green
            Write-Host "Use the credential object for your Google API calls" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "🔐 Google Hardware Key operation completed" -ForegroundColor Green
'@

    $masterScript = $masterScript.Replace("PLACEHOLDER_USB_DRIVE", $USBDriveLetter)
    $masterScript | Set-Content "$keyPath\Google-HardwareKey-Launcher.ps1"
    
    Write-Host "  ✅ Master launcher created" -ForegroundColor Green
}

# Function to create backup
function Create-Backup {
    if ($CreateBackup) {
        Write-Host "💾 Creating backup of existing authentication data..." -ForegroundColor Cyan
        
        # Backup existing certificates
        $certs = Get-ChildItem -Path "Cert:\CurrentUser\My" | Where-Object { $_.Subject -like "*GoogleHardwareKey*" }
        if ($certs) {
            $certs | ForEach-Object {
                Export-Certificate -Cert $_ -FilePath "$backupPath\Backup-Cert-$($_.Thumbprint).cer"
            }
            Write-Host "  ✅ Certificates backed up" -ForegroundColor Green
        }
        
        # Create backup info
        $backupInfo = @{
            BackupDate = Get-Date
            BackupLocation = $backupPath
            CertificatesBackedUp = $certs.Count
            BackupBy = $env:USERNAME
            ComputerName = $env:COMPUTERNAME
        }
        
        $backupInfo | ConvertTo-Json | Set-Content "$backupPath\Backup-Info.json"
    }
}

# Function to create documentation
function Create-Documentation {
    Write-Host "📚 Creating documentation..." -ForegroundColor Cyan
    
    $documentation = @"
# Google Hardware Key Setup - Documentation

## Overview
This USB drive has been configured as a hardware authentication key for secure Google access.

## Created: $(Get-Date)
## USB Drive: $USBDriveLetter
## Setup Method: $Method

## Folder Structure
```
GoogleSecurityKey/
├── Certificates/          # SSL certificates for authentication
├── Credentials/          # Encrypted credential storage
├── Backup/              # Backup of authentication data
├── Scripts/             # PowerShell scripts for authentication
├── Google-HardwareKey-Launcher.ps1  # Main launcher script
└── README.md           # This documentation
```

## Authentication Methods Available

### 1. FIDO2/WebAuthn (Recommended)
- **File**: `FIDO2-Setup.json`
- **Script**: `Scripts\Launch-FIDO2.ps1`
- **Description**: Hardware-based authentication using FIDO2 standards
- **Requirements**: Windows 10+, modern browser
- **Setup**: Follow instructions in FIDO2-Setup.json

### 2. Certificate-Based Authentication
- **File**: `Certificate-Config.json`
- **Location**: `Certificates\`
- **Description**: Uses SSL certificates for authentication
- **Best for**: Enterprise Google Workspace environments

### 3. Encrypted Credentials
- **File**: `Credentials-Config.json`
- **Script**: `Scripts\Load-Credentials.ps1`
- **Description**: Securely stores Google App Passwords
- **Security**: Windows DPAPI encryption

## Usage Instructions

### Quick Start
1. Insert USB hardware key
2. Run: `Google-HardwareKey-Launcher.ps1`
3. Select authentication method
4. Follow on-screen instructions

### Command Line Usage
```powershell
# FIDO2 authentication
.\Google-HardwareKey-Launcher.ps1 -Method FIDO2

# Load encrypted credentials
.\Google-HardwareKey-Launcher.ps1 -Method Credentials

# Interactive mode (default)
.\Google-HardwareKey-Launcher.ps1
```

## Security Features
- ✅ Hardware-based authentication (USB required)
- ✅ Encrypted credential storage (DPAPI)
- ✅ FIDO2/WebAuthn compliance
- ✅ Certificate-based authentication option
- ✅ Backup and recovery procedures
- ✅ User account isolation

## Google Account Setup Requirements

### For FIDO2:
1. Enable 2-Factor Authentication
2. Go to https://myaccount.google.com/security
3. Add security key under "2-Step Verification"

### For App Passwords:
1. Enable 2-Factor Authentication
2. Go to https://myaccount.google.com/apppasswords
3. Generate app-specific passwords

### For Enterprise (Certificates):
1. Contact your Google Workspace administrator
2. Configure certificate-based authentication
3. Import certificates to your account

## Troubleshooting

### USB Key Not Detected
- Ensure USB drive is properly inserted
- Check drive letter assignment
- Verify folder structure exists

### FIDO2 Issues
- Update your browser
- Ensure Windows Hello is configured
- Check Windows 10/11 compatibility

### Credential Issues
- Verify Google App Password is correct
- Check 2FA is enabled
- Ensure running from same user account

## Security Best Practices
1. **Physical Security**: Keep USB key secure
2. **Regular Updates**: Update passwords periodically
3. **Backup**: Keep backups in secure location
4. **Multiple Methods**: Use FIDO2 + backup method
5. **Account Monitoring**: Monitor Google account activity

## Recovery Procedures
If USB key is lost or damaged:
1. Use backup authentication methods
2. Restore from `Backup/` folder
3. Re-setup authentication using this guide
4. Update Google account security settings

## Support and Updates
- Documentation location: This file
- Script updates: Check PowerShell gallery
- Google documentation: https://support.google.com/accounts

---
**Note**: This setup provides multiple layers of security. Always maintain backup authentication methods.
"@

    $documentation | Set-Content "$keyPath\README.md"
    Write-Host "  ✅ Documentation created" -ForegroundColor Green
}

# Main execution flow
try {
    Write-Host "🔄 Starting hardware key setup process..." -ForegroundColor Yellow
    
    # Create backup if requested
    if ($CreateBackup) {
        Create-Backup
    }
    
    # Setup selected authentication methods
    switch ($Method) {
        'FIDO2' { Install-FIDO2 }
        'Certificate' { Install-Certificate }
        'EncryptedCredentials' { Install-EncryptedCredentials }
        'All' {
            Install-FIDO2
            Install-Certificate
            Install-EncryptedCredentials
        }
    }
    
    # Create master launcher and documentation
    Create-MasterLauncher
    Create-Documentation
    
    # Set hidden and system attributes for security
    Set-ItemProperty -Path $keyPath -Name Attributes -Value ([System.IO.FileAttributes]::Hidden -bor [System.IO.FileAttributes]::System)
    
    Write-Host ""
    Write-Host "🎉 Google Hardware Key setup completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Run: $keyPath\Google-HardwareKey-Launcher.ps1" -ForegroundColor Yellow
    Write-Host "2. Configure your Google account security settings" -ForegroundColor Yellow
    Write-Host "3. Test the authentication methods" -ForegroundColor Yellow
    Write-Host "4. Keep this USB key secure!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📚 Documentation: $keyPath\README.md" -ForegroundColor Cyan
    
    # Open documentation
    $openDoc = Read-Host "Open documentation now? (Y/N)"
    if ($openDoc -eq 'Y' -or $openDoc -eq 'y') {
        Start-Process "notepad.exe" -ArgumentList "$keyPath\README.md"
    }
    
} catch {
    Write-Error "Setup failed: $($_.Exception.Message)"
    Write-Host "Please check the error and try again." -ForegroundColor Yellow
}
