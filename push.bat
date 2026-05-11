@echo off
chcp 65001 >nul

echo [git add .]
git add .
if %errorlevel% neq 0 (
    echo git add failed
    exit /b 1
)

echo [git commit -m "-"]
git commit -m "-"
if %errorlevel% neq 0 (
    echo git commit failed (possibly no changes to commit)
    exit /b 1
)

echo [git push]
git push
if %errorlevel% neq 0 (
    echo git push failed
    exit /b 1
)

echo Done!

pause