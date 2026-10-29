package com.sky.service.impl;

import com.sky.exception.BaseException;
import com.sky.service.ChatSessionService;
import com.sky.vo.ChatMessageVO;
import com.sky.vo.ChatSessionVO;
import dev.langchain4j.data.message.AiMessage;
import dev.langchain4j.data.message.ChatMessage;
import dev.langchain4j.data.message.Content;
import dev.langchain4j.data.message.TextContent;
import dev.langchain4j.data.message.UserMessage;
import dev.langchain4j.store.memory.chat.ChatMemoryStore;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
@Slf4j
public class ChatSessionServiceImpl implements ChatSessionService {

    @Autowired
    private StringRedisTemplate redisTemplate;

    // 必须按 bean 名注入：容器里有两个 ChatMemoryStore
    // （CommonConfig.chatMemoryStore 的 InMemoryChatMemoryStore，和 redisChatMemoryStore），
    // 只按类型注入会报歧义。实际生效的是 Redis 那个。
    @Autowired
    @Qualifier("redisChatMemoryStore")
    private ChatMemoryStore chatMemoryStore;

    //每个管理员最多保留的会话数
    private static final int MAX_SESSIONS = 10;

    //会话清单：ZSet，member = memoryId，score = 最后活跃时间戳
    private static final String SESSION_KEY_PREFIX = "chat:sessions:";

    //会话标题
    private static final String TITLE_KEY_PREFIX = "chat:session:title:";

    private static final Duration TTL = Duration.ofDays(7);

    private static final int TITLE_MAX_LENGTH = 20;

    private static final String DEFAULT_TITLE = "新会话";

    @Override
    public void touch(Long empId, String memoryId, String message) {
        if (empId == null || !StringUtils.hasText(memoryId)) {
            return;
        }

        // 这个方法是在对话开始前同步调用的，一旦抛异常就会把整轮对话带崩。
        // 会话登记只是辅助功能，失败了也必须让用户正常拿到回答，所以这里整个兜住。
        try {
            String sessionKey = sessionKey(empId);
            String titleKey = titleKey(memoryId);

            // 1. 登记会话并刷新最后活跃时间。
            //    score 直接存时间戳，ZSet 天然按时间排序，取最旧的不用自己排。
            redisTemplate.opsForZSet().add(sessionKey, memoryId, System.currentTimeMillis());

            // 2. 标题只在第一次写入，后续追问不覆盖。
            //    setIfAbsent 是原子的，不用担心并发把标题写成中间某句追问。
            redisTemplate.opsForValue().setIfAbsent(titleKey, buildTitle(message), TTL);
            // 活跃会话给标题续期；key 不存在时 expire 是空操作
            redisTemplate.expire(titleKey, TTL);

            // 3. 超出上限就淘汰最久没用过的那条
            evictIfNeeded(empId);

        } catch (Exception e) {
            log.error("会话登记失败，不影响本次对话。empId={}, memoryId={}", empId, memoryId, e);
        }
    }

    @Override
    public String createSession() {
        // 只生成 id，不在这里登记。
        // 否则连点 10 次「新建会话」就会把 10 条真实会话全挤掉，留下的都是空会话。
        // 等第一条消息真正发过来时，再由 touch() 登记。
        return "web_" + UUID.randomUUID().toString().replace("-", "");
    }

    @Override
    public List<ChatSessionVO> listSessions(Long empId) {
        if (empId == null) {
            return new ArrayList<>();
        }

        String sessionKey = sessionKey(empId);

        // reverseRange：按 score 从大到小，即最近活跃的排前面
        Set<String> memoryIds = redisTemplate.opsForZSet().reverseRange(sessionKey, 0, -1);

        if (memoryIds == null || memoryIds.isEmpty()) {
            return new ArrayList<>();
        }

        List<ChatSessionVO> result = new ArrayList<>(memoryIds.size());
        for (String memoryId : memoryIds) {
            String title = redisTemplate.opsForValue().get(titleKey(memoryId));
            Double score = redisTemplate.opsForZSet().score(sessionKey, memoryId);
            result.add(new ChatSessionVO(
                    memoryId,
                    // 标题过期时兜底，不让前端显示成空白
                    StringUtils.hasText(title) ? title : DEFAULT_TITLE,
                    score == null ? null : score.longValue()));
        }
        return result;
    }

    @Override
    public List<ChatMessageVO> getSessionMessages(Long empId, String memoryId) {
        requireOwned(empId, memoryId);

        List<ChatMessage> messages = chatMemoryStore.getMessages(memoryId);

        List<ChatMessageVO> result = new ArrayList<>();
        for (ChatMessage message : messages) {
            // 只保留「用户说的话」和「助手的最终回答」。
            // 记忆里同时还存着 ToolExecutionRequest / ToolExecutionResultMessage，
            // 那是工具调用的中间过程，原样返回给前端就是一堆噪音。
            if (message instanceof UserMessage userMessage) {
                String text = extractText(userMessage);
                if (StringUtils.hasText(text)) {
                    result.add(new ChatMessageVO("user", text));
                }
            } else if (message instanceof AiMessage aiMessage) {
                String text = aiMessage.text();
                if (StringUtils.hasText(text)) {
                    result.add(new ChatMessageVO("ai", text));
                }
            }
        }
        return result;
    }

    @Override
    public void deleteSession(Long empId, String memoryId) {
        requireOwned(empId, memoryId);

        redisTemplate.opsForZSet().remove(sessionKey(empId), memoryId);
        redisTemplate.delete(titleKey(memoryId));
        // 走 ChatMemoryStore 而不是自己拼 key 删，
        // 这样消息的 key 格式只由 RedisChatMemoryStore 一处决定
        chatMemoryStore.deleteMessages(memoryId);
    }

    /**
     * 校验会话归属当前管理员。
     * memoryId 是前端传上来的，不校验的话换个 id 就能读到别人的会话。
     */
    private void requireOwned(Long empId, String memoryId) {
        if (empId == null || !StringUtils.hasText(memoryId)) {
            throw new BaseException("会话不存在");
        }
        Double score = redisTemplate.opsForZSet().score(sessionKey(empId), memoryId);
        if (score == null) {
            throw new BaseException("会话不存在或已过期");
        }
    }

    /**
     * 超过上限时淘汰「最久没有使用」的会话，连带删掉它的标题和消息，
     * 避免消息变成 Redis 里的垃圾数据。
     */
    private void evictIfNeeded(Long empId) {
        String sessionKey = sessionKey(empId);

        Long size = redisTemplate.opsForZSet().zCard(sessionKey);
        if (size == null || size <= MAX_SESSIONS) {
            return;
        }

        long overflow = size - MAX_SESSIONS;
        // 升序取最旧的 overflow 条
        Set<String> oldest = redisTemplate.opsForZSet().range(sessionKey, 0, overflow - 1);
        if (oldest == null || oldest.isEmpty()) {
            return;
        }

        redisTemplate.opsForZSet().remove(sessionKey, oldest.toArray());
        for (String memoryId : oldest) {
            redisTemplate.delete(titleKey(memoryId));
            chatMemoryStore.deleteMessages(memoryId);
            log.info("会话数超过 {} 条，已淘汰最久未使用的会话：{}", MAX_SESSIONS, memoryId);
        }
    }

    /**
     * 用第一条用户消息生成标题，过长截断
     */
    private String buildTitle(String message) {
        if (!StringUtils.hasText(message)) {
            return DEFAULT_TITLE;
        }
        String title = message.trim().replaceAll("\\s+", " ");
        return title.length() <= TITLE_MAX_LENGTH
                ? title
                : title.substring(0, TITLE_MAX_LENGTH) + "…";
    }

    /**
     * 取出用户消息里的文本内容。
     * 不用 UserMessage.singleText()，因为它在「内容不是恰好一段文本」时会抛异常。
     */
    private String extractText(UserMessage message) {
        StringBuilder sb = new StringBuilder();
        for (Content content : message.contents()) {
            if (content instanceof TextContent textContent) {
                sb.append(textContent.text());
            }
        }
        return sb.toString();
    }

    private String sessionKey(Long empId) {
        return SESSION_KEY_PREFIX + empId;
    }

    private String titleKey(String memoryId) {
        return TITLE_KEY_PREFIX + memoryId;
    }
}
