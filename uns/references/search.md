---
name: tier0-uns-search
version: 0.3.0
description: "在 UNS 命名空间中搜索节点。triggers: Tier0, UNS, 搜索, 查找"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [uns, search, namespace]
---

# search — 搜索命名空间

## 说明

在 UNS 命名空间中按关键字、路径前缀或节点类型搜索节点。

## API

```
POST /openapi/v1/uns/search
```

## 请求参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `keyword` | string | 否 | 搜索关键字 |
| `path_prefix` | string | 否 | 路径前缀过滤 |
| `topicType` | string | 否 | 节点类型过滤 |
| `include_metadata` | boolean | 否 | 是否返回每个节点的字段定义（fields）、topicType、description。**搜索后需要了解 topic 结构时带上** |
| `page` | int64 | 否 | 页码 |
| `size` | int64 | 否 | 每页大小 |

## 示例

```bash
# 按关键字搜索
tier0 uns search --keyword temp

# 按路径前缀搜索
tier0 uns search --path-prefix factory/line1

# 分页搜索
tier0 uns search --keyword sensor --page 1 --size 20
```

## 典型场景

**查找特定类型的所有节点：**
```bash
tier0 uns search --path-prefix factory --topic-type metric --size 100
```

**搜索后查看 topic 字段定义（推荐两步工作流）：**

第一步：先搜索定位 topic 路径
```bash
tier0 uns search --keyword Temperature --topic-type metric
```

第二步：加 `--include-metadata` 查看字段结构，了解有哪些字段、类型、单位
```bash
tier0 uns search --keyword Temperature --topic-type metric --include-metadata
```

返回中每个节点会带上字段信息：
```json
{
  "path": "Plant/Line1/Metric/Temperature",
  "topicType": "METRIC",
  "fields": [
    { "name": "temperature", "type": "float", "unit": "°C" },
    { "name": "unit",        "type": "string" },
    { "name": "humidity",    "type": "float",  "unit": "%" }
  ],
  "description": "Line 1 temperature sensor"
}
```

拿到 `fields` 后即可构造正确的写入请求，或对 `value` 进行字段级解析。

## Windows PowerShell

```powershell
tier0 uns search --keyword temp
tier0 uns search --path-prefix factory/line1
```
