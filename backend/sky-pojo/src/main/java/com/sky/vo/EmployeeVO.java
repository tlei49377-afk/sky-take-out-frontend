package com.sky.vo;

import com.sky.entity.Role;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmployeeVO implements Serializable {

    private static final long serialVersionUID = 1L;

    //主键
    private Long id;

    //用户名
    private String username;

    //姓名
    private String name;

    //手机号
    private String phone;

    //性别
    private String sex;

    //身份证号
    private String idNumber;

    //账号状态 1启用 0禁用
    private Integer status;

    //更新时间
    private LocalDateTime updateTime;

    //该员工拥有的角色
    private List<Role> roles;

}