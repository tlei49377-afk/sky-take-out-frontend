package com.sky.task;

import com.sky.entity.Orders;
import com.sky.mapper.OrderMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 订单定时任务类：定时处理待订单状态
 */
@Component
@Slf4j
public class OrderTask {

    // 每批处理的订单数量
    private static final int BATCH_SIZE = 100;

    @Autowired
    private OrderMapper orderMapper;

    /**
     * 处理超时订单
     */
    @Scheduled(cron = "0 * * * * ?") // 每分钟执行一次
    public void processTimeoutOrders(){
        log.info("处理超时订单：{}", LocalDateTime.now());

        LocalDateTime deadline = LocalDateTime.now().plusMinutes(-15);
        int handled = 0;

        // 分批处理，避免一次捞出过多订单
        while (true){
            List<Orders> ordersList = orderMapper.getByStatusAudOrderTimeLT(Orders.PENDING_PAYMENT, deadline, BATCH_SIZE);
            if (ordersList == null || ordersList.isEmpty()){
                break;
            }

            for (Orders orders : ordersList){
                Orders update = Orders.builder()
                        .id(orders.getId())
                        .status(Orders.CANCELLED)
                        .cancelReason("支付超时，自动取消")
                        .cancelTime(LocalDateTime.now())
                        .build();

                // 带上原状态更新，订单在这期间被支付就不会被误取消
                if (orderMapper.updateStatusIfMatch(update, Orders.PENDING_PAYMENT) > 0){
                    handled++;
                }
            }

            if (ordersList.size() < BATCH_SIZE){
                break;
            }
        }

        log.info("超时订单处理完成，自动取消 {} 笔", handled);
    }

    /**
     * 处理一直处于派送中的订单
     */
    @Scheduled(cron = "0 0 1 * * ?") // 每日0点执行一次
    public void processDeliveryOrders(){
        log.info("处理处于派送中的订单：{}", LocalDateTime.now());

        LocalDateTime deadline = LocalDateTime.now().plusMinutes(-60);
        int handled = 0;

        while (true){
            List<Orders> ordersList = orderMapper.getByStatusAudOrderTimeLT(Orders.DELIVERY_IN_PROGRESS, deadline, BATCH_SIZE);
            if (ordersList == null || ordersList.isEmpty()){
                break;
            }

            for (Orders orders : ordersList){
                Orders update = Orders.builder()
                        .id(orders.getId())
                        .status(Orders.COMPLETED)
                        .deliveryTime(LocalDateTime.now())
                        .build();

                if (orderMapper.updateStatusIfMatch(update, Orders.DELIVERY_IN_PROGRESS) > 0){
                    handled++;
                }
            }

            if (ordersList.size() < BATCH_SIZE){
                break;
            }
        }

        log.info("派送中订单处理完成，自动完成 {} 笔", handled);
    }
}
