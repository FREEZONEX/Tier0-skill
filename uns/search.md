---
name: tier0-uns-search
description: "在 UNS 命名空间中搜索节点。triggers: Tier0, UNS, 搜索, 查找"
metadata:
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
| `include_metadata` | boolean | 否 | 是否包含元数据 |
| `page` | int64 | 否 | 页码 |
| `size` | int64 | 否 | 每页大小 |

## 示例

```bash
# 按关键字搜索
tier0 api /openapi/v1/uns/search --body '{"keyword":"temp"}'

# 按路径前缀搜索
tier0 api /openapi/v1/uns/search --body '{"path_prefix":"factory/line1"}'

# 分页搜索
tier0 api /openapi/v1/uns/search --body '{"keyword":"sensor","page":1,"size":20}'
```

## 典型场景

**查找特定类型的所有节点：**
```bash
tier0 api /openapi/v1/uns/search --body '{"path_prefix":"factory","topicType":"thing","size":100}'
```

## Windows PowerShell 简写

PowerShell 中双引号处理较复杂，v0.2.6+ 支持简写（自动修复引号）：


