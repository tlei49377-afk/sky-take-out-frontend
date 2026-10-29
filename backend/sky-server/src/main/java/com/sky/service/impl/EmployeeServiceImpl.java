package com.sky.service.impl;

import com.github.pagehelper.PageHelper;
import com.sky.constant.MessageConstant;
import com.sky.constant.PasswordConstant;
import com.sky.constant.StatusConstant;
import com.sky.context.BaseContext;
import com.sky.dto.EmployeeDTO;
import com.sky.dto.EmployeeLoginDTO;
import com.sky.dto.EmployeePageQueryDTO;
import com.sky.entity.Employee;
import com.sky.entity.Role;
import com.sky.exception.AccountLockedException;
import com.sky.exception.AccountNotFoundException;
import com.sky.exception.BaseException;
import com.sky.exception.PasswordErrorException;
import com.sky.mapper.EmployeeMapper;
import com.sky.result.PageResult;
import com.sky.service.EmployeeService;
import com.sky.service.RoleService;
import com.sky.vo.EmployeeRoleVO;
import com.sky.vo.EmployeeVO;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import com.github.pagehelper.Page;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.DigestUtils;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
public class EmployeeServiceImpl implements EmployeeService {

    @Autowired
    private EmployeeMapper employeeMapper;

    @Autowired
    private RoleService roleService;

    /**
     * 员工登录
     *
     * @param employeeLoginDTO
     * @return
     */
    public Employee login(EmployeeLoginDTO employeeLoginDTO) {
        String username = employeeLoginDTO.getUsername();
        String password = employeeLoginDTO.getPassword();

        //1、根据用户名查询数据库中的数据
        Employee employee = employeeMapper.getByUsername(username);

        //2、处理各种异常情况（用户名不存在、密码不对、账号被锁定）
        if (employee == null) {
            //账号不存在
            throw new AccountNotFoundException(MessageConstant.ACCOUNT_NOT_FOUND);
        }

        //密码比对
        // md5加密，然后再进行比对
        password = DigestUtils.md5DigestAsHex(password.getBytes());
        if (!password.equals(employee.getPassword())) {
            //密码错误
            throw new PasswordErrorException(MessageConstant.PASSWORD_ERROR);
        }

        if (employee.getStatus() == StatusConstant.DISABLE) {
            //账号被锁定
            throw new AccountLockedException(MessageConstant.ACCOUNT_LOCKED);
        }

        //3、返回实体对象
        return employee;
    }

    /**
     * 新增员工
     * @param employeeDTO
     */
    @Override
    @Transactional
    public void save(EmployeeDTO employeeDTO) {
        // 用户名不允许重复
        if (employeeMapper.getByUsername(employeeDTO.getUsername()) != null) {
            throw new BaseException(MessageConstant.USERNAME_EXISTS);
        }

        Employee employee = new Employee();

        // 对象属性拷贝
        BeanUtils.copyProperties(employeeDTO, employee);

        // 设置账号状态，默认正常状态 1正常 0锁定
        employee.setStatus(StatusConstant.ENABLE);

        // 密码不填用默认的 123456，填了就用填的
        String password = StringUtils.hasText(employeeDTO.getPassword())
                ? employeeDTO.getPassword()
                : PasswordConstant.DEFAULT_PASSWORD;
        employee.setPassword(DigestUtils.md5DigestAsHex(password.getBytes()));

        // // 设置当前记录的创建时间和修改时间
        // employee.setCreateTime(LocalDateTime.now());
        // employee.setUpdateTime(LocalDateTime.now());

        // // 设置当前记录创建人id和修改人id
        // employee.setCreateUser(BaseContext.getCurrentId());
        // employee.setUpdateUser(BaseContext.getCurrentId());

        employeeMapper.insert(employee);

        // 新增时带的角色一并写入
        if (employeeDTO.getRoleIds() != null && employeeDTO.getRoleIds().size() > 0) {
            roleService.assignRoles(employee.getId(), employeeDTO.getRoleIds());
        }
    }

    /**
     * 分页查询
     * @param employeePageQueryDTO
     * @return
     */
    @Override
    public PageResult pageQuery(EmployeePageQueryDTO employeePageQueryDTO) {
        //1.设置分页参数
        PageHelper.startPage(employeePageQueryDTO.getPage(), employeePageQueryDTO.getPageSize());

        //2.执行查询
        Page<Employee> page = employeeMapper.pageQuery(employeePageQueryDTO);

        long total = page.getTotal();
        List<Employee> records = page.getResult();

        //3.一次查出这批员工的角色，避免逐行查询
        Map<Long, List<Role>> roleMap = new HashMap<>();
        List<Long> employeeIds = records.stream().map(Employee::getId).collect(Collectors.toList());
        if (employeeIds.size() > 0) {
            for (EmployeeRoleVO employeeRole : roleService.listEmployeeRoles(employeeIds)) {
                Role role = Role.builder()
                        .id(employeeRole.getRoleId())
                        .code(employeeRole.getCode())
                        .name(employeeRole.getName())
                        .build();
                roleMap.computeIfAbsent(employeeRole.getEmployeeId(), key -> new ArrayList<>()).add(role);
            }
        }

        //4.解析查询结果，并封装
        List<EmployeeVO> voList = new ArrayList<>();
        for (Employee employee : records) {
            EmployeeVO employeeVO = new EmployeeVO();
            BeanUtils.copyProperties(employee, employeeVO);
            employeeVO.setRoles(roleMap.getOrDefault(employee.getId(), new ArrayList<>()));
            voList.add(employeeVO);
        }
        return new PageResult(total, voList);
    }

    /**
     * 启用禁用员工账号
     * @param status
     * @param id
     */
    @Override
    public void startOrStop(Integer status, Long id) {
        // 超级管理员账号不允许被禁用
        if (StatusConstant.DISABLE.equals(status) && roleService.hasAdminRole(id)) {
            throw new BaseException(MessageConstant.ADMIN_EMPLOYEE_DISABLE_FAILED);
        }
//        Employee employee = new Employee();
//        employee.setStatus(status);
//        employee.setId(id);

        Employee employee = Employee.builder()
                .status(status)
                .id(id)
                .updateTime(LocalDateTime.now())
                .build();

        employeeMapper.update(employee);
    }

    /**
     * 根据id查询员工信息
     * @param id
     * @return
     */
    @Override
    public Employee getById(Long id) {
        Employee employee = employeeMapper.getById(id);
        employee.setPassword("****");
        return employee;
    }

    /**
     * 编辑员工信息
     * @param employeeDTO
     */
    @Override
    @Transactional
    public void update(EmployeeDTO employeeDTO) {
        // 超级管理员信息不允许被他人修改
        if (roleService.hasAdminRole(employeeDTO.getId())
                && !Objects.equals(employeeDTO.getId(), BaseContext.getCurrentId())) {
            throw new BaseException(MessageConstant.ADMIN_EMPLOYEE_UPDATE_FAILED);
        }

        Employee employee = new Employee();
        BeanUtils.copyProperties(employeeDTO, employee);

        // 密码单独处理：不填保持原密码，填了就加密后覆盖
        employee.setPassword(null);
        if (StringUtils.hasText(employeeDTO.getPassword())) {
            employee.setPassword(DigestUtils.md5DigestAsHex(employeeDTO.getPassword().getBytes()));
        }

        // employee.setUpdateTime(LocalDateTime.now());
        // employee.setUpdateUser(BaseContext.getCurrentId());
        employeeMapper.update(employee);

        // 带了角色就一起更新
        if (employeeDTO.getRoleIds() != null) {
            roleService.assignRoles(employeeDTO.getId(), employeeDTO.getRoleIds());
        }
    }


}
