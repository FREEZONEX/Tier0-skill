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
      "flowId": "e7bdfaabfcae875c",
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

> **⚠️ `id` vs `flowId` 区别**：
> - `id`（整数，如 `1`）：平台数据库 ID，**所有后续操作（get/update/delete/data/deploy）都用这个**
> - `flowId`（字符串，如 `e7bdfaabfcae875c`）：Node-RED 实例内部 ID，**只是响应字段，不能用于查询**
>
> 常见错误：用 `flowId` 调用 `flow/get` → 报错 `field "id" is not set`

**拿到 `id` 后，用它进行后续所有操作：**
```bash
tier0 flow get --id 1        # 用整数 id，不是 flowId 字符串
tier0 flow deploy --id 1 -f flows.json
tier0 flow delete --id 1
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

## Flow ↔ UNS 关联查询

Flow 的 `flowName` 与 UNS topic 路径**通常同名**。拿到 Flow 列表后，如果用户想了解该 Flow 处理的数据，应同时查询对应的 UNS topic：

```bash
# 1. 找到 Flow
tier0 flow list --keyword modbus-collector --json

# 2. 同名查 UNS topic（browse 找路径，再 read 取值）
tier0 api /openapi/v1/uns/browse --body '{"path":"/"}'
# 按 Flow 名称定位到对应路径，如 Plant/Line1/...
tier0 api /openapi/v1/uns/read --body '{"topics":["Plant/Line1/Metric/Temperature"]}'
```

> ⚠️ 目前 API 尚无显式关联字段，`topicmeta` 接口后续版本将提供 Flow ↔ topic 映射，届时可直接获取关联关系。

## Windows PowerShell

```powershell
tier0 flow list --source
tier0 flow get --id 1 --json
```
