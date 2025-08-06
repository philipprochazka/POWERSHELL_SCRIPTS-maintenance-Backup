#Requires -Version 5.1
<#
.SYNOPSIS
    Example script demonstrating Google Hardware Key usage
    
.DESCRIPTION
    This script shows practical examples of how to use your USB hardware key
    for Google authentication in various scenarios including automation,
    enterprise integration, and daily usage.
    
.PARAMETER USBDriveLetter
    Drive letter of your Google Hardware Key
    
.PARAMETER DemoType
    Type of demonstration: Basic, Automation, Enterprise, or All
    
.EXAMPLE
    .\Demo-GoogleHardwareKey.ps1 -USBDriveLetter "E:" -DemoType "Basic"
    
.EXAMPLE
    .\Demo-GoogleHardwareKey.ps1 -USBDriveLetter "E:" -DemoType "All"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[A-Z]:$')]
    [string]$USBDriveLetter,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet('Basic', 'Automation', 'Enterprise', 'All')]
    [string]$DemoType = 'Basic'
)

Write-Host "🎯 Google Hardware Key - Usage Examples" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

$keyPath = "$USBDriveLetter\GoogleSecurityKey"

# Verify hardware key is available
if (-not (Test-Path $keyPath)) {
    Write-Error "Google Hardware Key not found at $USBDriveLetter"
    Write-Host "Please run Install-GoogleHardwareKey.ps1 first" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Google Hardware Key detected at $USBDriveLetter" -ForegroundColor Green
Write-Host ""

function Demo-BasicUsage {
    Write-Host "📚 Basic Usage Demonstration" -ForegroundColor Cyan
    Write-Host "=============================" -ForegroundColor Cyan
    
    Write-Host "🔍 1. Checking available authentication methods..." -ForegroundColor Yellow
    $configs = Get-ChildItem "$keyPath\*-Config.json" -ErrorAction SilentlyContinue
    
    if ($configs.Count -eq 0) {
        Write-Host "❌ No authentication configurations found" -ForegroundColor Red
        return
    }
    
    foreach ($config in $configs) {
        $configData = Get-Content $config.FullName | ConvertFrom-Json
        Write-Host "  ✅ $($configData.Type) authentication available" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "🚀 2. Launching interactive authentication..." -ForegroundColor Yellow
    Write-Host "   This will open the main launcher script" -ForegroundColor Cyan
    
    $launch = Read-Host "Launch Google Hardware Key authentication? (Y/N)"
    if ($launch -eq 'Y' -or $launch -eq 'y') {
        & "$keyPath\Google-HardwareKey-Launcher.ps1"
    }
    
    Write-Host ""
    Write-Host "📋 3. Basic health check..." -ForegroundColor Yellow
    
    # Check USB drive health
    $usbInfo = Get-Volume -DriveLetter $USBDriveLetter.TrimEnd(':')
    Write-Host "   💾 USB Drive: $($usbInfo.FileSystemLabel)" -ForegroundColor Cyan
    Write-Host "   📊 Free Space: $([math]::Round($usbInfo.SizeRemaining / 1MB, 2)) MB" -ForegroundColor Cyan
    
    # Check file integrity
    $requiredFiles = @("Google-HardwareKey-Launcher.ps1", "README.md")
    foreach ($file in $requiredFiles) {
        if (Test-Path "$keyPath\$file") {
            Write-Host "   ✅ $file exists" -ForegroundColor Green
        } else {
            Write-Host "   ❌ $file missing" -ForegroundColor Red
        }
    }
}

function Demo-Automation {
    Write-Host "🤖 Automation Examples" -ForegroundColor Cyan
    Write-Host "======================" -ForegroundColor Cyan
    
    Write-Host "🔑 1. Loading encrypted credentials..." -ForegroundColor Yellow
    
    # Check if credentials are available
    $credConfig = "$keyPath\Credentials-Config.json"
    if (-not (Test-Path $credConfig)) {
        Write-Host "   ❌ Encrypted credentials not configured" -ForegroundColor Red
        Write-Host "   Run Install-GoogleHardwareKey.ps1 with -Method 'EncryptedCredentials'" -ForegroundColor Yellow
        return
    }
    
    Write-Host "   Loading credentials from hardware key..." -ForegroundColor Cyan
    
    try {
        # Simulate credential loading
        $credScript = "$keyPath\Scripts\Load-Credentials.ps1"
        if (Test-Path $credScript) {
            Write-Host "   ✅ Credential loader script found" -ForegroundColor Green
            Write-Host "   📋 Example usage:" -ForegroundColor Yellow
            Write-Host "      `$cred = & '$credScript'" -ForegroundColor Cyan
            Write-Host "      `$username = `$cred.UserName" -ForegroundColor Cyan
            Write-Host "      `$password = `$cred.GetNetworkCredential().Password" -ForegroundColor Cyan
        } else {
            Write-Host "   ❌ Credential loader script not found" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ Failed to load credentials: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "📧 2. Example: Automated Gmail access..." -ForegroundColor Yellow
    
    $gmailExample = @'
# Example: Automated Gmail API access with hardware key
try {
    # Load credentials from hardware key
    $cred = & "E:\GoogleSecurityKey\Scripts\Load-Credentials.ps1"
    
    if ($cred) {
        Write-Host "✅ Credentials loaded for: $($cred.UserName)" -ForegroundColor Green
        
        # Example: Connect to Gmail API (pseudo-code)
        # $gmailService = New-GmailService -Credential $cred
        # $messages = Get-GmailMessages -Service $gmailService -Query "is:unread"
        
        Write-Host "📧 Ready for Gmail API operations" -ForegroundColor Green
    }
} catch {
    Write-Error "Failed to authenticate: $($_.Exception.Message)"
}
'@
    
    Write-Host $gmailExample -ForegroundColor Cyan
    
    Write-Host ""
    Write-Host "⏰ 3. Example: Scheduled authentication..." -ForegroundColor Yellow
    
    $scheduledExample = @'
# Example: PowerShell scheduled task with hardware key
# Create scheduled task that:
# 1. Checks if USB key is present
# 2. Loads credentials
# 3. Performs automated Google operations
# 4. Logs results

$taskAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File 'C:\Scripts\AutoGoogleAuth.ps1'"
$taskTrigger = New-ScheduledTaskTrigger -Daily -At "9:00AM"
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName "GoogleHardwareKeyAuth" -Action $taskAction -Trigger $taskTrigger -Settings $taskSettings
'@
    
    Write-Host $scheduledExample -ForegroundColor Cyan
}

function Demo-Enterprise {
    Write-Host "🏢 Enterprise Integration Examples" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Cyan
    
    Write-Host "🔐 1. Certificate-based authentication..." -ForegroundColor Yellow
    
    # Check certificate configuration
    $certConfig = "$keyPath\Certificate-Config.json"
    if (Test-Path $certConfig) {
        $config = Get-Content $certConfig | ConvertFrom-Json
        Write-Host "   ✅ Certificate configuration found" -ForegroundColor Green
        Write-Host "   📋 Subject: $($config.Subject)" -ForegroundColor Cyan
        Write-Host "   📅 Expires: $($config.ExpirationDate)" -ForegroundColor Cyan
        Write-Host "   🔑 Thumbprint: $($config.CertificateThumbprint)" -ForegroundColor Cyan
    } else {
        Write-Host "   ❌ Certificate not configured" -ForegroundColor Red
        Write-Host "   Run Install-GoogleHardwareKey.ps1 with -Method 'Certificate'" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "📊 2. Audit and compliance..." -ForegroundColor Yellow
    
    # Check for enterprise configuration
    $enterpriseConfig = "$keyPath\Enterprise-Config.json"
    if (Test-Path $enterpriseConfig) {
        $config = Get-Content $enterpriseConfig | ConvertFrom-Json
        Write-Host "   ✅ Enterprise configuration found" -ForegroundColor Green
        Write-Host "   🏢 Domain: $($config.Domain)" -ForegroundColor Cyan
        Write-Host "   📧 Admin Contact: $($config.AdminContact)" -ForegroundColor Cyan
        Write-Host "   🛡️  Compliance: $($config.ComplianceStandards -join ', ')" -ForegroundColor Cyan
    } else {
        Write-Host "   ❌ Enterprise configuration not found" -ForegroundColor Red
        Write-Host "   Run: Manage-GoogleHardwareKey.ps1 -Action Enterprise" -ForegroundColor Yellow
    }
    
    # Check audit logs
    $auditPath = "$keyPath\Audit"
    if (Test-Path $auditPath) {
        $auditFiles = Get-ChildItem "$auditPath\Audit-*.json" -ErrorAction SilentlyContinue
        if ($auditFiles.Count -gt 0) {
            Write-Host "   📊 Found $($auditFiles.Count) audit log file(s)" -ForegroundColor Green
        } else {
            Write-Host "   📊 No audit logs found (enterprise mode not enabled)" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "🔧 3. Example: Enterprise authentication script..." -ForegroundColor Yellow
    
    $enterpriseExample = @'
# Example: Enterprise Google Workspace authentication
param(
    [string]$Domain = "company.com",
    [switch]$AuditMode = $true
)

# Verify hardware key and enterprise setup
$keyPath = "E:\GoogleSecurityKey"
if (-not (Test-Path "$keyPath\Enterprise-Config.json")) {
    Write-Error "Enterprise configuration not found"
    exit 1
}

# Load enterprise configuration
$enterpriseConfig = Get-Content "$keyPath\Enterprise-Config.json" | ConvertFrom-Json

Write-Host "🏢 Authenticating to Google Workspace: $($enterpriseConfig.Domain)" -ForegroundColor Cyan

# Certificate-based authentication
$certConfig = Get-Content "$keyPath\Certificate-Config.json" | ConvertFrom-Json
$cert = Get-ChildItem "Cert:\CurrentUser\My\$($certConfig.CertificateThumbprint)"

if ($cert) {
    Write-Host "✅ Certificate found: $($cert.Subject)" -ForegroundColor Green
    
    # Log authentication attempt (if audit mode enabled)
    if ($AuditMode) {
        $auditEntry = @{
            Timestamp = Get-Date
            User = $env:USERNAME
            Computer = $env:COMPUTERNAME
            Domain = $env:USERDOMAIN
            Action = "Enterprise Authentication"
            Certificate = $cert.Thumbprint
            Success = $true
        }
        
        # Save audit log
        $auditLog = "$keyPath\Audit\Enterprise-$(Get-Date -Format 'yyyyMM').json"
        # ... audit logging code ...
        
        Write-Host "📊 Audit entry logged" -ForegroundColor Green
    }
    
    # Proceed with Google Workspace authentication
    Write-Host "🔑 Proceeding with certificate-based authentication..." -ForegroundColor Green
    
} else {
    Write-Error "Certificate not found or expired"
}
'@
    
    Write-Host $enterpriseExample -ForegroundColor Cyan
}

function Demo-SecurityFeatures {
    Write-Host "🛡️ Security Features Demonstration" -ForegroundColor Cyan
    Write-Host "===================================" -ForegroundColor Cyan
    
    Write-Host "🔍 1. Integrity verification..." -ForegroundColor Yellow
    
    # Check for integrity file
    $integrityFile = "$keyPath\Integrity.json"
    if (Test-Path $integrityFile) {
        Write-Host "   ✅ Integrity verification file found" -ForegroundColor Green
        
        try {
            $integrityData = Get-Content $integrityFile | ConvertFrom-Json
            Write-Host "   📅 Created: $($integrityData.Created)" -ForegroundColor Cyan
            Write-Host "   📁 Files tracked: $($integrityData.Files.Count)" -ForegroundColor Cyan
            
            # Verify a few key files
            $criticalFiles = $integrityData.Files | Where-Object { $_.Path -like "*Launcher*" -or $_.Path -like "*Config*" } | Select-Object -First 3
            foreach ($file in $criticalFiles) {
                $fullPath = "$keyPath$($file.Path)"
                if (Test-Path $fullPath) {
                    $currentHash = Get-FileHash $fullPath -Algorithm SHA256
                    if ($currentHash.Hash -eq $file.Hash) {
                        Write-Host "   ✅ $($file.Path) - Integrity OK" -ForegroundColor Green
                    } else {
                        Write-Host "   ❌ $($file.Path) - Integrity FAILED" -ForegroundColor Red
                    }
                } else {
                    Write-Host "   ❌ $($file.Path) - File missing" -ForegroundColor Red
                }
            }
        } catch {
            Write-Host "   ❌ Failed to verify integrity: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "   ⚠️  Integrity file not found" -ForegroundColor Yellow
        Write-Host "   Run: Manage-GoogleHardwareKey.ps1 -Action Secure" -ForegroundColor Cyan
    }
    
    Write-Host ""
    Write-Host "🔐 2. Encryption status..." -ForegroundColor Yellow
    
    # Check credential encryption
    $credentialFile = "$keyPath\Credentials\GoogleCredentials.xml"
    if (Test-Path $credentialFile) {
        Write-Host "   ✅ Encrypted credentials found" -ForegroundColor Green
        Write-Host "   🔒 Encryption: Windows DPAPI" -ForegroundColor Cyan
        Write-Host "   👤 Accessible only to: $env:USERNAME" -ForegroundColor Cyan
    } else {
        Write-Host "   ⚠️  No encrypted credentials found" -ForegroundColor Yellow
    }
    
    # Check certificate security
    $certPath = "$keyPath\Certificates"
    if (Test-Path $certPath) {
        $certFiles = Get-ChildItem "$certPath\*.pfx" -ErrorAction SilentlyContinue
        if ($certFiles.Count -gt 0) {
            Write-Host "   ✅ Found $($certFiles.Count) encrypted certificate(s)" -ForegroundColor Green
            Write-Host "   🔐 Certificate protection: Password-protected PFX" -ForegroundColor Cyan
        } else {
            Write-Host "   ⚠️  No encrypted certificates found" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "🚨 3. Emergency procedures..." -ForegroundColor Yellow
    
    Write-Host "   📋 Emergency access options:" -ForegroundColor Cyan
    Write-Host "     • Google backup codes" -ForegroundColor Yellow
    Write-Host "     • SMS authentication (if configured)" -ForegroundColor Yellow
    Write-Host "     • Recovery email access" -ForegroundColor Yellow
    Write-Host "     • Hardware key cloning" -ForegroundColor Yellow
    
    $emergencyFile = "$keyPath\Emergency-Access.json"
    if (Test-Path $emergencyFile) {
        Write-Host "   ✅ Emergency access procedures documented" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  Emergency procedures not yet configured" -ForegroundColor Yellow
        Write-Host "   Run: Manage-GoogleHardwareKey.ps1 -Action Emergency" -ForegroundColor Cyan
    }
}

# Execute selected demonstration
switch ($DemoType) {
    'Basic' { 
        Demo-BasicUsage 
    }
    'Automation' { 
        Demo-Automation 
    }
    'Enterprise' { 
        Demo-Enterprise 
    }
    'All' {
        Demo-BasicUsage
        Write-Host ""
        Demo-Automation
        Write-Host ""
        Demo-Enterprise
        Write-Host ""
        Demo-SecurityFeatures
    }
}

Write-Host ""
Write-Host "🎯 Demo completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📚 Next steps:" -ForegroundColor Cyan
Write-Host "  • Review the documentation: $keyPath\README.md" -ForegroundColor Yellow
Write-Host "  • Test authentication methods: $keyPath\Google-HardwareKey-Launcher.ps1" -ForegroundColor Yellow
Write-Host "  • Set up regular maintenance: Manage-GoogleHardwareKey.ps1 -Action Monitor" -ForegroundColor Yellow
Write-Host "  • Configure backup procedures: Manage-GoogleHardwareKey.ps1 -Action Clone" -ForegroundColor Yellow
