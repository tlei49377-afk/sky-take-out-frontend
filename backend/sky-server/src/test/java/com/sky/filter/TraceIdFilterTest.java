package com.sky.filter;

import org.junit.jupiter.api.Test;
import org.slf4j.MDC;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;

// traceId 过滤器的单元测试
class TraceIdFilterTest {

    private final TraceIdFilter filter = new TraceIdFilter();

    /** 请求头没带 traceId 时自动生成 16 位，写回响应头，处理完清掉 MDC */
    @Test
    void shouldGenerateTraceIdAndClearMdc() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest();
        MockHttpServletResponse response = new MockHttpServletResponse();
        List<String> seenInChain = new ArrayList<>();

        filter.doFilter(request, response, (req, res) -> seenInChain.add(MDC.get(TraceIdFilter.TRACE_ID)));

        assertEquals(1, seenInChain.size());
        String traceId = seenInChain.get(0);
        assertNotNull(traceId);
        assertEquals(16, traceId.length());
        // 响应头要回写，方便前端或网关拿这个 id 来查日志
        assertEquals(traceId, response.getHeader(TraceIdFilter.TRACE_ID_HEADER));
        // 线程是复用的，请求处理完必须清掉
        assertNull(MDC.get(TraceIdFilter.TRACE_ID));
    }

    /** 请求头带了 traceId 就直接沿用，不再重新生成 */
    @Test
    void shouldReuseUpstreamTraceId() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.addHeader(TraceIdFilter.TRACE_ID_HEADER, "upstream-abc-123");
        MockHttpServletResponse response = new MockHttpServletResponse();
        List<String> seenInChain = new ArrayList<>();

        filter.doFilter(request, response, (req, res) -> seenInChain.add(MDC.get(TraceIdFilter.TRACE_ID)));

        assertEquals("upstream-abc-123", seenInChain.get(0));
        assertEquals("upstream-abc-123", response.getHeader(TraceIdFilter.TRACE_ID_HEADER));
    }

    /** 传进来的 traceId 过长要截断到 64 位，避免脏数据撑爆日志 */
    @Test
    void shouldTrimTooLongTraceId() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.addHeader(TraceIdFilter.TRACE_ID_HEADER, "x".repeat(100));
        MockHttpServletResponse response = new MockHttpServletResponse();
        List<String> seenInChain = new ArrayList<>();

        filter.doFilter(request, response, (req, res) -> seenInChain.add(MDC.get(TraceIdFilter.TRACE_ID)));

        assertEquals(64, seenInChain.get(0).length());
    }

    /** traceId 是空白字符串时按缺失处理，重新生成 */
    @Test
    void shouldReplaceBlankTraceId() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.addHeader(TraceIdFilter.TRACE_ID_HEADER, "   ");
        MockHttpServletResponse response = new MockHttpServletResponse();
        List<String> seenInChain = new ArrayList<>();

        filter.doFilter(request, response, (req, res) -> seenInChain.add(MDC.get(TraceIdFilter.TRACE_ID)));

        assertEquals(16, seenInChain.get(0).length());
    }

    /** 后续处理抛异常时 MDC 也要清掉，不能污染复用的线程 */
    @Test
    void shouldClearMdcWhenChainThrows() {
        MockHttpServletRequest request = new MockHttpServletRequest();
        MockHttpServletResponse response = new MockHttpServletResponse();

        assertThrows(IllegalStateException.class, () -> filter.doFilter(request, response, (req, res) -> {
            throw new IllegalStateException("解析请求失败");
        }));

        assertNull(MDC.get(TraceIdFilter.TRACE_ID));
    }
}
