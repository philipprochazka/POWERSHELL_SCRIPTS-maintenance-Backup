<#
.SYNOPSIS
Monitors Steam downloads and initiates a system shutdown when downloads have completed.

.DESCRIPTION
This script will check for active Steam downloads and monitor their progress. Other scripts rely on
network / disk activity however they are somewhat flawed as they don't accommodate for user intervention
or drop in network connectivity.

Providing Steam doesn't change how the registry settings work, this script should correctly identify when
downloads are active, when they have completed and when there has been user intervention.

.PARAMETER loopSleepSeconds
This is the interval timer for the loop that monitors the active download.

.PARAMETER shutdownDelaySeconds
This is the delay for system shutdown, AFTER the threshold for no download activity has been exceeded.

.PARAMETER noDownloadActivityThreshold
This is used to specify how many loop iterations of an inactive download are completed before the script is to
initiate the shutdown call.
#>

param (
    [int] $loopSleepSeconds = 60,
    [int] $shutdownDelaySeconds = 900,  # 15 minutes
    [int] $noDownloadActivityThreshold = 5
)

$STEAM_REG_PATHS = @(
    'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam',
    'HKLM:\SOFTWARE\Valve\Steam'
)
$STEAM_APPS_REG_PATH = "HKCU:\Software\Valve\Steam\Apps\*"
$STEAM_PROCESS_NAME = "steam"
$ACF_FILE_PATTERN = "appmanifest_{0}.acf"

function Get-SteamPath {

    # There should only be one return here but just in case...

    foreach ($path in $STEAM_REG_PATHS | Where-Object {Test-Path $_}) {

        $installPath = (Get-ItemProperty -Path $path -Name "InstallPath" -ErrorAction SilentlyContinue).InstallPath

        if (Test-Path -Path $installPath) {
            return $installPath
        } else {
            throw "No Steam path was detected."
        }
    }
}

function Get-ActiveDownload {
    return Get-ItemProperty -Path $STEAM_APPS_REG_PATH -Name "Updating" -ErrorAction SilentlyContinue | Where-Object {$_.Updating -eq 1}
}

function Confirm-DownloadComplete {

    param (
        [Parameter(Mandatory=$true)]
        [string] $acfPath
    )

    # User has cancelled the download and uninstalled.
    if (!(Test-Path -Path $acfPath)) {
        return $false
    }

    $acfContent = Get-Content -Path $acfPath

    $isDownloadCompleted = $false

    if ($acfContent) {

        $bytesToDownloadMatch = $acfContent | Select-String -Pattern "`"BytesToDownload`"\s+`"(\d+)`""
        $bytesDownloadedMatch = $acfContent | Select-String -Pattern "`"BytesDownloaded`"\s+`"(\d+)\`""
        
        if($bytesToDownloadMatch -and $bytesDownloadedMatch) {

            $bytesToDownload = [int] $bytesToDownloadMatch.Matches[0].Groups[1].Value
            $bytesDownloaded = [int] $bytesDownloadedMatch.Matches[0].Groups[1].Value
    
            if ($bytesToDownload -eq $bytesDownloaded) {
                $isDownloadCompleted = $true
            }
        }
    }

    return $isDownloadCompleted
}

$steamPath = Get-SteamPath
$downloadAppID = $null
$loopState = "WaitingForSteam"
$i = 0

while ($true) {

    Clear-Host

    switch ($loopState) {

        "WaitingForSteam" {

            Write-Output "Looking for Steam process..."

            if (Get-Process $STEAM_PROCESS_NAME -ErrorAction SilentlyContinue) {
                Write-Output "Steam process detected!"
                $loopState = "WaitingForDownloads"
            } else {
                Start-Sleep -Seconds 3
            }
        }

        "WaitingForDownloads" {

            $activeDownload = Get-ActiveDownload

            if ($activeDownload) {
                $downloadAppID = $activeDownload.PSChildName
                $loopState = "MonitoringDownloads"
                $i = 0
            } else {
                Write-Output "Waiting for downloads to begin..."
                Start-Sleep -Seconds 3
            }
        }

        "MonitoringDownloads" {

            $activeDownload = Get-ActiveDownload

            if ($activeDownload) {
                Write-Output "Steam client is downloading."
                $downloadAppID = $activeDownload.PSChildName
                $i = 0
            } else {
                if(Confirm-DownloadComplete -acfPath ("${steamPath}\steamapps\$ACF_FILE_PATTERN" -f $downloadAppID)) {
                    Write-Warning "There is no active download."
                    Write-Warning "$($noDownloadActivityThreshold - $i) checks remain until shutdown."
                    if ($i -ge $noDownloadActivityThreshold) {
                        Write-Output "Sending shutdown signal..."
                        shutdown /s /f /t $shutdownDelaySeconds
                        Write-Output "To cancel the shutdown, run `"shutdown /a`"."
                        $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
                        exit
                    }
                    $i++
                } else {
                    Write-Output "User intervention has been detected."
                    $loopState = "WaitingForDownloads"
                    continue
                }
            }
            Write-Output "Next check: ~$((Get-Date).AddSeconds($loopSleepSeconds).ToString('HH:mm:ss'))"
            Start-Sleep -Seconds $loopSleepSeconds
        }
    }
}