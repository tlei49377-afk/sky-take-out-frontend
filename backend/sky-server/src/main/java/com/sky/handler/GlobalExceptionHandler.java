package com.sky.handler;

import com.sky.constant.MessageConstant;
import com.sky.exception.BaseException;
import com.sky.result.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.ConstraintViolationException;
import java.sql.SQLIntegrityConstraintViolationException;

/**
 * 全局异常处理器，处理项目中抛出的业务异常
 */
@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    /**
     * 捕获业务异常
     * @param ex
     * @return
     */
    @ExceptionHandler
    public Result exceptionHandler(BaseException ex){
        log.error("异常信息：{}", ex.getMessage());
        return Result.error(ex.getMessage());
    }

    /**
     * 处理SQL异常
     * @param ex
     * @return
     */
    @ExceptionHandler
    public Result exceptionHandler(SQLIntegrityConstraintViolationException ex){
        String message = ex.getMessage();
        if (message.contains("Duplicate entry")) {
            String[] split = message.split(" ");
            String username = split[2];
            String msg = username + MessageConstant.ALREADY_EXISTS;
            return Result.error(msg);
        }
        return Result.error(MessageConstant.UNKNOWN_ERROR);
    }

    /**
     * 处理参数校验异常
     * @param ex
     * @return
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Result exceptionHandler(MethodArgumentNotValidException ex) {
        String message = firstFieldError(ex.getBindingResult().getFieldError());
        log.warn("参数校验失败：{}", message);
        return Result.error(message);
    }

    /**
     * 处理参数绑定异常
     * @param ex
     * @return
     */
    @ExceptionHandler(BindException.class)
    public Result exceptionHandler(BindException ex) {
        String message = firstFieldError(ex.getBindingResult().getFieldError());
        log.warn("参数绑定失败：{}", message);
        return Result.error(message);
    }

    /**
     * 处理方法参数约束校验异常
     * @param ex
     * @return
     */
    @ExceptionHandler(ConstraintViolationException.class)
    public Result exceptionHandler(ConstraintViolationException ex) {
        String message = ex.getConstraintViolations().stream()
                .findFirst()
                .map(ConstraintViolation::getMessage)
                .orElse(MessageConstant.PARAM_ERROR);
        log.warn("参数约束校验失败：{}", message);
        return Result.error(message);
    }

    /**
     * 处理其他未知异常
     * @param ex
     * @return
     */
    @ExceptionHandler(Exception.class)
    public Result exceptionHandler(Exception ex) {
        log.error("系统异常", ex);
        return Result.error(MessageConstant.UNKNOWN_ERROR);
    }

    /**
     * 提取第一条字段校验失败的提示
     * @param fieldError
     * @return
     */
    private String firstFieldError(FieldError fieldError) {
        return fieldError == null
                ? MessageConstant.PARAM_ERROR
                : fieldError.getField() + " " + fieldError.getDefaultMessage();
    }

}
