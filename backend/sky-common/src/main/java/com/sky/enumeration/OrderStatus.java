package com.sky.enumeration;

import com.sky.constant.MessageConstant;
import com.sky.exception.OrderBusinessException;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/**
 * 订单状态，以及状态之间允许的流转
 */
public enum OrderStatus {

    /**
     * 待付款
     */
    PENDING_PAYMENT(1, "待付款"),

    /**
     * 待接单
     */
    TO_BE_CONFIRMED(2, "待接单"),

    /**
     * 已接单
     */
    CONFIRMED(3, "已接单"),

    /**
     * 派送中
     */
    DELIVERY_IN_PROGRESS(4, "派送中"),

    /**
     * 已完成
     */
    COMPLETED(5, "已完成"),

    /**
     * 已取消
     */
    CANCELLED(6, "已取消"),

    /**
     * 退款
     */
    REFUND(7, "退款");

    private final Integer code;

    private final String desc;

    OrderStatus(Integer code, String desc) {
        this.code = code;
        this.desc = desc;
    }

    // 允许的流转：当前状态 -> 可以流转到的状态
    private static final Map<Integer, Set<Integer>> TRANSITIONS;

    static {
        Map<Integer, Set<Integer>> map = new HashMap<>();
        map.put(PENDING_PAYMENT.code, Set.of(TO_BE_CONFIRMED.code, CANCELLED.code));
        map.put(TO_BE_CONFIRMED.code, Set.of(CONFIRMED.code, CANCELLED.code));
        map.put(CONFIRMED.code, Set.of(DELIVERY_IN_PROGRESS.code, CANCELLED.code));
        map.put(DELIVERY_IN_PROGRESS.code, Set.of(COMPLETED.code));
        map.put(COMPLETED.code, Collections.emptySet());
        map.put(CANCELLED.code, Collections.emptySet());
        map.put(REFUND.code, Collections.emptySet());
        TRANSITIONS = Collections.unmodifiableMap(map);
    }

    public Integer getCode() {
        return code;
    }

    public String getDesc() {
        return desc;
    }

    /**
     * 判断订单能否从当前状态流转到目标状态
     * @param from
     * @param to
     * @return
     */
    public static boolean canTransfer(Integer from, Integer to) {
        // Set.of 建的集合不接受 null，先挡掉，避免空状态直接抛 NPE
        if (from == null || to == null) {
            return false;
        }
        Set<Integer> allowed = TRANSITIONS.get(from);
        return allowed != null && allowed.contains(to);
    }

    /**
     * 校验状态流转，不合法时抛业务异常
     * @param from
     * @param to
     */
    public static void checkTransfer(Integer from, Integer to) {
        if (!canTransfer(from, to)) {
            throw new OrderBusinessException(MessageConstant.ORDER_STATUS_ERROR);
        }
    }
}
