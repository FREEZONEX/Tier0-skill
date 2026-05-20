---
name: tier0-flow-protocol-modbus
version: 0.3.0
description: "Modbus TCP/RTU 协议节点配置指南。通过 node-red-contrib-modbus 节点采集 PLC 数据并发布到 UNS。"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [flow, modbus, protocol, plc, sourceflow]
---

# Modbus TCP/RTU — 协议节点配置

## 何时使用

- 用户要从 Modbus TCP/RTU 设备（PLC、变频器、仪表等）采集数据发布到 UNS
- 用户要创建或修改 SourceFlow 的 Modbus 采集配置
- 用户说"采集 Modbus"、"读 PLC 寄存器"、"Modbus 采集到 UNS"

## 不应该使用

- 用户要查询已采集数据的历史值 → 走 `uns/references/history.md`
- 用户要读当前 UNS 数据点的值 → 走 `uns/references/read.md`
- 用户要修改 Flow 元数据（改名、描述）→ 走 `references/update.md`

## 不可违反规则

1. **先备份再部署** — 对现有 Flow 部署前必须先 `tier0 flow data --id <id> --out backup.json`
2. **function 节点必须写** — 模板里 `{{FUNCTION_BODY}}` 不能留空，必须根据 topic 字段定义填写映射逻辑
3. **value 是对象** — UNS write 的 `value` 必须是字段名→值的对象，不能是裸数字
4. **先查 UNS topic 结构** — 写 function 前必须先 `tier0 api /openapi/v1/uns/browse --body '{"path":"<父路径>","include_metadata":true}'` 确认 topic 的字段定义
5. **地址是 0-based** — Modbus `adr` 从 0 开始，对应设备文档的地址 1（如设备文档写地址 40001，实际 `adr` = 0）

## 节点架构

```
[modbus-client] ← 连接配置（config 节点，不显示在画布）
      ↓ 引用
[modbus-read] → output1 → [function] → [mqtt out] → UNS
                output2 → [modbus-response] （可选，调试用）
```

## 节点说明

### modbus-client（连接配置）

config 节点，不出现在画布上，被 `modbus-read` 的 `server` 字段引用。

| 关键字段 | 说明 | 示例 |
|---------|------|------|
| `clienttype` | 连接类型 | `tcp`（TCP/IP）、`serial`（串口） |
| `tcpHost` | 设备 IP | `192.168.1.100` |
| `tcpPort` | 端口（Modbus TCP 默认 502） | `502` |
| `unit_id` | 从站 ID（1–247） | `1` |
| `clientTimeout` | 超时 ms | `1000` |
| `reconnectTimeout` | 重连等待 ms | `2000` |

### modbus-read（周期轮询）

自动按固定频率读取，无需 inject 触发。

| 关键字段 | 说明 | 值 |
|---------|------|-----|
| `dataType` | 寄存器类型 | `Coil` / `Input` / `HoldingRegister` / `InputRegister` |
| `adr` | 起始地址（0-based） | `0` |
| `quantity` | 读取数量 | `10` |
| `rate` + `rateUnit` | 轮询频率 | `1` + `s` = 每秒一次 |
| `server` | 引用 modbus-client 的 id | `modbus_client_xxx` |

**dataType 对应 Modbus 功能码：**

| dataType | FC | 说明 |
|----------|-----|------|
| `Coil` | FC 1 | 线圈（数字量输出，可读写） |
| `Input` | FC 2 | 离散输入（数字量输入，只读） |
| `HoldingRegister` | FC 3 | 保持寄存器（16-bit，常用） |
| `InputRegister` | FC 4 | 输入寄存器（16-bit，只读） |

**输出 msg 结构：**

```json
{
  "payload": {
    "data": [1234, 5678, 0, ...],   // 寄存器/线圈值数组
    "buffer": "<Buffer ...>",        // 原始字节
    "fc": 3,                         // 功能码
    "byteCount": 20
  },
  "topic": "",
  "modbus": { ... }
}
```

### function（数据映射）

将 `msg.payload.data` 数组映射为 UNS write body，这是**必须手写**的业务逻辑。

**写法规范：**

```javascript
var registers = msg.payload.data;  // 原始数组
var writes = [];

// 按 UNS topic 字段定义构造 value 对象
writes.push({
  topic: "Plant/Line1/Metric/Temperature",
  value: {
    temperature: registers[0] * 0.1,  // 缩放系数根据设备文档
    unit: "°C"
  }
});

// 可以一次 write 多个 topic
writes.push({
  topic: "Plant/Line1/State/MachineStatus",
  value: {
    running: registers[1] === 1,
    speed: registers[2]
  }
});

msg.payload = JSON.stringify({ writes: writes });
return msg;
```

> **关键**：`value` 字段必须和 UNS topic 的字段定义一致。先用 `uns/references/browse.md` 查看 topic 结构再写 function。

## 快速部署流程

```bash
# 1. 确认 UNS topic 字段结构
tier0 api /openapi/v1/uns/browse --body '{"path":"Plant/Line1","include_metadata":true}'

# 2. 确认目标 Flow ID
tier0 flow list --source

# 3. 备份现有画布
tier0 flow data --id <id> --out backup.json

# 4. 下载模板，替换占位符
# 参考 templates/README.md 了解每个占位符的含义

# 5. 部署（需用户确认）
tier0 flow deploy --id <id> -f my-modbus.json --yes
```

## 典型示例

**场景：读 Line1 PLC 的 10 个保持寄存器，发布到 UNS**

```json
占位符替换：
  {{FLOW_ID}}         → "line1_modbus"
  {{FLOW_NAME}}       → "Line1 Modbus 采集"
  {{DEVICE_NAME}}     → "Line1 PLC"
  {{MODBUS_HOST}}     → "192.168.1.100"
  {{MODBUS_PORT}}     → 502
  {{UNIT_ID}}         → 1
  {{READ_NODE_NAME}}  → "读保持寄存器 HR0-9"
  {{DATA_TYPE}}       → "HoldingRegister"
  {{START_ADDRESS}}   → "0"
  {{QUANTITY}}        → "10"
  {{POLL_RATE}}       → "1"
  {{POLL_RATE_UNIT}}  → "s"
  {{MQTT_HOST}}       → "localhost"
  {{MQTT_PORT}}       → 1883
  {{UNS_TOPIC}}       → "Plant/Line1/Metric/Temperature"
  {{FUNCTION_BODY}}   →
    var r = msg.payload.data;
    writes.push({ topic: "Plant/Line1/Metric/Temperature",
                  value: { temperature: r[0] * 0.1, unit: "°C" } });
    writes.push({ topic: "Plant/Line1/Metric/Humidity",
                  value: { humidity: r[1] * 0.1 } });
```

## 常见问题

| 现象 | 原因 | 解决 |
|------|------|------|
| modbus-read 节点一直红色 | 连接不上 PLC | 检查 IP、端口、unit_id；确认 PLC 开启 Modbus TCP 服务 |
| `msg.payload.data` 全是 0 | 地址偏移错误 | `adr` 从 0 开始，对应设备文档地址需 -1 |
| UNS 收不到数据 | MQTT broker 配置错误 | 检查 `{{MQTT_HOST}}` 和端口；确认 Tier0 平台 MQTT 地址 |
| value 写入失败 | 字段不匹配 UNS schema | 先 browse 查 topic 字段定义，再写 function |
| 数据漂移/不稳定 | 轮询过快或无缩放 | 调大 `rate`；检查缩放系数是否和设备文档一致 |
