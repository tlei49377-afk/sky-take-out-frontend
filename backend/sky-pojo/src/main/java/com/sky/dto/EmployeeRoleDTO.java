package com.sky.dto;

import lombok.Data;

import java.io.Serializable;
import java.util.List;

@Data
public class EmployeeRoleDTO implements Serializable {

    //角色id列表
    private List<Long> roleIds;

}
