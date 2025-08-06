@{
    # Repository-specific PowerShell module requirements
    ModuleVersion   = '1.0.0'
    GUID            = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author          = 'Repository Team'
    Description     = 'Required modules for POWERSHELL_SCRIPTS-maintenance-Backup repository'
    
    # Required modules for this repository
    RequiredModules = @(
        @{ ModuleName = 'Az.Tools.Predictor'; ModuleVersion = '1.0.0' }
        @{ ModuleName = 'Terminal-Icons'; ModuleVersion = '0.11.0' }
        @{ ModuleName = 'z'; ModuleVersion = '1.1.13' }
        @{ ModuleName = 'PSReadLine'; ModuleVersion = '2.3.4' }
        @{ ModuleName = 'PsFzf'; ModuleVersion = 'v2.6.14' }
        
        @{ModuleName = 'PSScriptAnalyzer'; ModuleVersion = '1.24.0' }
    }
)
    
# Repository-specific functions to export
FunctionsToExport = @(
    'Import-RepoModules'
    'Invoke-RepoScript'
)
    
# Repository-specific aliases
AliasesToExport   = @(
    'repo-root'
    'edit-profile'
)
}
