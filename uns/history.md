---
name: tier0-uns-history
version: 0.3.0
description: "查询 UNS 数据点的历史数据。triggers: Tier0, UNS, 历史, 查询, 时序数据"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [uns, history, timeseries]
---

# history — 查询历史数据

**CRITICAL — 历史查询涉及时间戳和聚合参数，调用前 MUST 先读完本文档，确认 `start`/`end` 单位和 `function`/`interval` 组合正确，再执行命令。**

## 说明

查询一个或多个 UNS 数据点在指定时间范围内的历史数据。

**时间戳说明**：`start` / `end` 单位为 **Unix 秒**（不是毫秒）。如用户说"最近1小时"，计算方式：`end = now()`，`start = now() - 3600`。

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
| `function` | string | 否 | 聚合函数（avg / max / min / sum / count） |
| `interval` | string | 否 | 聚合间隔（如 `1m`、`1h`、`1d`） |
| `page` | int64 | 否 | 页码 |
| `size` | int64 | 否 | 每页大小 |

## 示例

```bash
# 查询时间段内原始数据
tier0 api /openapi/v1/uns/history --body '{"topics":["factory/line1/sensor/temp"],"start":1715000000,"end":1715600000}'

# 按小时聚合均值
tier0 api /openapi/v1/uns/history --body '{"topics":["factory/line1/sensor/temp"],"start":1715000000,"end":1715600000,"function":"avg","interval":"1h"}'
```

## 典型场景

**获取最近 1 小时内分钟级均值：**
```bash
tier0 api /openapi/v1/uns/history --body-file body.json
# body.json 内容：
# {"topics":["factory/line1/sensor/temp"],"start":1715000000,"end":1715003600,"function":"avg","interval":"1m"}
```

## Windows PowerShell 简写

PowerShell 中双引号处理较复杂，v0.2.6+ 支持简写（自动修复引号）：

```powershell
# 文件法（时间戳参数推荐）
@'
{
  "topics": ["factory/line1/sensor/temp"],
  "start": 1715000000,
  "end": 1715600000,
  "function": "avg",
  "interval": "1h"
}
'@ | Out-File body.json -Encoding utf8
tier0 api /openapi/v1/uns/history --body-file body.json
```
