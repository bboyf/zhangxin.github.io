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

 Date: 22/05/2023 09:50:10
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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB AUTO_INCREMENT = 29 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

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
INSERT INTO `auth_permission` VALUES (25, 'Can add camera', 7, 'add_camera');
INSERT INTO `auth_permission` VALUES (26, 'Can change camera', 7, 'change_camera');
INSERT INTO `auth_permission` VALUES (27, 'Can delete camera', 7, 'delete_camera');
INSERT INTO `auth_permission` VALUES (28, 'Can view camera', 7, 'view_camera');

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
INSERT INTO `auth_user` VALUES (1, 'pbkdf2_sha256$390000$pTWDlAH4cLAoX0P5VbSU2I$580UHbrKvvgc4u5ZYdBpe7QTkZkuwA2SsoUC01Fbz/E=', '2023-03-27 16:40:03.093963', 1, 'admin', '', '', '123456@qq.com', 1, 1, '2023-03-07 18:52:57.623482');

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

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
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of auth_user_user_permissions
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
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_admin_log
-- ----------------------------
INSERT INTO `django_admin_log` VALUES (1, '2023-03-07 21:21:51.266796', '1', 'demo1', 1, '[{\"added\": {}}]', 7, 1);
INSERT INTO `django_admin_log` VALUES (2, '2023-03-07 21:22:36.988281', '1', 'demo1', 3, '', 7, 1);
INSERT INTO `django_admin_log` VALUES (3, '2023-03-07 21:22:58.573247', '2', 'test', 1, '[{\"added\": {}}]', 7, 1);
INSERT INTO `django_admin_log` VALUES (4, '2023-03-10 09:27:31.542822', '2', 'test', 3, '', 7, 1);
INSERT INTO `django_admin_log` VALUES (5, '2023-03-10 09:27:56.528711', '3', 'test', 1, '[{\"added\": {}}]', 7, 1);
INSERT INTO `django_admin_log` VALUES (6, '2023-03-10 15:12:51.450869', '3', 'test', 3, '', 7, 1);
INSERT INTO `django_admin_log` VALUES (7, '2023-03-10 15:14:41.795490', '4', 'demo', 1, '[{\"added\": {}}]', 7, 1);
INSERT INTO `django_admin_log` VALUES (8, '2023-03-14 16:14:17.016955', '4', 'demo', 3, '', 7, 1);
INSERT INTO `django_admin_log` VALUES (9, '2023-03-14 16:16:23.252190', '5', 'demo', 1, '[{\"added\": {}}]', 7, 1);
INSERT INTO `django_admin_log` VALUES (10, '2023-03-17 18:19:04.180695', '6', 'demo2', 1, '[{\"added\": {}}]', 7, 1);
INSERT INTO `django_admin_log` VALUES (11, '2023-03-19 18:59:05.746047', '5', 'demo', 3, '', 7, 1);
INSERT INTO `django_admin_log` VALUES (12, '2023-03-19 18:59:19.872285', '7', 'demo', 1, '[{\"added\": {}}]', 7, 1);
INSERT INTO `django_admin_log` VALUES (13, '2023-03-20 18:09:29.610310', '8', 'demo3', 1, '[{\"added\": {}}]', 7, 1);
INSERT INTO `django_admin_log` VALUES (14, '2023-03-21 09:59:07.239780', '8', 'demo3', 3, '', 7, 1);
INSERT INTO `django_admin_log` VALUES (15, '2023-03-21 09:59:33.271827', '9', '本地', 1, '[{\"added\": {}}]', 7, 1);
INSERT INTO `django_admin_log` VALUES (16, '2023-03-21 10:33:38.067676', '1', 'dmeo', 1, '[{\"added\": {}}]', 7, 1);
INSERT INTO `django_admin_log` VALUES (17, '2023-03-21 10:57:02.415214', '2', 'demo2', 1, '[{\"added\": {}}]', 7, 1);
INSERT INTO `django_admin_log` VALUES (18, '2023-03-21 10:57:20.251035', '3', 'demo3', 1, '[{\"added\": {}}]', 7, 1);

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
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of django_content_type
-- ----------------------------
INSERT INTO `django_content_type` VALUES (1, 'admin', 'logentry');
INSERT INTO `django_content_type` VALUES (3, 'auth', 'group');
INSERT INTO `django_content_type` VALUES (2, 'auth', 'permission');
INSERT INTO `django_content_type` VALUES (4, 'auth', 'user');
INSERT INTO `django_content_type` VALUES (5, 'contenttypes', 'contenttype');
INSERT INTO `django_content_type` VALUES (7, 'monitor', 'camera');
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
INSERT INTO `django_migrations` VALUES (1, 'contenttypes', '0001_initial', '2023-03-07 18:52:17.748529');
INSERT INTO `django_migrations` VALUES (2, 'auth', '0001_initial', '2023-03-07 18:52:18.080566');
INSERT INTO `django_migrations` VALUES (3, 'admin', '0001_initial', '2023-03-07 18:52:18.145864');
INSERT INTO `django_migrations` VALUES (4, 'admin', '0002_logentry_remove_auto_add', '2023-03-07 18:52:18.151071');
INSERT INTO `django_migrations` VALUES (5, 'admin', '0003_logentry_add_action_flag_choices', '2023-03-07 18:52:18.157598');
INSERT INTO `django_migrations` VALUES (6, 'contenttypes', '0002_remove_content_type_name', '2023-03-07 18:52:18.194773');
INSERT INTO `django_migrations` VALUES (7, 'auth', '0002_alter_permission_name_max_length', '2023-03-07 18:52:18.224875');
INSERT INTO `django_migrations` VALUES (8, 'auth', '0003_alter_user_email_max_length', '2023-03-07 18:52:18.238902');
INSERT INTO `django_migrations` VALUES (9, 'auth', '0004_alter_user_username_opts', '2023-03-07 18:52:18.245224');
INSERT INTO `django_migrations` VALUES (10, 'auth', '0005_alter_user_last_login_null', '2023-03-07 18:52:18.272463');
INSERT INTO `django_migrations` VALUES (11, 'auth', '0006_require_contenttypes_0002', '2023-03-07 18:52:18.275701');
INSERT INTO `django_migrations` VALUES (12, 'auth', '0007_alter_validators_add_error_messages', '2023-03-07 18:52:18.281706');
INSERT INTO `django_migrations` VALUES (13, 'auth', '0008_alter_user_username_max_length', '2023-03-07 18:52:18.315306');
INSERT INTO `django_migrations` VALUES (14, 'auth', '0009_alter_user_last_name_max_length', '2023-03-07 18:52:18.349605');
INSERT INTO `django_migrations` VALUES (15, 'auth', '0010_alter_group_name_max_length', '2023-03-07 18:52:18.363531');
INSERT INTO `django_migrations` VALUES (16, 'auth', '0011_update_proxy_permissions', '2023-03-07 18:52:18.370802');
INSERT INTO `django_migrations` VALUES (17, 'auth', '0012_alter_user_first_name_max_length', '2023-03-07 18:52:18.408961');
INSERT INTO `django_migrations` VALUES (18, 'monitor', '0001_initial', '2023-03-07 18:52:18.439638');
INSERT INTO `django_migrations` VALUES (19, 'sessions', '0001_initial', '2023-03-07 18:52:18.471142');

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
INSERT INTO `django_session` VALUES ('03urwcgqzm8topfmfz3ch8t0cbqf79su', '.eJzFkslugzAQhl8l8jkBbBabHNtzjj2VKBovCW5ZKhtOEe9eO0RqS0mKqko9Dcz_65vNZ3SAvisPvVXmoCXaIozWn3McxKtqvCBfoDm1gWibzmgeeEtwVW2wa6WqHq7eL4ASbOmxMU6yXPEspUxEgqYqiwSmaQacSEYIBhIxkuZE0fwoMDBCCZGYZDHlxzyJPLRWTW8d6_lcoAZqVaDtqkC7ttFdawq0dj_atTemj2BWR9gIbUSlRrH2TVovfyU8ui8DdgGhN9WohSBr3YT1WDsUF0I4mkDKp_s-57h6uVEghelrPtPXssmG9eoX0wx7LystvYqjiEwTeMotip5xSC5BYBfShAkXspgxH2gSf69pfU1balXJDVTd_Ts4Ck3JBUZiemMA_6jmj-HfXOjl23f4sCw8wd8MPbPKpYNOz5LMsZRIbnThIXYj2tOdlZ1M27_9sLPR8-9LWzTodGXpNBEPezS8A7YcjPw:1pgeJo:3QwyNCYXZhSF2eiyOqgfGl784tMtVtmaalaAAZN7pqI', '2023-04-10 12:18:52.979472');
INSERT INTO `django_session` VALUES ('0h0otbmmgqbxm4m7475rrapkp7lbji1l', '.eJzFUstuwjAQ_BXkMyQkzsNwbM8ce2oQWtsb4jaPyk5OKP9emyC1pIFGFVJPa--MZ3d2fSIH6Nri0BnUByXJlgRk-T3HQbxj7QD5BvWx8URTt1pxz1G8C2q8XSOxfLpwrwQKMIV9zYM8R4iQ5jzhfBPwVIYxhxRzjpswSRFkyvIwYDJZI6chiwGAbbigzPIpOtEK685YrddTRmqoMCPbRUZ2Ta3aRmdkaS_Ktjekc9CLHFZCaVHiAFauSePga4Vne9JgZih0uhwwH2Slar8aavvirOAPJJDy5T7PMi5crq1xobuKT_Q1z1m_XPzBTb93MCrp0GC9DseJYKybZR3jEJ2DCGyIIyZsSChjLqQR_VnTuJqmUFjKFZTt_T1YlTQOz2IhTW8YcJ9qehnuz_kOvr2HL8rMFTzG9MQo5xodryWa0kIR3ejCiZiVaI53RnbUTffxy8wGzr8PbZbR8cjicYL2e9J_Aj4PkAQ:1pZXGY:0puQZ4BG4XLkMj_8fUf93-vuzziulcpPXt66sY0vxQ0', '2023-03-21 21:22:06.280337');
INSERT INTO `django_session` VALUES ('12ddew99w4lqg6kq02hg6usgdd1pjgv2', 'NGRlOGUwMmZiMGE4NzE4M2YzZTQ3MmVhMTNiMmRhYzA4MmFiNTkzNjp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI1MDY0ZmU3YWRmMzc4M2M0ZDU5Y2U0ZGVhOGJiYTQ5NWQ3MGE5YTJmIiwiX21lbnVzIjoiW3tcIm5hbWVcIjogXCJNb25pdG9yXCIsIFwiaWNvblwiOiBcImZhciBmYS1jaXJjbGVcIiwgXCJtb2RlbHNcIjogW3tcIm5hbWVcIjogXCJDYW1lcmFzXCIsIFwiaWNvblwiOiBcImZhciBmYS1jaXJjbGVcIiwgXCJ1cmxcIjogXCIvYWRtaW4vbW9uaXRvci9jYW1lcmEvXCIsIFwiYWRkVXJsXCI6IFwiL2FkbWluL21vbml0b3IvY2FtZXJhL2FkZC9cIiwgXCJicmVhZGNydW1ic1wiOiBbe1wibmFtZVwiOiBcIk1vbml0b3JcIiwgXCJpY29uXCI6IFwiZmFyIGZhLWNpcmNsZVwifSwge1wibmFtZVwiOiBcIkNhbWVyYXNcIiwgXCJpY29uXCI6IFwiZmFyIGZhLWNpcmNsZVwifV0sIFwiZWlkXCI6IDEwMDJ9XSwgXCJlaWRcIjogMTAwMX0sIHtcIm5hbWVcIjogXCJcXHU4YmE0XFx1OGJjMVxcdTU0OGNcXHU2Mzg4XFx1Njc0M1wiLCBcImljb25cIjogXCJmYXMgZmEtc2hpZWxkLWFsdFwiLCBcIm1vZGVsc1wiOiBbe1wibmFtZVwiOiBcIlxcdTc1MjhcXHU2MjM3XCIsIFwiaWNvblwiOiBcImZhciBmYS11c2VyXCIsIFwidXJsXCI6IFwiL2FkbWluL2F1dGgvdXNlci9cIiwgXCJhZGRVcmxcIjogXCIvYWRtaW4vYXV0aC91c2VyL2FkZC9cIiwgXCJicmVhZGNydW1ic1wiOiBbe1wibmFtZVwiOiBcIlxcdThiYTRcXHU4YmMxXFx1NTQ4Y1xcdTYzODhcXHU2NzQzXCIsIFwiaWNvblwiOiBcImZhcyBmYS1zaGllbGQtYWx0XCJ9LCB7XCJuYW1lXCI6IFwiXFx1NzUyOFxcdTYyMzdcIiwgXCJpY29uXCI6IFwiZmFyIGZhLXVzZXJcIn1dLCBcImVpZFwiOiAxMDA0fSwge1wibmFtZVwiOiBcIlxcdTdlYzRcIiwgXCJpY29uXCI6IFwiZmFzIGZhLXVzZXJzLWNvZ1wiLCBcInVybFwiOiBcIi9hZG1pbi9hdXRoL2dyb3VwL1wiLCBcImFkZFVybFwiOiBcIi9hZG1pbi9hdXRoL2dyb3VwL2FkZC9cIiwgXCJicmVhZGNydW1ic1wiOiBbe1wibmFtZVwiOiBcIlxcdThiYTRcXHU4YmMxXFx1NTQ4Y1xcdTYzODhcXHU2NzQzXCIsIFwiaWNvblwiOiBcImZhcyBmYS1zaGllbGQtYWx0XCJ9LCB7XCJuYW1lXCI6IFwiXFx1N2VjNFwiLCBcImljb25cIjogXCJmYXMgZmEtdXNlcnMtY29nXCJ9XSwgXCJlaWRcIjogMTAwNX1dLCBcImVpZFwiOiAxMDAzfV0ifQ==', '2023-04-09 16:14:47.751974');
INSERT INTO `django_session` VALUES ('2hyqk6gx4swrrmv3cwezsnv43pbqh0o0', 'NGRlOGUwMmZiMGE4NzE4M2YzZTQ3MmVhMTNiMmRhYzA4MmFiNTkzNjp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI1MDY0ZmU3YWRmMzc4M2M0ZDU5Y2U0ZGVhOGJiYTQ5NWQ3MGE5YTJmIiwiX21lbnVzIjoiW3tcIm5hbWVcIjogXCJNb25pdG9yXCIsIFwiaWNvblwiOiBcImZhciBmYS1jaXJjbGVcIiwgXCJtb2RlbHNcIjogW3tcIm5hbWVcIjogXCJDYW1lcmFzXCIsIFwiaWNvblwiOiBcImZhciBmYS1jaXJjbGVcIiwgXCJ1cmxcIjogXCIvYWRtaW4vbW9uaXRvci9jYW1lcmEvXCIsIFwiYWRkVXJsXCI6IFwiL2FkbWluL21vbml0b3IvY2FtZXJhL2FkZC9cIiwgXCJicmVhZGNydW1ic1wiOiBbe1wibmFtZVwiOiBcIk1vbml0b3JcIiwgXCJpY29uXCI6IFwiZmFyIGZhLWNpcmNsZVwifSwge1wibmFtZVwiOiBcIkNhbWVyYXNcIiwgXCJpY29uXCI6IFwiZmFyIGZhLWNpcmNsZVwifV0sIFwiZWlkXCI6IDEwMDJ9XSwgXCJlaWRcIjogMTAwMX0sIHtcIm5hbWVcIjogXCJcXHU4YmE0XFx1OGJjMVxcdTU0OGNcXHU2Mzg4XFx1Njc0M1wiLCBcImljb25cIjogXCJmYXMgZmEtc2hpZWxkLWFsdFwiLCBcIm1vZGVsc1wiOiBbe1wibmFtZVwiOiBcIlxcdTc1MjhcXHU2MjM3XCIsIFwiaWNvblwiOiBcImZhciBmYS11c2VyXCIsIFwidXJsXCI6IFwiL2FkbWluL2F1dGgvdXNlci9cIiwgXCJhZGRVcmxcIjogXCIvYWRtaW4vYXV0aC91c2VyL2FkZC9cIiwgXCJicmVhZGNydW1ic1wiOiBbe1wibmFtZVwiOiBcIlxcdThiYTRcXHU4YmMxXFx1NTQ4Y1xcdTYzODhcXHU2NzQzXCIsIFwiaWNvblwiOiBcImZhcyBmYS1zaGllbGQtYWx0XCJ9LCB7XCJuYW1lXCI6IFwiXFx1NzUyOFxcdTYyMzdcIiwgXCJpY29uXCI6IFwiZmFyIGZhLXVzZXJcIn1dLCBcImVpZFwiOiAxMDA0fSwge1wibmFtZVwiOiBcIlxcdTdlYzRcIiwgXCJpY29uXCI6IFwiZmFzIGZhLXVzZXJzLWNvZ1wiLCBcInVybFwiOiBcIi9hZG1pbi9hdXRoL2dyb3VwL1wiLCBcImFkZFVybFwiOiBcIi9hZG1pbi9hdXRoL2dyb3VwL2FkZC9cIiwgXCJicmVhZGNydW1ic1wiOiBbe1wibmFtZVwiOiBcIlxcdThiYTRcXHU4YmMxXFx1NTQ4Y1xcdTYzODhcXHU2NzQzXCIsIFwiaWNvblwiOiBcImZhcyBmYS1zaGllbGQtYWx0XCJ9LCB7XCJuYW1lXCI6IFwiXFx1N2VjNFwiLCBcImljb25cIjogXCJmYXMgZmEtdXNlcnMtY29nXCJ9XSwgXCJlaWRcIjogMTAwNX1dLCBcImVpZFwiOiAxMDAzfV0ifQ==', '2023-03-31 19:02:47.124249');
INSERT INTO `django_session` VALUES ('azqf2xpddxxglqxp6zcdhu46t7cyloib', '.eJzFkslugzAQhl8l8jkBbBabHNtzjj2VKBovCW5ZKhtOEe9eO0RqS0mKqko9Dcz_65vNZ3SAvisPvVXmoCXaIozWn3McxKtqvCBfoDm1gWibzmgeeEtwVW2wa6WqHq7eL4ASbOmxMU6yXPEspUxEgqYqiwSmaQacSEYIBhIxkuZE0fwoMDBCCZGYZDHlxzyJPLRWTW8d6_lcoAZqVaDtqkC7ttFdawq0dj_atTemj2BWR9gIbUSlRrH2TVovfyU8ui8DdgGhN9WohSBr3YT1WDsUF0I4mkDKp_s-57h6uVEghelrPtPXssmG9eoX0wx7LystvYqjiEwTeMotip5xSC5BYBfShAkXspgxH2gSf69pfU1balXJDVTd_Ts4Ck3JBUZiemMA_6jmj-HfXOjl23f4sCw8wd8MPbPKpYNOz5LMsZRIbnThIXYj2tOdlZ1M27_9sLPR8-9LWzTodGXpNBEPezS8A7YcjPw:1pgiOZ:QhFKA4xtPaVcJqFH9oRkbzZHdyKbe3Gi_2Rq8dXYo0E', '2023-04-10 16:40:03.123235');
INSERT INTO `django_session` VALUES ('gvnzi6nlfa3vsvtnj1f6ksy57fdu08hr', 'NGRlOGUwMmZiMGE4NzE4M2YzZTQ3MmVhMTNiMmRhYzA4MmFiNTkzNjp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI1MDY0ZmU3YWRmMzc4M2M0ZDU5Y2U0ZGVhOGJiYTQ5NWQ3MGE5YTJmIiwiX21lbnVzIjoiW3tcIm5hbWVcIjogXCJNb25pdG9yXCIsIFwiaWNvblwiOiBcImZhciBmYS1jaXJjbGVcIiwgXCJtb2RlbHNcIjogW3tcIm5hbWVcIjogXCJDYW1lcmFzXCIsIFwiaWNvblwiOiBcImZhciBmYS1jaXJjbGVcIiwgXCJ1cmxcIjogXCIvYWRtaW4vbW9uaXRvci9jYW1lcmEvXCIsIFwiYWRkVXJsXCI6IFwiL2FkbWluL21vbml0b3IvY2FtZXJhL2FkZC9cIiwgXCJicmVhZGNydW1ic1wiOiBbe1wibmFtZVwiOiBcIk1vbml0b3JcIiwgXCJpY29uXCI6IFwiZmFyIGZhLWNpcmNsZVwifSwge1wibmFtZVwiOiBcIkNhbWVyYXNcIiwgXCJpY29uXCI6IFwiZmFyIGZhLWNpcmNsZVwifV0sIFwiZWlkXCI6IDEwMDJ9XSwgXCJlaWRcIjogMTAwMX0sIHtcIm5hbWVcIjogXCJcXHU4YmE0XFx1OGJjMVxcdTU0OGNcXHU2Mzg4XFx1Njc0M1wiLCBcImljb25cIjogXCJmYXMgZmEtc2hpZWxkLWFsdFwiLCBcIm1vZGVsc1wiOiBbe1wibmFtZVwiOiBcIlxcdTc1MjhcXHU2MjM3XCIsIFwiaWNvblwiOiBcImZhciBmYS11c2VyXCIsIFwidXJsXCI6IFwiL2FkbWluL2F1dGgvdXNlci9cIiwgXCJhZGRVcmxcIjogXCIvYWRtaW4vYXV0aC91c2VyL2FkZC9cIiwgXCJicmVhZGNydW1ic1wiOiBbe1wibmFtZVwiOiBcIlxcdThiYTRcXHU4YmMxXFx1NTQ4Y1xcdTYzODhcXHU2NzQzXCIsIFwiaWNvblwiOiBcImZhcyBmYS1zaGllbGQtYWx0XCJ9LCB7XCJuYW1lXCI6IFwiXFx1NzUyOFxcdTYyMzdcIiwgXCJpY29uXCI6IFwiZmFyIGZhLXVzZXJcIn1dLCBcImVpZFwiOiAxMDA0fSwge1wibmFtZVwiOiBcIlxcdTdlYzRcIiwgXCJpY29uXCI6IFwiZmFzIGZhLXVzZXJzLWNvZ1wiLCBcInVybFwiOiBcIi9hZG1pbi9hdXRoL2dyb3VwL1wiLCBcImFkZFVybFwiOiBcIi9hZG1pbi9hdXRoL2dyb3VwL2FkZC9cIiwgXCJicmVhZGNydW1ic1wiOiBbe1wibmFtZVwiOiBcIlxcdThiYTRcXHU4YmMxXFx1NTQ4Y1xcdTYzODhcXHU2NzQzXCIsIFwiaWNvblwiOiBcImZhcyBmYS1zaGllbGQtYWx0XCJ9LCB7XCJuYW1lXCI6IFwiXFx1N2VjNFwiLCBcImljb25cIjogXCJmYXMgZmEtdXNlcnMtY29nXCJ9XSwgXCJlaWRcIjogMTAwNX1dLCBcImVpZFwiOiAxMDAzfV0ifQ==', '2023-04-03 18:09:06.005436');
INSERT INTO `django_session` VALUES ('mc0yg8qbsoemnyt5efbvzzkr05nbm0ze', 'NGRlOGUwMmZiMGE4NzE4M2YzZTQ3MmVhMTNiMmRhYzA4MmFiNTkzNjp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI1MDY0ZmU3YWRmMzc4M2M0ZDU5Y2U0ZGVhOGJiYTQ5NWQ3MGE5YTJmIiwiX21lbnVzIjoiW3tcIm5hbWVcIjogXCJNb25pdG9yXCIsIFwiaWNvblwiOiBcImZhciBmYS1jaXJjbGVcIiwgXCJtb2RlbHNcIjogW3tcIm5hbWVcIjogXCJDYW1lcmFzXCIsIFwiaWNvblwiOiBcImZhciBmYS1jaXJjbGVcIiwgXCJ1cmxcIjogXCIvYWRtaW4vbW9uaXRvci9jYW1lcmEvXCIsIFwiYWRkVXJsXCI6IFwiL2FkbWluL21vbml0b3IvY2FtZXJhL2FkZC9cIiwgXCJicmVhZGNydW1ic1wiOiBbe1wibmFtZVwiOiBcIk1vbml0b3JcIiwgXCJpY29uXCI6IFwiZmFyIGZhLWNpcmNsZVwifSwge1wibmFtZVwiOiBcIkNhbWVyYXNcIiwgXCJpY29uXCI6IFwiZmFyIGZhLWNpcmNsZVwifV0sIFwiZWlkXCI6IDEwMDJ9XSwgXCJlaWRcIjogMTAwMX0sIHtcIm5hbWVcIjogXCJcXHU4YmE0XFx1OGJjMVxcdTU0OGNcXHU2Mzg4XFx1Njc0M1wiLCBcImljb25cIjogXCJmYXMgZmEtc2hpZWxkLWFsdFwiLCBcIm1vZGVsc1wiOiBbe1wibmFtZVwiOiBcIlxcdTc1MjhcXHU2MjM3XCIsIFwiaWNvblwiOiBcImZhciBmYS11c2VyXCIsIFwidXJsXCI6IFwiL2FkbWluL2F1dGgvdXNlci9cIiwgXCJhZGRVcmxcIjogXCIvYWRtaW4vYXV0aC91c2VyL2FkZC9cIiwgXCJicmVhZGNydW1ic1wiOiBbe1wibmFtZVwiOiBcIlxcdThiYTRcXHU4YmMxXFx1NTQ4Y1xcdTYzODhcXHU2NzQzXCIsIFwiaWNvblwiOiBcImZhcyBmYS1zaGllbGQtYWx0XCJ9LCB7XCJuYW1lXCI6IFwiXFx1NzUyOFxcdTYyMzdcIiwgXCJpY29uXCI6IFwiZmFyIGZhLXVzZXJcIn1dLCBcImVpZFwiOiAxMDA0fSwge1wibmFtZVwiOiBcIlxcdTdlYzRcIiwgXCJpY29uXCI6IFwiZmFzIGZhLXVzZXJzLWNvZ1wiLCBcInVybFwiOiBcIi9hZG1pbi9hdXRoL2dyb3VwL1wiLCBcImFkZFVybFwiOiBcIi9hZG1pbi9hdXRoL2dyb3VwL2FkZC9cIiwgXCJicmVhZGNydW1ic1wiOiBbe1wibmFtZVwiOiBcIlxcdThiYTRcXHU4YmMxXFx1NTQ4Y1xcdTYzODhcXHU2NzQzXCIsIFwiaWNvblwiOiBcImZhcyBmYS1zaGllbGQtYWx0XCJ9LCB7XCJuYW1lXCI6IFwiXFx1N2VjNFwiLCBcImljb25cIjogXCJmYXMgZmEtdXNlcnMtY29nXCJ9XSwgXCJlaWRcIjogMTAwNX1dLCBcImVpZFwiOiAxMDAzfV0ifQ==', '2023-04-04 10:33:22.879837');
INSERT INTO `django_session` VALUES ('swqapxvaxlm3txzdabse65upq5igblgm', '.eJzFUstuwjAQ_BXkMyQkzsNwbM8ce2oQWtsb4jaPyk5OKP9emyC1pIFGFVJPa--MZ3d2fSIH6Nri0BnUByXJlgRk-T3HQbxj7QD5BvWx8URTt1pxz1G8C2q8XSOxfLpwrwQKMIV9zYM8R4iQ5jzhfBPwVIYxhxRzjpswSRFkyvIwYDJZI6chiwGAbbigzPIpOtEK685YrddTRmqoMCPbRUZ2Ta3aRmdkaS_Ktjekc9CLHFZCaVHiAFauSePga4Vne9JgZih0uhwwH2Slar8aavvirOAPJJDy5T7PMi5crq1xobuKT_Q1z1m_XPzBTb93MCrp0GC9DseJYKybZR3jEJ2DCGyIIyZsSChjLqQR_VnTuJqmUFjKFZTt_T1YlTQOz2IhTW8YcJ9qehnuz_kOvr2HL8rMFTzG9MQo5xodryWa0kIR3ejCiZiVaI53RnbUTffxy8wGzr8PbZbR8cjicYL2e9J_Aj4PkAQ:1paXMY:xc5EyHA8OZaR7vbnwg40QJgxIUqrbsE1ZqfTihAoyJU', '2023-03-24 15:40:26.416376');
INSERT INTO `django_session` VALUES ('xqqtnd0a7zrmmlzdddwjyf09j5rjjtmw', '.eJzFUstuwjAQ_BXkMyQkzsNwbM8ce2oQWtsb4jaPyk5OKP9emyC1pIFGFVJPa--MZ3d2fSIH6Nri0BnUByXJlgRk-T3HQbxj7QD5BvWx8URTt1pxz1G8C2q8XSOxfLpwrwQKMIV9zYM8R4iQ5jzhfBPwVIYxhxRzjpswSRFkyvIwYDJZI6chiwGAbbigzPIpOtEK685YrddTRmqoMCPbRUZ2Ta3aRmdkaS_Ktjekc9CLHFZCaVHiAFauSePga4Vne9JgZih0uhwwH2Slar8aavvirOAPJJDy5T7PMi5crq1xobuKT_Q1z1m_XPzBTb93MCrp0GC9DseJYKybZR3jEJ2DCGyIIyZsSChjLqQR_VnTuJqmUFjKFZTt_T1YlTQOz2IhTW8YcJ9qehnuz_kOvr2HL8rMFTzG9MQo5xodryWa0kIR3ejCiZiVaI53RnbUTffxy8wGzr8PbZbR8cjicYL2e9J_Aj4PkAQ:1pZXMU:1BTivkqXEhP7fe2nBzFSgp89-RCH1fnwjESfPeJp8KM', '2023-03-21 21:28:14.783533');
INSERT INTO `django_session` VALUES ('yhj22xvd1ztkapqthq7jjy7on5p6uo2l', 'NGRlOGUwMmZiMGE4NzE4M2YzZTQ3MmVhMTNiMmRhYzA4MmFiNTkzNjp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI1MDY0ZmU3YWRmMzc4M2M0ZDU5Y2U0ZGVhOGJiYTQ5NWQ3MGE5YTJmIiwiX21lbnVzIjoiW3tcIm5hbWVcIjogXCJNb25pdG9yXCIsIFwiaWNvblwiOiBcImZhciBmYS1jaXJjbGVcIiwgXCJtb2RlbHNcIjogW3tcIm5hbWVcIjogXCJDYW1lcmFzXCIsIFwiaWNvblwiOiBcImZhciBmYS1jaXJjbGVcIiwgXCJ1cmxcIjogXCIvYWRtaW4vbW9uaXRvci9jYW1lcmEvXCIsIFwiYWRkVXJsXCI6IFwiL2FkbWluL21vbml0b3IvY2FtZXJhL2FkZC9cIiwgXCJicmVhZGNydW1ic1wiOiBbe1wibmFtZVwiOiBcIk1vbml0b3JcIiwgXCJpY29uXCI6IFwiZmFyIGZhLWNpcmNsZVwifSwge1wibmFtZVwiOiBcIkNhbWVyYXNcIiwgXCJpY29uXCI6IFwiZmFyIGZhLWNpcmNsZVwifV0sIFwiZWlkXCI6IDEwMDJ9XSwgXCJlaWRcIjogMTAwMX0sIHtcIm5hbWVcIjogXCJcXHU4YmE0XFx1OGJjMVxcdTU0OGNcXHU2Mzg4XFx1Njc0M1wiLCBcImljb25cIjogXCJmYXMgZmEtc2hpZWxkLWFsdFwiLCBcIm1vZGVsc1wiOiBbe1wibmFtZVwiOiBcIlxcdTc1MjhcXHU2MjM3XCIsIFwiaWNvblwiOiBcImZhciBmYS11c2VyXCIsIFwidXJsXCI6IFwiL2FkbWluL2F1dGgvdXNlci9cIiwgXCJhZGRVcmxcIjogXCIvYWRtaW4vYXV0aC91c2VyL2FkZC9cIiwgXCJicmVhZGNydW1ic1wiOiBbe1wibmFtZVwiOiBcIlxcdThiYTRcXHU4YmMxXFx1NTQ4Y1xcdTYzODhcXHU2NzQzXCIsIFwiaWNvblwiOiBcImZhcyBmYS1zaGllbGQtYWx0XCJ9LCB7XCJuYW1lXCI6IFwiXFx1NzUyOFxcdTYyMzdcIiwgXCJpY29uXCI6IFwiZmFyIGZhLXVzZXJcIn1dLCBcImVpZFwiOiAxMDA0fSwge1wibmFtZVwiOiBcIlxcdTdlYzRcIiwgXCJpY29uXCI6IFwiZmFzIGZhLXVzZXJzLWNvZ1wiLCBcInVybFwiOiBcIi9hZG1pbi9hdXRoL2dyb3VwL1wiLCBcImFkZFVybFwiOiBcIi9hZG1pbi9hdXRoL2dyb3VwL2FkZC9cIiwgXCJicmVhZGNydW1ic1wiOiBbe1wibmFtZVwiOiBcIlxcdThiYTRcXHU4YmMxXFx1NTQ4Y1xcdTYzODhcXHU2NzQzXCIsIFwiaWNvblwiOiBcImZhcyBmYS1zaGllbGQtYWx0XCJ9LCB7XCJuYW1lXCI6IFwiXFx1N2VjNFwiLCBcImljb25cIjogXCJmYXMgZmEtdXNlcnMtY29nXCJ9XSwgXCJlaWRcIjogMTAwNX1dLCBcImVpZFwiOiAxMDAzfV0ifQ==', '2023-04-04 10:56:16.838337');

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
