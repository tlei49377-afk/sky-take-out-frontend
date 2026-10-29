package com.sky.constant;

import java.time.Duration;

/**
 * 缓存常量，存放 key 前缀和过期时间
 */
public class CacheConstant {

    //菜品缓存 key 前缀，完整 key 是 dish_{分类id}
    public static final String DISH_KEY_PREFIX = "dish_";

    //菜品缓存过期时间
    public static final Duration DISH_TTL = Duration.ofMinutes(30);

    //查不到数据时也缓存一小会儿，避免每次都打库
    public static final Duration EMPTY_TTL = Duration.ofMinutes(2);

    //套餐缓存的 cacheNames，完整 key 是 setmealCache::分类id
    public static final String SETMEAL_CACHE_NAME = "setmealCache";

    //套餐缓存过期时间
    public static final Duration SETMEAL_TTL = Duration.ofMinutes(30);

    //重建缓存时加的互斥锁，key 后缀
    public static final String LOCK_SUFFIX = ":lock";

    //互斥锁的过期时间，防止持锁的线程挂掉后锁一直不释放
    public static final Duration LOCK_TTL = Duration.ofSeconds(10);

    //没抢到锁的请求先等一小会儿，再去读一次缓存
    public static final long LOCK_WAIT_MILLIS = 50;

    //没抢到锁时最多等这么久（次），等到了就读缓存，等不到才自己查库兜底
    public static final int LOCK_WAIT_RETRY = 10;

    //过期时间抖动比例，实际 TTL 落在正负 10% 之间
    public static final double TTL_JITTER = 0.1;
}
