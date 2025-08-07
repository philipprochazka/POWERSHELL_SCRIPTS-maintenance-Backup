#*Environment Detection & Variables*
*Current-user*: `env:USERNAME`
*User-profile-path*: `env:USERPROFILE`
*OS-version*: (Get-CimInstance Win32_OperatingSystem).Caption`
  *Admin-check*: ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
*System-root*:: [string] $env:SystemRoot`

# List all environment variables
Write-Host "`n--- Environment Variables ---`n"

# Get all environment variables
$envVars = Get-ChildItem Env:

foreach ($envVar in $envVars) {
  if ($envVar.Name -eq "PATH") {
    Write-Host "`nPATH variable entries:`n"
    $paths = $envVar.Value -split ';'
    foreach ($path in $paths) {
      if ([string]::IsNullOrWhiteSpace($path)) { continue }
      if (Test-Path $path) {
        Write-Host "  $path" -ForegroundColor Green
      }
      else {
        Write-Host "  $path" -ForegroundColor Red
      }
    }
  }
  else {
    Write-Host "$($envVar.Name): $($envVar.Value)"
  }
}

# Output some key variables for reference
Write-Host "`n--- Key Variables ---"
Write-Host "Current User: $env:USERNAME"
Write-Host "User Profile Path: $env:USERPROFILE"
Write-Host "System Root: $env:SystemRoot"
Write-Host "OS Version: $((Get-CimInstance Win32_OperatingSystem).Caption)"
$adminCheck = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Write-Host "Is Administrator: $adminCheck"