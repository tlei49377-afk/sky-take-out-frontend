package com.sky.controller.user;

import com.fasterxml.jackson.core.type.TypeReference;
import com.sky.cache.CacheHelper;
import com.sky.constant.CacheConstant;
import com.sky.constant.StatusConstant;
import com.sky.entity.Dish;
import com.sky.result.Result;
import com.sky.service.DishService;
import com.sky.vo.DishVO;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.Operation;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController("userDishController")
@RequestMapping("/user/dish")
@Slf4j
// 菜品浏览接口
public class DishController {
    @Autowired
    private DishService dishService;

    @Autowired
    private CacheHelper cacheHelper;

    /**
     * 根据分类id查询菜品
     *
     * @param categoryId
     * @return
     */
    @GetMapping("/list")
    public Result<List<DishVO>> list(Long categoryId) {
        // 缓存 key 的规则：dish_分类id
        String key = CacheConstant.DISH_KEY_PREFIX + categoryId;

        List<DishVO> list = cacheHelper.getOrLoad(key, new TypeReference<List<DishVO>>() {}, CacheConstant.DISH_TTL,
                () -> {
                    Dish dish = new Dish();
                    dish.setCategoryId(categoryId);
                    dish.setStatus(StatusConstant.ENABLE);//查询起售中的菜品
                    return dishService.listWithFlavor(dish);
                });
        return Result.success(list);
    }

}
