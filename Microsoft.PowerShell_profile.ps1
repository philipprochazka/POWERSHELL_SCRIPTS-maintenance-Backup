# Powershell 7 main-system config
#TODO: make this a remote profile back it up to github 
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

# Init oh my powershell and load dracula powerline
oh-my-posh init pwsh --config 'C:\Users\philip\Documents\PowerShell\Theme\dracula.omp.json' | Invoke-Expression

# Import modules for powershell 
Import-Module Az.Tools.Predictor
Import-Module -Name Terminal-Icons
Import-Module z
# PSReadLine variables
Set-PSReadLineOption -Colors @{emphasis = '#ff0000'; inlinePrediction = 'Cyan'}
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle inlinePrediction + ListView
Set-PSReadLineOption -EditMode Windows
# Shows navigable menu of all options when hitting Tab
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key Alt+RightArrow -Function MoveToEndOfLine
Set-PSReadLineKeyHandler -Key Alt+LeftArrow -Function MoveToStartOfLine
Set-PSReadLineOption -EditMode Windows
# Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
# New-Alias <alias> <aliased-command>
# New-Alias open ii
Set-Alias ls "dir" 
Set-Alias l "ls"
Set-Alias ll "ls -la"
# Set-Alias cd "z"
#if ($host.Name -eq 'ConsoleHost')
#{
#    function ls_git { & 'C:\Program Files\Git\usr\bin\ls' --color=auto -hF $args }
#    Set-Alias -Name ls -Value ls_git -Option AllScope
#}

Set-PSReadLineKeyHandler -Key F7 `
                         -BriefDescription History `
                         -LongDescription 'Show command history' `
                         -ScriptBlock {
    $pattern = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$pattern, [ref]$null)
    if ($pattern)
    {
        $pattern = [regex]::Escape($pattern)
    }

    $history = [System.Collections.ArrayList]@(
        $last = ''
        $lines = ''
        foreach ($line in [System.IO.File]::ReadLines((Get-PSReadLineOption).HistorySavePath))
        {
            if ($line.EndsWith('`'))
            {
                $line = $line.Substring(0, $line.Length - 1)
                $lines = if ($lines)
                {
                    "$lines`n$line"
                }
                else
                {
                    $line
                }
                continue
            }

            if ($lines)
            {
                $line = "$lines`n$line"
                $lines = ''
            }

            if (($line -cne $last) -and (!$pattern -or ($line -match $pattern)))
            {
                $last = $line
                $line
            }
        }
    )
    $history.Reverse()

    $command = $history | Out-GridView -Title History -PassThru
    if ($command)
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($command -join "`n"))
    }
}