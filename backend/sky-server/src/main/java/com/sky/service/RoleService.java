package com.sky.service;

import com.sky.dto.RoleDTO;
import com.sky.entity.Role;
import com.sky.vo.EmployeeRoleVO;

import java.util.List;

public interface RoleService {

    /**
     * 查询全部角色
     * @return
     */
    List<Role> list();

    /**
     * 新增角色
     * @param roleDTO
     */
    void createRole(RoleDTO roleDTO);

    /**
     * 查询角色已分配的权限id
     * @param roleId
     * @return
     */
    List<Long> listPermissionIds(Long roleId);

    /**
     * 给角色分配权限
     * @param roleId
     * @param permissionIds
     */
    void assignPermissions(Long roleId, List<Long> permissionIds);

    /**
     * 查询员工已分配的角色id
     * @param employeeId
     * @return
     */
    List<Long> listRoleIdsByEmployeeId(Long employeeId);

    /**
     * 给员工分配角色
     * @param employeeId
     * @param roleIds
     */
    void assignRoles(Long employeeId, List<Long> roleIds);

    /**
     * 查询一批员工的角色
     * @param employeeIds
     * @return
     */
    List<EmployeeRoleVO> listEmployeeRoles(List<Long> employeeIds);

    /**
     * 判断员工是否拥有超级管理员角色
     * @param employeeId
     * @return
     */
    boolean hasAdminRole(Long employeeId);
}
