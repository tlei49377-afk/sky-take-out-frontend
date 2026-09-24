# 智能外卖平台 · 前端

「智能外卖平台」的**前端静态资源 + Nginx 配置**，包含管理端后台与 AI 助手页面。

> 这是前端仓库，后端服务在 👉 [sky-take-out](https://github.com/tlei49377-afk/sky-take-out)

---

## 目录

- [项目说明](#项目说明)
- [目录结构](#目录结构)
- [环境要求](#环境要求)
- [快速开始](#快速开始)
- [配置说明](#配置说明)
- [功能页面](#功能页面)
- [常见问题](#常见问题)

---

## 项目说明

本仓库是**编译后的前端产物**（Vue 2 + Element UI），不含前端源码，配合 Nginx 部署使用。

仓库同时提供了配套的 `conf/nginx.conf`，其中已经写好了**静态资源托管**和**接口反向代理**规则，克隆后可直接使用。

### 前后端如何配合

```
浏览器
  │
  ├─ /            → Nginx 返回静态页面（本仓库的 html/sky）
  │
  ├─ /api/xxx     → Nginx 转发到 后端 /admin/xxx   （管理端接口）
  ├─ /user/xxx    → Nginx 转发到 后端 /user/xxx    （用户端接口）
  └─ /ws/xxx      → Nginx 转发到 后端 WebSocket    （来单提醒）
```

> **重要**：Nginx 的 `/api/` 会被转发到后端的 `/admin/`，因此后端管理端接口路径都带 `/admin` 前缀。

---

## 目录结构

```
sky-take-out-frontend
├── README.md
├── conf/
│   └── nginx.conf           Nginx 配置（静态资源 + 接口代理 + WebSocket）
└── html/
    └── sky/                 前端应用
        ├── index.html       入口页面
        ├── ai-chat.html     AI 助手聊天页（手写单文件）
        ├── employee.html    员工与权限页（手写单文件）
        ├── rbac.html        角色权限页（手写单文件，入口已并入员工与权限页）
        ├── favicon.ico
        ├── css/             样式
        ├── js/              JavaScript
        ├── img/             图片资源
        ├── fonts/           图标字体
        └── media/           音频（来单提醒）
```

---

## 环境要求

| 组件 | 版本 | 说明 |
|---|---|---|
| Nginx | 1.20+ | 托管静态资源并反向代理 |
| 后端服务 | — | 需先启动，默认 `localhost:8080` |
| 浏览器 | 现代浏览器 | 推荐 Chrome |

**无需 Node.js / npm** —— 这是编译后的产物，不需要构建。

---

## 快速开始

### 第 1 步：启动后端

先确保后端服务已运行在 `8080` 端口。

```bash
# 在 sky-take-out 后端仓库中
mvn clean package -DskipTests
java -jar sky-server/target/sky-server-1.0-SNAPSHOT.jar
```

看到控制台输出 `server started` 即成功。

> 后端启动前需要配置好 MySQL、Redis 和 AI 密钥（`QW-API-KEY`），详见 [后端仓库说明](https://github.com/tlei49377-afk/sky-take-out)。

### 第 2 步：部署前端到 Nginx

**方式 A：替换 Nginx 自带目录（推荐）**

下载并解压 Nginx，然后把本仓库的文件复制进去：

```bash
# 假设 nginx 解压在 D:\nginx-1.20.2
cp -r conf/nginx.conf   D:/nginx-1.20.2/conf/nginx.conf
cp -r html/*            D:/nginx-1.20.2/html/
```

**方式 B：直接用本仓库目录作为 Nginx 根目录**

把 Nginx 解压到本仓库同级目录，然后修改 `conf/nginx.conf` 中的相对路径即可（`root html/sky` 相对于 Nginx 安装目录）。

### 第 3 步：启动 Nginx

```bash
# Windows
cd D:/nginx-1.20.2
start nginx

# Linux / macOS
nginx -c /path/to/conf/nginx.conf
```

浏览器访问 **http://localhost** 即可看到登录页。

**默认管理员账号**：`admin` / `123456`（取决于后端数据库中的员工数据，其余内置示例账号见后端仓库 README）

---

## 配置说明

### 修改后端地址

如果后端不在本机 `8080`，编辑 `conf/nginx.conf`：

```nginx
location /api/ {
    proxy_pass http://后端IP:端口/admin/;    # 修改这里
}

location /user/ {
    proxy_pass http://后端IP:端口/user/;     # 修改这里
}

location /ws/ {
    proxy_pass http://后端IP:端口/ws/;       # 修改这里
}
```

### 完整配置参考

```nginx
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile      on;
    keepalive_timeout  65;

    # WebSocket 升级支持（来单提醒需要）
    map $http_upgrade $connection_upgrade {
        default upgrade;
        ''      close;
    }

    upstream webservers {
        server 127.0.0.1:8080 weight=90;
    }

    server {
        listen       80;
        server_name  localhost;

        # 静态资源
        location / {
            root   html/sky;
            index  index.html index.htm;
        }

        # 管理端接口：/api/xxx -> 后端 /admin/xxx
        location /api/ {
            proxy_pass   http://localhost:8080/admin/;
        }

        # 用户端接口
        location /user/ {
            proxy_pass   http://webservers/user/;
        }

        # WebSocket 来单提醒
        location /ws/ {
            proxy_pass   http://webservers/ws/;
            proxy_http_version 1.1;
            proxy_read_timeout 3600s;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "$connection_upgrade";
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}
```

---

## 功能页面

### 管理端

| 页面 | 说明 |
|---|---|
| 登录 | 员工账号登录 |
| 工作台 | 今日营业额、订单、用户等概览 |
| 数据统计 | 营业额 / 用户 / 订单统计、销量排名 Top10 |
| 订单管理 | 订单搜索、接单拒单、派送完成 |
| 套餐管理 | 套餐增删改查 |
| 菜品管理 | 菜品增删改查、起售停售 |
| 分类管理 | 菜品分类与套餐分类管理 |
| 员工与权限 | 员工增删改查、启用禁用、登录密码设置、角色分配；角色权限页签可新增自定义角色并勾选权限 |
| **AI 助手** | **自然语言查询菜品、分类、订单** |

### 用户端

菜品浏览、购物车、下单支付、历史订单等。

### 员工与权限

左侧菜单「**员工管理**」，页面分两个页签：

- **员工管理**：新增 / 编辑员工时可设置登录密码（留空则新增用默认 `123456`、编辑表示不改），并可勾选所属角色；支持启用禁用、按姓名或用户名搜索、分页。
- **角色权限**：左侧选角色、右侧勾权限，支持整组全选；「新增角色」可创建自定义角色，创建时就能勾好权限（角色编码、角色名称为必填项）。

保存后，该角色下员工**无需重新登录**，下一次请求即按新权限校验。超级管理员的角色与资料不允许被他人改动，也不能被禁用。

### AI 助手

左侧菜单**最底部**「AI 助手」，进入后可用自然语言提问，例如：

- 「汤类有哪些菜」
- 「查询鸡蛋汤的价格」
- 「查询手机号 13655220337 的订单」
- 「有哪些分类」

AI 会调用后端工具查询**真实数据**后回答，不会编造。支持多轮对话（后端用 Redis 保存会话记忆），点击「新建会话」可清空上下文。

---

## 常见问题

### 页面能打开，但接口全部报错

1. 确认后端已启动：浏览器访问 `http://localhost:8080/doc.html`，能打开接口文档说明后端正常
2. 确认 Nginx 配置中的 `proxy_pass` 地址与端口正确
3. 修改 `nginx.conf` 后需要**重载 Nginx**：
   ```bash
   nginx -s reload
   ```

### 修改了文件但页面没变化

浏览器缓存导致，按 **Ctrl + F5** 强制刷新。

### 菜单里没有「AI 助手」

确认后端已启动且 `application.yml` 中的 AI 配置正确（需要设置 `QW-API-KEY` 环境变量）。

### 登录提示 401 / 一直跳回登录页

后端 Redis 未启动或连接失败。检查后端的 Redis 配置（`application-dev.yml` 中的 `sky.redis.*`）。

### 端口 80 被占用

修改 `conf/nginx.conf` 中的 `listen 80;` 为其他端口，例如 `listen 8081;`，然后访问 `http://localhost:8081`。

---

## 关联项目

| 项目 | 说明 |
|---|---|
| [sky-take-out](https://github.com/tlei49377-afk/sky-take-out) | 后端服务（Spring Boot 3 + LangChain4j） |
