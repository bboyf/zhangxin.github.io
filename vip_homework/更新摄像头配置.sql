-- 更新本地摄像头配置
-- 将 localhost 改为 0，这样系统可以正确识别

UPDATE tb_camera 
SET rtsp = '0' 
WHERE rtsp IN ('localhost', '127.0.0.1');

-- 查看更新后的配置
SELECT * FROM tb_camera;

