@{
    # PSScriptAnalyzer settings for Dracula PowerShell Profile
    Severity            = @('Error', 'Warning', 'Information')
    
    # Include default rules
    IncludeDefaultRules = $true
    
    # Custom rules for PowerShell profiles
    Rules               = @{
        PSPlaceOpenBrace           = @{
            Enable             = $true
            OnSameLine         = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $false
        }
        
        PSPlaceCloseBrace          = @{
            Enable             = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $false
        }
        
        PSUseConsistentIndentation = @{
            Enable          = $true
            Kind            = 'space'
            IndentationSize = 4
        }
        
        PSUseConsistentWhitespace  = @{
            Enable          = $true
            CheckInnerBrace = $true
            CheckOpenBrace  = $true
            CheckOpenParen  = $true
            CheckOperator   = $true
            CheckPipe       = $true
            CheckSeparator  = $true
        }
        
        PSAlignAssignmentStatement = @{
            Enable         = $true
            CheckHashtable = $true
        }
        
        PSUseCorrectCasing         = @{
            Enable = $true
        }
    }
    
    # Exclude certain rules for profile scripts
    ExcludeRules        = @(
        'PSAvoidUsingWriteHost',  # Profiles commonly use Write-Host for output
        'PSAvoidGlobalVars'       # Profiles may set global variables
    )
}
