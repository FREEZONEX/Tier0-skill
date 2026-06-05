---
name: tier0-flow-protocol-opcda
version: 0.1.0
description: "OPC-DA 协议节点配置指南。通过 @tier0/node-red-contrib-opcda-client 节点周期读取 OPC-DA Server 数据并发布到 UNS。"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [flow, opcda, opc-da, dcom, protocol, plc, sourceflow]
---

# OPC-DA — 协议节点配置

## 何时使用

- 用户要从 OPC-DA Server（老旧 SCADA、DCS、仪表系统）采集数据发布到 UNS
- 设备只支持 OPC-DA（不支持 OPC-UA）
- 用户说"OPC DA 采集"、"DCOM 读取"、"老系统 OPC 接入"

## 不应该使用

- 设备支持 OPC-UA → 优先走 `opcua.md`（OPC-UA 更现代、跨平台）
- 用户要查询已采集数据历史值 → 走 `uns/references/history.md`

## ⚠️ 重要限制

**OPC-DA 基于 Windows DCOM，运行 SourceFlow 的 Node-RED 容器必须运行在 Windows 宿主机或能访问目标 Windows 机器的网络环境中。** Linux 容器无法直接连接 OPC-DA Server。

## 不可违反规则

1. **先备份再部署** — 对现有 Flow 部署前必须先 `tier0 flow data --id <id> --out backup.json`
2. **ClsId 必须精确** — OPC Server 的 ClsId 是 GUID 格式，错一位连接失败，需从注册表或 OPC 客户端工具获取
3. **ItemID 路径与 OPC Server 一致** — 不同厂商格式不同（如 `Siemens.S7-300.1` 或 `Channel1.Device1.Tag1`）
4. **value 是对象** — UNS write 的 `value` 必须是字段名→值的对象，不能是裸数字
5. **先查 UNS topic 结构** — 写 function 前先 `tier0 uns browse --path <父路径> --include-metadata` 确认字段定义

## 节点架构

```
[tier0-opcda-server] ← config 节点（不在画布），被 tier0-opcda-read 引用

[inject(repeat)] → [tier0-opcda-read] → [function: 映射 UNS] → [mqtt out]
 周期触发                ↓ 返回数组
                    [{itemID, value, quality, timestamp}, ...]
```

## 节点说明

### tier0-opcda-server（连接配置）

config 节点，不出现在画布上，被 `tier0-opcda-read` 的 `server` 字段引用。

| 关键字段 | 说明 | 示例 |
|---------|------|------|
| `address` | OPC-DA Server 所在机器 IP 或主机名 | `192.168.1.100` |
| `domain` | Windows 域名（无域环境留空或填机器名） | `WORKGROUP` |
| `username` | Windows 用户名 | `Administrator` |
| `password` | Windows 密码 | — |
| `clsid` | OPC Server 的 COM 类 ID（GUID） | `F8582CF2-88FB-11D0-B850-00C0F0104305` |
| `timeout` | 连接超时 ms | `5000` |

> **ClsId 获取方式**：在 OPC Server 所在机器上用 OPC Quick Client、MatrikonOPC Explorer 等工具浏览可用 OPC Server，复制对应 ClsId。或在注册表 `HKEY_CLASSES_ROOT\OPC.DA...` 下查找。

### tier0-opcda-read（周期读取）

需要 inject 节点周期触发（每次 input 消息触发一次读取）。

| 关键字段 | 说明 | 值 |
|---------|------|-----|
| `server` | 引用 tier0-opcda-server config 节点 | — |
| `groupitems` | 要读取的 OPC ItemID 列表 | `["Channel1.Tag1", "Channel1.Tag2"]` |
| `updaterate` | 读取速率参考（ms，影响 OPC Group 配置） | `1000` |
| `cache` | true=从 OPC Server 缓存读（快），false=直接从设备读（准） | `false` |
| `datachange` | true=只在值变化时发送消息 | `false` |

**输出 msg.payload 结构（数组，每个元素对应一个 ItemID）：**

```json
[
  {
    "itemID": "Channel1.Device1.Temperature",
    "value": 27.5,
    "quality": "GOOD",
    "timestamp": 1748000000000,
    "errorCode": 0
  },
  {
    "itemID": "Channel1.Device1.Humidity",
    "value": 58.3,
    "quality": "GOOD",
    "timestamp": 1748000000001,
    "errorCode": 0
  }
]
```

**quality 取值：**

| quality | 含义 | 处理建议 |
|---------|------|---------|
| `GOOD` | 数据有效 | 正常发布 |
| `BAD` | 数据无效 | 丢弃或告警 |
| `UNCERTAIN` | 数据可疑 | 按需处理，建议告警 |
| `UNKNOWN` | 未知状态 | 丢弃 |

### function（数据映射）

将读取结果数组映射为 UNS write 消息。**每个 ItemID 独立映射为一个 MQTT 消息。**

```javascript
// msg.payload = [{itemID, value, quality, timestamp, errorCode}, ...]
var items = msg.payload;
var messages = [];

// ItemID → UNS topic 路径 + 字段名映射表
var topicMap = {
  "Channel1.Device1.Temperature": { topic: "Plant/Line1/Metric/Temperature", field: "temperature" },
  "Channel1.Device1.Humidity":    { topic: "Plant/Line1/Metric/Humidity",    field: "humidity" },
  "Channel1.Device1.Production":  { topic: "Plant/Line1/Metric/ProductionCount", field: "value" }
};

for (var i = 0; i < items.length; i++) {
  var item = items[i];

  // 只发布 GOOD 质量数据
  if (item.quality !== "GOOD") continue;

  var mapping = topicMap[item.itemID];
  if (!mapping) continue;  // 未映射的标签忽略

  messages.push({
    topic:   mapping.topic,
    payload: JSON.stringify({ [mapping.field]: item.value })
  });
}

return messages.length > 0 ? messages : null;
```

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
tier0 flow deploy --id <id> -f my-opcda.json --yes
```

## 示例 Flow 结构（AI Agent 按此结构生成，不是照搬）

```json
[
  { "id": "tab-opcda", "type": "tab", "label": "OPC-DA 采集" },

  {
    "id": "cfg-opcda-srv",
    "type": "tier0-opcda-server",
    "name": "Line1 OPC-DA Server",
    "address": "192.168.1.100",
    "domain": "WORKGROUP",
    "clsid": "F8582CF2-88FB-11D0-B850-00C0F0104305",
    "timeout": 5000
  },

  { "id": "cfg-mqtt-tier0", "type": "mqtt-broker",
    "name": "Tier0 MQTT", "broker": "localhost", "port": 1883 },

  {
    "id": "inject-poll",
    "type": "inject",
    "z": "tab-opcda",
    "name": "每秒轮询",
    "repeat": "1",
    "once": true,
    "onceDelay": 0.5,
    "x": 160, "y": 120,
    "wires": [["opcda-read-1"]]
  },

  {
    "id": "opcda-read-1",
    "type": "tier0-opcda-read",
    "z": "tab-opcda",
    "name": "读取 Line1 标签",
    "server": "cfg-opcda-srv",
    "groupitems": [
      "Channel1.Device1.Temperature",
      "Channel1.Device1.Humidity",
      "Channel1.Device1.Production"
    ],
    "updaterate": 1000,
    "cache": false,
    "datachange": false,
    "x": 400, "y": 120,
    "wires": [["fn-to-uns"]]
  },

  {
    "id": "fn-to-uns",
    "type": "function",
    "z": "tab-opcda",
    "name": "OPC-DA → UNS 映射",
    "func": "var items = msg.payload;\nvar messages = [];\nvar topicMap = {\n  \"Channel1.Device1.Temperature\": { topic: \"Plant/Line1/Metric/Temperature\", field: \"temperature\" },\n  \"Channel1.Device1.Humidity\":    { topic: \"Plant/Line1/Metric/Humidity\",    field: \"humidity\" }\n};\nfor (var i = 0; i < items.length; i++) {\n  var item = items[i];\n  if (item.quality !== \"GOOD\") continue;\n  var m = topicMap[item.itemID];\n  if (!m) continue;\n  messages.push({ topic: m.topic, payload: JSON.stringify({ [m.field]: item.value }) });\n}\nreturn messages.length > 0 ? messages : null;",
    "outputs": 1,
    "x": 640, "y": 120,
    "wires": [["mqtt-out-uns"]]
  },

  {
    "id": "mqtt-out-uns",
    "type": "mqtt out",
    "z": "tab-opcda",
    "name": "发布到 UNS",
    "topic": "",
    "qos": "0",
    "retain": false,
    "broker": "cfg-mqtt-tier0",
    "x": 880, "y": 120,
    "wires": []
  }
]
```

## 常见问题

| 现象 | 原因 | 解决 |
|------|------|------|
| 节点一直 `Connecting` / `Timeout` | DCOM 连接失败 | 检查 address/domain/username/password；确认目标机器开放 DCOM 端口（135 + 动态端口）；检查防火墙 |
| 报错 `Clsid is not found` | ClsId 错误 | 用 OPC 客户端工具在目标机器上重新获取正确 ClsId |
| 报错 `Access denied` | 用户名/密码错误 | 确认 Windows 账户有权访问 OPC Server |
| `quality: "BAD"` 所有标签 | ItemID 不存在 | 在 OPC 客户端工具上浏览确认 ItemID 路径；大小写敏感 |
| UNS 收不到数据 | function 逻辑问题 | 在 function 前加 debug 节点确认 `msg.payload` 数组内容；检查 quality 过滤条件 |
| 读取延迟高 | inject 间隔太大 | 调小 `repeat` 值（如 `0.5` 秒）；注意 OPC Server 和网络承载能力 |
