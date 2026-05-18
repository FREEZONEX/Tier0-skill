---
name: tier0-uns-info
description: "获取 UNS 网关服务信息。triggers: Tier0, UNS, 服务信息, 状态"
metadata:
  hermes:
    tags: [uns, info, status]
---

# info — 服务信息

## 说明

获取 UNS 网关服务的运行信息和状态。

## API

```
POST /openapi/v1/info
```

## 请求参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| — | — | — | 无需参数 |

## 示例

```bash
# 查询服务信息
tier0 api /openapi/v1/info --body '{}'
```

## 典型场景

**服务健康检查：**
```bash
# 验证网关服务是否正常运行
tier0 api /openapi/v1/info --body '{}'
```
