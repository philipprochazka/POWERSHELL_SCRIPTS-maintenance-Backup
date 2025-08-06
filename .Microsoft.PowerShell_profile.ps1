# Powershell 7 main-system config
#TODO: make this a remote profile back it up to github
using namespace System.Management.Automation
using namespace System.Management.Automation.Language
# Auto-load repository .powershell environment if it exists
if (Test-Path ".\.powershell\profile.ps1") {
    . ".\.powershell\profile.ps1"
}
# Init oh my powershell and load dracula powerline
oh-my-posh init pwsh --config '$env:backup\Powershell\Theme\dracula.omp.json' | Invoke-Expression
# Import modules folder for powershell
$env:PSModulePath += ";C:\backup\Powershell\PowerShellModules"

Import-Module Az.Tools.Predictor
Import-Module -Name Terminal-Icons
Import-Module z
# PSReadLine variables
Set-PSReadLineOption -Colors @{emphasis = '#ff0000'; inlinePrediction = 'Cyan' }
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

