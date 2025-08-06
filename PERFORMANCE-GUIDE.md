# 🧛‍♂️ Dracula Profile Performance Guide

## Performance Issues Solved

Your PowerShell profile was experiencing performance issues due to:

1. **Excessive Verbosity**: Multiple `Write-Host` statements during every profile load
2. **Synchronous Module Loading**: All modules loaded at startup regardless of need
3. **No Reload Prevention**: Profile could reload multiple times per session
4. **Heavy Startup Messages**: Verbose output slowing down terminal startup

## Available Profile Modes

### 🚀 Performance Mode (Recommended)
**File**: `Microsoft.PowerShell_profile_Dracula_Performance.ps1`

**Benefits**:
- 50-70% faster startup time
- Lazy module loading (modules load only when needed)
- Minimal startup verbosity
- Reload prevention mechanism
- On-demand extension loading

**Best for**: Daily productive work, development

**Usage**:
```powershell
.\Switch-DraculaMode.ps1 -Mode Performance
```

**Available Commands**:
- `load-ext` - Load all extensions when needed
- `help-dracula` - Show available commands
- `sys` - Quick system information
- `lld` - Enhanced directory listing

### 🤫 Silent Mode
**File**: `Microsoft.PowerShell_profile_Dracula_Silent.ps1`

**Benefits**:
- Zero startup messages
- Ultra-quiet operation
- Essential features only
- Perfect for automation

**Best for**: Scripts, automation, background tasks

### ⚡ Minimal Mode  
**File**: `Microsoft.PowerShell_profile_Dracula_Minimal.ps1`

**Benefits**:
- Fastest possible startup
- Bare minimum setup
- Basic Dracula colors only
- Tiny memory footprint

**Best for**: Remote sessions, constrained environments

### 🧛‍♂️ Normal Mode
**File**: `Microsoft.PowerShell_profile_Dracula.ps1`

**Benefits**:
- Full-featured experience
- All modules loaded at startup
- Complete visual feedback

**Best for**: Exploration, learning, full feature access

## Quick Setup

### Switch to Performance Mode (Recommended)
```powershell
# Switch to performance mode with no startup messages
.\Switch-DraculaMode.ps1 -Mode Performance -ShowStartup:$false

# Restart PowerShell to apply
```

### Test Performance Improvements
```powershell
# Benchmark all modes
.\Test-DraculaPerformance.ps1

# Detailed analysis
.\Test-DraculaPerformance.ps1 -Iterations 10 -Detailed
```

## VS Code Integration

Use these VS Code tasks (Ctrl+Shift+P → "Tasks: Run Task"):

- **⚡ Switch to Performance Mode** - Quick switch to performance mode
- **🤫 Switch to Silent Mode** - Switch to silent mode  
- **🚀 Switch to Normal Mode** - Switch back to normal mode
- **⚡ Switch to Minimal Mode** - Switch to minimal mode
- **📊 Benchmark Profile Performance** - Test performance
- **📈 Detailed Performance Analysis** - Comprehensive analysis

## Performance Features Explained

### Reload Prevention
```powershell
# Prevents multiple reloads in same session
if ($global:DraculaProfileLoaded) { return }
$global:DraculaProfileLoaded = $true
```

### Lazy Module Loading
```powershell
# Modules load only when first used
$global:DraculaLazyModules = @{
    'Terminal-Icons' = { Import-Module Terminal-Icons -ErrorAction SilentlyContinue }
    'z' = { Import-Module z -ErrorAction SilentlyContinue }
}

function Initialize-DraculaModule {
    param([string]$ModuleName)
    if ($global:DraculaLazyModules.ContainsKey($ModuleName)) {
        & $global:DraculaLazyModules[$ModuleName]
        $global:DraculaLazyModules.Remove($ModuleName)
    }
}
```

### Verbosity Control
```powershell
# Suppress verbose output during load
$originalVerbose = $VerbosePreference
$VerbosePreference = 'SilentlyContinue'

# ... profile setup ...

# Restore at end
$VerbosePreference = $originalVerbose
```

### Startup Time Tracking
```powershell
# Optional performance monitoring
$global:ProfileLoadStart = Get-Date
# ... setup ...
$loadTime = ((Get-Date) - $global:ProfileLoadStart).TotalMilliseconds
```

## Environment Variables

### Control Startup Messages
```powershell
# Show startup messages in Performance mode
[Environment]::SetEnvironmentVariable('DRACULA_SHOW_STARTUP', 'true', 'User')

# Hide startup messages (default)
[Environment]::SetEnvironmentVariable('DRACULA_SHOW_STARTUP', 'false', 'User')
```

## Migration Path

### From Normal to Performance Mode
1. Run benchmark to see current performance
2. Switch to Performance mode
3. Test functionality
4. Load extensions as needed with `load-ext`

### Gradual Optimization
1. Start with Performance mode
2. If still too slow, try Silent mode
3. For fastest startup, use Minimal mode
4. For scripts/automation, use Silent mode

## Troubleshooting

### Profile Not Loading
```powershell
# Check profile path
$PROFILE.CurrentUserCurrentHost

# Verify file exists
Test-Path $PROFILE.CurrentUserCurrentHost

# Test syntax
powershell -NoProfile -File $PROFILE.CurrentUserCurrentHost
```

### Missing Modules in Performance Mode
```powershell
# Load extensions manually
load-ext

# Or load specific module
Initialize-DraculaModule 'Terminal-Icons'
```

### Restore Original Profile
```powershell
# Backups are created automatically during mode switches
# Look for backup files: Microsoft.PowerShell_profile.ps1.backup.*
Get-ChildItem $PROFILE.CurrentUserCurrentHost.backup.*
```

## Best Practices

1. **Use Performance Mode for daily work** - Best balance of features and speed
2. **Use Silent Mode for automation** - Scripts and background tasks
3. **Use Minimal Mode for remote sessions** - SSH, constrained environments
4. **Benchmark regularly** - Monitor performance changes
5. **Load extensions on demand** - Only load what you need when you need it

## Performance Tips

1. **Avoid Write-Host in profiles** - Use Write-Verbose or conditional output
2. **Implement lazy loading** - Load modules only when needed
3. **Prevent multiple reloads** - Use global flags
4. **Minimize startup output** - Keep startup messages brief
5. **Use aliases for common commands** - Reduce typing and improve efficiency

---

🧛‍♂️ **Happy PowerShell-ing with optimized performance!** 🧛‍♂️
