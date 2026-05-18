---
name: tier0-uns-history
description: "查询 UNS 数据点的历史数据。triggers: Tier0, UNS, 历史, 查询, 时序数据"
metadata:
  hermes:
    tags: [uns, history, timeseries]
---

# history — 查询历史数据

## 说明

查询一个或多个 UNS 数据点在指定时间范围内的历史数据。

## API

```
POST /openapi/v1/uns/history
```

## 请求参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `topics` | string[] | 是 | 数据点路径列表 |
| `start` | int64 | 否 | 起始时间戳（Unix 秒） |
| `end` | int64 | 否 | 结束时间戳（Unix 秒） |
| `function` | string | 否 | 聚合函数 |
| `interval` | string | 否 | 聚合间隔 |
| `page` | int64 | 否 | 页码 |
| `size` | int64 | 否 | 每页大小 |

## 示例

```bash
# 查询最近 1 小时的历史数据
tier0 api /openapi/v1/uns/history --body '{"topics":["factory/line1/sensor/temp"],"start":1715000000,"end":1715600000}'

# 按小时聚合
tier0 api /openapi/v1/uns/history --body '{"topics":["factory/line1/sensor/temp"],"start":1715000000,"end":1715600000,"function":"avg","interval":"1h"}'
```
