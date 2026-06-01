
from django.shortcuts import render
from django.http import HttpResponse, JsonResponse,StreamingHttpResponse
from .video import VideoCamera
from .models import Camera
import redis
import cv2
from django.views.decorators import gzip
import json
import os

# 使用 dlib 预训练 ResNet 深度学习模型进行人脸识别
# 模型准确率: 99.38% (LFW数据集)
# 特征维度: 128维向量
FACE_RECOGNITION_AVAILABLE = True
print("使用 dlib ResNet 深度学习模型进行人脸识别（准确率99.38%）")

# pool = redis.ConnectionPool(host='localhost', port=6379, decode_responses=True)
# client = redis.Redis(connection_pool=pool)

def index(request):
    return render(request, 'monitor/index.html')


def real(request):
    uid=request.GET.get('uid')
    assert uid,'uid不能为空'
    camera=Camera.objects.get(uid=uid)
    rtsp=camera.rtsp
    print(rtsp)
    camera=VideoCamera(rtsp)
    return StreamingHttpResponse(camera.gen(),
                    content_type='multipart/x-mixed-replace; boundary=frame')

def camera_list(request):
    cameras=Camera.objects.all()
    result={}
    cam_list=[]
    for camera in cameras:
        temp={}
        temp['uid']=camera.uid
        temp['name']=camera.name
        temp['rtsp']=camera.rtsp
        temp['position']=camera.position
        temp['is_active']=camera.is_active
        # temp['img']=client.get(camera.uid)
        cam_list.append(temp)
    result['msg']='success'
    result['status']=1
    result['data']=cam_list
    return JsonResponse(result)

def stream_frames(uid):
    """使用OpenCV进行人脸检测和识别"""
    from django.conf import settings
    import pickle
    import numpy as np
    
    camera = Camera.objects.get(uid=uid)
    rtsp = camera.rtsp
    
    # 处理本地摄像头地址
    if rtsp in ['0', 'localhost', '127.0.0.1']:
        rtsp = 0  # 本地摄像头索引
    
    print(f"正在打开摄像头: {rtsp}")
    
    # 尝试多种方式打开摄像头
    cap = None
    if isinstance(rtsp, int):
        # 本地摄像头 - 尝试不同的后端
        print("尝试使用 CAP_DSHOW 后端...")
        cap = cv2.VideoCapture(rtsp, cv2.CAP_DSHOW)
        
        if not cap.isOpened():
            print("尝试使用默认后端...")
            cap = cv2.VideoCapture(rtsp)
        
        if not cap.isOpened():
            print("尝试其他摄像头索引...")
            for i in range(1, 3):
                print(f"  尝试索引 {i}...")
                cap = cv2.VideoCapture(i, cv2.CAP_DSHOW)
                if cap.isOpened():
                    print(f"  ✓ 成功打开索引 {i}")
                    break
    else:
        # RTSP 网络摄像头
        cap = cv2.VideoCapture(rtsp)
    
    if not cap.isOpened():
        print(f"✗ 无法打开摄像头: {rtsp}")
        print("  可能的原因：")
        print("  1. 摄像头被其他程序占用")
        print("  2. 摄像头驱动未安装")
        print("  3. 摄像头被禁用")
    else:
        print(f"✓ 摄像头已打开: {rtsp}")
        # 设置摄像头参数
        cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
        cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
        cap.set(cv2.CAP_PROP_FPS, 30)
    
    # 加载 Haar Cascade 人脸检测器
    cascade_path = os.path.join(settings.BASE_DIR, 'static', 'haarcascade_frontalface_default.xml')
    face_cascade = cv2.CascadeClassifier(cascade_path)
    
    # ==================== 已注释：特征匹配方法（效果不佳） ====================
    # 加载人脸数据库（无需训练的特征匹配）
    # database_path = os.path.join(settings.BASE_DIR, 'static', 'face_database.pkl')
    # 
    # face_database = None
    # 
    # if os.path.exists(database_path):
    #     try:
    #         with open(database_path, 'rb') as f:
    #             face_database = pickle.load(f)
    #         print(f"已加载人脸数据库，可识别 {len(face_database)} 个人")
    #         print(f"  可识别: {list(face_database.keys())}")
    #     except Exception as e:
    #         print(f"加载数据库失败: {e}")
    #         face_database = None
    # else:
    #     print(f"未找到人脸数据库，仅使用人脸检测")
    #     print(f"  运行 prepare_face_database.py 来准备数据库")
    # ==================== 特征匹配方法结束 ====================
    
    # 使用 dlib 预训练 ResNet 深度学习模型进行人脸识别
    # 该模型在 LFW 数据集上准确率达到 99.38%
    recognizer = None
    try:
        import dlib
        
        # 加载 dlib 预训练模型
        model_dir = os.path.join(settings.BASE_DIR.parent, 'vip3-django', 'Lib', 'site-packages', 'face_recognition_models', 'models')
        predictor_path = os.path.join(model_dir, 'shape_predictor_68_face_landmarks.dat')
        recognition_path = os.path.join(model_dir, 'dlib_face_recognition_resnet_model_v1.dat')
        
        if os.path.exists(predictor_path) and os.path.exists(recognition_path):
            shape_predictor = dlib.shape_predictor(predictor_path)
            face_encoder = dlib.face_recognition_model_v1(recognition_path)
            
            # 加载已知人脸特征库
            known_faces = {}
            image_dir = os.path.join(settings.BASE_DIR.parent, 'image')
            
            if os.path.exists(image_dir):
                print(f"\n加载人脸数据库（深度学习模型）...")
                for filename in os.listdir(image_dir):
                    if not filename.lower().endswith(('.jpg', '.jpeg', '.png')):
                        continue
                    
                    filepath = os.path.join(image_dir, filename)
                    name = os.path.splitext(filename)[0]
                    
                    try:
                        img = cv2.imread(filepath)
                        if img is None:
                            continue
                        
                        gray_img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
                        faces_in_img = face_cascade.detectMultiScale(gray_img, 1.1, 5, minSize=(30, 30))
                        
                        if len(faces_in_img) > 0:
                            x, y, w, h = faces_in_img[0]
                            rect = dlib.rectangle(int(x), int(y), int(x+w), int(y+h))
                            rgb_img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
                            shape = shape_predictor(rgb_img, rect)
                            # 提取 128 维人脸特征向量
                            face_descriptor = face_encoder.compute_face_descriptor(rgb_img, shape)
                            known_faces[name] = np.array(face_descriptor)
                            print(f"  ✓ {name}")
                    except Exception as e:
                        print(f"  ✗ {filename}: {e}")
                        continue
                
                print(f"✓ 已加载 {len(known_faces)} 个人脸（ResNet深度学习模型，准确率99.38%）")
                recognizer = {
                    'dlib': dlib,
                    'shape_predictor': shape_predictor,
                    'face_encoder': face_encoder,
                    'known_faces': known_faces
                }
        else:
            print("✗ 未找到 dlib 预训练模型文件")
    
    except ImportError:
        print("✗ dlib 未安装")
    except Exception as e:
        print(f"✗ 加载深度学习模型失败: {e}")
        import traceback
        traceback.print_exc()
    
    face_database = None  # 临时保留变量
    
    frame_count = 0
    while True:
        ret, frame = cap.read()
        if not ret:
            # 创建一个错误提示图像
            blank_frame = np.zeros((480, 640, 3), dtype=np.uint8)
            cv2.putText(blank_frame, 'Camera not available', (150, 240), 
                       cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)
            ret, buffer = cv2.imencode('.jpg', blank_frame)
            frame_bytes = buffer.tobytes()
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')
            break
        
        # 转换为灰度图进行人脸检测
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        # 检测人脸
        faces = face_cascade.detectMultiScale(
            gray,
            scaleFactor=1.1,
            minNeighbors=5,
            minSize=(30, 30)
        )
        
        # 处理每个检测到的人脸
        for (x, y, w, h) in faces:
            # ==================== 已注释：特征匹配识别方法 ====================
            # name = "Unknown"
            # similarity = 0.0
            # 
            # # 如果有人脸数据库，进行识别
            # if face_database is not None:
            #     try:
            #         # 提取人脸区域
            #         face_roi = gray[y:y+h, x:x+w]
            #         face_resized = cv2.resize(face_roi, (100, 100))
            #         face_equalized = cv2.equalizeHist(face_resized)
            #         
            #         # 计算直方图
            #         current_hist = cv2.calcHist([face_equalized], [0], None, [256], [0, 256])
            #         
            #         # 与数据库中的每个人脸比对
            #         best_match = None
            #         best_score = -1
            #         
            #         for person_name, person_data in face_database.items():
            #             # 方法1: 直方图相关性
            #             hist_score = cv2.compareHist(
            #                 current_hist,
            #                 person_data['histogram'],
            #                 cv2.HISTCMP_CORREL  # 相关性比较，值越大越相似
            #             )
            #             
            #             # 方法2: 模板匹配
            #             template_result = cv2.matchTemplate(
            #                 face_equalized,
            #                 person_data['face'],
            #                 cv2.TM_CCOEFF_NORMED
            #             )
            #             template_score = template_result[0][0]
            #             
            #             # 综合得分 (加权平均)
            #             combined_score = hist_score * 0.4 + template_score * 0.6
            #             
            #             if combined_score > best_score:
            #                 best_score = combined_score
            #                 best_match = person_name
            #         
            #         # 如果相似度足够高，认为是匹配的
            #         if best_score > 0.5:  # 阈值可调整 (0-1之间，越大越严格)
            #             name = best_match
            #             similarity = best_score * 100
            #             
            #     except Exception as e:
            #         print(f"识别错误: {e}")
            #         name = "Error"
            # 
            # # 根据识别结果设置颜色
            # if name != "Unknown" and name != "Error":
            #     # 识别成功 - 绿色
            #     color = (0, 255, 0)
            #     label_text = f"{name} ({similarity:.0f}%)"
            # else:
            #     # 未识别 - 黄色
            #     color = (0, 255, 255)
            #     label_text = "Unknown"
            # ==================== 特征匹配识别方法结束 ====================
            
            # 使用深度学习模型进行人脸识别
            name = "Unknown"
            confidence = 0.0
            
            if recognizer is not None:
                try:
                    # 转换为 dlib 矩形格式
                    rect = recognizer['dlib'].rectangle(int(x), int(y), int(x+w), int(y+h))
                    
                    # 转换为 RGB（dlib 需要）
                    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
                    
                    # 检测 68 个面部关键点
                    shape = recognizer['shape_predictor'](rgb_frame, rect)
                    
                    # 提取 128 维人脸特征向量
                    face_descriptor = recognizer['face_encoder'].compute_face_descriptor(rgb_frame, shape)
                    current_encoding = np.array(face_descriptor)
                    
                    # 与已知人脸比对
                    best_distance = float('inf')
                    best_match = None
                    
                    for person_name, known_encoding in recognizer['known_faces'].items():
                        # 计算欧氏距离（距离越小越相似）
                        distance = np.linalg.norm(current_encoding - known_encoding)
                        
                        if distance < best_distance:
                            best_distance = distance
                            best_match = person_name
                    
                    # 阈值判断（dlib 推荐阈值为 0.6）
                    if best_distance < 0.6:
                        name = best_match
                        confidence = max(0, (1 - best_distance) * 100)
                    
                except Exception as e:
                    print(f"识别错误: {e}")
                    name = "Error"
            
            # 设置显示颜色和标签
            if name != "Unknown" and name != "Error":
                color = (0, 255, 0)  # 识别成功 - 绿色
                label_text = f"{name} ({confidence:.1f}%)"
            else:
                color = (0, 255, 255)  # 未识别 - 黄色
                label_text = "Unknown"
            
            # 绘制矩形框
            cv2.rectangle(frame, (x, y), (x + w, y + h), color, 2)
            
            # 添加文字标签（名字）
            cv2.putText(frame, label_text, (x, y - 10), 
                       cv2.FONT_HERSHEY_SIMPLEX, 0.7, color, 2)
        
        # 在画面左上角显示检测到的人脸数量
        if len(faces) > 0:
            cv2.putText(frame, f'Faces: {len(faces)}', (10, 30), 
                       cv2.FONT_HERSHEY_SIMPLEX, 0.8, (255, 255, 255), 2)
        
        frame_count += 1
        
        # 将帧转换为JPEG格式
        ret, buffer = cv2.imencode('.jpg', frame)
        frame_bytes = buffer.tobytes()
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame_bytes + b'\r\n')
    
    cap.release()
    print(f"视频流结束，处理了 {frame_count} 帧")

@gzip.gzip_page
def video_feed(request, uid):
    response = StreamingHttpResponse(stream_frames(uid), content_type='multipart/x-mixed-replace; boundary=frame')
    return response

