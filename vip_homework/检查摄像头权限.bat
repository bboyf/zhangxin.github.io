@echo off
chcp 65001 >nul
echo ==========================================
echo 检查摄像头权限和设置
echo ==========================================
echo.
echo 将打开以下设置：
echo 1. Windows 相机隐私设置
echo 2. 设备管理器
echo.
echo 请检查：
echo   ✓ 允许应用访问相机已开启
echo   ✓ 图像设备中摄像头状态正常
echo.
pause

echo.
echo 正在打开相机隐私设置...
start ms-settings:privacy-webcam

timeout /t 2 >nul

echo 正在打开设备管理器...
start devmgmt.msc

echo.
echo 设置窗口已打开
echo 检查完成后关闭此窗口
echo.
pause

