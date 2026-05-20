---
name: tier0-flow-create
version: 0.3.0
description: "创建新的 Flow（SourceFlow 或 EventFlow）。triggers: Tier0, Flow, 创建, 新建, SourceFlow, EventFlow, Node-RED"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [flow, create]
---

# create — 创建 Flow

## API

```
POST /openapi/v1/flow/create
```

## 命令

```bash
tier0 flow create --name <name> --source|--event [--desc <desc>] [--template <json>] [--template-file <file>]
```

| Flag | 必填 | 说明 |
|------|------|------|
| `--name`, `-n` | ✅ | Flow 名称 |
| `--source` | ✅（二选一）| 类型设为 SourceFlow |
| `--event` | ✅（二选一）| 类型设为 EventFlow |
| `--type`, `-t` | ✅（二选一）| 直接指定类型字符串 |
| `--desc` | — | 描述 |
| `--template` | — | 初始 Node-RED 模板 JSON 字符串 |
| `--template-file` | — | 从文件读取初始模板（推荐） |
| `--json` | — | JSON 输出（含新建的 ID） |

## 示例

```bash
# 创建 SourceFlow（连接协议采集数据）
tier0 flow create --name "modbus-line1" --source --desc "车间1 Modbus TCP 采集"

# 创建 EventFlow（处理业务数据）
tier0 flow create --name "temp-alert" --event --desc "温度超限告警处理"

# 创建时指定初始模板
tier0 flow create --name "modbus-line1" --source --template-file modbus-template.json

# JSON 输出（获取新建的 ID）
tier0 flow create --name "my-flow" --source --json
# → {"id": 5}
```

## 典型场景

**从已有 Flow 克隆（导出 → 创建 → 部署）：**
```bash
# 1. 导出参考 Flow 的画布
tier0 flow data --id 1 --out template.json

# 2. 创建新 Flow
tier0 flow create --name "modbus-line2" --source --json
# → {"id": 6}

# 3. 将模板画布部署到新 Flow
tier0 flow deploy --id 6 -f template.json
```

## Windows PowerShell

```powershell
tier0 flow create --name "modbus-line1" --source --desc "Modbus 采集"
tier0 flow create --name "my-flow" --source --template-file template.json --json
```
