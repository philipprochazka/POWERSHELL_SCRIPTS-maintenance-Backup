@{
    RootModule = 'UnifiedPowerShellProfile.psm1'
    ModuleVersion = '2.0.0'
    GUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author = 'Philip Rochazka'
    CompanyName = 'Personal'
    Copyright = '© 2025 Philip Rochazka. All rights reserved.'
    Description = 'Unified PowerShell Profile System with Smart Self-Linting and Quality Enforcement'
    
    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'
    
    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    ScriptsToProcess = @('Scripts\Initialize-ProfileEnvironment.ps1')
    
    # Functions to export from this module
    FunctionsToExport = @(
        'Initialize-UnifiedProfile',
        'Set-ProfileMode',
        'Get-ProfileStatus',
        'Test-ProfileConfiguration',
        'Invoke-SmartLinting',
        'Enable-RealtimeLinting',
        'Disable-RealtimeLinting',
        'Get-QualityMetrics',
        'New-VSCodeWorkspace'
    )
    
    # Cmdlets to export from this module
    CmdletsToExport = @()
    
    # Variables to export from this module
    VariablesToExport = @(
        'UnifiedProfileConfig',
        'ProfileLintingRules'
    )
    
    # Aliases to export from this module
    AliasesToExport = @(
        'profile-init',
        'profile-mode',
        'profile-status',
        'profile-test',
        'smart-lint',
        'smart-lint-async',
        'lint-on',
        'lint-off',
        'quality-check'
    )
    
    # List of all modules packaged with this module
    NestedModules = @()
    
    # Required modules
    RequiredModules = @(
        @{ ModuleName = 'PSScriptAnalyzer'; ModuleVersion = '1.20.0' },
        @{ ModuleName = 'Pester'; ModuleVersion = '5.0.0' }
    )
    
    # Modules that must be imported into the global environment prior to importing this module
    RequiredAssemblies = @()
    
    # Type files (.ps1xml) to be loaded when importing this module
    TypesToProcess = @()
    
    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess = @()
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData = @{
        PSData = @{
            Tags = @('PowerShell', 'Profile', 'Linting', 'Quality', 'PSScriptAnalyzer', 'Pester', 'Development')
            LicenseUri = ''
            ProjectUri = 'https://github.com/philipprochazka/PowerShellModules'
            IconUri = ''
            ReleaseNotes = 'v2.0.0: Smart Self-Linting PowerShell Profile with Real-time Quality Enforcement'
        }
    }
}
