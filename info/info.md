---
name: tier0-info
version: 0.3.0
description: "获取 Tier0 网关服务信息。triggers: Tier0, 服务信息, 状态, 健康检查"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [info, status, health]
---

# info — 服务信息

## 说明

获取 Tier0 网关服务的运行信息和状态，可用于连通性验证和健康检查。

## API

```
POST /openapi/v1/info
```

## 请求参数

无需参数，传空对象即可。

## 示例

```bash
tier0 api /openapi/v1/info --body '{}'
```

## 典型场景

**验证连接是否正常：**
```bash
# 调试时确认 API Key 和 BaseURL 配置正确
tier0 api /openapi/v1/info --body '{}' --debug
```

## Windows PowerShell 简写

```powershell
tier0 api /openapi/v1/info --body '{}'
```
