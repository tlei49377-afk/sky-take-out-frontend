package com.sky.dto;

import lombok.Data;

import java.io.Serializable;
import java.util.List;

@Data
public class EmployeeDTO implements Serializable {

    private Long id;

    private String username;

    private String name;

    private String phone;

    private String sex;

    private String idNumber;

    //登录密码，新增时不填默认 123456，编辑时不填表示不改密码
    private String password;

    //角色id，新增或编辑时一并分配
    private List<Long> roleIds;

}
