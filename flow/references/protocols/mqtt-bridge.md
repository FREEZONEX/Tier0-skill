---
name: tier0-flow-protocol-mqtt-bridge
version: 0.1.0
description: "MQTT Bridge 协议配置指南。从外部 MQTT Broker 订阅数据，经格式转换后发布到 Tier0 UNS。"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [flow, mqtt, bridge, protocol, sourceflow]
---

# MQTT Bridge — 外部 MQTT → Tier0 UNS

## 何时使用

- 用户要把外部 MQTT Broker（设备直连、第三方系统、云平台）的数据接入 Tier0 UNS
- 用户说"MQTT 接入"、"桥接 MQTT"、"外部 MQTT 数据写入 UNS"
- 设备已经在发 MQTT 消息，只需转换格式

## 不应该使用

- 用户要从 Modbus/OPC-UA 设备直接采集 → 走对应协议文档
- 用户要读取 UNS 当前值 → 走 `uns/references/read.md`

## 不可违反规则

1. **先备份再部署** — 对现有 Flow 部署前必须先 `tier0 flow data --id <id> --out backup.json`
2. **value 是对象** — Tier0 UNS 的 `value` 必须是字段名→值的对象，不能是裸数字或裸字符串
3. **先查 UNS topic 结构** — 写 function 前先 `tier0 uns browse --path <父路径> --include-metadata` 确认 topic 的字段定义
4. **外部 broker 用独立 config 节点** — 不要和 Tier0 内置 MQTT 共用同一个 mqtt-broker config
5. **必须复用系统颁发的 Tier0 mqtt-broker config 节点** — 见下方"⚠️ Tier0 内置 MQTT 账号密码"说明，禁止自行新建或修改该节点的凭据字段

## ⚠️ Tier0 内置 MQTT 账号密码

**Tier0 MQTT Broker（EMQX）启用了认证，拒绝匿名连接。** 账号密码仅在系统创建 Flow 时自动颁发，AI Agent 无法自行生成或查询。

### 凭据的来源与生命周期

| 阶段 | 发生了什么 |
|------|-----------|
| `tier0 flow create` | 后端自动生成 `clientid`、`username`（格式 `{workspaceId}&{connId}`）和随机 30 位 `password` |
| 初始部署 | 凭据以明文写入 Node-RED `mqtt-broker` config 节点，Node-RED 加密后持久化存储 |
| `tier0 flow data` 导出 | **Node-RED 不导出密码原文**，`credentials` 字段为空或缺失 |
| `tier0 flow deploy` | Node-RED 以 **节点 `id`** 为 key 匹配内部存储的凭据 |

### AI Agent 操作规则

- **必须先 `tier0 flow data --id <id> --out backup.json`，从中找到 `"type": "mqtt-broker"` 且连接 Tier0 EMQX 的 config 节点，记录其 `id` 字段**
- 生成新 flowsJson 时，**原样保留**该 mqtt-broker 节点（同 `id`、同 `broker`、同 `clientid`，`credentials` 可省略）
- **禁止**删除、替换或新建 Tier0 侧的 mqtt-broker config 节点，否则 Node-RED 找不到已存储的凭据，连接必然失败
- **禁止**向 Tier0 mqtt-broker 节点写入任何自定义的 `credentials.user` / `credentials.password`

### 如果 Flow 不是通过系统创建的

手动创建的 Node-RED 容器没有系统颁发的账号密码，无法连接 Tier0 MQTT Broker。必须通过 `tier0 flow create` 先创建 Flow，由系统生成凭据后再进行配置。

---

## 节点架构

```
[mqtt-broker: 外部]  ← config 节点，指向外部 MQTT Broker
[mqtt-broker: Tier0] ← config 节点，指向 Tier0 内置 MQTT（localhost:1883）

[mqtt in] → [function: 格式转换] → [mqtt out]
 外部topic              ↓ 失败            Tier0 UNS 路径
                   [debug: 错误]
```

## 节点说明

### mqtt-broker（外部连接配置）

| 关键字段 | 说明 | 示例 |
|---------|------|------|
| `broker` | 外部 Broker 地址 | `192.168.1.50` |
| `port` | 端口 | `1883`（标准）/ `8883`（TLS）|
| `clientid` | 客户端 ID | 留空自动生成 |
| `usetls` | 是否 TLS | `false` |
| `credentials.user/password` | 认证信息（如需） | — |

### mqtt in（订阅外部 topic）

| 关键字段 | 说明 | 示例 |
|---------|------|------|
| `topic` | 订阅的 topic（支持通配符 +/#） | `devices/+/data` |
| `qos` | 服务质量 | `0`（至多一次）/ `1`（至少一次）|
| `broker` | 引用外部 mqtt-broker config | — |

**输出 msg 结构（外部设备发来的原始消息）：**

```json
{
  "topic": "devices/line1/data",
  "payload": "...",
  "qos": 0,
  "retain": false
}
```

`msg.payload` 的格式取决于外部设备，可能是 JSON 字符串、纯数字或自定义格式。

### function（格式转换）

将外部 MQTT 消息转换为 Tier0 UNS 格式。这是**核心业务逻辑**，按实际情况编写。

**常见场景 1：外部 payload 是 JSON，直接提取字段**

```javascript
var data;
try {
    data = (typeof msg.payload === "string") ? JSON.parse(msg.payload) : msg.payload;
} catch(e) {
    node.warn("JSON parse error: " + e.message);
    return null;
}

// 从外部 topic 解析 UNS 路径（按实际约定修改）
// 例：外部 topic "devices/line1/temperature" → UNS "Plant/Line1/Metric/Temperature"
var parts = msg.topic.split("/");
var deviceId = parts[1];  // "line1"

msg.topic   = "Plant/" + deviceId.charAt(0).toUpperCase() + deviceId.slice(1) + "/Metric/Temperature";
msg.payload = JSON.stringify({ temperature: data.value });
return msg;
```

**常见场景 2：外部 payload 是裸数字**

```javascript
var rawValue = parseFloat(msg.payload);
if (isNaN(rawValue)) return null;

// 固定映射到 UNS topic
msg.topic   = "Plant/Line1/Metric/Temperature";
msg.payload = JSON.stringify({ temperature: rawValue });
return msg;
```

**常见场景 3：一个外部 topic 包含多个字段，拆分为多个 UNS topic**

```javascript
var data = JSON.parse(msg.payload);
var messages = [];

messages.push({
    topic:   "Plant/Line1/Metric/Temperature",
    payload: JSON.stringify({ temperature: data.temp })
});
messages.push({
    topic:   "Plant/Line1/Metric/Humidity",
    payload: JSON.stringify({ humidity: data.humi })
});

return messages;  // 返回数组，Node-RED 会分别发送每条消息
```

### mqtt out（发布到 Tier0 UNS）

| 关键字段 | 说明 | 值 |
|---------|------|-----|
| `topic` | 留空，由 `msg.topic` 动态设置 | `""` |
| `qos` | 服务质量 | `0` |
| `retain` | 是否保留消息 | `false` |
| `broker` | 引用 Tier0 内置 mqtt-broker config（**复用原有节点 id，不可新建**） | 系统颁发节点 |

> Tier0 内置 mqtt-broker config 节点由系统在创建 Flow 时自动生成，含系统颁发的 clientid/username/password。请从 `tier0 flow data` 导出的 JSON 中找到该节点并原样保留，不要替换。

## 快速部署流程

```bash
# 1. 确认 UNS topic 字段结构
tier0 uns browse --path Plant/Line1 --include-metadata

# 2. 确认目标 SourceFlow ID
tier0 flow list --source

# 3. 备份现有画布
tier0 flow data --id <id> --out backup.json

# 4. 根据任务生成 Flow JSON（参考下方示例结构）

# 5. 部署（需用户确认）
tier0 flow deploy --id <id> -f my-mqtt-bridge.json --yes
```

## 示例 Flow 结构（AI Agent 按此结构生成，不是照搬）

> **重要**：`broker-tier0` 节点只是占位说明，**实际操作时必须用 `tier0 flow data` 导出的现有 mqtt-broker 节点 id 替换**，不能使用此示例 id，也不能填入 credentials。

```json
[
  { "id": "tab-1", "type": "tab", "label": "MQTT Bridge" },

  { "id": "broker-ext", "type": "mqtt-broker", "name": "外部 MQTT",
    "broker": "192.168.1.50", "port": 1883 },

  {
    "id": "<从 flow data 导出的原有 mqtt-broker 节点 id，如 a1b2c3d4>",
    "type": "mqtt-broker",
    "name": "emqx",
    "broker": "<系统配置的 EMQX 地址，从 flow data 中原样复制>",
    "port": "1883",
    "clientid": "<系统颁发，从 flow data 中原样复制>",
    "credentials": {}
  },

  { "id": "mqtt-in-1", "type": "mqtt in", "z": "tab-1",
    "topic": "devices/+/data", "qos": "0", "broker": "broker-ext",
    "name": "订阅外部设备数据",
    "x": 160, "y": 120,
    "wires": [["fn-transform"]] },

  { "id": "fn-transform", "type": "function", "z": "tab-1",
    "name": "格式转换",
    "func": "// 按实际任务编写转换逻辑\nvar data = JSON.parse(msg.payload);\nmsg.topic = \"Plant/Line1/Metric/Temperature\";\nmsg.payload = JSON.stringify({ temperature: data.value });\nreturn msg;",
    "outputs": 1,
    "x": 400, "y": 120,
    "wires": [["mqtt-out-uns"]] },

  { "id": "mqtt-out-uns", "type": "mqtt out", "z": "tab-1",
    "topic": "", "qos": "0", "retain": false,
    "broker": "<同上，系统 mqtt-broker 节点 id>",
    "name": "发布到 UNS",
    "x": 640, "y": 120,
    "wires": [] }
]
```

## 常见问题

| 现象 | 原因 | 解决 |
|------|------|------|
| mqtt in 节点红色 | 无法连接外部 Broker | 检查 IP、端口、认证信息；确认防火墙放行 |
| UNS 收不到数据 | payload 格式错误 | 在 function 前加 debug 节点确认原始 payload；检查 JSON.parse 是否报错 |
| value 写入失败 | 字段名不匹配 UNS schema | 先 `uns browse --include-metadata` 查 fields 定义 |
| 外部消息丢失 | qos=0 且网络抖动 | 外部 Broker 使用 `qos: 1`；注意设备是否支持 qos 1 |
| 消息重复发布 | 多个 mqtt in 订阅同一 topic | 检查是否有重复的 mqtt in 节点或通配符重叠 |
