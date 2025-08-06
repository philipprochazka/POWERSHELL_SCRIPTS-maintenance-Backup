# 🎨 Oh My Posh Tasks

This module contains tasks for installing, configuring, and testing Oh My Posh prompt themes with modern v26+ features.

## 📋 Available Tasks

### Installation & Setup

#### 🚀 Install Modern Oh My Posh v26+
**Complete installation** of modern Oh My Posh with full features.
- Downloads and installs latest Oh My Posh v26+
- Installs complete theme collection
- Updates PowerShell profiles automatically
- Configures environment variables

#### ⚡ Install Modern Oh My Posh (Scoop)
**Scoop-based installation** for package manager users.
- Uses Scoop package manager
- Automatic dependency resolution
- Cleaner uninstallation process
- Better version management

#### 🔄 Force Reinstall Modern Oh My Posh
**Force reinstallation** to fix issues or update.
- Removes existing installation
- Clean reinstall process
- Updates all components
- Resolves configuration conflicts

### Testing & Validation

#### 🧪 Test Modern Oh My Posh (Quick)
**Quick validation** of Oh My Posh installation.
- Basic functionality testing
- Version verification
- Theme loading tests
- Essential feature validation

#### 📊 Test Modern Oh My Posh (Comprehensive)
**Comprehensive testing** with detailed reporting.
- Complete functionality testing
- Performance benchmarking
- Theme compatibility testing
- Generates detailed HTML reports

#### 🎨 Test Modern Oh My Posh Themes
**Theme-specific testing** for Dracula variants.
- Tests Dracula theme integration
- Tests Performance theme variant
- Tests Minimal theme variant
- Verbose output for troubleshooting

#### 🔧 Validate Oh My Posh Installation
**Complete installation validation** with detailed diagnostics.
- Version compatibility check
- Path and environment validation
- Theme availability verification
- UnifiedPowerShellProfile integration check

### Theme Management

#### 🎯 Initialize Modern Dracula Theme
**Interactive Dracula theme initialization**.
- Loads custom Dracula theme
- Enhanced prompt with Dracula colors
- Git integration and status indicators
- Performance-optimized configuration

#### 📋 Check Oh My Posh Version
**Version information and compatibility check**.
- Shows installed version
- Detects modern vs legacy versions
- Shows installation paths
- Environment variable verification

### Documentation & Support

#### 🌐 Open Oh My Posh Documentation
**Quick access to official documentation**.
- Opens official Oh My Posh documentation
- Windows-specific installation guide
- Configuration examples
- Troubleshooting resources

## 🎯 Usage Workflow

### First-Time Installation
1. **Install Oh My Posh**: Run "🚀 Install Modern Oh My Posh v26+"
2. **Validate Installation**: Use "🔧 Validate Oh My Posh Installation"
3. **Test Themes**: Run "🎨 Test Modern Oh My Posh Themes"
4. **Initialize Theme**: Use "🎯 Initialize Modern Dracula Theme"

### Alternative Installation (Scoop Users)
1. **Scoop Install**: Run "⚡ Install Modern Oh My Posh (Scoop)"
2. **Validate Setup**: Use "🔧 Validate Oh My Posh Installation"
3. **Test Installation**: Run "🧪 Test Modern Oh My Posh (Quick)"

### Regular Testing
1. **Quick Check**: Use "📋 Check Oh My Posh Version"
2. **Theme Testing**: Run "🎨 Test Modern Oh My Posh Themes"
3. **Comprehensive Test**: Use "📊 Test Modern Oh My Posh (Comprehensive)" monthly

### Troubleshooting
1. **Validate Installation**: "🔧 Validate Oh My Posh Installation"
2. **Check Documentation**: "🌐 Open Oh My Posh Documentation"
3. **Force Reinstall**: "🔄 Force Reinstall Modern Oh My Posh" if issues persist

## 🎨 Theme Features

### Dracula Theme Integration
- **Custom Colors**: Authentic Dracula color scheme
- **Git Integration**: Branch and status indicators
- **Performance Icons**: Visual performance indicators
- **Unicode Support**: Full diacritics and special characters

### Performance Optimizations
- **Lazy Loading**: Themes load on-demand
- **Caching**: Repeated prompts use cached data
- **Minimal Overhead**: Optimized for startup speed
- **Memory Efficient**: Low memory footprint

### Modern Features (v26+)
- **Advanced Segments**: Rich prompt segments
- **Conditional Display**: Smart visibility rules
- **Cross-Platform**: Works on Windows, Linux, macOS
- **Terminal Support**: Wide terminal compatibility

## 🔧 Requirements

### System Requirements
- **PowerShell 7+**: Latest PowerShell version recommended
- **Modern Terminal**: Windows Terminal, VS Code Terminal, or compatible
- **Unicode Support**: Terminal with Unicode/emoji support
- **Network Access**: For downloading themes and updates

### Optional Requirements
- **Scoop**: For Scoop-based installation
- **Git**: For Git status features
- **Nerd Fonts**: For enhanced icons (recommended)

### Module Dependencies
- **UnifiedPowerShellProfile**: For enhanced integration
- **Initialize-ModernOhMyPosh**: Custom initialization function

## 📁 Related Files

- `${workspaceFolder}/Install-ModernOhMyPosh.ps1` - Installation script
- `${workspaceFolder}/Test-ModernOhMyPosh.ps1` - Testing script
- `${workspaceFolder}/PowerShellModules/UnifiedPowerShellProfile/Scripts/Initialize-ModernOhMyPosh.ps1` - Initialization
- Environment variable: `POSH_THEMES_PATH` - Theme location
- Profile integration files

## 🎯 Performance Considerations

### Startup Impact
- **Modern Oh My Posh**: ~50-100ms additional startup time
- **Theme Loading**: ~10-30ms per theme initialization
- **Git Integration**: ~20-50ms for Git status (when in Git repos)

### Optimization Strategies
1. **Use Performance Theme**: Minimal theme for speed
2. **Conditional Loading**: Load only when needed
3. **Cache Configuration**: Reuse prompt data
4. **Selective Features**: Enable only required segments

## 🛡️ Migration from Legacy

### From Oh My Posh v3/v5
1. **Backup Configuration**: Save existing themes/config
2. **Uninstall Legacy**: Remove old Oh My Posh versions
3. **Clean Install**: Use "🚀 Install Modern Oh My Posh v26+"
4. **Migrate Themes**: Convert or recreate custom themes

### From Starship/Other Prompts
1. **Disable Current**: Remove existing prompt configuration
2. **Install Oh My Posh**: Use installation tasks
3. **Configure Integration**: Update PowerShell profiles
4. **Test Compatibility**: Validate with existing setup

## 🔍 Troubleshooting

### Common Issues
- **Command Not Found**: Check PATH environment variable
- **Theme Not Loading**: Verify POSH_THEMES_PATH
- **Performance Issues**: Use Performance theme variant
- **Unicode Problems**: Check terminal font and encoding

### Diagnostic Steps
1. **Version Check**: "📋 Check Oh My Posh Version"
2. **Validation**: "🔧 Validate Oh My Posh Installation"
3. **Theme Test**: "🎨 Test Modern Oh My Posh Themes"
4. **Comprehensive Test**: "📊 Test Modern Oh My Posh (Comprehensive)"

### Recovery Options
1. **Force Reinstall**: "🔄 Force Reinstall Modern Oh My Posh"
2. **Clean Installation**: Remove all components and reinstall
3. **Documentation**: "🌐 Open Oh My Posh Documentation"
4. **Alternative Installation**: Try Scoop method if direct fails
