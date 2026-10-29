package com.sky.vo;

import lombok.Data;

import java.io.Serializable;

@Data
public class EmployeeRoleVO implements Serializable {

    private static final long serialVersionUID = 1L;

    //员工id
    private Long employeeId;

    //角色id
    private Long roleId;

    //角色编码
    private String code;

    //角色名称
    private String name;

}