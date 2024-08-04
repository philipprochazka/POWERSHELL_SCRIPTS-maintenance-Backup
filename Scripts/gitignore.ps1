# C:\backup\Powershell\Scripts\gitignore.ps1
$path = Join-Path $PSScriptRoot "..\apps\psutils\current\gitignore.ps1"
if ($MyInvocation.ExpectingInput) { $input | & $path  @args } else { & $path  @args }
exit $LASTEXITCODE