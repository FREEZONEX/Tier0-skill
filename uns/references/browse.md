---
name: tier0-uns-browse
version: 0.3.0
description: "浏览 UNS 命名空间树形结构。triggers: Tier0, UNS, 浏览, 命名空间, 树形结构"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [uns, browse, namespace]
---

# browse — 浏览命名空间

## 说明

浏览 UNS（Unified Namespace）命名空间的树形结构，获取指定路径下的节点列表。

## API

```
POST /openapi/v1/uns/browse
```

## 请求参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `path` | string | 否 | 起始路径，默认根路径 `/` |
| `max_depth` | int64 | 否 | 最大递归深度 |
| `include_metadata` | boolean | 否 | 是否包含节点元数据 |

## 示例

```bash
tier0 uns browse --max-depth 2
tier0 uns browse factory/line1 --max-depth 1
```

## 典型场景

**查看命名空间全貌：**
```bash
tier0 uns browse --max-depth 3 --include-metadata
```

**查看指定路径下的节点：**
```bash
tier0 uns browse factory/line1 --max-depth 1
```

## UNS ↔ Flow 关联查询

UNS topic 路径与 Flow 名称**通常同名**。浏览到某个路径后，如果用户想了解数据来源（谁在采集/处理），应同时查询对应的 Flow：

```bash
# 1. browse 发现 topic 路径
tier0 uns browse Plant/Line1 --max-depth 2

# 2. 同名查 Flow（SourceFlow 负责采集，EventFlow 负责处理）
tier0 flow list --keyword Line1
```

> ⚠️ 目前 API 尚无显式关联字段，`topicmeta` 接口后续版本将提供 Flow ↔ topic 映射。

