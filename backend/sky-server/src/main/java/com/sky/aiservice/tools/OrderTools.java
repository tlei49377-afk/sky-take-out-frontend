package com.sky.aiservice.tools;

import com.sky.dto.OrdersPageQueryDTO;
import com.sky.result.PageResult;
import com.sky.service.OrderService;
import com.sky.vo.OrderVO;
import dev.langchain4j.agent.tool.P;
import dev.langchain4j.agent.tool.Tool;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * AI 助手的订单查询工具。
 */
@Component
@Slf4j
public class OrderTools {

    @Autowired
    private OrderService orderService;

    private static final int PAGE_SIZE = 10;

    private static final DateTimeFormatter DATE_TIME_FORMATTER =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private static final DateTimeFormatter DATE_FORMATTER =
            DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @Tool("查询订单信息。可以根据订单号、下单人手机号、订单状态、下单时间范围查询订单列表，"
            + "返回订单号、下单时间、订单状态、订单金额、下单人等信息。"
            + "当用户询问订单、某笔订单的状态、某人的订单时，调用此工具。")
    public String queryOrder(
            @P(value = "订单号，精确匹配。用户没有提供订单号时传空字符串", required = false)
            String orderNo,

            @P(value = "下单人的手机号，精确匹配。用户没有提供手机号时传空字符串", required = false)
            String phone,

            @P(value = "订单状态：1 待付款，2 待接单，3 已接单，4 派送中，5 已完成，6 已取消，7 退款。用户没有指定状态时传 -1", required = false)
            Integer status,

            @P(value = "下单开始时间，格式 yyyy-MM-dd HH:mm:ss，也可以只给日期 yyyy-MM-dd。没有则传空字符串", required = false)
            String beginTime,

            @P(value = "下单结束时间，格式 yyyy-MM-dd HH:mm:ss，也可以只给日期 yyyy-MM-dd。没有则传空字符串", required = false)
            String endTime) {

        log.info("AI 工具调用 -> queryOrder(orderNo={}, phone={}, status={}, beginTime={}, endTime={})",
                orderNo, phone, status, beginTime, endTime);

        try {
            OrdersPageQueryDTO dto = new OrdersPageQueryDTO();
            dto.setPage(1);
            dto.setPageSize(PAGE_SIZE);

            if (isNotBlank(orderNo)) {
                dto.setNumber(orderNo.trim());
            }
            if (isNotBlank(phone)) {
                dto.setPhone(phone.trim());
            }
            if (status != null && status != -1) {
                dto.setStatus(status);
            }

            // 模型只能产出字符串，LocalDateTime 必须在这里自己解析
            if (isNotBlank(beginTime)) {
                dto.setBeginTime(parseDateTime(beginTime, false));
            }
            if (isNotBlank(endTime)) {
                dto.setEndTime(parseDateTime(endTime, true));
            }

            PageResult pageResult = orderService.conditionSearch(dto);

            @SuppressWarnings("unchecked")
            List<OrderVO> records = pageResult.getRecords();

            if (records == null || records.isEmpty()) {
                return "没有查询到符合条件的订单。";
            }

            StringBuilder sb = new StringBuilder();
            sb.append("共查询到 ").append(pageResult.getTotal())
              .append(" 笔订单，以下是最多 ").append(records.size()).append(" 条结果：\n");

            int index = 1;
            for (OrderVO order : records) {
                sb.append(index++).append(". 订单号：").append(order.getNumber())
                  .append(" | 下单时间：").append(formatTime(order.getOrderTime()))
                  .append(" | 状态：").append(toStatusText(order.getStatus()))
                  .append(" | 金额：").append(order.getAmount()).append(" 元")
                  .append(" | 下单人：").append(order.getConsignee() == null ? "未知" : order.getConsignee())
                  .append(" | 手机号：").append(order.getPhone() == null ? "未知" : order.getPhone())
                  .append("\n");
            }
            return sb.toString();

        } catch (Exception e) {
            log.error("AI 工具 queryOrder 执行失败", e);
            return "查询订单时发生错误：" + e.getMessage();
        }
    }

    /**
     * 解析时间字符串。
     * 只给到日期时：开始时间取当天 00:00:00，结束时间取当天 23:59:59。
     */
    private LocalDateTime parseDateTime(String text, boolean endOfDay) {
        String value = text.trim().replace('T', ' ');
        if (value.length() <= 10) {
            LocalDate date = LocalDate.parse(value, DATE_FORMATTER);
            return endOfDay ? date.atTime(23, 59, 59) : date.atStartOfDay();
        }
        return LocalDateTime.parse(value, DATE_TIME_FORMATTER);
    }

    private String formatTime(LocalDateTime time) {
        return time == null ? "未知" : time.format(DATE_TIME_FORMATTER);
    }

    private String toStatusText(Integer status) {
        if (status == null) {
            return "未知";
        }
        switch (status) {
            case 1: return "待付款";
            case 2: return "待接单";
            case 3: return "已接单";
            case 4: return "派送中";
            case 5: return "已完成";
            case 6: return "已取消";
            case 7: return "退款";
            default: return "未知(" + status + ")";
        }
    }

    private boolean isNotBlank(String text) {
        return text != null && !text.trim().isEmpty();
    }
}
