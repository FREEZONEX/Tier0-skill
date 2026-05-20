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

**CRITICAL — 删除 Flow 会立即停止并销毁对应的 Node-RED 容器，操作不可恢复。执行前 MUST：**
1. **运行 `tier0 flow get --id <id>` 确认目标 Flow 的名称和类型**
2. **向用户明确告知"此操作将停止 Node-RED 容器并删除所有配置"，等待用户确认**

> **⚠️ 注意**：删除 Flow 会同时停止对应的 Node-RED 容器，操作不可恢复，请确认后执行。

## 命令

```bash
tier0 flow delete --id <id> [--id <id2> ...] --yes [--json]
# 或逗号分隔
tier0 flow delete 1,2,3 --yes
```

| Flag | 说明 |
|------|------|
| `--id` | Flow ID（可重复指定多个） |
| `--yes`, `-y` | ✅ **必填** — 确认高风险操作门禁（不带此参数 CLI 退出码 10） |
| `--json` | JSON 输出 |

> **exit 10 门禁**：不带 `--yes` 时 CLI 退出码为 10，stderr 输出 `{"type":"confirmation_required",...}`。
> Agent 必须将 Flow ID 列表和"将停止 Node-RED 容器"的警告展示给用户，等用户同意后追加 `--yes` 重试。

## 示例

```bash
# 删除单个 Flow（需 --yes）
tier0 flow delete --id 1 --yes

# 删除多个（重复 --id）
tier0 flow delete --id 1 --id 2 --id 3 --yes

# 删除多个（逗号分隔位置参数）
tier0 flow delete 1,2,3 --yes

# JSON 输出
tier0 flow delete --id 1 --yes --json
```

## 典型场景

**删除前先确认 Flow 信息：**
```bash
# 1. 先查看要删除的 Flow
tier0 flow get --id 5

# 2. 向用户展示 Flow 名称/类型，确认同意后执行删除
tier0 flow delete --id 5 --yes
```

## Windows PowerShell

```powershell
tier0 flow delete --id 1 --yes
tier0 flow delete 1,2,3 --yes
```
