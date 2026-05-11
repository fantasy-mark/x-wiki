@echo off
chcp 65001 >nul

echo [git add .]
git add .
if %errorlevel% neq 0 (
    echo git add 失敗
    exit /b 1
)

echo [git commit -m "-"]
git commit -m "-"
if %errorlevel% neq 0 (
    echo git commit 失敗（可能無變更）
    exit /b 1
)

echo [git push]
git push
if %errorlevel% neq 0 (
    echo git push 失敗
    exit /b 1
)

echo 完成！

pause