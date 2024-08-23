param (
    [switch]$libraryPaths
)

$STEAM_REG_PATHS = @(
    'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam',
    'HKLM:\SOFTWARE\Valve\Steam'
)

$steamPath = $null
$steamLibraryArray = @()
$steamGamesArray = @()
$excludedAppsArray = @(228980) # Steamworks Redistributables

# Obtain the Steam installation directory from the registry

foreach ($path in $STEAM_REG_PATHS | Where-Object {Test-Path $_}) {

    $installPath = (Get-ItemProperty -Path $path -Name "InstallPath" -ErrorAction SilentlyContinue).InstallPath

    if (Test-Path -Path $installPath) {
        $steamPath = $installPath
        break
    }
}

if (!$steamPath) {
    throw "It was not possible to identify the Steam install path."
}

# Parse the "libraryfodlers.vdf" file for the game library paths

$libraryVDFContent = Get-Content "$steamPath\steamapps\libraryfolders.vdf" -ErrorAction SilentlyContinue

if ($libraryVDFContent) {

    $strMatches = $libraryVDFContent | Select-String -Pattern '"path"\s+"([^"]+)"' -AllMatches

    if ($strMatches) {

        $strMatches | Where-Object {$_} | ForEach-Object {

            $library = $_.Matches.Groups[1] -replace '\\\\', '\'

            if (Test-Path $library) {
               $steamLibraryArray += $library
            }
        }
    }
}

if (!$steamLibraryArray) {
    throw "No valid Steam game libraries were found."
}

# Conditionally output return only the libraries if the switch is passed.

if ($libraryPaths) {

    $steamLibraryArray | ForEach-Object {
        $_
    }

    return
}

# Parse all appmanifest files within each game library

foreach ($library in $steamLibraryArray) {

    $acfManifests = Get-ChildItem -Path "$library\steamapps" -File -Filter 'appmanifest_*.acf' -ErrorAction SilentlyContinue

    foreach ($manifest in $acfManifests) {

        $manifestContent = Get-Content $manifest.FullName -ErrorAction SilentlyContinue

        if ($manifestContent) {

            $strMatches = $manifestContent | Select-String -Pattern  '"appid"\s+"([^"]+)"', '"name"\s+"([^"]+)"', '"installdir"\s+"([^"]+)"', '"SizeOnDisk"\s+"([^"]+)"'

            if ($strMatches) {
                $matchGroups = $strMatches.Matches.Groups | Where-Object {$_.Name -eq 1}
            }

            if (!($matchGroups[0].Value -in $excludedAppsArray)) {

                $steamGamesArray +=
                    [PSCustomObject]@{
                        GameID = $matchGroups[0].Value
                        Name = $matchGroups[1].Value
                        Path = "$library\steamapps\common\$($matchGroups[2].Value)"
                        SizeOnDisk = [math]::Round([int64]$matchGroups[3].Value / 1GB, 2)
                    }
            }
        }
    }
}

$steamGamesArray | Sort-Object Name