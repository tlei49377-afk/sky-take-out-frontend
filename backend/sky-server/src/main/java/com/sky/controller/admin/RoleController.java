package com.sky.controller.admin;

import com.sky.annotation.RequirePermission;
import com.sky.dto.RoleDTO;
import com.sky.dto.RolePermissionDTO;
import com.sky.entity.Role;
import com.sky.result.Result;
import com.sky.service.RoleService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 角色管理
 */
@RestController
@RequestMapping("/admin/role")
@Tag(name = "角色相关接口")
@Slf4j
public class RoleController {

    @Autowired
    private RoleService roleService;

    /**
     * 查询全部角色
     * @return
     */
    @RequirePermission("role:query")
    @GetMapping("/list")
    public Result<List<Role>> list() {
        return Result.success(roleService.list());
    }

    /**
     * 新增角色
     * @param roleDTO
     * @return
     */
    @RequirePermission("role:assign")
    @PostMapping
    public Result<String> create(@RequestBody RoleDTO roleDTO) {
        log.info("新增角色：{}", roleDTO);
        roleService.createRole(roleDTO);
        return Result.success();
    }

    /**
     * 查询角色已分配的权限id
     * @param id
     * @return
     */
    @RequirePermission("role:query")
    @GetMapping("/{id}/permissions")
    public Result<List<Long>> listPermissions(@PathVariable Long id) {
        return Result.success(roleService.listPermissionIds(id));
    }

    /**
     * 给角色分配权限
     * @param id
     * @param rolePermissionDTO
     * @return
     */
    @RequirePermission("role:assign")
    @PutMapping("/{id}/permissions")
    public Result<String> assignPermissions(@PathVariable Long id, @RequestBody RolePermissionDTO rolePermissionDTO) {
        log.info("角色分配权限：roleId={}, permissionIds={}", id, rolePermissionDTO.getPermissionIds());
        roleService.assignPermissions(id, rolePermissionDTO.getPermissionIds());
        return Result.success();
    }
}
