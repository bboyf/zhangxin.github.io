# -*- coding: utf-8 -*-
"""
测试本地摄像头是否可用
"""
import cv2

print("="*60)
print("测试本地摄像头")
print("="*60)

# 尝试打开摄像头
print("\n尝试打开摄像头索引 0...")
cap = cv2.VideoCapture(0)

if not cap.isOpened():
    print("✗ 无法打开摄像头索引 0")
    print("\n尝试其他索引...")
    
    # 尝试其他索引
    for i in range(1, 5):
        print(f"尝试索引 {i}...")
        cap = cv2.VideoCapture(i)
        if cap.isOpened():
            print(f"✓ 摄像头索引 {i} 可用！")
            break
        cap.release()
    else:
        print("\n✗ 未找到可用的摄像头")
        print("\n可能的原因：")
        print("1. 摄像头被其他程序占用")
        print("2. 摄像头驱动未安装")
        print("3. 摄像头被禁用")
        print("4. 需要管理员权限")
        input("\n按回车键退出...")
        exit(1)
else:
    print("✓ 摄像头索引 0 已打开")

# 尝试读取一帧
print("\n尝试读取视频帧...")
ret, frame = cap.read()

if ret:
    print(f"✓ 成功读取帧")
    print(f"  分辨率: {frame.shape[1]}x{frame.shape[0]}")
    print(f"  通道数: {frame.shape[2]}")
else:
    print("✗ 无法读取帧")
    cap.release()
    input("\n按回车键退出...")
    exit(1)

# 显示摄像头画面
print("\n显示摄像头画面...")
print("按 'q' 键退出")
print("="*60)

while True:
    ret, frame = cap.read()
    if not ret:
        print("无法读取帧")
        break
    
    # 显示提示信息
    cv2.putText(frame, "Press 'q' to quit", (10, 30),
                cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0, 255, 0), 2)
    
    cv2.imshow('Camera Test', frame)
    
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()

print("\n✓ 摄像头测试完成")
print("如果能看到画面，说明摄像头工作正常")
input("\n按回车键退出...")

