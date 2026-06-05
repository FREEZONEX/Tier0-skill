---
name: tier0-uns-delete
version: 0.3.0
description: "删除 UNS 命名空间中的节点。triggers: Tier0, UNS, 删除, 节点"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [uns, delete, namespace]
---

# delete — 删除节点

**CRITICAL — `hard_delete: true` 为永久删除，不可恢复。执行前 MUST 向用户明确说明区别，等待用户确认后再执行。默认不传或传 `false` 为软删除，可通过 `restore` 恢复。**

## 说明

删除 UNS 命名空间中的指定节点。支持**软删除**（可通过 `restore` 恢复）和**硬删除**（永久删除，不可恢复）。

> **⚠️ 注意**：硬删除不可逆，执行前请确认。建议先软删除，确认无误后再硬删除。

## API

```
POST /openapi/v1/uns/delete
```

## 请求参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `topics` | string[] | 是 | 节点路径列表（CLI: `--path`，可重复） |
| `hard_delete` | boolean | 否 | 是否永久删除，默认 `false`（软删除） |

## 示例

```bash
# 软删除（可恢复）
tier0 uns delete --path factory/line1/sensor/temp --yes

# 永久删除（需 --yes 确认）
tier0 uns delete --path factory/line1/sensor/temp --hard --yes
```

## 典型场景

**安全清理废弃节点：**
```bash
# 1. 先软删除
tier0 uns delete --path factory/line1/old-sensor --yes
# 2. 确认无误后永久删除
tier0 uns delete --path factory/line1/old-sensor --hard --yes
# 如需恢复软删除：
tier0 uns restore --path factory/line1/old-sensor
```
