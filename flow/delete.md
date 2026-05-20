---
name: tier0-flow-delete
version: 0.3.0
description: "删除一个或多个 Flow。triggers: Tier0, Flow, 删除, 移除"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [flow, delete]
---

# delete — 删除 Flow

> **⚠️ 注意**：删除 Flow 会同时停止对应的 Node-RED 容器，操作不可恢复，请确认后执行。

## 命令

```bash
tier0 flow delete --id <id> [--id <id2> ...] [--json]
# 或逗号分隔
tier0 flow delete 1,2,3
```

| Flag | 说明 |
|------|------|
| `--id` | Flow ID（可重复指定多个） |
| `--json` | JSON 输出 |

## 示例

```bash
# 删除单个 Flow
tier0 flow delete --id 1

# 删除多个（重复 --id）
tier0 flow delete --id 1 --id 2 --id 3

# 删除多个（逗号分隔位置参数）
tier0 flow delete 1,2,3

# JSON 输出
tier0 flow delete --id 1 --json
```

## 典型场景

**删除前先确认 Flow 信息：**
```bash
# 1. 先查看要删除的 Flow
tier0 flow get --id 5

# 2. 确认无误后删除
tier0 flow delete --id 5
```

## Windows PowerShell

```powershell
tier0 flow delete --id 1
tier0 flow delete 1,2,3
```
