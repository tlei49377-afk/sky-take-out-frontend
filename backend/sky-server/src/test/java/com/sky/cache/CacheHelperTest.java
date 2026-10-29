package com.sky.cache;

import com.sky.constant.CacheConstant;
import org.junit.jupiter.api.Test;

import java.time.Duration;
import java.util.HashSet;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.assertTrue;

// 过期时间抖动的单元测试
class CacheHelperTest {

    /** 抖动后的过期时间要落在基准值上下 10% 以内 */
    @Test
    void jitterShouldStayWithinTenPercent() {
        assertJitterInRange(CacheConstant.DISH_TTL);
        assertJitterInRange(CacheConstant.SETMEAL_TTL);
        assertJitterInRange(CacheConstant.EMPTY_TTL);
        assertJitterInRange(CacheConstant.LOCK_TTL);
    }

    /** 连续抖动不能每次都是同一个值，否则 key 还是会同时失效 */
    @Test
    void jitterShouldNotReturnSameValueEveryTime() {
        Set<Long> values = new HashSet<>();
        for (int i = 0; i < 50; i++) {
            values.add(CacheHelper.withJitter(CacheConstant.SETMEAL_TTL).toMillis());
        }
        // 全都一样说明抖动没起作用，缓存还是会同时失效
        assertTrue(values.size() > 1, "抖动后不应该每次都得到同一个过期时间");
    }

    /** 校验某个基准 TTL 反复抖动后都不越界 */
    private void assertJitterInRange(Duration base) {
        long min = (long) (base.toMillis() * (1 - CacheConstant.TTL_JITTER));
        long max = (long) (base.toMillis() * (1 + CacheConstant.TTL_JITTER));
        for (int i = 0; i < 200; i++) {
            long actual = CacheHelper.withJitter(base).toMillis();
            assertTrue(actual >= min && actual <= max, "抖动后的过期时间超出范围：" + actual);
        }
    }

    /** TTL 很小时抖动不会算出负数 */
    @Test
    void jitterShouldNotGoNegativeForVeryShortTtl() {
        // TTL 很小时抖动幅度算出来是 0，不能出现负数
        assertTrue(CacheHelper.withJitter(Duration.ofMillis(1)).toMillis() >= 0);
        assertTrue(CacheHelper.withJitter(Duration.ofMillis(9)).toMillis() >= 0);
    }
}
