/*
 Navicat Premium Data Transfer

 Source Server         : 127.0.0.1
 Source Server Type    : MySQL
 Source Server Version : 80031 (8.0.31)
 Source Host           : localhost:3306
 Source Schema         : monitor

 Target Server Type    : MySQL
 Target Server Version : 80031 (8.0.31)
 File Encoding         : 65001

 Date: 28/03/2023 19:35:47
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for tb_camera
-- ----------------------------
DROP TABLE IF EXISTS `tb_camera`;
CREATE TABLE `tb_camera`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `uid` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `rtsp` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `position` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `create_time` datetime(6) NOT NULL,
  `is_active` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of tb_camera
-- ----------------------------
INSERT INTO `tb_camera` VALUES (1, '59be94fa35734d158db0bcdf4c889346', 'dmeo', '0', 'localhost', '2023-03-21 10:33:38.065683', 1);
INSERT INTO `tb_camera` VALUES (2, 'fcf252ff7e804066a05da3e85267cd50', 'demo2', 'rtsp://admin:d12345678@192.168.1.108/cam/realmonitor?channel=1&subtype=0', '192.168.1.108:37777', '2023-03-21 10:57:02.414214', 0);
INSERT INTO `tb_camera` VALUES (3, '62f8b3a6af4f4a7c85c8edbe95b74b7c', 'demo3', 'rtsp://admin:d12345678@192.168.1.109/cam/realmonitor?channel=1&subtype=0', '192.168.1.109:37777', '2023-03-21 10:57:20.251035', 1);

SET FOREIGN_KEY_CHECKS = 1;
