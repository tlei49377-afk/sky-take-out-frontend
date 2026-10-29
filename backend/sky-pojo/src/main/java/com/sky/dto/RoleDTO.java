package com.sky.dto;

import lombok.Data;

import java.io.Serializable;
import java.util.List;

@Data
public class RoleDTO implements Serializable {

    private Long id;

    //角色编码
    private String code;

    //角色名称
    private String name;

    //说明
    private String description;

    //该角色拥有的权限id
    private List<Long> permissionIds;

}