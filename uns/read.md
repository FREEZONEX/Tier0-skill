---
name: tier0-uns-read
version: 0.3.0
description: "读取 UNS 数据点的当前值。triggers: Tier0, UNS, 读取, 数据点, 实时值"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [uns, read, data]
---

# read — 读取数据点

## 说明

读取一个或多个 UNS 数据点的当前值。

## API

```
POST /openapi/v1/uns/read
```

## 请求参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `topics` | string[] | 是 | 数据点路径列表 |
| `include_metadata` | boolean | 否 | 是否包含元数据 |
| `max_depth` | int64 | 否 | 最大递归深度 |

## 示例

```bash
# 读取单个数据点
tier0 api /openapi/v1/uns/read --body '{"topics":["factory/line1/sensor/temp"]}'

# 读取多个数据点
tier0 api /openapi/v1/uns/read --body '{"topics":["factory/line1/sensor/temp","factory/line1/sensor/humidity"]}'
```

## Windows PowerShell 简写

PowerShell 中双引号处理较复杂，v0.2.6+ 支持简写（自动修复引号）：

```powershell
# 简写 — 单个数据点
tier0 api /openapi/v1/uns/read --body '{topics:[factory/line1/sensor/temp]}'

# 简写 — 多个数据点
tier0 api /openapi/v1/uns/read --body '{topics:[factory/line1/sensor/temp,factory/line1/sensor/humidity]}'

# 文件法
'{"topics":["factory/line1/sensor/temp"],"include_metadata":true}' | Out-File body.json -Encoding utf8
tier0 api /openapi/v1/uns/read --body-file body.json
```

