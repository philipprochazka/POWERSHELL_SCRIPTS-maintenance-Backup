# 🔐 Google Hardware Key Tasks

This module contains tasks for managing Google Hardware Keys, including setup, testing, backup, and security operations.

## 📋 Available Tasks

### Setup & Installation

#### 🔐 Setup Google Hardware Key (All Methods)
Complete hardware key setup with all authentication methods.
- Installs all supported authentication methods
- Creates automatic backup
- Configures FIDO2, OTP, and certificate authentication
- Comprehensive security setup

#### 🔑 Setup Google Hardware Key (FIDO2 Only)
FIDO2-only setup for modern authentication.
- Faster setup process
- FIDO2/WebAuthn only
- Modern security standards
- Streamlined configuration

### Testing & Validation

#### 🧪 Test Google Hardware Key
**Comprehensive testing** of hardware key functionality.
- Tests all authentication methods
- Detailed validation reporting
- Hardware compatibility check
- Security feature verification

#### 🧪 Run Google Hardware Key Tests (Pester)
**Automated testing** using Pester framework.
- Installs Pester if missing
- Runs GoogleHardwareKey.Tests.ps1
- Detailed test output
- Validation of all functions

### Information & Management

#### 📋 Google Hardware Key Info
Display detailed hardware key information.
- Shows credentials and certificates
- Hardware key status
- Configuration details
- Security settings overview

#### 🚀 Launch Google Authentication
Start Google authentication workflow.
- Interactive authentication process
- Hardware key integration
- Google account linking
- Secure authentication flow

### Backup & Security

#### 💾 Backup Google Hardware Key
Create comprehensive backup of hardware key.
- Includes certificates and credentials
- Secure backup process
- Encrypted backup storage
- Recovery preparation

#### 📜 Create Google Security Certificate
Generate new security certificates.
- 2-year validity period
- Hardware key integration
- Google-compatible certificates
- Secure certificate storage

#### 🔓 Import Google Credentials
Import and validate stored credentials.
- Shows detailed credential information
- Validates credential integrity
- Success/failure reporting
- Secure credential handling

### Maintenance & Utilities

#### 🗑️ Remove Google Hardware Key
Safely remove hardware key configuration.
- Creates backup before removal
- Removes certificates and credentials
- Clean uninstallation process
- Secure data cleanup

#### 📚 Open Google Hardware Key Documentation
Open module documentation.
- Opens README.md in notepad
- Complete usage documentation
- Setup instructions
- Troubleshooting guide

#### 🎯 Open USB Hardware Key (F:)
Quick access to hardware key drive.
- Opens F: drive in Explorer
- Checks for drive availability
- Error handling for missing drive
- Quick file access

## 🎯 Usage Workflow

### First-Time Setup
1. **Insert Hardware Key**: Connect USB hardware key to F: drive
2. **Complete Setup**: Run "🔐 Setup Google Hardware Key (All Methods)"
3. **Test Installation**: Use "🧪 Test Google Hardware Key"
4. **Create Backup**: Run "💾 Backup Google Hardware Key"

### Regular Usage
1. **Authentication**: Use "🚀 Launch Google Authentication"
2. **Check Status**: Run "📋 Google Hardware Key Info"
3. **Access Files**: Use "🎯 Open USB Hardware Key (F:)"

### Maintenance
1. **Regular Testing**: Run "🧪 Run Google Hardware Key Tests (Pester)"
2. **Update Certificates**: Use "📜 Create Google Security Certificate"
3. **Backup Updates**: Periodic "💾 Backup Google Hardware Key"

### Troubleshooting
1. **Check Documentation**: "📚 Open Google Hardware Key Documentation"
2. **Validate Setup**: "🧪 Test Google Hardware Key"
3. **Reimport Credentials**: "🔓 Import Google Credentials"

## 🔧 Requirements

### Hardware Requirements
- **USB Hardware Key**: Compatible security key
- **USB Port**: Available F: drive mapping
- **Windows Security**: Modern Windows with security features

### Software Requirements
- **PowerShell 7+**: Latest PowerShell version
- **GoogleHardwareKey Module**: Module must be available
- **Pester**: For automated testing (auto-installed)
- **Windows Credential Manager**: For secure storage

### Security Requirements
- **Administrator Privileges**: May be required for some operations
- **Network Access**: For Google authentication workflows
- **Certificate Store Access**: For certificate management

## 📁 Related Files

- `${workspaceFolder}/PowerShellModules/Google-Hardware-key/` - Main module directory
- `${workspaceFolder}/PowerShellModules/Google-Hardware-key/GoogleHardwareKey.psd1` - Module manifest
- `${workspaceFolder}/PowerShellModules/Google-Hardware-key/Tests/` - Test files
- `${workspaceFolder}/PowerShellModules/Google-Hardware-key/README.md` - Documentation
- `F:\` - Hardware key drive (configurable)

## 🛡️ Security Considerations

### Best Practices
1. **Regular Backups**: Use backup tasks frequently
2. **Test Regularly**: Validate hardware key functionality
3. **Secure Storage**: Keep backup files secure
4. **Update Certificates**: Refresh certificates before expiration

### Security Features
- **Encrypted Storage**: Credentials stored securely
- **Hardware Validation**: Physical hardware key required
- **Multi-Factor**: Combines hardware + authentication
- **Audit Trail**: Operations logged for security

## 🔍 Troubleshooting

### Common Issues
- **Drive Not Found**: Check USB connection and drive letter
- **Module Import Errors**: Verify PowerShell module path
- **Authentication Failures**: Check Google account settings
- **Permission Errors**: Run as Administrator if needed

### Diagnostic Tasks
1. **Hardware Detection**: "🎯 Open USB Hardware Key (F:)"
2. **Module Validation**: "🧪 Run Google Hardware Key Tests (Pester)"
3. **Credential Verification**: "🔓 Import Google Credentials"
4. **Complete Testing**: "🧪 Test Google Hardware Key"
