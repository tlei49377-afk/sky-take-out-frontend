package com.sky.aiservice;

import dev.langchain4j.service.MemoryId;
import dev.langchain4j.service.SystemMessage;
import dev.langchain4j.service.UserMessage;
import dev.langchain4j.service.spring.AiService;
import dev.langchain4j.service.spring.AiServiceWiringMode;
import reactor.core.publisher.Flux;

/**
 * AI 助手。
 * tools 里填的是 Spring bean 名（EXPLICIT 模式下按名字装配）：
 * DishTools -> dishTools，CategoryTools -> categoryTools，OrderTools -> orderTools
 */
@AiService(
        wiringMode = AiServiceWiringMode.EXPLICIT,
        chatModel = "openAiChatModel",
        streamingChatModel = "openAiStreamingChatModel",
        chatMemoryProvider = "chatMemoryProvider",
        tools = {"dishTools", "categoryTools", "orderTools"}
)
public interface ConsultantService {

    @SystemMessage(fromResource = "system.txt")
    Flux<String> chat(@MemoryId String memoryId, @UserMessage String memory);
}
