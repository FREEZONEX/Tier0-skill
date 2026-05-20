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
tier0 api /openapi/v1/uns/browse --body '{"path":"/","max_depth":2}'
```

## 典型场景

**查看命名空间全貌：**
```bash
tier0 api /openapi/v1/uns/browse --body '{"path":"/","max_depth":3,"include_metadata":true}'
```

**查看指定路径下的节点：**
```bash
tier0 api /openapi/v1/uns/browse --body '{"path":"factory/line1","max_depth":1}'
```

## Windows PowerShell 简写

PowerShell 中双引号处理较复杂，v0.2.6+ 支持简写（自动修复引号）：

```powershell
# 简写 — 根路径浏览
tier0 api /openapi/v1/uns/browse --body '{path:/}'

# 简写 — 指定路径
tier0 api /openapi/v1/uns/browse --body '{path:factory/line1,max_depth:2}'

# 文件法（复杂参数推荐）
'{"path":"/","max_depth":3,"include_metadata":true}' | Out-File body.json -Encoding utf8
tier0 api /openapi/v1/uns/browse --body-file body.json
```

