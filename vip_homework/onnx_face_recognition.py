# -*- coding: utf-8 -*-
"""
基于ONNX预训练模型的人脸识别
使用轻量级ONNX Runtime + FaceNet预训练模型
准确率高，速度快，无需GPU
"""

import cv2
import numpy as np
import os
import pickle
import urllib.request

class ONNXFaceRecognizer:
    """
    ONNX人脸识别器
    使用预训练的FaceNet/ArcFace模型
    """
    
    def __init__(self, model_path=None):
        """
        初始化识别器
        """
        print("="*60)
        print("初始化 ONNX 人脸识别器")
        print("="*60)
        
        try:
            import onnxruntime as ort
            
            # 下载或加载预训练模型
            if model_path is None:
                model_path = self._download_model()
            
            # 初始化ONNX Runtime
            print(f"加载模型: {model_path}")
            self.session = ort.InferenceSession(
                model_path,
                providers=['CPUExecutionProvider']
            )
            print("✓ 模型加载成功")
            
            # 加载Haar Cascade人脸检测器
            cascade_path = r"H:\vip_homework\smartbox\static\haarcascade_frontalface_default.xml"
            self.face_cascade = cv2.CascadeClassifier(cascade_path)
            print("✓ 人脸检测器加载成功")
            
            # 加载已知人脸数据库
            self.known_faces = {}
            self.load_database()
            
        except ImportError:
            print("✗ ONNX Runtime 未安装")
            print("请运行: pip install onnxruntime")
            raise
        except Exception as e:
            print(f"✗ 初始化失败: {e}")
            raise
    
    def _download_model(self):
        """
        下载预训练的FaceNet ONNX模型
        """
        model_dir = r"H:\vip_homework\smartbox\static"
        model_path = os.path.join(model_dir, "facenet.onnx")
        
        if os.path.exists(model_path):
            print(f"使用已有模型: {model_path}")
            return model_path
        
        print("下载预训练模型...")
        # 使用一个轻量级的FaceNet模型
        model_url = "https://github.com/onnx/models/raw/main/vision/body_analysis/arcface/model/arcfaceresnet100-8.onnx"
        
        try:
            print(f"  从 {model_url} 下载...")
            urllib.request.urlretrieve(model_url, model_path)
            print(f"✓ 模型已下载: {model_path}")
        except Exception as e:
            print(f"✗ 下载失败: {e}")
            print("  请手动下载模型或使用其他方案")
            raise
        
        return model_path
    
    def _extract_features(self, face_img):
        """
        提取人脸特征向量
        
        参数:
            face_img: 人脸图像（BGR格式）
        
        返回:
            特征向量（512维）
        """
        # 预处理图像
        # 调整大小为112x112（FaceNet/ArcFace标准输入）
        face_resized = cv2.resize(face_img, (112, 112))
        
        # 转换为RGB
        face_rgb = cv2.cvtColor(face_resized, cv2.COLOR_BGR2RGB)
        
        # 归一化
        face_normalized = (face_rgb.astype(np.float32) - 127.5) / 128.0
        
        # 转换为NCHW格式 (batch, channels, height, width)
        face_transposed = np.transpose(face_normalized, (2, 0, 1))
        face_batch = np.expand_dims(face_transposed, axis=0)
        
        # 运行模型推理
        input_name = self.session.get_inputs()[0].name
        output_name = self.session.get_outputs()[0].name
        
        embedding = self.session.run([output_name], {input_name: face_batch})[0]
        
        # 归一化特征向量
        embedding_norm = embedding / np.linalg.norm(embedding)
        
        return embedding_norm.flatten()
    
    def load_database(self, image_dir=r"H:\vip_homework\image"):
        """
        从图片目录加载已知人脸
        
        参数:
            image_dir: 图片目录路径
        """
        print(f"\n从 {image_dir} 加载已知人脸...")
        
        if not os.path.exists(image_dir):
            print(f"✗ 目录不存在: {image_dir}")
            return
        
        count = 0
        for filename in os.listdir(image_dir):
            if not filename.lower().endswith(('.jpg', '.jpeg', '.png')):
                continue
            
            filepath = os.path.join(image_dir, filename)
            name = os.path.splitext(filename)[0]
            
            try:
                # 读取图片
                img = cv2.imread(filepath)
                if img is None:
                    print(f"  ✗ 无法读取: {filename}")
                    continue
                
                # 转换为灰度图进行人脸检测
                gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
                
                # 检测人脸
                faces = self.face_cascade.detectMultiScale(
                    gray,
                    scaleFactor=1.1,
                    minNeighbors=5,
                    minSize=(30, 30)
                )
                
                if len(faces) == 0:
                    print(f"  ✗ 未检测到人脸: {filename}")
                    continue
                
                # 取第一个检测到的人脸
                (x, y, w, h) = faces[0]
                face_roi = img[y:y+h, x:x+w]
                
                # 提取特征
                embedding = self._extract_features(face_roi)
                self.known_faces[name] = embedding
                
                count += 1
                print(f"  ✓ {count}. {name}")
                
            except Exception as e:
                print(f"  ✗ 处理失败 {filename}: {e}")
                continue
        
        print(f"\n共加载 {len(self.known_faces)} 个人脸")
        print("="*60)
    
    def recognize(self, frame, threshold=0.6):
        """
        识别视频帧中的人脸
        
        参数:
            frame: 视频帧（BGR格式）
            threshold: 相似度阈值（0-1），越大越严格
        
        返回:
            results: 识别结果列表
                [{
                    'bbox': [x, y, w, h],  # 人脸框坐标
                    'name': '人名',         # 识别的名字
                    'confidence': 85.5      # 置信度（0-100）
                }, ...]
        """
        results = []
        
        try:
            # 转换为灰度图进行人脸检测
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            
            # 检测人脸
            faces = self.face_cascade.detectMultiScale(
                gray,
                scaleFactor=1.1,
                minNeighbors=5,
                minSize=(30, 30)
            )
            
            for (x, y, w, h) in faces:
                # 提取人脸区域
                face_roi = frame[y:y+h, x:x+w]
                
                # 提取特征
                embedding = self._extract_features(face_roi)
                
                # 与已知人脸比对
                name = "Unknown"
                max_sim = 0.0
                
                for known_name, known_embedding in self.known_faces.items():
                    # 计算余弦相似度
                    sim = np.dot(embedding, known_embedding)
                    
                    if sim > max_sim:
                        max_sim = sim
                        if sim > threshold:
                            name = known_name
                
                results.append({
                    'bbox': [x, y, w, h],
                    'name': name,
                    'confidence': max_sim * 100
                })
        
        except Exception as e:
            print(f"识别错误: {e}")
        
        return results
    
    def save_database(self, filepath='face_embeddings_onnx.pkl'):
        """
        保存人脸数据库到文件
        
        参数:
            filepath: 保存路径
        """
        data = {
            'embeddings': self.known_faces,
            'names': list(self.known_faces.keys())
        }
        with open(filepath, 'wb') as f:
            pickle.dump(data, f)
        print(f"数据库已保存: {filepath}")


# 测试代码
if __name__ == "__main__":
    import sys
    
    print("ONNX 人脸识别器测试")
    print("="*60)
    
    try:
        # 创建识别器
        recognizer = ONNXFaceRecognizer()
        
        print("\n测试本地摄像头...")
        cap = cv2.VideoCapture(0)
        
        if not cap.isOpened():
            print("✗ 无法打开摄像头")
            sys.exit(1)
        
        print("✓ 摄像头已打开")
        print("\n按 'q' 退出，按 's' 截图保存")
        print("="*60)
        
        frame_count = 0
        while True:
            ret, frame = cap.read()
            if not ret:
                break
            
            # 识别人脸
            results = recognizer.recognize(frame)
            
            # 绘制结果
            for result in results:
                x, y, w, h = result['bbox']
                name = result['name']
                confidence = result['confidence']
                
                # 设置颜色
                color = (0, 255, 0) if name != "Unknown" else (0, 255, 255)
                
                # 绘制框
                cv2.rectangle(frame, (x, y), (x + w, y + h), color, 2)
                
                # 显示名字和置信度
                label = f"{name} ({confidence:.1f}%)"
                cv2.putText(frame, label, (x, y - 10),
                          cv2.FONT_HERSHEY_SIMPLEX, 0.7, color, 2)
            
            # 显示帧数
            frame_count += 1
            cv2.putText(frame, f"Frame: {frame_count}", (10, 30),
                       cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255, 255, 255), 2)
            
            # 显示画面
            cv2.imshow('ONNX Face Recognition Test', frame)
            
            # 按键处理
            key = cv2.waitKey(1) & 0xFF
            if key == ord('q'):
                print("\n用户退出")
                break
            elif key == ord('s'):
                filename = f"screenshot_{frame_count}.jpg"
                cv2.imwrite(filename, frame)
                print(f"截图保存: {filename}")
        
        cap.release()
        cv2.destroyAllWindows()
        print("测试完成")
        
    except Exception as e:
        print(f"\n错误: {e}")
        import traceback
        traceback.print_exc()
    
    input("\n按回车键退出...")

