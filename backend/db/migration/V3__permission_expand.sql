-- ============================================================
-- V3：补充订单处理、员工管理、报表、店铺状态权限点
-- 依赖 V2 的 role / permission / role_permission 表与初始数据
-- ============================================================

USE sky_take_out;

INSERT IGNORE INTO permission (code, name) VALUES
('order:handle',    '订单处理'),
('order:cancel',    '订单取消'),
('employee:query',  '员工查询'),
('employee:add',    '员工新增'),
('employee:update', '员工修改'),
('employee:status', '员工启用禁用'),
('report:query',    '报表查询'),
('shop:status',     '营业状态调整');

-- 超级管理员补齐新增权限
INSERT IGNORE INTO role_permission (role_id, permission_id)
SELECT 1, id FROM permission
WHERE code IN ('order:handle', 'order:cancel', 'employee:query', 'employee:add',
               'employee:update', 'employee:status', 'report:query', 'shop:status');

-- 运营：订单查询与处理
INSERT IGNORE INTO role_permission (role_id, permission_id)
SELECT 2, id FROM permission
WHERE code IN ('order:query', 'order:handle', 'order:cancel');

-- 财务：报表查询
INSERT IGNORE INTO role_permission (role_id, permission_id)
SELECT 3, id FROM permission
WHERE code = 'report:query';
