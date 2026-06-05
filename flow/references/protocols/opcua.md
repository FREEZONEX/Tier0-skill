---
name: tier0-flow-protocol-opcua
version: 0.1.0
description: "OPC-UA 协议节点配置指南。通过 node-red-contrib-opcua 节点订阅 OPC-UA Server 数据并发布到 UNS。"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [flow, opcua, opc-ua, protocol, plc, sourceflow]
---

# OPC-UA — 协议节点配置

## 何时使用

- 用户要从 OPC-UA Server（PLC、SCADA、工业网关等）订阅数据发布到 UNS
- 用户要创建或修改 SourceFlow 的 OPC-UA 采集配置
- 用户说"采集 OPC-UA"、"订阅 OPC UA"、"OPC-UA 数据采集到 UNS"

## 不应该使用

- 用户要查询已采集数据的历史值 → 走 `uns/references/history.md`
- 用户要读当前 UNS 数据点的值 → 走 `uns/references/read.md`
- 用户要修改 Flow 元数据（改名、描述）→ 走 `flow/references/update.md`

## 不可违反规则

1. **先备份再部署** — 对现有 Flow 部署前必须先 `tier0 flow data --id <id> --out backup.json`
2. **subscribe 只触发一次** — `inject` 节点设置 `once=true`，启动时触发一次即可持续订阅，不要用定时重复触发
3. **value 是对象** — UNS write 的 `value` 必须是字段名→值的对象，不能是裸数字
4. **先查 UNS topic 结构** — 写 function 前先 `tier0 uns browse --path <父路径> --include-metadata` 确认 topic 的字段定义
5. **nodeId 格式** — OPC-UA 节点 ID 格式为 `ns=<命名空间>;s=<字符串>` 或 `ns=<命名空间>;i=<数字>`，必须与服务器完全一致

## 节点架构

```
[OpcUa-Endpoint]  ← config 节点（不在画布上），被 OpcUa-Client 引用
[mqtt-broker]     ← config 节点，Tier0 内置 MQTT

[inject(once)] → [function: 标签列表] → [OpcUa-Client(subscribe)] → wire[0] → [function: 映射 UNS] → [mqtt out]
                                                                   → wire[1] → [debug: 状态]
```

## 节点说明

### OpcUa-Endpoint（连接配置）

config 节点，不出现在画布上，被 `OpcUa-Client` 的 `endpoint` 字段引用。

| 关键字段 | 说明 | 示例 |
|---------|------|------|
| `endpoint` | OPC-UA 服务器地址 | `opc.tcp://192.168.1.200:4840` |
| `secpol` | 安全策略 | `None`（明文，工厂内网常用） |
| `secmode` | 消息安全模式 | `None` |
| `none` | 是否匿名登录 | `true`（匿名）|
| `login` | 是否用户名+密码 | `false`（匿名时留 false） |

### OpcUa-Client（订阅客户端）

| 关键字段 | 说明 | 值 |
|---------|------|-----|
| `action` | 操作类型 | `subscribe`（变更触发推送）|
| `time` + `timeUnit` | 订阅采样间隔 | `1` + `s` = 每秒采样一次 |
| `deadbandtype` | 死区类型（monitor 模式） | `a`（绝对）|
| `deadbandvalue` | 死区值 | `1`（变化超过此值才推送）|
| `endpoint` | 引用 OpcUa-Endpoint config 节点 | — |

**3 个输出端口：**

| 端口 | 内容 |
|------|------|
| wire[0] | 数据：`msg.payload` = OPC-UA DataValue，`msg.topic` = nodeId |
| wire[1] | 状态：`msg.payload.status` = 连接状态字符串，`msg.payload.error` = 错误信息 |
| wire[2] | 错误（旧版，通常不用）|

### 订阅触发方式

**单标签**（OpcUa-Item → OpcUa-Client）：

```
inject → OpcUa-Item(ns=2;s=Temperature) → OpcUa-Client(subscribe)
```

**多标签**（推荐，function 构造数组 → OpcUa-Client）：

```javascript
// function 节点：构造 nodeId 数组
msg.topic = "multiple";
msg.payload = [
  { nodeId: "ns=2;s=Temperature" },
  { nodeId: "ns=2;s=Humidity" },
  { nodeId: "ns=2;s=ProductionCount" }
];
return msg;
```

### 订阅输出 msg 结构

```json
{
  "topic": "ns=2;s=Temperature",
  "payload": {
    "value": {
      "value": 27.5,
      "dataType": "Double"
    },
    "statusCode": { "value": 0 },
    "sourceTimestamp": "2026-01-01T08:00:00.000Z",
    "serverTimestamp": "2026-01-01T08:00:00.001Z"
  }
}
```

### function（数据映射）

从 OPC-UA DataValue 提取值，映射到 UNS topic 路径，构造 MQTT 消息。

```javascript
// wire[0] 的数据处理
var dv = msg.payload;

// 提取实际值
var rawValue = (dv && dv.value) ? dv.value.value : null;
if (rawValue === null || rawValue === undefined) return null;

// 质量判断：statusCode.value === 0 为 Good
var quality = (dv.statusCode && dv.statusCode.value === 0) ? "Good" : "Bad";

// nodeId → UNS topic 路径映射表（按实际配置填写）
var topicMap = {
  "ns=2;s=Temperature":    "Plant/Line1/Metric/Temperature",
  "ns=2;s=Humidity":       "Plant/Line1/Metric/Humidity",
  "ns=2;s=ProductionCount":"Plant/Line1/Metric/ProductionCount"
};

var unsTopic = topicMap[msg.topic];
if (!unsTopic) return null;  // 未映射的标签忽略

// UNS write body：value 必须是对象，字段名与 UNS topic 定义一致
var fieldName = unsTopic.split("/").pop().toLowerCase();  // 简单取叶子名作字段名
msg.topic   = unsTopic;
msg.payload = JSON.stringify({ [fieldName]: rawValue });
return msg;
```

> **提示**：字段名需与 `uns/references/create.md` 中 `--fields` 定义的 `name` 完全一致，不要靠猜测。

## 快速部署流程

```bash
# 1. 确认 UNS topic 字段结构
tier0 uns browse --path Plant/Line1 --include-metadata

# 2. 确认目标 SourceFlow ID
tier0 flow list --source

# 3. 备份现有画布
tier0 flow data --id <id> --out backup.json

# 4. 填写模板中的占位符（见下文）

# 5. 部署（需用户确认）
tier0 flow deploy --id <id> -f my-opcua.json --yes
```

## Node-RED JSON 模板

下面是可直接导入的完整 Flow JSON。替换所有 `{{...}}` 占位符后部署。

| 占位符 | 说明 | 示例 |
|--------|------|------|
| `{{OPCUA_ENDPOINT}}` | OPC-UA Server 地址 | `opc.tcp://192.168.1.200:4840` |
| `{{MQTT_HOST}}` | Tier0 MQTT 地址 | `localhost` |
| `{{MQTT_PORT}}` | Tier0 MQTT 端口 | `1883` |
| `{{SUBSCRIBE_INTERVAL}}` | 采样间隔（秒） | `1` |
| `{{NODEID_ARRAY}}` | 订阅的 nodeId 列表（JS 数组字面量） | 见示例 |
| `{{TOPIC_MAP}}` | nodeId → UNS 路径映射（JS 对象字面量） | 见示例 |
| `{{FLOW_LABEL}}` | Flow 标签名 | `OPC-UA Line1 采集` |

```json
[
  {
    "id": "tab-opcua-collect",
    "type": "tab",
    "label": "{{FLOW_LABEL}}",
    "disabled": false,
    "info": "OPC-UA 订阅采集，发布到 Tier0 UNS"
  },
  {
    "id": "cfg-opcua-ep",
    "type": "OpcUa-Endpoint",
    "endpoint": "{{OPCUA_ENDPOINT}}",
    "secpol": "None",
    "secmode": "None",
    "none": true,
    "login": false,
    "usercert": false
  },
  {
    "id": "cfg-mqtt-tier0",
    "type": "mqtt-broker",
    "name": "Tier0 MQTT",
    "broker": "{{MQTT_HOST}}",
    "port": {{MQTT_PORT}},
    "clientid": "",
    "autoConnect": true,
    "usetls": false,
    "keepalive": 60,
    "cleansession": true
  },
  {
    "id": "inject-start",
    "type": "inject",
    "z": "tab-opcua-collect",
    "name": "启动订阅（部署后自动触发一次）",
    "repeat": "",
    "crontab": "",
    "once": true,
    "onceDelay": 1,
    "topic": "",
    "payload": "",
    "payloadType": "str",
    "x": 160,
    "y": 120,
    "wires": [["fn-build-items"]]
  },
  {
    "id": "fn-build-items",
    "type": "function",
    "z": "tab-opcua-collect",
    "name": "订阅标签列表",
    "func": "// 多标签订阅：构造 nodeId 数组\nmsg.topic = \"multiple\";\nmsg.payload = {{NODEID_ARRAY}};\nreturn msg;",
    "outputs": 1,
    "x": 400,
    "y": 120,
    "wires": [["opcua-client-sub"]]
  },
  {
    "id": "opcua-client-sub",
    "type": "OpcUa-Client",
    "z": "tab-opcua-collect",
    "endpoint": "cfg-opcua-ep",
    "action": "subscribe",
    "deadbandtype": "a",
    "deadbandvalue": 0,
    "time": {{SUBSCRIBE_INTERVAL}},
    "timeUnit": "s",
    "certificate": "n",
    "localfile": "",
    "localkeyfile": "",
    "securitymode": "None",
    "securitypolicy": "None",
    "useTransport": false,
    "maxChunkCount": 1,
    "maxMessageSize": 65536,
    "receiveBufferSize": 65536,
    "sendBufferSize": 65536,
    "setstatusandtime": false,
    "keepsessionalive": true,
    "name": "OPC-UA 订阅",
    "x": 640,
    "y": 120,
    "wires": [
      ["fn-to-uns"],
      ["debug-status"]
    ]
  },
  {
    "id": "fn-to-uns",
    "type": "function",
    "z": "tab-opcua-collect",
    "name": "OPC-UA → UNS 映射",
    "func": "var dv = msg.payload;\nvar rawValue = (dv && dv.value) ? dv.value.value : null;\nif (rawValue === null || rawValue === undefined) return null;\n\nvar quality = (dv.statusCode && dv.statusCode.value === 0) ? \"Good\" : \"Bad\";\n\n// nodeId → UNS topic 路径 + 字段名映射\n// 格式: \"nodeId\": { topic: \"UNS路径\", field: \"字段名\" }\nvar topicMap = {{TOPIC_MAP}};\n\nvar mapping = topicMap[msg.topic];\nif (!mapping) return null;\n\nmsg.topic   = mapping.topic;\nmsg.payload = JSON.stringify({ [mapping.field]: rawValue });\nreturn msg;",
    "outputs": 1,
    "x": 880,
    "y": 80,
    "wires": [["mqtt-out-uns"]]
  },
  {
    "id": "debug-status",
    "type": "debug",
    "z": "tab-opcua-collect",
    "name": "OPC-UA 连接状态",
    "active": true,
    "tosidebar": true,
    "console": false,
    "tostatus": true,
    "complete": "payload",
    "targetType": "msg",
    "x": 880,
    "y": 160,
    "wires": []
  },
  {
    "id": "mqtt-out-uns",
    "type": "mqtt out",
    "z": "tab-opcua-collect",
    "name": "发布到 UNS",
    "topic": "",
    "qos": "0",
    "retain": false,
    "respTopic": "",
    "contentType": "",
    "userProps": "",
    "correl": "",
    "expiry": "",
    "broker": "cfg-mqtt-tier0",
    "x": 1120,
    "y": 80,
    "wires": []
  }
]
```

### 完整占位符填写示例

**场景：采集 Line1 PLC 温度、湿度、产量三个标签**

```
{{OPCUA_ENDPOINT}}   → opc.tcp://192.168.1.200:4840
{{MQTT_HOST}}        → localhost
{{MQTT_PORT}}        → 1883
{{SUBSCRIBE_INTERVAL}} → 1
{{FLOW_LABEL}}       → OPC-UA Line1 采集

{{NODEID_ARRAY}} →
[
  { "nodeId": "ns=2;s=Temperature" },
  { "nodeId": "ns=2;s=Humidity" },
  { "nodeId": "ns=2;s=ProductionCount" }
]

{{TOPIC_MAP}} →
{
  "ns=2;s=Temperature":     { "topic": "Plant/Line1/Metric/Temperature",     "field": "temperature" },
  "ns=2;s=Humidity":        { "topic": "Plant/Line1/Metric/Humidity",         "field": "humidity" },
  "ns=2;s=ProductionCount": { "topic": "Plant/Line1/Metric/ProductionCount",  "field": "value" }
}
```

## 常见问题

| 现象 | 原因 | 解决 |
|------|------|------|
| OpcUa-Client 节点红色 / `connecting` 卡住 | 无法连接 OPC-UA Server | 检查 endpoint URL；确认服务器开放了 4840 端口；network 可达 |
| 订阅后收不到数据 | nodeId 拼写错误 | 用 `OpcUa-Browser` 节点浏览服务器节点树，复制正确的 nodeId |
| `msg.payload.value.value` 为 null | 订阅未生效或服务器无此变量 | 检查 nodeId 是否存在；查看 wire[1] 状态输出 |
| UNS 收不到数据 | MQTT topic 或 payload 格式错误 | 检查 mqtt out 节点 topic 是否正确设置为 UNS 路径；payload 是否是 JSON 字符串 |
| 数据质量 Bad | OPC-UA 服务器报告节点状态异常 | 检查 PLC 侧该变量是否正常；statusCode.value 非 0 时丢弃或告警 |
| 订阅延迟高 | 采样间隔太大 | 调小 `time`（如 `100` ms）；注意过小可能增加服务器负载 |
