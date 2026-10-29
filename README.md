# 智能外卖平台（历史版本归档）

这是「智能外卖平台」的前后端历史归档仓库。项目以管理端业务为主，包含员工、分类、菜品、套餐、订单、统计、角色权限、WebSocket 来单提醒，以及基于 LangChain4j + 通义千问的 AI 助手。

> 本仓库用于保留课程学习和项目演进中的旧版本，不代表当前正式项目。当前校园食堂预约项目「海韵食刻」位于 [haiyun-campus-meal](https://github.com/tlei49377-afk/haiyun-campus-meal)。

## 归档说明

- 分支：`archive/smart-takeout-platform`
- 前端：原 `html/sky` 下的 Vue 2 + Element UI 编译产物，保留原目录结构，不伪装成可维护源码。
- 后端：原 `sky-take-out` 多模块 Maven 工程，归档在 `backend/`。
- 数据库：`backend/db/sky_take_out.sql`。
- 原前端仓库的 `main` 分支和历史保持不变；本归档使用独立分支。
- 为安全起见，归档不会提交 `application-dev.yml`、私钥、证书和本地环境变量。

## 功能概览

管理端包含：

- 员工管理、角色与权限管理
- 菜品分类与套餐分类管理
- 菜品、口味、套餐和图片上传
- 订单查询、接单、拒单、派送、完成与统计
- 营业额、用户、订单和销量排行统计
- 店铺营业状态、来单语音提醒
- 基于通义千问的 AI 助手，可查询业务数据并执行受控的菜品操作

原版本的微信小程序用户端不在本仓库内；本仓库保留的是后台管理端静态页面和对应后端。微信登录、微信支付、阿里云 OSS、百度地图和 AI 能力需要接入真实第三方配置后才能完整使用。

## 技术栈

| 层次 | 技术 |
|---|---|
| 后端 | Java 17、Spring Boot 3.5、MyBatis、PageHelper、Druid |
| 数据库与缓存 | MySQL 8、Redis |
| 鉴权与文档 | JWT、自定义权限注解 + AOP、Knife4j / OpenAPI 3 |
| 实时与报表 | WebSocket、Apache POI |
| AI | LangChain4j、通义千问（DashScope OpenAI 兼容接口） |
| 前端 | Vue 2 + Element UI 编译产物、Nginx |
| 外部服务 | 阿里云 OSS、微信支付、百度地图 |

## 目录结构

```text
sky-take-out-frontend/
├── backend/
│   ├── db/                    数据库建表和初始化脚本
│   ├── sky-common/            公共模块
│   ├── sky-pojo/              Entity、DTO、VO
│   ├── sky-server/            Controller、Service、Mapper、Task、Config
│   ├── pom.xml
│   └── README.md              后端详细说明
├── conf/
│   └── nginx.conf             静态资源托管和接口反向代理
├── html/
│   └── sky/                   管理端编译产物
│       ├── index.html         管理端入口
│       ├── ai-chat.html       AI 助手
│       ├── employee.html      员工与权限
│       └── rbac.html          角色权限
└── README.md
```

## 环境要求

| 组件 | 建议版本 | 用途 |
|---|---|---|
| JDK | 17 或 21 | 后端运行 |
| Maven | 3.8+ | 后端构建 |
| MySQL | 8.0+ | 业务数据 |
| Redis | 6.0+ | 登录会话、缓存和 AI 会话 |
| Nginx | 1.20+ | 前端静态资源与接口代理 |
| 通义千问 API Key | - | AI 助手，启动前必须配置 |

> `application.yml` 中 AI 自动配置会在启动阶段读取 `QW-API-KEY`，缺少时应用可能直接启动失败，即使暂时不使用 AI 页面也需要设置。

## 本地启动

### 1. 克隆归档分支

```powershell
git clone -b archive/smart-takeout-platform https://github.com/tlei49377-afk/sky-take-out-frontend.git
cd sky-take-out-frontend
```

### 2. 初始化数据库

先启动 MySQL，然后执行：

```powershell
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS sky_take_out DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql --default-character-set=utf8mb4 -u root -p sky_take_out -e "source backend/db/sky_take_out.sql"
```

也可以在 MySQL Workbench 中新建 `sky_take_out` 数据库，再导入 `backend/db/sky_take_out.sql`。

### 3. 创建后端本地配置

```powershell
Copy-Item backend/sky-server/src/main/resources/application-dev.yml.example `
  backend/sky-server/src/main/resources/application-dev.yml
```

打开复制后的 `application-dev.yml`，至少修改以下配置：

- MySQL 地址、数据库名、用户名和密码
- Redis 地址、端口、密码和 database
- JWT 管理端与用户端密钥（使用两段不同的随机字符串）
- 需要上传图片时填写阿里云 OSS 配置
- 需要真实微信登录或支付时填写微信配置
- 需要地址距离校验时填写百度地图 AK

这个文件已经被 `.gitignore` 忽略，请勿提交真实值。

Redis 有两套用途：业务缓存使用 `sky.redis.*`，AI 社区版 Redis 配置位于 `backend/sky-server/src/main/resources/application.yml` 的 `langchain4j.community.redis.*`。默认端口不同，请根据本机 Redis 实际监听端口调整。

### 4. 设置 AI Key

PowerShell：

```powershell
${env:QW-API-KEY} = "你的 DashScope API Key"
```

CMD：

```bat
set "QW-API-KEY=你的 DashScope API Key"
```

IDEA：在 `Run/Debug Configurations` 的 `Environment variables` 中添加 `QW-API-KEY=你的 Key`。

### 5. 构建并启动后端

```powershell
cd backend
mvn clean package -DskipTests
java -jar sky-server/target/sky-server-1.0-SNAPSHOT.jar
```

默认地址：

- 后端：`http://localhost:8080`
- 接口文档：`http://localhost:8080/doc.html`
- 健康检查：`http://localhost:8080/actuator/health`

健康检查显示数据库或 Redis 不可用时，先修复对应连接再登录。

### 6. 启动前端

安装 Nginx 后，在本仓库根目录执行：

```powershell
$root = (Get-Location).Path
nginx -p "$root/" -c conf/nginx.conf
```

浏览器访问 `http://localhost`。

初始管理员账号来自数据库脚本：

- 用户名：`admin`
- 密码：`123456`

修改 Nginx 配置后重载：

```powershell
nginx -s reload
```

停止 Nginx：

```powershell
nginx -s stop
```

如果 80 端口被占用，把 `conf/nginx.conf` 中的 `listen 80;` 改成其他端口，例如 `listen 8081;`。

## 接口代理关系

```text
浏览器
  ├── /            -> Nginx 返回 html/sky 静态页面
  ├── /api/*       -> 后端 http://localhost:8080/admin/*
  ├── /user/*      -> 后端 http://localhost:8080/user/*
  └── /ws/*        -> 后端 WebSocket
```

如果后端不在 `localhost:8080`，修改 `conf/nginx.conf` 中 `proxy_pass` 的地址。

## 常见问题

### 后端启动时报 `Could not resolve placeholder 'QW-API-KEY'`

没有设置通义千问 API Key。按“设置 AI Key”步骤配置后重新启动。

### 登录后立即返回登录页 / 提示 401

优先检查 Redis 是否启动、密码和 database 是否正确，以及后端日志中是否有连接异常。

### 页面能打开但接口报 502

检查后端是否运行在 `8080`，以及 Nginx 的 `proxy_pass` 地址是否正确。

### 图片上传失败

检查阿里云 OSS 的 endpoint、AccessKey、Bucket 和跨域配置。没有 OSS 配置时不影响页面打开，但上传功能不可用。

### 微信支付或登录不可用

归档配置只提供占位符。微信登录、支付和回调需要真实 AppID、商户号、API v3 Key、证书及可被微信访问的回调地址，不能仅靠本地示例配置完成。

### 修改代码后页面没有变化

该前端是编译产物，修改 `html/sky` 下的内容后需要重启或重载 Nginx，并强制刷新浏览器缓存。若需要维护前端源码，应回到原前端工程，而不是直接修改压缩后的 JS。

## 安全说明

- 不要把 `application-dev.yml`、`.env`、私钥、证书或真实 API Key 提交到 Git。
- 如果某个密钥曾经出现在公开提交、截图或历史仓库中，应立即在对应平台轮换并作废旧密钥。
- 本归档只用于学习和演示。部署到公网前应更换默认密码、JWT 密钥，并限制 Actuator 和接口文档的访问范围。
- 第三方支付、短信、地图、OSS 和 AI 服务会产生真实费用，请设置配额和告警。

## 与当前项目的关系

本仓库是旧「智能外卖平台」的技术归档。当前「海韵食刻」已经重构为校园食堂预约取餐系统，使用新的前后端代码和业务模型：

- 当前项目：[haiyun-campus-meal](https://github.com/tlei49377-afk/haiyun-campus-meal)
- 本归档：保留旧平台前后端、页面和运行说明，便于回顾技术演进
