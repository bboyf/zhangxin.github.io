@echo off
chcp 65001 >nul
echo ==========================================
echo       GitHub Pages 一键发布脚本
echo ==========================================
echo.

echo [1/3] 正在添加文件...
git add .

echo.
set /p msg="[2/3] 请输入更新说明 (直接回车默认为 '更新网站内容'): "
if "%msg%"=="" set msg=更新网站内容
git commit -m "%msg%"

echo.
echo [3/3] 正在推送到 GitHub...
git push

echo.
echo ==========================================
echo       发布成功！🎉
echo       请等待 1-2 分钟后访问你的主页。
echo ==========================================
pause