---
name: tier0-uns-restore
description: "恢复已软删除的 UNS 节点。triggers: Tier0, UNS, 恢复, 还原"
metadata:
  hermes:
    tags: [uns, restore, namespace]
---

# restore — 恢复节点

## 说明

恢复之前被软删除的 UNS 命名空间节点。

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
# 恢复软删除的节点
tier0 api /openapi/v1/uns/restore --body '{"path":"factory/line1/sensor/temp"}'
```

## 典型场景

**误删除恢复：**
```bash
# 如果节点被误删除（软删除），可以立即恢复
tier0 api /openapi/v1/uns/restore --body '{"path":"factory/line1/sensor/temp"}'
```
