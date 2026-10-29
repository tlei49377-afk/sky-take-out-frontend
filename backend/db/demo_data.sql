-- ============================================================
-- 智能外卖平台演示数据
-- 在导入 backend/db/sky_take_out.sql 之后执行。
-- 本脚本只维护 500-599 和 5001-5099 范围内的演示数据，可重复执行。
-- ============================================================

SET NAMES utf8mb4;
START TRANSACTION;

-- 演示顾客：覆盖最近 7 天，便于用户统计图展示变化趋势
DELETE FROM `user` WHERE `id` BETWEEN 501 AND 599;
INSERT INTO `user` (`id`,`openid`,`name`,`phone`,`sex`,`id_number`,`avatar`,`create_time`) VALUES
(501,'demo-openid-501','林晓雨','13800000501','1',NULL,NULL,DATE_SUB(CURDATE(), INTERVAL 6 DAY)),
(502,'demo-openid-502','周子航','13800000502','0',NULL,NULL,DATE_SUB(CURDATE(), INTERVAL 6 DAY)),
(503,'demo-openid-503','陈思远','13800000503','1',NULL,NULL,DATE_SUB(CURDATE(), INTERVAL 5 DAY)),
(504,'demo-openid-504','许安然','13800000504','0',NULL,NULL,DATE_SUB(CURDATE(), INTERVAL 4 DAY)),
(505,'demo-openid-505','黄嘉禾','13800000505','1',NULL,NULL,DATE_SUB(CURDATE(), INTERVAL 4 DAY)),
(506,'demo-openid-506','吴可欣','13800000506','0',NULL,NULL,DATE_SUB(CURDATE(), INTERVAL 3 DAY)),
(507,'demo-openid-507','赵明轩','13800000507','1',NULL,NULL,DATE_SUB(CURDATE(), INTERVAL 2 DAY)),
(508,'demo-openid-508','唐雨桐','13800000508','0',NULL,NULL,DATE_SUB(CURDATE(), INTERVAL 2 DAY)),
(509,'demo-openid-509','何俊杰','13800000509','1',NULL,NULL,DATE_SUB(CURDATE(), INTERVAL 1 DAY)),
(510,'demo-openid-510','苏梦琪','13800000510','0',NULL,NULL,CURDATE()),
(511,'demo-openid-511','梁浩然','13800000511','1',NULL,NULL,CURDATE()),
(512,'demo-openid-512','宋若溪','13800000512','0',NULL,NULL,CURDATE());

-- 演示地址
DELETE FROM `address_book` WHERE `id` BETWEEN 501 AND 599;
INSERT INTO `address_book` (`id`,`user_id`,`consignee`,`sex`,`phone`,`province_code`,`province_name`,`city_code`,`city_name`,`district_code`,`district_name`,`detail`,`label`,`is_default`) VALUES
(501,501,'林晓雨','1','13800000501','46','海南省','4602','三亚市','460202','吉阳区','育才路 18 号海韵公寓 3 栋','公司',1),
(502,502,'周子航','0','13800000502','46','海南省','4602','三亚市','460202','吉阳区','榆亚路 66 号 2 单元','家',1),
(503,503,'陈思远','1','13800000503','46','海南省','4602','三亚市','460203','天涯区','解放路 128 号','学校',1),
(504,504,'许安然','0','13800000504','46','海南省','4602','三亚市','460202','吉阳区','凤凰路 88 号','家',1),
(505,505,'黄嘉禾','1','13800000505','46','海南省','4602','三亚市','460203','天涯区','迎宾路 216 号','公司',1);

-- 套餐：替换测试名称并补充不同套餐
DELETE FROM `setmeal_dish` WHERE `id` BETWEEN 5001 AND 5099 OR `setmeal_id` BETWEEN 501 AND 599;
DELETE FROM `setmeal` WHERE `id` BETWEEN 501 AND 599;
INSERT INTO `setmeal` (`id`,`category_id`,`name`,`price`,`status`,`description`,`image`,`create_time`,`update_time`,`create_user`,`update_user`) VALUES
(501,13,'经典双人餐',128.00,1,'两荤一素，适合两位顾客日常用餐','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/c1163ffe-2205-41f5-990f-b814546e5747.jpg',NOW(),NOW(),1,1),
(502,15,'酸菜鱼精选套餐',168.00,1,'招牌酸菜鱼搭配时蔬与主食','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/cef22c3d-068b-4f4f-b3ec-a6ea2f507e96.jpg',NOW(),NOW(),1,1),
(503,13,'家常小炒套餐',98.00,1,'清爽家常菜组合，工作日午餐推荐','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/c1163ffe-2205-41f5-990f-b814546e5747.jpg',NOW(),NOW(),1,1),
(504,15,'周末欢聚套餐',228.00,0,'多人分享套餐，周末聚餐饮品齐全','https://sky-take-out-ith.oss-cn-beijing.aliyuncs.com/cef22c3d-068b-4f4f-b3ec-a6ea2f507e96.jpg',NOW(),NOW(),1,1);

-- 整理原有的两条测试套餐，避免截图和演示页面出现无意义名称
UPDATE `setmeal` SET `category_id`=15, `name`='双人招牌鱼宴', `price`=288.00, `status`=0, `description`='招牌鱼类组合，适合双人聚餐', `update_time`=NOW(), `update_user`=1 WHERE `id`=33;
UPDATE `setmeal` SET `category_id`=13, `name`='家庭营养套餐', `price`=188.00, `status`=1, `description`='荤素搭配，适合家庭日常用餐', `update_time`=NOW(), `update_user`=1 WHERE `id`=34;
INSERT INTO `setmeal_dish` (`id`,`setmeal_id`,`dish_id`,`name`,`price`,`copies`) VALUES
(5001,501,51,'老坛酸菜鱼',56.00,1),
(5002,501,54,'清炒小油菜',18.00,1),
(5003,501,49,'米饭',2.00,2),
(5004,502,59,'东坡肘子',138.00,1),
(5005,502,68,'鸡蛋汤',5.00,1),
(5006,502,49,'米饭',2.00,2),
(5007,503,54,'清炒小油菜',18.00,1),
(5008,503,55,'蒜蓉娃娃菜',18.00,1),
(5009,503,49,'米饭',2.00,2),
(5010,504,65,'草鱼2斤',68.00,1),
(5011,504,67,'鮰鱼2斤',72.00,1),
(5012,504,68,'鸡蛋汤',5.00,1),
(5013,504,49,'米饭',2.00,4);

-- 更新原有测试菜名，保留菜品图片和菜品关系
UPDATE `dish` SET `name`='时令水果拼盘', `description`='精选当季水果，清爽解腻', `update_time`=NOW(), `update_user`=1 WHERE `id`=71;

-- 订单：覆盖待付款、待接单、已接单、派送中、已完成、已取消和退款
DELETE FROM `order_detail` WHERE `order_id` BETWEEN 5001 AND 5099;
DELETE FROM `orders` WHERE `id` BETWEEN 5001 AND 5099;
INSERT INTO `orders` (`id`,`number`,`status`,`user_id`,`address_book_id`,`order_time`,`checkout_time`,`pay_method`,`pay_status`,`amount`,`remark`,`phone`,`address`,`user_name`,`consignee`,`cancel_reason`,`rejection_reason`,`cancel_time`,`estimated_delivery_time`,`delivery_status`,`delivery_time`,`pack_amount`,`tableware_number`,`tableware_status`) VALUES
(5001,CONCAT(DATE_FORMAT(CURDATE(),'%Y%m%d'),'0001'),1,510,501,TIMESTAMP(CURDATE(),'09:10:00'),NULL,1,0,76.00,'少放辣','13800000501','海南省三亚市吉阳区育才路 18 号海韵公寓 3 栋','林晓雨','林晓雨',NULL,NULL,NULL,TIMESTAMP(CURDATE(),'10:10:00'),0,NULL,3,1,1),
(5002,CONCAT(DATE_FORMAT(CURDATE(),'%Y%m%d'),'0002'),2,511,502,TIMESTAMP(CURDATE(),'10:05:00'),TIMESTAMP(CURDATE(),'10:06:00'),1,1,128.00,'米饭两份','13800000502','海南省三亚市吉阳区榆亚路 66 号 2 单元','周子航','周子航',NULL,NULL,NULL,TIMESTAMP(CURDATE(),'11:05:00'),0,NULL,3,2,0),
(5003,CONCAT(DATE_FORMAT(CURDATE(),'%Y%m%d'),'0003'),2,512,503,TIMESTAMP(CURDATE(),'10:35:00'),TIMESTAMP(CURDATE(),'10:36:00'),1,1,96.00,'不要香菜','13800000503','海南省三亚市天涯区解放路 128 号','陈思远','陈思远',NULL,NULL,NULL,TIMESTAMP(CURDATE(),'11:35:00'),0,NULL,2,1,1),
(5004,CONCAT(DATE_FORMAT(CURDATE(),'%Y%m%d'),'0004'),3,501,501,TIMESTAMP(CURDATE(),'11:20:00'),TIMESTAMP(CURDATE(),'11:21:00'),1,1,158.00,'餐具按餐量提供','13800000501','海南省三亚市吉阳区育才路 18 号海韵公寓 3 栋','林晓雨','林晓雨',NULL,NULL,NULL,TIMESTAMP(CURDATE(),'12:20:00'),0,NULL,4,0,1),
(5005,CONCAT(DATE_FORMAT(CURDATE(),'%Y%m%d'),'0005'),3,502,502,TIMESTAMP(CURDATE(),'11:45:00'),TIMESTAMP(CURDATE(),'11:46:00'),1,1,88.00,'微辣','13800000502','海南省三亚市吉阳区榆亚路 66 号 2 单元','周子航','周子航',NULL,NULL,NULL,TIMESTAMP(CURDATE(),'12:45:00'),0,NULL,2,2,0),
(5006,CONCAT(DATE_FORMAT(CURDATE(),'%Y%m%d'),'0006'),4,503,503,TIMESTAMP(CURDATE(),'12:10:00'),TIMESTAMP(CURDATE(),'12:11:00'),1,1,126.00,'送到前台','13800000503','海南省三亚市天涯区解放路 128 号','陈思远','陈思远',NULL,NULL,NULL,TIMESTAMP(CURDATE(),'13:10:00'),0,NULL,3,1,1),
(5007,CONCAT(DATE_FORMAT(CURDATE(),'%Y%m%d'),'0007'),5,504,504,TIMESTAMP(CURDATE(),'12:30:00'),TIMESTAMP(CURDATE(),'12:31:00'),1,1,156.00,NULL,'13800000504','海南省三亚市吉阳区凤凰路 88 号','许安然','许安然',NULL,NULL,NULL,TIMESTAMP(CURDATE(),'13:30:00'),0,TIMESTAMP(CURDATE(),'13:05:00'),4,2,0),
(5008,CONCAT(DATE_FORMAT(CURDATE(),'%Y%m%d'),'0008'),5,505,505,TIMESTAMP(CURDATE(),'13:05:00'),TIMESTAMP(CURDATE(),'13:06:00'),1,1,208.00,'请多放米饭','13800000505','海南省三亚市天涯区迎宾路 216 号','黄嘉禾','黄嘉禾',NULL,NULL,NULL,TIMESTAMP(CURDATE(),'14:05:00'),0,TIMESTAMP(CURDATE(),'13:42:00'),6,3,0),
(5009,CONCAT(DATE_FORMAT(CURDATE(),'%Y%m%d'),'0009'),5,506,501,TIMESTAMP(CURDATE(),'17:10:00'),TIMESTAMP(CURDATE(),'17:11:00'),1,1,98.00,NULL,'13800000506','海南省三亚市吉阳区育才路 18 号海韵公寓 3 栋','吴可欣','吴可欣',NULL,NULL,NULL,TIMESTAMP(CURDATE(),'18:10:00'),0,TIMESTAMP(CURDATE(),'17:36:00'),2,1,1),
(5010,CONCAT(DATE_FORMAT(CURDATE(),'%Y%m%d'),'0010'),6,507,502,TIMESTAMP(CURDATE(),'14:20:00'),TIMESTAMP(CURDATE(),'14:21:00'),1,1,72.00,NULL,'13800000507','海南省三亚市吉阳区榆亚路 66 号 2 单元','赵明轩','赵明轩','用户临时取消',NULL,TIMESTAMP(CURDATE(),'14:25:00'),TIMESTAMP(CURDATE(),'15:20:00'),0,NULL,2,1,1),
(5011,CONCAT(DATE_FORMAT(CURDATE(),'%Y%m%d'),'0011'),7,508,503,TIMESTAMP(CURDATE(),'15:00:00'),TIMESTAMP(CURDATE(),'15:01:00'),1,2,58.00,NULL,'13800000508','海南省三亚市天涯区解放路 128 号','唐雨桐','唐雨桐','商家同意退款',NULL,TIMESTAMP(CURDATE(),'15:15:00'),TIMESTAMP(CURDATE(),'16:00:00'),0,NULL,1,1,1),
(5012,CONCAT(DATE_FORMAT(CURDATE(),'%Y%m%d'),'0012'),5,509,504,TIMESTAMP(CURDATE(),'16:15:00'),TIMESTAMP(CURDATE(),'16:16:00'),1,1,88.00,NULL,'13800000509','海南省三亚市吉阳区凤凰路 88 号','苏梦琪','苏梦琪',NULL,NULL,NULL,TIMESTAMP(CURDATE(),'17:15:00'),0,TIMESTAMP(CURDATE(),'16:48:00'),2,1,1),
(5013,CONCAT(DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),'%Y%m%d'),'0013'),5,510,501,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY),'12:20:00'),TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY),'12:21:00'),1,1,186.00,NULL,'13800000510','海南省三亚市吉阳区育才路 18 号海韵公寓 3 栋','梁浩然','梁浩然',NULL,NULL,NULL,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY),'13:20:00'),0,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY),'13:02:00'),4,2,0),
(5014,CONCAT(DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 DAY),'%Y%m%d'),'0014'),5,511,502,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY),'18:10:00'),TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY),'18:11:00'),1,1,132.00,NULL,'13800000511','海南省三亚市吉阳区榆亚路 66 号 2 单元','宋若溪','宋若溪',NULL,NULL,NULL,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY),'19:10:00'),0,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 1 DAY),'18:47:00'),3,1,1),
(5015,CONCAT(DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 2 DAY),'%Y%m%d'),'0015'),5,512,503,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 2 DAY),'19:05:00'),TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 2 DAY),'19:06:00'),1,1,174.00,NULL,'13800000512','海南省三亚市天涯区解放路 128 号','陈思远','陈思远',NULL,NULL,NULL,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 2 DAY),'20:05:00'),0,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 2 DAY),'19:43:00'),4,2,0),
(5016,CONCAT(DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 3 DAY),'%Y%m%d'),'0016'),5,501,501,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 3 DAY),'12:30:00'),TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 3 DAY),'12:31:00'),1,1,146.00,NULL,'13800000501','海南省三亚市吉阳区育才路 18 号海韵公寓 3 栋','林晓雨','林晓雨',NULL,NULL,NULL,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 3 DAY),'13:30:00'),0,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 3 DAY),'13:08:00'),3,1,1),
(5017,CONCAT(DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 3 DAY),'%Y%m%d'),'0017'),5,502,502,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 3 DAY),'18:25:00'),TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 3 DAY),'18:26:00'),1,1,214.00,NULL,'13800000502','海南省三亚市吉阳区榆亚路 66 号 2 单元','周子航','周子航',NULL,NULL,NULL,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 3 DAY),'19:25:00'),0,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 3 DAY),'18:59:00'),5,3,0),
(5018,CONCAT(DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 4 DAY),'%Y%m%d'),'0018'),5,503,503,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 4 DAY),'19:10:00'),TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 4 DAY),'19:11:00'),1,1,168.00,NULL,'13800000503','海南省三亚市天涯区解放路 128 号','陈思远','陈思远',NULL,NULL,NULL,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 4 DAY),'20:10:00'),0,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 4 DAY),'19:49:00'),4,2,0),
(5019,CONCAT(DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 5 DAY),'%Y%m%d'),'0019'),5,504,504,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 5 DAY),'12:40:00'),TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 5 DAY),'12:41:00'),1,1,192.00,NULL,'13800000504','海南省三亚市吉阳区凤凰路 88 号','许安然','许安然',NULL,NULL,NULL,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 5 DAY),'13:40:00'),0,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 5 DAY),'13:18:00'),5,2,0),
(5020,CONCAT(DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 6 DAY),'%Y%m%d'),'0020'),5,505,505,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 6 DAY),'18:50:00'),TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 6 DAY),'18:51:00'),1,1,226.00,NULL,'13800000505','海南省三亚市天涯区迎宾路 216 号','黄嘉禾','黄嘉禾',NULL,NULL,NULL,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 6 DAY),'19:50:00'),0,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 6 DAY),'19:26:00'),6,3,0),
(5021,CONCAT(DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 7 DAY),'%Y%m%d'),'0021'),5,506,501,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 7 DAY),'13:15:00'),TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 7 DAY),'13:16:00'),1,1,154.00,NULL,'13800000506','海南省三亚市吉阳区育才路 18 号海韵公寓 3 栋','吴可欣','吴可欣',NULL,NULL,NULL,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 7 DAY),'14:15:00'),0,TIMESTAMP(DATE_SUB(CURDATE(), INTERVAL 7 DAY),'13:55:00'),3,1,1);

-- 订单明细：支撑销量排行、订单详情和报表
INSERT INTO `order_detail` (`id`,`name`,`image`,`order_id`,`dish_id`,`setmeal_id`,`dish_flavor`,`number`,`amount`) VALUES
(5001,'老坛酸菜鱼',NULL,5001,51,NULL,'中辣',1,56.00),(5002,'米饭',NULL,5001,49,NULL,NULL,2,2.00),(5003,'王老吉',NULL,5001,46,NULL,NULL,1,6.00),
(5004,'经典双人餐',NULL,5002,NULL,501,NULL,1,128.00),(5005,'清炒小油菜',NULL,5002,54,NULL,NULL,1,18.00),
(5006,'金汤酸菜牛蛙',NULL,5003,62,NULL,'微辣',1,88.00),(5007,'米饭',NULL,5003,49,NULL,NULL,2,2.00),
(5008,'东坡肘子',NULL,5004,59,NULL,NULL,1,138.00),(5009,'清炒小油菜',NULL,5004,54,NULL,NULL,1,18.00),
(5010,'香锅牛蛙',NULL,5005,63,NULL,'中辣',1,88.00),(5011,'鸡蛋汤',NULL,5005,68,NULL,NULL,1,5.00),
(5012,'江团鱼2斤',NULL,5006,66,NULL,'中辣',1,119.00),(5013,'米饭',NULL,5006,49,NULL,NULL,2,2.00),
(5014,'清蒸鲈鱼',NULL,5007,58,NULL,NULL,1,98.00),(5015,'蒜蓉娃娃菜',NULL,5007,55,NULL,NULL,1,18.00),(5016,'米饭',NULL,5007,49,NULL,NULL,4,2.00),
(5017,'酸菜鱼精选套餐',NULL,5008,NULL,502,NULL,1,168.00),(5018,'米饭',NULL,5008,49,NULL,NULL,4,2.00),
(5019,'家常小炒套餐',NULL,5009,NULL,503,NULL,1,98.00),(5020,'炝炒圆白菜',NULL,5009,57,NULL,NULL,1,18.00),
(5021,'鮰鱼2斤',NULL,5010,67,NULL,'不辣',1,72.00),(5022,'米饭',NULL,5010,49,NULL,NULL,2,2.00),
(5023,'清炒小油菜',NULL,5011,54,NULL,NULL,1,18.00),(5024,'平菇豆腐汤',NULL,5011,69,NULL,NULL,1,6.00),
(5025,'金汤酸菜牛蛙',NULL,5012,62,NULL,'微辣',1,88.00),(5026,'米饭',NULL,5012,49,NULL,NULL,2,2.00),
(5027,'草鱼2斤',NULL,5013,65,NULL,'中辣',1,68.00),(5028,'清炒小油菜',NULL,5013,54,NULL,NULL,1,18.00),(5029,'米饭',NULL,5013,49,NULL,NULL,4,2.00),
(5030,'经典双人餐',NULL,5014,NULL,501,NULL,1,128.00),(5031,'鸡蛋汤',NULL,5014,68,NULL,NULL,1,5.00),
(5032,'酸菜鱼精选套餐',NULL,5015,NULL,502,NULL,1,168.00),(5033,'王老吉',NULL,5015,46,NULL,NULL,1,6.00),
(5034,'东坡肘子',NULL,5016,59,NULL,NULL,1,138.00),(5035,'蒜蓉娃娃菜',NULL,5016,55,NULL,NULL,1,18.00),
(5036,'江团鱼2斤',NULL,5017,66,NULL,'中辣',1,119.00),(5037,'清炒西兰花',NULL,5017,56,NULL,NULL,1,18.00),(5038,'米饭',NULL,5017,49,NULL,NULL,4,2.00),
(5039,'老坛酸菜鱼',NULL,5018,51,NULL,'中辣',1,56.00),(5040,'经典酸菜鮰鱼',NULL,5018,52,NULL,'微辣',1,66.00),(5041,'米饭',NULL,5018,49,NULL,NULL,4,2.00),
(5042,'香锅牛蛙',NULL,5019,63,NULL,'微辣',1,88.00),(5043,'清炒小油菜',NULL,5019,54,NULL,NULL,1,18.00),(5044,'米饭',NULL,5019,49,NULL,NULL,4,2.00),
(5045,'家常小炒套餐',NULL,5020,NULL,503,NULL,1,98.00),(5046,'鸡蛋汤',NULL,5020,68,NULL,NULL,2,5.00),
(5047,'草鱼2斤',NULL,5021,65,NULL,'中辣',1,68.00),(5048,'平菇豆腐汤',NULL,5021,69,NULL,NULL,1,6.00),(5049,'米饭',NULL,5021,49,NULL,NULL,4,2.00);

COMMIT;

SELECT '演示数据导入完成' AS message,
       (SELECT COUNT(*) FROM orders WHERE id BETWEEN 5001 AND 5099) AS demo_orders,
       (SELECT COUNT(*) FROM user WHERE id BETWEEN 501 AND 599) AS demo_users,
       (SELECT COUNT(*) FROM setmeal WHERE id BETWEEN 501 AND 599) AS demo_setmeals;
