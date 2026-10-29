-- ============================================================
-- V4：角色权限管理相关权限点
-- 依赖 V2 的 role / permission / role_permission 表与初始数据
-- ============================================================

USE sky_take_out;

INSERT IGNORE INTO permission (code, name) VALUES
('role:query',  '角色查询'),
('role:assign', '角色权限分配');

-- 超级管理员
INSERT IGNORE INTO role_permission (role_id, permission_id)
SELECT 1, id FROM permission WHERE code IN ('role:query', 'role:assign');
