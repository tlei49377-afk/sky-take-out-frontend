package com.sky.mapper;

import com.sky.entity.Permission;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface PermissionMapper {

    /**
     * 查询员工的权限码
     * @param employeeId
     * @return
     */
    List<String> listCodesByEmployeeId(Long employeeId);

    /**
     * 查询全部权限点
     * @return
     */
    List<Permission> list();
}
