package com.sky.controller.admin;

import com.sky.aiservice.ConsultantService;
import com.sky.context.BaseContext;
import com.sky.result.Result;
import com.sky.service.ChatSessionService;
import com.sky.vo.ChatMessageVO;
import com.sky.vo.ChatSessionVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;

import java.util.List;

@RestController
public class ChatController {

    @Autowired
    private ConsultantService consultantService;

    @Autowired
    private ChatSessionService chatSessionService;

    /**
     * AI 助手对话接口（流式返回）
     *
     * @param memoryId 会话 id，用于区分不同用户/会话的上下文
     * @param memory   用户输入的问题
     */
    @RequestMapping(value = "/admin/chat", produces = "text/plain;charset=UTF-8")
    public Flux<String> chat(@RequestParam("memoryId") String memoryId,
                             @RequestParam("memory") String memory) {

        // empId 必须在这里同步取出：BaseContext 是 ThreadLocal，
        // 而 Flux 是异步流式返回、在别的线程上发射的，等流开始后再取就取不到了。
        chatSessionService.touch(BaseContext.getCurrentId(), memoryId, memory);

        return consultantService.chat(memoryId, memory);
    }

    /**
     * 新建会话，返回后端生成的 memoryId
     */
    @PostMapping("/admin/chat/session")
    public Result<String> createSession() {
        return Result.success(chatSessionService.createSession());
    }

    /**
     * 当前管理员的会话列表（最多 10 条，按最后活跃时间倒序）
     */
    @GetMapping("/admin/chat/sessions")
    public Result<List<ChatSessionVO>> listSessions() {
        return Result.success(chatSessionService.listSessions(BaseContext.getCurrentId()));
    }

    /**
     * 读取某个会话的历史消息
     */
    @GetMapping("/admin/chat/session/{memoryId}/messages")
    public Result<List<ChatMessageVO>> getSessionMessages(@PathVariable("memoryId") String memoryId) {
        return Result.success(chatSessionService.getSessionMessages(BaseContext.getCurrentId(), memoryId));
    }

    /**
     * 删除某个会话（连同它的消息一起删掉）
     */
    @DeleteMapping("/admin/chat/session/{memoryId}")
    public Result<Void> deleteSession(@PathVariable("memoryId") String memoryId) {
        chatSessionService.deleteSession(BaseContext.getCurrentId(), memoryId);
        return Result.success();
    }
}
