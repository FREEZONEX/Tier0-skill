---
name: tier0-flow-update
version: 0.3.0
description: "更新 Flow 元数据：重命名、修改描述、收藏/取消收藏。triggers: Tier0, Flow, 更新, 重命名, 收藏"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [flow, update]
---

# update — 更新 Flow 元数据

更新 Flow 的名称、描述、收藏状态。**不涉及 Node-RED 画布内容**（画布更新请用 `flow deploy`）。

## 命令

```bash
tier0 flow update --id <id> [--name <name>] [--desc <desc>] [--favorite | --unfavorite]
```

| Flag | 说明 |
|------|------|
| `--id` | ✅ Flow ID |
| `--name`, `-n` | 新名称 |
| `--desc` | 新描述 |
| `--favorite` | 标记为收藏（`isFavorite=1`） |
| `--unfavorite` | 取消收藏（`isFavorite=0`） |
| `--json` | JSON 输出 |

## 示例

```bash
# 重命名
tier0 flow update --id 1 --name "modbus-line1-v2"

# 更新描述
tier0 flow update --id 1 --desc "车间1 Modbus TCP 采集（已更新）"

# 标记收藏
tier0 flow update --id 1 --favorite

# 取消收藏
tier0 flow update --id 1 --unfavorite

# 同时更新多个字段
tier0 flow update --id 1 --name "new-name" --desc "new description" --favorite
```

## Windows PowerShell

```powershell
tier0 flow update --id 1 --name "modbus-line1-v2"
tier0 flow update --id 1 --favorite
```
