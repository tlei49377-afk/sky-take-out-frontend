-- ============================================================
-- V6：慢 SQL 治理，给高频查询补索引
-- 每个索引对应一条实际 SQL，来源见 README「性能优化」一节
-- 脚本可重复执行：已存在的索引会被跳过
-- ============================================================

USE sky_take_out;

DROP PROCEDURE IF EXISTS sky_add_index;

DELIMITER //
CREATE PROCEDURE sky_add_index(IN p_table VARCHAR(64), IN p_index VARCHAR(64), IN p_cols VARCHAR(255))
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.statistics
                 WHERE table_schema = DATABASE() AND table_name = p_table AND index_name = p_index) THEN
    SET @ddl = CONCAT('ALTER TABLE `', p_table, '` ADD INDEX `', p_index, '` (', p_cols, ')');
    PREPARE stmt FROM @ddl;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END IF;
END //
DELIMITER ;

-- orders：定时任务「按状态 + 下单时间」扫未支付超时单
--         带状态的营业额统计、管理端按状态筛选的订单分页
CALL sky_add_index('orders', 'idx_status_order_time', 'status, order_time');

-- orders：用户端历史订单，按 user_id 过滤 + 按 order_time 倒序
CALL sky_add_index('orders', 'idx_user_id_order_time', 'user_id, order_time');

-- orders：不带状态的时间范围统计（用户统计）、无过滤的订单列表排序，
--         以及「时间范围 + 状态过滤」的订单分页。
--         把 status 并进索引是为了让状态条件在索引内过滤（不回表），
--         单独建 (order_time) 会让优化器走了索引却仍要逐行回表判断 status
CALL sky_add_index('orders', 'idx_order_time_status', 'order_time, status');

-- order_detail：订单明细按 order_id 查、销量 Top10 的 join 驱动列
CALL sky_add_index('order_detail', 'idx_order_id', 'order_id');

-- dish_flavor：菜品口味按 dish_id 查 / 删
CALL sky_add_index('dish_flavor', 'idx_dish_id', 'dish_id');

-- setmeal_dish：套餐包含的菜品按 setmeal_id 查 / 删
CALL sky_add_index('setmeal_dish', 'idx_setmeal_id', 'setmeal_id');

-- employee：员工分页按 create_time 倒序
CALL sky_add_index('employee', 'idx_create_time', 'create_time');

-- employee_role：按角色反查员工（改角色权限后失效缓存要用），
--                现有 uk_emp_role 左前缀是 employee_id，用不上
CALL sky_add_index('employee_role', 'idx_role_id', 'role_id');

-- shopping_cart：购物车按 user_id 查 / 清空
CALL sky_add_index('shopping_cart', 'idx_user_id', 'user_id');

-- address_book：地址簿按 user_id 查
CALL sky_add_index('address_book', 'idx_user_id', 'user_id');

DROP PROCEDURE sky_add_index;