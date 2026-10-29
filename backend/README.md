# 智能外卖平台

一个面向餐厅的外卖管理平台，包含**管理端后台**与**用户端下单**两套业务，并集成了基于 **LangChain4j + 通义千问** 的 **AI 助手**——支持用自然语言查询菜品、分类、订单，也支持执行新增、修改、删除菜品和上下架等写操作。

本文件是归档仓库中的后端详细说明。统一的部署入口和前后端启动步骤请先阅读上级目录的 [README.md](../README.md)。
---

## 目录

- [功能特性](#功能特性)
- [技术栈](#技术栈)
- [项目结构](#项目结构)
- [环境要求](#环境要求)
- [快速开始](#快速开始)
- [配置说明](#配置说明)
- [性能优化](#性能优化)
- [缓存设计](#缓存设计)
- [可观测性](#可观测性)
- [测试](#测试)
- [AI 助手](#ai-助手)
  - [实现方式](#实现方式)
  - [工具清单](#工具清单)
  - [写操作的安全机制](#写操作的安全机制)
  - [会话管理](#会话管理)
  - [接口](#接口)
  - [行为约束](#行为约束)
  - [能力边界](#能力边界)
  - [前端入口](#前端入口)
- [接口文档](#接口文档)
- [常见问题](#常见问题)
- [项目来源](#项目来源)

---

## 功能特性

### 管理端

| 模块 | 说明 |
|---|---|
| 员工管理 | 员工登录、新增/编辑（可同时分配角色、设置登录密码）、启用禁用、分页查询 |
| 分类管理 | 菜品分类与套餐分类的增删改查、启用禁用 |
| 菜品管理 | 菜品增删改查、口味配置、图片上传、起售停售 |
| 套餐管理 | 套餐增删改查、关联菜品、起售停售 |
| 订单管理 | 订单搜索、接单/拒单、派送/完成、各状态订单统计 |
| 数据统计 | 工作台、营业额统计、用户统计、订单统计、销量排名 Top10 |
| 报表导出 | 运营数据报表导出 Excel |
| 店铺管理 | 营业状态设置（营业中 / 打烊中） |
| 角色权限 | 新增自定义角色、角色权限分配、员工角色分配，在「员工管理」页签内维护（也可直接访问 `/rbac.html`） |
| **AI 助手** | **自然语言查询数据 + 菜品增删改与上下架**，带历史会话管理 |

### 用户端

- 微信登录、浏览分类 / 菜品 / 套餐
- 购物车、收货地址管理
- 下单、微信支付、取消订单、再来一单
- 历史订单查询、订单详情

### 平台能力

- **RBAC 权限控制**：登录返回权限码，接口用自定义注解 + AOP 校验，改角色/改权限后缓存即时失效
- **权限规则**：不能修改自己的角色；超级管理员的角色与资料不允许被他人改动；超级管理员账号不允许被禁用
- **WebSocket 来单提醒**：新订单实时推送到管理端
- **定时任务**：每分钟处理超时未支付订单，每日凌晨处理派送中订单
- **微信支付**：支付与退款回调处理
- **阿里云 OSS**：菜品图片云存储
- **百度地图**：商家端配送距离检测

---

## 技术栈

### 后端

| 技术 | 版本 | 说明 |
|---|---|---|
| Spring Boot | 3.5.0 | 基础框架（Jakarta EE） |
| Java | 17 | 继承 `spring-boot-starter-parent` 的 `java.version` |
| MyBatis | 3.0.3 | 持久层框架 |
| PageHelper | 1.4.7 | 分页插件 |
| MySQL | 8.0.33 | 数据库（`mysql-connector-j`） |
| Druid | 1.2.28 | 数据库连接池（`druid-spring-boot-3-starter`） |
| Redis | — | 业务缓存、AI 会话记忆与会话清单 |
| Knife4j | 4.5.0 | 接口文档（OpenAPI 3 / springdoc） |
| LangChain4j | 1.0.1-beta6 | AI 应用框架（Function Calling、流式输出、会话记忆） |
| Apache POI | 3.16 | Excel 报表导出 |
| JJWT | 0.9.1 | JWT 令牌 |
| WebSocket | — | 来单提醒 |

### 前端

- Vue 2 + Element UI（编译产物，无源码）
- Nginx 托管静态资源并反向代理后端接口
- AI 助手页为独立页面 `ai-chat.html`，由主应用通过 iframe 嵌入

---

## 项目结构

```
sky-take-out
├── db/                  数据库脚本：建表语句与基础数据
├── sky-common/          通用模块：常量、上下文、枚举、异常、工具类、统一返回结果
├── sky-pojo/            实体模块：Entity、DTO、VO
├── sky-server/          服务模块：Controller、Service、Mapper、Config、Task
│   └── src/main/java/com/sky/
│       ├── controller/
│       │   ├── admin/       管理端接口（含 ChatController）
│       │   ├── user/        用户端接口
│       │   └── notify/      支付回调
│       ├── service/         业务逻辑（含 ChatSessionService：AI 会话清单）
│       ├── mapper/          数据访问
│       ├── repository/      Redis 存储（RedisChatMemoryStore：AI 会话记忆）
│       ├── config/          Spring 配置
│       ├── task/            定时任务
│       ├── websocket/       WebSocket 服务
│       └── aiservice/       AI 助手
│           ├── ConsultantService.java   AiService 接口声明
│           └── tools/                   @Tool 工具：DishTools / CategoryTools / OrderTools
└── pom.xml              父 POM，统一依赖版本管理
```

---

## 环境要求

| 组件 / 依赖 | 版本要求 |
|---|---|
| JDK | 17 及以上 |
| Maven | 3.6+ |
| MySQL | 8.0+ |
| Redis | 5.0+ |
| Nginx | 1.20+（前端部署，可选） |
| 通义千问 API Key | 启动必需，环境变量 `QW-API-KEY` |

---

## 快速开始

### 1. 准备数据库

表结构与基础数据都在 `db/sky_take_out.sql`，脚本内已包含 `CREATE DATABASE sky_take_out`，不需要先手动建库：

```bash
# Linux / macOS
mysql -uroot -p < db/sky_take_out.sql

# Windows（PowerShell 不支持 < 重定向）
mysql -uroot -p -e "source db/sky_take_out.sql"
```

导入后应是 16 张表（12 张业务表 + 4 张权限表），其中 10 个分类、25 道菜品、2 个套餐。

内置账号密码统一是 `123456`：

| 用户名 | 姓名 | 角色 | 权限范围 |
|---|---|---|---|
| `admin` | 管理员 | 超级管理员 | 全部 28 个权限点 |
| `lisi` | 李四 | 运营 | 菜品 / 分类 / 套餐维护、订单查询处理 |
| `liming` | 黎静 | 财务 | 订单查询、报表导出 |
| `zhangsan` | 张三 | 后厨 | 套餐维护、订单查询处理 |
| `wangwu` | 王五 | 客服 | 订单查询 / 处理 / 取消、报表查询 |
| `zhaoliu` | 赵六 | 审计 | 订单与报表只读 |
| `sunqi` | 孙七 | 运营 + 财务 | 两个角色的权限并集 |

用其中任意账号登录即可体验：接口权限按登录账号的角色实时校验，改角色或改权限后无需重新登录，下一次请求就生效。

### 2. 配置后端

敏感配置**不进入版本库**：仓库里只保留模板
`sky-server/src/main/resources/application-dev.yml.example`，
真实的 `application-dev.yml` 已被 `.gitignore` 忽略。

**方式一：本地配置文件（推荐）**

```bash
# Windows
copy sky-server\src\main\resources\application-dev.yml.example sky-server\src\main\resources\application-dev.yml

# Linux / macOS
cp sky-server/src/main/resources/application-dev.yml.example sky-server/src/main/resources/application-dev.yml
```

然后编辑 `application-dev.yml`，把占位符替换成自己的真实配置：

```yaml
sky:
  jwt:
    # 不少于 32 字节的随机字符串，管理端与用户端分别设置
    admin-secret-key: 你的管理端密钥
    user-secret-key: 你的用户端密钥
  datasource:
    host: localhost
    port: 3306
    database: sky_take_out
    username: root
    password: 你的密码
  redis:
    host: localhost
    port: 6379
    password: 你的Redis密码
    database: 10
```

> `application.yml` 里 `sky.jwt` 的两个密钥不写默认值，真实值只存在于本文件或环境变量中。
> 生成随机密钥：`openssl rand -base64 32`（Git Bash / Linux / macOS 均可），长度不少于 32 字节。

**方式二：环境变量（CI/CD、容器部署）**

Spring Boot 会用环境变量覆盖同名配置项，转换规则是
**大写 + 点号换成下划线**（`sky.datasource.password` → `SKY_DATASOURCE_PASSWORD`）：

| 配置属性 | 环境变量 |
|---|---|
| `sky.datasource.host` | `SKY_DATASOURCE_HOST` |
| `sky.datasource.password` | `SKY_DATASOURCE_PASSWORD` |
| `sky.redis.password` | `SKY_REDIS_PASSWORD` |
| `sky.alioss.access-key-id` | `SKY_ALIOSS_ACCESS_KEY_ID` |
| `sky.alioss.access-key-secret` | `SKY_ALIOSS_ACCESS_KEY_SECRET` |
| `sky.wechat.secret` | `SKY_WECHAT_SECRET` |
| `sky.baidu.ak` | `SKY_BAIDU_AK` |
| `sky.jwt.admin-secret-key` | `SKY_JWT_ADMIN_SECRET` |
| `sky.jwt.user-secret-key` | `SKY_JWT_USER_SECRET` |

```bash
# Windows (PowerShell)
$env:SKY_DATASOURCE_PASSWORD="你的MySQL密码"

# Linux / macOS
export SKY_DATASOURCE_PASSWORD=你的MySQL密码
```

> 在 IDEA 中运行：`Run/Debug Configurations` → `Environment variables` 填写即可。
> 环境变量优先级高于 `application-dev.yml`，本地调试可两者混用。

### 3. 配置 AI 密钥

AI 助手的 API Key 通过**环境变量**注入，不写在配置文件里。**这一项是启动必需**：LangChain4j 的自动配置在启动阶段就要读取 `${QW-API-KEY}`，缺失会直接导致应用起不来（报错见[常见问题](#常见问题)）。启动前需设置：

```bash
# Windows (PowerShell)
$env:QW-API-KEY="你的阿里云百炼API-Key"

# Windows (CMD)
set QW-API-KEY=你的API-Key

# Linux / macOS
export QW-API-KEY=你的API-Key
```

> 在 IDEA 中运行：`Run/Debug Configurations` → `Environment variables` 填入 `QW-API-KEY=sk-xxxxxx`

### 4. 启动后端

```bash
mvn clean package -DskipTests
java -jar sky-server/target/sky-server-1.0-SNAPSHOT.jar
```

或在 IDEA 中直接运行 `com.sky.SkyApplication`。

启动成功后监听 `8080` 端口。

### 5. 部署前端

前端仓库 [sky-take-out-frontend](https://github.com/tlei49377-afk/sky-take-out-frontend) 本身就是一份 Nginx 目录：`nginx.exe` 在根目录，静态资源在 `html/sky/`，`conf/nginx.conf` 已包含下面的配置。

Windows 下在仓库根目录执行 `start nginx`（或双击 `nginx.exe`），访问 `http://localhost` 即可。若自己搭 Nginx，参照下面的配置：

```nginx
server {
    listen 80;
    server_name localhost;

    # 静态资源
    location / {
        root   html/sky;
        index  index.html;
    }

    # 管理端接口：/api/xxx -> 后端 /admin/xxx
    location /api/ {
        proxy_pass http://localhost:8080/admin/;
    }

    # 用户端接口
    location /user/ {
        proxy_pass http://127.0.0.1:8080/user/;
    }

    # WebSocket 来单提醒
    location /ws/ {
        proxy_pass http://127.0.0.1:8080/ws/;
        proxy_http_version 1.1;
        proxy_read_timeout 3600s;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

启动 Nginx 后访问 `http://localhost` 即可。

> **注意**：Nginx 的 `/api/xxx` 会转发到后端 `/admin/xxx`，因此后端管理端接口路径都带 `/admin` 前缀。AI 助手页的 `/api/chat/sessions` 也正是靠这条规则落到 `/admin/chat/sessions`，**新增接口无需改 Nginx 配置**。

---

## 配置说明

### 对外部服务的依赖

以下服务不配置不影响核心业务启动，但对应功能不可用：

| 配置项 | 用途 | 是否必需 |
|---|---|---|
| `sky.alioss.*` | 菜品图片上传到阿里云 OSS | 上传图片时需要 |
| `sky.wechat.*` | 微信支付（商户号、证书、回调地址） | 支付功能需要 |
| `sky.baidu.ak` | 百度地图距离计算 | 配送距离检测需要 |
| `QW-API-KEY` | 通义千问 API Key | **启动必需** |

### Redis 说明

项目使用**两个 Redis 实例**：

| 端口 | 用途 | 配置位置 |
|---|---|---|
| 6379 | 业务缓存、AI 会话记忆与会话清单 | `sky.redis.*`（database 10） |
| 6380 | LangChain4j 向量库（**当前未启用**） | `langchain4j.community.redis.*` |

> Spring Boot 3 中 Redis 配置前缀为 `spring.data.redis.*`（不再是 `spring.redis.*`）。

#### AI 相关的 Redis key

业务 Redis（6379 / db10）中，AI 助手会用到以下 key：

| Key | 类型 | 说明 | TTL |
|---|---|---|---|
| `chat:memory:{memoryId}` | String | 会话的完整消息序列（JSON） | 7 天，每次对话续期 |
| `chat:sessions:{empId}` | ZSet | 该管理员的会话清单，member 为 memoryId，score 为最后活跃时间戳 | 随会话淘汰 |
| `chat:session:title:{memoryId}` | String | 会话标题（取自第一条消息前 20 字） | 7 天，随会话续期 |

> 6380 的向量库虽然配置齐全（`contentRetriever` Bean 也已定义），但 `contentRetriever` **没有装配到 `@AiService`**，且负责灌数据的 `store()` Bean 被注释掉了，所以 RAG 检索目前不参与对话。
>
> 不过 `redisEmbeddingStore` 是随容器启动创建的，所以**应用启动仍然要求 6380 上跑一个带 RediSearch 模块的 Redis**（`redislabs/redisearch`、Redis Stack 之类）；用普通 Redis 顶替会因为缺少 `FT._LIST` 命令直接启动失败。

---

## 性能优化

### 慢 SQL 与索引

订单、报表相关的几条查询在数据量上来后会退化成全表扫：订单分页要按「状态 + 下单时间」过滤再倒序取页，报表统计按时间范围聚合，销量 Top10 还要 join 订单明细。

先用递归 CTE 造出 5 万订单、15 万订单明细、3 万购物车/地址、5 千员工的测试数据，靠 `EXPLAIN ANALYZE` 逐条看计划，再按真实查询补索引。索引定义写在 `db/migration/V6__index.sql`（幂等，重复执行会跳过已存在的索引），同时也并进了 `db/sky_take_out.sql` 的建表语句，新库和老库都能对上。

| 表 | 索引 | 对应的查询 |
|---|---|---|
| `orders` | `idx_status_order_time` (`status`, `order_time`) | 管理端按状态筛选的订单分页、定时任务扫超时未支付单、带状态的营业额统计 |
| `orders` | `idx_user_id_order_time` (`user_id`, `order_time`) | 用户端历史订单 |
| `orders` | `idx_order_time_status` (`order_time`, `status`) | 不带状态的时间范围统计、无过滤的订单列表排序 |
| `order_detail` | `idx_order_id` (`order_id`) | 订单明细查询、销量 Top10 的 join 驱动 |
| `dish_flavor` | `idx_dish_id` (`dish_id`) | 菜品口味查询与删除 |
| `setmeal_dish` | `idx_setmeal_id` (`setmeal_id`) | 套餐菜品查询与删除 |
| `employee` | `idx_create_time` (`create_time`) | 员工分页按创建时间倒序 |
| `employee_role` | `idx_role_id` (`role_id`) | 按角色反查员工（改角色权限后失效缓存） |
| `shopping_cart` | `idx_user_id` (`user_id`) | 购物车查询与清空 |
| `address_book` | `idx_user_id` (`user_id`) | 地址簿查询 |

### 优化前后对比

数据量 5 万订单 / 15 万明细。每次查询先 `ANALYZE TABLE`，再跑 5 遍取中位数（第 1 遍作为预热丢弃），单位毫秒：

| 查询 | 优化前 | 优化后 |
|---|---|---|
| 订单分页（状态 + 时间范围 + 倒序） | 47.7 | 0.10 |
| 订单列表（按时间倒序，无过滤） | 54.4 | 0.05 |
| 用户端历史订单 | 35.8 | 0.04 |
| 订单明细按 `order_id` | 57.2 | 0.01 |
| 购物车按 `user_id` | 11.3 | 0.02 |
| 地址簿按 `user_id` | 19.0 | 0.03 |
| 员工分页按 `create_time` 倒序 | 1.9 | 0.03 |
| 菜品口味按 `dish_id` | 9.5 | 1.3 |
| 套餐菜品按 `setmeal_id` | 9.9 | 0.4 |
| 销量 Top10（join 明细 + 聚合） | 233.5 | 57.9 |
| 按角色反查员工 | 0.7 | 0.4 |
| 定时任务扫描超时订单 | 0.8 | 0.3 |
| 营业额统计（时间范围 + 状态聚合） | 21.3 | 11.8 |
| 用户统计（时间范围 count） | 24.9 | 19.4 |

后两行是低选择率的聚合，要算的行占了整表的两成到全部，优化器依旧倾向于全表扫（用户统计后来改走了 index skip scan，营业额统计的计划没变），实测差值落在抖动范围内，不算收益。索引只影响执行计划、不改变结果集：对上面 13 条查询用 `IGNORE INDEX` 强制回退全表扫，结果集校验和逐条一致。

索引不是建了就快，得让过滤条件真的用上。订单分页的条件是 `status = ? and order_time between ? and ?`，只给 `order_time` 建单列索引的实测是 24.3ms：优化器按时间范围先捞出 17536 行，再逐行回表判断 `status`，才凑够一页的 10 条。换成 `(status, order_time)` 后两个条件都被下推进索引（执行计划里的 index condition），降到 0.10ms。同一个 5 万数据下，无索引是 33.6ms、单列索引 24.3ms、复合索引 0.10ms，差别就在过滤条件有没有真正用上索引。

订单号和手机号是前后都带通配的 `like '%关键词%'`，走不了 B+ 树，加索引前后都是同一个全表扫计划（10~50ms，取决于当次扫描的快慢，跟索引无关）。这类搜索得换思路（前缀匹配、全文索引或独立搜索引擎），当前保持原样。

复现方式：`mysql -uroot -p -e "source db/migration/V6__index.sql"` 建索引；想看优化前的计划就先 `ALTER TABLE ... DROP INDEX` 掉对应索引，`ANALYZE TABLE` 之后用 `EXPLAIN ANALYZE` 跑同一条 SQL 对比。

---

## 缓存设计

Redis 在里面有两种角色，得分开看：**缓存**的数据在数据库里，Redis 只是加速；**主存**的数据只有 Redis 有。给主存加过期时间等于丢数据。`SHOP_STATUS` 就属于主存这一类，所以它不设过期时间。

| Key | 内容 | 角色 | TTL | 清理时机 |
|---|---|---|---|---|
| `dish_{分类id}` | 该分类下起售中的菜品（含口味） | 缓存 | 30 分钟 ±10% | 菜品新增/编辑/删除/起售停售 |
| `dish_{分类id}`（空结果） | 空列表 | 缓存 | 2 分钟 | 同上 |
| `setmealCache::{分类id}` | 该分类下起售中的套餐 | 缓存 | 30 分钟 ±10% | 套餐新增/编辑/删除/起售停售 |
| `perm:emp:{员工id}` | 员工的权限码 | 缓存 | 30 分钟 | 改角色或改角色权限 |
| `SHOP_STATUS` | 店铺营业状态 | **主存** | 不过期 | 管理端修改；服务启动时发现缺失就补一个「营业中」兜底 |

### 穿透：空结果也缓存，但 TTL 缩到 2 分钟

菜品分类传一个不存在的 id 时，数据库查出来是空列表。空列表照样写进缓存，只是过期时间缩到 2 分钟 —— 同一个不存在的条件不会反复打库，也不会长期占内存。权限查询是同样的做法。

### 击穿：热点 key 重建时加互斥锁

热点 key 失效的那一瞬间，并发请求会一起涌向数据库。`CacheHelper` 用 `setIfAbsent` 抢一个 10 秒的锁，只放一个请求查库并写回缓存，其他请求等 50ms 再读一次缓存；还没读到就自己查库返回、不写缓存。锁在 `finally` 里删掉，持锁线程挂掉也会靠 10 秒 TTL 自动释放。

### 雪崩：TTL 带 ±10% 随机抖动

所有过期时间都过一遍 `CacheHelper.withJitter`，避免一批 key 在同一秒失效。注解式缓存的 `@Cacheable` 走 `CacheConfiguration` 里的 `RedisCacheManager`，那个 TTL 也接的是同一个抖动函数 —— Spring Boot 默认给 Redis 缓存的 TTL 是"永不过期"，这里改掉了。

### 两种写法怎么分工

简单的读缓存用注解，`@Cacheable` 读、`@CacheEvict` 清，现在只有套餐在用；需要互斥重建和空值哨兵的走 `CacheHelper`，也就是菜品。注解方式加不进锁，热点 key 用注解扛不住并发重建，所以菜品那条路单独写。套餐缓存的 value 是 JSON（redis-cli 里能直接看）；早期版本用 JDK 序列化留下的旧值是二进制，读出来会报错，升级后清一次 `setmealCache::*` 就行。

---

## 可观测性

线上排查主要靠两件事：一个请求的日志能串起来，服务的运行状态能被外部采集。

### traceId 贯穿日志

`TraceIdFilter` 挂在过滤器链最前面（`@Order(HIGHEST_PRECEDENCE)`），每个请求先拿一个 traceId：优先用请求头 `X-Trace-Id`（方便前端或网关透传），没有就生成一个 16 位随机串。traceId 放进 MDC，日志格式里配了 `[%X{traceId:-}]`，所以同一个请求打出来的每一行都带同一个 `[xxx]`，排查时直接 grep 这个值就行；同时通过响应头 `X-Trace-Id` 回给调用方，前端报错时能把这个值贴给后端。请求结束后在 `finally` 里清掉 MDC，避免线程复用时串号；传进来的值超过 64 字符会截断，防止脏数据撑爆日志。

用法：

```bash
curl -H "X-Trace-Id: my-trace-0001" http://localhost:8080/actuator/health -i
# 响应头里带回 X-Trace-Id: my-trace-0001
# 日志里同一个请求的每一行都带 [my-trace-0001]
```

### Actuator 与 Prometheus

`sky-server` 引入了 `spring-boot-starter-actuator` 和 `micrometer-registry-prometheus`，开放四个端点（线上这些端点只应该对内网开放，或者加一层认证）：

| 端点 | 作用 |
|---|---|
| `/actuator/health` | 健康检查，`show-details: always`，能看到 db、redis、diskSpace、ping、ssl 各自的状态 |
| `/actuator/info` | 构建信息（版本、构建时间、groupId）和 JDK、操作系统版本，由 `spring-boot-maven-plugin` 的 `build-info` goal 生成 |
| `/actuator/metrics` | 按名字查单个指标，例如 `/actuator/metrics/cache.gets?tag=result:hit` |
| `/actuator/prometheus` | Prometheus 抓取格式，所有 series 都带 `application=sky-take-out` 标签 |

缓存相关有两组指标，来源不一样，别混在一起看：

- `cache_gets_total{cache,result}`、`cache_puts_total{cache}`：Spring 缓存抽象的统计，命中、未命中、写缓存各多少次。**默认是关的**，`CacheConfiguration` 里用 `RedisCacheWriter.nonLockingRedisCacheWriter(factory).withStatisticsCollector(CacheStatisticsCollector.create())` 打开，否则这几个计数永远是 0。
- `sky_cache_requests_total{cache,result}`：手写缓存（菜品那条路）自己的计数，`result` 有 `hit`、`miss`、`load` 三种。

### 缓存故障不影响业务

`TolerantCacheErrorHandler` 实现了 Spring 的 `CacheErrorHandler`，在 `CacheConfiguration` 里通过 `CachingConfigurer#errorHandler` 注册。Redis 里存了脏数据、或者 Redis 短暂不可用，读写缓存只会打一条 warn 日志，然后照常查库返回结果，不会把异常抛给调用方。

### 一个和自定义 Jackson 有关的坑

`/actuator/info` 刚打开时返回的是项目自己的 `{"code":0,"msg":"未知错误"}`，日志里能看到 `InvalidDefinitionException: Java 8 date/time type java.time.Instant not supported`。原因是 `build.time` 的类型是 `Instant`，而项目自定义的 `JacksonObjectMapper` 只注册了 `LocalDateTime`、`LocalDate`、`LocalTime` 三个类型的序列化器，没有注册 JSR-310 模块。

修法是先注册 `JavaTimeModule` 补齐 `Instant` 这些类型，再注册自定义模块 —— 后注册的会覆盖先注册的，所以 `yyyy-MM-dd HH:mm` 这套日期格式不受影响。

---

## 测试

单元测试在 `sky-server/src/test`，跑整个套件：

```bash
mvn test
```

| 测试类 | 用例数 | 覆盖内容 |
|---|---|---|
| `OrderStatusTest` | 6 | 订单状态机：正常流转（待付款→待接单→待派送→派送中→已完成）、派送前可取消、拒绝跳状态和回退、拒绝相同状态与终态、状态码未知或为 null 返回 false、`checkTransfer` 抛业务异常并带上错误提示 |
| `CacheHelperTest` | 3 | TTL 抖动落在 ±10% 区间内、多次抖动不会得到同一个值、极短 TTL（1ms、9ms）抖动后不为负数 |
| `TraceIdFilterTest` | 5 | 无请求头时生成 16 位并写回响应头、透传上游传入的值、超长截断到 64 位、空白值按缺失处理、业务链路抛异常时 MDC 也被清掉 |

`HttpClientTest` 是手动调接口用的，标了 `@Disabled`，不参与构建。

顺带说一个测试真抓出来的 bug：`OrderStatus.canTransfer(1, null)` 原本会抛 `NullPointerException` —— `Set.of(...).contains(null)` 直接抛异常，而不是返回 false。现在方法入口先判空返回 false，非法入参不会再变成 500。

## AI 助手

### 实现方式

基于 **LangChain4j Function Calling**：大模型识别用户意图后，**主动调用后端工具方法操作真实数据库**，再用自然语言组织答案。不是简单的提示词问答，也不会编造数据。

```
用户提问
  → 大模型识别意图
  → 调用 @Tool 方法（读 / 写真实数据库）
  → 模型根据执行结果组织自然语言回答
  → 流式返回前端
```

### 工具清单

每个 `@Tool` 方法都会作为「函数」暴露给大模型，由模型决定何时调用。工具类以 `@Component` 注册为 Spring Bean，通过 `ConsultantService` 的 `tools` 属性按 **bean 名**装配（`AiServiceWiringMode.EXPLICIT`）。

**查询类**

| 工具类 | 方法 | 维度 |
|---|---|---|
| `DishTools` | `queryDish` | 菜品名称、分类名称、售卖状态 |
| `CategoryTools` | `queryCategory` | 分类类型（菜品分类 / 套餐分类） |
| `OrderTools` | `queryOrder` | 订单号、手机号、订单状态、下单时间范围 |

**写操作类**

| 工具类 | 方法 | 作用 | 底层 Service |
|---|---|---|---|
| `DishTools` | `addDish` | 新增菜品 | `saveWithFlavor` |
| `DishTools` | `updateDish` | 修改名称 / 分类 / 价格 / 描述 | `updateWithFlavor` |
| `DishTools` | `deleteDish` | 按名称删除菜品 | `deleteBatch` |
| `DishTools` | `startOrStopDish` | 起售 / 停售，支持按分类批量 | `startOrStop` |

### 写操作的安全机制

让大模型直接操作数据库有风险，项目里做了几层约束：

| 机制 | 说明 | 位置 |
|---|---|---|
| **二次确认** | 提示词强制要求：任何写操作前必须先复述「要做什么」并等用户明确同意，**即使用户指令已经很明确也不许跳过**。删除须单独确认并提示不可恢复 | `resources/system.txt` |
| **删除前置校验** | 依赖 `DishService.deleteBatch` 的既有校验：**起售中的菜品不能删**、**被套餐关联的菜品不能删**。工具捕获异常后把原因转述给用户，并建议先停售 | `DishServiceImpl` |
| **修改重名消歧** | 修改匹配到多道菜时**不猜**，返回候选列表让模型追问用户确认。删除和上下架允许批量（相对容易发现和补救） | `DishTools.updateDish` |
| **口味保留** | `updateWithFlavor` 会先删光口味再插入，因此修改前先读回原口味原样带上，否则改个价格就会把口味全丢掉 | `DishTools.updateDish` |
| **状态变更走专用通道** | 修改工具**不支持**改 `status`。因为 `updateWithFlavor` 直接更新状态不会触发「停售菜品时同步停售关联套餐」的逻辑，会留下「套餐在卖、里面的菜已下架」的脏数据 | `DishTools` / `startOrStopDish` |
| **会话归属校验** | 读写历史、删除会话前校验该会话确实属于当前登录管理员，避免换个 id 读到别人的会话 | `ChatSessionServiceImpl.requireOwned` |

### 会话管理

AI 助手支持多轮对话和历史会话切换，规则如下：

- **每个管理员最多保留 10 条会话**，按 `empId` 隔离（`chat:sessions:{empId}`）
- 超过 10 条时，淘汰**最久没有使用**的那条（而非最早创建的），并连带删除它的消息和标题，不留下垃圾 key
- **标题**取自该会话的第一条用户消息（截前 20 字），后续追问不会覆盖——用 `setIfAbsent` 保证原子性
- **新建会话只生成 id 不登记**：否则连点 10 次「新建会话」会把 10 条真实会话全挤掉，留下的都是空会话。会话在第一条消息发来时才由 `touch()` 登记
- **会话记忆存 Redis，TTL 7 天**，每次对话自动续期，所以活跃会话不会过期
- 读历史时**只返回用户消息和助手回复**。记忆里还存着 `ToolExecutionRequest` / `ToolExecutionResultMessage`（工具调用的中间过程），直接返回会是一堆噪音，已在服务层过滤

### 接口

`ChatController` 提供 5 个接口，均受 `JwtTokenAdminInterceptor` 保护（`/admin/**`），需携带 `token` 请求头：

| 方法 | 路径 | 说明 |
|---|---|---|
| GET | `/admin/chat` | 流式对话，`text/plain` 返回 |
| POST | `/admin/chat/session` | 新建会话，返回后端生成的 `memoryId` |
| GET | `/admin/chat/sessions` | 会话列表，最多 10 条，按最后活跃时间倒序 |
| GET | `/admin/chat/session/{memoryId}/messages` | 读取某会话的历史消息 |
| DELETE | `/admin/chat/session/{memoryId}` | 删除会话（连同消息） |

对话接口：

```http
GET /admin/chat?memoryId={会话ID}&memory={用户问题}
Header: token: {JWT令牌}
```

> `memoryId` 由前端持有并回传。当前员工 id 取自 `BaseContext`，且必须在进入 `Flux` **之前**同步取出——`BaseContext` 是 `ThreadLocal`，而 `Flux` 是在别的线程上异步发射的。

### 行为约束

提示词（`system.txt`）中已约束模型：

- 必须先调用工具查询，**禁止编造**数据
- 查不到就如实说明，不臆造结果
- 信息不足时**主动追问**（如只说"查订单"未给订单号）
- 超出业务范围（闲聊、写代码）礼貌拒绝
- 写操作**必须先复述并征得用户同意**，删除须单独确认
- 写操作失败时转述失败原因并给出下一步建议（例如先停售再删除）
- 不输出 JSON、代码块，把数据整理成自然语言

### 能力边界

以下几件事 AI 助手**做不到**，提示词中已要求它如实告知用户：

| 限制 | 原因 | 替代做法 |
|---|---|---|
| 新增菜品不能设置图片 | 对话中无法上传图片 | 新增后到后台补传图片 |
| 不能修改口味（辣度、忌口等） | 未开放为工具 | 到菜品管理页调整 |
| 不能改售卖状态 | 状态变更只走上下架工具（见上文） | 用「上架 / 下架」的说法告诉它 |
| 新增菜品的**描述字段不会入库** | `DishMapper.xml` 的 `insert` 语句未包含 `description` 列（`update` 语句有）——这是既有问题 | 新增后到后台补填描述 |

### 关键文件

| 文件 | 作用 |
|---|---|
| `aiservice/ConsultantService.java` | AI 服务接口，`@AiService` 声明式装配（模型、记忆、工具） |
| `aiservice/tools/*.java` | `@Tool` 工具方法，对接现有 Service |
| `resources/system.txt` | 系统提示词（角色、规则、确认机制、能力边界） |
| `repository/RedisChatMemoryStore.java` | 会话记忆存 Redis（`ChatMemoryStore` 实现） |
| `service/impl/ChatSessionServiceImpl.java` | 会话清单：登记、列表、淘汰、读历史、删除 |
| `config/CommonConfig.java` | 对话记忆、向量检索等 Bean |
| `controller/admin/ChatController.java` | 对话与会话管理接口 |

### 前端入口

管理端登录后，左侧菜单「**AI 助手**」，聊天页通过 iframe 嵌入 `ai-chat.html`，支持：

- 流式打字效果、多轮对话
- 右上角 **历史会话图标**：鼠标悬停展开下拉列表，点击任意一条即可切回该会话，历史对话自动加载
- 每条会话右侧 `×` 可单独删除；面板支持点击固定展开、Esc 收起
- 「+ 新建会话」按钮：向后端申请新的 `memoryId` 并清空界面

> `ai-chat.html` 与 `employee.html`（员工与权限）都是**独立的手写单文件页面**（非编译产物），位于 Nginx 的 `html/sky/` 目录下，可直接编辑。其余前端页面是打包后的 SPA，无源码。

---

## 接口文档

项目集成 Knife4j，启动后访问：

```
http://localhost:8080/doc.html
```

---

## 常见问题

### 启动报 `Could not resolve placeholder 'QW-API-KEY'`

没配置通义千问 API Key。它是**启动必需项**，不是可选的 AI 功能——LangChain4j 的自动配置在条件评估阶段就要读取 `${QW-API-KEY}`，解析不到会直接中断启动。按 [3. 配置 AI 密钥](#3-配置-ai-密钥) 设置即可。

### 启动报 `ClassNotFoundException: ${sky.datasource.driver-class-name}`

`application-dev.yml` 不存在。它是本地配置文件，不进版本库，需要先按 [2. 配置后端](#2-配置后端) 从模板复制一份。

注意**复制要在打包之前**：`mvn package` 只把打包那一刻存在的资源打进 jar，打完包再补文件，jar 里依旧是缺的。

### 接口返回 `{"code":0,"msg":"未知错误"}`

先看后端日志的堆栈，两种常见情况：

- `NoResourceFoundException: No static resource xxx` —— 请求路径写错了。兜底异常处理器会把这类 404 一并转成统一返回结构，所以看到的不是 HTTP 404。核对路径前缀（管理端 `/admin/**`，用户端 `/user/**`）。
- `Communications link failure`、`Access denied` —— MySQL 没启动，或 `application-dev.yml` 里的库名、账号、密码不对。

### 导入 SQL 报错

脚本内已包含 `CREATE DATABASE sky_take_out`，不需要先手动建库。另外 PowerShell 不支持 `<` 重定向，用 `-e "source ..."` 的写法（见 [1. 准备数据库](#1-准备数据库)）。

---

## 项目来源

本项目基于黑马程序员《苍穹外卖》教学项目进行开发与重构，主要改动包括：

- 从 Spring Boot 2.7 升级至 **Spring Boot 3.5**（Jakarta EE 迁移、Druid/Knife4j 等依赖适配）
- 集成 **LangChain4j + 通义千问**：初期只做数据查询，后续扩展为**查询 + 写操作**（菜品增删改、上下架），并配套实现了**写操作二次确认**等安全约束
- 新增 **AI 会话管理**：会话清单（每管理员最多 10 条）、历史会话切换与删除，会话记忆从内存版迁移到 Redis 并加长 TTL
- 前端品牌与界面调整，AI 助手页重写为独立的 `ai-chat.html`

