if (Test-Path $env:USERPROFILE\scoop) {
  scoop install clipboard -installdir "C:\tools\Clipboard"
  exit
}

Invoke-WebRequest https://nightly.link/Slackadays/Clipboard/workflows/build-clipboard/main/clipboard-windows-amd64.zip -OutFile clipboard-windows-amd64.zip
Expand-Archive clipboard-windows-amd64.zip -DestinationPath .\clipboard-windows-amd64

New-Item -ItemType Directory -Force -Path "C:\tools\Clipboard"

Copy-Item .\clipboard-windows-amd64\bin\cb.exe -Force -Destination "C:\tools\Clipboard\cb.exe"

$Old = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name path).path
$New = "$Old;C:\tools\Clipboard"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name path -Value $New

Remove-Item .\clipboard-windows-amd64.zip -Force
Remove-Item .\clipboard-windows-amd64 -Force -Recurse

Write-Host "Please restart to use CB"