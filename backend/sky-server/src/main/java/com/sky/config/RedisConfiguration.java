package com.sky.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.sky.json.JacksonObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.serializer.Jackson2JsonRedisSerializer;
import org.springframework.data.redis.serializer.StringRedisSerializer;

@Configuration // 配置类
@Slf4j
public class RedisConfiguration {

    @Bean
    public RedisTemplate redisTemplate(RedisConnectionFactory redisConnectionFactory) {
        log.info("开始创建RedisTemplate对象...");

        RedisTemplate<String, Object> template = new RedisTemplate<>();
        template.setConnectionFactory(redisConnectionFactory);

        // 1. 创建字符串序列化器（给所有 Key 使用）
        StringRedisSerializer stringSerializer = new StringRedisSerializer();

        // 2. 创建 JSON 序列化器（给所有 Value 使用），使用自定义的 ObjectMapper 支持 Java 8 日期时间类型
        // 创建自定义的 ObjectMapper，支持 LocalDateTime 等 Java 8 日期时间类型
        ObjectMapper objectMapper = new JacksonObjectMapper();
        Jackson2JsonRedisSerializer<Object> jsonSerializer =
                new Jackson2JsonRedisSerializer<>(objectMapper, Object.class);

        // --- 四个序列化全部设置 ---
        template.setKeySerializer(stringSerializer);          // 外层 key
        template.setHashKeySerializer(stringSerializer);      // Hash 的 field (修复这里！)
        template.setValueSerializer(jsonSerializer);         // 普通 value
        template.setHashValueSerializer(jsonSerializer);     // Hash 的 value

        // 必须加这一行，让配置生效
        template.afterPropertiesSet();

        return template;
    }
}

