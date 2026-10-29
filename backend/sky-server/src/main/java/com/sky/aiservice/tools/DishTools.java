package com.sky.aiservice.tools;

import com.sky.dto.DishDTO;
import com.sky.dto.DishPageQueryDTO;
import com.sky.entity.Category;
import com.sky.entity.DishFlavor;
import com.sky.result.PageResult;
import com.sky.service.CategoryService;
import com.sky.service.DishService;
import com.sky.vo.DishVO;
import dev.langchain4j.agent.tool.P;
import dev.langchain4j.agent.tool.Tool;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.List;

/**
 * AI 助手的菜品查询工具。
 * 每个 @Tool 方法都会作为「函数」暴露给大模型，由模型决定何时调用。
 */
@Component
@Slf4j
public class DishTools {

    @Autowired
    private DishService dishService;

    @Autowired
    private CategoryService categoryService;

    //分类类型：1 菜品分类
    private static final Integer CATEGORY_TYPE_DISH = 1;

    //单次最多返回的条数，避免把过多数据塞给模型浪费 token
    private static final int PAGE_SIZE = 10;

    @Tool("查询菜品信息。可以根据菜品名称、分类名称、售卖状态查询菜品列表，"
            + "返回菜品的名称、所属分类、价格和售卖状态。"
            + "当用户询问某个菜品、某个分类下有哪些菜、某道菜的价格时，调用此工具。")
    public String queryDish(
            @P(value = "菜品名称关键字，支持模糊匹配。用户没有提到具体菜名时传空字符串", required = false)
            String dishName,

            @P(value = "菜品分类名称，例如“酒水饮料”“蜀味烤鱼”“特色蒸菜”。用户没有提到分类时传空字符串", required = false)
            String categoryName,

            @P(value = "菜品的售卖状态：1 表示起售（在售），0 表示停售（已下架）。用户没有提到状态时传 -1", required = false)
            Integer status) {

        log.info("AI 工具调用 -> queryDish(dishName={}, categoryName={}, status={})",
                dishName, categoryName, status);

        try {
            DishPageQueryDTO dto = new DishPageQueryDTO();
            dto.setPage(1);
            dto.setPageSize(PAGE_SIZE);

            if (isNotBlank(dishName)) {
                dto.setName(dishName.trim());
            }

            // 用户说的是「分类名称」，而 DTO 需要的是「分类 id」，这里必须做一次转换
            if (isNotBlank(categoryName)) {
                Long categoryId = findDishCategoryId(categoryName.trim());
                if (categoryId == null) {
                    return "没有找到名为「" + categoryName + "」的菜品分类，请确认分类名称是否正确。";
                }
                dto.setCategoryId(categoryId.intValue());
            }

            if (status != null && status != -1) {
                dto.setStatus(status);
            }

            PageResult pageResult = dishService.page(dto);

            @SuppressWarnings("unchecked")
            List<DishVO> records = pageResult.getRecords();

            if (records == null || records.isEmpty()) {
                return "没有查询到符合条件的菜品。";
            }

            StringBuilder sb = new StringBuilder();
            sb.append("共查询到 ").append(pageResult.getTotal())
              .append(" 道菜品，以下是最多 ").append(records.size()).append(" 条结果：\n");

            int index = 1;
            for (DishVO dish : records) {
                sb.append(index++).append(". ")
                  .append(dish.getName())
                  .append(" | 分类：").append(dish.getCategoryName() == null ? "未知" : dish.getCategoryName())
                  .append(" | 价格：").append(dish.getPrice()).append(" 元")
                  .append(" | 状态：").append(toStatusText(dish.getStatus()))
                  .append("\n");
            }
            return sb.toString();

        } catch (Exception e) {
            // 工具内部必须自行兜底：抛异常会中断整轮对话，用户只会看到报错
            log.error("AI 工具 queryDish 执行失败", e);
            return "查询菜品时发生错误：" + e.getMessage();
        }
    }

    /**
     * 把分类名称解析成分类 id。
     * 先精确匹配，再模糊匹配（“热菜” 与 “热菜类” 这种能对上）。
     * 注意：底层 mapper 只返回「启用状态」的分类。
     */
    private Long findDishCategoryId(String categoryName) {
        List<Category> categories = categoryService.list(CATEGORY_TYPE_DISH);
        if (categories == null || categories.isEmpty()) {
            return null;
        }
        for (Category category : categories) {
            if (categoryName.equals(category.getName())) {
                return category.getId();
            }
        }
        for (Category category : categories) {
            String name = category.getName();
            if (name != null && (name.contains(categoryName) || categoryName.contains(name))) {
                return category.getId();
            }
        }
        return null;
    }

    private String toStatusText(Integer status) {
        if (status == null) {
            return "未知";
        }
        return status == 1 ? "起售" : "停售";
    }



    @Tool("删除菜品。用户要求删除某道菜时调用。"
            + "注意：只有「停售」且「未被套餐关联」的菜才能删除；执行前请先向用户确认。")
    public String deleteDish(@P("要删除的菜品名称，支持模糊匹配。") String dishName){
        log.info("AI 工具调用 -> deleteDish(dishName={})", dishName);
        try{
            if(isNotBlank(dishName)){
                // 1. 按名称查出菜品 id（菜品名可能重复，取前几条让用户确认更好）
                DishPageQueryDTO dto = new DishPageQueryDTO();
                dto.setPage(1); // 设置当前页为1
                dto.setPageSize(PAGE_SIZE); // 设置每页大小
                dto.setName(dishName.trim()); // 设置菜品名称关键字
                PageResult page = dishService.page(dto); // 执行分页查询
                List<DishVO> records = page.getRecords(); // 获取分页数据
                if(records == null || records.isEmpty()){
                    return "没有找到名为「" + dishName + "」的菜品，请确认菜品名称是否正确。";
                }
                // 2.转成 id 列表
                List<Long> ids = records.stream().map(DishVO::getId).toList();
                // 3.调用服务删除
                dishService.deleteBatch(ids);
                return "成功删除名为「" + dishName + "」的菜品。";
            }
            return "请输入要删除的菜品名称。";
        } catch (Exception e) {
            log.error("AI 工具 deleteDish 执行失败", e);
            return "删除菜品时发生错误：" + e.getMessage();
        }
    }

    @Tool("新增菜品。用户要求添加新菜品时调用。")
    public String addDish(
            @P("菜品名称") String name,
            @P("菜品所属分类名称，例如「蜀味烤鱼」") String categoryName,
            @P("菜品价格（元），数字") java.math.BigDecimal price,
            @P(value = "菜品描述，可空", required = false) String description
    ){
        log.info("AI 工具调用 -> addDish(name={}, categoryName={}, price={}, description={})", name, categoryName, price, description);
        try{
            Long categoryId = findDishCategoryId(categoryName);
            if (categoryId == null) {
                return "没有找到名为「" + categoryName + "」的菜品分类，请先确认分类名称或先创建分类。";
            }
            DishDTO dto = new DishDTO();
            dto.setName(name);
            dto.setCategoryId(categoryId);
            dto.setPrice(price);
            dto.setDescription(description);
            dto.setStatus(1); // 设置状态为起售
            dishService.saveWithFlavor(dto); // 保存菜品及口味
            return "成功添加菜品「" + name + "」。";
        } catch (Exception e) {
            log.error("AI 工具 addDish 执行失败", e);
            return "添加菜品时发生错误：" + e.getMessage();
        }
    }

    @Tool("菜品起售（上架）或停售（下架）。用户要求上架、下架、起售、停售某道菜，"
            + "或把某个分类下的菜全部上下架时，调用此工具。"
            + "可以只按菜品名称操作，也可以按分类名称批量操作（此时菜品名称传空字符串）。"
            + "注意：本工具只负责改售卖状态，改价格、改名称请用 updateDish。")
    public String startOrStopDish(
            @P(value = "菜品名称关键字，支持模糊匹配。用户没有提到具体菜名时传空字符串", required = false)
            String dishName,

            @P(value = "菜品分类名称，例如“酒水饮料”“蜀味烤鱼”。用于把某个分类下的菜品全部上下架，用户没有提到分类时传空字符串", required = false)
            String categoryName,

            @P("目标状态：1 表示起售（上架），0 表示停售（下架）")
            Integer status) {

        log.info("AI 工具调用 -> startOrStopDish(dishName={}, categoryName={}, status={})",
                dishName, categoryName, status);

        try {
            // 状态只能传 0 或 1，模型偶尔会传 -1 或别的值，这里直接拦下来
            if (status == null || (status != 1 && status != 0)) {
                return "请明确是要「起售（上架）」还是「停售（下架）」，目标状态只能是 1（起售）或 0（停售）。";
            }
            if (!isNotBlank(dishName) && !isNotBlank(categoryName)) {
                return "请提供要操作的菜品名称，或者要批量操作的分类名称。";
            }

            DishPageQueryDTO dto = new DishPageQueryDTO();
            dto.setPage(1);
            dto.setPageSize(PAGE_SIZE);

            if (isNotBlank(dishName)) {
                dto.setName(dishName.trim());
            }
            if (isNotBlank(categoryName)) {
                Long categoryId = findDishCategoryId(categoryName.trim());
                if (categoryId == null) {
                    return "没有找到名为「" + categoryName + "」的菜品分类，请确认分类名称是否正确。";
                }
                dto.setCategoryId(categoryId.intValue());
            }

            PageResult pageResult = dishService.page(dto);

            @SuppressWarnings("unchecked")
            List<DishVO> records = pageResult.getRecords();

            if (records == null || records.isEmpty()) {
                return "没有找到符合条件的菜品，无法上下架。";
            }

            // 上下架是可恢复操作，所以允许批量；逐条调用，单条失败不影响已成功的部分
            StringBuilder done = new StringBuilder();
            StringBuilder failed = new StringBuilder();
            int successCount = 0;
            for (DishVO dish : records) {
                try {
                    dishService.startOrStop(status, dish.getId());
                    successCount++;
                    done.append(dish.getName()).append("、");
                } catch (Exception e) {
                    log.error("菜品 {} 上下架失败", dish.getId(), e);
                    failed.append(dish.getName()).append("（").append(e.getMessage()).append("）、");
                }
            }

            String action = status == 1 ? "起售（上架）" : "停售（下架）";
            StringBuilder sb = new StringBuilder();
            sb.append("已将 ").append(successCount).append(" 道菜品").append(action).append("：");
            if (done.length() > 0) {
                sb.append(done, 0, done.length() - 1);
            }
            if (failed.length() > 0) {
                sb.append("。以下菜品操作失败：").append(failed, 0, failed.length() - 1);
            }
            if (status == 0) {
                sb.append("。提示：菜品停售后，包含它的套餐会被自动停售。");
            }
            return sb.toString();

        } catch (Exception e) {
            log.error("AI 工具 startOrStopDish 执行失败", e);
            return "菜品上下架时发生错误：" + e.getMessage();
        }
    }

    @Tool("修改菜品的基本信息，包括菜品名称、所属分类、价格、描述。"
            + "用户要求改菜名、改价格、换分类、改描述时，调用此工具。"
            + "只传需要修改的字段，不需要改的字段留空即可。"
            + "注意：本工具不能改售卖状态（上下架请用 startOrStopDish），也不能改口味（辣度、忌口等）。")
    public String updateDish(
            @P("要修改的菜品当前名称，支持模糊匹配")
            String dishName,

            @P(value = "菜品当前所属的分类名称，用于菜品重名时精确定位。用户没有提到时传空字符串", required = false)
            String categoryName,

            @P(value = "修改后的新菜品名称。不修改名称时传空字符串", required = false)
            String newName,

            @P(value = "修改后的新分类名称，例如“特色蒸菜”。不修改分类时传空字符串", required = false)
            String newCategoryName,

            @P(value = "修改后的新价格（元），数字。不修改价格时传 -1", required = false)
            BigDecimal newPrice,

            @P(value = "修改后的新描述。不修改描述时传空字符串", required = false)
            String newDescription) {

        log.info("AI 工具调用 -> updateDish(dishName={}, categoryName={}, newName={}, newCategoryName={}, newPrice={}, newDescription={})",
                dishName, categoryName, newName, newCategoryName, newPrice, newDescription);

        try {
            if (!isNotBlank(dishName)) {
                return "请提供要修改的菜品名称。";
            }

            // 1. 先按名称（可加分类）定位菜品
            DishPageQueryDTO query = new DishPageQueryDTO();
            query.setPage(1);
            query.setPageSize(PAGE_SIZE);
            query.setName(dishName.trim());

            if (isNotBlank(categoryName)) {
                Long categoryId = findDishCategoryId(categoryName.trim());
                if (categoryId == null) {
                    return "没有找到名为「" + categoryName + "」的菜品分类，请确认分类名称是否正确。";
                }
                query.setCategoryId(categoryId.intValue());
            }

            PageResult pageResult = dishService.page(query);

            @SuppressWarnings("unchecked")
            List<DishVO> records = pageResult.getRecords();

            if (records == null || records.isEmpty()) {
                return "没有找到名为「" + dishName + "」的菜品，无法修改。";
            }

            // 2. 改操作必须精确到唯一一道菜：重名时先让用户确认，绝不批量改
            if (records.size() > 1) {
                StringBuilder sb = new StringBuilder();
                sb.append("名称包含「").append(dishName).append("」的菜品有 ").append(records.size())
                  .append(" 道，无法确定要修改哪一道，请告诉用户确认后再操作：");
                for (DishVO dish : records) {
                    sb.append("\n- ").append(dish.getName())
                      .append("（分类：").append(dish.getCategoryName() == null ? "未知" : dish.getCategoryName())
                      .append("，价格：").append(dish.getPrice()).append(" 元）");
                }
                return sb.toString();
            }

            DishVO target = records.get(0);

            // 3. 校验至少有一个字段需要改
            boolean changeName = isNotBlank(newName);
            boolean changeCategory = isNotBlank(newCategoryName);
            boolean changePrice = newPrice != null && newPrice.compareTo(BigDecimal.ZERO) > 0;
            boolean changeDescription = isNotBlank(newDescription);

            if (!changeName && !changeCategory && !changePrice && !changeDescription) {
                return "没有提供任何要修改的内容，请告诉我要改菜品的名称、分类、价格还是描述。";
            }

            // 4. 查出原有口味并原样保留：
            //    updateWithFlavor 会先删掉全部口味再插入 DTO 里的口味，
            //    如果这里不把老口味带上，用户改个价格就会把口味全丢掉。
            DishVO current = dishService.getByIdWithFlavor(target.getId());
            List<DishFlavor> keepFlavors = current.getFlavors();

            DishDTO dto = new DishDTO();
            dto.setId(target.getId());
            dto.setFlavors(keepFlavors == null ? List.of() : keepFlavors);
            // 未传的字段保持 null，DishMapper.update 的动态 SQL 会跳过 null 字段，不会覆盖原值

            if (changeName) {
                dto.setName(newName.trim());
            }
            if (changeCategory) {
                Long newCategoryId = findDishCategoryId(newCategoryName.trim());
                if (newCategoryId == null) {
                    return "没有找到名为「" + newCategoryName + "」的菜品分类，请确认分类名称是否正确。";
                }
                dto.setCategoryId(newCategoryId);
            }
            if (changePrice) {
                dto.setPrice(newPrice);
            }
            if (changeDescription) {
                dto.setDescription(newDescription.trim());
            }

            dishService.updateWithFlavor(dto);

            // 5. 组装修改结果，方便模型转述给用户
            StringBuilder sb = new StringBuilder();
            sb.append("已修改菜品「").append(target.getName()).append("」：");
            if (changeName) {
                sb.append("名称→").append(newName.trim()).append("；");
            }
            if (changeCategory) {
                sb.append("分类→").append(newCategoryName.trim()).append("；");
            }
            if (changePrice) {
                sb.append("价格→").append(newPrice).append(" 元；");
            }
            if (changeDescription) {
                sb.append("描述→").append(newDescription.trim()).append("；");
            }
            return sb.toString();

        } catch (Exception e) {
            log.error("AI 工具 updateDish 执行失败", e);
            return "修改菜品时发生错误：" + e.getMessage();
        }
    }

    private boolean isNotBlank(String text) {
        return text != null && !text.trim().isEmpty();
    }
}
