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

**CRITICAL — 部署会完全替换 Flow 的所有 Node-RED 节点配置，Node-RED 实例会立即重新加载，操作不可撤销。执行前必须确认：**
1. **已通过 `tier0 flow data --id <id> --out backup.json` 备份当前画布**
2. **已确认目标 Flow ID 正确（用 `tier0 flow get --id <id>` 核实）**
3. **flows JSON 文件格式有效**
4. **已保留后端创建 Flow 时初始化的 Tier0 `mqtt-broker` config 节点**（不要新建/替换 Tier0 broker 节点）

> **⚠️ 注意**：部署会替换 Flow 当前所有节点配置，Node-RED 实例会重新加载。请确保 JSON 格式正确。

## 命令

```bash
tier0 flow deploy --id <id> -f <file> --yes
# 或内联 JSON（不推荐，过长时 shell 会出错）
tier0 flow deploy --id <id> --flows-json '<json>' --yes
```

| Flag | 说明 |
|------|------|
| `--id` | ✅ Flow ID |
| `--flows-file`, `-f` | ✅ Node-RED 画布 JSON 文件路径（推荐） |
| `--flows-json` | Node-RED 画布 JSON 字符串（简单场景） |
| `--yes`, `-y` | ✅ **必填** — 确认高风险操作门禁（不带此参数 CLI 退出码 10） |
| `--json` | JSON 输出（含部署后的 Node-RED FlowId） |
| `--debug` | 打印 HTTP 请求/响应 |

> **exit 10 门禁**：不带 `--yes` 时 CLI 退出码为 10，stderr 输出 `{"type":"confirmation_required",...}`。
> Agent 必须将 `error.message`（含备份建议）展示给用户，等用户同意后追加 `--yes` 重试。

## MQTT broker config 保留规则

如果画布里需要通过 mqtt out 写入 Tier0 UNS，必须复用后端创建 Flow 时初始化的 `mqtt-broker` config 节点。部署前从 `tier0 flow data --id <id> --out backup.json` 中找到该节点，并在新画布中保留同一个 `id`、`broker`、`clientid`。Node-RED 的密码存储在内部加密凭据库里，导出的 flowsJson 通常不会包含明文 password；不要手写 `credentials.user/password` 试图恢复凭据。

如果删除或替换该 broker config，mqtt out 会出现匿名连接、鉴权失败或 `Encrypted credentials not found`。正确处理方式是基于导出的画布修改，或重新通过 `tier0 flow create` 创建一个带系统 MQTT config 的 Flow。

部署返回的 Node-RED `flowId` 可能与输入 JSON 里的 tab id 不一致，这是 Node-RED 重新映射后的内部 ID，正常情况下无需处理。

## 示例

```bash
# 从文件部署（需 --yes）
tier0 flow deploy --id 1 -f flows.json --yes

# JSON 输出（确认部署结果）
tier0 flow deploy --id 1 -f flows.json --yes --json
# → {"flowId": "abc123"}
```

## 典型场景

**备份 → 修改 → 部署（完整工作流）：**
```bash
# 1. 导出备份（必须执行）
tier0 flow data --id 1 --out flows_backup.json

# 2. 基于备份创建新版本并修改
cp flows_backup.json flows_v2.json
# ... 编辑 flows_v2.json（在 Node-RED UI 中修改后重新导出） ...

# 3. 部署（用户确认后加 --yes）
tier0 flow deploy --id 1 -f flows_v2.json --yes
```

**批量部署同一画布到多个 Flow：**
```bash
for id in 1 2 3; do
  tier0 flow deploy --id $id -f shared-template.json --yes
done
```

## Windows PowerShell

```powershell
# 文件法（唯一推荐方式）
tier0 flow deploy --id 1 -f flows.json --yes

# 批量部署
foreach ($id in 1, 2, 3) {
    tier0 flow deploy --id $id -f shared-template.json --yes
}
```
