package com.sky.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

/**
 * AI 会话列表项
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class ChatSessionVO implements Serializable {

    //会话 id，前端发消息时回传
    private String memoryId;

    //会话标题，取自该会话的第一条用户消息
    private String title;

    //最后活跃时间（时间戳，毫秒）
    private Long lastActiveTime;
}
