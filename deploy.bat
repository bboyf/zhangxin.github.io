@echo off
chcp 65001 >nul
echo ==========================================
echo       GitHub Pages 一键发布脚本
echo ==========================================
echo.

echo [1/3] 正在添加文件...
git add -A
if errorlevel 1 (
    echo [错误] git add 失败，请检查 Git 环境。
    pause
    exit /b 1
)

echo.
set /p msg="[2/3] 请输入更新说明 (直接回车默认为 '更新网站内容'): "
if "%msg%"=="" set msg=更新网站内容
git commit -m "%msg%"
if errorlevel 1 (
    echo [提示] 没有需要提交的改动，或提交失败（上方为 Git 原始输出）。
)

echo.
echo [3/3] 正在推送到 GitHub...
git push
if errorlevel 1 (
    echo.
    echo ==========================================
    echo       发布失败：推送未成功
    echo       请检查网络、分支保护或远程冲突后重试。
    echo ==========================================
    pause
    exit /b 1
)

echo.
echo ==========================================
echo       发布成功！
echo       请等待 1-2 分钟后访问你的主页。
echo ==========================================
pause
