# Powershell 7 main-system config
# TODO: make this a remote profile back it up to github
using namespace System.Management.Automation
using namespace System.Management.Automation.Language

# Init oh my powershell and load dracula powerline
oh-my-posh init pwsh --config 'C:\Users\philip\Documents\PowerShell\Theme\dracula.omp.json' | Invoke-Expression

# Import modules for PowerShell
Import-Module Az.Tools.Predictor
Import-Module -Name Terminal-Icons
Import-Module z

# PSReadLine configuration
Set-PSReadLineOption -Colors @{emphasis = '#ff0000'; inlinePrediction = 'Cyan'}
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle inlinePrediction + ListView

# Shows navigable menu of all options when hitting Tab
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key Alt+RightArrow -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::MoveCursor([Microsoft.PowerShell.PSConsoleReadLine+Direction]::End, 1, 0)
}
Set-PSReadLineKeyHandler -Key Alt+LeftArrow -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::MoveCursor([Microsoft.PowerShell.PSConsoleReadLine+Direction]::Start, 1, 0)
}

# Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

function l { z -ListFiles -OnlyCurrentDirectory }
function ll { z -ListFiles -Tree } 
function ls { z -ListFiles }
function cd { z -JumpPath }
function j { z -JumpPath }
function rm { z -Remove -Verbose }
function rmf { z -Remove -force }

# Variables
$GithubDir = 'C:\backup'
$LogDir = 'C:\transcripts'
$KodiDir = 'C:\Program Files\Kodi'
$StartUpDir = 'C:\backup'
$TaskbarDir = 'C:\ProgramData\Microsoft\Windows\Start Menu'
$DocDir = 'C:\Users\philip\Documents'
$PicDir = 'C:\Users\philip\Pictures'
$PicDirOld = 'E:\Obrázky'
$VideoDir = 'E:\FILMY'
$MusicDir = 'D:\Library music'
$SteamDir = 'C:\Program Files (x86)\Steam\steamapps'
$SteamDirA = 'A:\SteamLibrary\steamapps\common'
$LangDir = 'C:\Backup\Visual studio code\LangSchema'
$ScriptDir = 'C:\Backup\powershell-web-browser-management'

# Aliases
Set-Alias setep 'Set-ExecutionPolicy'

# Only set the EditMode for Windows in the user profile
if ($IsWindows) {
    Set-PSReadLineOption -EditMode Windows
}
