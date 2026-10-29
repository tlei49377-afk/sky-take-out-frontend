package com.sky.service;

import com.sky.vo.ChatMessageVO;
import com.sky.vo.ChatSessionVO;

import java.util.List;

/**
 * AI 会话管理：维护「有哪些会话」这份清单。
 * 会话的消息本身由 langchain4j 的 ChatMemoryStore 负责，这里只管清单和元数据。
 */
public interface ChatSessionService {

    /**
     * 登记/续期一个会话。每次用户发消息时调用。
     *
     * @param empId      当前登录管理员 id，会话按管理员隔离
     * @param memoryId   会话 id
     * @param message    本次用户消息，用于生成会话标题
     */
    void touch(Long empId, String memoryId, String message);

    /**
     * 新建会话，返回后端生成的 memoryId。
     * 只生成 id 不登记，等第一条消息发来时再由 touch 登记。
     */
    String createSession();

    /**
     * 查询当前管理员的会话列表，按最后活跃时间倒序，最多 10 条
     */
    List<ChatSessionVO> listSessions(Long empId);

    /**
     * 读取某个会话的历史消息（只返回用户消息和助手回复，不含工具调用过程）
     */
    List<ChatMessageVO> getSessionMessages(Long empId, String memoryId);

    /**
     * 删除某个会话，连同它的标题和消息一起删除
     */
    void deleteSession(Long empId, String memoryId);
}
