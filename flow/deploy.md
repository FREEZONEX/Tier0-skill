---
name: tier0-flow-deploy
version: 0.3.0
description: "将 Node-RED 画布 JSON 部署到指定 Flow。triggers: Tier0, Flow, 部署, 发布, 上传, flowsJson, Node-RED"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [flow, deploy, nodered]
---

# deploy — 部署 Node-RED 画布

将本地的 Node-RED 画布 JSON（`flowsJson`）上传并部署到指定 Flow 的 Node-RED 实例。

> **⚠️ 注意**：部署会替换 Flow 当前所有节点配置，Node-RED 实例会重新加载。请确保 JSON 格式正确。

## 命令

```bash
tier0 flow deploy --id <id> -f <file>
# 或内联 JSON（不推荐，过长时 shell 会出错）
tier0 flow deploy --id <id> --flows-json '<json>'
```

| Flag | 说明 |
|------|------|
| `--id` | ✅ Flow ID |
| `--flows-file`, `-f` | ✅ Node-RED 画布 JSON 文件路径（推荐） |
| `--flows-json` | Node-RED 画布 JSON 字符串（简单场景） |
| `--json` | JSON 输出（含部署后的 Node-RED FlowId） |
| `--debug` | 打印 HTTP 请求/响应 |

## 示例

```bash
# 从文件部署（推荐）
tier0 flow deploy --id 1 -f flows.json

# JSON 输出（确认部署结果）
tier0 flow deploy --id 1 -f flows.json --json
# → {"flowId": "abc123"}

# 简写 ID
tier0 flow deploy 1 -f flows.json
```

## 典型场景

**备份 → 修改 → 部署：**
```bash
# 1. 导出备份
tier0 flow data --id 1 --out flows_backup.json

# 2. 基于备份创建新版本并修改
cp flows_backup.json flows_v2.json
# ... 编辑 flows_v2.json ...

# 3. 部署
tier0 flow deploy --id 1 -f flows_v2.json
```

**批量部署同一画布到多个 Flow：**
```bash
for id in 1 2 3; do
  tier0 flow deploy --id $id -f shared-template.json
done
```

## Windows PowerShell

```powershell
# 文件法（唯一推荐方式）
tier0 flow deploy --id 1 -f flows.json

# 批量部署
foreach ($id in 1, 2, 3) {
    tier0 flow deploy --id $id -f shared-template.json
}
```
