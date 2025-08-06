# 🌳 UnifiedPowerShellProfile Branch Strategy

## Overview

The UnifiedPowerShellProfile project uses a multi-branch strategy to manage different versions and development streams.

## Branch Structure

### 🚀 Production Branches

- **`master`** - Main production branch
  - Stable, production-ready code
  - Tagged releases for major versions
  - Direct deployments to user systems

- **`main`** - GitHub default branch
  - Mirror of master for GitHub conventions
  - Used for GitHub Pages and documentation

### 🔧 Version Branches

- **`v3-stable`** - Stable v3 releases and maintenance
  - Contains the stable v3 PowerShell profile system
  - Bug fixes and minor enhancements for v3 users
  - Backward compatible improvements only
  - No breaking changes

- **`v4-alpha`** - v4 development with XML schema architecture
  - Active development of the new XML-based architecture
  - Features the new XML schema validation system
  - Lazy loading and performance optimizations
  - Build step tracking and recovery system
  - **Current active development branch**

### 🧪 Development Branches

- **`dev`** - General development branch
  - Integration branch for new features
  - Testing ground for experimental features
  - Merges into version branches when ready

- **`feature`** - Feature development branch
  - Specific feature development
  - Merged into dev when complete
  - Short-lived branches for specific features

## 🎯 Branch Purposes and Usage

### v3-stable Branch
```bash
# Switch to v3-stable for maintenance
git checkout v3-stable

# Make bug fixes for v3 users
# Commit and push
git push origin v3-stable
```

**Use cases:**
- Bug fixes for existing v3 installations
- Minor performance improvements
- Documentation updates for v3
- Security patches

### v4-alpha Branch  
```bash
# Switch to v4-alpha for new development
git checkout v4-alpha

# Continue XML schema development
# Commit and push
git push origin v4-alpha
```

**Use cases:**
- XML schema architecture development
- Lazy loading system enhancements
- Performance optimization work
- Build system improvements
- New features for v4

## 🔄 Workflow

### For v3 Maintenance
1. Checkout `v3-stable`
2. Make changes
3. Test thoroughly
4. Commit and push
5. Tag for release if needed

### For v4 Development
1. Checkout `v4-alpha`
2. Develop new features
3. Test with new architecture
4. Commit with descriptive messages
5. Push regularly

### For Integration
1. Merge stable features from `v4-alpha` to `dev`
2. Test integration
3. Merge to `master` when ready for release

## 📦 Release Strategy

### v3 Releases
- Semantic versioning: v3.x.y
- Bug fixes increment patch version (y)
- Minor features increment minor version (x)

### v4 Releases
- Alpha releases: v4.0.0-alpha.x
- Beta releases: v4.0.0-beta.x
- Stable release: v4.0.0

## 🚀 Current State

As of August 2025:
- **v3-stable**: Contains the stable PowerShell profile system
- **v4-alpha**: Active development with XML schema architecture
- **Features in v4-alpha**:
  - XML-based profile manifests with XSD validation
  - Runtime parser engine with PowerShell classes
  - Lazy module loading with dependency resolution
  - Performance optimization and caching system
  - Build step tracking for resumable development

## 🛠️ Setup Commands

### Create branches (if needed)
```bash
# Create v3-stable from current state
git branch v3-stable

# Create v4-alpha from current state  
git branch v4-alpha

# Switch to v4-alpha for development
git checkout v4-alpha
```

### Push branches to remote
```bash
# Push v3-stable
git push -u origin v3-stable

# Push v4-alpha
git push -u origin v4-alpha
```

## 📋 Branch Protection

Consider implementing branch protection rules:
- Require pull request reviews for `master`
- Require status checks for `v3-stable` and `v4-alpha`
- Restrict pushes to `master` to maintain stability

## 🎯 Next Steps

1. **Immediate**: Continue v4-alpha development
2. **Short-term**: Establish automated testing for both branches
3. **Medium-term**: Prepare v4 beta release
4. **Long-term**: Merge v4 stable back to master

---

🧛‍♂️ **Happy coding with the UnifiedPowerShellProfile!** 🦇
