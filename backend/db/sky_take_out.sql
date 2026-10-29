-- MySQL dump 10.13  Distrib 8.0.26, for Win64 (x86_64)
--
-- Host: localhost    Database: sky_take_out
-- ------------------------------------------------------
-- Server version	8.0.26

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `sky_take_out`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `sky_take_out` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `sky_take_out`;

--
-- Table structure for table `address_book`
--

DROP TABLE IF EXISTS `address_book`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `address_book` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `user_id` bigint NOT NULL COMMENT '用户id',
  `consignee` varchar(50) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '收货人',
  `sex` varchar(2) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '性别',
  `phone` varchar(11) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '手机号',
  `province_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '省级区划编号',
  `province_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '省级名称',
  `city_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '市级区划编号',
  `city_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '市级名称',
  `district_code` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '区级区划编号',
  `district_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '区级名称',
  `detail` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '详细地址',
  `label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '标签',
  `is_default` tinyint(1) NOT NULL DEFAULT '0' COMMENT '默认 0 否 1是',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_bin COMMENT='地址簿';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `address_book`
--

LOCK TABLES `address_book` WRITE;
/*!40000 ALTER TABLE `address_book` DISABLE KEYS */;
INSERT INTO `address_book` VALUES (2,4,'张三','0','15501145441','11','北京市','1101','市辖区','110108','海淀区','1号','1',0),(4,4,'李四','0','13655220337','11','北京市','1101','市辖区','110108','海淀区','北京海淀颐和园路5号','3',1);
/*!40000 ALTER TABLE `address_book` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `type` int DEFAULT NULL COMMENT '类型   1 菜品分类 2 套餐分类',
  `name` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '分类名称',
  `sort` int NOT NULL DEFAULT '0' COMMENT '顺序',
  `status` int DEFAULT NULL COMMENT '分类状态 0:禁用，1:启用',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `create_user` bigint DEFAULT NULL COMMENT '创建人',
  `update_user` bigint DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_category_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_bin COMMENT='菜品及套餐分类';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES (11,1,'酒水饮料',10,1,'2022-06-09 22:09:18','2022-06-09 22:09:18',1,1),(12,1,'传统主食',9,1,'2022-06-09 22:09:32','2022-06-09 22:18:53',1,1),(13,2,'人气套餐',12,1,'2022-06-09 22:11:38','2022-06-10 11:04:40',1,1),(15,2,'商务套餐',13,1,'2022-06-09 22:14:10','2022-06-10 11:04:48',1,1),(16,1,'蜀味烤鱼',4,1,'2022-06-09 22:15:37','2026-04-09 11:49:22',1,1),(17,1,'蜀味牛蛙',5,1,'2022-06-09 22:16:14','2022-08-31 14:39:44',1,1),(18,1,'特色蒸菜',6,1,'2022-06-09 22:17:42','2022-06-09 22:17:42',1,1),(19,1,'新鲜时蔬',7,1,'2022-06-09 22:18:12','2022-06-09 22:18:28',1,1),(20,1,'水煮鱼',8,1,'2022-06-09 22:22:29','2022-06-09 22:23:45',1,1),(21,1,'汤类',11,1,'2022-06-10 10:51:47','2022-06-10 10:51:47',1,1);
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dish`
--

DROP TABLE IF EXISTS `dish`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dish` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '菜品名称',
  `category_id` bigint NOT NULL COMMENT '菜品分类id',
  `price` decimal(10,2) DEFAULT NULL COMMENT '菜品价格',
  `image` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '图片',
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '描述信息',
  `status` int DEFAULT '1' COMMENT '0 停售 1 起售',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `create_user` bigint DEFAULT NULL COMMENT '创建人',
  `update_user` bigint DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_dish_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_bin COMMENT='菜品';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dish`
--

LOCK TABLES `dish` WRITE;
/*!40000 ALTER TABLE `dish` DISABLE KEYS */;
INSERT INTO `dish` VALUES (46,'王老吉',11,6.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/7208d40a-c87a-4dd4-8ecd-b2b36090b9fc.jpg','',1,'2022-06-09 22:40:47','2026-05-03 15:19:25',1,1),(47,'北冰洋',11,4.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/b1a314db-a08c-4786-b63b-87496b9b365e.png','还是小时候的味道',1,'2022-06-10 09:18:49','2026-05-03 15:19:50',1,1),(48,'雪花啤酒',11,4.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/b58bfcb6-40dc-4415-a1f9-760198aa0c6f.jpg','',1,'2022-06-10 09:22:54','2026-05-03 15:20:09',1,1),(49,'米饭',12,2.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/1aa13a7a-ecc4-498b-a640-737c8223838d.jpg','精选五常大米',1,'2022-06-10 09:30:17','2026-05-03 15:21:17',1,1),(50,'馒头',12,1.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/64c63bff-7633-4803-bcfa-c9ae943207fc.jpg','优质面粉',1,'2022-06-10 09:34:28','2026-05-03 15:24:14',1,1),(51,'老坛酸菜鱼',20,56.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/dc9dcef9-8bfe-4f82-8ad1-d2e281050296.jpg','原料：汤，草鱼，酸菜',1,'2022-06-10 09:40:51','2026-05-03 15:23:53',1,1),(52,'经典酸菜鮰鱼',20,66.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/6ab73f17-c77c-45d6-9c2d-dec0b6af73a3.jpg','原料：酸菜，江团，鮰鱼',1,'2022-06-10 09:46:02','2026-05-03 15:23:26',1,1),(53,'蜀味水煮草鱼',20,38.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/611a56bb-b8b0-48cf-8ae5-bd67c0cab084.jpg','原料：草鱼，汤',1,'2022-06-10 09:48:37','2026-05-03 15:23:02',1,1),(54,'清炒小油菜',19,18.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/68982d51-956f-474e-bf35-5c0c92c0846d.jpg','原料：小油菜',1,'2022-06-10 09:51:46','2026-05-03 15:22:43',1,1),(55,'蒜蓉娃娃菜',19,18.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/13a7ec6f-b908-43e7-be23-88d6ac328fe5.jpg','原料：蒜，娃娃菜',1,'2022-06-10 09:53:37','2026-05-03 15:21:52',1,1),(56,'清炒西兰花',19,18.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/fabcfb00-eced-448e-95df-ba5edb594d24.jpg','原料：西兰花',1,'2022-06-10 09:55:44','2026-05-03 15:19:05',1,1),(57,'炝炒圆白菜',19,18.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/9aaf6df6-211f-4f57-934f-76333d6d9346.jpg','原料：圆白菜',1,'2022-06-10 09:58:35','2026-05-03 15:18:46',1,1),(58,'清蒸鲈鱼',18,98.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/e14e52a5-d146-4189-b644-7523c46226c8.jpg','原料：鲈鱼',1,'2022-06-10 10:12:28','2026-05-03 15:18:16',1,1),(59,'东坡肘子',18,138.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/bb7bf73d-c0b3-4c1e-8d51-8e41fa461f0e.jpg','原料：猪肘棒',1,'2022-06-10 10:24:03','2026-05-03 15:17:50',1,1),(60,'梅菜扣肉',18,58.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/8b1b0210-d640-483e-a56e-1a0428d5ab6d.jpg','原料：猪肉，梅菜',1,'2022-06-10 10:26:03','2026-05-03 15:17:16',1,1),(61,'剁椒鱼头',18,66.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/654dc347-2f89-4d6f-9db8-ec4193d55efd.jpg','原料：鲢鱼，剁椒',1,'2022-06-10 10:28:54','2026-05-03 15:16:48',1,1),(62,'金汤酸菜牛蛙',17,88.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/8dc24dd0-57e4-4d4d-8025-6280102ac603.jpg','原料：鲜活牛蛙，酸菜',1,'2022-06-10 10:33:05','2026-05-03 15:16:24',1,1),(63,'香锅牛蛙',17,88.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/7bd44a3e-9265-4a15-9321-2861dfc58826.jpg','配料：鲜活牛蛙，莲藕，青笋',1,'2022-06-10 10:35:40','2026-05-03 15:16:00',1,1),(64,'馋嘴牛蛙',17,88.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/e66b671c-db26-45c5-a9f3-83be46bf30ab.jpg','配料：鲜活牛蛙，丝瓜，黄豆芽',1,'2022-06-10 10:37:52','2026-05-03 15:15:35',1,1),(65,'草鱼2斤',16,68.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/9b9bc636-6a93-417b-811b-ef3242151c89.jpg','原料：草鱼，黄豆芽，莲藕',1,'2022-06-10 10:41:08','2026-05-03 15:14:48',1,1),(66,'江团鱼2斤',16,119.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/5a9a88f7-cc84-4b8a-88be-e71b31b08660.jpg','配料：江团鱼，黄豆芽，莲藕',1,'2022-06-10 10:42:42','2026-05-03 15:14:13',1,1),(67,'鮰鱼2斤',16,72.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/710ade9f-c73b-4e25-9703-6ec9578acf1d.jpg','原料：鮰鱼，黄豆芽，莲藕',1,'2022-06-10 10:43:56','2026-05-03 15:13:49',1,1),(68,'鸡蛋汤',21,5.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/a57e89a0-283c-468c-b9cd-ffe72586a651.jpg','配料：鸡蛋，紫菜',1,'2022-06-10 10:54:25','2026-05-12 11:32:33',1,1),(69,'平菇豆腐汤',21,6.00,'https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/45ea8f6d-e731-497a-8034-67425ee78d59.jpg','配料：豆腐，平菇',1,'2022-06-10 10:55:02','2026-05-12 11:33:25',1,1),(71,'AI测试菜',20,42.00,NULL,NULL,1,'2026-09-20 16:17:34','2026-09-20 16:18:23',NULL,NULL);
/*!40000 ALTER TABLE `dish` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dish_flavor`
--

DROP TABLE IF EXISTS `dish_flavor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dish_flavor` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `dish_id` bigint NOT NULL COMMENT '菜品',
  `name` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '口味名称',
  `value` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '口味数据list',
  PRIMARY KEY (`id`),
  KEY `idx_dish_id` (`dish_id`)
) ENGINE=InnoDB AUTO_INCREMENT=122 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_bin COMMENT='菜品口味关系表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dish_flavor`
--

LOCK TABLES `dish_flavor` WRITE;
/*!40000 ALTER TABLE `dish_flavor` DISABLE KEYS */;
INSERT INTO `dish_flavor` VALUES (40,10,'甜味','[\"无糖\",\"少糖\",\"半糖\",\"多糖\",\"全糖\"]'),(41,7,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]'),(42,7,'温度','[\"热饮\",\"常温\",\"去冰\",\"少冰\",\"多冰\"]'),(45,6,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]'),(46,6,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]'),(47,5,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]'),(48,5,'甜味','[\"无糖\",\"少糖\",\"半糖\",\"多糖\",\"全糖\"]'),(49,2,'甜味','[\"无糖\",\"少糖\",\"半糖\",\"多糖\",\"全糖\"]'),(50,4,'甜味','[\"无糖\",\"少糖\",\"半糖\",\"多糖\",\"全糖\"]'),(51,3,'甜味','[\"无糖\",\"少糖\",\"半糖\",\"多糖\",\"全糖\"]'),(52,3,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]'),(108,67,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]'),(109,66,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]'),(110,65,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]'),(111,60,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]'),(112,57,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]'),(113,56,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]'),(114,54,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\"]'),(115,53,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]'),(116,53,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]'),(117,52,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]'),(118,52,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]'),(119,51,'忌口','[\"不要葱\",\"不要蒜\",\"不要香菜\",\"不要辣\"]'),(120,51,'辣度','[\"不辣\",\"微辣\",\"中辣\",\"重辣\"]'),(121,68,'温度','[\"常温\"]');
/*!40000 ALTER TABLE `dish_flavor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee`
--

DROP TABLE IF EXISTS `employee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '姓名',
  `username` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '用户名',
  `password` varchar(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '密码',
  `phone` varchar(11) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '手机号',
  `sex` varchar(2) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '性别',
  `id_number` varchar(18) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '身份证号',
  `status` int NOT NULL DEFAULT '1' COMMENT '状态 0:禁用，1:启用',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `create_user` bigint DEFAULT NULL COMMENT '创建人',
  `update_user` bigint DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_username` (`username`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_bin COMMENT='员工信息';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee`
--

LOCK TABLES `employee` WRITE;
/*!40000 ALTER TABLE `employee` DISABLE KEYS */;
INSERT INTO `employee` VALUES (1,'管理员','admin','e10adc3949ba59abbe56e057f20f883e','13812312312','1','110101199001010047',1,'2022-02-15 15:51:20','2022-02-17 09:16:20',10,1),(3,'李四','lisi','e10adc3949ba59abbe56e057f20f883e','15012378952','0','440102566253154879',1,'2026-04-08 12:30:28','2026-04-09 09:23:42',10,10),(10,'黎静','liming','e10adc3949ba59abbe56e057f20f883e','18164688413','0','110101199001010048',1,'2026-04-08 14:11:08','2026-04-14 01:31:00',1,1),(11,'张三','zhangsan','e10adc3949ba59abbe56e057f20f883e','13800000011','1','110101199003071234',1,'2026-09-24 09:30:00','2026-09-24 09:30:00',1,1),(12,'王五','wangwu','e10adc3949ba59abbe56e057f20f883e','13800000012','1','110101199105161234',1,'2026-09-24 09:31:00','2026-09-24 09:31:00',1,1),(13,'赵六','zhaoliu','e10adc3949ba59abbe56e057f20f883e','13800000013','0','110101199207231245',1,'2026-09-24 09:32:00','2026-09-24 09:32:00',1,1),(14,'孙七','sunqi','e10adc3949ba59abbe56e057f20f883e','13800000014','0','110101199311081236',1,'2026-09-24 09:33:00','2026-09-24 09:33:00',1,1);
/*!40000 ALTER TABLE `employee` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee_role`
--

DROP TABLE IF EXISTS `employee_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee_role` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `employee_id` bigint NOT NULL COMMENT '员工id',
  `role_id` bigint NOT NULL COMMENT '角色id',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_emp_role` (`employee_id`,`role_id`),
  KEY `idx_role_id` (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='员工-角色关联';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee_role`
--

LOCK TABLES `employee_role` WRITE;
/*!40000 ALTER TABLE `employee_role` DISABLE KEYS */;
INSERT INTO `employee_role` VALUES (1,1,1),(2,3,2),(3,10,3),(7,11,4),(8,12,5),(9,13,6),(10,14,2),(11,14,3);
/*!40000 ALTER TABLE `employee_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_detail`
--

DROP TABLE IF EXISTS `order_detail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_detail` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '名字',
  `image` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '图片',
  `order_id` bigint NOT NULL COMMENT '订单id',
  `dish_id` bigint DEFAULT NULL COMMENT '菜品id',
  `setmeal_id` bigint DEFAULT NULL COMMENT '套餐id',
  `dish_flavor` varchar(50) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '口味',
  `number` int NOT NULL DEFAULT '1' COMMENT '数量',
  `amount` decimal(10,2) NOT NULL COMMENT '金额',
  PRIMARY KEY (`id`),
  KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_bin COMMENT='订单明细表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_detail`
--

LOCK TABLES `order_detail` WRITE;
/*!40000 ALTER TABLE `order_detail` DISABLE KEYS */;
INSERT INTO `order_detail` VALUES (5,'草鱼2斤','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/9b9bc636-6a93-417b-811b-ef3242151c89.jpg',6,65,NULL,'中辣',1,68.00),(6,'东坡肘子','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/bb7bf73d-c0b3-4c1e-8d51-8e41fa461f0e.jpg',6,59,NULL,NULL,1,138.00),(7,'米饭','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/1aa13a7a-ecc4-498b-a640-737c8223838d.jpg',6,49,NULL,NULL,3,2.00),(8,'王老吉','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/7208d40a-c87a-4dd4-8ecd-b2b36090b9fc.jpg',6,46,NULL,NULL,1,6.00),(9,'北冰洋','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/b1a314db-a08c-4786-b63b-87496b9b365e.png',6,47,NULL,NULL,1,4.00),(10,'雪花啤酒','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/b58bfcb6-40dc-4415-a1f9-760198aa0c6f.jpg',6,48,NULL,NULL,1,4.00),(11,'平菇豆腐汤','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/45ea8f6d-e731-497a-8034-67425ee78d59.jpg',6,69,NULL,NULL,1,6.00),(12,'草鱼2斤','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/9b9bc636-6a93-417b-811b-ef3242151c89.jpg',7,65,NULL,'重辣',1,68.00),(13,'清炒小油菜','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/68982d51-956f-474e-bf35-5c0c92c0846d.jpg',7,54,NULL,'不要香菜',1,18.00),(14,'金汤酸菜牛蛙','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/8dc24dd0-57e4-4d4d-8025-6280102ac603.jpg',7,62,NULL,NULL,1,88.00),(15,'江团鱼2斤','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/5a9a88f7-cc84-4b8a-88be-e71b31b08660.jpg',8,66,NULL,'不辣',1,119.00),(16,'草鱼2斤','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/9b9bc636-6a93-417b-811b-ef3242151c89.jpg',9,65,NULL,'不辣',1,68.00),(17,'馒头','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/64c63bff-7633-4803-bcfa-c9ae943207fc.jpg',10,50,NULL,NULL,5,1.00),(18,'老坛酸菜鱼','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/dc9dcef9-8bfe-4f82-8ad1-d2e281050296.jpg',10,51,NULL,'不要蒜,中辣',1,56.00),(19,'鮰鱼2斤','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/710ade9f-c73b-4e25-9703-6ec9578acf1d.jpg',11,67,NULL,'不辣',1,72.00),(20,'蒜蓉娃娃菜','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/13a7ec6f-b908-43e7-be23-88d6ac328fe5.jpg',11,55,NULL,NULL,1,18.00),(21,'经典酸菜鮰鱼','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/6ab73f17-c77c-45d6-9c2d-dec0b6af73a3.jpg',11,52,NULL,'微辣,不要辣',1,66.00),(22,'平菇豆腐汤','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/45ea8f6d-e731-497a-8034-67425ee78d59.jpg',11,69,NULL,NULL,2,6.00),(23,'馒头','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/64c63bff-7633-4803-bcfa-c9ae943207fc.jpg',12,50,NULL,NULL,5,1.00),(24,'老坛酸菜鱼','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/dc9dcef9-8bfe-4f82-8ad1-d2e281050296.jpg',12,51,NULL,'不要蒜,中辣',1,56.00),(25,'江团鱼2斤','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/5a9a88f7-cc84-4b8a-88be-e71b31b08660.jpg',13,66,NULL,'中辣',1,119.00),(26,'清炒小油菜','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/68982d51-956f-474e-bf35-5c0c92c0846d.jpg',13,54,NULL,'不要香菜',1,18.00),(27,'东坡肘子','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/bb7bf73d-c0b3-4c1e-8d51-8e41fa461f0e.jpg',13,59,NULL,NULL,1,138.00),(28,'雪花啤酒','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/b58bfcb6-40dc-4415-a1f9-760198aa0c6f.jpg',13,48,NULL,NULL,3,4.00),(29,'鸡蛋汤','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/a57e89a0-283c-468c-b9cd-ffe72586a651.jpg',13,68,NULL,'常温',1,5.00),(30,'米饭','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/1aa13a7a-ecc4-498b-a640-737c8223838d.jpg',13,49,NULL,NULL,6,2.00),(31,'江团鱼2斤','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/5a9a88f7-cc84-4b8a-88be-e71b31b08660.jpg',14,66,NULL,'中辣',1,119.00),(32,'清炒小油菜','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/68982d51-956f-474e-bf35-5c0c92c0846d.jpg',15,54,NULL,'不要香菜',1,18.00),(33,'老坛酸菜鱼','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/dc9dcef9-8bfe-4f82-8ad1-d2e281050296.jpg',15,51,NULL,'不要葱,中辣',1,56.00);
/*!40000 ALTER TABLE `order_detail` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `number` varchar(50) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '订单号',
  `status` int NOT NULL DEFAULT '1' COMMENT '订单状态 1待付款 2待接单 3已接单 4派送中 5已完成 6已取消 7退款',
  `user_id` bigint NOT NULL COMMENT '下单用户',
  `address_book_id` bigint NOT NULL COMMENT '地址id',
  `order_time` datetime NOT NULL COMMENT '下单时间',
  `checkout_time` datetime DEFAULT NULL COMMENT '结账时间',
  `pay_method` int NOT NULL DEFAULT '1' COMMENT '支付方式 1微信,2支付宝',
  `pay_status` tinyint NOT NULL DEFAULT '0' COMMENT '支付状态 0未支付 1已支付 2退款',
  `amount` decimal(10,2) NOT NULL COMMENT '实收金额',
  `remark` varchar(100) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '备注',
  `phone` varchar(11) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '手机号',
  `address` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '地址',
  `user_name` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '用户名称',
  `consignee` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '收货人',
  `cancel_reason` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '订单取消原因',
  `rejection_reason` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '订单拒绝原因',
  `cancel_time` datetime DEFAULT NULL COMMENT '订单取消时间',
  `estimated_delivery_time` datetime DEFAULT NULL COMMENT '预计送达时间',
  `delivery_status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '配送状态  1立即送出  0选择具体时间',
  `delivery_time` datetime DEFAULT NULL COMMENT '送达时间',
  `pack_amount` int DEFAULT NULL COMMENT '打包费',
  `tableware_number` int DEFAULT NULL COMMENT '餐具数量',
  `tableware_status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '餐具数量状态  1按餐量提供  0选择具体数量',
  PRIMARY KEY (`id`),
  KEY `idx_status_order_time` (`status`,`order_time`),
  KEY `idx_user_id_order_time` (`user_id`,`order_time`),
  KEY `idx_order_time_status` (`order_time`,`status`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_bin COMMENT='订单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (6,'1779803454860',6,4,2,'2026-05-26 21:50:55',NULL,1,0,247.00,'','15501145441','1号',NULL,'张三','支付超时，自动取消',NULL,'2026-06-07 05:21:46','2026-05-26 22:50:00',0,NULL,9,0,0),(7,'1780315934669',6,4,2,'2026-06-01 20:12:15',NULL,1,0,183.00,'','15501145441','1号',NULL,'张三','支付超时，自动取消',NULL,'2026-06-07 05:21:46','2026-06-01 21:12:00',0,NULL,3,0,0),(8,'1780316576821',5,4,2,'2026-06-01 20:22:57','2026-06-01 20:32:58',1,1,126.00,'','15501145441','1号',NULL,'张三',NULL,NULL,NULL,'2026-06-01 21:22:00',0,'2026-06-19 17:45:41',1,0,0),(9,'1780317189057',6,4,2,'2026-06-01 20:33:09','2026-06-01 20:33:10',1,1,75.00,'','15501145441','1号',NULL,'张三',NULL,'餐厅已打烊，暂时无法接单','2026-06-05 16:53:00','2026-06-01 21:33:00',0,NULL,1,0,0),(10,'1780317240510',6,4,2,'2026-06-01 20:34:01','2026-06-01 20:34:01',1,1,73.00,'','15501145441','1号',NULL,'张三','用户取消',NULL,'2026-06-02 18:50:52','2026-06-01 21:33:00',0,NULL,6,0,0),(11,'1780317521815',5,4,2,'2026-06-01 20:38:42','2026-06-01 20:38:43',1,1,179.00,'','15501145441','1号',NULL,'张三',NULL,NULL,NULL,'2026-06-01 21:38:00',0,'2026-06-05 17:48:01',5,0,0),(12,'1780398569227',6,4,2,'2026-06-02 19:09:29','2026-06-02 19:09:31',1,1,73.00,'','15501145441','1号',NULL,'张三','订单量较多，暂时无法接单',NULL,'2026-06-05 17:40:39','2026-06-02 20:09:00',0,NULL,6,0,0),(13,'1780655083720',5,4,4,'2026-06-05 18:24:44','2026-06-05 18:24:46',1,1,323.00,'','13655220337','北京海淀颐和园路5号',NULL,'李四',NULL,NULL,NULL,'2026-06-05 19:24:00',0,'2026-06-19 17:45:40',13,0,0),(14,'1780824422398',5,4,4,'2026-06-07 17:27:02','2026-06-07 17:27:04',1,1,126.00,'','13655220337','北京海淀颐和园路5号',NULL,'李四',NULL,NULL,NULL,'2026-06-07 18:26:00',0,'2026-06-19 17:45:40',1,0,0),(15,'1780824598180',5,4,4,'2026-06-07 17:29:58','2026-06-07 17:29:59',1,1,82.00,'','13655220337','北京海淀颐和园路5号',NULL,'李四',NULL,NULL,NULL,'2026-06-07 18:29:00',0,'2026-06-19 17:45:39',2,0,0);
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_callback_log`
--

DROP TABLE IF EXISTS `payment_callback_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_callback_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `out_trade_no` varchar(64) NOT NULL COMMENT '商户订单号',
  `transaction_id` varchar(64) NOT NULL COMMENT '微信支付交易号',
  `create_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_out_trade_transaction` (`out_trade_no`,`transaction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='支付回调流水';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_callback_log`
--

LOCK TABLES `payment_callback_log` WRITE;
/*!40000 ALTER TABLE `payment_callback_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `payment_callback_log` ENABLE KEYS */;
UNLOCK TABLES;
--
-- Table structure for table `permission`
--

DROP TABLE IF EXISTS `permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permission` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(128) NOT NULL COMMENT '权限点，如 dish:add',
  `name` varchar(64) NOT NULL COMMENT '权限名称',
  `type` tinyint NOT NULL DEFAULT '2' COMMENT '1菜单 2按钮/接口',
  `parent_id` bigint DEFAULT NULL COMMENT '父级，前端做树用',
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `create_user` bigint DEFAULT NULL,
  `update_user` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='权限表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permission`
--

LOCK TABLES `permission` WRITE;
/*!40000 ALTER TABLE `permission` DISABLE KEYS */;
INSERT INTO `permission` VALUES (1,'dish:query','菜品查询',2,NULL,NULL,NULL,NULL,NULL),(2,'dish:add','菜品新增',2,NULL,NULL,NULL,NULL,NULL),(3,'dish:update','菜品修改',2,NULL,NULL,NULL,NULL,NULL),(4,'dish:delete','菜品删除',2,NULL,NULL,NULL,NULL,NULL),(5,'dish:status','菜品上下架',2,NULL,NULL,NULL,NULL,NULL),(6,'category:query','分类查询',2,NULL,NULL,NULL,NULL,NULL),(7,'category:add','分类新增',2,NULL,NULL,NULL,NULL,NULL),(8,'category:update','分类修改',2,NULL,NULL,NULL,NULL,NULL),(9,'category:delete','分类删除',2,NULL,NULL,NULL,NULL,NULL),(10,'category:status','分类启禁用',2,NULL,NULL,NULL,NULL,NULL),(11,'setmeal:query','套餐查询',2,NULL,NULL,NULL,NULL,NULL),(12,'setmeal:add','套餐新增',2,NULL,NULL,NULL,NULL,NULL),(13,'setmeal:update','套餐修改',2,NULL,NULL,NULL,NULL,NULL),(14,'setmeal:delete','套餐删除',2,NULL,NULL,NULL,NULL,NULL),(15,'setmeal:status','套餐上下架',2,NULL,NULL,NULL,NULL,NULL),(16,'order:query','订单查询',2,NULL,NULL,NULL,NULL,NULL),(17,'order:statistics','订单统计',2,NULL,NULL,NULL,NULL,NULL),(18,'report:export','报表导出',2,NULL,NULL,NULL,NULL,NULL),(19,'order:handle','订单处理',2,NULL,NULL,NULL,NULL,NULL),(20,'order:cancel','订单取消',2,NULL,NULL,NULL,NULL,NULL),(21,'employee:query','员工查询',2,NULL,NULL,NULL,NULL,NULL),(22,'employee:add','员工新增',2,NULL,NULL,NULL,NULL,NULL),(23,'employee:update','员工修改',2,NULL,NULL,NULL,NULL,NULL),(24,'employee:status','员工启用禁用',2,NULL,NULL,NULL,NULL,NULL),(25,'report:query','报表查询',2,NULL,NULL,NULL,NULL,NULL),(26,'shop:status','营业状态调整',2,NULL,NULL,NULL,NULL,NULL),(27,'role:query','角色查询',2,NULL,NULL,NULL,NULL,NULL),(28,'role:assign','角色权限分配',2,NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role`
--

DROP TABLE IF EXISTS `role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `code` varchar(64) NOT NULL COMMENT '角色编码，如 ADMIN',
  `name` varchar(64) NOT NULL COMMENT '角色名称',
  `description` varchar(255) DEFAULT NULL COMMENT '说明',
  `create_time` datetime DEFAULT NULL,
  `update_time` datetime DEFAULT NULL,
  `create_user` bigint DEFAULT NULL,
  `update_user` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role`
--

LOCK TABLES `role` WRITE;
/*!40000 ALTER TABLE `role` DISABLE KEYS */;
INSERT INTO `role` VALUES (1,'ADMIN','超级管理员','拥有全部权限',NULL,NULL,NULL,NULL),(2,'OPERATOR','运营','菜品/分类/套餐的日常维护',NULL,NULL,NULL,NULL),(3,'FINANCE','财务','订单查询与报表导出',NULL,NULL,NULL,NULL),(4,'KITCHEN','后厨','套餐制作与订单处理',NULL,NULL,NULL,NULL),(5,'CUSTOMER_SERVICE','客服','订单查询与处理',NULL,NULL,NULL,NULL),(6,'AUDITOR','审计','订单与报表只读',NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_permission`
--

DROP TABLE IF EXISTS `role_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permission` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `role_id` bigint NOT NULL COMMENT '角色id',
  `permission_id` bigint NOT NULL COMMENT '权限id',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_perm` (`role_id`,`permission_id`)
) ENGINE=InnoDB AUTO_INCREMENT=79 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色-权限关联';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_permission`
--

LOCK TABLES `role_permission` WRITE;
/*!40000 ALTER TABLE `role_permission` DISABLE KEYS */;
INSERT INTO `role_permission` VALUES (8,1,1),(6,1,2),(10,1,3),(7,1,4),(9,1,5),(3,1,6),(1,1,7),(5,1,8),(2,1,9),(4,1,10),(16,1,11),(14,1,12),(18,1,13),(15,1,14),(17,1,15),(11,1,16),(12,1,17),(13,1,18),(39,2,1),(37,2,2),(41,2,3),(38,2,4),(40,2,5),(34,2,6),(32,2,7),(36,2,8),(33,2,9),(35,2,10),(44,2,11),(42,2,12),(46,2,13),(43,2,14),(45,2,15),(47,3,16),(48,3,17),(49,3,18),(50,1,19),(51,1,20),(52,1,21),(53,1,22),(54,1,23),(55,1,24),(56,1,25),(57,1,26),(58,2,16),(59,2,19),(60,2,20),(61,3,25),(62,1,27),(63,1,28),(64,4,11),(65,4,12),(66,4,13),(67,4,14),(68,4,15),(69,4,16),(70,4,19),(71,5,16),(72,5,19),(73,5,20),(74,5,25),(75,6,16),(76,6,17),(77,6,18),(78,6,25);
/*!40000 ALTER TABLE `role_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `setmeal`
--

DROP TABLE IF EXISTS `setmeal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `setmeal` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `category_id` bigint NOT NULL COMMENT '菜品分类id',
  `name` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '套餐名称',
  `price` decimal(10,2) NOT NULL COMMENT '套餐价格',
  `status` int DEFAULT '1' COMMENT '售卖状态 0:停售 1:起售',
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '描述信息',
  `image` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '图片',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `create_user` bigint DEFAULT NULL COMMENT '创建人',
  `update_user` bigint DEFAULT NULL COMMENT '修改人',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_setmeal_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_bin COMMENT='套餐';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `setmeal`
--

LOCK TABLES `setmeal` WRITE;
/*!40000 ALTER TABLE `setmeal` DISABLE KEYS */;
INSERT INTO `setmeal` VALUES (33,15,'BBBAA',1888.00,1,'好吃不贵','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/c1163ffe-2205-41f5-990f-b814546e5747.jpg','2026-04-23 07:32:21','2026-05-15 08:18:40',1,1),(34,13,'abbc',188.00,1,'','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/cef22c3d-068b-4f4f-b3ec-a6ea2f507e96.jpg','2026-05-15 08:20:16','2026-05-15 08:20:21',1,1);
/*!40000 ALTER TABLE `setmeal` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `setmeal_dish`
--

DROP TABLE IF EXISTS `setmeal_dish`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `setmeal_dish` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `setmeal_id` bigint DEFAULT NULL COMMENT '套餐id',
  `dish_id` bigint DEFAULT NULL COMMENT '菜品id',
  `name` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '菜品名称 （冗余字段）',
  `price` decimal(10,2) DEFAULT NULL COMMENT '菜品单价（冗余字段）',
  `copies` int DEFAULT NULL COMMENT '菜品份数',
  PRIMARY KEY (`id`),
  KEY `idx_setmeal_id` (`setmeal_id`)
) ENGINE=InnoDB AUTO_INCREMENT=120 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_bin COMMENT='套餐菜品关系';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `setmeal_dish`
--

LOCK TABLES `setmeal_dish` WRITE;
/*!40000 ALTER TABLE `setmeal_dish` DISABLE KEYS */;
INSERT INTO `setmeal_dish` VALUES (47,NULL,69,'平菇豆腐汤',6.00,1),(48,NULL,48,'雪花啤酒',4.00,1),(49,NULL,49,'米饭',2.00,1),(50,NULL,56,'清炒西兰花',18.00,1),(51,NULL,59,'东坡肘子',138.00,1),(52,NULL,65,'草鱼2斤',68.00,1),(53,NULL,62,'金汤酸菜牛蛙',88.00,1),(54,NULL,67,'鮰鱼2斤',72.00,1),(55,NULL,65,'草鱼2斤',68.00,1),(56,NULL,69,'平菇豆腐汤',6.00,1),(57,NULL,47,'北冰洋',4.00,1),(58,NULL,49,'米饭',2.00,1),(59,NULL,58,'清蒸鲈鱼',98.00,1),(60,NULL,59,'东坡肘子',138.00,1),(61,NULL,55,'蒜蓉娃娃菜',18.00,1),(62,NULL,54,'清炒小油菜',18.00,1),(103,33,69,'平菇豆腐汤',6.00,1),(104,33,46,'王老吉',6.00,1),(105,33,47,'北冰洋',4.00,1),(106,33,49,'米饭',2.00,1),(107,33,51,'老坛酸菜鱼',56.00,1),(108,33,54,'清炒小油菜',18.00,1),(109,33,55,'蒜蓉娃娃菜',18.00,1),(110,33,59,'东坡肘子',138.00,1),(111,33,60,'梅菜扣肉',58.00,1),(112,33,67,'鮰鱼2斤',72.00,1),(113,NULL,68,'鸡蛋汤',5.00,1),(114,NULL,48,'雪花啤酒',4.00,1),(115,NULL,47,'北冰洋',4.00,1),(116,NULL,49,'米饭',2.00,1),(117,NULL,54,'清炒小油菜',18.00,1),(118,NULL,62,'金汤酸菜牛蛙',88.00,1),(119,NULL,65,'草鱼2斤',68.00,1);
/*!40000 ALTER TABLE `setmeal_dish` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shopping_cart`
--

DROP TABLE IF EXISTS `shopping_cart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `shopping_cart` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '商品名称',
  `image` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '图片',
  `user_id` bigint NOT NULL COMMENT '主键',
  `dish_id` bigint DEFAULT NULL COMMENT '菜品id',
  `setmeal_id` bigint DEFAULT NULL COMMENT '套餐id',
  `dish_flavor` varchar(50) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '口味',
  `number` int NOT NULL DEFAULT '1' COMMENT '数量',
  `amount` decimal(10,2) NOT NULL COMMENT '金额',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_bin COMMENT='购物车';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shopping_cart`
--

LOCK TABLES `shopping_cart` WRITE;
/*!40000 ALTER TABLE `shopping_cart` DISABLE KEYS */;
/*!40000 ALTER TABLE `shopping_cart` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `openid` varchar(45) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '微信用户唯一标识',
  `name` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '姓名',
  `phone` varchar(11) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '手机号',
  `sex` varchar(2) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '性别',
  `id_number` varchar(18) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '身份证号',
  `avatar` varchar(500) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '头像',
  `create_time` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8_bin COMMENT='用户信息';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (4,'oOrNV3drYzEfA3lsGkBuNVfnHPJ4',NULL,NULL,NULL,NULL,NULL,'2026-04-30 17:59:25');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-23 19:47:48
