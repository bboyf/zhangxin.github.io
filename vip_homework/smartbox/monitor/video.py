import cv2
import os
from django.conf import settings

class VideoCamera(object):
    def __init__(self, rtsp):
        self.video = None
        # 处理本地摄像头地址
        if rtsp in ['0', 'localhost', '127.0.0.1']:
            rtsp = 0  # 本地摄像头索引
        self.rtsp = rtsp

    def __del__(self):
        if self.video:
            self.video.release()

    def check_online(self):
        video = cv2.VideoCapture(self.rtsp)
        success = video.read()[0]
        return success

    def get_frame(self):
        success, image = self.video.read()
        if success:
            try:
                gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
                # 使用正确的静态文件路径
                cascade_path = os.path.join(settings.BASE_DIR, 'static', 'haarcascade_frontalface_default.xml')
                if os.path.exists(cascade_path):
                    faces_classifier = cv2.CascadeClassifier(cascade_path)
                    faces = faces_classifier.detectMultiScale(gray, 1.15, 5)
                    for x, y, w, h in faces:
                        cv2.rectangle(image, (x, y), (x + w, y + h), (0, 255, 255), 2)
            except Exception as e:
                print(f"人脸检测错误: {e}")
            jpeg = cv2.imencode('.jpg', image)[1]
            return jpeg.tobytes()
        else:
            # 如果读取失败，创建一个简单的错误图像
            import numpy as np
            blank_image = np.zeros((480, 640, 3), dtype=np.uint8)
            cv2.putText(blank_image, 'Camera not available', (50, 240), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)
            jpeg = cv2.imencode('.jpg', blank_image)[1]
            return jpeg.tobytes()

    def gen(self):
        # 尝试多种方式打开摄像头
        if isinstance(self.rtsp, int):
            # 本地摄像头 - 使用 DSHOW 后端（Windows 推荐）
            self.video = cv2.VideoCapture(self.rtsp, cv2.CAP_DSHOW)
            if not self.video.isOpened():
                self.video = cv2.VideoCapture(self.rtsp)
        else:
            # RTSP 网络摄像头
            self.video = cv2.VideoCapture(self.rtsp)
        
        # 设置摄像头参数
        if self.video.isOpened():
            self.video.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
            self.video.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
            self.video.set(cv2.CAP_PROP_FPS, 30)
        
        try:
            while True:
                frame = self.get_frame()
                yield (b'--frame\r\n'
                       b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n\r\n')
        except GeneratorExit:
            pass
