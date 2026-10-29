package com.sky.enumeration;

import com.sky.constant.MessageConstant;
import com.sky.exception.OrderBusinessException;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

// 订单状态流转规则的单元测试
class OrderStatusTest {

    /** 正常流转：待付款、待接单、待派送、派送中、已完成依次放行 */
    @Test
    void shouldAllowNormalFlow() {
        assertTrue(OrderStatus.canTransfer(1, 2));
        assertTrue(OrderStatus.canTransfer(2, 3));
        assertTrue(OrderStatus.canTransfer(3, 4));
        assertTrue(OrderStatus.canTransfer(4, 5));
    }

    /** 派送前可以取消：待付款、待接单、待派送都允许取消 */
    @Test
    void shouldAllowCancelBeforeDelivery() {
        assertTrue(OrderStatus.canTransfer(1, 6));
        assertTrue(OrderStatus.canTransfer(2, 6));
        assertTrue(OrderStatus.canTransfer(3, 6));
        // 派送中不能再取消
        assertFalse(OrderStatus.canTransfer(4, 6));
    }

    /** 不允许跳状态，也不允许往回退 */
    @Test
    void shouldRejectSkippingAndBackward() {
        assertFalse(OrderStatus.canTransfer(1, 3));
        assertFalse(OrderStatus.canTransfer(1, 5));
        assertFalse(OrderStatus.canTransfer(3, 2));
        assertFalse(OrderStatus.canTransfer(5, 1));
    }

    /** 相同状态和终态（已完成、已取消）都不允许再流转 */
    @Test
    void shouldRejectSameAndTerminalStatus() {
        assertFalse(OrderStatus.canTransfer(1, 1));
        assertFalse(OrderStatus.canTransfer(5, 5));
        assertFalse(OrderStatus.canTransfer(5, 6));
        assertFalse(OrderStatus.canTransfer(6, 1));
        assertFalse(OrderStatus.canTransfer(7, 1));
    }

    /** 状态码不在枚举里或者是 null 时返回 false，不抛异常 */
    @Test
    void shouldRejectUnknownStatus() {
        assertFalse(OrderStatus.canTransfer(99, 1));
        assertFalse(OrderStatus.canTransfer(0, 1));
        assertFalse(OrderStatus.canTransfer(null, 1));
        assertFalse(OrderStatus.canTransfer(1, null));
    }

    /** 合法流转不报错，非法流转抛业务异常并带上错误提示 */
    @Test
    void checkTransferShouldThrowOnIllegalTransition() {
        assertDoesNotThrow(() -> OrderStatus.checkTransfer(1, 2));

        OrderBusinessException exception = assertThrows(OrderBusinessException.class,
                () -> OrderStatus.checkTransfer(5, 1));
        assertEquals(MessageConstant.ORDER_STATUS_ERROR, exception.getMessage());
    }
}
