# -*- coding: utf-8 -*-
"""
快速修复摄像头配置
将数据库中的 localhost 改为 0
"""
import sqlite3
import os

db_path = r"H:\vip_homework\smartbox\db.sqlite3"

if not os.path.exists(db_path):
    print(f"✗ 数据库文件不存在: {db_path}")
    input("\n按回车键退出...")
    exit(1)

print("="*60)
print("修复摄像头配置")
print("="*60)

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # 查看当前配置
    print("\n当前摄像头配置：")
    cursor.execute("SELECT uid, name, rtsp, is_active FROM tb_camera")
    cameras = cursor.fetchall()
    
    for cam in cameras:
        uid, name, rtsp, is_active = cam
        status = "在线" if is_active == 1 else "离线"
        print(f"  - {name}: rtsp='{rtsp}', 状态={status}")
    
    # 更新本地摄像头配置
    print("\n正在更新本地摄像头配置...")
    cursor.execute("""
        UPDATE tb_camera 
        SET rtsp = '0' 
        WHERE rtsp IN ('localhost', '127.0.0.1', 'local')
    """)
    
    rows_updated = cursor.rowcount
    conn.commit()
    
    if rows_updated > 0:
        print(f"✓ 已更新 {rows_updated} 个摄像头配置")
        
        # 显示更新后的配置
        print("\n更新后的摄像头配置：")
        cursor.execute("SELECT uid, name, rtsp, is_active FROM tb_camera")
        cameras = cursor.fetchall()
        
        for cam in cameras:
            uid, name, rtsp, is_active = cam
            status = "在线" if is_active == 1 else "离线"
            print(f"  - {name}: rtsp='{rtsp}', 状态={status}")
    else:
        print("✓ 配置已经是正确的，无需更新")
    
    conn.close()
    
    print("\n" + "="*60)
    print("修复完成！")
    print("请重启Django服务以使配置生效")
    print("="*60)

except Exception as e:
    print(f"\n✗ 修复失败: {e}")
    import traceback
    traceback.print_exc()

input("\n按回车键退出...")

