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

所有接口均为 POST 方法，请求格式 `{code, msg, data}`，认证方式 `Authorization: Bearer <api-key>`。

## 何时激活

当用户提到以下关键词或意图时激活此 skill：

- **Tier0**、**UNS**、**统一命名空间**、**数据点**
- **读取/写入设备数据**、**传感器数据**、**时序数据**
- **浏览命名空间树**、**查询历史数据**
- **创建/更新/删除节点**、**命名空间管理**
- 使用 `tier0` CLI 命令或 Tier0 API

## 安装 CLI

从 [GitHub Releases](https://github.com/FREEZONEX/Tier0-cli/releases) 下载对应平台的预编译包：

```bash
# Linux x86_64
curl -LO https://github.com/FREEZONEX/Tier0-cli/releases/latest/download/tier0-cli-Linux-x86_64.tar.gz
tar -xzf tier0-cli-Linux-x86_64.tar.gz
sudo mv linux-amd64/tier0 /usr/local/bin/

# macOS Apple Silicon
curl -LO https://github.com/FREEZONEX/Tier0-cli/releases/latest/download/tier0-cli-macOS-arm64.tar.gz
tar -xzf tier0-cli-macOS-arm64.tar.gz
sudo mv darwin-arm64/tier0 /usr/local/bin/
```

Release 包已包含 skills 文档。也可通过 `go install github.com/FREEZONEX/Tier0-cli@latest` 仅安装二进制（不含 skills）。

## 配置（私有化部署必读）

如果使用私有化部署或自定义平台地址，**必须先设置 BaseURL**（写入配置文件，持久生效）：

```bash
# 设置私有化平台地址
tier0 config --base-url https://tier0-eks-frontend.tier0.dev

# 查看当前配置
tier0 config
```

**优先级**：`--base-url` 参数 > 环境变量 `TIER0_BASE_URL` > 配置文件 > 默认地址 `https://tier0.dev`

## 认证（Device Flow）

**AI Agent 自动执行，无需用户输入密码：**

```bash
# 1. 获取授权 URL（自动使用配置文件中的 baseURL）
tier0 login --no-wait

# 2. 在浏览器中打开返回的 verification_url，完成授权

# 3. 使用 setup_code 完成登录
tier0 login --setup-code <code>
```

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

## 常用命令速查

```bash
# 浏览命名空间
tier0 api /openapi/v1/uns/browse --body '{"path":"/"}'

# 读取数据点
tier0 api /openapi/v1/uns/read --body '{"topics":["factory/line1/sensor/temp"]}'

# 写入数据点
tier0 api /openapi/v1/uns/write --body '{"writes":[{"topic":"factory/line1/sensor/temp","value":25.5}]}'

# 查询历史数据
tier0 api /openapi/v1/uns/history --body '{"topics":["factory/line1/sensor/temp"],"start":1715000000,"end":1715600000}'

# 搜索节点
tier0 api /openapi/v1/uns/search --body '{"keyword":"temp"}'
```
