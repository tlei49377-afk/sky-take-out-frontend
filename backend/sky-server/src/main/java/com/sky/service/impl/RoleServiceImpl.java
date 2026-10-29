package com.sky.service.impl;

import com.sky.constant.MessageConstant;
import com.sky.context.BaseContext;
import com.sky.dto.RoleDTO;
import com.sky.entity.Role;
import com.sky.exception.BaseException;
import com.sky.mapper.RoleMapper;
import com.sky.service.PermissionService;
import com.sky.service.RoleService;
import com.sky.vo.EmployeeRoleVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Service
@Slf4j
public class RoleServiceImpl implements RoleService {

    @Autowired
    private RoleMapper roleMapper;

    @Autowired
    private PermissionService permissionService;

    /**
     * 查询全部角色
     * @return
     */
    public List<Role> list() {
        return roleMapper.list();
    }

    /**
     * 新增角色
     * @param roleDTO
     */
    @Transactional
    public void createRole(RoleDTO roleDTO) {
        if (!StringUtils.hasText(roleDTO.getCode()) || !StringUtils.hasText(roleDTO.getName())) {
            throw new BaseException(MessageConstant.PARAM_ERROR);
        }

        // 角色编码不允许重复
        if (roleMapper.getByCode(roleDTO.getCode()) != null) {
            throw new BaseException(MessageConstant.ROLE_CODE_EXISTS);
        }

        Role role = Role.builder()
                .code(roleDTO.getCode())
                .name(roleDTO.getName())
                .description(roleDTO.getDescription())
                .build();
        roleMapper.insertRole(role);

        // 新增时勾选的权限一并写入
        if (roleDTO.getPermissionIds() != null && roleDTO.getPermissionIds().size() > 0) {
            // XML 映射的 insert 不回填自增主键，按编码取回
            Long roleId = roleMapper.getByCode(role.getCode()).getId();
            roleMapper.insertRolePermission(roleId, roleDTO.getPermissionIds());
        }
        log.info("新增角色：{}", role.getCode());
    }

    /**
     * 查询角色已分配的权限id
     * @param roleId
     * @return
     */
    public List<Long> listPermissionIds(Long roleId) {
        return roleMapper.listPermissionIdsByRoleId(roleId);
    }

    /**
     * 给角色分配权限
     * @param roleId
     * @param permissionIds
     */
    @Transactional
    public void assignPermissions(Long roleId, List<Long> permissionIds) {
        roleMapper.deleteRolePermission(roleId);
        if (permissionIds != null && permissionIds.size() > 0) {
            roleMapper.insertRolePermission(roleId, permissionIds);
        }

        // 角色权限变了，持有该角色的员工缓存全部失效
        List<Long> employeeIds = roleMapper.listEmployeeIdsByRoleId(roleId);
        for (Long employeeId : employeeIds) {
            permissionService.evictCache(employeeId);
        }
        log.info("角色 {} 权限已更新，失效 {} 个员工缓存", roleId, employeeIds.size());
    }

    /**
     * 查询员工已分配的角色id
     * @param employeeId
     * @return
     */
    public List<Long> listRoleIdsByEmployeeId(Long employeeId) {
        return roleMapper.listRoleIdsByEmployeeId(employeeId);
    }

    /**
     * 给员工分配角色
     * @param employeeId
     * @param roleIds
     */
    @Transactional
    public void assignRoles(Long employeeId, List<Long> roleIds) {
        // 角色没有变化就不用动
        if (sameRoleIds(roleMapper.listRoleIdsByEmployeeId(employeeId), roleIds)) {
            return;
        }

        // 不能修改自己的角色
        Long currentId = BaseContext.getCurrentId();
        if (currentId != null && currentId.equals(employeeId)) {
            throw new BaseException(MessageConstant.SELF_ROLE_EDIT_FAILED);
        }

        // 超级管理员的角色不允许被改动
        if (hasAdminRole(employeeId)) {
            throw new BaseException(MessageConstant.ADMIN_ROLE_EDIT_FAILED);
        }

        roleMapper.deleteEmployeeRole(employeeId);
        if (roleIds != null && roleIds.size() > 0) {
            roleMapper.insertEmployeeRole(employeeId, roleIds);
        }
        permissionService.evictCache(employeeId);
        log.info("员工 {} 角色已更新", employeeId);
    }

    /**
     * 查询一批员工的角色
     * @param employeeIds
     * @return
     */
    public List<EmployeeRoleVO> listEmployeeRoles(List<Long> employeeIds) {
        return roleMapper.listEmployeeRoles(employeeIds);
    }

    /**
     * 判断员工是否拥有超级管理员角色
     * @param employeeId
     * @return
     */
    public boolean hasAdminRole(Long employeeId) {
        return roleMapper.countAdminRole(employeeId) > 0;
    }

    // 比较角色集合是否一致，忽略顺序
    private boolean sameRoleIds(List<Long> currentIds, List<Long> roleIds) {
        Set<Long> current = new HashSet<>(currentIds);
        Set<Long> target = roleIds == null ? new HashSet<>() : new HashSet<>(roleIds);
        return current.equals(target);
    }
}
