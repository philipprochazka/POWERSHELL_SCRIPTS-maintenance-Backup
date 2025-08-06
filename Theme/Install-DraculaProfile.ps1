# =================================================================== 
# 🧛‍♂️ DRACULA PROFILE MODULE INSTALLER 🧛‍♂️
# Complete setup script for the Dracula PowerShell Profile Module
# ===================================================================

param(
    [ValidateSet('Install', 'Update', 'Uninstall', 'Test')]
    [string]$Action = 'Install',
    
    [switch]$Force,
    [switch]$Quiet
)

$ModuleName = 'DraculaProfile'
$SourcePath = Join-Path $PSScriptRoot "Modules\$ModuleName"
$TargetPath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Modules\$ModuleName"

function Write-Status {
    param([string]$Message, [string]$Color = 'Cyan')
    if (-not $Quiet) {
        Write-Host $Message -ForegroundColor $Color
    }
}

function Install-DraculaProfileModule {
    Write-Status "🧛‍♂️ Installing Dracula Profile Module..." 'Magenta'
    
    # Create target directory
    if (-not (Test-Path (Split-Path $TargetPath))) {
        New-Item -Path (Split-Path $TargetPath) -ItemType Directory -Force | Out-Null
    }
    
    # Copy module files
    if (Test-Path $TargetPath) {
        if ($Force) {
            Remove-Item $TargetPath -Recurse -Force
            Write-Status "✅ Removed existing module installation" 'Yellow'
        } else {
            throw "Module already installed. Use -Force to overwrite."
        }
    }
    
    Copy-Item $SourcePath $TargetPath -Recurse
    Write-Status "✅ Module files copied to: $TargetPath" 'Green'
    
    # Test installation
    try {
        Import-Module $ModuleName -Force
        $moduleInfo = Get-Module $ModuleName
        Write-Status "✅ Module imported successfully (Version: $($moduleInfo.Version))" 'Green'
        
        # Run basic test
        Test-DraculaProfile
        
    } catch {
        Write-Status "❌ Module installation failed: $($_.Exception.Message)" 'Red'
        throw
    }
    
    Write-Status "`n🎯 Installation Complete!" 'Green'
    Write-Status "To use the module, add this to your PowerShell profile:" 'Cyan'
    Write-Status "Import-Module DraculaProfile; Initialize-DraculaProfile" 'Yellow'
}

function Update-DraculaProfileModule {
    Write-Status "🔄 Updating Dracula Profile Module..." 'Cyan'
    
    if (-not (Test-Path $TargetPath)) {
        throw "Module not installed. Use 'Install' action first."
    }
    
    $currentVersion = (Import-PowerShellDataFile (Join-Path $TargetPath "$ModuleName.psd1")).ModuleVersion
    $newVersion = (Import-PowerShellDataFile (Join-Path $SourcePath "$ModuleName.psd1")).ModuleVersion
    
    Write-Status "Current version: $currentVersion" 'Gray'
    Write-Status "New version: $newVersion" 'Gray'
    
    # Force update
    Remove-Item $TargetPath -Recurse -Force
    Copy-Item $SourcePath $TargetPath -Recurse
    
    Write-Status "✅ Module updated successfully!" 'Green'
    
    # Test updated installation
    Import-Module $ModuleName -Force
    Test-DraculaProfile
}

function Uninstall-DraculaProfileModule {
    Write-Status "🗑️ Uninstalling Dracula Profile Module..." 'Yellow'
    
    if (Test-Path $TargetPath) {
        Remove-Item $TargetPath -Recurse -Force
        Write-Status "✅ Module uninstalled from: $TargetPath" 'Green'
    } else {
        Write-Status "⚠️ Module not found at: $TargetPath" 'Yellow'
    }
    
    # Remove from current session
    if (Get-Module $ModuleName) {
        Remove-Module $ModuleName
        Write-Status "✅ Module removed from current session" 'Green'
    }
}

function Test-DraculaProfileModule {
    Write-Status "🧪 Testing Dracula Profile Module..." 'Cyan'
    
    if (-not (Test-Path $SourcePath)) {
        throw "Source module not found at: $SourcePath"
    }
    
    # Test module manifest
    $manifest = Join-Path $SourcePath "$ModuleName.psd1"
    $moduleData = Import-PowerShellDataFile $manifest
    Write-Status "✅ Module manifest is valid (Version: $($moduleData.ModuleVersion))" 'Green'
    
    # Test module import
    Import-Module $SourcePath -Force
    Write-Status "✅ Module imports successfully" 'Green'
    
    # Test core functions
    $functions = @(
        'Initialize-DraculaProfile',
        'Initialize-MCPEnvironment',
        'Show-MCPStatus',
        'New-PowerShellScript',
        'Test-PowerShellSyntax',
        'Show-GitStatus',
        'Get-ProjectStructure'
    )
    
    foreach ($func in $functions) {
        if (Get-Command $func -ErrorAction SilentlyContinue) {
            Write-Status "✅ Function available: $func" 'Green'
        } else {
            Write-Status "❌ Function missing: $func" 'Red'
        }
    }
    
    # Test aliases
    $aliases = @('gs', 'help-dracula', 'mcp-status', 'new-script')
    foreach ($alias in $aliases) {
        if (Get-Alias $alias -ErrorAction SilentlyContinue) {
            Write-Status "✅ Alias available: $alias" 'Green'
        } else {
            Write-Status "❌ Alias missing: $alias" 'Red'
        }
    }
    
    # Run internal tests
    Test-DraculaProfile
    
    Write-Status "`n🎯 All tests completed!" 'Green'
}

# Main execution
try {
    Write-Status "`n🧛‍♂️ DRACULA PROFILE MODULE MANAGER 🧛‍♂️" 'Magenta'
    Write-Status "Action: $Action" 'Gray'
    Write-Status "Source: $SourcePath" 'Gray'
    Write-Status "Target: $TargetPath" 'Gray'
    Write-Status ""
    
    switch ($Action) {
        'Install' {
            Install-DraculaProfileModule 
        }
        'Update' {
            Update-DraculaProfileModule 
        }
        'Uninstall' {
            Uninstall-DraculaProfileModule 
        }
        'Test' {
            Test-DraculaProfileModule 
        }
    }
    
    Write-Status "`n🦇 Operation completed successfully! 🦇" 'Magenta'
    
} catch {
    Write-Status "`n❌ Operation failed: $($_.Exception.Message)" 'Red'
    exit 1
}
