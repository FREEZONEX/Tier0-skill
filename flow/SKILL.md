---
name: tier0-flow
version: 0.3.0
description: "Tier0 Flow（Node-RED）管理：列出、创建、更新、删除 SourceFlow 和 EventFlow，导出和部署 Node-RED 画布 JSON。triggers: Tier0, Flow, Node-RED, SourceFlow, EventFlow, 工作流, 数据采集, 协议, MQTT, 画布, 部署"
metadata:
  requires:
    bins: ["tier0"]
  cliHelp: "tier0 flow help"
  hermes:
    tags: [flow, nodered, sourceflow, eventflow, deploy]
---

# tier0-flow — Node-RED Flow 管理

**CRITICAL — 开始前 MUST 先确认已通过 `tier0 login` 完成授权。**
**CRITICAL — 执行 `deploy` 前 MUST 先用 Read 工具读取 [`flow/deploy.md`](deploy.md)，禁止直接盲目调用命令。deploy 会替换 Flow 的全部 Node-RED 节点配置，操作不可撤销。**
**CRITICAL — 执行 `delete` 前 MUST 先运行 `tier0 flow get --id <id>` 确认目标 Flow 存在，并告知用户删除会停止对应的 Node-RED 容器。**
**CRITICAL — 不清楚 Flow ID 时，MUST 先运行 `tier0 flow list` 获取列表，再执行后续操作。禁止凭空猜测 ID。**

## Flow 类型

每个 Workspace 包含两类 Node-RED 容器：

| 类型 | 说明 | 典型用途 |
|------|------|---------|
| **SourceFlow** | 连接工业协议，采集设备数据，发布到 MQTT / UNS | Modbus、OPC-UA、MQTT 桥接 |
| **EventFlow** | 订阅 MQTT 消息，对业务数据进行二次处理 | 告警规则、数据转换、触发动作 |

## 子技能路由

| 意图 | 加载文件 | 说明 |
|------|---------|------|
| 列出 / 查看 Flow | `flow/list.md` | 列表、类型过滤、查看详情 |
| 创建 Flow | `flow/create.md` | 新建 SourceFlow 或 EventFlow |
| 更新 Flow 元数据 | `flow/update.md` | 重命名、描述、收藏 |
| 删除 Flow | `flow/delete.md` | 单个或批量删除 |
| 导出 Node-RED 画布 | `flow/data.md` | 获取 flowsJson 到本地文件 |
| 部署 Node-RED 画布 | `flow/deploy.md` | 上传并激活 flowsJson |

## 常用操作速查

```bash
# 查看所有 Flow
tier0 flow list

# 只看 SourceFlow / EventFlow
tier0 flow list --source
tier0 flow list --event --json

# 查看 Flow 详情
tier0 flow get --id 1

# 创建 SourceFlow
tier0 flow create --name "modbus-collector" --source --desc "Modbus TCP 采集"

# 创建 EventFlow
tier0 flow create --name "alert-handler" --event --desc "温度告警处理"

# 导出画布 → 修改 → 部署（典型工作流）
tier0 flow data --id 1 --out flows.json
# ... 编辑 flows.json ...
tier0 flow deploy --id 1 -f flows.json
```

## Node-RED 画布工作流

```
tier0 flow list             # 确认 Flow ID
    ↓
tier0 flow data --id <id> --out flows.json   # 导出当前画布
    ↓
# 编辑 flows.json（用 Node-RED 编辑器或手动修改）
    ↓
tier0 flow deploy --id <id> -f flows.json    # 部署新画布
```
