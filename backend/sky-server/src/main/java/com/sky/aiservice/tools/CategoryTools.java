package com.sky.aiservice.tools;

import com.sky.entity.Category;
import com.sky.service.CategoryService;
import dev.langchain4j.agent.tool.P;
import dev.langchain4j.agent.tool.Tool;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * AI 助手的分类查询工具。
 */
@Component
@Slf4j
public class CategoryTools {

    @Autowired
    private CategoryService categoryService;

    @Tool("查询菜品分类或套餐分类的列表。返回分类的名称、所属类型。"
            + "当用户询问有哪些分类、有没有某个分类时，调用此工具。"
            + "注意：只返回当前「启用中」的分类，已禁用的分类查不到。")
    public String queryCategory(
            @P(value = "分类类型：1 表示菜品分类，2 表示套餐分类。用户没有指定类型时传 -1 表示查询全部", required = false)
            Integer type) {

        log.info("AI 工具调用 -> queryCategory(type={})", type);

        try {
            // mapper 的 <if test="type != null"> 决定：传 null 表示不加类型条件，查全部
            Integer queryType = (type == null || type == -1) ? null : type;

            List<Category> categories = categoryService.list(queryType);

            if (categories == null || categories.isEmpty()) {
                return "没有查询到符合条件的分类。";
            }

            StringBuilder sb = new StringBuilder();
            sb.append("共查询到 ").append(categories.size()).append(" 个启用中的分类：\n");

            int index = 1;
            for (Category category : categories) {
                sb.append(index++).append(". ")
                  .append(category.getName())
                  .append(" | 类型：").append(toTypeText(category.getType()))
                  .append("\n");
            }
            return sb.toString();

        } catch (Exception e) {
            log.error("AI 工具 queryCategory 执行失败", e);
            return "查询分类时发生错误：" + e.getMessage();
        }
    }

    private String toTypeText(Integer type) {
        if (type == null) {
            return "未知";
        }
        if (type == 1) {
            return "菜品分类";
        }
        if (type == 2) {
            return "套餐分类";
        }
        return "未知";
    }
}
