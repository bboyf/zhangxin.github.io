/*
 Navicat Premium Data Transfer

 Source Server         : 127.0.0.1
 Source Server Type    : MySQL
 Source Server Version : 80031 (8.0.31)
 Source Host           : localhost:3306
 Source Schema         : django003

 Target Server Type    : MySQL
 Target Server Version : 80031 (8.0.31)
 File Encoding         : 65001

 Date: 29/03/2023 15:58:02
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for auth_group
-- ----------------------------
DROP TABLE IF EXISTS `auth_group`;
CREATE TABLE `auth_group`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `name`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_group
-- ----------------------------

-- ----------------------------
-- Table structure for auth_group_permissions
-- ----------------------------
DROP TABLE IF EXISTS `auth_group_permissions`;
CREATE TABLE `auth_group_permissions`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `auth_group_permissions_group_id_permission_id_0cd325b0_uniq`(`group_id` ASC, `permission_id` ASC) USING BTREE,
  INDEX `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm`(`permission_id` ASC) USING BTREE,
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_group_permissions
-- ----------------------------

-- ----------------------------
-- Table structure for auth_permission
-- ----------------------------
DROP TABLE IF EXISTS `auth_permission`;
CREATE TABLE `auth_permission`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `content_type_id` int NOT NULL,
  `codename` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `auth_permission_content_type_id_codename_01ab375a_uniq`(`content_type_id` ASC, `codename` ASC) USING BTREE,
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 77 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_permission
-- ----------------------------
INSERT INTO `auth_permission` VALUES (1, 'Can add log entry', 1, 'add_logentry');
INSERT INTO `auth_permission` VALUES (2, 'Can change log entry', 1, 'change_logentry');
INSERT INTO `auth_permission` VALUES (3, 'Can delete log entry', 1, 'delete_logentry');
INSERT INTO `auth_permission` VALUES (4, 'Can view log entry', 1, 'view_logentry');
INSERT INTO `auth_permission` VALUES (5, 'Can add permission', 2, 'add_permission');
INSERT INTO `auth_permission` VALUES (6, 'Can change permission', 2, 'change_permission');
INSERT INTO `auth_permission` VALUES (7, 'Can delete permission', 2, 'delete_permission');
INSERT INTO `auth_permission` VALUES (8, 'Can view permission', 2, 'view_permission');
INSERT INTO `auth_permission` VALUES (9, 'Can add group', 3, 'add_group');
INSERT INTO `auth_permission` VALUES (10, 'Can change group', 3, 'change_group');
INSERT INTO `auth_permission` VALUES (11, 'Can delete group', 3, 'delete_group');
INSERT INTO `auth_permission` VALUES (12, 'Can view group', 3, 'view_group');
INSERT INTO `auth_permission` VALUES (13, 'Can add user', 4, 'add_user');
INSERT INTO `auth_permission` VALUES (14, 'Can change user', 4, 'change_user');
INSERT INTO `auth_permission` VALUES (15, 'Can delete user', 4, 'delete_user');
INSERT INTO `auth_permission` VALUES (16, 'Can view user', 4, 'view_user');
INSERT INTO `auth_permission` VALUES (17, 'Can add content type', 5, 'add_contenttype');
INSERT INTO `auth_permission` VALUES (18, 'Can change content type', 5, 'change_contenttype');
INSERT INTO `auth_permission` VALUES (19, 'Can delete content type', 5, 'delete_contenttype');
INSERT INTO `auth_permission` VALUES (20, 'Can view content type', 5, 'view_contenttype');
INSERT INTO `auth_permission` VALUES (21, 'Can add session', 6, 'add_session');
INSERT INTO `auth_permission` VALUES (22, 'Can change session', 6, 'change_session');
INSERT INTO `auth_permission` VALUES (23, 'Can delete session', 6, 'delete_session');
INSERT INTO `auth_permission` VALUES (24, 'Can view session', 6, 'view_session');
INSERT INTO `auth_permission` VALUES (25, 'Can add bme280 sof', 7, 'add_bme280sof');
INSERT INTO `auth_permission` VALUES (26, 'Can change bme280 sof', 7, 'change_bme280sof');
INSERT INTO `auth_permission` VALUES (27, 'Can delete bme280 sof', 7, 'delete_bme280sof');
INSERT INTO `auth_permission` VALUES (28, 'Can view bme280 sof', 7, 'view_bme280sof');
INSERT INTO `auth_permission` VALUES (29, 'Can add bme sds', 8, 'add_bmesds');
INSERT INTO `auth_permission` VALUES (30, 'Can change bme sds', 8, 'change_bmesds');
INSERT INTO `auth_permission` VALUES (31, 'Can delete bme sds', 8, 'delete_bmesds');
INSERT INTO `auth_permission` VALUES (32, 'Can view bme sds', 8, 'view_bmesds');
INSERT INTO `auth_permission` VALUES (33, 'Can add device info', 9, 'add_deviceinfo');
INSERT INTO `auth_permission` VALUES (34, 'Can change device info', 9, 'change_deviceinfo');
INSERT INTO `auth_permission` VALUES (35, 'Can delete device info', 9, 'delete_deviceinfo');
INSERT INTO `auth_permission` VALUES (36, 'Can view device info', 9, 'view_deviceinfo');
INSERT INTO `auth_permission` VALUES (37, 'Can add dev tem', 10, 'add_devtem');
INSERT INTO `auth_permission` VALUES (38, 'Can change dev tem', 10, 'change_devtem');
INSERT INTO `auth_permission` VALUES (39, 'Can delete dev tem', 10, 'delete_devtem');
INSERT INTO `auth_permission` VALUES (40, 'Can view dev tem', 10, 'view_devtem');
INSERT INTO `auth_permission` VALUES (41, 'Can add gydb', 11, 'add_gydb');
INSERT INTO `auth_permission` VALUES (42, 'Can change gydb', 11, 'change_gydb');
INSERT INTO `auth_permission` VALUES (43, 'Can delete gydb', 11, 'delete_gydb');
INSERT INTO `auth_permission` VALUES (44, 'Can view gydb', 11, 'view_gydb');
INSERT INTO `auth_permission` VALUES (45, 'Can add hdfs information', 12, 'add_hdfsinformation');
INSERT INTO `auth_permission` VALUES (46, 'Can change hdfs information', 12, 'change_hdfsinformation');
INSERT INTO `auth_permission` VALUES (47, 'Can delete hdfs information', 12, 'delete_hdfsinformation');
INSERT INTO `auth_permission` VALUES (48, 'Can view hdfs information', 12, 'view_hdfsinformation');
INSERT INTO `auth_permission` VALUES (49, 'Can add hdfs total', 13, 'add_hdfstotal');
INSERT INTO `auth_permission` VALUES (50, 'Can change hdfs total', 13, 'change_hdfstotal');
INSERT INTO `auth_permission` VALUES (51, 'Can delete hdfs total', 13, 'delete_hdfstotal');
INSERT INTO `auth_permission` VALUES (52, 'Can view hdfs total', 13, 'view_hdfstotal');
INSERT INTO `auth_permission` VALUES (53, 'Can add hjdb', 14, 'add_hjdb');
INSERT INTO `auth_permission` VALUES (54, 'Can change hjdb', 14, 'change_hjdb');
INSERT INTO `auth_permission` VALUES (55, 'Can delete hjdb', 14, 'delete_hjdb');
INSERT INTO `auth_permission` VALUES (56, 'Can view hjdb', 14, 'view_hjdb');
INSERT INTO `auth_permission` VALUES (57, 'Can add sds011 sof', 15, 'add_sds011sof');
INSERT INTO `auth_permission` VALUES (58, 'Can change sds011 sof', 15, 'change_sds011sof');
INSERT INTO `auth_permission` VALUES (59, 'Can delete sds011 sof', 15, 'delete_sds011sof');
INSERT INTO `auth_permission` VALUES (60, 'Can view sds011 sof', 15, 'view_sds011sof');
INSERT INTO `auth_permission` VALUES (61, 'Can add sensor count', 16, 'add_sensorcount');
INSERT INTO `auth_permission` VALUES (62, 'Can change sensor count', 16, 'change_sensorcount');
INSERT INTO `auth_permission` VALUES (63, 'Can delete sensor count', 16, 'delete_sensorcount');
INSERT INTO `auth_permission` VALUES (64, 'Can view sensor count', 16, 'view_sensorcount');
INSERT INTO `auth_permission` VALUES (65, 'Can add tem hum', 17, 'add_temhum');
INSERT INTO `auth_permission` VALUES (66, 'Can change tem hum', 17, 'change_temhum');
INSERT INTO `auth_permission` VALUES (67, 'Can delete tem hum', 17, 'delete_temhum');
INSERT INTO `auth_permission` VALUES (68, 'Can view tem hum', 17, 'view_temhum');
INSERT INTO `auth_permission` VALUES (69, 'Can add topic', 18, 'add_topic');
INSERT INTO `auth_permission` VALUES (70, 'Can change topic', 18, 'change_topic');
INSERT INTO `auth_permission` VALUES (71, 'Can delete topic', 18, 'delete_topic');
INSERT INTO `auth_permission` VALUES (72, 'Can view topic', 18, 'view_topic');
INSERT INTO `auth_permission` VALUES (73, 'Can add entry', 19, 'add_entry');
INSERT INTO `auth_permission` VALUES (74, 'Can change entry', 19, 'change_entry');
INSERT INTO `auth_permission` VALUES (75, 'Can delete entry', 19, 'delete_entry');
INSERT INTO `auth_permission` VALUES (76, 'Can view entry', 19, 'view_entry');

-- ----------------------------
-- Table structure for auth_user
-- ----------------------------
DROP TABLE IF EXISTS `auth_user`;
CREATE TABLE `auth_user`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `password` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `last_login` datetime(6) NULL DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `first_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `last_name` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `email` varchar(254) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `username`(`username` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_user
-- ----------------------------
INSERT INTO `auth_user` VALUES (1, 'pbkdf2_sha256$390000$GBIywt7pXI35C2xzLFPC0Z$Ua7IF3NVxwtHyXc5ibd8YxkosCghEoQp+5nQS5T6ZHI=', '2023-03-28 11:25:57.023780', 1, 'admin', '', '', '123456@qq.com', 1, 1, '2023-03-07 13:01:52.616651');

-- ----------------------------
-- Table structure for auth_user_groups
-- ----------------------------
DROP TABLE IF EXISTS `auth_user_groups`;
CREATE TABLE `auth_user_groups`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `auth_user_groups_user_id_group_id_94350c0c_uniq`(`user_id` ASC, `group_id` ASC) USING BTREE,
  INDEX `auth_user_groups_group_id_97559544_fk_auth_group_id`(`group_id` ASC) USING BTREE,
  CONSTRAINT `auth_user_groups_group_id_97559544_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `auth_user_groups_user_id_6a12ed8b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_user_groups
-- ----------------------------

-- ----------------------------
-- Table structure for auth_user_user_permissions
-- ----------------------------
DROP TABLE IF EXISTS `auth_user_user_permissions`;
CREATE TABLE `auth_user_user_permissions`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `auth_user_user_permissions_user_id_permission_id_14a6b632_uniq`(`user_id` ASC, `permission_id` ASC) USING BTREE,
  INDEX `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm`(`permission_id` ASC) USING BTREE,
  CONSTRAINT `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_user_user_permissions
-- ----------------------------

-- ----------------------------
-- Table structure for bme280sof
-- ----------------------------
DROP TABLE IF EXISTS `bme280sof`;
CREATE TABLE `bme280sof`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `sensor_id` int NULL DEFAULT NULL,
  `location` int NULL DEFAULT NULL,
  `lat` double NULL DEFAULT NULL,
  `lon` double NULL DEFAULT NULL,
  `timestamp` datetime(6) NULL DEFAULT NULL,
  `pressure` double NULL DEFAULT NULL,
  `temperature` double NULL DEFAULT NULL,
  `humidity` double NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bme280sof
-- ----------------------------

-- ----------------------------
-- Table structure for bme_sds
-- ----------------------------
DROP TABLE IF EXISTS `bme_sds`;
CREATE TABLE `bme_sds`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `sensor_id_bme` bigint NULL DEFAULT NULL,
  `location` bigint NULL DEFAULT NULL,
  `lat` double NULL DEFAULT NULL,
  `lon` double NULL DEFAULT NULL,
  `timestamp` datetime(6) NULL DEFAULT NULL,
  `pressure` double NULL DEFAULT NULL,
  `temperature` double NULL DEFAULT NULL,
  `humidity` double NULL DEFAULT NULL,
  `sensor_id_sds` bigint NULL DEFAULT NULL,
  `P1` double NULL DEFAULT NULL,
  `P2` double NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of bme_sds
-- ----------------------------

-- ----------------------------
-- Table structure for dev_tem
-- ----------------------------
DROP TABLE IF EXISTS `dev_tem`;
CREATE TABLE `dev_tem`  (
  `idc` int NOT NULL AUTO_INCREMENT,
  `City` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Region` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Date` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Time` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `dev_tem` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Dencode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`idc`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of dev_tem
-- ----------------------------

-- ----------------------------
-- Table structure for device_info
-- ----------------------------
DROP TABLE IF EXISTS `device_info`;
CREATE TABLE `device_info`  (
  `Idd` int NOT NULL AUTO_INCREMENT,
  `Dencode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Devname` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `City` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Region` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Longitude` double NULL DEFAULT NULL,
  `Latitude` double NULL DEFAULT NULL,
  `Sensornum` int NULL DEFAULT NULL,
  `Status` int NULL DEFAULT NULL,
  PRIMARY KEY (`Idd`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of device_info
-- ----------------------------

-- ----------------------------
-- Table structure for django_admin_log
-- ----------------------------
DROP TABLE IF EXISTS `django_admin_log`;
CREATE TABLE `django_admin_log`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `object_repr` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `action_flag` smallint UNSIGNED NOT NULL,
  `change_message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `content_type_id` int NULL DEFAULT NULL,
  `user_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `django_admin_log_content_type_id_c4bce8eb_fk_django_co`(`content_type_id` ASC) USING BTREE,
  INDEX `django_admin_log_user_id_c564eba6_fk_auth_user_id`(`user_id` ASC) USING BTREE,
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `django_admin_log_chk_1` CHECK (`action_flag` >= 0)
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_admin_log
-- ----------------------------

-- ----------------------------
-- Table structure for django_content_type
-- ----------------------------
DROP TABLE IF EXISTS `django_content_type`;
CREATE TABLE `django_content_type`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `model` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `django_content_type_app_label_model_76bd3d3b_uniq`(`app_label` ASC, `model` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_content_type
-- ----------------------------
INSERT INTO `django_content_type` VALUES (1, 'admin', 'logentry');
INSERT INTO `django_content_type` VALUES (3, 'auth', 'group');
INSERT INTO `django_content_type` VALUES (2, 'auth', 'permission');
INSERT INTO `django_content_type` VALUES (4, 'auth', 'user');
INSERT INTO `django_content_type` VALUES (5, 'contenttypes', 'contenttype');
INSERT INTO `django_content_type` VALUES (7, 'Industrial_Logs', 'bme280sof');
INSERT INTO `django_content_type` VALUES (8, 'Industrial_Logs', 'bmesds');
INSERT INTO `django_content_type` VALUES (9, 'Industrial_Logs', 'deviceinfo');
INSERT INTO `django_content_type` VALUES (10, 'Industrial_Logs', 'devtem');
INSERT INTO `django_content_type` VALUES (19, 'Industrial_Logs', 'entry');
INSERT INTO `django_content_type` VALUES (11, 'Industrial_Logs', 'gydb');
INSERT INTO `django_content_type` VALUES (12, 'Industrial_Logs', 'hdfsinformation');
INSERT INTO `django_content_type` VALUES (13, 'Industrial_Logs', 'hdfstotal');
INSERT INTO `django_content_type` VALUES (14, 'Industrial_Logs', 'hjdb');
INSERT INTO `django_content_type` VALUES (15, 'Industrial_Logs', 'sds011sof');
INSERT INTO `django_content_type` VALUES (16, 'Industrial_Logs', 'sensorcount');
INSERT INTO `django_content_type` VALUES (17, 'Industrial_Logs', 'temhum');
INSERT INTO `django_content_type` VALUES (18, 'Industrial_Logs', 'topic');
INSERT INTO `django_content_type` VALUES (6, 'sessions', 'session');

-- ----------------------------
-- Table structure for django_migrations
-- ----------------------------
DROP TABLE IF EXISTS `django_migrations`;
CREATE TABLE `django_migrations`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `app` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_migrations
-- ----------------------------
INSERT INTO `django_migrations` VALUES (1, 'contenttypes', '0001_initial', '2023-03-07 13:01:29.780916');
INSERT INTO `django_migrations` VALUES (2, 'auth', '0001_initial', '2023-03-07 13:01:30.041336');
INSERT INTO `django_migrations` VALUES (3, 'Industrial_Logs', '0001_initial', '2023-03-07 13:01:30.345908');
INSERT INTO `django_migrations` VALUES (4, 'admin', '0001_initial', '2023-03-07 13:01:30.427143');
INSERT INTO `django_migrations` VALUES (5, 'admin', '0002_logentry_remove_auto_add', '2023-03-07 13:01:30.433774');
INSERT INTO `django_migrations` VALUES (6, 'admin', '0003_logentry_add_action_flag_choices', '2023-03-07 13:01:30.440702');
INSERT INTO `django_migrations` VALUES (7, 'contenttypes', '0002_remove_content_type_name', '2023-03-07 13:01:30.492077');
INSERT INTO `django_migrations` VALUES (8, 'auth', '0002_alter_permission_name_max_length', '2023-03-07 13:01:30.525909');
INSERT INTO `django_migrations` VALUES (9, 'auth', '0003_alter_user_email_max_length', '2023-03-07 13:01:30.545325');
INSERT INTO `django_migrations` VALUES (10, 'auth', '0004_alter_user_username_opts', '2023-03-07 13:01:30.552473');
INSERT INTO `django_migrations` VALUES (11, 'auth', '0005_alter_user_last_login_null', '2023-03-07 13:01:30.587254');
INSERT INTO `django_migrations` VALUES (12, 'auth', '0006_require_contenttypes_0002', '2023-03-07 13:01:30.590261');
INSERT INTO `django_migrations` VALUES (13, 'auth', '0007_alter_validators_add_error_messages', '2023-03-07 13:01:30.599261');
INSERT INTO `django_migrations` VALUES (14, 'auth', '0008_alter_user_username_max_length', '2023-03-07 13:01:30.654692');
INSERT INTO `django_migrations` VALUES (15, 'auth', '0009_alter_user_last_name_max_length', '2023-03-07 13:01:30.697413');
INSERT INTO `django_migrations` VALUES (16, 'auth', '0010_alter_group_name_max_length', '2023-03-07 13:01:30.711410');
INSERT INTO `django_migrations` VALUES (17, 'auth', '0011_update_proxy_permissions', '2023-03-07 13:01:30.721454');
INSERT INTO `django_migrations` VALUES (18, 'auth', '0012_alter_user_first_name_max_length', '2023-03-07 13:01:30.761450');
INSERT INTO `django_migrations` VALUES (19, 'sessions', '0001_initial', '2023-03-07 13:01:30.788163');

-- ----------------------------
-- Table structure for django_session
-- ----------------------------
DROP TABLE IF EXISTS `django_session`;
CREATE TABLE `django_session`  (
  `session_key` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `session_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`) USING BTREE,
  INDEX `django_session_expire_date_a5c62663`(`expire_date` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_session
-- ----------------------------
INSERT INTO `django_session` VALUES ('2ishbyg0l8vzve7t952i0h4xypljrmlt', '.eJxVjEEOwiAQRe_C2hAoA4hL9z0DYYZBqoYmpV0Z765NutDtf-_9l4hpW2vcOi9xyuIitDj9bpjowW0H-Z7abZY0t3WZUO6KPGiX45z5eT3cv4Oaev3W1rMGww4oqBDwrDNBscAeiYw2zufBkkYaPJcCDpVi4OwxGGM8gBXvD93wN6s:1pZXRZ:hbH7kX66r4J_E9yRnRfS8-tqRsaxD4yfxqnGchbNe24', '2023-03-21 13:33:29.670240');
INSERT INTO `django_session` VALUES ('3mt1yllff5d1ljirw24ncv5qfh6w8k7c', '.eJzFVMtu2zAQ_BWDZ9t6kBLlHFPkUKC5NacqMPhY2WwkMSClQxH430NaBpowtsM8kJxW2BkOd2YFPqA1G4fterRg1kqiC5Sh-dMeZ-IOeg_Iv6zf6KXQ_WAUX3rK8oDa5bWW0F4euM8Etsxu3emCQkYwlESs0tWKV5kUpCkIUC4EznBJZV6IjIucQtOQkqcpEJCUrzDGlJDCi3bQj9Zp_XmoUc86qNHFrEY_ezlaNxJr17_0xtZo7prKjTnBDTOzhi2EMqKFCez8sNbDz5WuvDOIURhNO2EJk53qk2CGBJzSv2TiMilvouiOeDjCDTApzNjxI1O-ze9uPnuHx92th0FJj2Zpmocyv_W9Ep-R1OCF4pOa6F-SVJTFMCgcNrJQ9lr3atDmA7_pD_dl2HvC76a7E7FXOJ16wIuMO85ZmEecmzDWImyQULeux4ozsi8ic6UglXClxFXlCyX45Z3W32m3Clq5YO1wfg9OhRb5XizH9IQB_wYeX4Z_IhMPn97Df0rkCj7H9JEoY42Ga6HHtECQE1N4EbsQenMmso3R4_0rmU2cbw8tymgYWRU2yt0t2j0Cbrhr0w:1phLpR:4mijzNjB6Qiw9n-kXNybYjYYi4gvnjZEf74a3ef6Jsk', '2023-04-12 02:46:25.486082');
INSERT INTO `django_session` VALUES ('d02v2y7z0bzzpxcrdcrxserbnzpsirdt', '.eJxVjEEOwiAQRe_C2hAoA4hL9z0DYYZBqoYmpV0Z765NutDtf-_9l4hpW2vcOi9xyuIitDj9bpjowW0H-Z7abZY0t3WZUO6KPGiX45z5eT3cv4Oaev3W1rMGww4oqBDwrDNBscAeiYw2zufBkkYaPJcCDpVi4OwxGGM8gBXvD93wN6s:1ph4vj:c9JDFCJE1ldXe0JrfpBxlpvBwRe-nj_WRnhpvYpyqBA', '2023-04-11 08:43:47.177377');
INSERT INTO `django_session` VALUES ('f5wcjlcogawt796eti7idgf2sb51m9h5', '.eJxVjEEOwiAQRe_C2hAoA4hL9z0DYYZBqoYmpV0Z765NutDtf-_9l4hpW2vcOi9xyuIitDj9bpjowW0H-Z7abZY0t3WZUO6KPGiX45z5eT3cv4Oaev3W1rMGww4oqBDwrDNBscAeiYw2zufBkkYaPJcCDpVi4OwxGGM8gBXvD93wN6s:1pZpKj:JR6usyesrW-759S6lVEWHp0n_lzIcisGkvEN5cJxy2k', '2023-03-22 08:39:37.684360');
INSERT INTO `django_session` VALUES ('g0uy7isgvlrbs0btvqqizxgyg7a2n7gu', '.eJxVjEEOwiAQRe_C2hAoA4hL9z0DYYZBqoYmpV0Z765NutDtf-_9l4hpW2vcOi9xyuIitDj9bpjowW0H-Z7abZY0t3WZUO6KPGiX45z5eT3cv4Oaev3W1rMGww4oqBDwrDNBscAeiYw2zufBkkYaPJcCDpVi4OwxGGM8gBXvD93wN6s:1pc0Gh:ksUT0HzXCkVnPuyKmIaSJYrzY2Mjk-t6FKIy0zFXD9w', '2023-03-28 08:44:27.056056');
INSERT INTO `django_session` VALUES ('w5h378ovv7symja9lqcagbmias39zr09', '.eJxVjEEOwiAQRe_C2hAoA4hL9z0DYYZBqoYmpV0Z765NutDtf-_9l4hpW2vcOi9xyuIitDj9bpjowW0H-Z7abZY0t3WZUO6KPGiX45z5eT3cv4Oaev3W1rMGww4oqBDwrDNBscAeiYw2zufBkkYaPJcCDpVi4OwxGGM8gBXvD93wN6s:1pZWxE:Y1W-y866thjmIeynLKG2dnnIadpkv-1CFEnXquYJvTI', '2023-03-21 13:02:08.445580');
INSERT INTO `django_session` VALUES ('ye21ipsw27q4exxeox24ev93l79hxm4j', '.eJxVjEEOwiAQRe_C2hAoA4hL9z0DYYZBqoYmpV0Z765NutDtf-_9l4hpW2vcOi9xyuIitDj9bpjowW0H-Z7abZY0t3WZUO6KPGiX45z5eT3cv4Oaev3W1rMGww4oqBDwrDNBscAeiYw2zufBkkYaPJcCDpVi4OwxGGM8gBXvD93wN6s:1pZsdO:JRGPn1YqcdMaOpQUbBZ2croe3su7mbBSQocwTPZQsi4', '2023-03-22 12:11:06.294912');

-- ----------------------------
-- Table structure for gydb
-- ----------------------------
DROP TABLE IF EXISTS `gydb`;
CREATE TABLE `gydb`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `ambient` double NOT NULL,
  `coolant` double NOT NULL,
  `u_d` double NOT NULL,
  `u_q` double NOT NULL,
  `motor_speed` double NOT NULL,
  `torque` double NOT NULL,
  `i_d` double NOT NULL,
  `i_q` double NOT NULL,
  `pm` double NOT NULL,
  `stator_yoke` double NOT NULL,
  `stator_tooth` double NOT NULL,
  `stator_winding` double NOT NULL,
  `profile_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of gydb
-- ----------------------------

-- ----------------------------
-- Table structure for hdfs_information
-- ----------------------------
DROP TABLE IF EXISTS `hdfs_information`;
CREATE TABLE `hdfs_information`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `使用已配置容量` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `当前容量` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `DFS剩余的容量` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `DFS已使用容量` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `DFS已经使用的比率` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `处于复制下的块` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `故障副本的块` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `丢失的块` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hdfs_information
-- ----------------------------

-- ----------------------------
-- Table structure for hdfs_total
-- ----------------------------
DROP TABLE IF EXISTS `hdfs_total`;
CREATE TABLE `hdfs_total`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `集群状态健康` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `集群总共文件大小` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `集群有多少个目录` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `集群有多少个文件` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `多少个数据块` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `备份因子` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `最少复制的块数` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `没备份的块有几个` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `集群有多少数据节点` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `集群有多少机架` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hdfs_total
-- ----------------------------

-- ----------------------------
-- Table structure for hjdb
-- ----------------------------
DROP TABLE IF EXISTS `hjdb`;
CREATE TABLE `hjdb`  (
  `Idc` int NOT NULL AUTO_INCREMENT,
  `Data` date NULL DEFAULT NULL,
  `Time` time(6) NULL DEFAULT NULL,
  `Temperature` int NULL DEFAULT NULL,
  `Humidity` int NULL DEFAULT NULL,
  PRIMARY KEY (`Idc`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of hjdb
-- ----------------------------

-- ----------------------------
-- Table structure for industrial_logs_entry
-- ----------------------------
DROP TABLE IF EXISTS `industrial_logs_entry`;
CREATE TABLE `industrial_logs_entry`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `text` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `date_added` datetime(6) NOT NULL,
  `topic_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `Industrial_Logs_entr_topic_id_088f0eeb_fk_Industria`(`topic_id` ASC) USING BTREE,
  CONSTRAINT `Industrial_Logs_entr_topic_id_088f0eeb_fk_Industria` FOREIGN KEY (`topic_id`) REFERENCES `industrial_logs_topic` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of industrial_logs_entry
-- ----------------------------

-- ----------------------------
-- Table structure for industrial_logs_topic
-- ----------------------------
DROP TABLE IF EXISTS `industrial_logs_topic`;
CREATE TABLE `industrial_logs_topic`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `text` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `date_added` datetime(6) NOT NULL,
  `owner_id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `Industrial_Logs_topic_owner_id_11b52a5c_fk_auth_user_id`(`owner_id` ASC) USING BTREE,
  CONSTRAINT `Industrial_Logs_topic_owner_id_11b52a5c_fk_auth_user_id` FOREIGN KEY (`owner_id`) REFERENCES `auth_user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of industrial_logs_topic
-- ----------------------------

-- ----------------------------
-- Table structure for sds011sof
-- ----------------------------
DROP TABLE IF EXISTS `sds011sof`;
CREATE TABLE `sds011sof`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `sensor_id` int NULL DEFAULT NULL,
  `location` int NULL DEFAULT NULL,
  `lat` double NULL DEFAULT NULL,
  `lon` double NULL DEFAULT NULL,
  `timestamp` datetime(6) NULL DEFAULT NULL,
  `P1` double NULL DEFAULT NULL,
  `P2` double NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sds011sof
-- ----------------------------

-- ----------------------------
-- Table structure for sensor_count
-- ----------------------------
DROP TABLE IF EXISTS `sensor_count`;
CREATE TABLE `sensor_count`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `kind` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `count` int NULL DEFAULT NULL,
  `percent` double NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sensor_count
-- ----------------------------

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

-- ----------------------------
-- Table structure for tem_hum
-- ----------------------------
DROP TABLE IF EXISTS `tem_hum`;
CREATE TABLE `tem_hum`  (
  `Idc` int NOT NULL AUTO_INCREMENT,
  `City` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Region` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `Date` date NULL DEFAULT NULL,
  `Time` time(6) NULL DEFAULT NULL,
  `Temperature` double NULL DEFAULT NULL,
  `Humidity` double NULL DEFAULT NULL,
  `Dencode` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`Idc`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of tem_hum
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
