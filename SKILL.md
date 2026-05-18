---
name: tier0-api
description: "Tier0 Cloud 平台 API 统一入口。涵盖 UNS（Unified Namespace）数据面操作：命名空间浏览、节点读写、历史数据查询、节点增删改。triggers: Tier0, Cloud, UNS, 命名空间, 数据读写, 设备数据"
metadata:
  hermes:
    tags: [api, cloud, uns, namespace, data]
---

# tier0-api — Tier0 Cloud 平台 API 工具

## 概述

Tier0 Cloud 是一个云原生数据平台，提供 UNS（Unified Namespace）统一命名空间能力，支持数据点的读写、历史查询、命名空间管理。

**统一入口**：`tier0` CLI

所有接口均为 POST 方法，请求格式 `{code, msg, data}`，认证方式 `Authorization: Bearer <api-key>`。

## 安装 CLI

```bash
go install github.com/FREEZONEX/Tier0-cli@latest
```

## 认证（Device Flow）

**AI Agent 自动执行，无需用户输入密码：**

```bash
# 1. 获取授权 URL
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

## 常用命令

```bash
# 浏览命名空间
tier0 api /openapi/v1/uns/browse --body '{"path":"/"}'

# 读取数据点
tier0 api /openapi/v1/uns/read --body '{"topics":["factory/line1/sensor/temp"]}'

# 写入数据点
tier0 api /openapi/v1/uns/write --body '{"topic":"factory/line1/sensor/temp","value":25.5}'

# 查询历史数据
tier0 api /openapi/v1/uns/history --body '{"topics":["factory/line1/sensor/temp"],"start":1715000000,"end":1715600000}'
```
