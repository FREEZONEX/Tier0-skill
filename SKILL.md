---
name: tier0-api
description: "Tier0 Cloud 平台 API 统一入口。涵盖 UNS（Unified Namespace）数据面操作：命名空间浏览、节点读写、历史数据查询、节点增删改。triggers: Tier0, Cloud, UNS, 命名空间, 数据读写, 设备数据"
metadata:
  openclaw:
    emoji: "☁️"
  hermes:
    tags: [api, cloud, uns, namespace, data]
---

# tier0-api — Tier0 Cloud 平台 API 工具

## 概述

Tier0 Cloud 是一个云原生数据平台，提供 UNS（Unified Namespace）统一命名空间能力，支持数据点的读写、历史查询、命名空间管理。

**统一入口**：`tier0` CLI

**⚠️ 前置条件：必须先安装 `tier0` CLI 并完成登录授权，否则无法调用任何 API。**

所有接口均为 POST 方法，请求格式 `{code, msg, data}`，认证方式 `x-api-key: <api-key>`（同时兼容 `Authorization: Bearer <api-key>` 和 `Authorization: ApiKey <key>`）。

## 何时激活

当用户提到以下关键词或意图时激活此 skill：

- **Tier0**、**UNS**、**统一命名空间**、**数据点**
- **读取/写入设备数据**、**传感器数据**、**时序数据**
- **浏览命名空间树**、**查询历史数据**
- **创建/更新/删除节点**、**命名空间管理**
- 使用 `tier0` CLI 命令或 Tier0 API

## 安装与初始化

**以下步骤必须按顺序完成。没有 CLI 或未登录时，所有 API 调用都会失败。**

> **版本要求**：`v0.2.6+` 推荐（支持 `--body-file`、`--debug` 和 JSON 自动修复）。如果已安装旧版本，请先执行 `tier0 upgrade`。

### 步骤 1：安装 CLI（必须）

**macOS / Linux：**
```bash
curl -sL https://raw.githubusercontent.com/FREEZONEX/Tier0-cli/main/install.sh | bash
```

**Windows (PowerShell)：**
```powershell
Invoke-RestMethod -Uri https://raw.githubusercontent.com/FREEZONEX/Tier0-cli/main/install.ps1 | Invoke-Expression
```

### 步骤 2：选择部署环境

**A. SaaS 环境（默认 `https://tier0.dev`）**

无需配置地址，直接跳到步骤 3 登录。

**B. 私有化部署**

必须在登录**之前**配置平台地址：

```bash
tier0 config --base-url https://your-tier0-instance.com
```

**⚠️ 关键约束**：如果先执行 `tier0 login` 再 `config --base-url`，授权 URL 会指向错误地址。私有化部署必须先 `config` 再 `login`。

### 步骤 3：登录授权

```bash
# AI 友好模式（输出 URL 后退出，不阻塞）
tier0 login --no-wait
# → 向用户展示 verification_url，用户浏览器授权后：
tier0 login --setup-code <code>
```

**配置优先级**：`--base-url` 参数 > 环境变量 `TIER0_BASE_URL` > 配置文件 > 默认地址 `https://tier0.dev`

## 核心概念

| 概念 | 说明 |
|------|------|
| Namespace | 统一命名空间，树形结构组织数据点 |
| Topic | 数据点路径，如 `factory/line1/sensor/temp` |
| Node | 命名空间中的节点，可以是文件夹或数据点 |
| Tag | 节点的元数据标签 |

## 子技能路由

此 skill 包含多个子文档，按用户意图加载对应文件：

| 意图 | 加载文件 | 说明 |
|------|---------|------|
| 浏览命名空间树 | `uns/browse.md` | 获取节点列表、层级结构 |
| 读取数据点当前值 | `uns/read.md` | 实时值查询 |
| 写入数据点 | `uns/write.md` | 发布数据 |
| 查询历史/时序数据 | `uns/history.md` | 历史记录、聚合查询 |
| 搜索节点 | `uns/search.md` | 按关键字/前缀搜索 |
| 创建节点 | `uns/create.md` | 新建文件夹或数据点 |
| 更新节点 | `uns/update.md` | 修改元数据或字段 |
| 删除节点 | `uns/delete.md` | 软删除或硬删除 |
| 恢复已删除节点 | `uns/restore.md` | 撤销软删除 |
| 服务信息/健康检查 | `uns/info.md` | 网关状态 |

## Windows PowerShell 调用注意

PowerShell 处理 JSON 字符串中的双引号时容易出错（如 `'{"path":"/"}'` 可能被解析异常）。**推荐以下三种方式**：

**方式一：单引号简写（v0.2.6+ 自动修复）**
```powershell
tier0 api /openapi/v1/uns/browse --body '{path:/}'
# CLI 会自动修复为 {"path":"/"} 再发送
```

**方式二：文件法（最稳妥）**
```powershell
'{"path":"/"}' | Out-File body.json -Encoding utf8
tier0 api /openapi/v1/uns/browse --body-file body.json
```

**方式三：调试模式**
```powershell
tier0 api /openapi/v1/uns/browse --body '{path:/}' --debug
# 可查看实际发出的 HTTP 请求和响应
```

## 常用命令速查

```bash
# 浏览命名空间
tier0 api /openapi/v1/uns/browse --body '{"path":"/"}'
# PowerShell 简写: --body '{path:/}'

# 读取数据点
tier0 api /openapi/v1/uns/read --body '{"topics":["factory/line1/sensor/temp"]}'
# PowerShell 简写: --body '{topics:[factory/line1/sensor/temp]}'

# 写入数据点
tier0 api /openapi/v1/uns/write --body '{"writes":[{"topic":"factory/line1/sensor/temp","value":25.5}]}'
# PowerShell 简写: --body '{writes:[{topic:factory/line1/sensor/temp,value:25.5}]}'

# 查询历史数据
tier0 api /openapi/v1/uns/history --body '{"topics":["factory/line1/sensor/temp"],"start":1715000000,"end":1715600000}'

# 搜索节点
tier0 api /openapi/v1/uns/search --body '{"keyword":"temp"}'
# PowerShell 简写: --body '{keyword:temp}'
```
