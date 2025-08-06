# ========================================
# NetworkDiscovery Module Manifest
# ========================================

@{
    # Script module or binary module file associated with this manifest.
    RootModule             = 'NetworkDiscovery.psm1'
    
    # Version number of this module.
    ModuleVersion          = '1.0.0'
    
    # Supported PSEditions
    CompatiblePSEditions   = @('Desktop', 'Core')
    
    # ID used to uniquely identify this module
    GUID                   = 'a1b2c3d4-e5f6-7890-abcd-1234567890ef'
    
    # Author of this module
    Author                 = 'UnifiedPowerShellProfile Team'
    
    # Company or vendor of this module
    CompanyName            = 'PowerShell Community'
    
    # Copyright statement for this module
    Copyright              = '© 2024 PowerShell Community. All rights reserved.'
    
    # Description of the functionality provided by this module
    Description            = 'Network Discovery Module with Ping+SMB functionality for comprehensive network enumeration and device discovery.'
    
    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion      = '5.1'
    
    # Name of the PowerShell host required by this module
    # PowerShellHostName = ''
    
    # Minimum version of the PowerShell host required by this module
    # PowerShellHostVersion = ''
    
    # Minimum version of Microsoft .NET Framework required by this module
    DotNetFrameworkVersion = '4.7.2'
    
    # Minimum version of the common language runtime (CLR) required by this module
    # ClrVersion = ''
    
    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''
    
    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules        = @(
        @{
            ModuleName    = 'NetTCPIP'
            ModuleVersion = '1.0.0.0'
        }
    )
    
    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies     = @(
        'System.Net.NetworkInformation',
        'System.DirectoryServices'
    )
    
    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()
    
    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()
    
    # Format files (.ps1xml) to be loaded when importing this module
    # FormatsToProcess = @()
    
    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()
    
    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport      = @(
        'Find-NetworkDevices',
        'Test-NetworkConnectivity',
        'Get-SMBShares'
    )
    
    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport        = @()
    
    # Variables to export from this module
    VariablesToExport      = @()
    
    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport        = @(
        'Scan-Network',
        'Test-Host',
        'Get-Shares'
    )
    
    # DSC resources to export from this module
    # DscResourcesToExport = @()
    
    # List of all modules packaged with this module
    # ModuleList = @()
    
    # List of all files packaged with this module
    FileList               = @(
        'NetworkDiscovery.psm1',
        'NetworkDiscovery.psd1',
        'README.md'
    )
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData            = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags         = @(
                'Network',
                'Discovery',
                'Ping',
                'SMB',
                'CIFS',
                'PortScan',
                'Security',
                'Administration',
                'PowerShell',
                'Windows',
                'Linux'
            )
            
            # A URL to the license for this module.
            LicenseUri   = 'https://opensource.org/licenses/MIT'
            
            # A URL to the main website for this project.
            ProjectUri   = 'https://github.com/PowerShellCommunity/NetworkDiscovery'
            
            # A URL to an icon representing this module.
            # IconUri = ''
            
            # ReleaseNotes of this module
            ReleaseNotes = @'
# NetworkDiscovery v1.0.0 Release Notes

## Features
- **Find-NetworkDevices**: Comprehensive network scanning with ping and port discovery
- **Test-NetworkConnectivity**: Detailed connectivity testing for specific hosts
- **Get-SMBShares**: SMB/CIFS share enumeration with access testing

## Key Capabilities
- Concurrent ping scanning with configurable parallelism
- Common port scanning (21, 22, 23, 25, 53, 80, 110, 135, 139, 143, 443, 445, 993, 995, 1433, 3389, 5985, 5986)
- Device type detection (Windows/SMB, Linux/Unix, Web Server, etc.)
- SMB share enumeration with anonymous and authenticated modes
- DNS resolution and reverse lookup
- Comprehensive connectivity reporting
- Performance optimized with runspace pools
- Cross-platform support (Windows PowerShell 5.1+ and PowerShell Core)

## Examples
```powershell
# Basic network discovery
Find-NetworkDevices -NetworkRange "192.168.1.0/24"

# Advanced discovery with SMB enumeration
Find-NetworkDevices -NetworkRange "10.0.0.0/16" -EnableSMBScan -MaxConcurrency 100

# Test specific host connectivity
Test-NetworkConnectivity -ComputerName "server01" -EnableSMBTest -EnableWMITest

# Enumerate SMB shares
Get-SMBShares -ComputerName "192.168.1.100" -IncludeHidden
```

## Requirements
- PowerShell 5.1 or later
- NetTCPIP module (Windows)
- Administrative privileges recommended for comprehensive scanning
'@
        }
    }
    
    # HelpInfo URI of this module
    # HelpInfoURI = ''
    
    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
}
