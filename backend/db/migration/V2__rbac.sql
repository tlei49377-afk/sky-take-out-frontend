-- ============================================================
-- V2：RBAC 角色权限模型
-- 权限点命名统一为「模块:操作」，如 dish:add
-- ============================================================

USE sky_take_out;

CREATE TABLE role (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  code VARCHAR(64) NOT NULL UNIQUE COMMENT '角色编码，如 ADMIN',
  name VARCHAR(64) NOT NULL COMMENT '角色名称',
  description VARCHAR(255) COMMENT '说明',
  create_time DATETIME, update_time DATETIME,
  create_user BIGINT, update_user BIGINT
) COMMENT '角色表';

CREATE TABLE permission (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  code VARCHAR(128) NOT NULL UNIQUE COMMENT '权限点，如 dish:add',
  name VARCHAR(64) NOT NULL COMMENT '权限名称',
  type TINYINT NOT NULL DEFAULT 2 COMMENT '1菜单 2按钮/接口',
  parent_id BIGINT DEFAULT NULL COMMENT '父级，前端做树用',
  create_time DATETIME, update_time DATETIME,
  create_user BIGINT, update_user BIGINT
) COMMENT '权限表';

CREATE TABLE employee_role (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  employee_id BIGINT NOT NULL COMMENT '员工id',
  role_id BIGINT NOT NULL COMMENT '角色id',
  UNIQUE KEY uk_emp_role (employee_id, role_id)
) COMMENT '员工-角色关联';

CREATE TABLE role_permission (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  role_id BIGINT NOT NULL COMMENT '角色id',
  permission_id BIGINT NOT NULL COMMENT '权限id',
  UNIQUE KEY uk_role_perm (role_id, permission_id)
) COMMENT '角色-权限关联';

-- ---------------- 初始数据 ----------------

INSERT INTO role (id, code, name, description) VALUES
 (1, 'ADMIN',    '超级管理员', '拥有全部权限'),
 (2, 'OPERATOR', '运营',       '菜品/分类/套餐的日常维护'),
 (3, 'FINANCE',  '财务',       '订单查询与报表导出');

INSERT INTO permission (code, name) VALUES
 ('dish:query',       '菜品查询'),
 ('dish:add',         '菜品新增'),
 ('dish:update',      '菜品修改'),
 ('dish:delete',      '菜品删除'),
 ('dish:status',      '菜品上下架'),
 ('category:query',   '分类查询'),
 ('category:add',     '分类新增'),
 ('category:update',  '分类修改'),
 ('category:delete',  '分类删除'),
 ('category:status',  '分类启禁用'),
 ('setmeal:query',    '套餐查询'),
 ('setmeal:add',      '套餐新增'),
 ('setmeal:update',   '套餐修改'),
 ('setmeal:delete',   '套餐删除'),
 ('setmeal:status',   '套餐上下架'),
 ('order:query',      '订单查询'),
 ('order:statistics', '订单统计'),
 ('report:export',    '报表导出');

-- 超级管理员：全部
INSERT INTO role_permission (role_id, permission_id)
SELECT 1, id FROM permission;

-- 运营：菜品 / 分类 / 套餐
INSERT INTO role_permission (role_id, permission_id)
SELECT 2, id FROM permission
WHERE code LIKE 'dish:%' OR code LIKE 'category:%' OR code LIKE 'setmeal:%';

-- 财务：订单查询 + 统计 + 报表
INSERT INTO role_permission (role_id, permission_id)
SELECT 3, id FROM permission
WHERE code IN ('order:query', 'order:statistics', 'report:export');

-- 员工分配：1=admin  3=李四(lisi)  10=黎静(liming)
INSERT INTO employee_role (employee_id, role_id) VALUES (1, 1), (3, 2), (10, 3);
