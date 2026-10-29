package com.sky.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

/**
 * AI 会话中的一条历史消息
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class ChatMessageVO implements Serializable {

    //角色：user 表示用户，ai 表示助手
    private String role;

    //消息正文
    private String content;
}
