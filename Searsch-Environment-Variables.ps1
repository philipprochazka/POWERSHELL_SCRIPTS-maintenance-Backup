*Environment Detection & Variables*
- *Current user*: `env:USERNAME`
- *User profile path*: `env:USERPROFILE`
- *OS version*: `(Get-CimInstance Win32_OperatingSystem).Caption`
- *Admin check*:
  ```powershell
  ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  ``