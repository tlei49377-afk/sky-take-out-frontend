package com.sky.aspect;

import com.sky.annotation.RequirePermission;
import com.sky.constant.MessageConstant;
import com.sky.context.BaseContext;
import com.sky.exception.BaseException;
import com.sky.service.PermissionService;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.aop.support.AopUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;

/**
 * 自定义切面,实现接口权限校验
 */
@Aspect
@Component
@Slf4j
public class PermissionAspect {

    @Autowired
    private PermissionService permissionService;

    /**
     * 切入点：管理端接口与 AI 工具方法
     */
    @Pointcut("execution(* com.sky.controller..*.*(..)) || execution(* com.sky.aiservice.tools..*.*(..))")
    public void permissionPointCut(){}

    /**
     * 校验当前登录员工是否具备方法上声明的权限
     * @param joinPoint
     */
    @Before("permissionPointCut()")
    public void checkPermission(JoinPoint joinPoint){
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = AopUtils.getMostSpecificMethod(signature.getMethod(), joinPoint.getTarget().getClass());
        RequirePermission requirePermission = method.getAnnotation(RequirePermission.class);

        // 未声明权限的方法直接放行
        if (requirePermission == null){
            return;
        }

        Long empId = BaseContext.getCurrentId();
        if (empId == null){
            throw new BaseException(MessageConstant.NO_PERMISSION);
        }

        if (!permissionService.listCodesByEmployeeId(empId).contains(requirePermission.value())){
            log.warn("员工 {} 缺少权限 {}", empId, requirePermission.value());
            throw new BaseException(MessageConstant.NO_PERMISSION);
        }
    }
}
