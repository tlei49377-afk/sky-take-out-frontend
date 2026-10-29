package com.sky.controller.admin;

import com.sky.annotation.RequirePermission;
import com.sky.context.BaseContext;
import com.sky.entity.Permission;
import com.sky.result.Result;
import com.sky.service.PermissionService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/admin/permission")
@Slf4j
public class PermissionController {

    @Autowired
    private PermissionService permissionService;

    /**
     * 查询当前登录员工的权限
     * @return
     */
    @GetMapping("/me")
    public Result<List<String>> me() {
        return Result.success(permissionService.listCodesByEmployeeId(BaseContext.getCurrentId()));
    }

    /**
     * 查询全部权限点
     * @return
     */
    @RequirePermission("role:query")
    @GetMapping("/list")
    public Result<List<Permission>> list() {
        return Result.success(permissionService.list());
    }
}
