package com.sky.dto;

import lombok.Data;

import java.io.Serializable;
import java.util.List;

@Data
public class RolePermissionDTO implements Serializable {

    //权限id列表
    private List<Long> permissionIds;

}
