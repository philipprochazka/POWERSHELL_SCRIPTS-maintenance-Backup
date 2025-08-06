# PowerShell Documentation Symbolic Links Setup

## Overview
This document describes the process for creating symbolic links to PowerShell documentation files, making them easily accessible from multiple locations without duplicating the files.

## Process Summary

### 1. Identify Source Documentation
- Source location: `C:\mozilla-build`
- Contains comprehensive PowerShell `Get-ChildItem` cmdlet documentation
- Includes syntax, parameters, examples, and usage notes

### 2. Create Symbolic Link Structure
```powershell
# Create the target directory if it doesn't exist
New-Item -ItemType Directory -Path "C:\backup\Powershell\.powershell\docs" -Force

# Create symbolic link to the documentation
New-Item -ItemType SymbolicLink -Path "C:\backup\Powershell\.powershell\docs\get-childitem.md" -Target "C:\tools\Wiki\Powershell\dir\dir.md"
```

### 3. Benefits of This Approach
- **No File Duplication**: Source file remains in original location
- **Synchronized Content**: Changes to source automatically reflect in linked location
- **Easy Access**: Documentation available from PowerShell scripts directory
- **Organized Structure**: Creates logical documentation hierarchy

### 4. Verification
```powershell
# Verify the symbolic link was created successfully
Get-ChildItem -Path "C:\backup\Powershell\.powershell\docs" -Force

# Test that the link works
Get-Content "C:\backup\Powershell\.powershell\docs\get-childitem.md" | Select-Object -First 5
```

### 5. Additional Documentation Links
You can extend this pattern for other PowerShell documentation:

```powershell
# Example: Link other cmdlet documentation
New-Item -ItemType SymbolicLink -Path "C:\backup\Powershell\.powershell\docs\get-item.md" -Target "C:\tools\Wiki\Powershell\get-item\get-item.md"
New-Item -ItemType SymbolicLink -Path "C:\backup\Powershell\.powershell\docs\set-location.md" -Target "C:\tools\Wiki\Powershell\set-location\set-location.md"
```

## Requirements
- PowerShell 5.0 or later
- Administrator privileges (for creating symbolic links on Windows)
- Source documentation files must exist

## Notes
- Symbolic links on Windows require elevated privileges by default
- If the source file is moved or deleted, the symbolic link will become broken
- Use `Get-ChildItem -Force` to see symbolic links in directory listings
- The link appears as a regular file to most applications

## Related Commands
- `New-Item -ItemType SymbolicLink`: Creates symbolic links
- `Get-ChildItem -Force`: Shows hidden and system files including links
- `Get-Item`: Can show link target information
- `Remove-Item`: Removes symbolic links (doesn't affect target)

## Created
Date: July 24, 2025
Purpose: Document the process for creating symbolic links to PowerShell documentation for better organization and accessibility.
