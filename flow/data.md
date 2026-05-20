---
name: tier0-flow-data
version: 0.3.0
description: "导出 Flow 的 Node-RED 画布 JSON 数据到本地文件。triggers: Tier0, Flow, 导出, 画布, flowsJson, Node-RED"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [flow, data, export, nodered]
---

# data — 导出 Node-RED 画布

获取指定 Flow 当前部署的 Node-RED 画布 JSON（`flowsJson`），通常用于：
- 备份画布
- 复制到其他 Flow
- 版本对比

## 命令

```bash
tier0 flow data --id <id> [--out <file>]
```

| Flag | 说明 |
|------|------|
| `--id` | ✅ Flow ID |
| `--out`, `-o` | 将 JSON 保存到文件（推荐，便于后续 deploy） |
| `--debug` | 打印 HTTP 请求/响应 |

## 示例

```bash
# 导出到文件（推荐）
tier0 flow data --id 1 --out flows.json

# 直接输出到 stdout（方便管道）
tier0 flow data --id 1

# 简写 ID（位置参数）
tier0 flow data 1 --out flows.json
```

## 响应结构

```json
{
  "rev": "abc123",
  "flows": [
    {"id": "tab1", "type": "tab", "label": "Flow 1"},
    {"id": "node1", "type": "inject", "z": "tab1", ...}
  ]
}
```

## 典型工作流

```bash
# 1. 导出当前画布
tier0 flow data --id 1 --out flows.json

# 2. 编辑 flows.json（用编辑器或 Node-RED UI）

# 3. 部署修改后的画布
tier0 flow deploy --id 1 -f flows.json
```

## Windows PowerShell

```powershell
tier0 flow data --id 1 --out flows.json
```
