# .powershell Directory Usage Guide

This directory contains repository-specific PowerShell configuration and scripts for the POWERSHELL_SCRIPTS-maintenance-Backup repository.

## Files Overview

### `pwsh.runtimeconfig.json`
- PowerShell runtime configuration
- Defines .NET framework requirements and runtime properties
- Optimized for repository-specific needs

### `profile.ps1`
- Repository-specific PowerShell profile
- Loads automatically when PowerShell starts in this repository
- Contains custom functions, aliases, and environment setup

### `modules.psd1`
- PowerShell module manifest
- Defines required modules for this repository
- Used by `init.ps1` to ensure dependencies are installed

### `init.ps1`
- Repository initialization script
- Installs required modules and loads the profile
- Run this when setting up the repository for the first time

### `scripts/`
- **`build.ps1`** - Repository build script
- **`test.ps1`** - Repository test script
- Additional utility scripts specific to this repository

## Usage

### First-time setup:
```powershell
# Run the initialization script
.\.powershell\init.ps1
```

### Load repository environment:
```powershell
# Dot-source the profile
. .\.powershell\profile.ps1
```

### Available Commands:
- `repo-root` - Navigate to repository root
- `edit-profile` - Edit the repository profile
- `Invoke-RepoScript build` - Run build script
- `Invoke-RepoScript test` - Run test script

## Benefits

1. **Isolation**: Repository-specific configuration doesn't affect global PowerShell
2. **Consistency**: All team members get the same environment
3. **Version Control**: Configuration is tracked with the code
4. **Automation**: Easy to set up development environment

## Integration with Global Profile

You can add this to your global PowerShell profile to auto-load repository environments:

```powershell
# Auto-load repository .powershell environment
if (Test-Path ".\.powershell\profile.ps1") {
    . ".\.powershell\profile.ps1"
}
```
