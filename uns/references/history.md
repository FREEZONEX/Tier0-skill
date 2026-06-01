---
name: tier0-uns-history
version: 0.4.2
description: "查询 UNS 数据点的历史数据。triggers: Tier0, UNS, 历史, 查询, 时序数据"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [uns, history, timeseries]
---

# history — 查询历史数据

**CRITICAL — 历史查询涉及时间戳和聚合参数，调用前 MUST 先读完本文档，确认时间格式和聚合参数正确，再执行命令。**

## 说明

查询一个或多个 UNS 数据点在指定时间范围内的历史数据。

CLI 支持相对时间表达式（如 `-1h`、`-7d`），会自动转换为 ISO 8601 字符串发给 API。

## API

```
POST /openapi/v1/uns/history
```

Request body:
```json
{
  "topics": ["string"],
  "start_time": "2026-01-01T00:00:00Z",
  "end_time": "2026-01-02T00:00:00Z",
  "page": 1,
  "size": 100,
  "aggregation": {
    "function": "avg",
    "interval": "1h",
    "field": "string"
  }
}
```

## CLI 参数

| 参数 | 说明 |
|------|------|
| `-t, --topics` | 点位名称，可重复（必填） |
| `--start` | 起始时间（必填） |
| `--end` | 结束时间（默认 `now`） |
| `--fn` | 聚合函数：`avg` / `max` / `min` / `sum` / `count` |
| `--interval` | 聚合间隔：`1m` / `1h` / `1d` |
| `--field` | 聚合字段名 |
| `-l, --size` | 每页条数（默认 100） |
| `--page` | 页码（默认 1） |

### 时间格式（`--start` / `--end`）

| 格式 | 示例 | 说明 |
|------|------|------|
| 相对时间 | `-1h`、`-30m`、`-7d`、`-1w` | 当前时间往前推，CLI 转为 ISO 8601 |
| ISO 8601 | `2026-01-01T00:00:00Z` | 直接传给 API |
| 关键字   | `now` | 当前时间 |

## 响应结构

history 是批量接口，即使有 topic 失败 HTTP 仍为 200，**必须检查 `data.success` 和 `data.results[i].success`**：

```json
{
  "code": 200,
  "msg": "success",
  "data": {
    "success": true,
    "results": [
      {
        "success": true,
        "topic": "Plant/Line1/Metric/Temperature",
        "result": {
          "total": 2,
          "page": 1,
          "size": 100,
          "records": [
            { "value": { "temperature": 27.5, "unit": "C" }, "quality": "Good", "timeStamp": 1733382000000 },
            { "value": { "temperature": 28.1, "unit": "C" }, "quality": "Good", "timeStamp": 1733385600000 }
          ]
        }
      }
    ]
  }
}
```

部分 topic 失败时（如 topic 不存在），`data.success` 为 `false`，失败项 `results[i].success` 为 `false`：

```json
{
  "success": false,
  "topic": "__not_exist__/Metric/Temp",
  "error": { "code": 404, "message": "topic not found" }
}
```

## 示例

```bash
# 查询最近 1 小时原始数据
tier0 uns history -t factory/line1/sensor/temp --start -1h

# 查询最近 24 小时，按小时聚合均值
tier0 uns history -t factory/line1/sensor/temp --start -24h --fn avg --interval 1h

# 查询指定时间段
tier0 uns history -t factory/line1/sensor/temp \
  --start 2026-01-01T00:00:00Z --end 2026-01-02T00:00:00Z

# 多个 topic，最近 7 天按天聚合最大值
tier0 uns history -t Plant/Line1/Metric/Temperature -t Plant/Line1/Metric/Humidity \
  --start -7d --fn max --interval 1d
```
