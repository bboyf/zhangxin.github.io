@echo off
chcp 65001 >nul
echo ==========================================
echo 快速修复摄像头配置
echo ==========================================
echo.
echo 此脚本会将数据库中的 localhost 改为 0
echo.

H:\vip_homework\vip3-django\Scripts\python.exe "H:\vip_homework\快速修复摄像头.py"

echo.
echo 完成！请重启Django服务
echo.
pause

