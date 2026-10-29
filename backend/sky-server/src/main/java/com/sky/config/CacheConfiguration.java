package com.sky.config;

import com.sky.cache.CacheHelper;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.sky.cache.TolerantCacheErrorHandler;
import com.sky.constant.CacheConstant;
import com.sky.json.JacksonObjectMapper;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.CachingConfigurer;
import org.springframework.cache.interceptor.CacheErrorHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.cache.RedisCacheConfiguration;
import org.springframework.data.redis.cache.RedisCacheManager;
import org.springframework.data.redis.cache.RedisCacheWriter;
import org.springframework.data.redis.cache.CacheStatisticsCollector;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.serializer.GenericJackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.RedisSerializationContext;
import org.springframework.data.redis.serializer.StringRedisSerializer;

/**
 * 配置类，给 @Cacheable 用的缓存管理器设置序列化和过期时间
 */
@Configuration
public class CacheConfiguration implements CachingConfigurer {

    @Bean
    public CacheManager cacheManager(RedisConnectionFactory redisConnectionFactory) {
        ObjectMapper objectMapper = new JacksonObjectMapper();
        // 缓存里放的是各种返回类型，类型信息必须一起写进 JSON，
        // 否则读出来统一是 LinkedHashMap，转成 Result 时直接抛 ClassCastException
        objectMapper.activateDefaultTyping(objectMapper.getPolymorphicTypeValidator(),
                ObjectMapper.DefaultTyping.NON_FINAL, JsonTypeInfo.As.PROPERTY);
        GenericJackson2JsonRedisSerializer jsonSerializer = new GenericJackson2JsonRedisSerializer(objectMapper);

        RedisCacheConfiguration configuration = RedisCacheConfiguration.defaultCacheConfig()
                .serializeKeysWith(RedisSerializationContext.SerializationPair.fromSerializer(new StringRedisSerializer()))
                .serializeValuesWith(RedisSerializationContext.SerializationPair.fromSerializer(jsonSerializer))
                // 默认不过期太危险，这里统一给过期时间，再按 key 加抖动
                .entryTtl((key, value) -> CacheHelper.withJitter(CacheConstant.SETMEAL_TTL))
                .disableCachingNullValues();

        // 默认不收集缓存统计，命中数、未命中数就永远是 0，指标里看不出效果
        RedisCacheWriter cacheWriter = RedisCacheWriter.nonLockingRedisCacheWriter(redisConnectionFactory)
                .withStatisticsCollector(CacheStatisticsCollector.create());

        return RedisCacheManager.builder(cacheWriter)
                .cacheDefaults(configuration)
                .withCacheConfiguration(CacheConstant.SETMEAL_CACHE_NAME, configuration)
                .build();
    }

    // 缓存读写出问题只记日志，别让业务接口跟着失败
    @Override
    public CacheErrorHandler errorHandler() {
        return new TolerantCacheErrorHandler();
    }
}
