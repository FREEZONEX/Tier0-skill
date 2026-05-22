---
name: tier0-uns-restore
version: 0.3.0
description: "恢复已软删除的 UNS 节点。triggers: Tier0, UNS, 恢复, 还原"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [uns, restore, namespace]
---

# restore — 恢复节点

## 说明

恢复之前被**软删除**的 UNS 命名空间节点。仅对软删除有效，硬删除不可恢复。

## API

```
POST /openapi/v1/uns/restore
```

## 请求参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `path` | string | 是 | 要恢复的节点路径 |

## 示例

```bash
tier0 uns restore --path factory/line1/sensor/temp
```

## 典型场景

**误删除后立即恢复：**
```bash
tier0 uns restore --path factory/line1/sensor/temp

# 恢复后验证节点存在
tier0 uns browse factory/line1 --depth 1
```
