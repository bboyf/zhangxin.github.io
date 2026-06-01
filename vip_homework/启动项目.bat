@echo off
chcp 65001 >nul
echo ================================
echo   人脸识别监控系统
echo ================================
echo.
echo 正在激活虚拟环境...
call vip3-django\Scripts\activate.bat
echo.
echo 正在启动Django服务器 (端口8080)...
cd smartbox
python manage.py runserver 8080
pause

