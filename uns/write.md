---
name: tier0-uns-write
description: "向 UNS 数据点写入数据。triggers: Tier0, UNS, 写入, 数据点, 发布"
metadata:
  hermes:
    tags: [uns, write, data]
---

# write — 写入数据点

## 说明

向一个或多个 UNS 数据点写入数据值。

## API

```
POST /openapi/v1/uns/write
```

## 请求参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `writes` | WriteItem[] | 是 | 写入项列表 |
| `qos` | int64 | 否 | QoS 等级 |
| `retain` | boolean | 否 | 是否保留消息 |

### WriteItem

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `topic` | string | 是 | 数据点路径 |
| `value` | any | 是 | 写入值 |
| `timestamp` | int64 | 否 | 时间戳 |

## 示例

```bash
# 写入单个数据点
tier0 api /openapi/v1/uns/write --body '{"writes":[{"topic":"factory/line1/sensor/temp","value":25.5}]}'

# 批量写入
tier0 api /openapi/v1/uns/write --body '{"writes":[{"topic":"factory/line1/sensor/temp","value":25.5},{"topic":"factory/line1/sensor/humidity","value":60}]}'
```

## Windows PowerShell 简写

PowerShell 中双引号处理较复杂，v0.2.6+ 支持简写（自动修复引号）：


