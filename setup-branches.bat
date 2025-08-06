@echo off
cd /d "c:\backup\Powershell"

echo 🚀 Setting up version branches for UnifiedPowerShellProfile...

REM First, commit any pending changes
git add .
git commit -m "feat: v4-Alpha XML Schema Architecture + Lazy Loading System"

REM Check current status
echo.
echo 📋 Current repository status:
git branch -a
git status --short

REM Create v3-stable branch from current state (before v4 work)
echo.
echo 🔧 Creating v3-stable branch...
git branch v3-stable

REM Create v4-alpha branch for continued development
echo.
echo 🔧 Creating v4-alpha branch...
git branch v4-alpha

REM Switch to v4-alpha for continued development
echo.
echo 🔄 Switching to v4-alpha branch...
git checkout v4-alpha

REM Show final branch structure
echo.
echo ✅ Branch setup complete! Current branches:
git branch -a

echo.
echo 📋 Branch Purpose:
echo    • master      - Main production branch
echo    • v3-stable   - Stable v3 releases and maintenance
echo    • v4-alpha    - v4 development with XML schema architecture
echo    • main        - GitHub default branch
echo    • dev         - Development branch
echo    • feature     - Feature development branch

echo.
echo 🎯 You are now on v4-alpha branch for continued XML schema development!
pause
