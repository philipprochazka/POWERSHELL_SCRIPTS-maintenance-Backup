@echo off
cd /d "c:\backup\Powershell"
git add .
git commit -m "feat: v4-Alpha XML Schema Architecture"
git branch v3-stable
git branch v4-alpha
git checkout v4-alpha
echo Branch setup complete > branch-setup-result.txt
git branch >> branch-setup-result.txt
