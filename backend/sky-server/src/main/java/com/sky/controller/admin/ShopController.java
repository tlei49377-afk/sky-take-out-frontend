package com.sky.controller.admin;

import com.sky.annotation.RequirePermission;
import com.sky.result.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.web.bind.annotation.*;
import jakarta.annotation.PostConstruct;

@RestController("adminshopcontroller") // 响应数据使用 JSON
@RequestMapping("/admin/shop")
@Slf4j
public class ShopController {

    public static final String KEY = "SHOP_STATUS";

    @Autowired
    private RedisTemplate redisTemplate;

    //服务启动时补一个默认的营业状态，Redis 被清空后前端不至于读到 null
    @PostConstruct
    public void initShopStatus() {
        try {
            if (Boolean.TRUE.equals(redisTemplate.opsForValue().setIfAbsent(KEY, 1))) {
                log.info("店铺营业状态缺失，已初始化为营业中");
            }
        } catch (Exception e) {
            log.warn("初始化店铺营业状态失败，Redis 可能未就绪", e);
        }
    }

    /**
     * 设置店铺营业状态
     * @param status
     * @return
     */
    @RequirePermission("shop:status")
    @PutMapping("/{status}")
    public Result get(@PathVariable Integer status) {
        log.info("设置店铺营业状态：{}", status == 1 ? "营业中" : "打烊中");
        redisTemplate.opsForValue().set(KEY, status);
        return Result.success();
    }

    /**
     * 获取店铺营业状态
     * @return
     */
    @GetMapping("/status")
    public Result<Integer> getStatus() {
        Integer status = (Integer) redisTemplate.opsForValue().get(KEY);
        log.info("获取店铺营业状态为：", status == 1 ? "营业中" : "打烊中");
        return Result.success(status);
    }
}
