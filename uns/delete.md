---
name: tier0-uns-delete
description: "删除 UNS 命名空间中的节点。triggers: Tier0, UNS, 删除, 节点"
metadata:
  hermes:
    tags: [uns, delete, namespace]
---

# delete — 删除节点

## 说明

删除 UNS 命名空间中的指定节点。支持软删除（可恢复）和硬删除（永久删除）。

## API

```
POST /openapi/v1/uns/delete
```

## 请求参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `path` | string | 是 | 节点路径 |
| `hard_delete` | boolean | 否 | 是否永久删除，默认 false（软删除） |

## 示例

```bash
# 软删除节点（可恢复）
tier0 api /openapi/v1/uns/delete --body '{"path":"factory/line1/sensor/temp"}'

# 永久删除节点
tier0 api /openapi/v1/uns/delete --body '{"path":"factory/line1/sensor/temp","hard_delete":true}'
```

## 典型场景

**清理废弃节点：**
```bash
# 先软删除，确认无误后再永久删除
tier0 api /openapi/v1/uns/delete --body '{"path":"factory/line1/old-sensor"}'
tier0 api /openapi/v1/uns/delete --body '{"path":"factory/line1/old-sensor","hard_delete":true}'
```
