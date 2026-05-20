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

## 何时使用本 Skill

### 应该使用

- 用户要列出、查看、创建、更新或删除 Flow
- 用户要查看 Node-RED 画布内容（导出 flowsJson）
- 用户要部署/更新 Node-RED 画布配置
- 用户询问 SourceFlow / EventFlow 的状态或类型

### 不应该使用

- 用户想在 Node-RED 里拖拽节点、实时编辑画布 → 应在浏览器 Node-RED UI 中操作，CLI 只负责导入/导出
- 用户询问 UNS topic 的数据值 → 走 `uns/read.md`（Flow 只是采集管道，数据在 UNS）
- 用户询问设备协议配置（如 Modbus 地址映射）→ 这是 Node-RED 节点内部配置，CLI 无法直接编辑，需导出 flowsJson 后修改

## 不可违反规则

1. **先 list，再操作** — 不知道 ID 时必须先 `tier0 flow list`，禁止猜测 ID
2. **`id` ≠ `flowId`** — 所有命令参数用整数 `id`（如 `1`），`flowId` 是 Node-RED 内部字符串（如 `e7bdfaabfcae875c`），不可用于 CLI 参数
3. **deploy 前必须备份** — 执行 deploy 前必须先 `tier0 flow data --id <id> --out backup.json`，deploy 会覆盖全部节点配置且不可撤销
4. **deploy 和 delete 需要 `--yes`** — 这两个操作是高风险门禁，CLI 不带 `--yes` 时 exit 10，需先向用户确认
5. **delete 告知影响** — 删除 Flow 会停止对应的 Node-RED 容器，必须在用户知情的情况下执行
6. **不要读 deploy.md 就盲目执行** — deploy 参数复杂（整个 flowsJson），没读 `flow/deploy.md` 前禁止构造请求

## Flow 类型

每个 Workspace 包含两类 Node-RED 容器：

| 类型 | 说明 | 典型用途 |
|------|------|---------|
| **SourceFlow** | 连接工业协议，采集设备数据，发布到 MQTT / UNS | Modbus、OPC-UA、MQTT 桥接 |
| **EventFlow** | 订阅 MQTT 消息，对业务数据进行二次处理 | 告警规则、数据转换、触发动作 |

## 子技能路由

| 意图 | 加载文件 | 风险 | 说明 |
|------|---------|------|------|
| 列出 / 查看 Flow | `flow/list.md` | — | 列表、类型过滤、查看详情 |
| 创建 Flow | `flow/create.md` | — | 新建 SourceFlow 或 EventFlow |
| 更新 Flow 元数据 | `flow/update.md` | — | 重命名、描述、收藏 |
| 删除 Flow | `flow/delete.md` | ⚠️ 高风险 需 `--yes` | 停止 Node-RED 容器，不可撤销 |
| 导出 Node-RED 画布 | `flow/data.md` | — | 获取 flowsJson 到本地文件（deploy 前必备） |
| 部署 Node-RED 画布 | **必读** `flow/deploy.md` | ⚠️ 高风险 需 `--yes` | 替换全部节点配置，需先备份 |

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
