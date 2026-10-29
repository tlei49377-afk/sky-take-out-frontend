-- ============================================================
-- V5：支付回调流水，用于回调幂等
-- 同一笔交易的重复通知会因唯一键冲突被忽略
-- ============================================================

USE sky_take_out;

CREATE TABLE IF NOT EXISTS payment_callback_log (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  out_trade_no VARCHAR(64) NOT NULL COMMENT '商户订单号',
  transaction_id VARCHAR(64) NOT NULL COMMENT '微信支付交易号',
  create_time DATETIME,
  UNIQUE KEY uk_out_trade_transaction (out_trade_no, transaction_id)
) COMMENT '支付回调流水';
