---
name: tier0-flow-list
version: 0.3.0
description: "列出 Workspace 中的 Flow，支持按类型过滤；查看单个 Flow 详情。triggers: Tier0, Flow, 列出, 查看, SourceFlow, EventFlow"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [flow, list, get]
---

# list / get — 列出与查看 Flow

## 列出 Flow

```bash
tier0 flow list [--source | --event] [--keyword <kw>] [--json]
```

| Flag | 说明 |
|------|------|
| `--source` | 只列出 SourceFlow |
| `--event` | 只列出 EventFlow |
| `--keyword`, `-k` | 按名称关键词过滤 |
| `--type`, `-t` | 指定类型字符串（SourceFlow / EventFlow） |
| `--json` | JSON 格式输出（AI 推荐，便于解析） |
| `--debug` | 打印 HTTP 请求/响应 |

### 示例

```bash
# 列出所有 Flow（表格）
tier0 flow list

# 只看 SourceFlow
tier0 flow list --source

# 只看 EventFlow，JSON 输出
tier0 flow list --event --json

# 按名称关键词过滤
tier0 flow list --keyword modbus
```

### 响应字段（JSON）

```json
{
  "list": [
    {
      "id": 1,
      "flowId": "abc123",
      "flowName": "modbus-collector",
      "flowType": "SourceFlow",
      "flowStatus": "running",
      "description": "Modbus 采集",
      "isFavorite": 0,
      "currentVersionName": "v1",
      "currentVersionType": "deployed"
    }
  ]
}
```

---

## 查看 Flow 详情

```bash
tier0 flow get --id <id> [--json]
```

### 示例

```bash
# 查看 ID 为 1 的 Flow
tier0 flow get --id 1

# JSON 输出
tier0 flow get --id 1 --json

# 也可以直接传 ID 作为位置参数
tier0 flow get 1
```

## Windows PowerShell

```powershell
tier0 flow list --source
tier0 flow get --id 1 --json
```
