# Google Hardware Key (USB) - Quick Reference Guide

## 🔐 Overview
This guide helps you set up and use a USB flash drive as a hardware authentication key for secure Google access. The solution provides multiple authentication methods including FIDO2, certificates, and encrypted credentials.

## 📋 Prerequisites
- USB flash drive (8GB+ recommended)
- Windows 10/11 with PowerShell 5.1+
- Administrator privileges
- Google account with 2FA enabled
- Modern web browser (Chrome, Edge, Firefox)

## 🚀 Quick Setup

### 1. Initial Setup
```powershell
# Basic setup with all authentication methods
.\Setup-GoogleHardwareKey.ps1 -USBDriveLetter "E:" -Method "All" -GoogleAccount "your-email@gmail.com"

# FIDO2 only setup (recommended for most users)
.\Setup-GoogleHardwareKey.ps1 -USBDriveLetter "E:" -Method "FIDO2"

# Enterprise setup with certificates
.\Setup-GoogleHardwareKey.ps1 -USBDriveLetter "E:" -Method "Certificate" -CreateBackup
```

### 2. Daily Usage
```powershell
# Launch hardware key authentication
E:\GoogleSecurityKey\Google-HardwareKey-Launcher.ps1

# Quick FIDO2 authentication
E:\GoogleSecurityKey\Google-HardwareKey-Launcher.ps1 -Method FIDO2

# Load encrypted credentials for scripts
E:\GoogleSecurityKey\Google-HardwareKey-Launcher.ps1 -Method Credentials
```

## 🔧 Management Commands

### Validation and Health Check
```powershell
# Validate hardware key integrity
.\Manage-GoogleHardwareKey.ps1 -Action Validate -USBDriveLetter "E:"

# Monitor usage and health
.\Manage-GoogleHardwareKey.ps1 -Action Monitor -USBDriveLetter "E:"
```

### Security Operations
```powershell
# Rotate credentials (recommended every 90 days)
.\Manage-GoogleHardwareKey.ps1 -Action Rotate -USBDriveLetter "E:"

# Apply additional security measures
.\Manage-GoogleHardwareKey.ps1 -Action Secure -USBDriveLetter "E:"

# Create backup/clone
.\Manage-GoogleHardwareKey.ps1 -Action Clone -USBDriveLetter "E:" -NewUSBDrive "F:"
```

### Enterprise Features
```powershell
# Setup enterprise integration
.\Manage-GoogleHardwareKey.ps1 -Action Enterprise -USBDriveLetter "E:"

# Emergency access (use only when necessary)
.\Manage-GoogleHardwareKey.ps1 -Action Emergency -USBDriveLetter "E:"
```

## 🎯 Authentication Methods

### 1. FIDO2/WebAuthn (Recommended)
- **Best for**: Personal and business accounts
- **Security**: Hardware-based, phishing-resistant
- **Setup**: Automatic with Google Account
- **Usage**: Insert USB key when prompted by browser

**Google Setup Steps**:
1. Go to https://myaccount.google.com/security
2. Click "2-Step Verification"
3. Select "Add security key"
4. Choose "USB security key"
5. Follow browser prompts

### 2. Certificate-Based Authentication
- **Best for**: Enterprise Google Workspace
- **Security**: PKI-based authentication
- **Setup**: Requires certificate import
- **Usage**: Automatic when configured

**Enterprise Setup**:
1. Generate certificate using the script
2. Export to your Google Workspace admin
3. Configure certificate-based authentication
4. Import certificate to user accounts

### 3. Encrypted Credentials
- **Best for**: Automation and scripting
- **Security**: Windows DPAPI encryption
- **Setup**: Store Google App Passwords securely
- **Usage**: Load credentials in PowerShell scripts

**Google App Password Setup**:
1. Enable 2-Factor Authentication
2. Go to https://myaccount.google.com/apppasswords
3. Generate app-specific password
4. Store using the hardware key script

## 🛡️ Security Features

### Multi-Layer Protection
- ✅ **Physical Security**: Requires USB hardware key
- ✅ **Encryption**: DPAPI for credentials, PKI for certificates
- ✅ **Access Control**: User account isolation
- ✅ **Audit Trail**: Authentication logging
- ✅ **Backup Recovery**: Multiple recovery methods

### Security Best Practices
1. **Keep USB key secure** - Treat like cash or credit card
2. **Regular rotation** - Change credentials every 90 days
3. **Multiple backup methods** - Don't rely on single method
4. **Monitor usage** - Regular health checks
5. **Emergency procedures** - Know how to recover access

## 🔄 Folder Structure
```
E:\GoogleSecurityKey\
├── Certificates\              # SSL certificates
│   ├── GoogleAuthCert.pfx    # Private certificate
│   └── GoogleAuthCert.cer    # Public certificate
├── Credentials\              # Encrypted credentials
│   └── GoogleCredentials.xml # Encrypted app passwords
├── Scripts\                  # PowerShell scripts
│   ├── Launch-FIDO2.ps1     # FIDO2 launcher
│   └── Load-Credentials.ps1  # Credential loader
├── Backup\                   # Backup data
├── Audit\                    # Usage logs (enterprise)
├── Google-HardwareKey-Launcher.ps1  # Main launcher
├── README.md                 # Documentation
├── FIDO2-Setup.json         # FIDO2 configuration
├── Certificate-Config.json  # Certificate configuration
└── Credentials-Config.json  # Credential configuration
```

## 🚨 Troubleshooting

### Common Issues

#### "USB Hardware Key not detected"
```powershell
# Check drive letter
Get-Volume | Where-Object {$_.FileSystemLabel -like "*Google*"}

# Verify folder structure
Test-Path "E:\GoogleSecurityKey\Google-HardwareKey-Launcher.ps1"

# Re-run setup if needed
.\Setup-GoogleHardwareKey.ps1 -USBDriveLetter "E:" -Method "All"
```

#### "FIDO2 authentication failed"
- Update your web browser
- Ensure Windows Hello is configured
- Check USB key is properly inserted
- Try different USB port
- Clear browser cache and cookies

#### "Certificate authentication not working"
- Verify certificate is imported to Windows Certificate Store
- Check certificate hasn't expired
- Contact your Google Workspace administrator
- Try regenerating certificate

#### "Encrypted credentials error"
- Ensure running from same user account that created them
- Check USB key is detected
- Verify Google App Password is still valid
- Re-create credentials if needed

### Recovery Procedures

#### Lost USB Key
1. Use backup authentication methods (SMS, backup codes)
2. Access Google Account security settings
3. Remove lost hardware key from account
4. Set up new hardware key
5. Update all affected applications

#### Corrupted Hardware Key
1. Run validation: `.\Manage-GoogleHardwareKey.ps1 -Action Validate`
2. If backup exists, restore from backup USB
3. If no backup, re-run setup script
4. Test all authentication methods

#### Emergency Access
1. Use Google backup codes
2. Enable emergency access: `.\Manage-GoogleHardwareKey.ps1 -Action Emergency`
3. Follow emergency procedures in documentation
4. Contact IT support if enterprise account

## 📱 Mobile and Cross-Platform

### Using with Mobile Devices
- FIDO2 works with mobile browsers
- Use Google Smart Lock for seamless experience
- QR code authentication for quick setup
- Backup authentication methods for mobile-only scenarios

### Cross-Platform Compatibility
- **Windows**: Full support (all methods)
- **macOS**: FIDO2 and certificate support
- **Linux**: FIDO2 support with compatible browsers
- **Mobile**: FIDO2 with modern browsers

## 🔗 Integration Examples

### PowerShell Script Integration
```powershell
# Load credentials for automation
$cred = & "E:\GoogleSecurityKey\Scripts\Load-Credentials.ps1"

# Use with Google APIs
Import-Module GoogleCloud
Connect-GCPAccount -Credential $cred

# Use with Gmail API
$gmail = New-GmailConnection -Credential $cred
```

### Enterprise Integration
```powershell
# Enterprise authentication with audit logging
& "E:\GoogleSecurityKey\Scripts\Enterprise-Auth.ps1" -AuditMode

# Group Policy compliance check
.\Manage-GoogleHardwareKey.ps1 -Action Monitor -USBDriveLetter "E:"
```

## 📞 Support Resources

### Documentation
- Main documentation: `E:\GoogleSecurityKey\README.md`
- Configuration files: `*-Config.json` files
- Google Help: https://support.google.com/accounts/answer/6103523

### Security Updates
- Rotate credentials every 90 days
- Monitor Google security announcements
- Update PowerShell scripts periodically
- Review access logs regularly

---

## ⚡ Quick Commands Cheat Sheet

```powershell
# Setup new hardware key
.\Setup-GoogleHardwareKey.ps1 -USBDriveLetter "E:" -Method "All"

# Daily authentication
E:\GoogleSecurityKey\Google-HardwareKey-Launcher.ps1

# Health check
.\Manage-GoogleHardwareKey.ps1 -Action Validate -USBDriveLetter "E:"

# Rotate credentials
.\Manage-GoogleHardwareKey.ps1 -Action Rotate -USBDriveLetter "E:"

# Create backup
.\Manage-GoogleHardwareKey.ps1 -Action Clone -USBDriveLetter "E:" -NewUSBDrive "F:"

# Emergency access
.\Manage-GoogleHardwareKey.ps1 -Action Emergency -USBDriveLetter "E:"
```

Remember: **Always keep your hardware key secure and maintain backup authentication methods!**
