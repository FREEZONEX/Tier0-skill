---
name: tier0-uns-write
version: 0.4.16
description: "向 UNS topic 写入数据（对象值）。triggers: Tier0, UNS, 写入, 数据点, 发布, 上报"
metadata:
  requires:
    bins: ["tier0"]
  hermes:
    tags: [uns, write, data]
---

# write — 写入数据点

## 说明

向一个或多个 UNS topic 写入值。**不支持通配符**，必须明确指定 topic。

`value` 是业务数据对象，需符合该 topic 已声明的 `fields` 定义（若有）。写入成功仅代表 MQTT Broker 已收到，不代表下游执行完成——如需确认结果请用 `/read` 查对应 State topic。

> **注意**：写入时通常不需要传 `quality`，平台会根据 Broker ack 结果自动设置。若上游协议有明确的质量信息可按需传入。

## API

```
POST /openapi/v1/uns/write
```

## 请求参数

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `writes` | WriteItem[] | 是 | 写入项列表 |
| `qos` | int64 | 否 | MQTT QoS 等级（0 / 1 / 2），默认 0，全局作用于本次所有写入 |
| `retain` | boolean | 否 | 是否设置 MQTT retain 标志，默认 false |

### WriteItem

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `topic` | string | 是 | 目标 topic，不支持通配符 |
| `value` | any | 是 | 写入值，通常是包含多个字段的对象 |
| `quality` | string | 否 | 数据质量（`Good` / `Uncertain` / `Bad`），默认由平台按 Broker ack 结果设置 |
| `timeStamp` | int64 | 否 | 毫秒时间戳，默认服务端当前时间 |

## 写入前：确认 Schema

**不知道 topic 的字段定义时，必须先查再写，不要猜测字段名。**

```bash
# 查看 topic 元数据（fields 定义 + description 示例）
tier0 uns browse --path Plant/Line1/Metric/Temperature
```

返回的节点信息中：
- `fields` — metric 节点的字段类型约束（如 `[{"name":"value","type":"float","unit":"°C"}]`）
- `description` — 创建者写入的说明，**应包含示例 payload**，action/state 节点尤其依赖此处说明
- `topicType` — 确认是 metric / action / state，决定 value 的结构风格

拿到 schema 或示例后再构造 `value`，避免因字段名错误或类型不匹配导致写入被拒。

## 示例

### 写入多字段对象（典型 OT 场景）

```bash
tier0 uns write --topic Plant/Line1/Metric/Temperature --value '{"temperature":27.5,"unit":"C","humidity":58.6}'
```

### 写入业务状态对象（IT 场景）

```bash
tier0 uns write --topic Plant/Warehouse/State/OrderStatus --value '{"pending":42,"processing":15}'
```

### 触发动作指令

```bash
tier0 uns write --topic Plant/Line1/Action/EmergencyStop --value '{"command":"stop","reason":"温度超阈值","triggered_by":"agent"}'
```

### 批量写入（含 QoS 和 retain）

```bash
tier0 uns write --file writes.json
```

`writes.json` 内容：
```json
{
  "writes": [
    {
      "topic": "Plant/Line1/Metric/Temperature",
      "value": { "temperature": 27.5, "unit": "C", "humidity": 58.6 }
    },
    {
      "topic": "Plant/Warehouse/Metric/StockLevel",
      "value": { "sku_A": 120, "sku_B": 8 }
    }
  ],
  "qos": 1,
  "retain": true
}
```

## 响应结构

**HTTP 200 + 外层 `code:200` 不代表所有写入成功，必须检查 `data.success`（整体）和 `data.results[i].success`（逐项）**。单条失败不影响其他条（部分成功场景）：

```json
{
  "code": 200,
  "msg": "ok",
  "data": {
    "success": true,
    "results": [
      { "success": true, "topic": "Plant/Line1/Metric/Temperature", "result": null }
    ]
  }
}
```

单条失败（schema 校验不通过 / topic 不存在）：

```json
{
  "success": false,
  "topic": "Plant/Warehouse/Metric/StockLevel",
  "error": { "code": 400, "message": "Schema validation failed: sku_A must be integer" }
}
```

## 确认写入结果

写入成功 ≠ 下游执行完成，如需验证请用 read 查 State topic：

```bash
tier0 uns write --topic Plant/Line1/Action/EmergencyStop --value '{"command":"stop"}'
tier0 uns read Plant/Line1/State/MachineStatus
```

## Windows PowerShell 注意

value 含嵌套 JSON 时用文件法更稳妥：

```powershell
tier0 uns write --topic Plant/Line1/Metric/Temperature --value '{"temperature":27.5,"unit":"C"}'
# 或批量写入
tier0 uns write --file writes.json
```
