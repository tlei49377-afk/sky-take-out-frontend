package com.sky.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.MDC;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.UUID;

/**
 * 给每个请求准备一个 traceId，放进 MDC 供日志使用，并写回响应头
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class TraceIdFilter implements Filter {

    //日志里使用的 MDC key
    public static final String TRACE_ID = "traceId";

    //请求头与响应头里的名字
    public static final String TRACE_ID_HEADER = "X-Trace-Id";

    //上游带了 traceId 就用它的，只截前 64 位，防止超长内容把日志撑爆
    private static final int MAX_LENGTH = 64;

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        String traceId = resolveTraceId((HttpServletRequest) request);
        MDC.put(TRACE_ID, traceId);
        ((HttpServletResponse) response).setHeader(TRACE_ID_HEADER, traceId);
        try {
            chain.doFilter(request, response);
        } finally {
            //线程是复用的，处理完必须清掉
            MDC.remove(TRACE_ID);
        }
    }

    /**
     * 取请求头里的 traceId，没有就生成一个
     * @param request
     * @return
     */
    private String resolveTraceId(HttpServletRequest request) {
        String traceId = request.getHeader(TRACE_ID_HEADER);
        if (traceId == null || traceId.isBlank()) {
            return UUID.randomUUID().toString().replace("-", "").substring(0, 16);
        }
        return traceId.length() > MAX_LENGTH ? traceId.substring(0, MAX_LENGTH) : traceId;
    }
}
